# Chips and Cheese 微信公众号文章处理清单

更新时间：2026-08-19

清点口径：按 `input/` 中 144 个 HTML 的 canonical URL 去重，再与公众号母稿文首的主来源链接匹配。正文参考资料中出现过某个链接，不等同于该文章已经单独完成。初始待处理 99 篇；第一批至第十批均已完成，其中第二批至第十批共 89 篇于 2026 年 8 月 19 日统一完成，当前剩余 0 篇。

## 第一批：近期处理器与内存系统（已完成）

- [x] NVIDIA’s Vera Whitepaper Has a Thread Loose
- [x] Inside Nvidia GB10’s Memory Subsystem, from the CPU Side
- [x] AMD’s EPYC 9355P: Inside a 32 Core Zen 5 Server Chip
- [x] Evaluating Uniform Memory Access Mode on AMD’s Turin
- [x] A Look into Intel Xeon 6’s Memory Subsystem
- [x] Strix Halo’s Memory Subsystem: Tackling iGPU Challenges
- [x] Evaluating the Infinity Cache in AMD Strix Halo
- [x] Skymont in Gaming Workloads
- [x] Intel’s Lion Cove P-Core and Gaming Workloads
- [x] Running Gaming Workloads through AMD’s Zen 5

## 第二批：现代核心与前端机制（已完成）

- [x] Zen 5’s AVX-512 Frequency Behavior
- [x] Disabling Zen 5’s Op Cache and Exploring its Clustered Decoder
- [x] Zen 5 Variants and More, Clock for Clock
- [x] Discussing AMD’s Zen 5 at Hot Chips 2024
- [x] Hot Chips 2024: Qualcomm’s Oryon Core
- [x] Intel Details Skymont
- [x] Thoughts on Skymont Slides
- [x] Skymont in Desktop Form: Atom Unleashed
- [x] Analyzing Lion Cove’s Memory Subsystem in Arrow Lake
- [x] Examining Intel’s Arrow Lake, at the System Level

## 第三批：RISC-V 与新兴处理器（已完成）

- [x] A RISC-V Progress Check: Benchmarking P550 and C910
- [x] Condor’s Cuzco RISC-V Core at Hot Chips 2025
- [x] Hot Chips 2023: SiFive’s P870 Takes RISC-V Further
- [x] Hot Chips 2023: Ventana’s Unconventional Veyron V1
- [x] PEZY-SC4s at Hot Chips 2025
- [x] Tachyum’s Revised Prodigy Architecture
- [x] Tachyum: Too Good to be True?
- [x] Everactive’s Self-Powered SoC at Hot Chips 2025
- [x] LLVM’s Ampere1B Commit
- [x] Arm at HC35 (2023): CSS-Genesis

## 第四批：AMD Cache、前端与互连（已完成）

- [x] AMD’s Zen 4, Part 3: System Level Stuff, and iGPU
- [x] AMD’s 7950X3D: Zen 4 Gets VCache
- [x] AMD Disables Zen 4’s Loop Buffer
- [x] Turning off Zen 4’s Op Cache for Curiosity and Giggles
- [x] Pushing AMD’s Infinity Fabric to its Limits
- [x] AMD’s Pre-Zen Interconnect: Testing Trinity’s Northbridge
- [x] AMD’s Magny Cours and HyperTransport Interconnect
- [x] How Zen 2’s Op Cache Affects Performance
- [x] Analyzing Zen 2’s Cinebench R15 Lead
- [x] The Nerfed FPU in PS5’s Zen 2 Cores

## 第五批：Intel Cache、Golden Cove 与功耗（已完成）

- [x] A Preview of Raptor Lake’s Improved L2 Caches
- [x] Alder Lake – E-Cores, Ring Clock, and Hybrid Teething Troubles
- [x] Alder Lake’s Caching and Power Efficiency
- [x] Alder Lake’s Power Efficiency – A Complicated Picture
- [x] Addendum: Clock Ramp on ADL, Zen 4, M1, and More
- [x] Going Armchair Quarterback on Golden Cove’s Caches
- [x] Golden Cove’s Lopsided Vector Register File
- [x] Golden Cove’s Vector Register File: Checking with Official SPR Data
- [x] Was Rocket Lake Power Efficient?
- [x] Broadwell’s eDRAM: VCache before VCache was Cool

## 第六批：Intel 历史核心与 Meteor Lake（已完成）

- [x] Cannon Lake: Intel’s Forgotten Generation
- [x] Intel’s Netburst: Failure is a Foundation for Success
- [x] Intel’s Dunnington: Core 2 Goes Dun Dun Dun
- [x] Knight’s Landing: Atom with AVX-512
- [x] Comparing Crestmonts: No L3 Hurts
- [x] Previewing Meteor Lake at CES
- [x] Update on Meteor Lake DRAM Latency Measurements
- [x] Hot Chips 34 – Intel’s Meteor Lake Chiplets, Compared to AMD’s
- [x] How Quickly do CPUs Change Clock Speeds?
- [x] Details on the Gigabyte Leak

## 第七批：Arm、移动平台与游戏负载（已完成）

- [x] Cortex A73’s Not-So-Infinite Reordering Capacity
- [x] Neoverse N1 vs Zen 2: ARM in Practice
- [x] Graviton 3: First Impressions
- [x] Hot Chips 2023: Arm’s Neoverse V2
- [x] Hot Chips 2023: AMD’s Phoenix SoC
- [x] AMD’s Mild Hybrid Strategy: Ryzen Z1 in ASUS’s ROG Ally
- [x] Van Gogh, AMD’s Steam Deck APU
- [x] ARM or x86? ISA Doesn’t Matter
- [x] Caching Energy Efficiency Data – Mobile and AVX-512
- [x] Hot Chips 2023: Characterizing Gaming Workloads on Zen 4

## 第八批：中国处理器、VIA 与大型系统（已完成）

- [x] Can China’s Loongson Catch Western Designs? Probably Not.
- [x] Loongson’s LSX and LASX Vector Extensions
- [x] Previewing China’s Loongson 3A5000 with Performance Counters
- [x] Running SPEC CPU2017 on Chinese CPUs, and More
- [x] China’s New(ish) SW26010-Pro Supercomputer at SC23
- [x] China’s Phytium D2000: Building on A72?
- [x] The Weird and Wacky World of VIA Part 2: Zhaoxin’s not quite Electric Boogaloo
- [x] Centaur CHA’s Probably Unfinished Dual Socket Implementation
- [x] Examining Centaur CHA’s Die and Implementation Goals
- [x] Core to Core Latency Data on Large Systems

## 第九批：Benchmark、软件行为与 x86 机制（已完成）

- [x] Evaluating SPEC CPU2026
- [x] Evaluating Geekbench 6
- [x] CPU-Z’s Inadequate Benchmark
- [x] Cinebench 2024: Reviewing the Benchmark
- [x] Running SPEC CPU2017 at Chips and Cheese?
- [x] Why You Can’t Trust CPUID
- [x] Investigating Split Locks on x86-64
- [x] Microbenchmarking Chipsets for Giggles
- [x] Is x86 Ready to ACE It?
- [x] Why x86 Doesn’t Need to Die

## 第十批：其余专题（九篇，已完成）

- [x] AMD’s EPYC 7J13: Zen 3 Customized
- [x] Correction for A710/Neoverse N2’s FP Scheduler Layout
- [x] Do IBM’s Giant L3 and V-Cache Represent the Future?
- [x] Embracing AI with Claude’s C Compiler
- [x] Inside Control Data Corporation’s CDC 6600
- [x] Inside the AMD Instinct MI300A’s Giant Memory Subsystem
- [x] Telum II at Hot Chips 2024: Mainframe with a Unique Caching Strategy
- [x] Tracing Intel’s Atom Journey: Goldmont Plus
- [x] Zen 5’s Leaked Slides
