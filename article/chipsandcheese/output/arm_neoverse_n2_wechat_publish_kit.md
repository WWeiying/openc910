# Arm Neoverse N2 微信公众号发布资料

## 正式发布信息

- 正式标题：Arm Neoverse N2：面向服务器的 Cortex-A710
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2023 年 8 月 18 日
- 英文标题：ARM’s Neoverse N2: Cortex A710 for Servers
- 文章链接：https://chipsandcheese.com/p/arms-neoverse-n2-cortex-a710-for-servers
- 阅读原文链接：https://chipsandcheese.com/p/arms-neoverse-n2-cortex-a710-for-servers

### 摘要

以八核倚天 710 云实例观察 Neoverse N2：五宽前端、160 项 ROB、SVE、1 MB L2 与 CMN-700 如何把 Cortex-A710 改造成服务器核心，又为何仍受高 L3 延迟和较小窗口限制。

### 封面文案

主标题：Neoverse N2 深入解析

副标题：移动大核如何走进服务器

### 分享文案

N2 有五宽前端、160 项 ROB、两条 128-bit Vector 管线和 1 MB L2；倚天 710 的 L3 却约 35.48 ns。21 张图看清 Arm 用密度、私有 Cache 与 Mesh 对抗 Zen 4 的设计逻辑。

### 备选标题

- 深入 Neoverse N2：倚天 710 核心如何对阵 Zen 4
- Cortex-A710 的服务器形态：N2 的强项与代价
- 五宽前端、160 项 ROB 与高延迟 L3：Neoverse N2 全解

### 文章标签

- Arm Neoverse N2
- Cortex-A710
- Alibaba Yitian 710
- 服务器 CPU
- CPU 微架构
- CMN-700
- Cache 与 TLB

### 所属栏目

CPU 微架构

## 图片资料

- 正文图片：21 张；目录：`arm_neoverse_n2_figures/`；顺序：`01` 至 `21`
- 图 1、20、21 来自 Arm Hot Chips/公开资料；其余主要为测试图和结构整理
- 图 3、4 为分支预测曲面，图 17～19 为密集核间延迟矩阵，移动端保留点击查看
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，以 N2 核心、1 MB L2 与 CMN-700 Mesh 为视觉主线
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- ROB、BTB、TLB、SVE、NSQ、IPC、MSHR 保留英文缩写
- “体系结构视角”小节保留显式标题，与文章测试叙述自然区分

## 后台设置

- 标题：Arm Neoverse N2：面向服务器的 Cortex-A710
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/arms-neoverse-n2-cortex-a710-for-servers
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～21

## 来源与表述要求

- 实际访问的是八核倚天 710 云实例，不能写成完整 128 核芯片测试。
- 128 核、3.2 GHz、600 亿晶体管、八通道 DDR5 与 96 条 PCIe 5.0 是产品公开信息。
- 所测实例锁定 2.75 GHz；其他 N2 实现的频率策略未知。
- N2 的 10 级流水线来自 Arm；将其对应最小误预测路径是文章推测。
- 64 项 micro-BTB、8K 主 BTB 是 Arm 公布值；约 10K 的测试拐点不能直接当物理容量。
- 160 项 ROB 等官方/反推参数在图中混合，正文已分别说明。
- FP Scheduler 段采用 2023-08-20 勘误后的解释；约 19 项 Scheduler、约 14 项共享 NSQ 等仍是微基准重建，不是 RTL。
- L2 对 L1I Inclusive 属于公开机制语境；对 L1D Exclusive 的解释是文章推测。
- 35.48/35.05/33.48 ns 使用 16 MB 工作集；Pointer Chasing Pattern 为压制预取而加长。
- ROB/IPC 的 Little’s Law 计算是理想化窗口上限，不是实测隐藏周期。
- 111.95 GB/s DRAM、141/286 GB/s L3 等来自八核实例，不代表全芯片峰值。
- 图 16 对 N1/N2 的文字存在页面内部不一致，正文按图题与上下文说明，未静默删除。
- 核间延迟使用原子 Compare-and-Exchange；Mesh Stop 配对只是根据相邻核心结果提出的假说。
- 2023 年对 Siryn、Bergamo、Sierra Forest 与 N3 的判断保留当时语境，不倒写后续产品信息。

## 发布预览要点

- 21 张图片、图注和编号连续，母稿/WeMD 数量一致。
- `160/320 ROB`、`147/116`、`44/1280`、`48/52 bit`、`35.48 ns`、`36.5/141/286 GB/s` 等数字正常。
- 腾讯云 COS URL 全部返回 200，Content-Type 与图片扩展名一致。
- 母稿去除 H1、WeMD 去除 frontmatter 并统一图片 URL 后，正文逐字一致。
