# Intel Tremont 微信公众号发布资料

## 正式发布信息

- 正式标题：Intel Tremont：Atom 改变航向
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2022 年 1 月 2 日
- 英文标题：Intel’s Tremont: Atom Changes Course
- 文章链接：https://chipsandcheese.com/p/intels-tremont-atom-changes-course
- 阅读原文链接：https://chipsandcheese.com/p/intels-tremont-atom-changes-course

### 摘要

从 46 张图理解 Tremont：双三宽 Decode Cluster、208 项 ROB、Core 级分支预测和 NSQ 如何改变 Atom，又为何被小 Scheduler、弱 Cache 与缺失 AVX 限制。

### 封面文案

主标题：Tremont：Atom 改变航向

副标题：Gracemont 的关键起点

### 分享文案

六宽前端、四宽 Rename、208 项 ROB，却只有 31 项常用整数调度容量和 16 B/cycle 单核 L2。46 张图看 Intel 如何让 Atom 从低端小核变成 Hybrid 战略支点。

### 备选标题

- 深入 Tremont：Gracemont 之前，Atom 如何先变一次
- 双 Decode Cluster 与 208 项 ROB：Tremont 全解
- 从低功耗小核到 Hybrid 基石：Tremont 的强项与短板

### 文章标签

- Intel Tremont
- Atom
- Jasper Lake
- CPU 微架构
- 分支预测
- 乱序执行
- Hybrid CPU

### 所属栏目

CPU 微架构

## 图片资料

- 正文图片：46 张；目录：`intel_tremont_figures/`；顺序：`01` 至 `46`
- 图 2、36 来自 Intel 演示；图 1、12、19、22、35 为结构整理；其余为微基准、PMU 与平台测试
- 图 4～6、44～46 信息密集，移动端保留点击查看
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，用双 Decoder、Atom 核和四核共享 L2 表达“改变航向”
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- BTB、RAS、ROB、NSQ、PMU、TLB、AVX 保留英文缩写
- “体系结构视角”标题显式保留

## 后台设置

- 标题：Intel Tremont：Atom 改变航向
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/intels-tremont-atom-changes-course
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～46

## 来源与表述要求

- 30% IPC 增长是 Intel 相对 Goldmont Plus 的官方宣称。
- 双 Cluster 被描述为 Goldmont Plus Decoder 复用是文章推断，不是 RTL 证明。
- 128～160 条无 Taken 分支后退化、512/4096 BTB 等均是特定微基准观察。
- 208 ROB、168/175 RF、64/42 LSQ 等未公开容量为反推。
- 常用整数 Scheduler 31 项与总计 45 项必须区分，分支专用队列不服务普通整数操作。
- Memory/FP 的 34/57 在途容量含 NSQ，不等于 Scheduler 深度。
- 退休不超过四条来自 Event 0xC0 Count Mask 测试，不是 RTL 确认。
- Skylake RF Stall 细分使用未公开事件，正文已限定为粗估。
- Tremont/Gracemont/Skylake 的功耗与 FPS 来自不同整机，适合说明取舍，不作统一产品能效排名。
- Store Forwarding 的快慢路由延迟矩阵确认，内部状态机未公开。
- 图 44～46 是不同 ISA 的独立测试实现，比较时只看覆盖规则和延迟现象。

## 发布预览要点

- 46 张图和图注编号连续，母稿/WeMD 数量一致。
- `512/4096 BTB`、`208 ROB`、`31/45 scheduler`、`13+21 memory`、`24+33 FP`、`16/32 B/cycle L2`、`0.98/2.01/1.97 FPS` 等数字正常。
- 腾讯云 COS URL 全部返回 200，MIME 与扩展名一致。
- 母稿与 WeMD 在统一图片 URL 后逐字一致。
