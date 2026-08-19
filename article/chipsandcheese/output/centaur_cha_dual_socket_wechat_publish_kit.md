# Centaur CHA 双路微信公众号发布资料

## 正式发布信息

- 正式标题：Centaur CHA 的双路实现：协议能跑，带宽却像没做完
- 署名：Chester Lam
- 来源：Chips and Cheese
- 日期：2022 年 4 月 23 日
- 英文标题：Centaur CHA’s Probably Unfinished Dual Socket Implementation
- 原始链接：https://chipsandcheese.com/p/centaur-chas-probably-unfinished-dual-socket-implementation

### 摘要

CHA远端DRAM多约92 ns、带宽却只有1.3 GB/s；Atomic Ping-pong反而合理，指向协议/Directory可用、Outstanding Request深度不足。

### 封面与分享文案

- 主标题：协议能跑，带宽没跑起来
- 副标题：Centaur CHA 的双路遗憾
- 分享文案：为什么跨Socket延迟只是平庸，带宽却比NVMe还低？15张图对照Westmere、Broadwell和Milan-X。
- 备选标题：1.3 GB/s的双路CPU互连；Centaur最后一颗服务器SoC的未竟工作

### 标签与栏目

- 标签：Centaur、CHA、CNS、NUMA、双路服务器、Cache Coherence
- 栏目：多核与互连

## 图片与移动端排版

- 图片15张，目录 `centaur_cha_dual_socket_figures/`，按01～15上传。
- NUMA矩阵和带宽对比全宽；Latency/Bandwidth/Atomic三节分开。

## 后台设置与发布前检查

- CHA测试1 GB+2 MB Page隔离NUMA，应用4 KB Page不同；Bandwidth为3 GB Read。
- Milan-X来自Cloud、Pinning不干净；Broadwell模式不同。
- Queue浅/未验证与“unfinished”是推断，不是Centaur内部确认。
- 核对92 ns、1.3 GB/s、42/51/70～80 ns、21.3/40 GB/s、90～130/190 ns及15图。
- 后台作者 Chester Lam；阅读原文完整链接；原创关闭，AI标识按要求开启。
