"""
Function to return the text. Added this to allow custom text cleaning functions
"""
_pass_text(text) = text

"""
```julia
function download_filing(file_name::String, 
                        new_file::String, 
                        dest::String;
                        clean_text::Function)
```

Download filing from https://www.sec.gov/Archives/

Parameters
* `file_name`: SEC file name
* `new_file`: new local file
* `dest`: destination folder
* `clean_text`: function to clean text before writing to file
"""
function download_filing(
    file_name::String, new_file::String, dest::String; clean_text::Function=_pass_text
)
    full_url = "https://www.sec.gov/Archives/" * file_name
    text = HTTP.get(full_url).body

    company_folder = joinpath(dest, split(new_file, "/")[end - 1])
    if !isdir(company_folder)
        mkdir(company_folder)
    end

    open(new_file, "w") do f
        write(f, clean_text(text))
    end

    return nothing
end

"""
```julia
function download_filings(
    filenames::Vector;
    dest="./data/"::String,
    download_rate=10::Int,
    skip_file=true::Bool,
    pbar=ProgressBar(; )::ProgressBar,
    stop_pbar=true::Bool,
    pbar_desc="Downloading Filings"::String,
    running_tests=false::Bool,
    clean_text=nothing
)
```

Download all filings from a Vector of file names

Parameters
* `filenames`: Vector of file names to download
* `dest`: Destination folder for downloaded filings
* `download_rate`: Number of filings to download every second (limit=10)
* `skip_file`: If true, existing files will be skipped
* `pbar`: ProgressBar (Term.jl)
* `stop_pbar`: If false, progress bar will not be stopped
* `pbar_desc`: pbar Description
* `runnings_tests`: If true, only downloads one file
* `clean_text`: function to clean text before writing to file
"""
function download_filings(
    filenames::AbstractVector;
    dest="./data/"::String,
    download_rate=10::Int,
    skip_file=true::Bool,
    pbar=ProgressBar(;)::ProgressBar,
    stop_pbar=true::Bool,
    pbar_desc="Downloading Filings"::String,
    running_tests=false::Bool,
    clean_text::Function=_pass_text,
)
    if download_rate > 10
        download_rate = 10
        println(
            "download_rate of more than 10 per second(",
            download_rate,
            ") is not valid. download_rate has been set to 10/second.",
        )
    end

    if !isdir(dest)
        mkdir(dest)
    end

    # download filings at 10 requests per second
    sleep_time = 1 / download_rate

    if skip_file
        filenames = filter(file -> !isfile(joinpath(dest, replace(file, "edgar/data/" => ""))), filenames)
    end

    if isempty(filenames)
        return nothing
    end

    job = addjob!(pbar; N=size(filenames, 1), description=pbar_desc)
    start!(pbar)
    for file in filenames
        full_file = joinpath(dest, replace(file, "edgar/data/" => ""))

        @async download_filing(file, full_file, dest; clean_text)

        update!(job)
        sleep(sleep_time)
        render(pbar)

        if running_tests
            break
        end
    end
    if stop_pbar
        stop!(pbar)
    end

    return nothing
end

"""
```julia
function download_filings(
    metadata_file::String; 
    dest="./data/"::String, 
    filing_types=["10-K", ]::Vector{String}, 
    download_rate=10::Int, 
    skip_file=true::Bool,
    pbar=ProgressBar(; )::ProgressBar,
    stop_pbar=true::Bool,
    pbar_desc="Downloading Filings"::String,
    running_tests=false::Bool,
    clean_text=nothing
)
```

Download quarterly filings from https://www.sec.gov/Archives/ using a metadata file

Parameters
* `metadata_file`: CSV file with filing metadata
* `dest`: Destination folder for downloaded filings
* `filing_types`: Types of filings to download (eg. ["10-K", "10-Q"])
* `download_rate`: Number of filings to download every second (limit=10)
* `skip_file`: If true, existing files will be skipped
* `pbar`: ProgressBar (Term.jl)
* `stop_pbar`: If false, progress bar will not be stopped
* `pbar_desc`: pbar Description
* `runnings_tests`: If true, only downloads one file
* `clean_text`: function to clean text before writing to file
"""
function download_filings(
    metadata_file::String;
    dest="./data/"::String,
    filing_types=["10-K"]::Vector{String},
    download_rate=10::Int,
    skip_file=true::Bool,
    pbar=ProgressBar(;)::ProgressBar,
    stop_pbar=true::Bool,
    pbar_desc="Downloading Filings"::String,
    running_tests=false::Bool,
    clean_text::Function=_pass_text,
)
    if download_rate > 10
        download_rate = 10
        println(
            "download_rate of more than 10 per second(",
            download_rate,
            ") is not valid. download_rate has been set to 10/second.",
        )
    end

    df = DataFrame(CSV.File(metadata_file; delim="|"))
    if isempty(df)
        @warn "No filings found in metadata file: $metadata_file"
        return nothing
    end
    df = df[∈(filing_types).(df[!, "Form Type"]), :]

    download_filings(
        df.Filename;
        dest=dest,
        download_rate=download_rate,
        skip_file=skip_file,
        pbar=pbar,
        stop_pbar=stop_pbar,
        pbar_desc=pbar_desc,
        running_tests=running_tests,
        clean_text,
    )

    return nothing
end

"""
```julia
function download_filings(
    start_year::Int, 
    end_year::Int; 
    quarters=[1,2,3,4]::Vector{Int}, 
    dest="./data/"::String, 
    filing_types=["10-K", ]::Vector{String}, 
    download_rate=10::Int, 
    metadata_dest="./metadata/"::String,
    skip_file=true::Bool, 
    skip_metadata_file=true::Bool,
    running_tests=false::Bool,
    clean_text=nothing
)
```

Download quarterly filings from https://www.sec.gov/Archives/

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
* `runnings_tests`: If true, only downloads one file
* `clean_text`: function to clean text before writing to file
"""
function download_filings(
    start_year::Int,
    end_year::Int;
    quarters=[1, 2, 3, 4]::Vector{Int},
    dest="./data/"::String,
    filing_types=["10-K"]::Vector{String},
    download_rate=10::Int,
    metadata_dest="./metadata/"::String,
    skip_file=true::Bool,
    skip_metadata_file=true::Bool,
    running_tests=false::Bool,
    clean_text::Function=_pass_text,
)
    current_date = Dates.now() - Dates.Day(1) #https://github.com/tylerjthomas9/ScrapeSEC.jl/issues/24
    current_year = Dates.year(current_date)
    current_quarter = Dates.quarterofyear(current_date)

    if end_year == nothing
        end_year = current_year
    end

    years = collect(start_year:end_year)
    time_periods = [
        (y, q) for y in years for
        q in quarters if (q <= current_quarter || y < current_year) && (q > 2 || y > 1993)
    ]

    download_metadata_files(
        start_year,
        end_year;
        quarters=quarters,
        dest=metadata_dest,
        skip_file=skip_metadata_file,
    )

    pbar = ProgressBar(; columns=progress_bar_columns)
    job = addjob!(
        pbar; N=size(time_periods, 1), description="Iterating Over Time Periods..."
    )
    start!(pbar)
    for t in time_periods
        file = joinpath(metadata_dest, string(t[1]) * "-QTR" * string(t[2]) * ".tsv")
        download_filings(
            file;
            dest=dest,
            filing_types=filing_types,
            download_rate=download_rate,
            skip_file=skip_file,
            pbar=pbar,
            stop_pbar=false,
            pbar_desc="Downloading $(t[1]) Q$(t[2]) Filings",
            running_tests=running_tests,
            clean_text,
        )
        update!(job)
        render(pbar)
    end
    stop!(pbar)

    return nothing
end
