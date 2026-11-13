@testset "download_filing() (Download Filing)" begin
    file_name = "edgar/data/880794/9999999997-05-050434.txt"
    temp_file = "./temp_filing.txt"
    dest = "./"
    download_filing(file_name, temp_file, dest)
    @test isfile(temp_file)
    @test occursin("TEST COMPANY A", read(temp_file, String))
    rm(temp_file)
end

@testset "download_filing() (Download primary document)" begin
    temp_file = "./temp_filing.txt"
    dest = "./"
    for file_name in (
        "edgar/data/880794/9999999997-05-050434.txt",
        "edgar/data/775057/0001096906-21-003058.txt",
    )
        download_filing(file_name, temp_file, dest; primary_document=true)
        @test isfile(temp_file)
        rm(temp_file)
    end
end

@testset "download_filing() (primary document fails, falls back to full filing)" begin
    file_name = "edgar/data/880794/9999999997-05-050434.txt"
    temp_file = "./temp_filing.txt"
    FAIL_PRIMARY_DOCUMENTS[] = true
    try
        @test_logs (:warn, r"Failed to download primary document") download_filing(
            file_name, temp_file, "./"; primary_document=true
        )
    finally
        FAIL_PRIMARY_DOCUMENTS[] = false
    end
    @test occursin("TEST COMPANY A", read(temp_file, String))
    rm(temp_file)
end

@testset "download_filings() (download_rate above limit)" begin
    filenames = ["edgar/data/880794/9999999997-05-050434.txt"]
    @test_logs (:warn, r"download_rate of 50 per second") download_filings(
        filenames; dest="./temp/", download_rate=50
    )
    rm("./temp"; recursive=true, force=true)
end

@testset "download_filings() (only primary document)" begin
    rm("./temp"; recursive=true, force=true)
    rm("./metadata"; recursive=true, force=true)
    download_filings(
        1994,
        1994;
        quarters=[3],
        dest="./temp/",
        metadata_dest="./metadata/",
        primary_document=true,
        skip_metadata_file=false,
    )
    @test isfile("./metadata/1994-QTR3.tsv")
    @test isfile("./temp/880794/9999999997-05-050434.txt")
    rm("./temp"; recursive=true, force=true)
    rm("./metadata/1994-QTR3.tsv")

    # Test when metadata files are empty and no filings are downloaded
    download_filings(
        1994, 1994; quarters=[3], filing_types=["40-F"], skip_metadata_file=false
    )
    rm("./metadata/1994-QTR3.tsv")
end

@testset "download_filings()" begin
    download_filings(
        1994,
        1994;
        quarters=[1],
        dest="./temp/",
        metadata_dest="./metadata/",
        skip_metadata_file=false,
    )
    @test isfile("./metadata/1994-QTR1.tsv")
    rm("./metadata/1994-QTR1.tsv")
    rm("./temp"; recursive=true, force=true)
end

@testset "download_filings() (filenames vector)" begin
    filenames = [
        "edgar/data/880794/9999999997-05-050434.txt",
        "edgar/data/775057/0001096906-21-003058.txt",
    ]
    download_filings(filenames; dest="./temp/")
    for f in filenames
        @test isfile("./temp/" * replace(f, "edgar/data/" => ""))
    end
    rm("./temp"; recursive=true, force=true)
end
