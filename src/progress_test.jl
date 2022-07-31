


using ProgressMeter
@showprogress for i in 1:5
    sleep(0.01)
    1 + 1
end

using Term.Progress
pbar = ProgressBar()
job = addjob!(pbar; N=100, description="Downloading Metadata CSVs",)
start!(pbar)
for i in 1:100
    update!(job)
    #ScrapeSEC.download_metadata(urls[idx]; dest = dest, skip_file = skip_file, verbose = verbose)
    sleep(0.1)
    render(pbar)
end
stop!(pbar)


import Term.Progress: SeparatorColumn, ProgressColumn, DescriptionColumn, DownloadedColumn, ETAColumn

FILESIZE = 2342341
CHUNK = 2048
nsteps = Int64(ceil(FILESIZE / CHUNK))
@info nsteps

mycols = [DescriptionColumn, SeparatorColumn, ProgressColumn, DownloadedColumn, ETAColumn]

pbar = ProgressBar(; columns = mycols, width = 140)
job = addjob!(pbar; N = FILESIZE)

with(pbar) do
    for i in 1:nsteps
        update!(job; i = CHUNK)
        sleep(0.001)
    end
end


import Term.Progress: SeparatorColumn, ProgressColumn, DescriptionColumn, CompletedColumn, ETAColumn
mycols = [DescriptionColumn, SeparatorColumn, ProgressColumn, CompletedColumn, SeparatorColumn, ETAColumn]
pbar = ProgressBar(; columns = mycols)
job = addjob!(pbar; N=100, description="Downloading Metadata CSVs")
start!(pbar)
for i in 1:100
    update!(job)
    #ScrapeSEC.download_metadata(urls[idx]; dest = dest, skip_file = skip_file, verbose = verbose)
    sleep(0.1)
    render(pbar)
end
stop!(pbar)