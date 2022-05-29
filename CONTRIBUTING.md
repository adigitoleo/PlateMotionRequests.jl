# Guidelines for contributors and maintainers


## Git branching

The project maintainer will oversee three public branches:
- `main` (a branch for handling releases and registration),
- `next` (a branch for stabilisation of the next release) and
- `dev` (a branch for integrating destabilising changes).

The additional `gh-pages-...` branches are only used for publishing online documentation.

**Contributors should create a new branch for each topic, based on the `main` branch.**
Do not branch from `dev`: that branch is not guaranteed to maintain a linear modification history.
If you think you want to branch from `dev` (or `next`),
branch from `main` instead and use `git merge` to incorporate the commits you need.

The branching setup is a simplified version of [git-workflow](https://hackernoon.com/how-the-creators-of-git-do-branches-e6fcc57270fb),
without a previous release maintenance branch.
Only the latest release will be maintained with bugfixes.


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
Releasing new versions requires admin access to the GitHub mirror,
which is used for hosting the documentation.

### Preparing the release on `next`

1. Update the project manifest: `julia --project=$PWD -e 'using Pkg; Pkg.update()'`.
2. Verify that any tests are passing locally (or debug failures/errors, separate commits).
3. Update the documentation files, including `docs/make.jl` if necessary.
4. Update `docs/src/changelog.md` with an `Unreleased <date>` section (concise list of changes).
5. If the changelog is larger than 1MB, split off a `changelog-<version_range>.md` for old versions.
6. Run [JuliaFormatter](https://github.com/domluna/JuliaFormatter.jl) on the entire `src/` tree.
7. Commit the changes to `next` with a message like `Prepare release v<version>`.
8. **Don't add a tag!** Releases must only be tagged after registration on `main`.
9. Push `next` to all remotes.

### Releasing a new version on `main`

Any commit from `next` that is considered stable enough can be merged into `main`.
Then the HTML documentation also needs to be built, and the package can be registered with
[Registrator.jl](https://github.com/JuliaRegistries/Registrator.jl).
After merging, switch to `main`, then:

1. Bump the version number in `Project.toml` and register the package.
2. Resolve issues raised by registry maintainers and repeat step 1 **with new patch versions**.
3. After successful registration, create an annotated git tag with `git tag -am "Version <version>" v<version>`.
4. Create a documentation branch with `git switch -c gh-pages-<version>`.
5. Build the web docs **on the new branch** with `julia --project=docs/ docs/make.jl`.
6. From the project root: `mv docs/build site`.
7. Remove the `docs` folder **only on this branch** (due to GitHub Pages inflexibility).
8. From the project root: `mv site docs`, `git add -A`, `git c -m "Docs for v<version>"`.
9. Push `main` to all remotes, and the documentation branch to GitHub.
10. In the GitHub repository web UI, navigate to `Settings > Pages`, change the branch accordingly and make sure it is looking in the `docs/` subfolder.
