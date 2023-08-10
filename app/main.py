"""
in_project:     SpikePyLab
file_name:      main.py
create_by:      mrrai
create_time:    2023/7/27
description:    
"""
import time

from app.models.SpikeReader import readNEV
import os


if __name__ == '__main__':
    work_root = os.getcwd()
    data_path = ["..", "data", "BlackNeuroTech", "pat01", "datafile001-sorted.nev"]
    path = os.path.join(work_root, *data_path)

    t1 = time.time()
    spikes, events = readNEV(path)
    t2 = time.time()
    print(t2-t1)
    print("just pause the program")
