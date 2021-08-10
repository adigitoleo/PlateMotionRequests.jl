# PlateMotionRequests

https://git.sr.ht/~adigitoleo/PlateMotionRequests.jl

A Julia package for plate motion data requests using the [UNAVCO Plate Motion Calculator](
https://www.unavco.org/software/geodetic-utilities/plate-motion-calculator/plate-motion-calculator.html).


## Installation

From the Julia shell, switch to package mode with `]` and run

    add https://git.sr.ht/~adigitoleo/PlateMotionRequests.jl

For advanced packaging instructions, refer to <https://docs.julialang.org/en/v1/stdlib/Pkg/>.


## Usage

**Save data whenever possible to avoid repeating requests to the UNAVCO server.**
**Note that the provided methods do not implement any network limits.**

    using PlateMotionRequests
    latitudes = -40:10:40
    longitudes = 160:10:200
    platemotion(
        repeat(latitudes, length(longitudes)),
        repeat(longitudes, inner = length(latitudes)),
    )

Responses are tabulated using [TypedTables.jl](https://typedtables.juliadata.org/latest/):

    Table with 6 columns and 45 rows:
          lon    lat    velocity_east  velocity_north  plate_and_reference  model
        ┌────────────────────────────────────────────────────────────────────────────
     1  │ 160.0  -40.0  8.92           49.41           AU(NNR)              GSRM v2.1
     2  │ 160.0  -30.0  17.49          49.44           AU(NNR)              GSRM v2.1
     3  │ 160.0  -20.0  25.53          49.46           AU(NNR)              GSRM v2.1
     4  │ 160.0  -10.0  -61.14         25.72           PA(NNR)              GSRM v2.1
     5  │ 160.0  0.0    -65.81         25.72           PA(NNR)              GSRM v2.1
     6  │ 160.0  10.0   -68.49         25.72           PA(NNR)              GSRM v2.1
     7  │ 160.0  20.0   -69.1          25.71           PA(NNR)              GSRM v2.1
     8  │ 160.0  30.0   -67.63         25.7            PA(NNR)              GSRM v2.1
     9  │ 160.0  40.0   -64.1          25.68           PA(NNR)              GSRM v2.1
     10 │ 170.0  -40.0  3.75           42.96           AU(NNR)              GSRM v2.1
     11 │ 170.0  -30.0  13.47          42.98           AU(NNR)              GSRM v2.1
     12 │ 170.0  -20.0  -56.25         29.02           PA(NNR)              GSRM v2.1
     13 │ 170.0  -10.0  -61.97         29.02           PA(NNR)              GSRM v2.1
     14 │ 170.0  0.0    -65.81         29.03           PA(NNR)              GSRM v2.1
     15 │ 170.0  10.0   -67.66         29.02           PA(NNR)              GSRM v2.1
     16 │ 170.0  20.0   -67.48         29.02           PA(NNR)              GSRM v2.1
     17 │ 170.0  30.0   -65.25         29.0            PA(NNR)              GSRM v2.1
     18 │ 170.0  40.0   -61.04         28.99           PA(NNR)              GSRM v2.1
     19 │ 180.0  -40.0  -43.31         31.41           PA(NNR)              GSRM v2.1
     20 │ 180.0  -30.0  10.07          35.21           AU(NNR)              GSRM v2.1
     21 │ 180.0  -20.0  20.45          35.23           AU(NNR)              GSRM v2.1
     22 │ 180.0  -10.0  -62.88         31.45           PA(NNR)              GSRM v2.1
     23 │ 180.0  0.0    -65.81         31.45           PA(NNR)              GSRM v2.1
     24 │ 180.0  10.0   -66.75         31.45           PA(NNR)              GSRM v2.1
     25 │ 180.0  20.0   -65.68         31.44           PA(NNR)              GSRM v2.1
     26 │ 180.0  30.0   -62.62         31.43           PA(NNR)              GSRM v2.1
     27 │ 180.0  40.0   -57.66         31.41           PA(NNR)              GSRM v2.1
     28 │ 190.0  -40.0  -46.91         32.88           PA(NNR)              GSRM v2.1
     29 │ 190.0  -30.0  -54.26         32.9            PA(NNR)              GSRM v2.1
     30 │ 190.0  -20.0  -59.96         32.91           PA(NNR)              GSRM v2.1
     31 │ 190.0  -10.0  -63.85         32.92           PA(NNR)              GSRM v2.1
     32 │ 190.0  0.0    -65.81         32.92           PA(NNR)              GSRM v2.1
     33 │ 190.0  10.0   -65.78         32.92           PA(NNR)              GSRM v2.1
     34 │ 190.0  20.0   -63.76         32.91           PA(NNR)              GSRM v2.1
     35 │ 190.0  30.0   -59.82         32.9            PA(NNR)              GSRM v2.1
     36 │ 190.0  40.0   -54.06         32.88           PA(NNR)              GSRM v2.1
     37 │ 200.0  -40.0  -50.62         33.35           PA(NNR)              GSRM v2.1
     38 │ 200.0  -30.0  -57.15         33.37           PA(NNR)              GSRM v2.1
     39 │ 200.0  -20.0  -61.94         33.38           PA(NNR)              GSRM v2.1
     40 │ 200.0  -10.0  -64.85         33.39           PA(NNR)              GSRM v2.1
     41 │ 200.0  0.0    -65.81         33.39           PA(NNR)              GSRM v2.1
     42 │ 200.0  10.0   -64.78         33.39           PA(NNR)              GSRM v2.1
     43 │ 200.0  20.0   -61.79         33.38           PA(NNR)              GSRM v2.1
     44 │ 200.0  30.0   -56.93         33.37           PA(NNR)              GSRM v2.1
     45 │ 200.0  40.0   -50.35         33.35           PA(NNR)              GSRM v2.1

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

mailto:~adigitoleo/platemotionrequests.jl-devel@lists.sr.ht

Contributions are handled via patches sent to the same mailing list.
Check the [contributor guidelines](CONTRIBUTING.md).


## Wishlist

- Tests
- Rate limits? Prevent accidental spamming of requests to the server.
- Caching?
- More examples, e.g. how to save the psvelo table to a GMT-compatible file.
