using Pkg
Pkg.activate("$(@__DIR__)")
Pkg.add("PlateMotionRequests")
Pkg.update()

using Documenter
using PlateMotionRequests


DOCGEN = """


## API Reference

```@docs
PlateMotionRequests
platemotion
write_platemotion
read_platemotion
```
"""

cp("$(@__DIR__)/../README.md", "$(@__DIR__)/src/index.md", force = true)
@assert isfile("$(@__DIR__)/src/index.md")
open("$(@__DIR__)/src/index.md", write = true, append = true) do io
    write(io, DOCGEN)
end
makedocs(modules = [PlateMotionRequests], sitename = "PlateMotionRequests.jl")
