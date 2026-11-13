"""
    _time_periods(start_year, end_year, quarters) -> Vector{Tuple{Int,Int}}

`(year, quarter)` pairs from `start_year` through `end_year` (the current year when
`nothing`). Quarters that have not started yet and 1993 Q1–Q2, which have no EDGAR
index, are left out.
"""
function _time_periods(
    start_year::Int, end_year::Union{Int,Nothing}, quarters::Vector{Int}
)::Vector{Tuple{Int,Int}}
    current_date = Dates.now() - Dates.Day(1) #https://github.com/tylerjthomas9/ScrapeSEC.jl/issues/24
    current_year = Dates.year(current_date)
    current_quarter = Dates.quarterofyear(current_date)
    end_year = something(end_year, current_year)

    return [
        (y, q) for y in start_year:end_year for q in quarters if
        (y < current_year || (y == current_year && q <= current_quarter)) &&
            (q > 2 || y > 1993)
    ]
end

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
    skip_file::Bool=false, verbose::Bool=false
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
    url::String; dest::String, skip_file::Bool=false, verbose::Bool=false
)
    full_file = split(url, "/")[end - 2] * "-" * split(url, "/")[end - 1] * ".tsv"
    full_file = joinpath(dest, full_file)
    if verbose
        println(full_file)
    end

    if isfile(full_file) && skip_file
        if verbose
            println("Skipping " * full_file)
        end
        return nothing
    end

    # unique temp directory so concurrent downloads don't clobber each other
    tmp_dir = mktempdir()
    temp_file = joinpath(tmp_dir, "main.idx")
    temp_zip = joinpath(tmp_dir, "main.zip")

    ScrapeSEC.download_file(url, temp_zip)
    zarchive = ZipFile.Reader(temp_zip)
    for zip_file in zarchive.files
        @assert zip_file.name == "master.idx"
        open(temp_file, "w") do f
            return write(f, read(zip_file, String))
        end
    end
    close(zarchive)

    metadata = open(temp_file, "r") do f
        return readlines(f)[10:end] # skip fluff at top
    end
    rm(tmp_dir; recursive=true)

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
function download_metadata_files(
    start_year::Int64,
    end_year::Union{Int64,Nothing}=nothing;
    quarters::Vector{Int}=[1, 2, 3, 4],
    skip_file::Bool=false,
    dest::String="./metadata/",
    verbose::Bool=false,
)
```

Download all metadata files over a time range

Parameters
* `start_year`: first year in range
* `end_year`: last year in range (defaults to the current year)
* `quarters`: Quarters of the year to download files from [1,2,3,4]
* `skip_file`: If true, existing files will be skipped
* `verbose`: Print out log
"""
function download_metadata_files(
    start_year::Int64,
    end_year::Union{Int64,Nothing}=nothing;
    quarters::Vector{Int}=[1, 2, 3, 4],
    skip_file::Bool=false,
    dest::String="./metadata/",
    verbose::Bool=false,
)
    println("Metadata Destination:  " * dest)
    if !isdir(dest)
        mkdir(dest)
    end

    time_periods = _time_periods(start_year, end_year, quarters)
    urls = get_metadata_urls(time_periods)
    n_files = size(urls, 1)
    p = Progress(n_files; desc="Downloading Metadata CSVs...")
    for url in urls
        ScrapeSEC.download_metadata(url; dest=dest, skip_file=skip_file, verbose=verbose)
        next!(p)
    end
    finish!(p)

    return nothing
end
