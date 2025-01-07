@testset "download_filing() (Download Filing)" begin
    file_name = "edgar/data/880794/9999999997-05-050434.txt"
    temp_file = "./temp_filing.txt"
    dest = "./"
    download_filing(file_name, temp_file, dest)
    @test isfile(temp_file)
    rm(temp_file)
end

@testset "download_filing() (Download primary document)" begin
    file_name = "edgar/data/880794/9999999997-05-050434.txt"
    temp_file = "./temp_filing.txt"
    dest = "./"
    download_filing(file_name, temp_file, dest; primary_document=true)
    @test isfile(temp_file)
    rm(temp_file)
    file_name = "edgar/data/775057/0001096906-21-003058.txt"
    download_filing(file_name, temp_file, dest; primary_document=true)
    @test isfile(temp_file)
    rm(temp_file)
end

@testset "download_filings() (only primary document)" begin
    download_filings(
        1994,
        1994;
        quarters=[3, 4],
        dest="./temp/",
        metadata_dest="./metadata/",
        running_tests=true,
    )
    @test isfile("./metadata/1994-QTR4.tsv")
    rm("./metadata/1994-QTR4.tsv")

    # Test when metadata files are empty and no filings are downloaded
    download_filings(1994, 1994; filing_types=["40-F"])

    rm("./metadata/1994-QTR4.tsv")
end

@testset "download_filings()" begin
    download_filings(
        2024,
        2024;
        quarters=[1],
        dest="./temp/",
        metadata_dest="./metadata/",
        running_tests=true,
        primary_document=true,
    )
    @test isfile("./metadata/2024-QTR1.tsv")
    rm("./metadata/2024-QTR1.tsv")
end
