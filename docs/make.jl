using NamedTrajectories
using Documenter
using Literate

push!(LOAD_PATH, joinpath(@__DIR__, "..", "src"))

# DocMeta.setdocmeta!(
#     NamedTrajectories,
#     :DocTestSetup,
#     :(using NamedTrajectories);
#     recursive=true
# )

src = joinpath(@__DIR__, "src")
lit = joinpath(@__DIR__, "literate")

for (root, _, files) ∈ walkdir(lit), file ∈ files
    splitext(file)[2] == ".jl" || continue
    ipath = joinpath(root, file)
    opath = splitdir(replace(ipath, lit=>src))[1]
    Literate.markdown(ipath, opath)
end

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
        "Home" => "index.md",
        "Quickstart Guide" => "man/quickstart.md",
        "Plotting" => "man/plotting.md",
        "Tips and Tricks" => "man/tips.md",
        "Library" => "lib.md"
    ],
)

deploydocs(;
    repo="github.com/aarontrowbridge/NamedTrajectories.jl.git",
    devbranch="main",
)
