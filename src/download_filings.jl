"""
Function to return the text. Added this to allow custom text cleaning functions
"""
_pass_text(text) = text

function _extract_period_end_date(text::String)::String
    i = findfirst("CONFORMED PERIOD OF REPORT:", text)
    if i !== nothing
        line_end = findnext('\n', text, i.stop)
        if line_end !== nothing
            date_str = text[(i.stop + 1):(line_end - 1)]
            return strip(date_str)
        end
    end
    return ""
end

function get_primary_document_url(
    full_url::String, full_text::String, index_text::String
)::String
    period_end_date = _extract_period_end_date(full_text)
    primary_file_name = replace(split(full_url, "/edgar/")[2], "-" => "")
    primary_file_name = replace(primary_file_name, ".txt" => "") * "/"
    edgar_prefix = "https://www.sec.gov/Archives/"
    pattern = Regex("edgar/$primary_file_name\\w+-$(period_end_date)\\.htm")
    match_obj = match(pattern, index_text)
    if match_obj !== nothing
        primary_doc_url = edgar_prefix * match_obj.match
    else
        primary_doc_url = ""
    end
    return primary_doc_url
end

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
* `primary_document`: if true only download the primary document (if it exists)
"""
function download_filing(
    file_name::String,
    new_file::String,
    dest::String;
    clean_text::Function=_pass_text,
    primary_document::Bool=false,
)
    company_folder = joinpath(dest, split(new_file, "/")[end - 1])
    if !isdir(company_folder)
        mkdir(company_folder)
    end
    full_url = "https://www.sec.gov/Archives/" * file_name
    text = String(HTTP.get(full_url).body)

    if primary_document
        index_url = replace(full_url, ".txt" => "-index.html")
        index_text = String(HTTP.get(index_url).body)
        primary_doc_url = get_primary_document_url(full_url, text, index_text)
        if primary_doc_url != ""
            try
                text = String(HTTP.get(primary_doc_url).body)
            catch e
                # println("Failed to download primary document from $primary_doc_url")
                # println("Using full text instead")
                pass
            end
        end
    end

    text = clean_text(text)
    open(new_file, "w") do f
        write(f, text)
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
    clean_text=nothing,
    primary_document=false,
)
```

Download all filings from a Vector of file names

Parameters
* `filenames`: Vector of file names to download
* `dest`: Destination folder for downloaded filings
* `download_rate`: Number of filings to download every second (limit=10)
* `skip_file`: If true, existing files will be skipped
* `pbar_desc`: pbar Description
* `runnings_tests`: If true, only downloads one file
* `clean_text`: function to clean text before writing to file
* `primary_document`: if true only download the primary document (if it exists)
"""
function download_filings(
    filenames::AbstractVector;
    dest="./data/"::String,
    download_rate=10::Int,
    skip_file=true::Bool,
    pbar_desc="Downloading Filings"::String,
    running_tests=false::Bool,
    clean_text::Function=_pass_text,
    primary_document::Bool=false,
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
        filenames = filter(
            file -> !isfile(joinpath(dest, replace(file, "edgar/data/" => ""))), filenames
        )
    end

    if isempty(filenames)
        return nothing
    end

    p = Progress(size(filenames, 1); desc=pbar_desc)
    for file in filenames
        full_file = joinpath(dest, replace(file, "edgar/data/" => ""))

        @async download_filing(file, full_file, dest; clean_text, primary_document)

        next!(p)
        sleep(sleep_time)

        if running_tests
            break
        end
    end
    finish!(p)

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
    clean_text=nothing,
    primary_document::Bool=false,
)
```

Download quarterly filings from https://www.sec.gov/Archives/ using a metadata file

Parameters
* `metadata_file`: CSV file with filing metadata
* `dest`: Destination folder for downloaded filings
* `filing_types`: Types of filings to download (eg. ["10-K", "10-Q"])
* `download_rate`: Number of filings to download every second (limit=10)
* `skip_file`: If true, existing files will be skipped
* `pbar_desc`: pbar Description
* `runnings_tests`: If true, only downloads one file
* `clean_text`: function to clean text before writing to file
* `primary_document`: if true only download the primary document (if it exists)
"""
function download_filings(
    metadata_file::String;
    dest="./data/"::String,
    filing_types=["10-K"]::Vector{String},
    download_rate=10::Int,
    skip_file=true::Bool,
    pbar_desc="Downloading Filings"::String,
    running_tests=false::Bool,
    clean_text::Function=_pass_text,
    primary_document::Bool=false,
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
        pbar_desc=pbar_desc,
        running_tests=running_tests,
        clean_text,
        primary_document,
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
    clean_text=nothing,
    primary_document::Bool=false,
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
* `primary_document`: if true only download the primary document (if it exists)
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
    primary_document::Bool=false,
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
    p = Progress(size(time_periods, 1); desc="Iterating Over Time Periods...")
    for t in time_periods
        file = joinpath(metadata_dest, string(t[1]) * "-QTR" * string(t[2]) * ".tsv")
        download_filings(
            file;
            dest=dest,
            filing_types=filing_types,
            download_rate=download_rate,
            skip_file=skip_file,
            pbar_desc="Downloading $(t[1]) Q$(t[2]) Filings",
            running_tests=running_tests,
            clean_text,
            primary_document,
        )
        next!(p)
    end
    finish!(p)

    return nothing
end
