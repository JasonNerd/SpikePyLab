import os
import pickle
from app.models.SpikeDataModel import RawSpikeData

spike_suffix = "_spikes"
event_suffix = "_events"

def getSysSep(path=None):
    if path is not None:
        if '/' in path:
            return '/'
        if '\\' in path:
            return '\\'
    return os.sep

def readNEV(path: str):
    # 1. 拆解路径, 获取文件 所在目录、文件名、文件基本名、文件后缀名
    sep = getSysSep(path)
    file_root = sep.join(path.split(sep)[:-1])
    file_name = path.split(sep)[-1]
    base_file_name = file_name.split('.')[0]
    file_suffix = file_name.split('.')[1]
    # 2. 构造缓存文件路径
    cache_path_spikes = sep.join([file_root, base_file_name + spike_suffix]) + ".pkl"
    cache_path_events = sep.join([file_root, base_file_name + event_suffix]) + ".pkl"
    # 3. 读取数据
    if not (os.path.exists(cache_path_spikes) and os.path.exists(cache_path_events)):
        raw = RawSpikeData(path)
        raw.readNEV()
        raw.construct()
        spikes, events = raw.get_data_dict()
        # 为 spikes 的 header添加一些字段
        spikes["header"]['file_name'] = file_name
        spikes["header"]['file_root'] = file_root
        spikes["header"]['file_suffix'] = file_suffix
        spikes["header"]['base_file_name'] = base_file_name
        spikes["header"]['file_path'] = path
        # 缓存到文件
        cache_spikes_str = pickle.dumps(spikes)
        with open(cache_path_spikes, 'wb') as f:
            f.write(cache_spikes_str)
        cache_events_str = pickle.dumps(events)
        with open(cache_path_events, 'wb') as f:
            f.write(cache_events_str)
    else:
        print("探测到同目录下已包含spike数据文件和events数据文件, 选择加载该数据")
    with open(cache_path_spikes, 'rb') as f:
        s = pickle.loads(f.read())
    with open(cache_path_events, 'rb') as f:
        e = pickle.loads(f.read())
    return s, e

