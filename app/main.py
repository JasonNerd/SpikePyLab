"""
in_project:     SpikePyLab
file_name:      main.py
create_by:      mrrai
create_time:    2023/7/27
description:    
"""
import time

from app.models.SpikeDataModel import SpikeDataModel
from app.models.rawSpikes import RawData
from models.nevSpikes import NEVSpikes
import os

if __name__ == '__main__':
    work_root = os.getcwd()
    data_path = ["..", "data", "BlackNeuroTech", "pat01", "datafile001-sorted.nev"]
    path = os.path.join(work_root, *data_path)

    t1 = time.time()
    nev = NEVSpikes(path)
    t2 = time.time()
    print(t2-t1)

    raw_data = RawData()
    raw_data.load(nev)
    t1 = time.time()
    print(t1 - t2)

    spike_unit = SpikeDataModel(raw_data)
    spike_unit.construct()
    t2 = time.time()
    print(t2 - t1)

