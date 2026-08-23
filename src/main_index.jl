
"""
```julia
function create_main_index(metadata_folder::String="./metadata/", 
    main_file::String="./metadata/main_idx.tsv"
)
```

Create main index TSV file by combining all metadata files

Parameters
* `metadata_folder`: Folder where metadata TSVs are stored
* `main_file`: TSV file name for combined metadata

"""
function create_main_index(
    metadata_folder::String="./metadata/", main_file::String="./metadata/main_idx.tsv"
)
    metadata_files = [
        i for
        i in readdir(metadata_folder; join=true) if (i != main_file) && occursin(".tsv", i)
    ]
    df = reduce(vcat, [DataFrame(CSV.File(i; delim="|")) for i in metadata_files])

    df = df[.!nonunique(df), :]
    CSV.write(main_file, df; delim="|")

    return nothing
end
