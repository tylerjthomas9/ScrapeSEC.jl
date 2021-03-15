using Distributed
using DataFrames
import CSV
import HTTP
using ProgressMeter



function download_filing(row, dest)
    # check if file already has been downloaded
    full_file = joinpath(dest, replace(row["Filename"], "edgar/data/" => ""))
    if isfile(full_file)
        return 
    end

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


function download_quarterly_filings(metadata_file::String, dest="../data2/"::String)

    println("Metadata: " * metadata_file)
    
    df = DataFrame(CSV.File(metadata_file, delim="|"))
    df = df[df[!, "Form Type"] .== "10-K", :] # just 10-K's

    # create download folder if needed
    if !isdir(dest)
        mkdir(dest)
    end

    # download filings
    println("Using " * string(Threads.nthreads()) * " threads to download " * string(size(df)[1]) * " files")
    p = Progress(size(df)[1], 1, "Downloading...", 50)
    Threads.@threads for row in eachrow(df)
        download_filing(row, dest)
        next!(p)
    end

    return
end


#download_quarterly_filings("../metadata/2000-QTR2.tsv")
for year in 2008:2011
    for quarter in ["1", "2", "3", "4"]
        if year == 2003 && quarter == "1"; continue; end
        download_quarterly_filings("../metadata/"*string(year)*"-QTR"*quarter*".tsv")
    end
end