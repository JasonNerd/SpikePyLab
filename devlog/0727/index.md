---
title: "SpikePyLab日志-0727"
date: 2023-07-27T10:14:37+08:00
draft: false
tags: ["Spike Analysis"]
categories: ["SpikePyLab"]
twemoji: true
lightgallery: true
---

今天先尝试搭好 Python 运行环境, 能够在 python 程序中读取 BlackNeuralTech & Plexon 系列文件.

卸载和重装环境
```log
conda info -e
conda remove -n MNEenv --all
conda remove -n PsychoPy --all
conda remove -n PyQT6ws --all

conda create -n SpikePyLab python=3.8
conda activate SpikePyLab
```

安装库文件
```log
pip install PyQt5 
pip install PyQt5-tools
pip install matplotlib
```

引入 NEV/NSx 官方 Python 程序. 从官方示例的 `openNEV.m` 示例程序来看, NEV实体的字段属性还是相对固定的.

重要字段说明:
字段名 | 字段类型 | size示例 | 元素示例 | 元素示例含义 | 描述 | 补充说明 | 
:-|:-|:-|:-|:-|:-|:-|
NEV.Data.SerialDigitalIO.UnparsedData| 数组 | 918 | 81 | 实验起始标志| 实验标志位 | 与实验相关
NEV.Data.SerialDigitalIO.TimeStamp| 数组 | 918 | 296006| 30KHz的时间步| 打标时间戳| 与 UnparsedData 对应
NEV.Data.Spikes.Electrode| 数组| 320806 |143| 记录到发放的电极号| \ | \
NEV.Data.Spikes.Unit| 数组| 320806 |0| 记录到发放的神经元编号|Local于电极号| \
NEV.Data.Spikes.Waveform  |数组| 48 x 320806| \ | \ |发放的波形| \
NEV.Data.Spikes.TimeStamp| 数组| 320806 |1104|30KHz的时间步| 打标时间戳| 与 Electrode Waveform Unit 对应

**上述五个变量的联系是**:
A.
TimeStamp[i] (918) 指明了 UnparsedData[i] 的时间步, 而 UnparsedData[i] 则说明了实验中的事件标志位.

B.
TimeStamp[i] (320806) 指明了在 Electrode[i] 号电极上的 Unit[i] 号神经元 检测到了发放, 其波形数据为 waveform[i] (48).

同时, **还需要注意采样频率** -- 30KHz

因此:
依据A, 已知实验起始标志位为 81, 则找出所有的 81标志的时间步, 就得到了实验的维度, 也即有几次实验和每次实验起始时间步号
依据B, 需要将电极号-Local 于电极号的神经元号展平为神经元号, 得到神经元维度(这里就知道了哪一号神经元在哪一时刻发放)
这里可以整理为一个数组链表, 数组下标是神经元编号, 数组元素本身是它发放的时刻序列

通常的 NEV 文件还包含了一些单个字段, 例如实验持续的时间长度(总时间步数), 另一方面 对于A部分字段的值, 例如82表示实验开始, 似乎并非通用的, 是需要指明的, 也就是关于实验配置这个方面.

仅仅依赖于B部分数据, 我们可以展示spike train 序列, 神经元总数, 计算得到神经元的发放率展示为列表.
理论上也可以绘制 ISI, PSTH+RASTER (实验无关), waveform, 总体发放情况(spike train)

在加载实验配置后, 单时间维度被划分为(实验序号, 时间bin号), 此时还有一个 ... ...
(logger is interrupted ... ...)

`2023-07-28 10:00:01`, 补充说明
昨天在看 Plexon 文件时找到了一个软件很符合当前的要求: [neuroexplorer](https://www.neuroexplorer.com/downloadspage/)