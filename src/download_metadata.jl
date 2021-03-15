import Dates
import CSV
import ZipFile

#url = "https://www.sec.gov/Archives/edgar/daily-index/";
#res = HTTP.get(url);
#SEP = "|"

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


function download_metadata(url::String, dest::String, temp_file::String, skip_file::Bool)
    # get full file path for download
    full_file = split(url, "/")[end-2] * "-" * split(url, "/")[end-1] * ".tsv"
    full_file = joinpath(dest, full_file)
    println(full_file)

    # check if we skip the download
    if isfile(full_file) & skip_file
        println("Skipping " * full_file)
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


function get_metadata(start_year; skip_file=true, dest="../metadata/"::String, 
                        temp_file="temp.zip"::String)

    # create download folder if needed
    if !isdir(dest)
        mkdir(dest)
    end
    # get download urls
    urls = get_metadata_urls(start_year)

    # download metadata files
    for url in urls
        download_metadata(url, dest, temp_file, false)
    end
end


#get_metadata(1993)


#df = DataFrame(CSV.File("../data/2021-QTR1.tsv", delim="|"))