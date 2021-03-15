# https://github.com/edgarminers/python-edgar

import edgar

data_dir = "../data/"
since_year = 2000
edgar.download_index(data_dir, since_year, skip_all_present_except_last=False)