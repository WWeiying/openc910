# Intel Skymont 微信公众号发布资料

## 正式发布信息

- 正式标题：Skymont：Intel E-Core 直上云霄，Cache 却决定了落点
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2024 年 10 月 3 日
- 英文标题：Skymont: Intel’s E-Cores reach for the Sky
- 文章链接：https://chipsandcheese.com/p/skymont-intels-e-cores-reach-for-the-sky
- 阅读原文链接：https://chipsandcheese.com/p/skymont-intels-e-cores-reach-for-the-sky

### 摘要

Skymont 把 E-Core 扩到八宽重命名、约 416 项 ROB、四管线 FPU 和七条 AGU，却也显示出核心升级如何被 Cache 层次重新定价。

### 封面文案

主标题：Skymont 直上云霄

副标题：八宽 E-Core 与 Cache 的拉扯

### 分享文案

三组译码、8K BTB、约 416 项 ROB、四管线 FPU、七条 AGU：Skymont 几乎全面扩张，为什么面对标准 Crestmont 时仍有胜有负？从 39 张图理解一颗现代 E-Core，以及 Cache 如何决定核心升级的落点。

### 备选标题

- Skymont 微架构全解：一颗 E-Core 如何做到八宽乱序
- 从 416 项 ROB 到 8 MB MSC：Skymont 为什么有时快、有时不快
- Intel Skymont：核心全面扩张，性能却仍由 Cache 决定

### 文章标签

- Intel Skymont
- Lunar Lake
- E-Core
- CPU 微架构
- 分支预测
- 乱序执行
- Cache 与内存

### 所属栏目

CPU 微架构

## 文首来源信息

正文保留以下信息：

> **文章来源**
>
> - 文章：*Skymont: Intel’s E-Cores reach for the Sky*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2024 年 10 月 3 日
> - 链接：https://chipsandcheese.com/p/skymont-intels-e-cores-reach-for-the-sky

## 图片资料

- 正文图片：39 张
- 文件目录：`intel_skymont_figures/`
- 文件顺序：`01` 至 `39`
- 图片格式：PNG、JPG
- 图片来源：英文网页中的正文图表，按出现顺序提取
- 图 3、20、35～39 带英文正式图注；其他中文图注用于解释坐标、数据和证据边界
- 图 5、6 是方向预测曲面，图 24、25 是高密度 Store forwarding 矩阵，发布时保留原尺寸和点击查看能力
- WeMD 副本由脚本上传腾讯云 COS，并改写为 HTTPS 图片地址

## 封面规格

- 推荐比例：2.35:1
- 工作尺寸：900 × 383 px
- 背景：Intel 深蓝配低饱和青色
- 主体：Skymont 三译码集群、416 项 ROB 和 4 MB L2 的抽象框图
- 主标题：Skymont 直上云霄
- 副标题：八宽 E-Core 与 Cache 的拉扯
- 避免直接使用密集测试曲线作为封面，消息列表缩略图中会失去辨识度

## 移动端排版

- 正文字号：15～16 px；行距：1.7～1.8
- 小标题：18～20 px；“体系结构视角”保持明显但不过度装饰
- 图片说明：12～13 px，灰色；图 5、6、24、25 允许点击查看原图
- `vaddps`、`cvtsi2ss`、FTZ、DAZ、MPKI、ROB 等保留等宽或行内代码样式
- 图 32、33 为纵向长图，宽度使用 100%，不与其他图横向拼接

## 后台设置

- 标题：Skymont：Intel E-Core 直上云霄，Cache 却决定了落点
- 作者栏：Chester Lam
- 摘要：使用本文件“摘要”部分
- 封面：使用“封面文案”和“封面规格”部分制作
- 阅读原文：https://chipsandcheese.com/p/skymont-intels-e-cores-reach-for-the-sky
- 原创声明：关闭
- AI 内容标识：开启公众号后台提供的相应标识
- 图片上传顺序：01～39

## 来源与表述要求

- Skymont 的 8K 末级 BTB、128 项 RAS、416 项 ROB、272/282 项寄存器、114/56 项 Load/Store Queue、96 项 Branch Order Buffer 等来自微基准和框图复原，不写成 Intel 官方 RTL 参数。
- 三组译码器有九个槽，但持续入口受八宽重命名限制；不要把“9-wide decode”写成应用可持续 9 IPC。
- 图 3 明确提醒端口框图为近似复原，尤其分布式调度器很容易反推错误。
- 方向预测随机模式拐点同时受历史、容量与 aliasing 影响；不能从图 5、6断言具体算法或确定历史位数。
- SPEC CPU2017 图明确的是 GCC 14.2 和 Rate-1 Estimated Score；编译 flags、输入、重复次数和误差没有披露。
- 0.68% 与 1.5% 的套件差距按文章判断属于误差范围，不升级为确定胜负。
- Low Power Crestmont、Compute Tile Crestmont、Skymont、Zen 5c 的工艺、频率、Cache 和平台不同；图 31～33 不是同频 IPC 或能效对比。
- Lunar Lake 的 8 MB Memory Side Cache 从 Skymont 测得至少约 59.5 ns/214 cycles；这是整颗 SoC 的拓扑结果，不是 Skymont 核心固定参数。
- DRAM 的 170 ns/133 ns 差异与内存控制器功耗状态有关，不能只归因于核心。
- architectural event `0x2E` 在 Skymont 和 Crestmont 上映射的 longest-latency cache 层级不同，不能把两者都理解为相同物理 LLC。
- `libx264` 只明确 veryslow、CRF 24 和四核对照；版本、输入与误差未披露。
- `y-cruncher` 明确为 0.8.5.2、25 亿位、Broadwell binary；其余运行条件不自行补齐。
- 图 20 中不同 FP/向量指令不能使用相同队列，是测试观察；具体准入逻辑仍未知。
- Store forwarding 矩阵证明某些偏移组合会出现 7～8 或 14～15 cycle 慢路，但不确认内部检查电路的具体实现。

## 发布预览要点

- 标题、作者、日期、原始链接与正文一致。
- 39 张图片编号连续、顺序正确，母稿与 WeMD 图片数一致。
- `8K`、`1024`、`128`、`416/256`、`272/282`、`114/56`、`96`、`48 B/cycle`、`59.5 ns`、`170/133 ns` 等关键数字显示正常。
- 图 31～33 的平台名没有把 Low Power Crestmont 与标准 Crestmont 混写。
- 图 24、25 在手机上可放大，矩阵没有被裁切。
- 腾讯云 COS URL 返回 HTTPS 200，Content-Type 与 PNG/JPEG 一致。
- 手机预览没有横向滚动、图片错位、英文链接断行或标题重复。
