
# Imports
from brpylib import NsxFile, brpylib_ver

# Version control
brpylib_ver_req = "1.2.1"
if brpylib_ver.split('.') < brpylib_ver_req.split('.'):
    raise Exception("requires brpylib " + brpylib_ver_req + " or higher, please use latest version")

# Inits
datafile = 'data/sample/array_Sc2.ns6'

# Open file and extract headers
brns_file = NsxFile(datafile)

# save a subset of data based on elec_ids
brns_file.savesubsetnsx(elec_ids=[1, 2, 5, 15, 20, 200], file_suffix='elec_subset')

# save a subset of data based on file sizing (100 Mb)
brns_file.savesubsetnsx(file_size=(1024**2) * 100, file_suffix='size_subset')

# save a subset of data based on file timing
brns_file.savesubsetnsx(file_time_s=30, file_suffix='time_subset')

# save a subset of data based on elec_ids and timing
brns_file.savesubsetnsx(elec_ids=[1, 2, 5, 15, 20, 200], file_time_s=30, file_suffix='elecAndTime_subset')

# Close the original datafile
brns_file.close()
