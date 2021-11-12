"""Plate motion data requests using the [UNAVCO Plate Motion Calculator](https://www.unavco.org/software/geodetic-utilities/plate-motion-calculator/plate-motion-calculator.html).

Exported names:
$(EXPORTS)

"""
module PlateMotionRequests

export platemotion
export write_platemotion
export read_platemotion

using DelimitedFiles

using DocStringExtensions
using HTTP
using TypedTables


"""
    platemotion(lats::T, lons::T, heights::T; kwargs...) where {T<:AbstractArray}
    platemotion(lats::T, lons::T; kwargs...) where {T<:AbstractArray}
    platemotion(XYZ::NTuple{3, T}, kwargs...) where {T<:AbstractArray}

Request plate motion data from the [UNAVCO Plate Motion Calculator](https://www.unavco.org/software/geodetic-utilities/plate-motion-calculator/plate-motion-calculator.html). Headers and metadata are stripped from the output, which is parsed into a [`Table`](https://typedtables.juliadata.org/latest/man/table/).

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

"""
function platemotion(
    lats::T,
    lons::T,
    heights::T = fill(0, length(lats));
    kwargs...,
) where {T<:AbstractArray}
    request = _kwargparser(kwargs)
    push!(
        request,
        :geo =>
            join(mapslices(x -> join(x, " "), hcat(lons, lats, heights), dims = 2), ",\n"),
    )
    return _parse!(_submit(request), request[:format])
end

function platemotion(XYZ::NTuple{3,T}; kwargs...) where {T<:AbstractArray}
    X, Y, Z = XYZ
    request = _kwargparser(kwargs)
    push!(
        request,
        :xyz => join(mapslices(x -> join(x, " "), hcat(X, Y, Z), dims = 2), ",\n"),
    )
    return _parse!(_submit(request), request[:format])
end


function _kwargparser(kwargs::Base.Iterators.Pairs)
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
        :format => :format in keys(kwargs) ? _validate_format(kwargs[:format]) : "ascii",
    )
end


function _validate_format(format)
    supported_formats = ("ascii", "ascii_xyz", "psvelo")
    if !(format in supported_formats)
        throw(
            ArgumentError(
                "`format` must be one of `$(supported_formats)`." *
                " You've supplied `format = $(format)`.",
            ),
        )
    end
    return String(format)
end


function _submit(request)
    return HTTP.post(
        "https://www.unavco.org/software/geodetic-utilities/plate-motion-calculator/plate-motion/model",
        [],  # Empty header.
        HTTP.Form(request),
    )
end


function _parse!(raw::HTTP.Response, format)
    body = raw.body
    # Data is inside the <pre> tag.
    bytes = body[findfirst(b"<pre>", body)[end]+1:findfirst(b"</pre>", body)[1]-1]
    # Replace trailing tab(s) with 8-bit newline char, otherwise readdlm() fails.
    replace!(bytes, codepoint('\t') => UInt8('\n'))

    if format == "ascii"
        Format = _FormatASCII
    elseif format == "ascii_xyz"
        Format = _FormatASCIIxyz
    elseif format == "psvelo"
        Format = _FormatPsvelo
    end

    table = _mktable(Format)
    for line in eachrow(readdlm(bytes, ' ', '\n'))
        line = line[line.!=""]
        floats = line[isa.(line, Float64)]
        ints = line[isa.(line, Int64)]
        strings = line[isa.(line, SubString{String})]
        plate_and_ref, model = strings[1], join(strings[2:end], ' ')
        rowdata = Format(floats..., ints..., plate_and_ref, model)
        push!(table, _mkrow(rowdata))
    end
    return table
end


struct _FormatPsvelo
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

struct _FormatASCII
    lon::Float64
    lat::Float64
    velocity_east::Float64
    velocity_north::Float64
    plate_and_reference::String
    model::String
end

struct _FormatASCIIxyz
    lon::Float64
    lat::Float64
    velocity_x::Float64
    velocity_y::Float64
    velocity_z::Float64
    plate_and_reference::String
    model::String
end


struct ParseError <: Exception
    msg::AbstractString
end
ParseError() = ParseError("")


function _mktable(t::DataType)
    return Table(NamedTuple{fieldnames(t)}(type[] for type in fieldtypes(t)))
end
function _mktable(d::Matrix, t::DataType)
    return Table(;
        (colname => coldata for (colname, coldata) in zip(fieldnames(t), eachcol(d)))...,
    )
end


function _mkrow(x::Union{_FormatASCII,_FormatASCIIxyz,_FormatPsvelo})
    fields = fieldnames(typeof(x))
    return NamedTuple{fields}((getfield(x, field) for field in fields))
end


"""
    write_platemotion(file, table)

Write plate motion table to `file` as tab-delimited text columns.
The first line written is a tab-delimited header containing the column names.

"""
function write_platemotion(file, table)
    open(file, "w") do io
        println(io, join(String.(columnnames(table)), '\t'))
        writedlm(io, table)
    end
end


"""
    read_platemotion(file)

Read tab-delimited plate motion data from `file`.
Expects a single tab-delimited header line,
with column names that match one of the supported formats.
See [`platemotion`](@ref) for details.

"""
function read_platemotion(file)
    data, header = readdlm(file, '\t', Any, '\n', header = true)
    isformat(format) = Set(header) == Set(String.(fieldnames(format)))
    if isformat(_FormatASCII)
        table = _mktable(data, _FormatASCII)
    elseif isformat(_FormatASCIIxyz)
        table = _mktable(data, _FormatASCIIxyz)
    elseif isformat(_FormatPsvelo)
        table = _mktable(data, _FormatPsvelo)
    else
        throw(
            ParseError(
                "columns in `file` must match a supported format." *
                " You've supplied a corrupt or unsupported file." *
                " If possible, try to write the file again using `write_platemotion`.",
            ),
        )
    end
    return table
end


end # PlateMotionRequests
