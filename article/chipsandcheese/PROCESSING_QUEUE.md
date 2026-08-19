# Chips and Cheese 微信公众号文章处理清单

更新时间：2026-08-18

清点口径：按 `input/` 中 144 个 HTML 的 canonical URL 去重，再与公众号母稿文首的主来源链接匹配。正文参考资料中出现过某个链接，不等同于该文章已经单独完成。初始待处理 99 篇；第一批已于 2026 年 8 月 18 日完成，现余 89 篇，继续按八个十篇批次和最后一个九篇批次推进。

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

## 第二批：现代核心与前端机制

- [ ] Zen 5’s AVX-512 Frequency Behavior
- [ ] Disabling Zen 5’s Op Cache and Exploring its Clustered Decoder
- [ ] Zen 5 Variants and More, Clock for Clock
- [ ] Discussing AMD’s Zen 5 at Hot Chips 2024
- [ ] Hot Chips 2024: Qualcomm’s Oryon Core
- [ ] Intel Details Skymont
- [ ] Thoughts on Skymont Slides
- [ ] Skymont in Desktop Form: Atom Unleashed
- [ ] Analyzing Lion Cove’s Memory Subsystem in Arrow Lake
- [ ] Examining Intel’s Arrow Lake, at the System Level

## 第三批：RISC-V 与新兴处理器

- [ ] A RISC-V Progress Check: Benchmarking P550 and C910
- [ ] Condor’s Cuzco RISC-V Core at Hot Chips 2025
- [ ] Hot Chips 2023: SiFive’s P870 Takes RISC-V Further
- [ ] Hot Chips 2023: Ventana’s Unconventional Veyron V1
- [ ] PEZY-SC4s at Hot Chips 2025
- [ ] Tachyum’s Revised Prodigy Architecture
- [ ] Tachyum: Too Good to be True?
- [ ] Everactive’s Self-Powered SoC at Hot Chips 2025
- [ ] LLVM’s Ampere1B Commit
- [ ] Arm at HC35 (2023): CSS-Genesis

## 第四批：AMD Cache、前端与互连

- [ ] AMD’s Zen 4, Part 3: System Level Stuff, and iGPU
- [ ] AMD’s 7950X3D: Zen 4 Gets VCache
- [ ] AMD Disables Zen 4’s Loop Buffer
- [ ] Turning off Zen 4’s Op Cache for Curiosity and Giggles
- [ ] Pushing AMD’s Infinity Fabric to its Limits
- [ ] AMD’s Pre-Zen Interconnect: Testing Trinity’s Northbridge
- [ ] AMD’s Magny Cours and HyperTransport Interconnect
- [ ] How Zen 2’s Op Cache Affects Performance
- [ ] Analyzing Zen 2’s Cinebench R15 Lead
- [ ] The Nerfed FPU in PS5’s Zen 2 Cores

## 第五批：Intel Cache、Golden Cove 与功耗

- [ ] A Preview of Raptor Lake’s Improved L2 Caches
- [ ] Alder Lake – E-Cores, Ring Clock, and Hybrid Teething Troubles
- [ ] Alder Lake’s Caching and Power Efficiency
- [ ] Alder Lake’s Power Efficiency – A Complicated Picture
- [ ] Addendum: Clock Ramp on ADL, Zen 4, M1, and More
- [ ] Going Armchair Quarterback on Golden Cove’s Caches
- [ ] Golden Cove’s Lopsided Vector Register File
- [ ] Golden Cove’s Vector Register File: Checking with Official SPR Data
- [ ] Was Rocket Lake Power Efficient?
- [ ] Broadwell’s eDRAM: VCache before VCache was Cool

## 第六批：Intel 历史核心与 Meteor Lake

- [ ] Cannon Lake: Intel’s Forgotten Generation
- [ ] Intel’s Netburst: Failure is a Foundation for Success
- [ ] Intel’s Dunnington: Core 2 Goes Dun Dun Dun
- [ ] Knight’s Landing: Atom with AVX-512
- [ ] Comparing Crestmonts: No L3 Hurts
- [ ] Previewing Meteor Lake at CES
- [ ] Update on Meteor Lake DRAM Latency Measurements
- [ ] Hot Chips 34 – Intel’s Meteor Lake Chiplets, Compared to AMD’s
- [ ] How Quickly do CPUs Change Clock Speeds?
- [ ] Details on the Gigabyte Leak

## 第七批：Arm、移动平台与游戏负载

- [ ] Cortex A73’s Not-So-Infinite Reordering Capacity
- [ ] Neoverse N1 vs Zen 2: ARM in Practice
- [ ] Graviton 3: First Impressions
- [ ] Hot Chips 2023: Arm’s Neoverse V2
- [ ] Hot Chips 2023: AMD’s Phoenix SoC
- [ ] AMD’s Mild Hybrid Strategy: Ryzen Z1 in ASUS’s ROG Ally
- [ ] Van Gogh, AMD’s Steam Deck APU
- [ ] ARM or x86? ISA Doesn’t Matter
- [ ] Caching Energy Efficiency Data – Mobile and AVX-512
- [ ] Hot Chips 2023: Characterizing Gaming Workloads on Zen 4

## 第八批：中国处理器、VIA 与大型系统

- [ ] Can China’s Loongson Catch Western Designs? Probably Not.
- [ ] Loongson’s LSX and LASX Vector Extensions
- [ ] Previewing China’s Loongson 3A5000 with Performance Counters
- [ ] Running SPEC CPU2017 on Chinese CPUs, and More
- [ ] China’s New(ish) SW26010-Pro Supercomputer at SC23
- [ ] China’s Phytium D2000: Building on A72?
- [ ] The Weird and Wacky World of VIA Part 2: Zhaoxin’s not quite Electric Boogaloo
- [ ] Centaur CHA’s Probably Unfinished Dual Socket Implementation
- [ ] Examining Centaur CHA’s Die and Implementation Goals
- [ ] Core to Core Latency Data on Large Systems

## 第九批：Benchmark、软件行为与 x86 机制

- [ ] Evaluating SPEC CPU2026
- [ ] Evaluating Geekbench 6
- [ ] CPU-Z’s Inadequate Benchmark
- [ ] Cinebench 2024: Reviewing the Benchmark
- [ ] Running SPEC CPU2017 at Chips and Cheese?
- [ ] Why You Can’t Trust CPUID
- [ ] Investigating Split Locks on x86-64
- [ ] Microbenchmarking Chipsets for Giggles
- [ ] Is x86 Ready to ACE It?
- [ ] Why x86 Doesn’t Need to Die

## 第十批：其余专题（九篇）

- [ ] AMD’s EPYC 7J13: Zen 3 Customized
- [ ] Correction for A710/Neoverse N2’s FP Scheduler Layout
- [ ] Do IBM’s Giant L3 and V-Cache Represent the Future?
- [ ] Embracing AI with Claude’s C Compiler
- [ ] Inside Control Data Corporation’s CDC 6600
- [ ] Inside the AMD Instinct MI300A’s Giant Memory Subsystem
- [ ] Telum II at Hot Chips 2024: Mainframe with a Unique Caching Strategy
- [ ] Tracing Intel’s Atom Journey: Goldmont Plus
- [ ] Zen 5’s Leaked Slides
