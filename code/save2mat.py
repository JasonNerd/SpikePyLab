import json
import io

import hdf5storage
from scipy.io import loadmat, savemat


def get_a() -> dict:
    a = {}
    asl1 = [2, 5, 7, 90, 12]
    asl2 = [2, 5, 7, 90, 12]
    asl3 = [2, 5, 7, 90, 12]
    asl4 = [2, 5, 7, 90, 12]
    a["spikes"] = {}
    a["spikes"]["as1"] = asl1
    a["spikes"]["as2"] = asl2
    a["spikes"]["as3"] = asl3
    a["spikes"]["as4"] = asl4
    a["events"] = {}
    a["events"]["bs1"] = asl1
    a["events"]["bs2"] = asl1
    a["events"]["bs3"] = asl1
    return a

def write():
    f = io.open("a.json", 'w', encoding='utf-8')
    json.dump(get_a(), f, ensure_ascii=False)
    f.close()

def read():
    f = io.open("a.json", 'r', encoding='utf-8')
    j_str = f.readline()
    f.close()
    return json.loads(j_str)


if __name__ == '__main__':
    path = 'D:/Users/lucian/Desktop/MyProject/SpikePyLab/data/BlackNeuroTech/pat01/datafile001-sorted.mat'
    write()
    print(read())
