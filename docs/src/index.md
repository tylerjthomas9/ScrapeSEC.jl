# ScrapeSEC.jl Docs

# Installation
From the Julia General Registry:
```julia
julia> ]  # enters the pkg interface
pkg> add ScrapeSEC
```

```julia
julia> using Pkg; Pkg.add(ScrapeSEC)
```

From source:
```julia
julia> ]  # enters the pkg interface
pkg> add https://github.com/tylerjthomas9/ScrapeSEC.jl
```

```julia
julia> using Pkg; Pkg.add(url="https://github.com/tylerjthomas9/ScrapeSEC.jl")
```

# Download Metadata
```@docs
download_metadata_files
```

# Combine Metadata Files
```@docs
ScrapeSEC.create_main_index
```

# Download Filings
```@docs
download_filing
download_filings
```

