using ScrapeSEC
using Test

@testset "download_filing() (Download Filing)" begin
    

    file_name = "edgar/data/880794/9999999997-05-050434.txt"
    full_file = "./temp_filing.txt"
    dest = "test/"
    if !isdir(dest)
        mkdir(dest)
    end
    download_filing(file_name, full_file, dest)
    @test isfile(full_file)
    rm(full_file)


end
