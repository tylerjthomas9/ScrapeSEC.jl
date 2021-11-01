
"""
Creates an array of URLs for the metadata files

Parameters
----------
time_periods::Vector{Tuple{Int64, Int64}})
  * Vector of time periods (year, quarter) to get metadata files Vector{Tuple{year, quarter}}

Returns
----------
urls::Vector{String}
  * Vector of metadata urls
"""
function get_metadata_urls(time_periods::Vector{Tuple{Int64, Int64}})::Vector{String}

    # get urls for all time get_time_periods
    edgar_prefix = "https://www.sec.gov/Archives/"
    urls = [edgar_prefix * "edgar/full-index/"*string(i[1])*"/QTR"*string(i[2])*"/master.zip" for i in time_periods]

    return urls
end

"""
Download filing metadata CSV file

Parameters
----------
url::String
  * URL where metadata file is hosted
dest::String
  * Destination folder
temp_file::String
  * Name of temporary zip file
skip_file::Bool
  * If true, existing files will be skipped
verbose::Bool

Returns
----------
nothing
"""
function download_metadata(url::String; dest::String, temp_file::String, skip_file=false::Bool, verbose=false::Bool)
    
    # get full file path for download
    full_file = split(url, "/")[end-2] * "-" * split(url, "/")[end-1] * ".tsv"
    full_file = joinpath(dest, full_file)
    if verbose; println(full_file); end
    
    # make unique temp file
    temp_file = joinpath(dest, temp_file * split(full_file, "/")[end][1:end-4] * ".zip")

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

    return
end

"""
Download all metadata files over a time range

Parameters
----------
start_year::Int
  * first year in range
end_year::Int
  * last year in range
quarters::Vector{Int64}
  * Quarters of the year to download files from [1,2,3,4]
skip_file::Bool
  * If true, existing files will be skipped
temp_file::String
  * Name of temporary zip file
verbose:Bool
download_rate::Int
  * Number of filings to download every second (limit=10)

Returns
----------
nothing
"""
function get_metadata(start_year::Int64, end_year=nothing::Union{Int64, Nothing};
                        quarters=[1, 2, 3, 4]::Vector{Int64},
                        skip_file=false::Bool, 
                        dest="../metadata/"::String, 
                        temp_file="temp_"::String,
                        verbose=false::Bool,
                        download_rate=10::Int)


    # verify download_rate is valid (less than 10 requests per second, more than 0)
    if download_rate > 10
        download_rate = 10
        println("download_rate of more than 10 per second(", download_rate, ") is not valid. download_rate has been set to 10/second.")
    elseif download_rate < 1
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
    time_periods = [(y, q) for y in years for q in quarters if (q <= current_quarter || y < current_year) && (q > 2 || y > 1993)]
    
    # get download urls
    urls = get_metadata_urls(time_periods)

    # download metadata files at 10 requests per second
    sleep_time = 1 / download_rate 
    @showprogress 1 "Downloading Metadata..."  for idx in eachindex(urls)
        #TODO: Fix async here. All tasks unzip to the same file name, so it currently doesn't work
        #@async download_metadata(urls[idx]; dest=dest, temp_file=temp_file, skip_file=skip_file, verbose=true)
        download_metadata(urls[idx]; dest=dest, temp_file=temp_file, skip_file=skip_file, verbose=verbose)
        sleep(0.5)
    end

    return
end
