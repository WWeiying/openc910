# AMD Zen 4 上篇微信公众号发布资料

## 正式发布信息

- 正式标题：AMD Zen 4 上篇：前端、乱序执行与 AVX-512
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2022 年 11 月 5 日
- 英文标题：AMD’s Zen 4 Part 1: Frontend and Execution Engine
- 文章链接：https://chipsandcheese.com/p/amds-zen-4-part-1-frontend-and-execution-engine
- 阅读原文链接：https://chipsandcheese.com/p/amds-zen-4-part-1-frontend-and-execution-engine

### 摘要

Zen 4 没有全面加宽执行端，却以更强分支预测、6.75K 微操作 Cache、320 项 ROB、高频设计和 Double Pump AVX-512 提高既有资源利用率。

### 封面文案

主标题：AMD Zen 4 上篇

副标题：前端、乱序执行与 AVX-512

### 分享文案

两级 Override 预测、最多 3072 个快速 BTB 目标、6.75K 微操作 Cache、320 项 ROB，以及在 256-bit 管线上 Double Pump 的 AVX-512：25 张图拆开 Zen 4 前端与执行引擎。

### 备选标题

- Zen 4 前端全解：AMD 如何把六宽核心用得更充分
- 从 8K BTB 到 Double Pump：拆解 Zen 4 上半身
- AMD Zen 4 微架构上篇：不全面加宽，也能明显变快

### 文章标签

- AMD Zen 4
- Ryzen 9 7950X
- CPU 微架构
- 分支预测
- 乱序执行
- AVX-512
- 向量计算

### 所属栏目

CPU 微架构

## 文首来源信息

正文保留以下信息：

> **文章来源**
>
> - 文章：*AMD’s Zen 4 Part 1: Frontend and Execution Engine*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2022 年 11 月 5 日
> - 链接：https://chipsandcheese.com/p/amds-zen-4-part-1-frontend-and-execution-engine

## 图片资料

- 正文图片：25 张
- 文件目录：`amd_zen4_part1_figures/`
- 文件顺序：`01` 至 `25`
- 图片格式：PNG、JPG
- 图 2、3/4、5/6、9/10、11/12、15、16、21、22 带英文正式图注或纠错说明
- 图 3～6、9～12 为三维预测曲面，图 17～19、24 为密集表格，移动端保留点击查看原图
- WeMD 副本由脚本上传腾讯云 COS，并改写为 HTTPS 图片地址

## 封面规格

- 推荐比例：2.35:1
- 工作尺寸：900 × 383 px
- 背景：AMD 深红配低饱和灰黑
- 主体：两级预测器、六宽重命名与 256-bit Double Pump 的抽象结构
- 主标题：AMD Zen 4 上篇
- 副标题：前端、乱序执行与 AVX-512

## 移动端排版

- 正文字号：15～16 px；行距：1.7～1.8
- 小标题：18～20 px；“体系结构视角”保持明显层级
- 图片说明：12～13 px，灰色
- BTB、RAS、ROB、Override、Double Pump、Mask RF 等保留英文缩写
- 图 17～19、24 使用 100% 宽度，不与其他图片拼接

## 后台设置

- 标题：AMD Zen 4 上篇：前端、乱序执行与 AVX-512
- 作者栏：Chester Lam
- 摘要：使用本文件“摘要”部分
- 封面：使用“封面文案”和“封面规格”部分制作
- 阅读原文：https://chipsandcheese.com/p/amds-zen-4-part-1-frontend-and-execution-engine
- 原创声明：关闭
- AI 内容标识：开启公众号后台提供的相应标识
- 图片上传顺序：01～25

## 来源与表述要求

- 文首关于 2021 年“29% IPC”文章是网站正式撤回，必须保留“内容无效”的原意。
- 方向预测为两级 Override 行为判断；L1/L2 的具体表结构、标签和历史位宽没有 RTL 佐证。
- L1 BTB 最多 3072 个目标会受分支密度与同 Cache line 共享影响，不等于 3072 个物理 entry。
- 8K L2 BTB 为 8192 项，Zen 3 为 6656；命中额外惩罚从 3 周期降为约 1 周期。
- 间接目标阵列的 Override 机制来自旧手册与行为解释，不写成 Zen 4 已确认电路。
- RAS 约 32 项来自调用深度测试；Golden Cove 没有可确认的容量断崖。
- NOP 可两级融合，12 NOP/cycle 和 1265 NOP 不能写成 12-wide 前端或 1265 项通用 ROB。
- 图 16 纵轴原标注错误，应读作 IPC，不是 Bytes per Cycle。
- 320 项 ROB 用混合指令序列复核；224/192/332 等寄存器与队列数字仍为公开资料和微基准组合。
- Zen 4 可见 Load 数 136 与官方 Load Queue 88 是两种结构/口径，不能强行合并。
- 调度器不扩容、优先频率是文章根据工程权衡作出的解释，不是 AMD 官方原因。
- Zen 4 大部分 512-bit 指令在窗口中保持一条、执行端 Double Pump 是作者推断；512-bit Store 明确拆两条并占两项 Store Queue。
- AVX-512 不增加 L1D/L2 总线宽度；Zen 4 仍为每周期 2×256-bit Load、1×256-bit Store。
- Golden Cove AVX-512 数据来自能关闭 E-Core 的特定平台，不代表 Alder Lake 正式功能。
- 图 22 曾误画 Permute Unit，文章 2022-11-07 已更新删除；发布时保留纠错说明。

## 发布预览要点

- 标题、署名、日期与完整原始链接一致。
- 25 张图片编号连续，母稿与 WeMD 图片数一致。
- `3072`、`1024～2048`、`6656/8192`、`4K/6.75K`、`320/256/512`、`224/192/332`、`52+16`、`2×256/1×256` 等关键数字显示正常。
- 图 16 的纵轴纠错、图 22 的 Permute 纠错没有遗漏。
- 腾讯云 COS URL 返回 HTTPS 200，Content-Type 与 PNG/JPEG 一致。
- 手机预览没有图片错位、标题重复或表格裁切。
