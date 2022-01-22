[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://docs.juliahub.com/ScrapeSEC/)
[![CI](https://github.com/tylerjthomas9/ScrapeSEC.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/tylerjthomas9/ScrapeSEC.jl/actions/workflows/ci.yml)
 [![ScrapeSEC Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/ScrapeSEC)](https://pkgs.genieframework.com?packages=ScrapeSEC)


## Installation

```julia
julia> using Pkg; Pkg.add("ScrapeSEC")
```

```julia
]add ScrapeSEC
```

From source:
```julia
julia> using Pkg; Pkg.add(url="https://github.com/tylerjthomas9/ScrapeSEC.jl/")
```

```julia
]add https://github.com/tylerjthomas9/ScrapeSEC.jl/
```

# Examples

Download filing metadata for 2012-2020 from the [SEC archives](https://www.sec.gov/Archives/).

```julia
using ScrapeSEC: get_metadata
download_metadata_files(2012, 2020)
```

Download 10-K, 8-K, and 10-Q metadata, filings for 2012-2020

```julia
using ScrapeSEC: get_quarterly_filings
get_quarterly_filings(2012, 2020; filing_types=["10-K", "8-K", "10-Q"])
```


Download filing metadata for 2012-2020, create a main index file, and download 10-Ks using the master index
```julia
using ScrapeSEC
download_metadata_files(2012, 2020)
create_main_index()
get_quarterly_filings("../metadata/main_idx.tsv"; filing_types=["10-K", ])
```
