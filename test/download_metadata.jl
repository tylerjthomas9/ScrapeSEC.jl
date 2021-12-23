
@testset "get_metadata_urls()" begin
    time_periods = [(2020,1), (2020, 2), (2021, 1), (2021, 2)]
    urls = ["https://www.sec.gov/Archives/edgar/full-index/2020/QTR1/master.zip",
            "https://www.sec.gov/Archives/edgar/full-index/2020/QTR2/master.zip",
            "https://www.sec.gov/Archives/edgar/full-index/2021/QTR1/master.zip",
            "https://www.sec.gov/Archives/edgar/full-index/2021/QTR2/master.zip"]
    @test urls == get_metadata_urls(time_periods)

    inferred_type = @inferred get_metadata_urls(time_periods)
    @test inferred_type == Vector{String}
end

@testset "download_metadata()" begin

    url = "https://www.sec.gov/Archives/edgar/full-index/2020/QTR1/master.zip"
    dest = "./"
    temp_file = "temp_metadata"
    download_metadata(url, dest, temp_File)
    
end