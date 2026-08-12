# Arm Neoverse V2 / Graviton 4 微信公众号发布资料

## 正式发布信息

- 正式标题：Arm Neoverse V2：走进 AWS Graviton 4
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2024 年 7 月 22 日
- 英文标题：Arm’s Neoverse V2, in AWS’s Graviton 4
- 文章链接：https://chipsandcheese.com/p/arms-neoverse-v2-in-awss-graviton-4
- 阅读原文链接：https://chipsandcheese.com/p/arms-neoverse-v2-in-awss-graviton-4

### 摘要

从 30 张图理解 AWS Graviton 4 中的 Neoverse V2：六宽前端、八表 TAGE、三级 BTB、320 项 ROB、四条 FP/Vector Pipe，以及 96 核 Mesh、NUMA 和 DDR5 如何共同决定性能。

### 封面文案

主标题：Neoverse V2

副标题：走进 AWS Graviton 4

### 分享文案

96 颗 Neoverse V2、36 MB L3、十二通道 DDR5：核心很均衡，系统取舍却同样鲜明。30 张图看懂 Graviton 4 的前端、后端、Cache 与 NUMA。

### 备选标题

- 30 张图看懂 Graviton 4 与 Neoverse V2
- Neoverse V2 架构分析：六宽核心如何扩展到 96 核
- AWS Graviton 4：强核心、小 L3 与双路 NUMA

### 文章标签

- Arm Neoverse V2
- AWS Graviton 4
- CPU 微架构
- 服务器处理器
- 分支预测
- 乱序执行
- NUMA
- Cache 与内存

### 所属栏目

CPU 微架构

## 图片资料

- 正文图片：30 张；目录：`arm_neoverse_v2_graviton4_figures/`；顺序：`01` 至 `30`
- 图 2、5、8、13、17～19、25、29 有网页正式图注；其余中文图注用于辅助读图
- 图 2、3、7～12、18、19 为高密度矩阵或曲面，移动端应保留点击查看
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，可选图 1 的 Graviton 4 封装或图 6 的 V2 总览
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- TAGE、BTB、RAS、ROB、NSQ、AGU、TLB、CMN、NUMA、RRIP 等缩写保留
- “体系结构视角”小节显式保留

## 后台设置

- 标题：Arm Neoverse V2：走进 AWS Graviton 4
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/arms-neoverse-v2-in-awss-graviton-4
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～30

## 来源与表述要求

- 单路实例核心为 2.8 GHz，双路为 2.7 GHz；Genoa/Bergamo 对照来自不同频率、NUMA 和软件平台。
- 图 6 的 Queue、Register、BTB 和 Scheduler 容量部分来自微基准反推，不是 RTL。
- Arm 资料称八宽 Rename，实测持续六宽；两种口径必须并列。
- Arm 资料称六 ALU，Graviton 4 只能达到四 Add/cycle；删除哪两条 ALU/Queue 仍是推测。
- V2 Call+Return 两周期与文字称 Zen 4 四周期“相当”存在内部矛盾。
- Split-page Store 既被写成惩罚 11～12 周期，又被写成无惩罚，不能静默统一。
- Transaction Queue 在 Hot Chips 为 96 项、TRM 为 92 项。
- Benchmark 段落写 Graviton 3，图中写 Graviton 4，结合全文很可能是代际笔误，但需保留不确定性。
- 36 MB L3、CMN-700、十二通道 DDR5、跨路链路和实例频率属于 AWS 实现，不能全部归因于 V2 核心。
- Benchmark 未给完整版本、编译器、Flags、输入与误差，不能外推为云实例综合排名。

## 发布预览要点

- 30 张图和图注编号连续，本地链接有效，真实 MIME 与扩展名一致。
- `96 core`、`36 MB L3`、`2.8/2.7 GHz`、`320 ROB`、`175 LQ`、`80 SQ`、`48/2048 TLB` 等数字正常。
- 256/8K/14K BTB、31 RAS、六宽 Rename、四 ALU 等反推仍有近似或条件语气。
- 腾讯云 COS URL 全部返回 HTTP 200，且 `Content-Type` 与图片格式一致。
- 母稿与 WeMD 除 H1、YAML 和图片 URL 外正文一致。
