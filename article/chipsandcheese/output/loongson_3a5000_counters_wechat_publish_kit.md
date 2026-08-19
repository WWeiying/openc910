# 龙芯 3A5000 PMU 预览微信公众号发布资料

## 正式发布信息

- 正式标题：用性能计数器预览龙芯 3A5000：IPC、分支与 Cache
- 署名：Chester Lam
- 来源：Chips and Cheese
- 日期：2023 年 1 月 29 日
- 英文标题：Previewing China’s Loongson 3A5000 with Performance Counters
- 原始链接：https://chipsandcheese.com/p/previewing-chinas-loongson-3a5000-with-performance-counters

### 摘要

以 7-Zip 与 libx264 对比 Zen 1、Neoverse N1，并从 Retired Instruction、IPC、Branch、L1/L2/L3 事件观察3A5000同频表现和2.5 GHz瓶颈。

### 封面与分享文案

- 主标题：PMU 里的龙芯 3A5000
- 副标题：IPC 不差，为何还是慢
- 分享文案：7-Zip指令数只差5%，libx264却多12%～23%；17张图解释 ISA、Branch Density、Cache Miss 与低频。
- 备选标题：龙芯3A5000的性能从哪里丢掉；从指令数到L3事件

### 标签与栏目

- 标签：龙芯、3A5000、LA464、性能计数器、IPC、Cache
- 栏目：CPU 实测与微架构

## 图片与移动端排版

- 图片17张，目录 `loongson_3a5000_counters_figures/`，按01～17上传。
- PMU柱图全宽；Instruction Count与IPC相邻展示。

## 后台设置与发布前检查

- 不是全面Review；平台跨本地/Cloud、DDR与ISA。
- Loongson PMU未公开完整事件，LLC与Zen Demand Fill口径不等同；Altra L3事件明显无效。
- libx264图注中的LSX位宽文字有材料差异，正文按ISA定义说明。
- 核对2.5 GHz、16线程/四核、12%～23%、17.7/15.1/16.1%、1.2/1.1/1.16万亿及17图。
- 后台作者 Chester Lam；阅读原文完整链接；原创关闭，AI标识按要求开启。
