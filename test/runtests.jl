using Aqua
using ScrapeSEC
using Test

tests = ["download_metadata", "download_filings", "main_index"]

println("Running tests:")

# SEC rate-limits GitHub runner IPs, so CI network calls need retries
function retry_sec(f; attempts=5)
    for attempt in 1:attempts
        try
            return f()
        catch e
            attempt < attempts || rethrow()
            @info "SEC request failed (attempt $attempt), retrying" e
            sleep(2^attempt)
        end
    end
end
for t in tests
    fp = "$(t).jl"
    println("* $fp ...")
    include(fp)
end

println("* jet.jl ...")
include("jet.jl")

Aqua.test_all(ScrapeSEC; ambiguities=false)
