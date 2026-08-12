# Intel Lion Cove 微信公众号发布资料

## 正式发布信息

- 正式标题：Lion Cove：Intel P-Core 再度咆哮，八宽核心与多级 Cache
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2024 年 9 月 27 日
- 英文标题：Lion Cove: Intel’s P-Core Roars
- 文章链接：https://chipsandcheese.com/p/lion-cove-intels-p-core-roars
- 阅读原文链接：https://chipsandcheese.com/p/lion-cove-intels-p-core-roars

### 摘要

Lion Cove 把 P-Core 扩至八宽前端、18 个执行端口和约 576 项可见 ROB，并以 192 KB L1.5 重写 Cache 层次；36 张图完整解析其前端、后端与内存系统。

### 封面文案

主标题：Lion Cove 再度咆哮

副标题：八宽核心与四级数据层次

### 分享文案

八宽译码、12-wide 微操作 Cache、三级 BTB、18 个执行端口、约 576 项可见 ROB，再加一层 192 KB L1.5：Lion Cove 如何在移动功耗内重构 Intel P-Core？从 36 张图读懂前端、乱序后端、Store Forwarding、TLB 与整套 Cache 层次。

### 备选标题

- Lion Cove 微架构全解：Intel 如何重写新一代 P-Core
- 从 576 项 ROB 到 L1.5：Lion Cove 为什么是一次大改
- Intel Lion Cove：八宽前端、18 端口与四级 Cache

### 文章标签

- Intel Lion Cove
- Lunar Lake
- P-Core
- CPU 微架构
- 乱序执行
- 分支预测
- Cache 与内存

### 所属栏目

CPU 微架构

## 文首来源信息

正文保留以下信息：

> **文章来源**
>
> - 文章：*Lion Cove: Intel’s P-Core Roars*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2024 年 9 月 27 日
> - 链接：https://chipsandcheese.com/p/lion-cove-intels-p-core-roars

## 图片资料

- 正文图片：36 张
- 文件目录：`intel_lion_cove_figures/`
- 文件顺序：`01` 至 `36`
- 图片格式：PNG、JPG
- 图片来源：英文网页中的正文图表，按出现顺序提取
- 图 10、17、19 带英文正式图注；其他中文图注用于解释坐标、数字与证据边界
- 图 17 为高密度 Store Forwarding 矩阵，图 25、26、34、35 为多子项图表，移动端应保留点击查看原图能力
- WeMD 副本由脚本上传腾讯云 COS，并改写为 HTTPS 图片地址

## 封面规格

- 推荐比例：2.35:1
- 工作尺寸：900 × 383 px
- 背景：Intel 深蓝与 Lunar Lake 浅青渐变
- 主体：八宽前端、分区调度器和 L1D/L1.5/L2/L3 四级层次的抽象结构
- 主标题：Lion Cove 再度咆哮
- 副标题：八宽核心与四级数据层次
- 避免直接采用高密度测试曲线作为封面

## 移动端排版

- 正文字号：15～16 px；行距：1.7～1.8
- 小标题：18～20 px；“体系结构视角”保持明显层级
- 图片说明：12～13 px，灰色；图 17、25、26、34、35 允许点击查看原图
- BTB、RAS、ROB、TLB、RMW、MPKI、`-O3 -mtune=native -march=native` 等保留行内代码或英文缩写
- 图 16、19、20 的数字密集，不与其他图片横向拼接

## 后台设置

- 标题：Lion Cove：Intel P-Core 再度咆哮，八宽核心与多级 Cache
- 作者栏：Chester Lam
- 摘要：使用本文件“摘要”部分
- 封面：使用“封面文案”和“封面规格”部分制作
- 阅读原文：https://chipsandcheese.com/p/lion-cove-intels-p-core-roars
- 原创声明：关闭
- AI 内容标识：开启公众号后台提供的相应标识
- 图片上传顺序：01～36

## 来源与表述要求

- 约 576 项 ROB、97/114/62 项调度容量、290/406/166 项寄存器、189/120 项 Load/Store Queue、180 项分支资源等来自微基准反推，不写成 Intel RTL 确认参数。
- Intel 把 48 KB/192 KB/2.5 MB 称作 L0/L1/L2；正文为便于代际比较使用 L1D/L1.5/L2，发布时不要混写成两套同时存在的实体。
- 192 KB L1.5 约 9 周期的主要作用是降低平均 L1 miss 代价，不写成与 L1D 等带宽的第二个一级 Cache。
- 12 MB L3 只直接连接四颗 Lion Cove；Skymont E-Core 集群不应被写成同样挂接这条 L3 环。
- 8 MB Memory Side Cache 主要面向 NPU、显示等 SoC 客户端，不写成 P-Core 的普通 L4。
- 18 个执行端口不代表 18 个等价 ALU；持续 Store 仍约两条/周期，FP/向量端口能力也不同。
- Store Forwarding 延迟能显示快慢路径，但不能唯一确认是否等待 Store 退休、是否使用某种合并网络。
- L2 TLB 总计 2048 项由两个 1024 项分区构成，覆盖页大小不同；不要简化成所有页面共享一个完全均匀的 2048 项表。
- 随机方向模式约 12K 的拐点不是 12K-bit GHR；它还受索引散列、容量与 aliasing 影响。
- BTB 为微基准观察到的三级延迟平台；约 2 KB、6K、12K 分别描述不同快速层/容量现象，不能自行补组相联与标签位宽。
- 24/20 项 RAS 是调用深度拐点推断；“可能两级”仍是解释，不写成已确认结构。
- SPEC CPU2017 使用 GCC 14.2、Rate-1 Estimated Score 和 `-O3 -mtune=native -march=native`；平台、频率、功耗、内存均不同，不写成严格同频 IPC 排名。
- 文章发布于 2024 年 9 月，关于 Arrow Lake 的段落是当时对尚未发布桌面实现的期待，不倒写为后来的实际结果。

## 发布预览要点

- 标题、署名、日期与原始链接一致。
- 36 张图片编号连续，母稿与 WeMD 图片数一致。
- `12 MB`、`8 MB`、`192 KB/9 cycle`、`2.5 MB/17 cycle`、`97/114/62`、`18 ports`、`576`、`189/120`、`2048`、`8/12-wide` 等关键数字显示正常。
- 图 17 在手机上可放大，矩阵与 Henry Wong 链接没有被裁切或断行。
- 图 32～35 的 SPEC 口径说明与图表相邻，不被排版拆散。
- 腾讯云 COS URL 返回 HTTPS 200，Content-Type 与 PNG/JPEG 一致。
- 手机预览没有横向滚动、图片错位、英文链接断行或重复标题。
