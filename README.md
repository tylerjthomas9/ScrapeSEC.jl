## Installation
Normal install:
```julia
]add ScrapeSEC
```

From source:
```julia
]add "https://github.com/tylerjthomas9/ScrapeSEC.jl/"
```

# Examples

Download filing metadata for 2012-2020 from the [SEC archives](https://www.sec.gov/Archives/).

```julia
using ScrapeSEC: get_metadata
get_metadata(2012, 2020)
```

Download 10-K, 8-K, and 10-Q filings for 2012-2020

```julia
using ScrapeSEC: get_quarterly_filings
get_quarterly_filings(2012, 2020; filing_types=["10-K", "8-K", "10-Q"])
```
