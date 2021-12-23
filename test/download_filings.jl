@testset "download_filing() (Download Filing)" begin
    

    file_name = "edgar/data/880794/9999999997-05-050434.txt"
    temp_file = "./temp_filing.txt"
    dest = "./"
    download_filing(file_name, temp_file, dest)
    open(temp_file) do io
        sha256_val = bytes2hex(sha256(io))
        @test sha256_val == "76430ca567894f4fef1dac0f4f5dc7f0eb418b45283ddb7199ad2d962fb72b6e"
    end
    rm(temp_file)


end
