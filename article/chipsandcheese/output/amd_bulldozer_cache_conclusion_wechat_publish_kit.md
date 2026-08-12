# AMD Bulldozer（下）微信公众号发布资料

## 正式发布信息

- 正式标题：Bulldozer：AMD 的激进现代化（下）——Cache、内存与结局
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2023 年 1 月 24 日
- 英文标题：Bulldozer, AMD’s Crash Modernization: Caching and Conclusion
- 文章链接：https://chipsandcheese.com/p/bulldozer-amds-crash-modernization-caching-and-conclusion
- 阅读原文链接：https://chipsandcheese.com/p/bulldozer-amds-crash-modernization-caching-and-conclusion

### 摘要

从 19 张图理解 Bulldozer 的存储困局：16 KB Write-through L1D、4 KB WCC、2 MB 强 L2、Victim L3、集中 Northbridge 与 20-cycle L2 TLB 如何层层叠加。

### 封面文案

主标题：AMD Bulldozer（下）

副标题：Cache、内存与结局

### 分享文案

Bulldozer 的 2 MB L2 很出色，却夹在 16 KB Write-through L1D 和糟糕 L3 之间；真正的失败来自一长串小劣势相乘。

### 备选标题

- 19 张图看懂 Bulldozer 的 Cache 困局
- Bulldozer 为什么被存储系统拖垮
- AMD Bulldozer 架构分析：失败如何层层叠加

### 文章标签

- AMD Bulldozer
- CPU 微架构
- Cache
- TLB
- Northbridge
- 内存控制器
- 32 nm

### 所属栏目

CPU 微架构史

## 图片资料

- 正文图片：19 张；目录：`amd_bulldozer_cache_conclusion_figures/`；顺序：`01` 至 `19`
- 图 2 PMU 口径、图 4 Sandy Bridge-EP、图 13/14 频率估计、图 19 测试平台须保留
- 密集结构、延迟和带宽图移动端建议保留点击查看
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，可使用图 1 Cache Hierarchy 或图 18 演进图
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- L1D/L2/L3、WCC、Victim Cache、Northbridge、TLB、PMU 等术语保留
- “体系结构视角”小节显式保留

## 后台设置

- 标题：Bulldozer：AMD 的激进现代化（下）——Cache、内存与结局
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/bulldozer-amds-crash-modernization-caching-and-conclusion
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～19

## 来源与表述要求

- L1D 原计划 64 KB，先砍 32、再到 16 KB的信息来自前 AMD Engineer；Write-through 原因部分为推断。
- 8T/8-cell bitline 与 32 nm 难题有 AMD ISSCC 支撑，但不扩展电气根因。
- L2 内部六级、实测 20 cycle；其余十周期“Queue/Transit”是推测。
- L3 64-way 导致更长 Pipeline、Victim Policy 导致带宽差均为证据支持的解释，不是 RTL 确认。
- 35 GB/s Software Read 对应约 70 GB/s 内部流量来自 PMU `0x4E2` 复算。
- 220 ns Core-to-core 对游戏约 1% 是估算，不是直接性能消融。
- Memory 平台不同，只得出 Controller 合理，不做统一 DRAM 对比。
- L2 TLB 1024 项、Hit 约 20 cycle；K10 24-entry Walk Cache 与 Bulldozer Fill Policy 仍是推测。

## 发布预览要点

- 19 张图和图注连续，本地链接有效，真实 MIME 与扩展名一致。
- `16 KB/4-cycle L1D`、`4 KB WCC`、`2 MB/20-cycle L2`、`8 MB/64-way L3`、`1024-entry/20-cycle L2 TLB` 正常。
- 工艺事实、工程访谈、微基准和教学分析保持分层。
- 腾讯云 COS URL 全部返回 HTTP 200，且 `Content-Type` 与图片格式一致。
- 母稿与 WeMD 除 H1、YAML 和图片 URL 外正文一致。
