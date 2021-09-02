# Guidelines for contributors and maintainers


## Git branching

The `dev` branch will be used for development.
It's `HEAD` will point to potentially unstable code which is pending release.
Most contributors will want to branch off `dev` before making changes.
The `main` branch will be used for tagged commits (releases),
which will mostly be merges from `dev`.


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


## Releasing new versions

Releasing versions requires administrator access to the SourceHut and GitHub repositories.
Version releases should adhere to [semantic versioning](https://semver.org/).
Releasing new versions involves the following steps:

1. On the `dev` branch, increment the version number in `Project.toml`.
2. Merge the `dev` branch into `main`.
3. Create an annotated tag on `main`, with a message in the format `<PackageName> v<version> [(un)registered]` (the last component should indicate if the release will be registered in the Julia General Registry).
4. Create a documentation branch with `git switch -c gh-pages-<version>`.
5. Build the web docs with `julia --project=docs/ docs/make.jl`.
6. From the project root: `mv docs/build site`.
7. Remove the `docs` folder **only on this branch** (due to GitHub Pages inflexibility).
8. On the documentation branch: `mv site docs`.
9. On the documentation branch: `git add -A`, `git c -m "Docs for v<version>"`, push changes to all remotes, push tags to all remotes.
10. In the GitHub repository web UI, navigate to `Settings > Pages`, change the branch accordingly and make sure it is looking in the `docs/` folder.
