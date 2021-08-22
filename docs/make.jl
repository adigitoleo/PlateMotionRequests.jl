using Documenter
using PlateMotionRequests

# Steps to build docs manually after a new release tag:
# 1. Switch to gh-pages branch
# 2. run `julia --project=docs/ docs/make.jl
# 3. rearrange folders to meet github pages criteria (site files in docs/)
# 4. add commit and push

makedocs(modules = [PlateMotionRequests], sitename="PlateMotionRequests.jl")
