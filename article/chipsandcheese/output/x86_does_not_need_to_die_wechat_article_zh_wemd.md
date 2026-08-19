---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "x86_does_not_need_to_die_wechat_article_zh"
---

> 英文标题：Why x86 Doesn’t Need to Die
> 撰文：Chester Lam
> 首发：Chips and Cheese，2024 年 3 月 27 日
> 链接：https://chipsandcheese.com/p/why-x86-doesnt-need-to-die

面对“x86 应该消失”的论点，更值得结束的其实是把现代处理器简单分成 RISC 与 CISC 两派的争论。两种名称记录了 ISA 的历史起点：CISC 希望用较少、较复杂的指令完成任务，1970 年代的 x86 受此影响；RISC 希望用较少、较简单的指令降低 Hardware Complexity，1980 年代的 MIPS、Arm 起源于此。

但今天 CPU 性能更多由公司投入、微架构实现与软件生态决定。Superscalar 允许每周期执行多条指令；Out-of-order Execution（乱序执行）让不相关指令越过 Stall，Register Renaming 消除假依赖。它们远比“这条 ISA 当年属于哪一派”更能解释结果。

## 两套 ISA，现代核心却长得很像

![图 1：AMD Zen 4 微架构，依据 AMD 图示与微基准整理](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_does_not_need_to_die_wechat_article_zh/103276f5437d50f8_01_figure.png)

![图 2：Arm Cortex-X2 微架构，主要由微基准推断](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_does_not_need_to_die_wechat_article_zh/a883b46bc6e39dd3_02_figure.jpg)

Zen 4 与 Cortex-X2 都是 Superscalar、Speculative、Out-of-order，并做 Register Renaming；核心外都有 Multi-level Cache 与 Prefetcher，尽力避免 DRAM Penalty。它们首先响应的是“Compute 增长快于 Memory”的共同现实，而非 x86 或 AArch64 的标签。

### 体系结构视角：ISA 是契约，微架构才是执行它的方法

ISA 规定软件可见的 Instruction、Register、Memory Model 与 Exception；Pipeline、Micro-op、Scheduler、ROB、Cache、Predictor 是实现选择。同一 ISA 可有 In-order 小核和超宽乱序大核，不同 ISA 的高性能大核反而常采用相似技术。因此 ISA 影响设计，但不能替代对具体实现的分析。

## Decode 并非 x86 独有的负担

现代高性能 x86、Arm、MIPS、LoongArch、RISC-V 都不会像 1970 年代 MOS 6502 那样，直接用 Instruction Bit 控制每个执行单元。它们先 Decode 为内部格式，再交给乱序后端。

固定长度 RISC 指令的 Decode 也消耗功耗和延迟。Arm 和 Intel/AMD 一样使用 Micro-op Cache 保存已译码格式；部分 Arm Core 还在 L1I 存更长的 Intermediate/Predecoded Format，把部分 Decode 移到 Cache Fill Path，并与 Micro-op Cache 并用。大家都在缓解 Decode Cost，x86 并不孤立。

指令扩展也不只属于 x86。x86-64 有 SSE、AVX2、AVX-512；AArch64 有 ASIMD、SVE、SVE2；MIPS 有 MSA；由 64 bit MIPS 衍生但编码不兼容的 LoongArch 又加入 LSX/LASX。

![图 3：LoongArch LASX Vector Extension 的部分观测编码](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_does_not_need_to_die_wechat_article_zh/3822a094002cf039_03_figure.png)

AArch64 还增加了更快 Atomic、`memcpy/memset` 等非 Vector Feature；x86 也会在不同方向更新。Transistor Budget 增长后，把常见 Workload 用专门指令表达，正是提高性能/能效的正常手段。

## `mpsadbw` 并不可怕

x86 `mpsadbw` 一条指令可完成多次加法，常被当作“过于复杂”的例子。其用途来自 Video Codec：多数 Frame 以相对前一帧的差异编码，Sum of Absolute Differences（SAD）用于寻找 Block Change，Arm 也有类似 Vector Instruction。

![图 4：视频编码中的 Block SAD 计算](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_does_not_need_to_die_wechat_article_zh/65378c75884bca7b_04_figure.png)

一条指令内部做许多低层 Operation，不表示 Rename 也同样复杂。`mpsadbw` 只需两个 Source Register、一个 Destination：Renamer 读两次 Register Alias Table，再分配一个 Physical Register。

若用一串“简单”指令完成同样 SAD（甚至先不算 `mpsadbw` 的 Selection），每一条都要 Rename、分配目的寄存器、进入 Scheduler，并追踪中间依赖。

![图 5：把 SAD 拆成简单操作后产生的大量重叠依赖与中间值](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_does_not_need_to_die_wechat_article_zh/cce04bf37f2b1670_05_figure.png)

因此 Macro-level Complex Instruction 反而可能节省 Fetch/Decode/Rename Bandwidth、Scheduler Entry 与 Physical Register。假想的纯简单指令核心若要追平，只能提高 Clock 或加宽 Renamer；宽 Rename 又要在同周期处理同一 Architectural Register 的连续覆盖，依赖链逻辑更难，后端 Queue 也要扩大。

Arm 设计者当然同样珍惜这些资源。AArch64 的 Addressing Mode 可把 Index Shift、Base Add 与 Load 合成一个 Instruction；Vector Instruction 更可一次完成很多低层 Operation。

![图 6：Cortex-X2 Optimization Manual；RSUBHN2 可在两周期内完成 16 次 8 bit Subtract、选高半并 Round](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_does_not_need_to_die_wechat_article_zh/988f3dee29b3451f_06_figure.png)

另一方面，难并行的 Compression、Web Browsing 仍以简单 Operation 为主，现代 CPU 必须能快速执行它们，同时保留复杂指令加速特定热点。如今“RISC/CISC”更多描述远古来源，而非现实指令构成。

## 真正昂贵的是 Compatibility，但它也有价值

x86 保留 Real Mode，让 OS 能以长期稳定方式启动。同一个安装介质可覆盖 Zen 4、15 年前的 Phenom 及其间大量平台（老机需 MBR）；Phenom 仍能跑 Windows 10 或 Ubuntu 22.04。兼容性并非无限，例如 Northwood Pentium 4 不能开箱运行 Windows 10，但 PC Ecosystem 的 Longevity 很大程度来自这份投入。

![图 7：跨多代 PC 使用同一操作系统安装路径的兼容性示例](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_does_not_need_to_die_wechat_article_zh/b0776e38d0bdbc6f_07_figure.png)

手机生态形成鲜明对照：即使同厂、相隔数年，不同设备也常需定制 Image；厂商要逐设备 Build/Validate，很多 Arm 手机在硬件性能仍足够时就停止更新，变成 E-waste。解锁 Bootloader、使用 LineageOS 可延寿，却不是理想默认体验。

![图 8：LineageOS 拥有超过 1000 个 Repository，反映逐设备 Image 维护规模](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_does_not_need_to_die_wechat_article_zh/960d1d78136be115_08_figure.png)

兼容当然不能永久维持，ISA 要演进，验证 Real Mode 也有成本。文章发表时 Intel 已规划移除 Real Mode。合理方向不是永不破坏，而是仅在收益清楚时做最少 Compatibility Break，避免无谓 Upgrade Treadmill。

### 体系结构视角：生态性能包括部署、维护和寿命

处理器若不能运行目标软件，再高峰值也无意义。Compatibility 会增加 Decode、Boot 与 Validation 成本，却降低 OS Distribution、Application Qualification 和用户迁移成本。评价 ISA 时，Hardware PPA 只是系统账本的一部分，Toolchain、ABI、Firmware、Driver 与长期更新也要计入。

## 历史并不支持“简单 ISA 自动获胜”

1994 年 Alpha EV5 已是 4-wide、266 MHz，Intel Pentium 只有 2-wide、120 MHz；但后来 Intel 也做出了高性能 x86，差距并非 ISA 宿命。

2000 年代 Intel 甚至尝试用 Itanium 取代 x86。它有 128 个 Architectural Register，希望避免 Renaming；固定长度简单指令，把 Scheduling 推给 Compiler，并放弃硬件 OoO。随着 Transistor Budget 增长，更强 Predictor 与更大 OoO Structure 反而有效：Hardware 能适应 Runtime Behavior，动态安排比静态编译更稳，Itanium 的取舍最终失败。

![图 9：Intel Hot Chips 幻灯片中的 Itanium/EPIC 执行理念](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_does_not_need_to_die_wechat_article_zh/f05ab317c3c2fb6b_09_figure.jpg)

2010 年代后期，Marvell ThunderX3 与 Qualcomm Centriq 的 AArch64 Server 尝试也先后终止，不说明 AArch64 差，而说明 ISA 本身不足以替代性能、产品执行与生态。今天 AArch64 已有更强软件栈与 Core：Ampere Altra 进入 Google、Microsoft、Oracle Cloud，Amazon 也部署 Arm Neoverse，能够正面挑战 x86 双寡头，这是健康竞争。

## 结语

Arm、RISC-V、MIPS/LoongArch 或 x86，都要凭具体 Hardware 与 Software Ecosystem 成功。ISA Extension 会真实影响性能，License/Royalty 也值得讨论；但不能用 1980 年代的“RISC 全是简单硬连线、CISC 全是复杂 Microcode”解释今天的芯片。

x86 不因可变长度指令就必须消失，RISC 也不因名称就天然简单。更有意义的问题是：前端如何供给、Predictor 怎样恢复、Rename/Scheduler/ROB 多大、Cache/Interconnect 如何匹配工作集，以及整个平台能否长期运行用户需要的软件。

## 参考资料

- AMD Zen 4、Arm Cortex-X2 Architecture/Optimization Material
- Intel Itanium Hot Chips Material
- LineageOS Device Repositories
- Chips and Cheese：Why x86 Doesn’t Need to Die
