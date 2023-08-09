import io
import json
import os

import numpy as np
from app.utils.blackneurotech.brpylib import NevFile


class NEVSpikes:
    def __init__(self, file_path: str):
        # 1. 路径拆解
        self.path = file_path
        self.sep = ''
        self.setSep()
        self.file_root = self.sep.join(self.path.split(self.sep)[:-1])
        self.file_name = self.path.split(self.sep)[-1]
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
            self.data["events"] = {}
            for k, v in data["spike_events"].items():
                self.data["spikes"][k] = np.array(v, dtype=int).tolist()
            for k, v in data["digital_events"].items():
                self.data["events"][k] = np.array(v, dtype=int).tolist()
            self.data["header"] = meta.basic_header
            self.data["header"]["TimeOrigin"] = str(self.data["header"]["TimeOrigin"])
        except:
            return False
        return True
