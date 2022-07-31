
module ScrapeSEC

# Dependencies
using DataFrames
import Dates
import CSV
import HTTP
using Term.Progress
import ZipFile

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

