

"""
  function create_main_index(metadata_folder="../metadata/"::String, 
    main_file="../metadata/main_idx.tsv"::String
  )

Create main index TSV file by combining all metadata files

Parameters
----------
metadata_folder::String
  * Folder where metadata TSVs are stored
  main_file::String
  * TSV file name for combined metadata

Returns
----------
nothing
"""
function create_main_index(metadata_folder="../metadata/"::String, 
                            main_file="../metadata/main_idx.tsv"::String)

    # Import all csv files into a dataframe
    metadata_files = [i for i in readdir(metadata_folder; join=true) if i!=main_file]
    df = reduce(vcat, [DataFrame(CSV.File(i, delim="|")) for i in metadata_files])

    # remove duplicates
    df = df[findall(nonunique(df)), :]

    # export df
    CSV.write(main_file, df, delim="|")

    return

end
