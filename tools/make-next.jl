#!/usr/bin/julia
using Pkg

using ArgParse
using JuliaFormatter


function parse_cmdline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "NEW_VERSION"
            help = "the new version number, in the format X.Y.Z"
            required = true
    end

    return parse_args(s)
end


function main()
    # Verify that we are on the right git branch.
    gitbranch = readchomp(`git rev-parse --abbrev-ref HEAD`)
    if gitbranch != "next"
        error("must be on the 'next' git branch." * "You're on '$(gitbranch)'.")
    end

    args = parse_cmdline()
    new_version = args["NEW_VERSION"]
    try
        # Update Project.toml version.
        projectfile = "$(@__DIR__)/../Project.toml"
        lines = readlines(projectfile, keep = true)
        open(projectfile, write = true) do io
            for line in lines
                if startswith(line, "version")
                    print(io, "version = \"$(new_version)\"")
                else
                    print(io, line)
                end
            end
        end

        # Update the local manifest.
        Pkg.activate("$(@__DIR__)/../")
        Pkg.update()

        # TODO: Run local tests, if available

        # Build docs to verify that `docs/make.jl` works.
        docbuilder = "$(@__DIR__)/../docs/make.jl"
        run(`julia $docbuilder`)

        # Auto-format the entire source tree
        format("$(@__DIR__)/../src/")
    catch e
        docs_manifest = "$(@__DIR__)/../docs/Manifest.toml"
        run(`git restore $projectfile $docs_manifest`)
        throw(e)
    end

    println("Finished release preparation for v$(new_version)")
    println("Remember to update the changelog and add a git tag before committing the release")
end


main()
