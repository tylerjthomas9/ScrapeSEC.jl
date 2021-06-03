using DataFrames
import CSV
import HTTP
using ProgressMeter
include("download_metadata.jl")


"""
Download filing from https://www.sec.gov/Archives/

Parameters
----------
row
    - row of metadata for filing
full_file::String
    - new local file
"""
function download_filing(row, full_file::String)
    # get filing from SEC
    full_url = "https://www.sec.gov/Archives/" * row["Filename"]
    text = HTTP.get(full_url).body

    # create company folder
    company_folder = joinpath(dest, split(row["Filename"], "/")[end-1])
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
Get quarterly filings from https://www.sec.gov/Archives/

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
"""
function get_quarterly_filings(metadata_file::String, dest="../data/"::String; filing_types=["10-K", ]::Vector{String}, download_rate=10::Int)

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
        @async download_filing(row, full_file)
        
        # rest to throttle api hits to around 10/second
        sleep(sleep_time)
    end

    return
end



#get_quarterly_filings("../metadata/2000-QTR1.tsv")