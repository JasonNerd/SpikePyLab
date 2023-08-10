
class Neuron:
    """
    channel_id: 电极编号
    unit_id: 神经元编号(局部)
    neuron_id: 神经元编号(全局)
    name: 神经元名称(neuron_id的字符串形式)
    waveform: 二维数组(m, n), m 是神经元发放次数, n 是波形数据量
    firing_time_stamp: 该神经元在哪些时刻出现了发放
    """
    def __init__(self):
        self.channel_id = -1
        self.unit_id = -1
        self.neuron_id = -1
        self.name = ""
        self.waveform = []
        self.firing_time_stamp = []

    def setChannel(self, cid: int):
        self.channel_id = cid

    def setUnit(self, uid: int):
        self.unit_id = uid

    def setNeuronId(self, nid):
        self.neuron_id = nid

    def setName(self):
        self.name = "Neuron_"+str(self.neuron_id).zfill(4)

    def appendWave(self, wave: list):
        self.waveform.append(wave)

    def appendFireStamp(self, fireStamp: int):
        self.firing_time_stamp.append(fireStamp)

    def append(self, wave: list, stamp: int):
        self.waveform.append(wave)
        self.firing_time_stamp.append(stamp)


