using TeXPorter
using Documenter

DocMeta.setdocmeta!(TeXPorter, :DocTestSetup, :(using TeXPorter); recursive=true)

makedocs(;
    modules=[TeXPorter],
    authors="Kai Partmann",
    sitename="TeXPorter.jl",
    format=Documenter.HTML(;
        canonical="https://kaipartmann.github.io/TeXPorter.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/kaipartmann/TeXPorter.jl",
    devbranch="main",
)
