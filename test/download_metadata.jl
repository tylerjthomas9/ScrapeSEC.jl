
@testset "get_metadata_urls()" begin
    time_periods = [(2020,1), (2020, 2), (2021, 1), (2021, 2)]
    urls = ["https://www.sec.gov/Archives/edgar/full-index/2020/QTR1/master.zip",
            "https://www.sec.gov/Archives/edgar/full-index/2020/QTR2/master.zip",
            "https://www.sec.gov/Archives/edgar/full-index/2021/QTR1/master.zip",
            "https://www.sec.gov/Archives/edgar/full-index/2021/QTR2/master.zip"]
    @test urls == ScrapeSEC.get_metadata_urls(time_periods)

    inferred_type = @inferred ScrapeSEC.get_metadata_urls(time_periods)
    @test inferred_type == Vector{String}
end

@testset "download_metadata()" begin

    url = "https://www.sec.gov/Archives/edgar/full-index/2020/QTR4/master.zip"
    dest = "./"
    temp_file = "2020-QTR4.tsv"
    ScrapeSEC.download_metadata(url; dest=dest)
    open(temp_file) do io
        sha256_val = bytes2hex(sha256(io))
        @test sha256_val == "e64aa2946bf13d1f85196aacd06be8eac07690ccdbe46bb7c7dc44fcb22467ab"
    end
    rm(temp_file)
    
end