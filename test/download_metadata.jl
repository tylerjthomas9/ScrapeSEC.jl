
@testset "get_metadata_urls()" begin
    time_periods = [(2020, 1), (2020, 2), (2021, 1), (2021, 2)]
    urls = [
        "https://www.sec.gov/Archives/edgar/full-index/2020/QTR1/master.zip",
        "https://www.sec.gov/Archives/edgar/full-index/2020/QTR2/master.zip",
        "https://www.sec.gov/Archives/edgar/full-index/2021/QTR1/master.zip",
        "https://www.sec.gov/Archives/edgar/full-index/2021/QTR2/master.zip",
    ]
    @test urls == ScrapeSEC.get_metadata_urls(time_periods)

    val = @inferred ScrapeSEC.get_metadata_urls(time_periods)
    @test typeof(val) == Vector{String}
end

@testset "download_metadata()" begin

    url = "https://www.sec.gov/Archives/edgar/full-index/1995/QTR1/master.zip"
    dest = "./"
    temp_file = "1995-QTR1.tsv"
    ScrapeSEC.download_metadata(url; dest = dest)
    @test isfile(temp_file)
    rm(temp_file)

end
