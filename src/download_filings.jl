
"""
```julia
function download_filing(file_name::String, 
    new_file::String, dest::String
)
```

Download filing from https://www.sec.gov/Archives/

Parameters
* `file_name`: SEC file name
* `new_file`: new local file
"""
function download_filing(file_name::String, new_file::String, dest::String)
    # get filing from SEC
    full_url = "https://www.sec.gov/Archives/" * file_name
    text = HTTP.get(full_url).body::String

    # create company folder
    company_folder = joinpath(dest, split(new_file, "/")[end-1])
    if !isdir(company_folder)
        mkdir(company_folder)
    end

    # save filing
    f = open(new_file, "w")
    write(f, text)
    close(f)

    return
end


"""
```julia
function get_quarterly_filings(
    metadata_file::String; 
    dest="./data/"::String, 
    filing_types=["10-K", ]::Vector{String}, 
    download_rate=10::Int, 
    skip_file=true::Bool
)
```

Get quarterly filings from https://www.sec.gov/Archives/ using a metadata file

Parameters
* `metadata_file`: CSV file with filing metadata
* `dest`: Destination folder for downloaded filings
* `filing_types`: Types of filings to download (eg. ["10-K", "10-Q"])
* `download_rate`: Number of filings to download every second (limit=10)
* `skip_file`: If true, existing files will be skipped
"""
function get_quarterly_filings(
    metadata_file::String;
    dest = "./data/"::String,
    filing_types = ["10-K"]::Vector{String},
    download_rate = 10::Int,
    skip_file = true::Bool,
)

    # verify download_rate is valid (less than 10 requests per second, more than 0)
    if download_rate > 10
        download_rate = 10
        println(
            "download_rate of more than 10 per second(",
            download_rate,
            ") is not valid. download_rate has been set to 10/second.",
        )
    end

    println("Metadata: " * metadata_file)

    df = CSV.File(metadata_file, delim = "|") |> DataFrame
    df = df[∈(filing_types).(df[!, "Form Type"]), :]

    # create download folder if needed
    if !isdir(dest)
        mkdir(dest)
    end

    # download filings at 10 requests per second
    sleep_time = 1 / download_rate
    @showprogress 1 "Downloading Filings..." for row in eachrow(df)

        # check if filing already has been downloaded
        full_file = joinpath(dest, replace(row["Filename"], "edgar/data/" => ""))
        if isfile(full_file) && skip_file
            continue
        end

        # download new filing
        @async download_filing(row["Filename"], full_file, dest)

        # rest to throttle api hits to around 10/second
        sleep(sleep_time)
    end

    return
end


"""
```julia
function get_quarterly_filings(
    start_year::Int, 
    end_year::Int; 
    quarters=[1,2,3,4]::Vector{Int}, 
    dest="./data/"::String, 
    filing_types=["10-K", ]::Vector{String}, 
    download_rate=10::Int, 
    metadata_dest="./metadata/"::String,
    skip_file=true::Bool, 
    skip_metadata_file=true::Bool
)
```

Get quarterly filings from https://www.sec.gov/Archives/

Parameters
* `start_year`: First year to download filings
* `end_year`: Last year to download filings
* `quarters`: Quarters to download filings from
* `dest`: Destination folder for downloaded filings
* `filing_types`: Types of filings to download (eg. ["10-K", "10-Q"])
* `download_rate`: Number of filings to download every second (limit=10)
* `metadata_dest`: Directory to store metadata files
* `skip_file`: If true, existing files will be skipped
* `skip_metadata_file`: If true, existing metadata files will be skipped
"""
function get_quarterly_filings(
    start_year::Int,
    end_year::Int;
    quarters = [1, 2, 3, 4]::Vector{Int},
    dest = "./data/"::String,
    filing_types = ["10-K"]::Vector{String},
    download_rate = 10::Int,
    metadata_dest = "./metadata/"::String,
    skip_file = true::Bool,
    skip_metadata_file = true::Bool,
)

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
    time_periods = [
        (y, q) for y in years for q in quarters if
        (q <= current_quarter || y < current_year) && (q > 2 || y > 1993)
    ]

    # make sure all the metadata is downloaded
    download_metadata_files(
        start_year,
        end_year;
        quarters = quarters,
        #download_rate = download_rate,
        dest = metadata_dest,
        skip_file = skip_metadata_file,
    )


    # download all quarterly filings
    file_paths = [
        joinpath(metadata_dest, string(t[1]) * "-QTR" * string(t[2]) * ".tsv") for
        t in time_periods
    ]
    for file in file_paths
        get_quarterly_filings(
            file;
            dest = dest,
            filing_types = filing_types,
            download_rate = download_rate,
            skip_file = skip_file,
        )
    end

    return
end
