## TODO

- set up monthly data pulls and testing
- support site names?

## Out of scope

- reading the NetCDF file, use [NCDatasets.jl](https://github.com/Alexander-Barth/NCDatasets.jl) or similar
- writing NetCDF files with irregular lat/lon intervals
- caching, use [Memoize.jl](https://github.com/JuliaCollections/Memoize.jl) or similar
- rate limits, that is a serverside job (they have been provided with our UserAgent already)
