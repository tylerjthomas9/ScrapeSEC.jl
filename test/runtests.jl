using ScrapeSEC
using Test

tests = ["DownloadMetadata"]

println("Running tests:")
for t in tests
    fp = "$(t).jl"
    println("* $fp ...")
    include(fp)
end