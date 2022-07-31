[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://docs.juliahub.com/ScrapeSEC/)
[![Lifecycle:Stable](https://img.shields.io/badge/Lifecycle-Stable-97ca00)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)
[![CI](https://github.com/tylerjthomas9/ScrapeSEC.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/tylerjthomas9/ScrapeSEC.jl/actions/workflows/ci.yml)
 [![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
 [![Coverage](http://codecov.io/github/tylerjthomas9/ScrapeSEC.jl/coverage.svg?branch=main)](https://codecov.io/gh/tylerjthomas9/ScrapeSEC.jl)



# ScrapeSEC.jl

## Installation

From the Julia REPL:
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
# Examples

Download filing metadata for 2020-2022 from the [SEC archives](https://www.sec.gov/Archives/).

```julia
using ScrapeSEC
download_metadata_files(2020, 2022)
```

Download 10-K, 8-K, and 10-Q metadata, filings for 2020-2022

```julia
using ScrapeSEC
download_filings(2020, 2022; filing_types=["10-K", "8-K", "10-Q"])
```


Download filing metadata for 2020-2022, create a main index file, and download 10-Ks using the combined index file
```julia
using ScrapeSEC
download_metadata_files(2020, 2022)
create_main_index()
download_filings("./metadata/main_idx.tsv"; filing_types=["10-K", ])
```
