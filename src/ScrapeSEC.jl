
module ScrapeSEC

# Dependencies
using DataFrames
using Dates: Dates
using CSV: CSV
using HTTP: HTTP
using Term.Progress
using ZipFile: ZipFile

const progress_bar_columns = [
    Progress.DescriptionColumn,
    Progress.SeparatorColumn,
    Progress.ProgressColumn,
    Progress.CompletedColumn,
    Progress.SeparatorColumn,
    Progress.ETAColumn,
]

# source files
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
