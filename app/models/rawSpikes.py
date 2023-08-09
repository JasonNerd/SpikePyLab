from app.models.nevSpikes import NEVSpikes

class RawData:
    """
    NEVSpikes 中生成了一个字典对象, 这里将其转为一个对象
    spike_stamp = []
    spike_unit = []
    spike_chanel = []
    spike_wave = []
    event_stamp = []
    event_marker = []
    """
    def __init__(self):
        self.header = {}
        self.spike_stamp = []
        self.spike_unit = []
        self.spike_chanel = []
        self.spike_wave = []
        self.event_stamp = []
        self.event_marker = []

    def load(self, nev: NEVSpikes):
        self.spike_stamp = nev.data["spikes"]["TimeStamps"]
        self.spike_unit = nev.data["spikes"]["Unit"]
        self.spike_chanel = nev.data["spikes"]["Channel"]
        self.spike_wave = nev.data["spikes"]["Waveforms"]
        self.event_stamp = nev.data["events"]["TimeStamps"]
        self.event_marker = nev.data["events"]["UnparsedData"]
        self.header = nev.data["header"]
        self.header['file_name'] = nev.file_name
        self.header['file_root'] = nev.file_root
        self.header['file_suffix'] = nev.file_suffix
        self.header['base_file_name'] = nev.base_file_name
        self.header['file_path'] = nev.path


