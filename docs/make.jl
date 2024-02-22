using NamedTrajectories
using Documenter
using Literate

push!(LOAD_PATH, joinpath(@__DIR__, "..", "src"))

pages = [
    "Home" => "index.md",
    "Quickstart Guide" => "generated/quickstart.md",
    # "Manual" => [
    #     "generated/man/constructors.md",
    #     "generated/man/retrieval.md",
    #     "generated/man/add_remove.md",
    #     "generated/man/updating.md",
    #     "generated/man/times.md",
    #     "generated/man/operations.md",
    # ],
    "Plotting" => "generated/plotting.md",
    "Library" => "lib.md"
]

format = Documenter.HTML(;
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
)

src = joinpath(@__DIR__, "src")
lit = joinpath(@__DIR__, "literate")

lit_output = joinpath(src, "generated")

for (root, _, files) ∈ walkdir(lit), file ∈ files
    splitext(file)[2] == ".jl" || continue
    ipath = joinpath(root, file)
    opath = splitdir(replace(ipath, lit=>lit_output))[1]
    Literate.markdown(ipath, opath)
end

makedocs(;
    modules=[NamedTrajectories],
    authors="Aaron Trowbridge <aaron.j.trowbridge@gmail.com> and contributors",
    sitename="NamedTrajectories.jl",
    format=format,
    pages=pages,
)

deploydocs(;
    repo="github.com/aarontrowbridge/NamedTrajectories.jl.git",
    devbranch="main",
)
