# Intel Skymont 详解｜微信公众号发布资料

## 正式标题

Intel 详解 Skymont：9-wide 前端、416 项 ROB 与 26 个执行端口

## 备选标题

- Skymont 还是“小核”吗：拆解 Intel 最宽 E-Core
- 三组译码、16-wide 退休：Skymont 为什么这样设计
- 从 Nanocode 到 4K TLB：Intel 如何补齐 Atom 的短板

## 作者与来源

- 作者栏：Chester Lam、George Cozma
- 首发：Chips and Cheese
- 英文题目：*Intel Details Skymont*
- 发布日期：2024 年 6 月 15 日
- 阅读原文：https://chipsandcheese.com/p/intel-details-skymont

## 摘要

Skymont 以三组 3-wide Decoder、8-wide Rename、16-wide Retire、416 项 ROB、26 个端口和 4×128-bit 向量执行，把 E-Core 推向宽乱序核心。

## 分享卡片文案

9-wide 前端为什么不是两组 4-wide？16-wide 退休为何比入口宽一倍？15 张图看 Skymont 的结构与成本逻辑。

## 封面

- 主标题：INTEL SKYMONT
- 副标题：E-Core 的宽核心转型
- 小字：3×3 Decode / 416 ROB / 26 Ports
- 比例：2.35:1；Intel 蓝色，突出三集群前端与执行端口

## 推荐标签与栏目

- 标签：Intel、Skymont、E-Core、CPU 前端、乱序执行、Cache、TLB
- 栏目：处理器体系结构

## 图片与排版

- 正文 15 张图，按 01～15 上传。
- 图 2、7、9、13、14 是核心结构图，移动端不可裁切标注。

## 后台设置

- 作者栏：Chester Lam、George Cozma
- 阅读原文：https://chipsandcheese.com/p/intel-details-skymont
- 原创声明：关闭
- AI 内容标识：按平台要求开启

## 发布前边界

- 416 ROB、26 Port、4K L2 TLB 来自 Intel 公布信息。
- 同集群一致性的具体实现未公开，Cortex-A72 仅作机制参照。
- 16-wide Retire 不代表可越过未完成的 ROB Head。
- 与 P-Core 的比较必须同时考虑频率、ISA 与系统平台。
