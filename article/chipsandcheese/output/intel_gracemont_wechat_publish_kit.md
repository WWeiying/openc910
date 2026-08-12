# Intel Gracemont 微信公众号发布资料

## 正式发布信息

- 正式标题：Intel Gracemont：Atom 小核的复仇
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2021 年 12 月 21 日
- 英文标题：Gracemont: Revenge of the Atom Cores
- 文章链接：https://chipsandcheese.com/p/gracemont-revenge-of-the-atom-cores
- 阅读原文链接：https://chipsandcheese.com/p/gracemont-revenge-of-the-atom-cores

### 摘要

从 44 张图理解 Alder Lake 的 Gracemont：五宽 Rename、256 项 ROB、Core 级预测、AVX2 与共享 L2，如何把 Atom 推进高性能核心区间。

### 封面文案

主标题：Gracemont：Atom 小核的复仇

副标题：它不是传统意义的小核

### 分享文案

双三宽 Decode、五宽 Rename、256 项 ROB、64 KB L1I、5K BTB 和 AVX2——Gracemont 为何能用约四分之一单核功耗，做到大核级乱序能力？

### 备选标题

- 深入 Gracemont：Alder Lake 的能效核为何不是小核
- 256 项 ROB 与双 Decode Cluster：Gracemont 全解
- 从 Atom 到高性能乱序核：Gracemont 的复仇

### 文章标签

- Intel Gracemont
- Alder Lake
- Atom
- Hybrid CPU
- CPU 微架构
- 分支预测
- 乱序执行

### 所属栏目

CPU 微架构

## 图片资料

- 正文图片：44 张；目录：`intel_gracemont_figures/`；顺序：`01` 至 `44`
- 图 1、13、22、23、25、26、35 为结构整理，图 18 来自 Hirki 论文，其余主要是微基准和平台测试
- 图 2～7、39～44 信息密集，移动端保留点击查看
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，以四颗 E-Core、共享 L2 和双 Decode Cluster 为主体
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- BTB、ROB、NSQ、TLB、AVX2、RAPL、PMU 保留英文缩写
- “体系结构视角”标题显式保留

## 后台设置

- 标题：Intel Gracemont：Atom 小核的复仇
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/gracemont-revenge-of-the-atom-cores
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～44

## 来源与表述要求

- 5K BTB、深历史/大结构来自 Intel；1024 零气泡和二级 +2 cycle 来自微基准。
- A78 测试平台为 Realme GT，不能当统一 SoC 性能比较。
- 双 Cluster 自动切换结论来自循环测试；Rename 一次只能取一 Queue 是行为推断。
- 256 ROB、214/207 RF、80/50 LSQ 等未公开容量为反推。
- Scheduler 221、含 NSQ 299 带显著不确定性，不能作为精确官方总容量。
- MXCSR 不重命名与 256-bit 拆两条 128-bit micro-op 是测试结论/结构解释，无 RTL。
- Store 两发依赖同 Cache Line 合并；不同 Line 只有约一条/cycle。
- Little’s Law 表为理想上界，不是实测持续 IPC 保证。
- 共享 2 MB L2 的容量效率与带宽上限必须同时保留。
- 功耗来自 RAPL、libx264 第 90～120 帧；不是墙上功耗或通用能效排行。
- 12-23 修订中两种 Blocker 得到不同 Memory Scheduler 结论，正文采用后续共享结构并保留冲突原因未知。
- 文章对服务器、Bergamo 等判断处于 2021 年语境。

## 发布预览要点

- 44 张图和图注编号连续，母稿/WeMD 数量一致。
- `5K BTB`、`1024 zero-bubble`、`256 ROB`、`214/207 RF`、`80/50 LSQ`、`64 KB L1I`、`2 MB/17 cycle L2`、`5.72/21.05 W` 等数字正常。
- 腾讯云 COS URL 全部返回 200，MIME 与扩展名一致。
- 母稿与 WeMD 在统一图片 URL 后逐字一致。
