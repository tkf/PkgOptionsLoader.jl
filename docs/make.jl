using Documenter, PkgOptionsLoader

makedocs(;
    modules=[PkgOptionsLoader],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/tkf/PkgOptionsLoader.jl/blob/{commit}{path}#L{line}",
    sitename="PkgOptionsLoader.jl",
    authors="Takafumi Arakaki <aka.tkf@gmail.com>",
    assets=String[],
)

deploydocs(;
    repo="github.com/tkf/PkgOptionsLoader.jl",
)
