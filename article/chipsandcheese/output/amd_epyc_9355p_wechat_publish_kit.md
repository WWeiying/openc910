# AMD EPYC 9355P 微信公众号发布资料

## 正式标题

AMD EPYC 9355P：32 核 Turin 如何把资源留给每一颗核心

## 备选标题

- 32 核 EPYC 9355P：低核心数服务器不只是提高频率
- 八颗 CCD、32 核：拆解 EPYC 9355P 的 GMI-Wide
- AMD Turin 的另一种扩展方式：少核心、宽链路、大 Cache

## 作者与来源

- 作者栏：Chester Lam
- 首发：Chips and Cheese
- 英文题目：*AMD’s EPYC 9355P: Inside a 32 Core Zen 5 Server Chip*
- 发布日期：2025 年 9 月 30 日
- 阅读原文：https://chipsandcheese.com/p/amds-epyc-9355p-inside-a-32-core

## 摘要

EPYC 9355P 用八颗 CCD 承载 32 核，为每四核保留 32 MB L3，并以 GMI-Wide 提供双链路。实测揭示 NPS、带宽与低核心数服务器的真正价值。

## 分享卡片文案

核心数少了，AMD 没把 Cache 和互连一起削掉。沿 18 张图看 32 核 EPYC 9355P 的八 CCD、GMI-Wide、NPS1/2/4 与 SPEC CPU2017。

## 封面

- 主标题：EPYC 9355P
- 副标题：32 核 Turin 的宽链路设计
- 小字：8 CCD / GMI-Wide / 256 MB L3 / 12-channel DDR5
- 比例：2.35:1，AMD 橙＋服务器深灰，突出中央 IOD 与八颗 CCD

## 推荐标签与栏目

- 标签：AMD、EPYC、Turin、Zen 5、服务器 CPU、NUMA、Infinity Fabric、内存带宽
- 栏目：处理器体系结构

## 文章结构

1. 32 核与八颗完整 CCD
2. NPS1/NPS2/NPS4 延迟和带宽
3. GMI-Wide 受载特性
4. SPEC CPU2017 单线程与八 Copy
5. 低核心数服务器的资源重分配

## 图片与排版

- 正文图片：18 张，按 01～18 上传
- 图 6、8、13～15 数字密集，检查移动端可读性
- 不使用宽表格，单位保留半角

## 后台设置

- 作者栏：Chester Lam
- 阅读原文：https://chipsandcheese.com/p/amds-epyc-9355p-inside-a-32-core
- 原创声明：关闭
- AI 内容标识：开启后台相应标识

## 发布前边界

- 被测是 Dell 提供、ZeroOne 托管的 PowerEdge R6715，768 GB DDR5-5200。
- 9355P 为 32 核；完整 CCD 数、启用核数与系列最高核心数不要混写。
- NPS4 最低延迟但每节点只有三个控制器；549.fotonik3d 结果不能外推所有负载。
- GMI-Wide 结论不自动适用于每 CCD 八核、GMI-Narrow 的高密度 SKU。
