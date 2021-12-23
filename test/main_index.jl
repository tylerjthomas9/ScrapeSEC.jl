
@testset "create_main_index()" begin

    # create temp csvs to test on
    temp_csv1 = "./temp1.tsv"
    temp_csv2 = "./temp2.tsv"
    open(temp_csv1, "w") do io
        write(io, "col1|col1\n1|2")
    end
    open(temp_csv2, "w") do io
        write(io, "col1|col1\n3|4")
    end

    # run test
    main_file = "test_main.tsv"
    create_main_index("./", main_file)
    @test read(main_file, String) == "col1|col1_1\n1|2\n3|4\n"


    # remove temp files
    rm(temp_csv1)
    rm(temp_csv2)
    rm(main_file)
    

end
