push!(LOAD_PATH, "../src/")
using Documenter, Looping

DocMeta.setdocmeta!(Looping.Utilities, :DocTestSetup, :(using Looping.Utilities); recursive=true)
DocMeta.setdocmeta!(Looping.FloquetUtils, :DocTestSetup, :(using Looping.FloquetUtils); recursive=true)

makedocs(sitename="Looping Documentation", modules=[Looping.Utilities, Looping.FloquetUtils], draft=false, strict=:doctest)
