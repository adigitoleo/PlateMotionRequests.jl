using Documenter
using PlateMotionRequests

# Checklist for release tagging:
# 0. start on `main` branch
# 1. merge `dev` into `main`
# 2. create annotated git tag with release message
# 3. create `gh-pages-<version>` branch
# 4. build web docs with `juila --project=docs/ docs/make.jl`
# 5. copy the `docs/build` folder to a temporary folder in the poject root like `site`
# 6. remove the docs folder ONLY ON THIS BRANCH because github pages is inflexible, `git rm -r docs`
# 7. move the `site` folder to `docs`
# 8. add, commit and push

makedocs(modules = [PlateMotionRequests], sitename="PlateMotionRequests.jl")
