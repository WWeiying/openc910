# Arm Cortex-X2 微信公众号发布资料

## 正式发布信息

- 正式标题：Arm Cortex-X2：向高性能进发
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2023 年 10 月 27 日
- 英文标题：Cortex X2: Arm Aims High
- 文章链接：https://chipsandcheese.com/p/cortex-x2-arm-aims-high
- 阅读原文链接：https://chipsandcheese.com/p/cortex-x2-arm-aims-high

### 摘要

从 26 张图理解 Cortex-X2：五宽前端、288 项 ROB、四条 FP/Vector Pipe、三 AGU 与 2048 项 L2 TLB，以及慢 L3/DRAM 如何限制强核心。

### 封面文案

主标题：Cortex-X2

副标题：Arm 向高性能进发

### 分享文案

六宽 Rename、288 项 ROB、174 项 Load Queue、四条 128-bit FP Pipe，却面对 18.18 ns L3 和 202 ns DRAM。26 张图看懂 Cortex-X2。

### 备选标题

- Cortex-X2：Arm 大核心的第一次全面伸展
- 26 张图看懂 Cortex-X2 的核心与系统瓶颈
- Cortex-X2 架构分析：强核心为什么还需要更好的 SoC

### 文章标签

- Arm Cortex-X2
- Snapdragon 8+ Gen 1
- CPU 微架构
- 分支预测
- 乱序执行
- FP Vector
- Cache 与 TLB

### 所属栏目

CPU 微架构

## 图片资料

- 正文图片：26 张；目录：`arm_cortex_x2_figures/`；顺序：`01` 至 `26`
- 图 1、11、13～16、19、20、25、26 有网页正式图注或明确来源；其他中文图注用于辅助读图
- 图 3～6、13～16 为高密度曲面或矩阵，移动端保留点击查看
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，可使用 Cortex-X2 总览或 Arm Area Slide
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- BTB、RAS、ROB、NSQ、AGU、TLB、DSU、CHI、RFO 等缩写保留
- “体系结构视角”小节显式保留

## 后台设置

- 标题：Arm Cortex-X2：向高性能进发
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/cortex-x2-arm-aims-high
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～26

## 来源与表述要求

- 测试设备为 Asus Zenfone 9 / Snapdragon 8+ Gen 1；核心稳定观察到 2.8 GHz，3.187 GHz 只是系统枚举频点。
- Android 无 Huge Page，L3/DRAM 曲线混入 L2 TLB miss 与 Page Walk。
- 网页未披露 OS/Kernel、编译器、功耗温度、预热、重复次数与误差。
- 64/10K BTB、14 RAS、23+23 FP Scheduler、29 NSQ 等为行为观察或反推，不是 RTL。
- FP 四 Pipe 未被测试完全用满，2.53/cycle 是实测，不应写成理论 4/cycle 已兑现。
- 图 10 的结构容量是特定阻塞序列下的可见容量；Zen 4 文档值与实测值需并列。
- X2 Forwarding 只快速覆盖有限 32-bit/64-bit 半部组合；向量低 32-bit 合并是额外观察。
- 72～96 项 Transaction Queue 是可配置范围，Snapdragon 具体值未确认。
- DSU-110 每 Master Port 最多 128 Read 是 IP 能力；Qualcomm 是否用该端口连接内存控制器只是推测。
- 6 MB L3、64-bit LPDDR5 与 202 ns 延迟属于 Snapdragon 实现，不能全部归因于 X2 核心。
- 约 2.1 mm² 面积依赖工艺、库和配置，不能裸比 Zen 4c。
- Apple M1、Zen 4、Skylake、N1 的曲线来自不同平台和频率，只用于体系结构趋势。

## 发布预览要点

- 26 张图片和图注编号连续，本地链接有效，真实 MIME 与扩展名一致。
- `3072 uop cache`、`288 ROB`、`213/156/174/72`、`48/2048 TLB`、`11-cycle L2`、`18.18/202 ns` 等数字正常。
- FP Scheduler 组织、CHI 连接和 Transaction Queue 配置等未知项仍有条件语气。
- 腾讯云 COS URL 全部返回 HTTP 200，且 `Content-Type` 与图片格式一致。
- 母稿与 WeMD 除 H1、YAML 和图片 URL 外正文一致。
