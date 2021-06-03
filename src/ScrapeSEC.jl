module ScrapeSEC

    include("DownloadMetadata.jl")
    include("DownloadFilings.jl")

    export 
    # metadata functions
    get_metadata

    # filing downloaders
    get_quarterly_filings

end
