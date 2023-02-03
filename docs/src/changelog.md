# Changelog

Notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The first version of this package registered in the [Julia General registry](https://github.com/JuliaRegistries/General) was v3.1.0, earlier versions should be considered experimental.

## [3.1.2]: 2023-02-04

### Changed
- test suite, to restore NetCDF tests on Windows
- Linux CI manifest, to run tests on the latest stable Julia version

## [3.1.1]: 2022-05-29

### Changed
- test suite, to avoid running NetCDF tests on Windows (currently broken)

## [3.1.0] : 2022-05-23

### Added
- NetCDF output tests
- `WriteError` for error semantics when trying to write irregular data to NetCDF (unsupported)
- support for reading right-aligned tabular data files with `read_platemotion`

## [3.0.0] : 2022-01-18

### Changed
- the output file header format, to no longer use `#` as the first column (because it makes reading the file in Julia/Python more straightforward, however **plotting with GMT now requires a `-h1` flag**)

### Added
- User-Agent string to the HTTP.jl header, indicating the package version and the Juila version
- experimental NetCDF writer

### Removed

- buggy `platemotion` method that accepted WGS-84 XYZ coordinate input

## [2.0.2] : 2021-11-23

### Changed
- `platemotion`, to fix the MethodError when using non-integer lon/lat inputs
- platemotion documentation, to warn about WGS-84 XYZ input method deprecation

## [2.0.1] : 2021-09-03

### Changed
- [contributor guidelines](../../CONTRIBUTING.md)

## [2.0.0] : 2021-08-22

### Changed
- error messages, to adhere to the [internal guidelines](../../CONTRIBUTING.md)

### Added
- documentation pages, including GMT map demonstration
- `write_platemotion` and `read_platemotion` methods for writing/reading text files

### Removed
- single-location query methods, because they produced incorrect output for site names
