# Arm Cortex-A510 微信公众号发布资料

## 正式发布信息

- 正式标题：Arm Cortex-A510：把两颗小核装进同一件外套
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2023 年 10 月 2 日
- 英文标题：Arm’s Cortex A510: Two Kids in a Trench Coat
- 文章链接：https://chipsandcheese.com/p/arms-cortex-a510-two-kids-in-a-trench-coat
- 阅读原文链接：https://chipsandcheese.com/p/arms-cortex-a510-two-kids-in-a-trench-coat

### 摘要

从 21 张图理解 Cortex-A510：三宽顺序执行如何与双核合并配置结合，以及共享 FPU、L2 TLB、L2 Cache 和 CPU Bridge 带来的面积收益、争用与验证代价。

### 封面文案

主标题：Cortex-A510

副标题：把两颗小核装进同一件外套

### 分享文案

A510 第一次打破 Arm 小核延续十余年的两宽公式。真正大胆的变化，却是让两颗核心共享 FPU、L2 TLB、L2 Cache 和桥接。

### 备选标题

- 21 张图看懂 Cortex-A510
- Cortex-A510：三宽顺序小核与共享资源实验
- Cortex-A510 架构分析：两颗小核为何共享一套 FPU

### 文章标签

- Arm Cortex-A510
- CPU 微架构
- 顺序执行
- 分支预测
- 共享 FPU
- Cache 与 TLB
- Snapdragon 8+ Gen 1

### 所属栏目

CPU 微架构

## 图片资料

- 正文图片：21 张；目录：`arm_cortex_a510_figures/`；顺序：`01` 至 `21`
- 图 1、2、9、10、19～21 有网页正式图注，其余中文图注用于辅助读图
- 图 3、11、12 为密集曲面或矩阵，移动端建议保留点击查看
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，可选择图 1 双核结构或图 19 单/双核对照
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- Merged Core、BTB、RAS、VIPT、TLB、IPA、FPU、AGU、ECC 等术语保留
- “体系结构视角”小节显式保留

## 后台设置

- 标题：Arm Cortex-A510：把两颗小核装进同一件外套
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/arms-cortex-a510-two-kids-in-a-trench-coat
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～21

## 来源与表述要求

- 被测 A510 来自 Snapdragon 8+ Gen 1 的双核合并配置，A55 对照来自 Snapdragon 670，平台并不统一。
- 64-entry L1 BTB、约 512-entry L2 BTB、八项 RAS 等来自微基准解释；其中 L2 BTB 容量明确带问号。
- 2048-entry L2 TLB 是按 TRM 的八位 Set Index 和八路相联推算，不是 Arm 直接给出的总项数。
- L2 TLB 实测附加五周期，TRM 暗示三周期；两者不强行统一。
- Miss 后 12 条指令、6 条 FP、3 条 Branch、5 条 Load 是特定构造的可见距离，不是 ROB。
- Qualcomm 选择 2×64-bit 共享 FPU；其他 A510 实现可以选择单核配置或 2×128-bit FPU。
- L3、DRAM、频率和部分带宽属于 Snapdragon 8+ Gen 1 SoC 行为，不能全部归因于 A510 IP。
- SVE 在被测平台不可用；PALU 的预期收益没有实测。
- 超过 300 ns DRAM Latency 使用 4 KB Page，Android 环境无法进行 Huge Page 测试。

## 发布预览要点

- 21 张图和图注编号连续，本地链接有效，真实 MIME 与扩展名一致。
- `3-wide`、`8-stage`、`64/约512 BTB`、`8-entry RAS`、`16/约2048 TLB`、`128 KB shared L2` 等数字正常。
- 共享 FPU 的单核/双核口径正确：图 10 的 2c 数字是每核 IPC，整簇需要乘二。
- Snapdragon 8+ Gen 1 的具体配置、Arm 可选配置、测试反推和通用机制仍清晰分开。
- 腾讯云 COS URL 全部返回 HTTP 200，且 `Content-Type` 与图片格式一致。
- 母稿与 WeMD 除 H1、YAML 和图片 URL 外正文一致。
