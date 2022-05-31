"""Plate motion data requests using the [UNAVCO Plate Motion Calculator][1].

Exported names:
$(EXPORTS)

[1]: https://www.unavco.org/software/geodetic-utilities/plate-motion-calculator/plate-motion-calculator.html

"""
module PlateMotionRequests

export platemotion
export write_platemotion
export read_platemotion

using DelimitedFiles

using DataStructures
using Dates
using DocStringExtensions
using HTTP
using TOML
using NCDatasets
using TypedTables


# https://discourse.julialang.org/t/how-to-find-out-the-version-of-a-package-from-its-module/37755/15
const PACKAGE_VERSION = let
    project = TOML.parsefile(joinpath(pkgdir(@__MODULE__), "Project.toml"))
    VersionNumber(project["version"])
end


"""
    platemotion(lats, lons, heights; kwargs...)
    platemotion(lats, lons; kwargs...)

Request plate motion data from the [UNAVCO Plate Motion Calculator][1].
Headers and metadata are stripped from the output, which is parsed into a [`Table`][2].
Accepts either separate vectors for latitude, longitude and optionally height.

See also: [`write_platemotion`](@ref).

!!! note

    Site names are not supported.
    Only 'ansii', 'ansii_xyz' and 'psvelo' formats are supported.
    Not all optional argument permutations are permitted,
    see the website linked above for further details.

Optional arguments:
- `model`: The plate motion model to use for calculations, or GSRM v2.1 by default.
- `plate`: The tectonic plate of attributed motion, or automatic plate selection by default.
- `reference`: The fixed reference plate, or NNR (No Net Rotation) by default.
- `up_lat`: Custom coordinate of the Euler pole (attributed motion) in decimal degrees.
- `up_lon`: See above.
- `up_w`: Custom rotation rate (attributed motion) in degrees per million years.
- `up_x`: Custom component of the Euler pole (attributed motion) in degrees per million years.
- `up_y`: See above.
- `up_z`: See above.
- `ur_lat`: Custom coordinate of the Euler pole (reference velocity) in decimal degrees.
- `ur_lon`: See above.
- `ur_w`: Custom rotation rate of the Euler pole (reference velocity) in degrees per million years.
- `ur_x`: Custom component of the Euler pole (reference velocity) in degrees per million years.
- `ur_y`: See above.
- `ur_z`: See above.
- `format`: Output format for the data section of the response, or ASCII by default.

[1]: https://www.unavco.org/software/geodetic-utilities/plate-motion-calculator/plate-motion-calculator.html.
[2]: https://typedtables.juliadata.org/latest/man/table/

"""
function platemotion(lats, lons, heights = fill(0, length(lats)); kwargs...)
    request = parse_kwargs(kwargs)
    push!(
        request,
        :geo =>
            join(mapslices(x -> join(x, " "), hcat(lons, lats, heights), dims = 2), ",\n"),
    )
    return parse!(submit(request), request[:format])
end


function parse_kwargs(kwargs::Base.Iterators.Pairs)
    kwargs = Dict(kwargs)
    return Dict(
        :model => get(kwargs, :model, "gsrm_2014"),
        :plate => get(kwargs, :plate, ""),
        :reference => get(kwargs, :reference, "NNR"),
        :up_lat => String(get(kwargs, :up_lat, "")),
        :up_lon => String(get(kwargs, :up_lon, "")),
        :up_w => String(get(kwargs, :up_w, "")),
        :up_x => String(get(kwargs, :up_x, "")),
        :up_y => String(get(kwargs, :up_y, "")),
        :up_z => String(get(kwargs, :up_z, "")),
        :ur_lat => String(get(kwargs, :ur_lat, "")),
        :ur_lon => String(get(kwargs, :ur_lon, "")),
        :ur_w => String(get(kwargs, :ur_w, "")),
        :ur_x => String(get(kwargs, :ur_x, "")),
        :ur_y => String(get(kwargs, :ur_y, "")),
        :ur_z => String(get(kwargs, :ur_z, "")),
        :format => :format in keys(kwargs) ? validate_format(kwargs[:format]) : "ascii",
    )
end


function validate_format(format)
    supported_formats = ("ascii", "ascii_xyz", "psvelo")
    if !(format in supported_formats)
        throw(OptionError("format", supported_formats, format))
    end
    # Get canonical String from potentially exotic string types, e.g. SubString.
    return String(format)
end


function submit(request)
    return HTTP.post(
        "https://www.unavco.org/software/geodetic-utilities/plate-motion-calculator/plate-motion/model",
        ["User-Agent" => "PlateMotionRequests.jl/$(PACKAGE_VERSION) (Julia/$VERSION)"],
        HTTP.Form(request),
    )
end


function parse!(raw::HTTP.Response, format)
    body = raw.body
    # Data is inside the <pre> tag.
    bytes = body[findfirst(b"<pre>", body)[end]+1:findfirst(b"</pre>", body)[1]-1]
    # Replace trailing tab(s) with 8-bit newline char, otherwise readdlm() fails.
    replace!(bytes, codepoint('\t') => UInt8('\n'))

    if format == "ascii"
        Format = FormatASCII
    elseif format == "ascii_xyz"
        Format = FormatASCIIxyz
    elseif format == "psvelo"
        Format = FormatPsvelo
    end

    matrix = readdlm(bytes, ' ', '\n')
    table = new_table(Format, size(matrix, 1))
    for (index, line) in enumerate(eachrow(matrix))
        line = line[line.!=""]
        meta_start = findfirst(x -> x isa AbstractString, line)
        data = line[begin:meta_start-1]
        meta = line[meta_start:end]
        plate_and_reference, model = meta[1], decode_html(join(meta[2:end], ' '))
        rowdata = Format(data..., plate_and_reference, model)
        table[index] = as_row(rowdata)
    end
    return table
end


"""
    decode_html(text)

Decode html-encoded ascii entities in `text`.
Assumes that the trailing semicolon is alwaays present.

"""
function decode_html(text)
    return replace(
        text,
        r"&lt;"i => "<",
        r"&gt;"i => ">",
        r"&apos;"i => "'",
        r"&quot;"i => "\"",
        r"&amp;"i => "&",
        r"<br>" => " ",  # Dodgy <br> tags have been seen in the wild.
    )
end


struct FormatPsvelo
    lon::Float64
    lat::Float64
    velocity_east::Float64
    velocity_north::Float64
    err_east::Float64
    err_north::Float64
    correlation_NE::Float64
    plate_and_reference::String
    model::String
end

struct FormatASCII
    lon::Float64
    lat::Float64
    velocity_east::Float64
    velocity_north::Float64
    plate_and_reference::String
    model::String
end

struct FormatASCIIxyz
    lon::Float64
    lat::Float64
    velocity_x::Float64
    velocity_y::Float64
    velocity_z::Float64
    plate_and_reference::String
    model::String
end


struct OptionError <: Exception
    expected::Any
    supplied::Any
    msg::String
    OptionError(name, expected, supplied) = new(
        expected,
        supplied,
        "`$(name)` must be one of `$(expected)`. You've supplied `$(name) = $(supplied).",
    )
end

struct ReadError <: Exception
    msg::String
end

struct WriteError <: Exception
    msg::String
end

struct SamplingError <: Exception
    supplied::Any
    msg::String
    SamplingError(name, supplied) =
        new(supplied, "`$(name)` must contain regularly sampled values.")
end


"""
    new_table(T::DataType, nrows::Int = 0)

Return a new [Table][1] using the column format defined by `T`.
Use `nrows` to preallocate the number of rows using [`undef`](@ref).

[1]: https://typedtables.juliadata.org/latest/man/table/

"""
function new_table(T::DataType, nrows::Int = 0)
    return Table(
        NamedTuple{fieldnames(T)}(Vector{type}(undef, nrows) for type in fieldtypes(T)),
    )
end


"""
    as_table(T::DataType, d::Matrix)

Return a [Table][1] of the data contained in `d`, using the column format defined by `T`.

[1]: https://typedtables.juliadata.org/latest/man/table/

"""
function as_table(T::DataType, d::Matrix)
    table = new_table(T, size(d, 1))
    for (index, row) in enumerate(eachrow(d))
        table[index] = as_row(T(row...))
    end
    return table
end


function as_row(x::Union{FormatASCII,FormatASCIIxyz,FormatPsvelo})
    fields = fieldnames(typeof(x))
    return NamedTuple{fields}((getfield(x, field) for field in fields))
end


"""
    write_platemotion(file, table)

Write plate motion table to `file` as tab-delimited text columns or NetCDF.
The **experimental** NetCDF method will be used if `file` ends with a `.nc` extension.
For tab-delimited output, the first line is a header containing the column names.

Throws a `PlateMotionRequests.WriteError` if the table header is not recognised,
or if attempting to write a NetCDF file of irregularly sampled data.

!!! note

    Irregular sampling of latitude or longitude values is not supported for NetCDF output.

See also: [`read_platemotion`](@ref).

"""
function write_platemotion(file, table)
    if splitext(file)[2] == ".nc"
        try
            write_netcdf(file, table)
        catch e
            if e isa SamplingError
                throw(WriteError(e.msg))
            end
        end
    else
        if columnnames(table) in
           map(fieldnames, (FormatASCII, FormatASCIIxyz, FormatPsvelo))
            open(file, "w") do io
                println(io, join(String.(columnnames(table)), '\t'))
                writedlm(io, table, '\t')
            end
        else
            throw(
                WriteError(
                    "table column names must match a supported format." *
                    " You've supplied a table with the following columns:" *
                    join(String.(columnnames(table)), ", "),
                ),
            )
        end
    end
end


function write_netcdf(file, table)
    latitudes = unique(table.lat)
    longitudes = unique(table.lon)
    # Ensure that the coordinates are regularly sampled.
    # Irregular sampling is out of scope for this package, use interpolation as required.
    latitude_step, longitude_step = verify_regularity(latitudes, longitudes)

    # Recommended NetCDF conventions are the CF conventions:
    # <http://cfconventions.org/Data/cf-conventions/cf-conventions-1.9/cf-conventions.html>
    meta = OrderedDict(
        "Conventions" => "CF-1.9",
        "title" => "Tectonic plate motions",
        "institution" => "https://www.unavco.org/",
        "source" => join(unique(table.model), ",\n "),
        "history" => "[$(now())]: Created by PlateMotionRequests.jl $(PACKAGE_VERSION)\n",

        "references" => "See <https://www.unavco.org/software/geodetic-utilities/plate-motion-calculator/plate-motion-calculator.html#references>",
        "comment" => "Produced using https://git.sr.ht/~adigitoleo/PlateMotionRequests.jl\n",
    )

    try
        NCDataset(file, "c", attrib = meta) do nc
            lat_extrema = write_dim(nc, "lat", latitudes, "Y", "degrees_north", "latitude")
            lon_extrema = write_dim(nc, "lon", longitudes, "X", "degrees_east", "longitude")

            for (name, col) in zip(columnnames(table), columns(table))
                if name in (:lat, :lon)
                    continue
                else
                    element_type = name in (:plate_and_reference, :model) ? String : Float64
                    matrix =
                        Matrix{element_type}(undef, length(latitudes), length(longitudes))
                    for (index, cell) in enumerate(col)
                        i =
                            convert(
                                Int,
                                (table[index].lat - lat_extrema[1]) / latitude_step,
                            ) + 1
                        j =
                            convert(
                                Int,
                                (table[index].lon - lon_extrema[1]) / longitude_step,
                            ) + 1
                        matrix[i, j] = cell
                    end
                    defVar(
                        nc,
                        String(name),
                        matrix,
                        ("lat", "lon"),
                        attrib = attribute(name),
                    )
                end
            end
        end
    catch
        rm(file)
        rethrow()
    end
end


"""
    verify_regularity(x, y)

Verify regularity of both input arrays and return a tuple of step sizes.
Throws a `PlateMotionRequests.SamplingError` for irregular data.

"""
function verify_regularity(x, y)
    diff_x = diff(x)
    diff_y = diff(y)

    is_zero(x) = x == 0.0  # TODO: Add a small tolerance?
    all(is_zero, diff(diff_x)) || throw(SamplingError("x", x))
    all(is_zero, diff(diff_y)) || throw(SamplingError("y", y))

    return diff_x[1], diff_y[1]
end


"""
    attribute(colname::Symbol)

Create initial NetCDF attribute dict for a data column.
Construct standatd_name according to:
<http://cfconventions.org/Data/cf-standard-names/docs/guidelines.html>

"""
function attribute(colname::Symbol)
    names = (;
        velocity_east = ("Eastward plate velocity", "eastward_plate_velocity"),
        velocity_north = ("Northward plate velocity", "northward_plate_velocity"),
        err_east = (
            "Eastward plate velocity uncertainty",
            "eastward_plate_velocity standard_error",
        ),
        err_north = (
            "Northward plate velocity uncertainty",
            "northward_plate_velocity standard_error",
        ),
        correlation_NE = (
            "North-east velocity correlation",
            "correlation_of_northward_plate_velocity_and_eastward_plate_velocity",
        ),
        velocity_x = ("Velocity in the WGS-84 X-direction", "plate_x_velocity"),
        velocity_y = ("Velocity in the WGS-84 Y-direction", "plate_y_velocity"),
        velocity_z = ("Velocity in the WGS-84 Z-direction", "plate_z_velocity"),
        plate_and_reference = ("Local plate and reference plate", "plate_and_reference"),
        model = ("Plate tectonic model", "source"),
    )

    long_name, standard_name = getproperty(names, colname)
    d = OrderedDict("long_name" => long_name, "standard_name" => standard_name)
    if !(colname in (:plate_and_reference, :model))
        d["units"] = "mm/yr"
        d["ancillary_variables"] = "plate_and_reference model"
    end
    return d
end


"""
    write_dim(ds::NCDataset, name, samples, axis, units, standard_name)

Write a CF-compliant NetCDF dimension to an open NCDataset.
Returns a tuple containing the [`extrema`](@ref) of `samples`.

"""
function write_dim(ds::NCDataset, name, samples, axis, units, standard_name)
    defDim(ds, name, length(samples))
    min_sample, max_sample = extrema(samples)
    defVar(
        ds,
        name,
        samples,
        (name,),
        attrib = OrderedDict(
            "units" => units,
            "axis" => axis,
            "actual_range" => "[$(min_sample), $(max_sample)]",
            "standard_name" => standard_name,
        ),
    )
    return min_sample, max_sample
end


"""
    read_platemotion(file)

Read tab-delimited plate motion data from `file`.
Expects a single tab-delimited header line,
with column names that match one of the supported formats.
See [`platemotion`](@ref) for details.

May throw a `PlateMotionRequests.ReadError`.

"""
function read_platemotion(file)
    data, header = readdlm(file, '\t', Any, '\n', header = true)
    isformat(format) = Set(strip.(header)) == Set(String.(fieldnames(format)))
    cleanstrings(data) = map(s -> s isa AbstractString ? strip(s) : s, data)
    if isformat(FormatASCII)
        table = as_table(FormatASCII, cleanstrings(data))
    elseif isformat(FormatASCIIxyz)
        table = as_table(FormatASCIIxyz, cleanstrings(data))
    elseif isformat(FormatPsvelo)
        table = as_table(FormatPsvelo, cleanstrings(data))
    else
        throw(
            ReadError(
                "columns in `$(file)` must match a supported format." *
                " You've supplied a corrupt or unsupported file." *
                " If possible, try to write the file again using `write_platemotion`.",
            ),
        )
    end
    return table
end


end # module PlateMotionRequests
