# Arm Cortex-A710 微信公众号发布资料

## 正式发布信息

- 正式标题：Arm Cortex-A710：在没有对手的市场里稳健升级
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2023 年 8 月 11 日
- 英文标题：ARM’s Cortex A710: Winning by Default
- 文章链接：https://chipsandcheese.com/p/arms-cortex-a710-winning-by-default
- 阅读原文链接：https://chipsandcheese.com/p/arms-cortex-a710-winning-by-default

### 摘要

从 Snapdragon 8+ Gen 1 的 22 张测试图理解 Cortex-A710：五宽前端、大 Scheduler、三端口 L1D 与保守 TLB，如何在几乎没有同级对手的 Android 市场稳健升级。

### 封面文案

主标题：Cortex-A710 深入解析

副标题：稳健升级，还是不战而胜

### 分享文案

五宽、160 项 ROB、约 10K 主 BTB、三次 128-bit Load/cycle，却仍保留 32 项 DTLB 和 13～14 周期 L2。22 张图看清 Cortex-A710 如何用克制换能效。

### 备选标题

- Cortex-A710 深入解析：五宽移动大核的取舍
- 没有对手之后，Arm 如何设计 Cortex-A710
- Snapdragon 8+ Gen 1 的 A710：前端、后端与 Cache 全解

### 文章标签

- Arm Cortex-A710
- Snapdragon 8+ Gen 1
- 移动 CPU
- CPU 微架构
- DSU-110
- 分支预测
- Cache 与 TLB

### 所属栏目

CPU 微架构

## 图片资料

- 正文图片：22 张；目录：`arm_cortex_a710_figures/`；顺序：`01` 至 `22`
- 图 3 来自 Arm TRM；图 5、11、16 为结构整理；其余以微基准图为主
- 图 2、6、7、19 为高密度矩阵/曲面，移动端保留点击查看
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，以 A710 核心、DSU 双环和 6 MB L3 为视觉元素
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- DSU、BTB、RAS、VIPT、ROB、NSQ、TQ、MLP 保留英文缩写
- “体系结构视角”小节保留显式标题

## 后台设置

- 标题：Arm Cortex-A710：在没有对手的市场里稳健升级
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/arms-cortex-a710-winning-by-default
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～22

## 来源与表述要求

- 实测设备为 Asus Zenfone 9 / Snapdragon 8+ Gen 1；网页后半偶有“8 Gen 1”写法，正文已说明。
- Arm 的 30% 能效/10% 性能对比以“相对半 L3 容量 A78”为条件，不能脱离口径传播。
- DSU-110、最高 12 核/16 MB L3 是 IP 能力；Qualcomm 具体采用 6 MB L3。
- 633 MHz～2.745 GHz 为频点范围，受载测试通常在约 20 ms 后维持 2.22 GHz。
- Android 无法测试 Huge Page 与 SVE，数据噪声高于桌面平台。
- 第二颗 A710 可能有 64 KB L1 是测试推断，不是 Qualcomm 官方 Floorplan。
- 2048 项一级 BTB 来自极密 8 B Branch Spacing；现实有效分支数估计 512～1024。
- 10K 主 BTB、4K 间接总目标、14 项 RAS 等为微基准观察或反推。
- FP Scheduler/NSQ 采用 2023-08-20 修订结构，仍非 RTL 确认。
- 四整数端口中只有三条持续处理普通 Add/Logic，是吞吐实验结论；图 16 为结构假说。
- 32 项 DTLB 的功耗解释基于 Tag 比较数量推理。
- Store Forwarding 图只能确认延迟快慢路，不能确定内部回退状态机。
- L3 对共享/私有数据的 Inclusive/Exclusive 语义按 DSU 机制描述；不能泛化到所有 A710 SoC。
- TQ 48/56/62 为实现选项；Snapdragon 具体配置未由 RTL 确认。
- 结尾对 Qualcomm 自研核、Siryn 和市场竞争的判断保留 2023 年语境。

## 发布预览要点

- 22 张图片和图注编号连续，真实 MIME 与扩展名一致。
- `5-wide/10-stage`、`160 ROB`、`147/111/51`、`2048/10K BTB`、`32/1024 TLB`、`48/20/16 B/cycle` 等数字正常。
- 腾讯云 COS URL 全部返回 200 且 MIME 正确。
- 母稿与 WeMD 正文在统一图片 URL 后逐字一致。
