using Documenter, Intervals

makedocs(;
    modules=[Intervals],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/reallyasi9/Intervals.jl/blob/{commit}{path}#L{line}",
    sitename="Intervals.jl",
    authors="Phil Killewald",
    assets=String[],
)

deploydocs(;
    repo="github.com/reallyasi9/Intervals.jl",
)
