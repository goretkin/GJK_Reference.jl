using Documenter, GJK_Reference

makedocs(
    modules = [GJK_Reference],
    format = Documenter.HTML(),
    checkdocs = :exports,
    sitename = "GJK_Reference.jl",
    pages = Any["index.md"]
)

deploydocs(
    repo = "github.com/goretkin/GJK_Reference.jl.git",
)
