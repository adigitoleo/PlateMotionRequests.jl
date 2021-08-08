# PlateMotionRequests

https://git.sr.ht/~adigitoleo/PlateMotionRequests.jl

A julia package for plate motion data requests using the [UNAVCO Plate Motion Calculator](
https://www.unavco.org/software/geodetic-utilities/plate-motion-calculator/plate-motion-calculator.html).


## Installation

From the julia shell, switch to package mode with `]` and
`add https://git.sr.ht/~adigitoleo/PlateMotionRequests.jl`.
See also <https://docs.julialang.org/en/v1/stdlib/Pkg/>.


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

For more details, see `?PlateMotionRequests`.
You may also want to refer to the UNAVCO website linked above.

**The author is not affiliated with UNAVCO and cannot guartantee stability of the server.**
