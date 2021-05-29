using Distributed
using DataFrames
import CSV
import HTTP
using ProgressMeter
include("DownloadMetadata.jl")



function download_filing(row, full_file)
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


function download_quarterly_filings(metadata_file::String, dest="../data/"::String; download_rate=10::Int)

    # verify download_rate is valid (less than 10 requests per second, more than 0)
    if download_rate > 10
        download_rate = 10
        println("download_rate of more than 10 per second(", download_rate, ") is not valid. download_rate has been set to 10/second.")
    else if download_rate < 1
        download_rate = 1
        println("download_rate of less than 1 per second(", download_rate, ") is not valid. download_rate has been set to 1/second.")
    end

    
    println("Metadata: " * metadata_file)
    
    df = DataFrame(CSV.File(metadata_file, delim="|"))
    df = df[df[!, "Form Type"] .== "10-K", :] # just 10-K's

    # create download folder if needed
    if !isdir(dest)
        mkdir(dest)
    end
    
    # download filings at 10 requests per second
    @showprogress 1 "Downloading Filings..." for row in eachrow(df)
        
        # check if filing already has been downloaded
        full_file = joinpath(dest, replace(row["Filename"], "edgar/data/" => ""))
        if isfile(full_file)
            next 
        end
        
        # download new filing
        @async download_filing(row, full_file)
        
        # rest to throttle api hits to around 10/second
        sleep(0.1)
    end

    return
end



download_quarterly_filings("../metadata/2000-QTR1.tsv")
"""
for year in 2008:2011
    for quarter in ["1", "2", "3", "4"]
        if year == 2003 && quarter == "1"; continue; end
        download_quarterly_filings("../metadata/"*string(year)*"-QTR"*quarter*".tsv")
    end
end

"""