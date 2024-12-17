
"""
```julia
function get_metadata_urls(
    time_periods::Vector{Tuple{Int64, Int64}}
)::Vector{String}
```
Creates an array of URLs for the metadata files

Parameters
* `time_periods`: Vector of time periods (year, quarter) to get metadata files Vector{Tuple{year, quarter}}

Returns: Vector of metadata urls
"""
function get_metadata_urls(time_periods::Vector{Tuple{Int64,Int64}})::Vector{String}
    edgar_prefix = "https://www.sec.gov/Archives/"
    urls = [
        edgar_prefix *
        "edgar/full-index/" *
        string(i[1]) *
        "/QTR" *
        string(i[2]) *
        "/master.zip" for i in time_periods
    ]

    return urls
end

"""
```julia
function download_metadata(url::String; dest::String, 
    skip_file=false::Bool, verbose=false::Bool
)
```
Download filing metadata CSV file

Parameters
* `url`: URL where metadata file is hosted
* `dest`: Destination folder
* `skip_file`: If true, existing files will be skipped
* `verbose`: Print out log 
"""
function download_metadata(
    url::String; dest::String, skip_file=false::Bool, verbose=false::Bool
)
    full_file = split(url, "/")[end - 2] * "-" * split(url, "/")[end - 1] * ".tsv"
    full_file = joinpath(dest, full_file)
    if verbose
        println(full_file)
    end

    #TODO: unique temp files, so we can async download metadata
    temp_file = "main.idx"
    temp_zip = "main.zip"

    if isfile(full_file) & skip_file
        if verbose
            println("Skipping " * full_file)
        end
        return nothing
    end

    HTTP.download(url, temp_zip; update_period=Inf)
    zarchive = ZipFile.Reader(temp_zip)
    for zip_file in zarchive.files
        @assert zip_file.name == "master.idx"
        open(temp_file, "w") do f
            write(f, read(zip_file, String))
        end
    end
    close(zarchive)
    rm(temp_zip)

    metadata = open(temp_file, "r") do f
        readlines(f)[10:end] # skip fluff at top
    end
    rm(temp_file)

    open(full_file, "w") do f
        for line in metadata
            if occursin("|", line) # skip "----------" line
                write(f, line * "\n")
            end
        end
    end

    return nothing
end

"""
```julia
function download_metadata_files(start_year::Int64, end_year=nothing::Union{Int64, Nothing};
    quarters=[1, 2, 3, 4]::Vector{Int64},
    skip_file=false::Bool, 
    dest="./metadata/"::String, 
    verbose=false::Bool,
    download_rate=10::Int
)
```

Download all metadata files over a time range

Parameters
* `start_year`: first year in range
* `end_year`: last year in range
* `quarters`: Quarters of the year to download files from [1,2,3,4]
* `skip_file`: If true, existing files will be skipped
* `verbose`: Print out log
"""
function download_metadata_files(
    start_year::Int64,
    end_year=nothing::Union{Int64,Nothing};
    quarters=[1, 2, 3, 4]::Vector{Int64},
    skip_file=false::Bool,
    dest="./metadata/"::String,
    verbose=false::Bool,
)
    println("Metadata Destination:  " * dest)
    if !isdir(dest)
        mkdir(dest)
    end

    current_date = Dates.now() - Dates.Day(1) #https://github.com/tylerjthomas9/ScrapeSEC.jl/issues/24
    current_year = Dates.year(current_date)
    current_quarter = Dates.quarterofyear(current_date)

    if isnothing(end_year)
        years = collect(start_year:start_year)
    else
        years = collect(start_year:end_year)
    end
    time_periods = [
        (y, q) for y in years for
        q in quarters if (q <= current_quarter || y < current_year) && (q > 2 || y > 1993)
    ]

    urls = get_metadata_urls(time_periods)
    n_files = size(urls, 1)
    p = Progress(n_files; desc="Downloading Metadata CSVs...")
    for url in urls
        ScrapeSEC.download_metadata(
            url; dest=dest, skip_file=skip_file, verbose=verbose
        )
        next!(p)
    end
    finish!(p)

    return nothing
end
