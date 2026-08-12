# AMD Athlon 64 微信公众号发布资料

## 正式发布信息

- 正式标题：Athlon 64：AMD 如何靠“把基础做对”击败 NetBurst
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2022 年 7 月 28 日
- 英文标题：AMD’s Athlon 64: Getting the Basics Right
- 文章链接：https://chipsandcheese.com/p/amds-athlon-64-getting-the-basics-right
- 阅读原文链接：https://chipsandcheese.com/p/amds-athlon-64-getting-the-basics-right

### 摘要

从 30 张图理解 AMD K8：预测和窗口不如 NetBurst，却用三周期 L1D、温和慢路、二级 TLB、集成内存控制器与 HyperTransport 把基础做对。

### 封面文案

主标题：AMD Athlon 64

副标题：把基础做对

### 分享文案

K8 没有 NetBurst 的大窗口、Trace Cache 和强预测，却靠更低延迟、更小失败代价和集成内存控制器赢得竞争。

### 备选标题

- 30 张图看懂 AMD Athlon 64
- K8 对 NetBurst：复杂不等于更快
- Athlon 64 架构分析：AMD 的基础功

### 文章标签

- AMD K8
- Athlon 64
- NetBurst
- CPU 微架构
- 分支预测
- Cache 与 TLB
- 集成内存控制器

### 所属栏目

CPU 微架构史

## 图片资料

- 正文图片：30 张；目录：`amd_athlon_64_figures/`；顺序：`01` 至 `30`
- 多张 Die Photo、BTB、Hot Chips、Forwarding 与平台图有网页正式图注，中文图注同时补充证据边界
- 图 4、5、18、19、24 为密集曲面或矩阵，移动端建议保留点击查看
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，可使用图 30 K8 Die 或图 29 总结
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- BTB、MAB、RRF/PRF、Macro-op、TLB、ECC、HyperTransport 等术语保留
- “体系结构视角”小节显式保留

## 后台设置

- 标题：Athlon 64：AMD 如何靠“把基础做对”击败 NetBurst
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/amds-athlon-64-getting-the-basics-right
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～30

## 来源与表述要求

- 主平台 Athlon FX-62 为 90 nm、2.8 GHz；部分数据来自 65 nm Athlon 64 6000+，NetBurst 平台与内存配置不同。
- 16384-entry Predictor 需要 14-bit Index，Optimization Manual 明示信息只解释 12 bit；Hans de Vries 的 Line 内 Branch 选择是推测。
- AMD 称 Branch Accuracy 比 K7 提升 5%～10%，实测 Pattern 仍落后 16-bit History 的 NetBurst。
- 2048-entry BTB 与 L1I 紧耦合；NetBurst 解耦 BTB 是合理推测，不写成 RTL 事实。
- K8 1 MB L2 实测 12.5 cycle，Hot Chips 暗示 11 cycle；不强行统一。
- Store Forwarding 成功两者约 5 cycle；K8 失败 10～15，NetBurst 约 51，必须同时保留覆盖能力与失败代价。
- FX-62/EE 965 使用 DDR2-800 与 DDR2-533，DRAM 对比属于平台结果。
- Die Annotation 全是估计，不作为模块边界确认。

## 发布预览要点

- 30 张图和图注连续，本地链接有效，真实 MIME 与扩展名一致。
- `3-wide`、`16K predictor`、`2048 BTB`、`24×3 ROB lines`、`120 FP RF`、`32/512 DTLB` 等数字正常。
- K8 Core、NetBurst 对照、系统级 IMC/HyperTransport 与教学分析保持分层。
- 腾讯云 COS URL 全部返回 HTTP 200，且 `Content-Type` 与图片格式一致。
- 母稿与 WeMD 除 H1、YAML 和图片 URL 外正文一致。
