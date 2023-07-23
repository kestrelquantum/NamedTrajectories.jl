using NamedTrajectories
using Documenter

push!(LOAD_PATH, joinpath(@__DIR__, "..", "src"))

DocMeta.setdocmeta!(NamedTrajectories, :DocTestSetup, :(using NamedTrajectories); recursive=true)

makedocs(;
    modules=[NamedTrajectories],
    authors="Aaron Trowbridge <aaron.j.trowbridge@gmail.com> and contributors",
    repo="https://github.com/aarontrowbridge/NamedTrajectories.jl/blob/{commit}{path}#{line}",
    sitename="NamedTrajectories.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://aarontrowbridge.github.io/NamedTrajectories.jl",
        edit_link="main",
        assets=String[],
        mathengine = MathJax3(Dict(
            :loader => Dict("load" => ["[tex]/physics"]),
            :tex => Dict(
                "inlineMath" => [["\$","\$"], ["\\(","\\)"]],
                "tags" => "ams",
                "packages" => [
                    "base",
                    "ams",
                    "autoload",
                    "physics"
                ],
            ),
        )),
    ),
    pages=[
        "Introduction" => "index.md",
        "Manual" => "manual.md",
        "API" => "api.md",
    ],
)

deploydocs(;
    repo="github.com/aarontrowbridge/NamedTrajectories.jl.git",
    devbranch="dev-aaron",
)
