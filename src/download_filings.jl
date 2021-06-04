using DataFrames
import CSV
import HTTP
using ProgressMeter
include("download_metadata.jl")


"""
Download filing from https://www.sec.gov/Archives/

Parameters
----------
file_name
    - SEC file name
full_file::String
    - new local file
"""
function download_filing(file_name::String, full_file::String)
    # get filing from SEC
    full_url = "https://www.sec.gov/Archives/" * file_name
    text = HTTP.get(full_url).body

    # create company folder
    company_folder = joinpath(dest, split(file_name, "/")[end-1])
    if !isdir(company_folder)
        mkdir(company_folder)
    end

    # save filing
    f = open(full_file, "w")
    write(f, text)
    close(f)

    return
end

"""
Creates an array of file paths of the metadata files

Parameters
----------
time_periods::Vector{Tuple{Int64, Int64}})
    - Vector of time periods (year, quarter) to get metadata files Vector{Tuple{year, quarter}}
metadata_dest::String
    - Directory where metadata is stored
"""
function get_metadata_files(time_periods::Vector{Tuple{Int64, Int64}}, metadata_dest::String)::Vector{String}

    # get file paths for all time get_time_periods
    file_paths = [edgar_metadata_destprefix * string(i[1])*"/QTR"*string(i[2])*"/master.zip" for i in time_periods]

    return file_paths
end

"""
Get quarterly filings from https://www.sec.gov/Archives/ using a metadata file

Parameters
----------
metadata_file::String
    - csv file with filing metadata
dest::String
    - destination folder for downloaded filings
filing_types::Vector{String}
    - types of filings to download (eg. ["10-K", "10-Q"])
download_rate::Int
    - Number of filings to download every second (limit=10)
skip_file::Bool
    - If true, existing files will be skipped
"""
function get_quarterly_filings(metadata_file::String; dest="../data/"::String, filing_types=["10-K", ]::Vector{String}, 
                            download_rate=10::Int, skip_file=true::Bool)

    # verify download_rate is valid (less than 10 requests per second, more than 0)
    if download_rate > 10
        download_rate = 10
        println("download_rate of more than 10 per second(", download_rate, ") is not valid. download_rate has been set to 10/second.")
    elseif download_rate < 1
        download_rate = 1
        println("download_rate of less than 1 per second(", download_rate, ") is not valid. download_rate has been set to 1/second.")
    end
    
    println("Metadata: " * metadata_file)
    
    df = DataFrame(CSV.File(metadata_file, delim="|"))
    #df = df[df[!, "Form Type"] .== "10-K", :] # just 10-K's
    df = df[in.(df[!, "Form Type"], filing_types), :]

    # create download folder if needed
    if !isdir(dest)
        mkdir(dest)
    end
    
    # download filings at 10 requests per second
    sleep_time = 1 / download_rate 
    @showprogress 1 "Downloading Filings..." for row in eachrow(df)
        
        # check if filing already has been downloaded
        full_file = joinpath(dest, replace(row["Filename"], "edgar/data/" => ""))
        if isfile(full_file)
            next 
        end
        
        # download new filing
        @async download_filing(row["Filename"], full_file)
        
        # rest to throttle api hits to around 10/second
        sleep(sleep_time)
    end

    return
end


"""
Get quarterly filings from https://www.sec.gov/Archives/

Parameters
----------
start_year::Int
    - first year to download filings
end_year::Int
    - last year to download filings
quarters::Vector{Int}
    - Quarters to download filings from
dest::String
    - destination folder for downloaded filings
filing_types::Vector{String}
    - types of filings to download (eg. ["10-K", "10-Q"])
download_rate::Int
    - Number of filings to download every second (limit=10)
metadata_dest::String
    - Directory to store metadata files
skip_file::Bool
    - If true, existing files will be skipped
skip_metadata_file::Bool
    - If true, existing metadata files will be skipped
"""
function get_quarterly_filings(start_year::Int, end_year::Int; quarters=[1,2,3,4]::Vector{Int}, 
                                dest="../data/"::String, filing_types=["10-K", ]::Vector{String}, 
                                download_rate=10::Int, metadata_dest="../metadata/"::String,
                                skip_file=true::Bool)

                                # get current year, quarter to prevent errors trying to get future data
    current_date = Dates.now()
    current_year = Dates.year(current_date)
    current_quarter = Dates.quarterofyear(current_date)
    
    # set end year to current year if no year is specified
    if end_year == nothing
        end_year = current_year
    end

    # get an array of dates to download metadata
    years = collect(start_year:end_year)
    time_periods = [(y, q) for y in years for q in quarters if (q <= current_quarter || y < current_year)]

    # make sure all the metadata is downloaded
    get_metadata(start_year, end_Year; quarters=quarters, download_rate=download_rate, dest=metadata_dest)

    file_paths = [metadata_dest * string(t[1]) * "-QTR" * string(t[2]) * ".tsv"]

    for file in file_paths
        get_quarterly_filings(file; dest=dest, filing_types=filing_types, 
                            download_rate=download_rate, skip_file=skip_file)
    end

end


#get_quarterly_filings(1993, 1994)