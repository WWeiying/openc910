---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "zhaoxin_via_part2_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*The Weird and Wacky World of VIA Part 2: Zhaoxin’s not quite Electric Boogaloo*
> - 撰文：George Cozma、Chester Lam
> - 首发：Chips and Cheese
> - 发布：2021 年 9 月 22 日
> - 链接：https://chipsandcheese.com/p/the-weird-and-wacky-world-of-via-part-2-zhaoxins-not-quite-electric-boogaloo

上一篇讨论了 VIA 这条第三家 x86 设计路线及 Isaiah；这一篇转向 VIA 与上海市政府相关方于 2013 年合资成立的兆芯。张江基本是在 Isaiah II 上加入 SM3/SM4 PadLock；五道口宣称同频提高 25%。陆家嘴又宣称较五道口最高快 50%，但频率也最高提高 50%，因此文章怀疑它更多是把 28 nm 设计移到 TSMC 16 nm 后提频，而非同等幅度的架构升级。

![图 1：VIA—兆芯核心世代](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/35c50ac8ba09fb97_01_figure.png)

*图 1：历史与命名背景。*

## Cache：L1 减半，共享 L2 延迟升到 48 周期

![图 2：Isaiah 与陆家嘴的 Cache 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/c338870274625e7f_02_figure.jpg)

*图 2：复杂 Address Generation 测得两者 L1 都是 5-cycle；VIA 文档称其 L1 为 2-cycle，额外三周期可能来自寻址。文章推测陆家嘴本体为 4-cycle，复杂寻址再加 1-cycle，但测试无法拆开。*

L1 从 Isaiah 的 64 KB 降到 32 KB，节省功耗和面积，却降低 Hit Rate。四核 Cluster 共享 4 MB L2，取代每核私有 1 MB，与 Zen 1/2 APU 的 LLC 组织相似；但 L2 从 20 周期升到惊人的 48 周期。Zen 1 的 8 MB L3 约为 35 周期且频率更高。兆芯/VIA 宣称 KX-6000 可对标 Skylake，Tom's Hardware Review 并不支持这一说法。

![图 3：多核 Cache Bandwidth](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/b0701da3d734992a_03_figure.jpg)

*图 3：每核从 L2 连 8 B/cycle 都难维持。*

![图 4：单线程 Cache Bandwidth](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/33228b8ac0713db7_04_figure.jpg)

*图 4：即使与不做全宽 AVX 的 CPU 比也不突出。*

Memory Controller 从 FSB 移到 Die 内，降低 DRAM 延迟；Cluster 内 Interconnect 的 Cacheline Ping-pong 尚算合理。

![图 5：陆家嘴 Core-to-core Atomic Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/bea6fa4c1e87cc99_05_figure.png)

*图 5：反映 Coherence Ownership Transfer，不等同于普通 L3/内存访问。*

## Branch Predictor：16 项 L0 BTB 很快，后面仍是老 Isaiah

![图 6：Isaiah 与陆家嘴 BTB 层级](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/b1a002b3e548aed2_06_figure.png)

*图 6：新增 16-entry L0 BTB 可 Zero-bubble；4096-entry Main BTB 与 Isaiah 相似，提供 Target 会产生两个 Bubble，BTB miss 则略快于 Isaiah。Zen 2 也有小而快层级，可覆盖约一半 Branch。*

![图 7：陆家嘴方向预测 Pattern Length](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/f9aabf685dbec387_07_figure.jpg)

*图 7：长 Pattern 能力变化不大。*

![图 8：Isaiah 的对应结果](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/fa69c29e2b4dfbcc_08_figure.jpg)

*图 8：2008 年低功耗核心里很先进，十年后已平庸。*

![图 9：Zen/Skylake 的长 History 对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/cb3f6ae287333fed_09_figure.jpg)

*图 9：同期高性能核心识别更长 Pattern。*

![图 10：Cortex-A75 对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/2ce55479497ae579_10_figure.jpg)

*图 10：低功耗手机 A75 的 Predictor 更接近陆家嘴，再次说明其目标不是大核。*

Call/Return 更怪：可能有仅 2-entry 的快速 L1 Return Stack，另有约 34-entry L2；PMU 只在深度超过 34 后报告 Mispredict。

![图 11：Return Depth 与延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/8489a5e90cf4a020_11_figure.jpg)

*图 11：L2 Return 命中需 5～6 ns，即 2.6 GHz 下的 13～16 周期，几乎像 Haswell RAS Overflow。深调用即使预测正确也很慢。容量和层级来自行为反推。*

### 体系结构视角：预测器的“命中”也可能太慢

Direction 正确不代表前端无气泡。Target 若来自慢 BTB/RAS，仍要等 Redirect；小 L0 只覆盖最热 Branch。验证要分别测 Accuracy、Taken Throughput、每层 Capacity/Latency 与 Return Nesting，而不是把所有损失都归为 Mispredict。

## 核心变窄：三宽变两宽，为八核密度服务

Decoder 从 Isaiah 三宽缩到两宽，Rename/Retire 也似乎为两宽；一半指令 Decode 成两个 Uop 的测试只有 1.5 IPC、约 2 Uop/cycle。降宽通常换取频率、功耗或面积优势；五道口在 28 nm 下与 Isaiah 同为 2 GHz，所以纯提频解释不足。更合理的是用小核做八核，类似 A73 从 A72 三宽缩为两宽以提升能效。

## ROB/RF：65 项退到 48 项，但 Not-taken Branch 可旁路

Integer/FP Register-writing 指令都被 48-entry ROB 限制，似乎丢掉 Isaiah 分离 PRF，回到 P6 式 ROB + Retirement Register File（RRF），Integer/FP 共享存储。它可能更省 Bit 与更简单，却不是现代大核常见选择。

![图 12：Isaiah 的 PRF 组织](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/6e9042099d6c15e3_12_figure.jpg)

*图 12：旧设计的解耦 Register File。*

![图 13：陆家嘴 P6-style ROB+RRF 推断](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/fd802e58d8887f3f_13_figure.jpg)

*图 13：来自 Capacity 混合测试，不是公开 RTL。*

一个有趣优化是 Not-taken Branch 不占常规限制：两次 Long-latency Load 之间可放 64 个 `cmp+je` Pair，即 128 条在途，而普通组合最多 48 条。Cinebench R20/CoD Vanguard 中 Not-taken Branch 约占 5%/7%，因此有效窗口略大；未找到其他绕过项。

## Scheduler 与 Execution Port：重平衡，而非全面放大

Integer Queue 略增，ALU 可用项比 Nano 多一项。

![图 14：Integer Scheduler Capacity](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/ff805ca3e04f0c8c_14_figure.jpg)

*图 14：改动偏向常见 Scalar Integer。*

Load Scheduler 增至 12 项，Store Scheduler 增至 20 项；相对 Isaiah 分别约增加 7 项和 4 项。

![图 15：Load Scheduler](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/0d4012b2e93f6516_15_figure.png)

*图 15：Load 需求通常更多。*

![图 16：Store Scheduler](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/e272cadc6c4e28a0_16_figure.jpg)

*图 16：两边都扩大。*

FP Multiply/Add Scheduler 改成各 12 项，取代 Nano 的 8+24 不平衡配置。

![图 17：FP/SIMD Scheduler](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/ebd2f3c73b7e9d6a_17_figure.jpg)

*图 17：总量略减但更均衡。*

两宽限制让 Port Mapping 难测，文章以“能否同周期起发”和“是否共享 Scheduler”复原。Integer 仍有两条 ALU；16-bit `IMUL` 延迟 2 周期，64-bit 为 9 周期且走不同 Queue。新增第二条 128-bit Vector Integer ALU 和第二条 Load Pipe，L1D 每周期可完成两次 128-bit Load；FP Throughput 未变，FP Add 反从 Isaiah 的 2-cycle 退到 3-cycle。

## AVX：兼容性有了，性能上却不值得使用

256-bit AVX 拆成两个 128-bit Uop，占两个 Scheduler Entry；核心正好为 2 Uop-wide，所以相对 SSE 没有吞吐收益。

![图 18：AVX/SSE 吞吐](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/046525982441fae2_18_figure.png)

*图 18：Code Density 是理论剩余收益。*

![图 19：256-bit FP 的 Reorder Capacity](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/fd802e58d8887f3f_19_figure.jpg)

*图 19：容量降到一半以下。*

![图 20：AVX 对 ROB/RF 的异常占用](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/05952f7450c744d3_20_figure.png)

*图 20：似乎每条 256-bit AVX 消耗超过两个 Slot。*

![图 21：AMD K10 小 ROB 的 Stall 背景](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/4cb09c6099d2073a_21_figure.png)

*图 21：K10 有 72-entry ROB 尚常因满停顿，陆家嘴 48 项更敏感。*

![图 22：128/256-bit 执行延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/df1e2936f9f59f2e_22_figure.jpg)

*图 22：256-bit 还有额外延迟。Piledriver/Zen 1 同样拆 Uop，却保持相同延迟且只付预期两 Uop 资源；陆家嘴的 Code Density 好处被延迟+窗口缩水抵消。*

## Load/Store：Queue 扩大，仍无 Memory Dependence Prediction

Load/Store Queue 从 Isaiah 16/16 增至 24/22，是明确代际提升。

![图 23：LSQ Capacity](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/778247c0d7b6a36e_23_figure.jpg)

*图 23：但年轻 Load 仍不能越过地址未知的老 Store；这项 Core 2 已有的预测能力在现代大核很普遍。*

![图 24：陆家嘴近似 Core Block Diagram](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/169d292e50e26fa1_24_figure.png)

*图 24：汇总 Cache、BPU、两宽前端、48 项 ROB/RRF、Scheduler 与 Port，均是实测复原。*

## 附录：进一步验证奇怪的 ROB/AVX 行为

![图 25：Integer+AVX 混合 Capacity](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/ef77d1d257a7f08b_25_figure.jpg)

*图 25：混合后没有得到两份 RF Capacity，反而竞争同一存储；一条被 Long Load 阻塞的 256-bit AVX 后只能再放 45 条 Integer Add。*

只要 YMM 中存在 256-bit State，即使没有 AVX 指令待 Retirement，接近 48 项前也会出现可重复的延迟 Spike，说明回收逻辑受 State 影响。

![图 26：不同指令寻找超过48项窗口](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/5da2c0d033703d9d_26_figure.png)

*图 26：仅 Not-taken Branch 成功。*

![图 27：Taken Branch Retirement Capacity](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/c5eea08cd98e3393_27_figure.jpg)

*图 27：约 20 条 Taken Branch 后，Frontend 被 Backend 阻塞。*

16/32-bit Multiply 的窗口还随 Operand Value 变化，可能在 Scheduler 满时消除乘 1 等 Operation。

![图 28：Operand-dependent Multiply Capacity](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/5eaca36e0e468384_28_figure.jpg)

*图 28：说明可能存在 Value-based Elimination，但未用 RTL 确认。*

官方只称 AVX、不称 AVX2：FMA 会触发异常，但 256-bit Integer Instruction 能正确执行并拆成两条 128-bit Uop。

![图 29：可执行的部分 AVX2 Integer](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/96b28ebd9d35a933_29_figure.jpg)

*图 29：256-bit Packed Integer Multiply 不比 128-bit 多延迟。*

![图 30：Integer 与 FP 256-bit 的窗口差异](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/8661038e035665f4_30_figure.jpg)

*图 30：Integer Add 对 Reorder Capacity 的损伤小得多，Zen 1 则不区分数据类型。*

![图 31：256-bit Integer Scheduler Capacity](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/6b9f2ec7f6a0d391_31_figure.jpg)

*图 31：两条 128-bit Integer Port 各有 Queue，因此 Integer Vector 反而获得更多调度容量；可能做得不错，却因缺 FMA 等无法正式暴露完整 AVX2。*

FP Scheduler 测试要给指令建立对 Long Load 的 Dependency。若用 `cvtsi2ss`，转换本身可能占 Scheduler；文章主要让 Load Result 索引另一个 FP Array，并读最后一次 Latency Jump。

![图 32：FP Scheduler 微基准依赖链](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/zhaoxin_via_part2_wechat_article_zh/e547b214a8aaf02d_32_figure.jpg)

*图 32：最低平台仅受 Memory Latency/ILP 影响，随后 Scheduler 填满，让 OoO 能看到的 Ready Load 变少；Zen 2 的 96～100“项”无法区分 36 项 Scheduler 与 64 项 NSQ。*

## 结语

五道口/陆家嘴不是简单换皮 Isaiah，而是裁剪、重平衡 Nano：降宽、缩 ROB、共享慢 L2 来换八核密度和频率，同时扩大 LSQ、加快热 Branch、增强 128-bit Integer/Load。兆芯宣称同频提高 25% 并非全无依据；但十年只有这个量级，且 AVX、Predictor、Cache、窗口都偏低功耗路线，合理对手更像 Jaguar/Goldmont，而非 Skylake/Zen 2。

## 参考资料

- George Cozma, *The Weird and Wacky World of VIA Part 2*, Chips and Cheese, 2021-09-22
- VIA Isaiah/Nano 与兆芯 KX-6000 公开资料
- Tom's Hardware KX-U6780A Review；Arm Cortex-A75、AMD Zen 对照
