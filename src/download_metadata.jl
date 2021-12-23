
"""
    function get_metadata_urls(
        time_periods::Vector{Tuple{Int64, Int64}}
    )::Vector{String}

Creates an array of URLs for the metadata files

Parameters
* time_periods: Vector of time periods (year, quarter) to get metadata files Vector{Tuple{year, quarter}}

Returns: Vector of metadata urls
"""
function get_metadata_urls(time_periods::Vector{Tuple{Int64, Int64}})::Vector{String}

    # get urls for all time get_time_periods
    edgar_prefix = "https://www.sec.gov/Archives/"
    urls = [edgar_prefix * "edgar/full-index/"*string(i[1])*"/QTR"*string(i[2])*"/master.zip" for i in time_periods]

    return urls
end

"""
    function download_metadata(url::String; dest::String, 
        skip_file=false::Bool, verbose=false::Bool
    )

Download filing metadata CSV file

Parameters
* url: URL where metadata file is hosted
* dest: Destination folder
* skip_file: If true, existing files will be skipped
* verbose: Print out log 
"""
function download_metadata(url::String; dest::String, skip_file=false::Bool, verbose=false::Bool)
    
    # get full file path for download
    full_file = split(url, "/")[end-2] * "-" * split(url, "/")[end-1] * ".tsv"
    full_file = joinpath(dest, full_file)
    if verbose; println(full_file); end
    
    #TODO: unique temp files, so we can async download metadata
    temp_file = "main.idx"
    temp_zip = "main.zip"

    # check if we skip the download
    if isfile(full_file) & skip_file
        if verbose; println("Skipping " * full_file); end
        return
    end

    # download, unzip file
    HTTP.download(url, temp_zip)
    zarchive = ZipFile.Reader(temp_zip)
    for f in zarchive.files
        @assert f.name == "master.idx"
        out = open(temp_file,"w")
        write(out,read(f,String))
        close(out)
    end
    close(zarchive)
    rm(temp_zip)

    # import unziped file for cleaning
    f = open(temp_file, "r")
    metadata = readlines(f)[10:end] # skip fluff at top
    close(f)
    rm(temp_file)

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
    function download_metadata_files(start_year::Int64, end_year=nothing::Union{Int64, Nothing};
        quarters=[1, 2, 3, 4]::Vector{Int64},
        skip_file=false::Bool, 
        dest="../metadata/"::String, 
        verbose=false::Bool,
        download_rate=10::Int
    )

Download all metadata files over a time range

Parameters
* start_year: first year in range
* end_year: last year in range
* quarters: Quarters of the year to download files from [1,2,3,4]
* skip_file: If true, existing files will be skipped
* verbose: Print out log
"""
function download_metadata_files(start_year::Int64, end_year=nothing::Union{Int64, Nothing};
                        quarters=[1, 2, 3, 4]::Vector{Int64},
                        skip_file=false::Bool, 
                        dest="../metadata/"::String, 
                        verbose=false::Bool)


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

    # download metadata files
    @showprogress 1 "Downloading Metadata..."  for idx in eachindex(urls)
        download_metadata(urls[idx]; dest=dest, 
                    skip_file=skip_file, verbose=verbose)
    end

    return
end
