# Guidelines for contributors and maintainers


## Formatting

Write source code in UTF-8, with POSIX-compliant line terminators (i.e. `\n`).
Run code through [JuliaFormatter](https://github.com/domluna/JuliaFormatter.jl),
with default settings, before submitting.


## Documentation

Write docstrings for (at least) all `export`ed names.
Write a brief docstring for all `module`s.
Use [DocStringExtensions](https://github.com/JuliaDocs/DocStringExtensions.jl)
to show:

-   exported names in module docstrings, i.e. `$(EXPORTS)`
-   field docstrings in their parent struct docstrings, i.e. `$(TYPEDFIELDS)`


## Error messages

Errors can be classified as expected or unexpected. 
Expected errors will usually be implemented with `ArgumentError` or similar.
Trying to read from a missing file is an example of an "unexpected" error.

General guidelines:

-   Begin the message with a lowercase character
-   Enclose code in backticks, i.e. '\`...\`'
-   Don't include web hyperlinks

### Expected errors

1.  Indicate the violated constraints. Use an imperative statement, i.e. "must".
2.  Show the invalid name or expression. Use the second person, i.e. "you".
3.  Optionally offer suggestions for how to remedy the error.

Each component should consist of no more than two lines. For example:

    "`angle` must be in the interval (-90,90]." *
    " You've supplied `angle = $(angle)`." *
    " You might want to use `transform_angle`."

### Unexpected errors

1.  Indicate which operation failed and why. Use "unable to ..."
2.  Optionally offer suggestions for how to debug the error.

Each component should consist of no more than two lines. For example:

    "unable to write to '$(file)'." *
    " The file seems to be missing." *
    " You can use `loglevel=3` to enable debugging messages."
