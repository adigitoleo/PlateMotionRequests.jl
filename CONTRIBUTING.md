# Guidelines for contributors and maintainers


## Git branching

The project maintainer will oversee three public branches:
- `main` (a branch for stable releases),
- `next` (a branch for stabilisation of the next release) and
- `dev` (a branch for integrating destabilising changes).

The additional `gh-pages-...` branches are only used for publishing online documentation.

**Contributors should create a new branch for each topic, based on the `main` branch.**
Do not branch from `dev`: that branch is not guaranteed to maintain a linear modification history.
If you think you want to branch from `dev` (or `next`),
branch from `main` instead and use `git merge` to incorporate the commits you need.

The branching setup is a simplified version of [git-workflow](https://hackernoon.com/how-the-creators-of-git-do-branches-e6fcc57270fb),
without a previous release maintenance branch.
Only the latest stable release will be maintained with bugfixes.


## Formatting

Write source code in UTF-8, with POSIX-compliant line terminators (i.e. `\n`).


## Documentation

Write docstrings for (at least) all `export`ed names.
Write a brief docstring for all `module`s.
Use [DocStringExtensions](https://github.com/JuliaDocs/DocStringExtensions.jl)
to show:

-   exported names in module docstrings, i.e. `$(EXPORTS)`
-   field docstrings in their parent struct docstrings, i.e. `$(TYPEDFIELDS)`

Documentation should be written in Markdown format, according to the [Julia Markdown spec](https://docs.julialang.org/en/v1/stdlib/Markdown/).

More detailed examples or tutorials belong in the `docs/src` folder.
They will be rendered to web pages for online documentation.
The online documentation will be built with [Documenter.jl](https://juliadocs.github.io/Documenter.jl/stable/).


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

Version releases should adhere to [semantic versioning](https://semver.org/).
Code that is on `next` may undergo a few patch version increments before making it to `main`,
so stable releases might skip a few tags.
Online documentation is only built for stable versions,
so releasing stable versions requires administrator access to the online GitHub repository.

### Releasing a new version on `next` (unstable)

1. Update `Project.toml` with the new version number.
2. Update the project manifest: `julia --project=$PWD -e 'using Pkg; Pkg.update()'`
3. Verify that any tests are passing locally (otherwise `git restore` everything and go debugging).
4. Update the documentation files, including `docs/make.jl` if necessary (fix it if broken).
5. Update `docs/src/changelog.md` with the date of release and a concise list of changes.
6. If the changelog is larger than 1MB, split off a `changelog-<version_range>.md` for old versions.
7. Run [JuliaFormatter](https://github.com/domluna/JuliaFormatter.jl) on the entire `src/` tree.
8. Commit the changes to `next` with a message like `Prepare release v<version>`.
9. Create an annotated git tag with `git tag -am "Version <version>" v<version>`.
10. Push `next` to all remotes (with `--follow-tags`).

Some of the above steps are automated in `tools/make-next.jl`.
The script requires [ArgParse.jl](https://github.com/carlobaldassi/ArgParse.jl) and
[JuliaFormatter](https://github.com/domluna/JuliaFormatter.jl).

### Releasing a new version on `main` (stable)

Once a release is considered stable enough, it can be merged onto `main` from `next`.
Then the HTML documentation also needs to be built.
Starting on `main`:

1. Create a documentation branch with `git switch -c gh-pages-<version>`; **all remaining steps are to be performed on this branch**.
2. Build the web docs with `julia --project=docs/ docs/make.jl`.
3. From the project root: `mv docs/build site`.
4. Remove the `docs` folder **only on this branch** (due to GitHub Pages inflexibility).
5. From the project root: `mv site docs`, `git add -A`, `git c -m "Docs for v<version>"`.
6. Push both `main` and the documentation branch to all remotes (with `--follow-tags`).
7. In the GitHub repository web UI, navigate to `Settings > Pages`, change the branch accordingly and make sure it is looking in the `docs/` subfolder.
