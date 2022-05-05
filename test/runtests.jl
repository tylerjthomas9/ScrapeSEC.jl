using ScrapeSEC
using Test

tests = ["download_metadata", "download_filings", "main_index"]

println("Running tests:")
for t in tests
    fp = "$(t).jl"
    println("* $fp ...")
    include(fp)
end
