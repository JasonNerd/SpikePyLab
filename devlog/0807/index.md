---
title: "devlog-0807-nev数据读写"
date: 2023-08-07T15:52:39+08: 00
draft: false
tags: ["nev"]
categories: ["nev"]
twemoji: true
lightgallery: true
---

`2023-08-07 16:18:38`: 遗憾的是，没有找到官网下载数据的地址. 所以看看别的吧

`2023-08-08 12:41:40`: 这个官方示例, 似乎有很多错误, 关键在于 getdata 函数:
```py
"""
This function is used to return a set of data from the NSx datafile.
:param elec_ids: [optional] {list} User selection of elec_ids to extract specific spike waveforms (e.g., [13])
:param wave_read: [optional] {STR} 'read' or 'no_read' - whether to read waveforms or not
:return: output: {Dictionary} with one or more of the following dictionaries (all include TimeStamps)
            dig_events:            Reason, Data, [for file spec 2.2 and below, AnalogData and AnalogDataUnits]
            spike_events:          Units='nV', ChannelID, NEUEVWAV_HeaderIndices, Classification, Waveforms
            comments:              CharSet, Flag, Data, Comment
            video_sync_events:     VideoFileNum, VideoFrameNum, VideoElapsedTime_ms, VideoSourceID
            tracking_events:       ParentID, NodeID, NodeCount, PointCount, TrackingPoints
            button_trigger_events: TriggerType
            configuration_events:  ConfigChangeType, ConfigChanged

Note: For digital and neural data - TimeStamps, Classification, and Data can be lists of lists when more
than one digital type or spike event exists for a channel
"""
```

`2023-08-08 13:19:33`: 好像之前的那个下错了, 现在这一版可以看到正常的数据

`2023-08-08 13:37:21`: 感觉要把之前的工作都再做一遍了要
![](image/2023-08-08-13-39-30.png)

`2023-08-08 16:35:36`: python 读写 matlab 文件似乎不方便, 也不快捷

`2023-08-08 16:44:02`: python 也能序列化, 然而 json 似乎也是不错的选择?

`2023-08-09 15:06:13`: 编写了很多个模型数据类, 终于启动了
```py
# 目前 data 还都是扁平的数据结构, 需要使其更加结构化
# 例如支持检索具体某个神经元的发放(时刻和波形), 检索某电极(几个神经元)的发放
# 一个设想是维护两个表:
# 首次遍历: 建立 channel - unit 对应表, 也即每个电极记录了哪几个神经元, 同时 记录总的神经元数量
# 二次遍历: 建立 unit - Neuron 对应表, 此时需要为每个神经元分配全局编号, channel - unit 相应的 unit 也变为 全局编号
# 此时: channel - unit 对应表应该是一个字典类型, 其中的键是电极号, 键对应的值是一个列表,
#       列表中包含着所有该编号电极记录到的神经元全局唯一编号
# unit - Neuron 对应表则是一个简单的列表, 每一个元素都是一个 Neuron 对象, 其列表下标即为其全局编号
# 此时, 假设给定了一个 Neuron 对象, 我们就能查到它所在通道号, 进而查找到该通道下的所有记录神经元信息
```

`2023-08-09 17:08:42`: 就快要成功了
```py
[Neuron()]*100
```
以上方法看起来是定义了一个长度为100的 Neuron 类型列表, 实际上只是预定义了列表长度, 用一百个相同的元素去填充它, 因此在对其中一个进行修改时就相当于对所有的元素进行修改. 因此会出现异常情况
正确的做法是先预定义长度, 接着定义一个新对象并放到合适的下标位置.
```py
neuron_table = [0]*neuron_num     # 预定义长度
...
...

...
neuron = Neuron()
neuron_table[i] = neuron
```

`2023-08-09 17:21:23`: ok 了, 去吃饭


