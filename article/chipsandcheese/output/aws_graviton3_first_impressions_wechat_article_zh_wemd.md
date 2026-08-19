---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "aws_graviton3_first_impressions_wechat_article_zh"
---

> 英文标题：Graviton 3: First Impressions
> 撰文：George Cozma、Chester Lam
> 首发：Chips and Cheese，2022 年 5 月 29 日
> 链接：https://chipsandcheese.com/p/graviton-3-first-impressions

AWS 在 2022 年 5 月公开 Graviton 3，它是首款广泛可用、支持 SVE 的通用 Arm Server CPU。此前 Graviton 2 和 Ampere Altra 都以 Neoverse N1 为主：前者 64 核 2.5 GHz，后者最多 80 核 3 GHz。本文用 N1、Zen 3 Milan 和 Ice Lake-SP/Sunny Cove 作参照；The Next Platform 的分析认为 Graviton 3 可能基于修改版 Neoverse V1，但 AWS 未公开全部实现细节。

![图 1：Graviton 3 与 V1 关系及系统概览](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/240f7d52f48f7da0_01_figure.png)

## 分支预测：从 N1 的弱项变成强项

模式识别测试显示，Graviton 3 与 N1 已不是同一档。

![图 2：Graviton 3 的单 Branch Pattern 识别](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/be7a79fe037bcce0_02_figure.png)

![图 3：Graviton 3 与 N1 的模式容量细节](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/bf716081db710764_03_figure.jpg)

Zen 3 像是用稍慢、但极强的后级覆盖初级结果；Ice Lake 与 Graviton 3 更像单层长历史方案。这里是根据曲线作出的行为分类，不能据此确定算法。

![图 4：与 Ice Lake、Zen 3 的方向模式比较](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/be7a79fe037bcce0_04_figure.png)

![图 5：不同历史长度下的误预测拐点](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/5598c9c51b0548b4_05_figure.jpg)

同时存在 512 个 Branch 时，Graviton 3 能记长度约 16 的 Pattern，Ice Lake 约 32，Zen 3 约 96。

![图 6：多 Branch 条件下的 Pattern Capacity](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/be7a79fe037bcce0_06_figure.png)

![图 7：512 Branch 时三种预测器的对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/da06779dd2843df5_07_figure.jpg)

目标侧同样激进。Micro-BTB 可每拍处理两个 Taken Branch；当时只有 Golden Cove、Rocket Lake 也测出过该能力，而且它们的相应容量约 32 项和 8 项，Graviton 3 更大。

![图 8：Micro-BTB 双 Taken/cycle 的容量区间](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/2915efaffec8d610_08_figure.png)

主 BTB 可能约 4K 项，L2 BTB 或达 10K。主 BTB 的 Zero-bubble Capacity 超过 Zen 3；即使 10K Branch 落到 L2，每 Branch 只约 1～2 个气泡。除 Golden Cove 外，当时很少看到更大目标容量。

![图 9：不同 BTB Footprint 下的 Taken 吞吐](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/e701cd4f77b14374_09_figure.png)

### 体系结构视角：大窗口必须由大预测器喂养

ROB 增大只能让核心跨越更长延迟；若方向/目标常错，窗口装的是错误路径，反而浪费更多能量。Graviton 3 同时增加方向历史、BTB 容量与目标吞吐，正是让后续 512 项级窗口有意义。微基准拐点仍受 Hash/Aliasing 影响，不等于公开表项数。

## 四宽 Decode，六宽 Micro-op Path

Graviton 2/3 都是四宽 Decoder，但 Graviton 3 加入约 3K 项 Micro-op Cache，整体形态接近 AMD/Intel。

![图 10：Decode、Micro-op Cache 与 Rename 前端](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/90bcfc59ff833e0b_10_figure.png)

Decoder 支持 Flag-setting Instruction+Conditional Jump 融合，也会把成对 NOP 融合。缓存融合结果后，NOP 测试可达荒诞的 12 IPC，破坏常规取指带宽测法。

![图 11：NOP Fusion 导致的 12 IPC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/e6fe6b41edfac517_11_figure.png)

改用“Register 清零”指令后，它们不能像 NOP 成对融合，却可在 Rename 以六条/cycle 消除。Micro-op Cache 内 Graviton 3 与 Zen 3 都可持续约 6 IPC；走 L1I Decoder 则不超过四条，说明 AWS 的 V1 变体可能把常见说法中的五宽 Decode 缩为四宽。大代码区下 Zen 3 的 L3 更快，Graviton 3 仍优于 N1，可能还得益于更深 Fetch Queue、大 BTB 预取和更低 L3 延迟。

![图 12：不同代码 Footprint 的取指吞吐](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/00434f3d52b7ed5e_12_figure.png)

## Rename 优化与物理资源

Rename 看来为六宽。它不能像 Zen 3/Sunny Cove 那样按 Rename Width 消除 Register-to-register MOV，吞吐仍受 ALU 端口限制；偶尔能断开 MOV 依赖，但能力有限。

![图 13：MOV 与 Zeroing Idiom 的吞吐](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/724918c0893a93e4_13_figure.jpg)

把 0 写 Register 的指令可被完全消除，达到六条/cycle。Ice Lake 只能断依赖而不能消除，Zen 3 则有同等 Zeroing Elimination。

常规 NOP 测试暗示 512 项 ROB，但可能只是每项存两个融合 NOP。交替 Integer/FP 的测试仍超过 256，因此更支持 ROB 实际有 512 项的解释，以及融合 NOP 在 Rename 后重新展开；解释尚未完全确认。

![图 14：ROB 容量测试与 256/512 两种解释](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/5f46115745a460dc_14_figure.png)

Vector PRF 看来有约 125 个 256 bit Register，可用一个 Entry 跟踪两个 Scalar FP，却不能同样容纳两个 128 bit NEON Result。

![图 15：Scalar FP、NEON、SVE 的 Register Capacity](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/eccd99e45b048342_15_figure.png)

除巨大的 Scalar FP Rename Capacity 外，PRF 更像为 256 项 ROB 配置；Load Queue 则异常大，其他队列大致接近 Zen 2/3。

![图 16：ROB、PRF、Load/Store Queue 容量对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/734e9bc2899c3d9a_16_figure.png)

分布式 Scheduler 很难反推，作者只给几类指令的近似容量。

![图 17：Scheduler Capacity 的多组定向测试](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/0c5298a296c27e4a_17_figure.png)

![图 18：常见操作可用的 Scheduler Entry](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/19d9ecc808e7a101_18_figure.jpg)

整体明显大于 N1，并与 Zen 3/Ice Lake 常见操作资源相近。

![图 19：一种可能的 Scheduler 拓扑](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/a2217ce09c070fa6_19_figure.png)

图 19 只是能解释测量的候选布局，不是官方框图。

## 执行：四 ALU、三 Memory Pipe、256 bit SVE

整数 ALU 从 N1 的三条增至四条，Memory Pipe 从两条增至三条。FP/Vector 像把 N1 资源翻倍，以大型统一 Scheduler 供给；256 bit SVE FP Add/Mul 各可每拍两条，达到 AVX 级吞吐。

![图 20：常见 Scalar/Vector 操作延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/7970c4774101feba_20_figure.jpg)

FP Add 两周期，与 Golden Cove 相当；较低 2.6 GHz 使时序更容易。Mul 与其他 Server Core 接近，Vector Integer 略高于 Zen 3。

吞吐现象支持四条 128 bit FP/Vector Pipe，因为所有被测 256 bit SVE 操作都能超过一条/cycle；但 NEON FP Add/Mul 与 Integer Add 未超过三条/cycle，可能受 Register File Input Bandwidth 限制。

![图 21：NEON/SVE 执行吞吐与潜在 RF 限制](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/d20bf0c68bf1fca5_21_figure.jpg)

此处仍需要更多测试。

## Cache Latency：周期改善，纳秒仍受低频影响

L1D 仍是 64 KB、四周期；L2 容量不变、延迟降两周期；Altra 极差的 L3 延迟在 Graviton 3 上显著改善。

![图 22：按周期计的 Cache/Memory Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/40f978e3ddf2db56_22_figure.png)

Graviton 2 与 Altra 同为 N1/L2，主要差别在 Mesh/L3；Graviton 2 的较小 Mesh 略好。

![图 23：折算为 ns 的 Graviton 2/3 与 Altra 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/ee45dae434b7fcec_23_figure.png)

Graviton 3 DRAM 反而更慢，可能来自 DDR5 固有延迟与独立 I/O Chiplet Memory Controller。它和 Ice Lake 都采用 Chip-wide Unified L3，并以大私有 L2 隔离 Mesh 延迟；AMD 则给每个 Core Cluster 更快、但非全芯片统一的 L3。

![图 24：三种 Server Cache Strategy](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/fe3628ff64886075_24_figure.png)

Zen 3 与 Sunny Cove 还要服务 Client，可在 4 GHz 以上；Milan/Ice Lake 云实例的频率明显高于 Graviton 3。按纳秒看，低频让 Arm 的周期优势缩小。

![图 25：以实际时间比较 L1、L2、L3 与 DRAM](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/cb2fd6808d6bb19a_25_figure.png)

Ice Lake 约 3.5 GHz、EPYC 约 3.23 GHz（由 Register Add Latency 推断）。其小而快 L1/L2 在纳秒上领先；Intel/Arm Mesh L3 接近，AMD Cluster L3 很快。Graviton 3 与 EPYC 的 DRAM 访问同样都要跨 Chiplet，AMD DRAM 仍约低 10 ns，文章倾向归因于 DDR4/DDR5 差异。

## Bandwidth：SVE 与 DDR5 的价值

匹配核心数时，Graviton 3 各级 Cache 均比 Altra 高；使用 SVE 时 L1/L2 大幅拉开，NEON 下 Altra 靠 3 GHz 还能接近。

![图 26：Graviton 3 与 Altra 的 Cache Bandwidth](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/2ceb9e6ed8d70bac_26_figure.png)

x86 对手依靠高频与同/更宽 Vector 仍更强；Ice Lake 的 512 bit 和 64 B/cycle L2 尤其突出。256 bit SVE 能缩小差距，不能消除频率差。

![图 27：Graviton 3、Zen 3、Ice Lake 的每核带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/430f6b75af67f11e_27_figure.png)

DDR5 的高延迟换来高带宽，Graviton 3 在 Memory Bandwidth 明显领先。

![图 28：整芯片可获得数据下的层级带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/aws_graviton3_first_impressions_wechat_article_zh/6f1c5987b7baeb2e_28_figure.png)

与 V-Cache EPYC 比，Graviton 3 领先 L1/L2/DRAM；AMD 巨大且低延迟的 L3 在一段工作集内反超。整机样本有限，不能作全产品线排名。

### 体系结构视角：周期、纳秒与 Byte/cycle 要同时看

低频核心能用较少 Pipeline Stage 得到低 Cycle Latency，却未必有更低 ns；Bandwidth 也同时等于每拍位宽与频率。SVE 把每条 Load 扩到 256 bit，减少 Address Generation/Retire 次数，但软件不用 SVE 时该能力不存在。

## SVE 与 AWS 的密度选择

Graviton 3 是首个通用、广泛可用的 SVE Server；A64FX 更早但专为超算。短期优势有限：当时软件几乎没有 SVE，GCC 甚至在作者经验中拒绝生成，测试用 Clang 汇编。其处境类似 2017 年 AVX-512；SVE2 已发布，若未来软件直接要求 SVE2，Graviton 3 的初代 SVE 还可能被绕过。

按预测、窗口、执行资源和宽度，Graviton 3 已进入 Zen 3/Ice Lake 同一大区间，但 2.6 GHz 与对手相差很大，也未以更庞大的核心规模弥补频率差距。

AWS 的目标是 Cloud Compute Density。2.6 GHz 仅比 Graviton 2 高 100 MHz，核心数不增，性能提升几乎全来自 IPC；TSMC 5 nm 用于降低功耗，而不是冲高频。中等规模核心在低频下可让一个 Node 放三颗芯片，以更低单核售价提供比 Graviton 2 更强性能。

## 结语

这是一篇“初探”，Scheduler、ROB 展开、Vector Register 复用与 Pipe 数都保留候选解释。最牢靠的结论是：Graviton 3 的 BPU、Micro-op Frontend、重排窗口、Vector 和 Cache 层级相对 N1 全面升级；低频与软件 SVE Adoption 则限制其即时优势。它不是靠 Arm ISA 自动变快，而是 AWS 用工艺、微架构和云密度目标做出的系统性取舍。

## 参考资料

- Chips and Cheese：Graviton 3: First Impressions
- AWS Graviton 3、Arm Neoverse V1 与 The Next Platform 相关资料
