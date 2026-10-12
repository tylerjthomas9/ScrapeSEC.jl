using Aqua
using ScrapeSEC
using Test

println("Running tests:")

# Serve saved example responses instead of hitting sec.gov (see fixtures.jl)
include("fixtures.jl")

tests = ["download_metadata", "download_filings", "main_index"]

for t in tests
    fp = "$(t).jl"
    println("* $fp ...")
    include(fp)
end

println("* jet.jl ...")
include("jet.jl")

Aqua.test_all(ScrapeSEC; ambiguities=false)
