---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "arm_neoverse_v2_hot_chips_2023_wechat_article_zh"
---

> 英文标题：Hot Chips 2023: Arm’s Neoverse V2
> 撰文：Chester Lam、Chips and Cheese
> 首发：Chips and Cheese，2023 年 9 月 11 日
> 链接：https://chipsandcheese.com/p/hot-chips-2023-arms-neoverse-v2

Arm 在 2022 年 9 月已发布 Neoverse V2，Hot Chips 2023 时首个已知实现 Nvidia Grace 也已进入产品。它接续 N1/V1、N2，面向比传统低功耗 Arm 更高的 Server/HPC 性能区间；Venado 和 MareNostrum 5 等超算宣布采用 Grace/Grace-Hopper。不过 Bergamo 以 128 个 Zen 4c 核心和现成 x86 软件兼容性形成强大竞争。

![图 1：Neoverse V2 与相关 Server Core 关键规格](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_hot_chips_2023_wechat_article_zh/23883e21533faa5e_01_figure.jpg)

## 八宽前端：面向大而多分支的代码

V2 是八宽乱序核心，源自 Cortex-X3；V1 源自 Cortex-X1。前端重点是让 Branch Predictor 跑得更远，以隐藏 L1I Miss。

BTB 扩到 12K 项，与 Golden Cove 相当；条件方向使用八表 TAGE，并支持更长历史。更多 Target 与 History 让预测器在更大 Branch Footprint 下仍可提前生成 Fetch 地址。

![图 2：V2 分支预测、取指与多级缓存](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_hot_chips_2023_wechat_article_zh/abbc2947b39ed95c_02_figure.png)

Arm 把 64 KB L1I 称为“小”，而 AMD/Intel 常用 32 KB，可能反映其目标 Server Code Footprint 更大。可选 2 MB L2 用于把更多代码留在近处。

小 Footprint、高 IPC 场景则靠更快路径：iTLB 带宽翻倍，可能支持两次 Lookup/cycle；Micro-op Cache 带宽提高并匹配八宽 Rename。代价是 Micro-op Cache 容量反而缩小，似乎不再追求覆盖大段程序，而只抓最热 Loop。

![图 3：Micro-op Cache、六宽 Decode 与八宽 Rename](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_hot_chips_2023_wechat_article_zh/2c44864dab3ca2fa_03_figure.png)

容量变小会更常走 Conventional Decode，因此 Decoder 从五宽增至六宽，与 Golden Cove 相同；Decoder 前 Queue 也加大。Rename Checkpoint 可在 Mispredict 后快速恢复 Register Alias Table，让旧路径前的微操作继续执行，与前端重填重叠。具体 Checkpoint 内容是合理推断。

### 体系结构视角：六宽 Decode 和八宽 Rename 并不矛盾

Micro-op Cache 命中时可八宽供给，Decode Miss Path 只有六宽。前端通过 Queue 把瞬时高带宽储存起来，再平滑喂 Rename；若程序长期不命中 Micro-op Cache，六宽才成为持续上限。验证应分别测试热 Loop、L1I-resident 大 Loop 和 L2 Code。

## Backend：更多 ALU 与分布式 Scheduler

V2 延续 A710/X2 的大 Scheduler 方向。

![图 4：V2 调度队列与执行端口](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_hot_chips_2023_wechat_article_zh/c42f534ca723dc53_04_figure.png)

新增两条 ALU，总计六条 Common Integer Pipe。两个 Scheduler 各可每拍选两条，分别喂 ALU 与 Branch；其他 Queue 单端口喂单 ALU。

FP/Vector 由两个 28 项、双端口 Scheduler 喂四条 Vector Pipe，类似 X2 的两个 23 项 Queue。X2/A710 在 FP Cluster 前还有 Non-scheduling Queue，V2 很可能延续，以避免长延迟 FP 填满局部 Queue 后立即反压 Rename；但公开图未完全确认。

## 三 AGU 与 80 项 Store Queue

三个 AGU 各有 16 项 Scheduler。两个可 Load/Store，第三个仅 Load，因此每拍最高三个 Memory Operation。Store Queue 相对 X2 增 11% 至 80 项；AGU 前也可能有 Non-scheduling Queue。

![图 5：三条访存流水线、Load/Store Queue 与结果总线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_hot_chips_2023_wechat_article_zh/b42806f84ffc08b7_05_figure.png)

吞吐在整数 Server Code 中很强，但 Vector Data Width 小于 AMD/Intel 256 bit 乃至更宽路径。48 项一级 DTLB 覆盖 4 KB 页时 192 KB；L2 TLB 容量未披露，V1 为 2048 项，不能默认 V2 相同。

## 2 MB Banked L2 与 96 项 Transaction Queue

L2 可为 1/2 MB、八路、四 Bank，向 L1 提供 64 B/cycle，Load-to-use 十周期。若 3 GHz，约 3.33 ns，与关闭 Boost、4.2 GHz 的 7950X3D L2 实测接近；Sapphire Rapids 约 4.24 ns。跨芯片比较仍受频率和微基准影响。

L2 包含 L1I 内容，因此可充当 L1I Snoop Filter，避免 Probe 直接与 L1I 正常访问争端口。代价是 L2 一部分容量重复保存 L1 内容。Client Cortex-X3 可用 512 KB/1 MB 非包含 L2，因为低核心数 Mobile 的 Instruction Coherency 压力不同。

![图 6：V2 的 Inclusive L2 组织](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_hot_chips_2023_wechat_article_zh/169bed0713acef4d_06_figure.png)

L2 Miss 进入 96 项 Transaction Queue。Golden Cove 可跟踪约 48 个 Demand L2 Miss；V2 总 Queue 可能包含 Instruction Request。若延续 V1，最多约 92 项 Read Transaction。向系统的接口为双向 32 B/cycle。

![图 7：L2 Transaction Queue 与系统接口](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_hot_chips_2023_wechat_article_zh/62b1a949b88e9a01_07_figure.png)

V2 通过 CMN-700 Mesh 连接 Core、IO 和 Distributed Snoop Filter。最大规格可到 12×12 Mesh、512 MB LLC，甚至接近 Reticle Limit；这只是互连能力上限，不是典型芯片。

![图 8：CMN-700 最大 12×12 配置](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_hot_chips_2023_wechat_article_zh/3cc4146ec0e583df_08_figure.png)

## 用 Prefetch 对抗 Mesh Latency

L1/L2 都有 Prefetcher。L1 可用 Virtual Address、跨 Page 并触发 Page Walk；除 Stride/Region 外，还有 Sampling Indirect Prefetch，可追踪 Pointer Dereference。

![图 9：V2 的多类 Hardware Prefetcher](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_hot_chips_2023_wechat_article_zh/fe5cdcb143f412e9_09_figure.png)

Arm 把单线程 SPEC CPU2017 Integer 的 5.3% 提升归于 Prefetch 改进。单线程通常带宽余量大、Latency 敏感，SPEC 又有大 Data Footprint，最适合积极 Prefetch；多核带宽紧张时收益未必相同。

性能估算使用模拟的 32 核 3 GHz、32 MB LLC、2 GHz Mesh，并非实体产品；SPEC 用 “Reduced Benchmark”，很可能是代表性 Trace 片段。

![图 10：Arm 用于估算的 32 核模拟平台](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_hot_chips_2023_wechat_article_zh/d457bb629fb9b7c7_10_figure.png)

若 Trace 与完整运行相关良好，V2 单线程 SPEC2017 约增 13%。Prefetch 占最大部分，Scheduler 与 Load/Store 优化贡献较小；各 Block 单独叠加在 N1 Base 上，合计收益低于简单相加。

![图 11：单线程 SPEC 提升的 Block 分解](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_hot_chips_2023_wechat_article_zh/d13f4454ef1cb2ac_11_figure.png)

一些投入在单线程影响较小，多线程 SPECrate 估算提升更大。

![图 12：单线程与每核一份工作负载的增益](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_hot_chips_2023_wechat_article_zh/9fec832110781a15_12_figure.png)

更大 L2、Prefetch 和系统资源利用改善多核 Scaling。SPECrate 每核跑独立副本，Shared L3/Memory Bandwidth 压力大；大私有 L2 可减少 Mesh/LLC 流量。

### 体系结构视角：Prefetch 的收益会随并发反转

空闲带宽下，提前取数把 Latency 变成重叠时间；带宽饱和时，错误 Prefetch 会占 Queue、Mesh 和 DRAM，挤掉 Demand。验证需同时报告 Accuracy、Coverage、Lateness、额外流量及单核/满核结果，不能把单线程 5.3% 直接外推。

## 面积与 Zen 4c 的不同取舍

工艺缩小后，V2 面积与 V1 相近。

![图 13：V1/V2 工艺与 Core Area](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_hot_chips_2023_wechat_article_zh/e9c0139cb59a8e5a_13_figure.jpg)

V2 与 Zen 4c Core Area 相当。Zen 4c 有更大的六管线 FPU、256 bit Vector Execution 和 512 bit Vector Register Entry；V2 把更多面积给 2 MB L2 与 64 KB L1。两者都在 Branch Predictor 和 Load/Store 上投入显著。

![图 14：V2 与 Zen 4c Die 区域对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_hot_chips_2023_wechat_article_zh/0a1c850b2fe76238_14_figure.jpg)

## 结语

V2 的重排容量接近 Zen 4c，宽度和执行单元更多；Vector 已显著补强。具体场景下二者互有优势：V2 的大 L1/L2 与 Prefetch 面向大 Server Footprint，Zen 4c 的 Vector 和成熟 x86 Platform 更强。

![图 15：Neoverse V2 在 Arm Server 路线中的位置](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_hot_chips_2023_wechat_article_zh/4ff8d91b083948fa_15_figure.jpg)

Arm 的困难不只在核心：软件迁移、性能风险和缺少明确市场性能领导仍阻止部分组织采用。Hot Chips 数据主要是 Arm 模拟和规格，不等于 Grace 或其他实现的实测；但 V2 已是一颗严肃的高密度大核，足以给 Bergamo 和未来 Intel Density Product 施压。

## 参考资料

- Arm Hot Chips 2023 Neoverse V2 演讲
- Chips and Cheese：Hot Chips 2023: Arm’s Neoverse V2
- Arm CMN-700 Technical Reference Manual
