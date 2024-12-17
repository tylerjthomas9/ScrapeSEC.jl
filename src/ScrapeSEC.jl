
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

export
    # metadata functions
    download_metadata_files,
    create_main_index,

    # filing downloaders
    download_filings,
    download_filing

end
