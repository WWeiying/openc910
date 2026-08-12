# Arm Cortex-A57 微信公众号发布资料

## 正式发布信息

- 正式标题：Cortex-A57：Nintendo Switch 的 CPU 为何如此吃力
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2023 年 12 月 12 日
- 英文标题：Cortex A57, Nintendo Switch’s CPU
- 文章链接：https://chipsandcheese.com/p/cortex-a57-nintendo-switchs-cpu
- 阅读原文链接：https://chipsandcheese.com/p/cortex-a57-nintendo-switchs-cpu

### 摘要

从 34 张图理解 Nintendo Switch 的 Cortex-A57：三宽乱序与统一寄存器文件并不寒酸，真正的压力来自小调度器、高 FP 延迟、异常 TLB 慢路和薄弱的 L2/DRAM 带宽。

### 封面文案

主标题：Cortex-A57

副标题：Switch CPU 为何如此吃力

### 分享文案

40 个 Bundle、灵活 Rename、三宽乱序，却被八项 Scheduler、12 项 Store Queue、五十多周期 TLB/L2 慢路和不到 8 GB/s 的 CPU 内存带宽拖住。

### 备选标题

- 34 张图看懂 Nintendo Switch 的 Cortex-A57
- Cortex-A57 架构分析：三宽乱序为何仍显孱弱
- Switch 的 CPU 瓶颈究竟在哪里

### 文章标签

- Arm Cortex-A57
- Nintendo Switch
- Nvidia Tegra X1
- CPU 微架构
- 乱序执行
- Cache 与 TLB
- 内存带宽

### 所属栏目

CPU 微架构

## 图片资料

- 正文图片：34 张；目录：`arm_cortex_a57_figures/`；顺序：`01` 至 `34`
- 图 1、4、10、11、15、17、28、34 有网页正式图注，其余中文图注用于辅助读图
- 图 5、7、13、17、21 为密集曲面、表格或矩阵，移动端建议保留点击查看
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，可使用图 1 Tegra X1 Die 或图 34 游戏画面
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- BTB、RAS、ROB/Bundle、ARF/PRF、TLB、MLP、RFO 等缩写保留
- “体系结构视角”小节显式保留

## 后台设置

- 标题：Cortex-A57：Nintendo Switch 的 CPU 为何如此吃力
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/cortex-a57-nintendo-switchs-cpu
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～34

## 来源与表述要求

- 核心来自 Nintendo Switch 的 Tegra X1，A73、Skylake、Jaguar 对照均为不同平台。
- 40 是 Instruction Bundle 数，不是固定 40 条指令；NOP、Branch、Memory 各占一 Bundle，Math 可多条合并。
- Unified Register File 为 128×32 bit；实际可见容量受 Value Width、Bundle 和可能的对齐碎片影响。
- 32-entry RAS 来自噪声较大的拐点，只能写成推测。
- A57 Execute-stage 与 A73 Retired-stage Branch PMU 事件不等价。
- A73 的 `l2d_cache_refill` 可能计入激进 Prefetch，不能按 Demand Miss 解释。
- 12 KB 处的 TLB 异常可由 Huge Page 消除，但具体成因未知，不写成确认 Bug。
- Tegra X1 DRAM 理论 25.6 GB/s，CPU 实测峰值低于 8 GB/s；这是整条 SoC 路径结果。
- Benchmark 为 2.67 GB 文件的 7-Zip 与 4K→720p libx264，网页未完整给出版本和 Flags。

## 发布预览要点

- 34 张图和图注连续，本地链接有效，真实 MIME 与扩展名一致。
- `3-wide`、`40 bundles`、`128×32-bit RF`、`8/12/16 scheduler`、`32/12 LQ/SQ`、`32/1024 TLB` 等数字正常。
- A57 Core IP、Tegra X1 SoC、Switch 产品和异平台对照保持分层。
- 腾讯云 COS URL 全部返回 HTTP 200，且 `Content-Type` 与图片格式一致。
- 母稿与 WeMD 除 H1、YAML 和图片 URL 外正文一致。
