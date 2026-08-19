---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "arm_or_x86_isa_wechat_article_zh"
---

> 英文标题：ARM or x86? ISA Doesn’t Matter
> 撰文：Chester Lam
> 首发：Chips and Cheese，2021 年 7 月 13 日
> 链接：https://chipsandcheese.com/p/arm-or-x86-isa-doesnt-matter

关于 Arm 进入高性能市场的讨论，经常退回“RISC 天生省电、CISC 天生高性能”。这篇文章汇集研究、设计者访谈和实测，结论不是 ISA 完全没有任何影响，而是：对常见高性能通用处理器，微架构、工艺、目标功耗和软件生态通常远比 Arm/x86 标签重要。

## RISC/CISC 的旧边界已经收敛

x86 传统上用较少但更复杂的指令完成工作，被归为 CISC；Arm 则因采用更简单、易执行的指令而被归为 RISC。Jim Keller 指出，早期 x86 大量 Die 是 Microcode ROM，而现代 ROM、Adder 在大核面积中已很小；今天主要限制是指令/分支可预测性和数据局部性。

高性能核心要做的是持续喂对的指令与数据：Cache、Branch Prediction、Prefetch、Memory Dependence Prediction 才是大头。

2013 年 Blem、Menon、Sankaralingam 的《Power Struggles》也发现 Arm/x86 已高度收敛。

![图 1：论文总结 Arm 与 x86 的实现收敛](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_or_x86_isa_wechat_article_zh/54fee2d6bc7a845b_01_figure.jpg)

研究报告显示：实现之间性能差异很大，但指令数与 Mix 在一阶上与 ISA 无关；性能和能耗主要由 ISA-independent Microarchitecture 差异产生，没有一种 ISA 根本更省电。Arm 与 x86 产品只是针对不同性能点优化。

Intel Bonnell Atom 也说明 x86 可做低功耗。一项比较 Cortex-A9 与顺序执行 Bonnell 集群多级并行能力的研究中，Atom 在所测项目的性能与能效均领先，尽管 A9 是乱序。单项研究不能代表所有实现，却足以反驳“ISA 决定功耗”。

## x86 Decode Tax 有多大

x86 Variable-length Instruction 确实更难并行定界；Arm Fixed-length 更简单。但大核已用复杂 Predecode、Queue 和 Micro-op Cache 解决，Decode 并不主导 Die 或 Package Power。

在 Zen 2 上用 Undocumented MSR 关闭 Op Cache，Fetch/Decode Path 比 Op-cache Path 多约 4%～10% Core Power、0.5%～6% Package Power。测试 CPU-Z 且工作集在 L1，Zen 2 也未为关闭 Op Cache 优化；真实大工作集下 L2/L3/Memory Controller 占比会让 Decoder 比例更低。有些负载关闭 Op Cache 后总功耗反而下降，因为后端没被喂得那么满。

Haswell 的 2016 研究估计 Decoder 约占 Package Power 3%～10%，认为 x86-64 并非能效处理器的主要障碍。

![图 2：Haswell 各组件功耗模型中的 Decoder](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_or_x86_isa_wechat_article_zh/83d50d934c9982ca_02_figure.jpg)

Ivy Bridge 的在线功耗建模也显示 Fetch+Decode 远小于其他核心组件。

![图 3：Ivy Bridge Fetch/Decode 功耗估计](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_or_x86_isa_wechat_article_zh/36594d289213fa4d_03_figure.jpg)

这不表示 Decoder 功耗为零。功耗受限时每一瓦都有价值，x86 的 Op Cache 确实提高 Performance/Watt。

### 体系结构视角：前端省下的功耗可能转移到后端

更好的 Micro-op Cache/Decode 让后端执行更多有效工作，Package Power 可能上升但任务更快完成。应比较 Energy-to-solution，而非只看瞬时 Watt；还要分离 Frontend Idle、Backend Utilization 和 Race-to-sleep。

## Arm 同样使用 Micro-op Cache

Arm Decode 也值得绕过。Cortex-A77 在 2019 年加入约 1.5K 项 Op Cache，团队至少花六个月 Debug；后续 A78、A710、X1、X2 延续了这一设计。Samsung M5 也因为从四宽走向六宽、未来扩到八宽时 Fetch/Decode Power 显著，加入 Micro-operation Cache 供重复 Kernel。

因此 Fixed-length 并没有让高性能 Arm 免于 Decode 成本；两边都用相同思路降低它。

## Arm 指令也会拆成 Micro-op

“x86 拆 Micro-op 所以必然更耗电”的说法同样不成立。ThunderX3 仅靠减少 Micro-op Expansion 就比 ThunderX2 提升 6%，说明 Arm 指令也会展开。

![图 4：ThunderX3 的 6% Micro-op Expansion 改进](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_or_x86_isa_wechat_article_zh/b98b42b10cf82fa0_04_figure.png)

A64FX Manual 也列出一条 Armv8 Base Instruction 对应多个 Micro-op。

![图 5：A64FX 指令表中的多 Micro-op 指令](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_or_x86_isa_wechat_article_zh/7d7773cf3a1b4505_05_figure.jpg)

部分 SVE 指令甚至拆成几十个：严格顺序归约 `FADDA` 可达 63 个 Micro-op，其中一些九周期。`LDADD` 同时 Load/Add/Store，并非纯粹的简单 Load-store，A64FX 将其拆成四个 Micro-op。

## 两种 ISA 都有历史包袱

Arm 与 x86 在 64 bit 化时都清理过，却仍因多年需求增加扩展。RISC-V 发展历史更短、Legacy 少，今天实现新核心可能更简单；但 Legacy Operation 可以放到慢 Microcode，不必在 Fast Path 花大面积。现代大核面积主要在 Cache、Wide Execution、OoO Scheduler 和 BPU，Legacy 支持通常不是主导。

## ISA 何时仍然重要

文章的限定是“常见 Integer Workload 的一阶趋势”。若应用能使用 SSE/AVX/NEON/SVE、AES 等 Extension，ISA 与软件支持当然会改变性能。

![图 6：Zen 2 与 Ampere 编译 gem5 的时间](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_or_x86_isa_wechat_article_zh/329cbe0e769abb72_06_figure.png)

在编译测试中，两边大致处于同一范围；考虑到 Zen 2 更大、频率更高，N1 的表现合理。

![图 7：HEVC/x265 编码的巨大差距](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_or_x86_isa_wechat_article_zh/62f3de2236b1fa4d_07_figure.png)

24 秒 4K Clip 在 Altra 上超过半天，Zen 2 约一小时。最新 ffmpeg/libx265 启用 NEON 后 Arm 快 60% 以上、仍约九小时。Altra 动态指令数是 Zen 2 的 13.6 倍，新版路径仍 7.58 倍；Arm IPC 3.3/3.03，高于 Zen 2 的 2.35，却追不回工作量。这既涉及 Extension，也涉及 Hand-tuned Assembly 和生态，不可简化为 Base ISA。

### 体系结构视角：ISA 是接口，性能由接口两侧共同实现

一侧是 Compiler/Library 能否把算法映射到扩展，另一侧是 Core 如何 Decode、Rename、Schedule 和执行。相同 ISA 可有巨大实现差异；不同 ISA 也能在相同目标上收敛。只有控制工艺、频率、Cache、软件路径和工作量后，才可能估计 ISA 的边际影响。

## 结语

Arm 厂商不会因为换 ISA 自动战胜 Intel/AMD，必须依靠设计团队，或针对特定功耗/性能点绕开对手。反过来，x86 也不是高功耗的宿命，Atom 已证明可做低功耗。

有意义的问题不是“RISC/CISC 谁先进”，而是：预测器能否准确且及时，Cache/TLB 是否匹配工作集，Window 能否隐藏延迟，频率和电压是否接近能效甜点，软件是否使用了硬件。ISA 会影响实现，但不会替工程做完这些工作。

## 参考资料

- Emily Blem 等，Power Struggles，HPCA 2013
- Hirki 等，x86-64 Instruction Decoder Power，CoolDC 2016
- Agrawal，Cortex-A77 Macro-op Cache Verification，DVCon 2020
- Grayson 等，Samsung Exynos CPU Microarchitecture Evolution
- Oboril 等，High-Resolution Online Power Monitoring，DATE 2015
- Pinto 等，Low-power Multi-level Parallelism，CSBC 2014
- Chips and Cheese：ARM or x86? ISA Doesn’t Matter
