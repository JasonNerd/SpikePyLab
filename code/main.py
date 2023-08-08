"""
in_project:     SpikePyLab
file_name:      main.py
create_by:      mrrai
create_time:    2023/7/27
description:    
"""
import json

from utils.blackneurotech.brpylib import NevFile
import os
import io
import numpy as np
class NEVSpikes:
    def __init__(self, file_path: str):
        # 1. 路径拆解
        self.path = file_path
        self.sep = ''
        self.setSep()
        self.file_root = self.sep.join(path.split(self.sep)[:-1])
        self.file_name = path.split(self.sep)[-1]
        self.base_file_name = self.file_name.split('.')[0]
        self.file_suffix = self.file_name.split('.')[1]
        # 2. 尝试读取文件(假定 file_path 是正确的 nev 文件路径)
        #   2.2 检查路径下是否有已读取的 json 文件
        self.json_path = self.sep.join([self.file_root, self.base_file_name]) + ".json"
        # 3. 读取数据
        self.data = {}
        if os.path.exists(self.json_path):
            self.readJson()
        else:
            self.readNEV()
            self.toJson()

    def setSep(self):
        if '/' in self.path:
            self.sep = '/'
        if '\\' in self.path:
            self.sep = '\\'

    def toJson(self):
        # 写入 json 文件 到同目录
        f = io.open(self.json_path, 'w', encoding='utf-8')
        json.dump(self.data, f, ensure_ascii=False)
        f.close()

    def readJson(self):
        f = io.open(self.json_path, 'r', encoding='utf-8')
        j_str = f.readline()
        f.close()
        self.data = json.loads(j_str)

    def readNEV(self):
        try:
            meta = NevFile(self.path)
            data = meta.getdata()
            self.data["spikes"] = {}
            self.data["meta"] = {}
            for k, v in data["spike_events"].items():
                self.data["spikes"][k] = np.array(v, dtype=int)
            for k, v in data["digital_events"].items():
                self.data["meta"][k] = np.array(v, dtype=int)
        except:
            return False
        return True


if __name__ == '__main__':
    path = 'D:/Users/lucian/Desktop/MyProject/SpikePyLab/data/BlackNeuroTech/pat01/datafile001-sorted.nev'
    sp = NEVSpikes(path)

    np.array([1, 2, 3], dtype=int)
    print()
