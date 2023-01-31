using NamedTrajectories
using Documenter

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
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/aarontrowbridge/NamedTrajectories.jl",
    devbranch="main",
)
