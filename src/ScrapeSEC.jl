
module ScrapeSEC

    # Dependencies
    using DataFrames
    import Dates
    import CSV
    import HTTP
    using ProgressMeter
    import ZipFile

    # source files
    include("download_metadata.jl")
    include("main_index.jl")
    include("download_filings.jl")

    export 
    # metadata functions
    download_metadata_files, create_main_index,

    # filing downloaders
    get_quarterly_filings, download_filing

end

