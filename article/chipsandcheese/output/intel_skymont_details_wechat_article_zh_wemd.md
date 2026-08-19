---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "intel_skymont_details_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Intel Details Skymont*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2024 年 6 月 15 日
> - 链接：https://chipsandcheese.com/p/intel-details-skymont

Skymont 仍属于 Intel E-Core，却已经很难用“低功耗小核”概括。它把三组 3-wide Decoder、8-wide Rename、16-wide Retire、416 项 ROB、26 个执行端口、4×128-bit FP/向量执行和 4K 项 L2 TLB 放在同一颗核心里。目标不是只提高低负载能效，而是让低功耗岛能够承接更广泛应用，同时继续提供高密度多线程吞吐。

![图 1：Intel 对 Skymont 的总体介绍](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_details_wechat_article_zh/f667d2980cbc0086_01_figure.jpg)

*图 1：以下结构来自 Intel 正式演讲与访谈；与早期低清幻灯片推测不同，关键宽度和容量已有公开依据。*

## 一、三组 3-wide Decoder 为什么适合 x86

Tremont 以来，Atom 前端使用成组的取指/译码路径。每组从 L1I 取 32 B/cycle、译码三条指令。Skymont 增加第三组，因此峰值为 96 B/cycle、9 条指令/周期。

![图 2：Skymont 三集群前端](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_details_wechat_article_zh/162de1be5258a39d_02_figure.png)

Lead Architect Stephen Robinson 把它称为一项“统计下注”：x86 平均约每六条指令一个分支、每十二条一个 Taken Branch。三组 3-wide 比两组 4-wide 晶体管更多，却更容易分别填满，也更灵活地跨越多个基本块。

每组 Decoder 后有 32 项微操作队列，合计 96 项；Decoder 前的指令字节队列比 Crestmont 增加 50%，但绝对容量未公开。队列让前端在后端短暂停顿时继续前跑，并在指令 Cache Miss 或慢分支发生前积累缓冲。Redwood Cove 的 192 项微操作队列仍更大，双 SMT 时拆成两份 96 项。

Crestmont 已能每周期检查 128 Byte 范围内的 Taken Branch，但只有起始地址按 128 B 对齐时达到峰值。Skymont 改为从 64 B Cache Line 对齐出发，无论起点是否 128 B 对齐，都能同时扫描两个 Cache Line。

![图 3：Skymont 的两 Cache Line 分支扫描](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_details_wechat_article_zh/5d6c442d3bd8ded0_03_figure.png)

*图 3：更灵活的 128 B 预测窗口让预测器更早隐藏 BTB 延迟、发起 L1I Fill；它不代表单周期一定能从任意位置交付 128 B 有效指令。*

### 体系结构视角：集群译码是在绕开 Taken Branch 的槽位浪费

单个 8-wide Block 若前几条就遇到 Taken，后半槽位会浪费。多个较窄 Cluster 可以从不同预测基本块并行取指，代价是预测器必须给出多目标、各流还要按序合并。Skymont 用三组 3-wide 匹配 x86 的统计分支密度，而不是把“9-wide”当成一个连续基本块的理想宽度。

## 二、Nanocode：把常用复杂指令的微码复制三份

Atom 为节省面积，对复杂指令较依赖 Microcode ROM。读取共享 ROM 会阻塞并行译码；Tremont 可让另一集群继续处理简单指令，但两组不能同时访问微码。

![图 4：传统 Atom 的共享微码路径](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_details_wechat_article_zh/d28fc912a5091328_04_figure.jpg)

Skymont 把 Gather 等最常见复杂指令的微码复制到每个 Cluster，Intel 称之为 Nanocode。三组可以独立处理这些指令；罕见复杂指令仍可能走共享 Microcode ROM，以控制容量。

![图 5：三集群 Nanocode](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_details_wechat_article_zh/0be004f9c956bb21_05_figure.png)

![图 6：Skymont 与大核复杂译码策略对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_details_wechat_article_zh/db591b7e002ca824_06_figure.png)

*图 6：Intel P-Core 和 Apple 高性能核更倾向于给常见复杂指令配置能一次产生多个微操作的 Decoder，从源头减少微码使用；Skymont 则复制常见微码。两者是不同面积预算下的实现选择。*

## 三、8-wide 进入、16-wide 退休：用出口宽度换队列容量

Skymont 每周期可 Rename/Allocate 八条微操作。退休却从 Crestmont 的 8-wide 加倍到 16-wide，看似失衡。Intel 的理由是：更快释放 ROB、物理寄存器、Queue 等资源，可以把这些昂贵结构做得稍小；过度配置顺序退休逻辑，比把所有乱序资源继续扩大更便宜。

![图 7：Skymont 后端宽度与资源](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_details_wechat_article_zh/fd1eaeca2c5b0dd9_07_figure.jpg)

宽退休并非首次出现。Zen 长期采用 5-wide Rename、8-wide Retire；Skylake 的后端入口四条，但双 SMT 线程也能在合适条件下提供更高聚合退休。Rename 必须处理同周期内“前一条产生的新映射被后一条消费”，比单纯提交多个已完成 Entry 更难扩宽。

![图 8：重命名数据依赖与宽退休](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_details_wechat_article_zh/f6b30c4ad3b133b8_08_figure.jpg)

ROB 从 Crestmont 的 256 项增至 416 项，物理寄存器、Load/Store Queue 和其他资源同步扩大。执行端口达到 26 个。Intel 认为专用端口更节能；8 个整数 ALU 则“面积便宜，能帮助峰值”。更多端口会增加寄存器文件带宽与旁路成本，公开资料尚不足以复算整套能效收益。

![图 9：Skymont 的 26 端口执行后端](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_details_wechat_article_zh/442b3b3e202fe49f_09_figure.png)

Skymont 有四条 Store Address AGU，但 L1D 每周期只能写两次。多余 AGU 可更早确定 Store 地址，尽快检查年轻 Load 是否冲突；若 Memory-dependence Predictor 猜错，也能在错误路径扩散前 Replay。AGU 吞吐因此不仅服务最终 Cache 写带宽，还服务依赖消歧。

### 体系结构视角：ROB 大，不代表有效窗口一定有 416 条

Rename 会在 ROB、物理寄存器、Scheduler、Load Queue、Store Queue 或分配端口任一资源先满时停下。16-wide Retire 只在头部大量完成时快速回收；遇到一个长延迟头部指令，宽出口也无法越过。评估 Skymont 应同时看 `ROB full`、Scheduler full、Load/Store Queue full 与 Allocation Stall，而不是只引用 416。

## 四、向量与浮点：从 Atom 短板变成 4×128-bit

传统 Atom 因面积与功耗限制，FP/向量单元较弱。Skymont 希望覆盖更广应用，并借助新工艺配置四条 128-bit 常用 FP/向量整数路径，整体接近 Arm Cortex-X2 的宽度。

![图 10：Skymont FP/向量执行](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_details_wechat_article_zh/de81bf0d36aac790_10_figure.jpg)

![图 11：Skymont 四条 128-bit 向量路径](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_details_wechat_article_zh/68a045e985094680_11_figure.png)

*图 10、11：FMA 延迟从 Crestmont 的六周期降到四周期。吞吐与延迟同时改善，意味着依赖链和独立向量流都能受益。*

Skymont 还为 Subnormal（非规格化浮点数）加入硬件快路。Crestmont 的微码处理使一个产生 Subnormal 结果的 FP Multiply 超过 280 周期；编译器用 `-ffast-math` 设置 FTZ/DAZ 可把极小输入或结果视为零，却会改变 IEEE 语义。Skymont 在不要求软件放弃精确语义时，也避免了这个“玻璃下巴”。

![图 12：最小 Normal 值乘 0.5 的 Subnormal 测试](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_details_wechat_article_zh/41cf9bdb07987fe0_12_figure.jpg)

## 五、内存系统：三 Load、双倍 L2 带宽与 4K 项 TLB

L1D 每周期可处理三次 128-bit Load，Crestmont 为两次；Miss Address Buffer 从 12 项增加到 16 项。共享 L2 聚合带宽从 64 B/cycle 翻倍到 128 B/cycle，每核仍最多 64 B/cycle；L2 Eviction 写向下一级从 16 提升到 32 B/cycle。

![图 13：Skymont Cache 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_details_wechat_article_zh/bbfb05e9f13c8bc9_13_figure.jpg)

Lunar Lake 的 Skymont Cluster 配 4 MB L2，另有 8 MB System Level Cache。相比 Meteor Lake 低功耗 Crestmont 只有 2 MB L2、又直面高延迟 LPDDR5X，这套层级更有机会把应用留在低功耗岛。

地址翻译也同步扩容：L2 TLB 从 Crestmont 的 3K 增至 4K 项，高于 Redwood Cove 的 2K 和 Zen 4 的 3K；Page Miss Handler 增加，以并行处理多个 Walk。

## 六、同集群 Cache-to-Cache 不再绕远路

Gracemont/Crestmont 在一个核心写、另一个核心读时，会借助 Ring/Scalable Fabric 处理 Cache-to-Cache Transfer。即使两核同属一个 L2 Cluster，请求也表现得像 L2 Miss，从而省去 Cluster 内跟踪各 L1 修改行的硬件。

![图 14：Skymont 的集群内一致性改进](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_details_wechat_article_zh/4c19057680b6deb2_14_figure.png)

Skymont 让 L2 Complex 直接处理同集群转移，减少出集群流量与延迟。Intel 未公布具体结构；Arm Cortex-A72 曾在 L2 内放 Snoop Tag Array 跟踪各 L1 内容，可以作为一般性参照，但不能据此断言 Skymont 使用同一实现。

## 七、Skymont 仍不是 P-Core

![图 15：Skymont 产品与核心](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_details_wechat_article_zh/d5e8618005f80a40_15_figure.jpg)

*图 15：Intel 内部数据若成立，Skymont 每周期性能已接近 Redwood Cove；实际性能仍要乘上频率并受产品 Cache、内存和功耗限制。*

从 Bonnell、Silvermont 到 Skymont，Atom 已完成一次巨大扩张。它在宽度、乱序容量和向量能力上接近上一代大核，但目标频率仍明显低于 P-Core，AVX-512 等 ISA 支持也不同。混合架构因此保留两条核心线：E-Core 追求面积效率与多线程密度，P-Core 追求高频和单线程上限。

Skymont 的价值不在“26 个端口比谁多”，而在于通过集群前端、宽退休、专用端口、地址消歧和更强 Cache 层级，把小核过去容易突然崩溃的角落逐一补齐。它更像一颗面积受限的宽核心，而不是传统意义上的简化核心。

## 参考资料

- Chester Lam，*Intel Details Skymont*：https://chipsandcheese.com/p/intel-details-skymont
- Intel，Skymont Architecture Presentation
