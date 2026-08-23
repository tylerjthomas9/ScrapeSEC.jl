using JET
using ScrapeSEC
using Test

# report_package also surfaces false positives inside dependencies (HTTP, CSV,
# DataFrames), so only fail on reports located in ScrapeSEC's own src/.
result = report_package(ScrapeSEC)
srcdir = joinpath(pkgdir(ScrapeSEC), "src")
own_reports = filter(result.res.inference_error_reports) do er
    isempty(er.vst) || startswith(string(er.vst[end].file), srcdir)
end
foreach(er -> println("$(er.vst[end].file):$(er.vst[end].line): $(er)"), own_reports)
@test isempty(own_reports)
