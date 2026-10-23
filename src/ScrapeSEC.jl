
module ScrapeSEC

using DataFrames
using Dates: Dates
using CSV: CSV
using HTTP: HTTP
using ProgressMeter
using ZipFile: ZipFile

include("download_metadata.jl")
include("main_index.jl")
include("download_filings.jl")

# Network seams. Tests override these to serve saved example responses
# (see test/data/fixtures) so the suite never hits the SEC API.
function fetch_bytes(url::AbstractString)::String
    return String(HTTP.get(url).body)
end

function download_file(url::AbstractString, path::AbstractString)
    return HTTP.download(url, path; update_period=Inf)
end

export
    # metadata functions
    download_metadata_files,
    create_main_index,

    # filing downloaders
    download_filings,
    download_filing

end
