# NVIDIA GB10 内存系统微信公众号发布资料

## 正式标题

从 CPU 一侧看 NVIDIA GB10：20 核、双簇与共享内存系统

## 备选标题

- NVIDIA GB10 的 CPU 内存系统：大小核背后的双簇不对称
- DGX Spark 里的 GB10：Cache、带宽与核间延迟
- GB10 对比 Strix Halo：同为大 iGPU，内存系统有何不同

## 作者与来源

- 作者栏：Chester Lam
- 首发：Chips and Cheese
- 英文题目：*Inside Nvidia GB10’s Memory Subsystem, from the CPU Side*
- 发布日期：2025 年 12 月 31 日
- 阅读原文：https://chipsandcheese.com/p/inside-nvidia-gb10s-memory-subsystem

## 摘要

GB10 用 10 颗 X925、10 颗 A725、8/16 MB 双簇 L3 和 16 MB SLC 共享 LPDDR5X。本文沿实测观察 Cache、带宽、QoS 与一致性代价。

## 分享卡片文案

为什么两个 5 大＋5 小的 CPU 簇，一个只有 8 MB L3，另一个却有 16 MB？GB10 的 113 ns DRAM 很亮眼，跨簇一致性为何又接近 200 ns？

## 封面

- 主标题：NVIDIA GB10
- 副标题：20 核双簇与共享内存系统
- 小字：X925 / A725 / L3 / SLC / LPDDR5X
- 比例：2.35:1，建议用 NVIDIA 绿＋Arm 蓝，突出两个不对称 Cluster

## 推荐标签与栏目

- 标签：NVIDIA、GB10、DGX Spark、Cortex-X925、Cortex-A725、Cache、统一内存、片上互连
- 栏目：处理器体系结构

## 文章结构

1. 双簇与大小核配置
2. L2/L3/SLC/DRAM 延迟
3. 单核与簇级带宽
4. CPU/GPU 受载延迟
5. 核间一致性
6. GB10 与 Strix Halo 的设计取舍

## 图片与排版

- 正文图片：18 张，按 01～18 上传
- 16、17 是高密度矩阵；移动端需允许点击查看原图
- 单位统一为 `GHz`、`MB`、`cycle`、`ns`、`B/cycle`、`GB/s`

## 后台设置

- 作者栏：Chester Lam
- 阅读原文：https://chipsandcheese.com/p/inside-nvidia-gb10s-memory-subsystem
- 原创声明：关闭
- AI 内容标识：开启后台相应标识

## 发布前边界

- 测试通过 ZeroOne Technology 的 DGX Spark 远程完成。
- 8/16 MB L3、接口不对称来自系统识别与微基准；DSU 接口数量仍是推测。
- 113 ns、带宽与核间延迟只代表该 LPDDR5X/固件配置。
- 16 MB SLC 的跨引擎价值是架构分析，不能简化成普通 CPU L4。
