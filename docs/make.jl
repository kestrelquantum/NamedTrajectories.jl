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
                "macros" => Dict(
                    "minimize" => ["\\underset{#1}{\\operatorname{minimize}}", 1],
                )
            ),
            # :TeX => Dict(
            #     :Macros => Dict(
            #         :minimize => ["\\underset{#1}{\\operatorname{minimize}}", 1],
            #     )
            # )
        )),
    ),
    pages=[
        "Home" => "index.md",
        "Quickstart Guide" => "man/quickstart.md",
        "Manual" => "man/manual.md",
        "Plotting" => "man/plotting.md",
        "Library" => "lib.md"
    ],
)

deploydocs(;
    repo="github.com/aarontrowbridge/NamedTrajectories.jl.git",
    devbranch="main",
)
