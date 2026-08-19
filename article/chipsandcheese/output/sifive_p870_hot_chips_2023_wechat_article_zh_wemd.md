---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "sifive_p870_hot_chips_2023_wechat_article_zh"
---

> 英文标题：Hot Chips 2023: SiFive’s P870 Takes RISC-V Further
> 撰文：Chester Lam
> 首发：Chips and Cheese，2023 年 9 月 3 日
> 链接：https://chipsandcheese.com/p/hot-chips-2023-sifives-p870-takes-risc-v-further

SiFive 在 Hot Chips 2023 公布的 P870，是一颗面向更高性能区间的 RISC-V 授权核心。其目标大致靠近 Arm Cortex-X2 或 AMD Zen 4c：六宽乱序、较大的重排序资源、解耦分支预测器，以及对 RISC-V 向量扩展的支持。

![图 1：SiFive 在 Hot Chips 2023 展示 P870](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p870_hot_chips_2023_wechat_article_zh/f57b878777676a5c_01_figure.jpg)

## 六宽核心与短流水线

P870 支持大量指令融合，包含非调度队列（non-scheduling queue，也可理解为 dispatch queue），并拥有现代化的向量后端。

![图 2：P870 的高层微架构](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p870_hot_chips_2023_wechat_article_zh/761da50e4be97ffb_02_figure.png)

从官方流水图估算，分支误预测代价约八周期；若 Ex 级发现错误后能从指令缓存查询级直接重启，甚至可能只有七周期。这是基于幻灯片级间关系的推算，不是硅片测量。

![图 3：流水线与可能的误预测恢复路径](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p870_hot_chips_2023_wechat_article_zh/ccd04a932f39a711_03_figure.png)

P870 没有微操作缓存，却仍保持较短流水线。问答环节中 Brad Burgess 表示频率将“有竞争力”，可超过 3 GHz。若实现兑现，这意味着 SiFive 在时序和恢复延迟之间取得了很激进的平衡。

## 分级分支预测

方向预测由八表、总计 16K 项的 TAGE（Tagged Geometric History Length）预测器提供。不同子表覆盖不同历史长度，带标签匹配有助于减少历史混叠；“八表、16K 项”来自公开信息，但各表分配和哈希方式没有披露。

![图 4：TAGE、快速预测器和目标预测资源](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p870_hot_chips_2023_wechat_article_zh/38c3b3ac6fd85dbf_04_figure.png)

预测目标分多级产生：先由 1024 项零气泡预测器给出地址并启动 L1I；TAGE 稍后完成，可用约两周期代价覆盖初始结果；间接分支预测再晚一拍，与译码重叠，覆盖代价约三周期。这个结构与 Zen 4 的 L2 BTB/间接预测覆盖延迟相近。

![图 5：多级预测在 P870 流水线中的位置](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p870_hot_chips_2023_wechat_article_zh/7a9fed70958b4685_05_figure.png)

零气泡容量达到 1024 项，返回地址栈为 64 项，间接预测器约 2.5K 项。64 项 RAS 非常大；作为参照，Zen 系列的 32 项 RAS 已能取得很高返回预测精度。P870 的间接预测容量介于 Zen 3 的 1536 项和 Zen 4 的 3072 项之间。

### 体系结构视角：多级预测是在“快”和“准”之间分工

小而快的层保证连续 taken 分支不打断取指，大而慢的层提升大 footprint 下的覆盖。晚到的正确答案仍要付覆盖气泡，但远小于完整误预测恢复。验证时应把 L0/后级覆盖、方向误预测、间接目标错误和 RAS 错误分别计数，单一总 MPKI 无法说明前端瓶颈。

## 取指、融合与重命名

64 KB L1I 每周期可取 36 B，也就是九条 4 B RISC-V 指令，供给六宽译码。36 B/cycle 经确认不是笔误。iTLB 为 32 项，比 Zen 4 的 64 项小；SiFive 认为足以覆盖目标负载。

P870 支持多种融合，但没有公开具体清单。RISC-V 倾向用简单指令组合表达复杂操作，融合可以把相邻指令在内部合为一个微操作，减少译码、重命名和后端占用；代价是编译器必须把可融合指令排在一起。

![图 6：译码、融合、重命名和后端入口](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p870_hot_chips_2023_wechat_article_zh/64b24d45d374179c_06_figure.png)

译码后，架构寄存器映射到物理寄存器，并分配 ROB、队列等资源。这里的融合能力会直接决定“六宽”能为多少条架构指令提供有效吞吐。

## 大型分布式后端

P870 的 ROB 和寄存器文件容量大致与 Cortex-X 系列、Zen 4 同一量级，但 Load/Store Queue 相对偏小。

![图 7：P870 与当代大核后端容量比较](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p870_hot_chips_2023_wechat_article_zh/08eb955d61dad91b_07_figure.jpg)

其执行布局类似 Cortex-X2：很多小型分布式调度器分别服务执行端口。分布式队列节省全局比较代价，却容易因某一队列填满而让重命名端停顿。P870 在每个执行 cluster 前增加非调度队列，借鉴 Apple Firestorm 的缓冲思路，将全局分配与局部调度压力解耦。

![图 8：非调度队列与六个执行端口](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p870_hot_chips_2023_wechat_article_zh/192dc1c7a7dc3123_08_figure.png)

六个端口各有独立调度队列；其中一个分支端口还可执行普通 ALU 操作，因此比固定的专用分支端口更灵活。

### 体系结构视角：队列总容量不等于可用窗口

在分布式后端中，一条指令只能进入特定队列并访问特定端口。即使总空位很多，目标队列满仍会反压 Rename。非调度队列可吸收短时不平衡，却不能消除长期端口热点。定向微基准需要分别构造 ALU、分支、AGU 和混合依赖链，观察吞吐拐点与分配停顿。

## 浮点与 RISC-V Vector

两个 FP 端口覆盖常用操作，FP Add 和 FP Mul 都宣称只有两周期延迟。

![图 9：浮点执行端口和延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p870_hot_chips_2023_wechat_article_zh/c0628ec5fd1fb0ba_09_figure.png)

幻灯片暗示 FP 与向量使用独立物理寄存器文件：两者重命名容量不同且并非整数倍。若确实如此，分离可以减少单个寄存器阵列所需端口，降低面积与功耗；但这仍是根据图表的解释。

![图 10：两条 128 bit 向量流水线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p870_hot_chips_2023_wechat_article_zh/780b30b11f314ece_10_figure.png)

向量后端为 2×128-bit，吞吐并不强，却是 RISC-V 实现的重要进步；它大致接近 Neoverse N1/N2，而 Veyron V1 甚至没有向量执行能力。

RISC-V Vector 的 LMUL 可让一条指令操作连续多组向量寄存器。若在译码时直接拆分，LMUL>1 会大量消耗译码和重命名带宽。

![图 11：LMUL 将一条向量操作扩展到多组寄存器](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p870_hot_chips_2023_wechat_article_zh/bc098926fe94340a_11_figure.png)

P870 因此把拆分推迟到向量 sequencer：LMUL=2 的指令在前端只占一个译码槽，之后才变成多个调度项，按所需周期发射。

![图 12：向量 sequencer 与独立向量重命名](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p870_hot_chips_2023_wechat_article_zh/f95ba556e87e98d9_12_figure.png)

从流水图看，sequencer 最快一周期完成拆分，后面还有独立向量 Rename，因此物理寄存器是在拆分后分配。LMUL 在实际软件中的收益仍要等待编译器与工作负载验证。

## Load/Store、TLB 与缓存

三条地址生成管线中，两条可 Load/Store，一条仅 Load，与 Cortex-X2、A710、Zen 4 相似。L1D Load-to-use 为四周期：地址生成、Tag 和数据访问占三拍，另有一拍 Drv 搬运。

![图 13：L1D 访问的四周期路径](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p870_hot_chips_2023_wechat_article_zh/b4504520a2adc9d3_13_figure.png)

这额外一拍令人好奇；未来版本理论上可能压到三周期，但不能据此断言现有设计有无优化空间。64 项 DTLB 由 1024 项 L2 TLB 支持，后者在今天偏小，但与 Cortex-A710 接近。

![图 14：TLB 与 Load/Store 资源](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p870_hot_chips_2023_wechat_article_zh/7e2c428cf4b14cac_14_figure.png)

L1D miss 进入共享、非包含式 L2。L2 分 bank 支撑多核并发，延迟 16 周期；容量由客户配置，展示示例为 4 MB。L2 complex 还维护 snoop filter 跟踪私有缓存，描述上类似 Cortex-A72 的一致性过滤方案。

![图 15：共享分 Bank L2 与多核组织](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p870_hot_chips_2023_wechat_article_zh/1e9107fb18ddfede_15_figure.jpg)

跨 cluster 共享 L3，容量和延迟取决于 SoC 实现；SiFive 的性能估算采用 16 MB 配置。因此 L3 和 DRAM 结果不能被归为 P870 核心 IP 的固定属性。

## 可靠性版本 P870-A

汽车版 P870-A 为缓存和寄存器文件提供 ECC/Parity，并强化缓存控制器与互连可靠性。具体实现没有披露，可能包括队列和链路保护，但不能将类比写成确认设计。

![图 16：P870-A 与其他处理器的错误检测、恢复机制比较](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p870_hot_chips_2023_wechat_article_zh/2d684488c6961f5d_16_figure.jpg)

![图 17：P870-A 的可靠性覆盖范围](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p870_hot_chips_2023_wechat_article_zh/5fce9a98ed18ae63_17_figure.png)

P870 还可成对锁步执行。两核从确定的复位状态出发执行相同计算，随机位翻转不太可能同样影响两者；代价是大致用双倍核心资源换取一份有效吞吐。

## 结语

![图 18：RISC-V 高性能核心的演进位置](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p870_hot_chips_2023_wechat_article_zh/2fd6afa73668d79e_18_figure.png)

Arm 从 2007 年 Cortex-A9 起花了多年进入高性能市场；RISC-V 起步更晚，但从 BOOM 到 P870 的增长很快。P870 在宽度、ROB 和执行资源上已接近 Cortex-X 大核，短板主要是偏小的 Load/Store 队列与较弱的向量吞吐。

![图 19：SiFive 与 Arm 类似的可授权 IP 产品组合](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p870_hot_chips_2023_wechat_article_zh/abe7e60e961da862_19_figure.png)

真正难点将转向落地与生态：客户要把 IP 做成高频、低延迟的芯片，编译器还要稳定制造融合机会，向量库则需普及 RVV。Hot Chips 展示的是设计能力与目标，并不等于量产性能；但 P870 已清楚表明 SiFive 希望进入 Arm 的高性能授权市场。

## 参考资料

- SiFive Hot Chips 2023 P870 演讲
- Chips and Cheese：Hot Chips 2023: SiFive’s P870 Takes RISC-V Further
