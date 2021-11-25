# Changelog

Notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] : UNRELEASED

### Changed
- the output file header format, to no longer use `#` as the first column (because it makes reading the file in Julia/Python more straightforward, however **plotting with GMT now requires a `-h1` flag**)

### Added
- User-Agent string to the HTTP.jl header, indicating the package version and the Juila version

## [2.0.2] : 2021-11-23

### Changed
- `platemotion`, to fix the MethodError when using non-integer lon/lat inputs
- platemotion documentation, to warn about XYZ input method deprecation

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
