module ScrapeSEC

    # source files
    using Base: Bool
include("download_metadata.jl")
    include("download_filings.jl")

    export 
    # metadata functions
    get_metadata

    # filing downloaders
    get_quarterly_filings, download_filing

end
