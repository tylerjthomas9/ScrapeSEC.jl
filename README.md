[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://docs.juliahub.com/ScrapeSEC/)
[![Lifecycle:Stable](https://img.shields.io/badge/Lifecycle-Stable-97ca00)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)
[![CI](https://github.com/tylerjthomas9/ScrapeSEC.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/tylerjthomas9/ScrapeSEC.jl/actions/workflows/ci.yml)
 [![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
 [![Coverage](http://codecov.io/github/tylerjthomas9/ScrapeSEC.jl/coverage.svg?branch=main)](https://codecov.io/gh/tylerjthomas9/ScrapeSEC.jl)
 [![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)



# ScrapeSEC.jl

## Installation

From the Julia General Registry:
```julia
julia> ]  # enters the pkg interface
pkg> add ScrapeSEC
```

```julia
julia> using Pkg; Pkg.add("ScrapeSEC")
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
download_filings(2023, 2024; filing_types=["10-K", "8-K", "10-Q"])
df = DataFrame(CSV.File(metadata_file; delim="|"))
```

```julia
julia> first(df, 5)
5×5 DataFrame
 Row │ CIK      Company Name            Form Type  Date Filed  Filename                          
     │ Int64    String                  String31   Dates.Date  String                            
─────┼───────────────────────────────────────────────────────────────────────────────────────────
   1 │ 1000045  NICHOLAS FINANCIAL INC  10-Q       2023-02-14  edgar/data/1000045/0000950170-23…
   2 │ 1000045  NICHOLAS FINANCIAL INC  4          2023-02-24  edgar/data/1000045/0001000045-23…
   3 │ 1000045  NICHOLAS FINANCIAL INC  4          2023-02-28  edgar/data/1000045/0001000045-23…
   4 │ 1000045  NICHOLAS FINANCIAL INC  4          2023-03-09  edgar/data/1000045/0001398344-23…
   5 │ 1000045  NICHOLAS FINANCIAL INC  8-K        2023-01-24  edgar/data/1000045/0000950170-23…
```


Download filing metadata for 2020-2022, create a main index file, and download 10-Ks using the combined index file
```julia
using ScrapeSEC
download_metadata_files(2020, 2022)
create_main_index()
download_filings("./metadata/main_idx.tsv"; filing_types=["10-K", ])
```

Download filings from a vector of filenames
```julia
using CSV, DataFrames, ScrapeSEC
df = CSV.File("./metadata/main_idx.tsv", delim = "|") |> DataFrame
download_filings(df.FileName)
```

# Citing

If you use ScrapeSEC.jl as part of your research, teaching, or other activities, we would be grateful if you could cite our work. 

```
@misc{ScrapeSEC.jlPackage,
  author = {Tyler Thomas}
  title = {ScrapeSEC.jl}
  year = {2023}
  url = {https://github.com/tylerjthomas9/ScrapeSEC.jl}
}
```

# Other Julia Financial Data Packages
- [FredData.jl](https://github.com/micahjsmith/FredData.jl) - Federeral Reserve Economic Data (FRED). 
- [MarketData.jl](https://github.com/JuliaQuant/MarketData.jl) - Yahoo Finance market data.
- [YFinance.jl](https://github.com/eohne/YFinance.jl) - Yahoo Finance price, option, fundamental data.

Not maintained:
- [DailyTreasuryYieldCurve.jl](https://github.com/tbeason/DailyTreasuryYieldCurve.jl)
- [FredApi.jl](https://github.com/markushhh/FredApi.jl) 

