# Arm Neoverse N1 微信公众号发布资料

## 正式发布信息

- 正式标题：深入 Neoverse N1：80 核服务器为何单核仍像 Haswell
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2021 年 10 月 22 日
- 英文标题：Deep Diving Neoverse N1
- 文章链接：https://chipsandcheese.com/p/deep-diving-neoverse-n1
- 阅读原文链接：https://chipsandcheese.com/p/deep-diving-neoverse-n1

### 摘要

从 32 张图理解 Neoverse N1：单核 Cache、TLB、分支预测和小后端并不匹敌 Zen 2，Ampere Altra 却以 80 核、Mesh 与内存规模换取服务器吞吐。

### 封面文案

主标题：深入 Neoverse N1

副标题：单核、Mesh 与 80 核吞吐

### 分享文案

N1 L2 只有约 19.28 B/cycle、L3 约 663 GB/s，间接预测却能跟踪至少 4096 个目标；为什么 ChampSim 能赢 Zen 2，编译与向量编码却落后？一篇看清单核与整芯片的不同目标。

### 备选标题

- Neoverse N1 微架构全解：小核心如何撑起 80 核 Altra
- N1 对 Zen 2：ISA 不是答案，后端与 Cache 才是
- 从 Haswell 到 Altra：Neoverse N1 的强项与边界

### 文章标签

- Arm Neoverse N1
- Ampere Altra
- 服务器 CPU
- CPU 微架构
- Mesh Interconnect
- 分支预测
- Cache 与 TLB

### 所属栏目

CPU 微架构

## 图片资料

- 正文图片：32 张；目录：`arm_neoverse_n1_figures/`；顺序：`01` 至 `32`
- 图 4、5、18、19、22、23 等带英文正式图注或方法说明
- 图 7～12 为预测曲面，图 20～30 为宏基准/计数器图，移动端保留点击查看
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，深蓝/青绿色 Mesh 网格背景
- 主体使用四宽 N1 核、1 MB L2 与 80 核 Mesh 的抽象关系
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- TLB、RAS、BTB、CCX、CPPC、WSL1、MPKI 保留英文缩写

## 后台设置

- 标题：深入 Neoverse N1：80 核服务器为何单核仍像 Haswell
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/deep-diving-neoverse-n1
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～32

## 来源与表述要求

- N1、Zen 2 与各宏基准平台不统一，不能写成严格同频产品总排名。
- N1 L2 可能为 32 B 接口是由 19.28 B/cycle 推断，不是 RTL 位宽确认。
- Altra L3 约 663 GB/s 为测试曲线最佳估计；32 MB L3 与 80 MB 总 L2 难分离。
- 图 5 的 DRAM 数字被判为不合理，正式结论使用每线程独立数组。
- N1/Zen 2 TLB 为 48/64 与 1280/2048，N1 L2 hit 约 5 周期、Zen 2 约 7；N1 Page Directory Cache 未公开。
- 4096 间接目标、两级 RAS 11+31、44 Store/56 Load 等均为微基准观察。
- Zen 2 官方 44 Load 与测试 116 描述不同生命周期，不能与 N1 数字直接相加比较。
- gem5 编译必须保留 WSL1 旧结论被 Linux VM 推翻的过程。
- 7-Zip 16.02/16.04、Windows/WSL/Linux VM 差异很大，正文已拒绝不合理 VM 排名。
- EPYC 云 VM 频率、内存不可锁定或确定，只作视角补充。
- L3 hitrate 低于 1% 来自 Altra PMU，文章明确怀疑计数器准确性。
- OpenSSL ARMIE 指令统计与 N1 PMU 粒度都有限，不把 Kryo 领先唯一归因于乘法器。
- 对系统级 L4、A77/A78 以及 128 核路线的判断是原文章观点，不写成厂商事实。

## 发布预览要点

- 32 张图片和图注编号连续，母稿/WeMD 数量一致。
- `31.59/19.28 B/cycle`、`663 GB/s`、`48/1280`、`4096`、`11+31`、`44/56`、`37/116`、`40.3%/66.7%/69.3%` 等数字正常。
- 腾讯云 COS URL 全部返回 200 且 MIME 正确。
- 手机端表格与预测曲面可放大，无标题重复或断链。
