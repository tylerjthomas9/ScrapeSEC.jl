# Examples

Download filing metadata for 2012-2020 from the [SEC archives](https://www.sec.gov/Archives/).

```julia
using ScrapeSEC: get_metadata
get_metadata(2012, 2020)
```

Download 10-K, 8-K, and 10-Q filings from the first quarter of 2000

```julia
using ScrapeSEC: get_quarterly_filings
get_quarterly_filings("../metadata/2000-QTR1.tsv", filing_types=["10-K", "8-K", "10-Q"])
```
