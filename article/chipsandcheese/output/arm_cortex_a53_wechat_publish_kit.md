# Arm Cortex-A53 微信公众号发布资料

## 正式发布信息

- 正式标题：Arm Cortex-A53：微小，却举足轻重
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2023 年 5 月 28 日
- 英文标题：ARM’s Cortex A53: Tiny But Important
- 文章链接：https://chipsandcheese.com/p/arms-cortex-a53-tiny-but-important
- 阅读原文链接：https://chipsandcheese.com/p/arms-cortex-a53-tiny-but-important

### 摘要

从 28 张图理解 Cortex-A53：双发射顺序流水线、小型分支预测、有限 Nonblocking Load、单 AGU 和 256 KB 共享 L2，如何在极低功耗区间取得平衡。

### 封面文案

主标题：Cortex-A53

副标题：微小，却举足轻重

### 分享文案

八级流水线、双发射、八项 RAS、单项 BTIC、单 AGU、三个待处理 L1D miss。28 张图看懂 Cortex-A53 如何用极简结构覆盖手机、控制器与边缘设备。

### 备选标题

- Cortex-A53：一颗小核为什么如此重要
- 28 张图看懂 Cortex-A53 的低功耗取舍
- Cortex-A53 架构分析：顺序执行并没有消失

### 文章标签

- Arm Cortex-A53
- Amlogic S922X
- 低功耗 CPU
- CPU 微架构
- 分支预测
- Cache 与 TLB
- 顺序执行

### 所属栏目

CPU 微架构

## 图片资料

- 正文图片：28 张；目录：`arm_cortex_a53_figures/`；顺序：`01` 至 `28`
- 图 1、2、9、11、16、19、21、24、28 有网页正式图注；其余中文图注用于辅助读图
- 图 11、12 的网页资源名是 `.png`，实际编码为 JPEG，成稿已使用 `.jpg`
- 图 17 与图 18 在网页中位于不同段落，但两份资源字节完全相同；成稿保留这一原始编排
- 图 13、14 为高密度 Store Forwarding 矩阵，移动端应支持点击查看原图
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，可用 Tegra X1 裸片中的 A53 标注，或 A53 核心结构图
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- BTIC、RAS、AGU、TLB、SCU、MOESI、MPKI 等缩写保留
- “体系结构视角”小节显式保留
- 图 13、14 不裁切、不覆字，保留查看大图入口

## 后台设置

- 标题：Arm Cortex-A53：微小，却举足轻重
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/arms-cortex-a53-tiny-but-important
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～28

## 来源与表述要求

- 实测平台是 Odroid N2+ / Amlogic S922X，其中 A53 为双核集群，另有四颗 A73；SoC 结果不能全部归因于 A53 IP。
- 网页未披露 OS/Kernel、编译器与 Flags、固定频率、预热、重复次数和误差。
- 3072 项全局历史表、八项 RAS、256 项间接目标阵列等来自 Arm TRM；模式长度和多目标能力来自测试。
- BTIC 约 16 B 是依据两个 Fetch Window 和分支间距作出的推测，不是确认位宽。
- A53 缺少大型解耦 BTB 是文章结合 TRM 与测试的判断，不能进一步虚构内部索引结构。
- WAW 处理、标量 Forwarding 可能等待 Store 提交等属于机制解释，不是 RTL 结论。
- Nonblocking Load 的 8 条在途、4 条 FP、3 条分支等是特定测试可见边界，不应改写成命名内部队列。
- 10 项 Micro TLB、512 项 Main TLB、64 项 Walk Cache 和 40-bit PA 来自图中资料汇总。
- 图 24 是外部课程讲义，网页明确认为部分端口描述可疑，不是 Arm 官方结构图。
- 4K 跨页无额外惩罚只针对给定微基准，不等于所有异常页和访问类型都无慢路。
- 四项应用并非统一 Benchmark；libx264 使用 4K 输入、720p 输出、`slow` Preset，不能与旧文的 4K/`veryslow` 编码直接比较。
- Event `0xE0` 同时可能包含误预测与 Taken 分支附近前端带宽损失，不能二次拆分。
- Arm 声称同为 32 nm 时 A53 可用小 40% 面积达到 A9 性能，必须保留比较条件。

## 发布预览要点

- 28 张图片和图注编号连续，本地链接有效，真实 MIME 与扩展名一致。
- `3072/256/8`、`2/3-cycle`、`8 in-flight/4 FP/3 branches`、`10/512/64 TLB`、`3 misses` 等数字正常。
- 应用图中的 IPC、停顿比例、命中率与 MPKI 数字没有被跨系列错配。
- 腾讯云 COS URL 全部返回 HTTP 200，且 `Content-Type` 与图片格式一致。
- 母稿与 WeMD 除 H1、YAML 和图片 URL 外正文一致。
