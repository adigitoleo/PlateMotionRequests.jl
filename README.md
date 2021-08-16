# PlateMotionRequests

A Julia package for plate motion data requests using the [UNAVCO Plate Motion Calculator](https://www.unavco.org/software/geodetic-utilities/plate-motion-calculator/plate-motion-calculator.html).

The package is open source,
and [the code is available](https://git.sr.ht/~adigitoleo/PlateMotionRequests.jl)
for free under the Zero-Clause BSD license.


## Installation

From the Julia shell, switch to package mode with `]` and run

    add https://git.sr.ht/~adigitoleo/PlateMotionRequests.jl

For advanced packaging instructions, refer to <https://docs.julialang.org/en/v1/stdlib/Pkg/>.


## Usage

**Save data whenever possible to avoid repeating requests to the UNAVCO server.**
**Note that the provided methods do not implement any network limits.**

    julia> using PlateMotionRequests
    julia> latitudes = -20:10:20
    julia> longitudes = 160:10:200
    julia> GSRMdata = platemotion(
               repeat(latitudes, length(longitudes)),
               repeat(longitudes, inner = length(latitudes)),
           )

Data can be written to/read from storage using `write_platemotion` and `read_platemotion`.
These functions write/read simple tab-delimited text files.
To store binary representations,
the `Serialization` module from Julia's standard library may prove useful.
Robust formats like NetCDF, HDF5 or ASDF may be preferred,
depending on your requirements.

Responses are tabulated using [TypedTables.jl](https://typedtables.juliadata.org/latest/), e.g.:

    Table with 6 columns and 25 rows:
          lon    lat    velocity_east  velocity_north  plate_and_reference  model
        ┌────────────────────────────────────────────────────────────────────────────
     1  │ 160.0  -20.0  25.53          49.46           AU(NNR)              GSRM v2.1
     2  │ 160.0  -10.0  -61.14         25.72           PA(NNR)              GSRM v2.1
     3  │ 160.0  0.0    -65.81         25.72           PA(NNR)              GSRM v2.1
     4  │ 160.0  10.0   -68.49         25.72           PA(NNR)              GSRM v2.1
     5  │ 160.0  20.0   -69.1          25.71           PA(NNR)              GSRM v2.1
     6  │ 170.0  -20.0  -56.25         29.02           PA(NNR)              GSRM v2.1
     7  │ 170.0  -10.0  -61.97         29.02           PA(NNR)              GSRM v2.1
     8  │ 170.0  0.0    -65.81         29.03           PA(NNR)              GSRM v2.1
     9  │ 170.0  10.0   -67.66         29.02           PA(NNR)              GSRM v2.1
     10 │ 170.0  20.0   -67.48         29.02           PA(NNR)              GSRM v2.1
     11 │ 180.0  -20.0  20.45          35.23           AU(NNR)              GSRM v2.1
     12 │ 180.0  -10.0  -62.88         31.45           PA(NNR)              GSRM v2.1
     ⋮  │   ⋮      ⋮          ⋮              ⋮                  ⋮               ⋮

Change the model and reference frame using the `model` and `reference` keywords,
respectively. For a no-net-rotation frame, use the value `"NNR"` (default).

Change output formats using the `format` keyword.
The supported output formats are `"ascii"` (default),
`"ascii_xyz"` (WGS-84 coordinates) and `"psvelo"` (GMT 'psvelo' format).

For the full list of options, see `?platemotion`.
You may also want to refer to the UNAVCO website linked above.

**The author is not affiliated with UNAVCO and cannot guarantee stability of the server.**


## Feedback and contributions

Please use the public mailing list for feedback and discussion:

[~adigitoleo/platemotionrequests.jl-devel@lists.sr.ht](mailto:~adigitoleo/platemotionrequests.jl-devel@lists.sr.ht)

Contributions are handled via patches sent to the same mailing list.
Contributor guidelines are provided with the [source code repository](https://git.sr.ht/~adigitoleo/PlateMotionRequests.jl) (in the file `CONTRIBUTING.md`).
The file `TODO.md` lists some ideas for planned features.
If you want to work on one of them,
send an email first to check if an implementation is already underway.
