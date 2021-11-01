# WRDSMerger.jl Docs

# Installation
From the Julia REPL:
```julia
julia> ]add ScrapeSEC
```

```julia
julia> using Pkg; Pkg.add(ScrapeSEC)
```

From source:
```julia
julia> ]add https://github.com/tylerjthomas9/ScrapeSEC.jl
```

```julia
julia> using Pkg; Pkg.add(url="https://github.com/tylerjthomas9/ScrapeSEC.jl")
```

# Download Metadata
```@docs
get_metadata
```

# Combine Metadata Files
```@docs
create_main_index
```

# Download Filings
```@docs
download_filing
get_quarterly_filings
```

