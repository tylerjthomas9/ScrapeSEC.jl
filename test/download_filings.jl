@testset "download_filing() (Download Filing)" begin

    file_name = "edgar/data/880794/9999999997-05-050434.txt"
    temp_file = "./temp_filing.txt"
    dest = "./"
    download_filing(file_name, temp_file, dest)
    @test isfile(temp_file)
    rm(temp_file)

end


@testset "get_quarterly_filings()" begin

    get_quarterly_filings(
        1994,
        1994;
        quarters = [4],
        dest = "./temp/",
        metadata_dest = "./metadata/",
    )
    @test isfile("./metadata/1994-QTR4.tsv")
    @test isfile("./temp/3146/0000950144-94-002172.txt")
    rm("./metadata/1994-QTR4.tsv")
    # TODO: Is it safe to clear the temp dir? I dont want to accidently delete peoples files who
    # run the tests

end
