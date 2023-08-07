import matplotlib.pyplot as plt
from numpy import arange
from brpylib import NsxFile, brpylib_ver

# Version control
brpylib_ver_req = "1.3.1"
if brpylib_ver.split('.') < brpylib_ver_req.split('.'):
    raise Exception("requires brpylib " + brpylib_ver_req + " or higher, please use latest version")

# Inits
datafile = '../data/sample/array_Sc2.ns6'

elec_ids = [1, 15, 2, 20, 5, 200]  # 'all' is default for all (1-indexed)
start_time_s = 1  # 0 is default for all
data_time_s = 3000  # 'all' is default for all
downsample = 2  # 1 is default
plot_chan = 5  # 1-indexed

# Open file and extract headers
nsx_file = NsxFile(datafile)

# Extract data - note: data will be returned based on *SORTED* elec_ids, see cont_data['elec_ids']
cont_data = nsx_file.getdata(elec_ids, start_time_s, data_time_s, downsample)

# Close the nsx file now that all data is out
nsx_file.close()

# Plot the data channel
ch_idx = cont_data['elec_ids'].index(plot_chan)
hdr_idx = cont_data['ExtendedHeaderIndices'][ch_idx]
t = cont_data['start_time_s'] + arange(cont_data['data'].shape[1]) / cont_data['samp_per_s']

plt.plot(t, cont_data['data'][ch_idx])
plt.axis([t[0], t[-1], min(cont_data['data'][ch_idx]), max(cont_data['data'][ch_idx])])
plt.locator_params(axis='y', nbins=20)
plt.xlabel('Time (s)')
plt.ylabel("Output (" + nsx_file.extended_headers[hdr_idx]['Units'] + ")")
plt.title(nsx_file.extended_headers[hdr_idx]['ElectrodeLabel'])
plt.show()
