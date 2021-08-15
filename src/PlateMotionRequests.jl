"""Plate motion data requests using the [UNAVCO Plate Motion Calculator](https://www.unavco.org/software/geodetic-utilities/plate-motion-calculator/plate-motion-calculator.html).

Exported names:
$(EXPORTS)

"""
module PlateMotionRequests

export platemotion

using DelimitedFiles

using DocStringExtensions
using HTTP
using TypedTables


"""
    platemotion(lats::T, lons::T, heights::T; kwargs...) where {T<:AbstractArray{<:Real}}
    platemotion(lats::T, lons::T; kwargs...) where {T<:AbstractArray{<:Real}}
    platemotion(XYZ::NTuple{3, T}, kwargs...) where {T<:AbstractArray{<:Real}}

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
) where {T<:AbstractArray{<:Real}}
    request = _kwargparser(kwargs)
    push!(
        request,
        :geo =>
            join(mapslices(x -> join(x, " "), hcat(lons, lats, heights), dims = 2), ",\n"),
    )
    return _parse!(_submit(request), request[:format])
end

function platemotion(XYZ::NTuple{3,T}; kwargs...) where {T<:AbstractArray{<:Real}}
    X, Y, Z = XYZ
    request = _kwargparser(kwargs)
    push!(
        request,
        :xyz => join(mapslices(x -> join(x, " "), hcat(X, Y, Z), dims = 2), ",\n"),
    )
    return _parse!(_submit(request), request[:format])
end


function _kwargparser(kwargs::Base.Iterators.Pairs)::Dict{Symbol,String}
    kwargs = Dict(kwargs)
    return Dict(
        :model => get(kwargs, :model, "gsrm_2014"),
        :plate => get(kwargs, :plate, ""),
        :reference => get(kwargs, :reference, "NNR"),
        :up_lat => string(get(kwargs, :up_lat, "")),
        :up_lon => string(get(kwargs, :up_lon, "")),
        :up_w => string(get(kwargs, :up_w, "")),
        :up_x => string(get(kwargs, :up_x, "")),
        :up_y => string(get(kwargs, :up_y, "")),
        :up_z => string(get(kwargs, :up_z, "")),
        :ur_lat => string(get(kwargs, :ur_lat, "")),
        :ur_lon => string(get(kwargs, :ur_lon, "")),
        :ur_w => string(get(kwargs, :ur_w, "")),
        :ur_x => string(get(kwargs, :ur_x, "")),
        :ur_y => string(get(kwargs, :ur_y, "")),
        :ur_z => string(get(kwargs, :ur_z, "")),
        :format => :format in keys(kwargs) ? _validate_format(kwargs[:format]) : "ascii",
    )
end


function _validate_format(format::AbstractString)::String
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


function _submit(request::Dict{Symbol,String})::HTTP.Response
    return HTTP.post(
        "https://www.unavco.org/software/geodetic-utilities/plate-motion-calculator/plate-motion/model",
        [],  # Empty header.
        HTTP.Form(request),
    )
end


function _parse!(raw::HTTP.Response, format::String)::Table
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


function write_platemotion(file::AbstractString, table::Table)
    open(file, "w") do io
        writedlm(io, [append!(["#"], String.(columnnames(table)))])
        writedlm(io, table)
    end
end


function read_platemotion(file::AbstractString)
    data, header = readdlm(file, '\t', Any, '\n', header = true)
    # First cell of the header is the comment marker.
    isformat(format) = Set(header[2:end]) == Set(String.(fieldnames(format)))
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
