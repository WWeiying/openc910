# NVIDIA Vera 微信公众号发布资料

## 正式标题

NVIDIA Vera 白皮书的线头：强大的 CPU，不需要脆弱的论证

## 备选标题

- Vera CPU 很强，但 NVIDIA 的论证并不牢
- 从 Olympus 到 1.2 TB/s：拆解 NVIDIA Vera 白皮书
- 一颗强 CPU，为什么被白皮书拖了后腿

## 作者与来源

- 作者栏：George Cozma
- 首发：Chips and Cheese
- 英文题目：*NVIDIA’s Vera Whitepaper Has a Thread Loose*
- 发布日期：2026 年 8 月 5 日
- 阅读原文：https://chipsandcheese.com/p/nvidias-vera-whitepaper-has-a-thread

## 摘要

Vera 的 Olympus 核心、值预测和 1.2 TB/s 内存很有吸引力；但 SMT、NUMA、跨 ISA 计数器和精选 Benchmark 的论证仍需更严格地审视。

## 分享卡片文案

硬件很强，证据却有线头。沿 16 张图看 Vera 的 Olympus 核心、Spatial Multithreading、统一 NUMA、SPEC CPU2026 与 1.2 TB/s 内存究竟说明了什么。

## 封面

- 主标题：NVIDIA Vera
- 副标题：强大的 CPU，不需要脆弱的论证
- 小字：Olympus / SMT / NUMA / Memory / Benchmarks
- 比例：2.35:1，建议 900×383 px
- 视觉：深黑与 NVIDIA 绿，中央为 Vera/Olympus 抽象芯片，左右用“硬件能力/证据链”形成对照

## 推荐标签与栏目

- 标签：NVIDIA、Vera、Olympus、服务器 CPU、Arm、SMT、NUMA、内存带宽、性能分析
- 栏目：处理器体系结构

## 文章结构

1. Olympus 硬件与值预测
2. Spatial Multithreading 的真实取舍
3. 一个 NUMA 节点与物理距离
4. SPEC CPU2026、PMU 与跨 ISA 比较
5. 1.2 TB/s 内存接口
6. PageRank、ClickHouse 与 RL 证据边界
7. 如何评价 Vera

## 图片与排版

- 正文图片：16 张，按 01～16 上传
- 高密度图：1、5、7、9～13，需检查微信压缩后的文字
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px、灰色
- `SMT`、`NUMA`、`IPC`、`PMU`、`SPEC CPU2026` 保留半角

## 后台设置

- 标题：使用“正式标题”
- 作者栏：George Cozma
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/nvidias-vera-whitepaper-has-a-thread
- 原创声明：关闭
- AI 内容标识：开启后台相应标识

## 发布前边界

- 区分 Vera/Olympus 公开规格、NVIDIA 白皮书结果与 George Cozma 的质疑。
- Phoronix 数据属于厂商许可的预生产平台早期测试，不写成量产定论。
- 32 NUMA Node 是 AMD 可选配置；跨 ISA ops/cycle 缺少统一事件定义。
- 925 与 898 是完整 SPEC Rate 估算；1.7～1.8 倍来自四个精选子项。
- PageRank、RL 图缺少完整输入与方法，不能写成可复现的普遍结论。
