using Documenter
using TypedTables
using PlateMotionRequests

# Steps to build docs manually after a new release tag:
# 1. Switch to gh-pages branch
# 2. run `julia --project=docs/ docs/make.jl
# 3. rearrange folders to meet github pages criteria (site files in docs/)
# 4. add commit and push

makedocs(modules = [PlateMotionRequests], sitename="PlateMotionRequests.jl")
root = Documenter.Utilities.currentdir()
target = "build"
versions = ["stable" => "v^", "v#.#"]
latest = "v2.0.0"  # Parse this from the latest git tag?
HTMLWriter = Documenter.Writers.HTMLWriter
HTMLWriter.generate_siteinfo_file(target, latest)
mktempdir() do temp
    entries, symlinks = HTMLWriter.expand_versions(temp, versions)
    println(entries)
    println(symlinks)
    HTMLWriter.generate_version_file(joinpath(temp, "versions.js"), entries, symlinks)
    # HTMLWriter.generate_redirect_file(joinpath(temp, "index.html"), entries)

    cd(temp) do
        for kv in symlinks
            Documenter.rm_and_add_symlink(kv.second, kv.first)
        end
    end
end
