@testset "download_filing() (Download Filing)" begin
    file_name = "edgar/data/880794/9999999997-05-050434.txt"
    temp_file = "./temp_filing.txt"
    dest = "./"
    download_filing(file_name, temp_file, dest)
    @test isfile(temp_file)
    rm(temp_file)
end

@testset "download_filings()" begin
    download_filings(
        1994,
        1994;
        quarters=[3,4],
        dest="./temp/",
        metadata_dest="./metadata/",
        running_tests=true,
    )
    @test isfile("./metadata/1994-QTR4.tsv")
    rm("./metadata/1994-QTR4.tsv")
    # TODO: Is it safe to clear the temp dir? I dont want to accidently user files
end
