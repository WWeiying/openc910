# Centaur CHA Die 微信公众号发布资料

## 正式发布信息

- 正式标题：Centaur CHA 的 Die：用小核心给 NCore 和 I/O 腾出空间
- 署名：Chester Lam
- 来源：Chips and Cheese
- 日期：2022 年 4 月 30 日
- 英文标题：Examining Centaur CHA’s Die and Implementation Goals
- 原始链接：https://chipsandcheese.com/p/examining-centaur-chas-die-and-implementation-goals

### 摘要

194 mm² CHA如何容纳八核、16 MB L3、四通道DDR4、44 PCIe和一块NCore？答案是主动限制频率、IPC与AVX-512面积开销。

### 封面与分享文案

- 主标题：CHA 的面积预算
- 副标题：小核心、NCore 与 44 条 PCIe
- 分享文案：同为八核四通道，CHA只有Haswell-E略多一半面积；25张图解释密度导向CPU为何能强Vector却不适合桌面。
- 备选标题：Centaur最后一颗SoC如何分配Die；Haswell-like IPC装进更小核心

### 标签与栏目

- 标签：Centaur、CHA、CNS、NCore、Die Analysis、AVX-512、芯片面积
- 栏目：物理实现与微架构

## 图片与移动端排版

- 图片25张，目录 `centaur_cha_die_figures/`，按01～25上传。
- Die Photo保持等比例，Area Breakdown和ROB模拟图全宽。

## 后台设置与发布前检查

- Foundry节点不能按标称数字直接换算；Die区域为照片估算。
- Haswell Predictor、NSQ解释缺CNS文档PMU，保留“可能”。
- 假想32核、7 nm移植、Intel E-Core均为明确Speculation。
- 核对194/355 mm²、44/40 PCIe、16/20 MB、14.67/23.29%、65/140 W、约200 ROB Knee及25图。
- 后台作者 Chester Lam；阅读原文完整链接；原创关闭，AI标识按要求开启。
