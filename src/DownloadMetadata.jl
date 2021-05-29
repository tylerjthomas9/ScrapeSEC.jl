import Dates
import CSV
import ZipFile
using ProgressMeter

function get_metadata_urls(start_year=1993::Int)::Vector{String}
    # get current year, quarter
    current_date = Dates.now()
    current_year = Dates.year(current_date)
    current_quarter = Dates.quarterofyear(current_date)

    # get an array of dates to download metadata
    quarters = [1, 2, 3, 4]
    years = collect(start_year:current_year)
    history = [(y, q) for y in years for q in quarters if (q <= current_quarter || y < current_year)]

    # get urls for all time get_time_periods
    edgar_prefix = "https://www.sec.gov/Archives/"
    urls = [edgar_prefix * "edgar/full-index/"*string(i[1])*"/QTR"*string(i[2])*"/master.zip" for i in history]

    return urls
end

function get_metadata_urls(time_periods::Vector{Tuple{Int64, Int64}})::Vector{String}

    # get urls for all time get_time_periods
    edgar_prefix = "https://www.sec.gov/Archives/"
    urls = [edgar_prefix * "edgar/full-index/"*string(i[1])*"/QTR"*string(i[2])*"/master.zip" for i in time_periods]

    return urls
end


function download_metadata(url::String, dest::String, temp_file::String, skip_file::Bool, verbose::Bool)
    
    # get full file path for download
    full_file = split(url, "/")[end-2] * "-" * split(url, "/")[end-1] * ".tsv"
    full_file = joinpath(dest, full_file)
    if verbose; println(full_file); end
    
    # make unique temp file
    temp_file = temp_file + split(full_file, "/")[end]

    # check if we skip the download
    if isfile(full_file) & skip_file
        if verbose; println("Skipping " * full_file); end
        return
    end

    # download, unzip file
    download(url, temp_file)
    run(`unzip -o -qq $temp_file`)
    rm(temp_file)

    # import unziped file for cleaning
    f = open("master.idx", "r")
    metadata = readlines(f)[10:end] # skip fluff at top
    close(f)
    rm("master.idx")

    # save metadata file
    f = open(full_file, "w")
    for line in metadata
        if occursin("|", line) # skip "----------" line
            write(f, line * "\n")
        end
    end
    close(f)

end


function get_metadata(start_year::Int64, end_year=nothing::Union{Int64, Nothing};
                        quarters=[1, 2, 3, 4]::Vector{Int64},
                        skip_file=false::Bool, 
                        dest="../metadata/"::String, 
                        temp_file="temp.zip"::String,
                        verbose=false::Bool,
                        download_rate=10::Int)


    # verify download_rate is valid (less than 10 requests per second, more than 0)
    if download_rate > 10
        download_rate = 10
        println("download_rate of more than 10 per second(", download_rate, ") is not valid. download_rate has been set to 10/second.")
    else if download_rate < 1
        download_rate = 1
        println("download_rate of less than 1 per second(", download_rate, ") is not valid. download_rate has been set to 1/second.")
    end

    # create download folder if needed
    println("Metadata Destination:  " * dest)
    if !isdir(dest)
        mkdir(dest)
    end
    
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
    
    # get download urls
    urls = get_metadata_urls(time_periods)

    # download metadata files at 10 requests per second
    sleep_time = 1 / download_rate 
    @showprogress 1 "Downloading Metadata..." for idx in eachindex(urls)
        @async download_metadata(urls[idx], dest, temp_file, skip_file, verbose)
        sleep()
    end
end


if abspath(PROGRAM_FILE) == @__FILE__
    get_metadata(1993)
end

#df = DataFrame(CSV.File("../data/2021-QTR1.tsv", delim="|"))