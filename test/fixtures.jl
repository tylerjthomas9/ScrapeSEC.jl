# Offline test support: override ScrapeSEC's network seams to serve saved
# example responses from test/data/fixtures instead of hitting sec.gov.

using ScrapeSEC: ScrapeSEC
using ZipFile: ZipFile

const FIXTURES_DIR = joinpath(@__DIR__, "data", "fixtures")

# cik -> (filing text fixture, index html fixture)
const FILING_FIXTURES = Dict(
    "880794" => ("880794_9999999997-05-050434.txt", "880794_index.html"),
    "775057" => ("775057_0001096906-21-003058.txt", "775057_index.html"),
)

"""
Build a minimal `master.idx` zip matching the SEC's format. The first 9 lines
are header fluff (stripped by `download_metadata`), followed by the
pipe-delimited column header and data rows.
"""
function synth_master_zip(path::AbstractString)
    idx_content = """
        SEC HEADER LINE 1
        SEC HEADER LINE 2
        SEC HEADER LINE 3
        SEC HEADER LINE 4
        SEC HEADER LINE 5
        SEC HEADER LINE 6
        SEC HEADER LINE 7
        SEC HEADER LINE 8
        --------------------------------------------------------------------------------
        CIK|Company Name|Form Type|Date Filed|Filename
        880794|TEST COMPANY A|10-K|2005-07-01|edgar/data/880794/9999999997-05-050434.txt
        775057|TEST COMPANY B|10-K|2021-02-12|edgar/data/775057/0001096906-21-003058.txt
        """
    tmp = tempname()
    open(tmp, "w") do io
        w = ZipFile.Writer(io)
        f = ZipFile.addfile(w, "master.idx")
        write(f, idx_content)
        close(f)
        close(w)
    end
    cp(tmp, path; force=true)
    rm(tmp; force=true)
    return nothing
end

function fixture_bytes(url::AbstractString)::String
    if occursin("master.zip", url)
        error("use synth_master_zip for $url")
    elseif occursin("-index.html", url)
        for (cik, (_, index_fixture)) in FILING_FIXTURES
            occursin("/$(cik)/", url) && return read(joinpath(FIXTURES_DIR, index_fixture), String)
        end
    elseif occursin(".htm", url)
        # primary document request: any filing fixture works, pick by cik
        for (cik, (text_fixture, _)) in FILING_FIXTURES
            occursin("/$(cik)/", url) && return read(joinpath(FIXTURES_DIR, text_fixture), String)
        end
    else
        for (cik, (text_fixture, _)) in FILING_FIXTURES
            occursin("/$(cik)/", url) && return read(joinpath(FIXTURES_DIR, text_fixture), String)
        end
    end
    error("No saved example response for url: $url")
end

ScrapeSEC.fetch_bytes(url::AbstractString) = fixture_bytes(url)

function ScrapeSEC.download_file(url::AbstractString, path::AbstractString)
    if occursin("master.zip", url)
        return synth_master_zip(path)
    end
    return write(path, fixture_bytes(url))
end
