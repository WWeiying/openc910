# Nvidia Grace Hopper 微信公众号发布资料

## 正式发布信息

- 正式标题：Grace Hopper：Nvidia 的“半融合”CPU/GPU 超级芯片
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2024 年 7 月 31 日
- 英文标题：Grace Hopper, Nvidia’s Halfway APU
- 文章链接：https://chipsandcheese.com/p/grace-hopper-nvidias-halfway-apu
- 阅读原文链接：https://chipsandcheese.com/p/grace-hopper-nvidias-halfway-apu

### 摘要

从 23 张图理解 GH200：72 核 Neoverse V2、114 MB L3、LPDDR5X/HBM3 双池与 900 GB/s NVLink C2C，如何同时带来极高带宽、近 800 ns 远端延迟和平台验证挑战。

### 封面文案

主标题：Grace Hopper GH200

副标题：Nvidia 的“半融合”超级芯片

### 分享文案

900 GB/s 的 NVLink C2C 让 CPU 直接访问 HBM3，依赖延迟却接近 800 ns；GH200 展示了异构集成从峰值规格到可用平台的距离。

### 备选标题

- 23 张图看懂 Nvidia Grace Hopper
- GH200 架构分析：CPU 与 H100 之间还有多远
- Grace Hopper：900 GB/s 链路为何仍怕延迟

### 文章标签

- Nvidia GH200
- Grace Hopper
- Neoverse V2
- H100
- NVLink C2C
- NUMA
- 异构计算

### 所属栏目

CPU/GPU 系统架构

## 图片资料

- 正文图片：23 张；目录：`nvidia_grace_hopper_figures/`；顺序：`01` 至 `23`
- 图 1～6、22、23 等多图有网页正式图注和官方来源，中文图注同时补充读图边界
- 图 3、6、7、10～14、17～21 为密集曲线或矩阵，移动端建议保留点击查看
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，可使用图 1 GH200 渲染图或图 5 系统结构
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- SCF、NVLink C2C、NUMA、HBM3、LPDDR5X、MLP、DMA、SM 等术语保留
- “体系结构视角”小节显式保留

## 后台设置

- 标题：Grace Hopper：Nvidia 的“半融合”CPU/GPU 超级芯片
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/grace-hopper-nvidias-halfway-apu
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～23

## 来源与表述要求

- 被测 GH200 来自 Hydra，CPU 侧 480 GB LPDDR5X、GPU 侧 96 GB HBM3；GH200 存在其他配置。
- 900 GB/s 是 NVLink C2C 双向合计，每方向 450 GB/s。
- 图 6 CPU 访问远端内存未用 CUDA Copy Engine，仅由 CPU Core 通过标准 Linux Interface 传输。
- 接近 800 ns 的 HBM 延迟使用 2 MB Page；比本地 LPDDR 多 592 ns。
- 系统 Hang、PCIe/Graphics Error、OpenCL Context 失败属于这台 Cloud Instance/软件栈，不能外推所有 GH200。
- Grace 与 Graviton 4 Core 都是 Neoverse V2，差异从 L2 容量、频率、SCF/CMN、L3 与 DRAM 实现展开。
- 7-Zip 同命令却执行 2.58/1.86 万亿 Instruction，结果不可作纯微架构对照；libx264 均约 19.8 万亿。
- GPU Bandwidth Test 无法越过 384 MB，Copy Engine Test Hang；不得补造缺失峰值。
- 900 W 是 GH200 整体 Power Limit，不是 GPU 单独功耗。

## 发布预览要点

- 23 张图和图注连续，本地链接有效，真实 MIME 与扩展名一致。
- `72 cores`、`114 MB L3`、`384 GB/s LPDDR`、`4 TB/s HBM3`、`900/450 GB/s C2C` 等数字正常。
- Neoverse V2 Core IP、Nvidia Grace 实现、Hydra 测试环境和教学分析保持分层。
- 腾讯云 COS URL 全部返回 HTTP 200，且 `Content-Type` 与图片格式一致。
- 母稿与 WeMD 除 H1、YAML 和图片 URL 外正文一致。
