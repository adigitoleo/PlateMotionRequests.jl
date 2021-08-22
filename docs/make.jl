using Documenter
using PlateMotionRequests

# Checklist for release tagging:
# 1. merge `dev` into `main`
# 2. create annotated git tag with release message
# 3. switch to `gh-pages` branch
# 4. rebase `gh-pages` onto `main`
# 5. build web docs with `juila --project=docs/ docs/make.jl`
# 6. copy the `docs/build` folder to a temporary folder in the poject root like `site`
# 7. remove the docs folder ONLY ON THIS BRANCH because github pages is inflexible, `git rm -r docs`
# 8. move the `site` folder to `docs`
# 9. add, commit and push

makedocs(modules = [PlateMotionRequests], sitename="PlateMotionRequests.jl")
