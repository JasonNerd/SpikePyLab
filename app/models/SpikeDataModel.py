from typing import List

import numpy as np

from app.models.NeuronModel import Neuron
from app.utils.blackneurotech.brpylib import NevFile


class RawSpikeData:
    """
    NEVSpikes 中生成了一个字典对象, 这里将其转为一个对象
    spike_stamp = []
    spike_unit = []
    spike_chanel = []
    spike_wave = []
    event_stamp = []
    event_marker = []
    """
    neuron_table: List[Neuron]

    def __init__(self, path: str):
        # 1. nev 文件路径 (假定 path 是正确的 nev 文件路径)
        self.path = path
        # 2. nev 原始数据
        self.data = {}
        # 3. 提取变量
        self.header = {}
        self.spike_stamp = []
        self.spike_unit = []
        self.spike_chanel = []
        self.spike_wave = []
        self.event_stamp = []
        self.event_marker = []
        # 4. 数据预处理 - 扁平数据结构化.
        # 4-1. 神经元总数(此处我们假设了 每个电极记录到的神经元应该是互不相同的, 也即已进行了锋值排序)
        self.neuron_num = 0
        # 4-2. 所有电极记录到的所有神经元在全部的实验时间内发放的总次数
        self.total_firing_counts = 0
        # 4-3. channel - unit 对应表
        self.channel_unit_table = {}
        # 4-4. unit - Neuron 对应表
        self.neuron_table = []
        # 4-5. 其他变量
        self.channel_num = 0

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
            self.load()
        except:
            return False
        return True

    def load(self):
        self.spike_stamp = self.data["spikes"]["TimeStamps"]
        self.spike_unit = self.data["spikes"]["Unit"]
        self.spike_chanel = self.data["spikes"]["Channel"]
        self.spike_wave = self.data["spikes"]["Waveforms"]
        self.event_stamp = self.data["events"]["TimeStamps"]
        self.event_marker = self.data["events"]["UnparsedData"]
        self.header = self.data["header"]

    # 目前 spike_xx 和 event_xx 还都是扁平的数据结构, 需要使其更加结构化
    # 例如支持检索具体某个神经元的发放(时刻和波形), 检索某电极(几个神经元)的发放
    # 一个设想是维护两个表:
    # 遍历原始ch-unit: 建立 channel - unit 对应表, 也即每个电极记录了哪几个神经元(使用set存储), 记录总的神经元数量
    # 遍历channel - unit 对应表: 为每个神经元分配全局编号, channel - unit 相应的 unit 变为 {unit - 全局编号} 字典
    # 此时: channel - unit 对应表应该是一个字典类型, 其中的键是电极号ch, 键对应的值是一个字典unit-dict,
    #       它保存了 unit_id 与 neuron_id 的对应关系
    # 再次遍历原始数据: 此时有了全局编号对照表, 就可以一一进行更新了
    def construct(self):
        self.total_firing_counts = len(self.spike_stamp)
        # 1. 首次遍历
        for i in range(self.total_firing_counts):
            ch = self.spike_chanel[i]
            un = self.spike_unit[i]
            if ch in self.channel_unit_table:  # 键值存在则直接添加 un
                self.channel_unit_table[ch].add(un)
            else:
                self.channel_unit_table[ch] = {un}  # 不存在则赋值为空集并添加 un
        # 电极(通道)数量
        self.channel_num = len(self.channel_unit_table)
        # 遍历 channel_unit_table 得到总 unit 数
        for k, v in self.channel_unit_table.items():
            self.neuron_num += len(v)
        # 2. 构造 neuron_table, 分配全局编号
        self.neuron_table = [None] * self.neuron_num  # 预定义长度
        global_neuron_id = 0
        for k in self.channel_unit_table.keys():
            v = self.channel_unit_table[k]  # unit id set
            new_v = {}  # unit id - global id dict
            for u in v:
                new_v[u] = global_neuron_id
                # 新建一个 Neuron 对象, 更新其关于 id 的对应关系
                neuron = Neuron()
                neuron.setNeuronId(global_neuron_id)
                neuron.setChannel(k)
                neuron.setUnit(u)
                neuron.setName()
                self.neuron_table[global_neuron_id] = neuron
                global_neuron_id = global_neuron_id + 1
            self.channel_unit_table[k] = new_v  # 更新原列表关系
        # 再次遍历 原始数据
        for i in range(self.total_firing_counts):
            ch = self.spike_chanel[i]
            un = self.spike_unit[i]
            wv = self.spike_wave[i]
            st = self.spike_stamp[i]
            idx = self.channel_unit_table[ch][un]
            self.neuron_table[idx].append(wv, st)
        # 封装必要数据
        self.header["channel_unit_table"] = self.channel_unit_table
        self.header["channel_num"] = self.channel_num
        self.header["neuron_num"] = self.neuron_num

    def get_data_dict(self):
        spikes = {
            "header": self.header,
            "data": self.neuron_table
        }
        events = {
            "event_stamp": self.event_stamp,
            "event_marker": self.event_marker
        }
        return spikes, events
