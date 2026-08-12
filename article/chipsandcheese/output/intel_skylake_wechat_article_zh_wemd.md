---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "intel_skylake_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Skylake: Intel’s Longest Serving Architecture*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2022 年 10 月 14 日
> - 链接：https://chipsandcheese.com/p/skylake-intels-longest-serving-architecture

Skylake 于 2015 年发布，随后六年覆盖 Intel 主要产品线。它首发时没有强敌，却意外承担了抵挡 Zen 1、Zen 2、Zen 3 的任务。直到 2021 年 Alder Lake，Intel 才在全线真正替代它；Rocket Lake 虽先取代 Comet Lake，却没有同时胜过后者的 Gaming 和 Core Count。

![图 1：Skylake 及其大量 Refresh](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/6c8c155f9d248a84_01_figure.png)

*图 1：蓝色代表 Skylake 衍生产品。超长服役并非原计划，也说明 Sandy Bridge/Haswell 奠定的基础非常扎实。*

奇妙之处在于，Client Skylake 相比 Haswell 的跨代提升不大。真正的大改多为 Server/AVX-512 做准备，或者被四宽 Rename 等旧边界抵消。

## 核心总览：Haswell 的演进，而非又一次地基重做

![图 2：Client Skylake 核心](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/68cdfa34389ba00c_02_figure.png)

*图 2：Skylake 扩大 Buffer、调整 Scheduler/RF，并增强向量与 Fetch，但仍是四宽 Rename 的 Core。*

![图 3：Haswell 核心对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/43877c9b5678d879_03_figure.png)

*图 3：Haswell 已经平衡、弱点少、Vector 很强；Skylake 主要是在这套基础上补强。图中结构来自资料与测试整理，不是 RTL。*

## Branch Predictor：准确率近似 Haswell，目标路径略有取舍

Haswell 在 2010 年代中期已有领先 Predictor，Skylake 行为与其很接近。

![图 4：分支 Pattern 测试之一](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/6d095ce8d9a81e7d_04_figure.png)

*图 4：Skylake 在长 Pattern 下没有显著改变可见行为。具体内部优化仍可能存在，微基准不一定敏感。*

![图 5：分支 Pattern 测试之二](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/0d0e14045688fa1a_05_figure.jpg)

*图 5：英文正式图注指出 Skylake Direction Predictor 很像 Haswell。*

![图 6：实际负载 MPKI](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/cdeea6e8f42e0a28_06_figure.png)

*图 6：正式图注同样认为 Haswell→Skylake 的 Accuracy 变化很小。MPKI 是工作负载结果，不等于所有模式测试。*

速度方面，两代都用两级 BTB：第一层约 128 Target，可在 Taken 后不浪费 Cycle；第二层约 4096 Target，命中付出 1-cycle Penalty。

![图 7：BTB Footprint 与 Taken Branch 代价](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/1265b37095dd638b_07_figure.png)

*图 7：超出 BTB 后 Skylake 更快，暗示 Branch Address Calculator 更快或更靠前；Dense Branch 却略退步：Haswell 在 16 B 间距可让 128 Branch 无罚，Skylake 需 32 B。*

![图 8：Skylake Die 上的 Predictor 区域](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/404d675e444c9bbf_08_figure.jpg)

*图 8：正式图注提醒 Die Annotation 都是猜测，照片来自 Fritzchens Fritz。Call Depth 超出 RAS 后，Skylake 可退回 Indirect Predictor，猜中时减少惩罚。*

### 体系结构视角：强 Predictor 也会进入边际收益区

容量、Dense-branch Throughput、Fallback 与实际 MPKI 是不同维度。Skylake 没显著提高 Accuracy，却改善部分 BTB Miss 路径和 RAS Overflow。成熟设计的进步常转向减少极端 Penalty，而非让平均 MPKI 大幅下降。

## Fetch：六宽 Op Cache 被四宽 Rename 截住

L1I 到 Decoder 的 Byte Buffer 从 Haswell 每线程 20 增至 25 Entry；Rename 前 Decoded Instruction Queue 为每线程 64 Entry，Haswell 总 56、双 SMT 时每线程 28。更深 Buffer 可平滑供给 Burst；iTLB Associativity 也提高。

![图 9：Skylake Frontend Die 区域](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/547a6fa6e8d371fc_09_figure.jpg)

*图 9：Decoder 最多输出 5 Micro-op/cycle，却仍只处理 4 Instruction/cycle；第五个 Micro-op 只在某条指令展开为多个 Micro-op 时出现。多数 Skylake Instruction 仍为一个。*

Op Cache 从 Haswell 4 Micro-op/cycle 增至 6，正好一次取完整 6-op Line；但随后 Rename 只有四宽，小 Footprint 下总吞吐提升被截断。

![图 10：大 Instruction Footprint 吞吐](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/d64e4d1ec121a117_10_figure.png)

*图 10：从 L2/L3 Fetch 时 Skylake 明显占优，可能来自更高 Instruction-side MLP 与更积极 Prefetch。*

![图 11：4-byte NOP 的 Instruction Bandwidth](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/11e9e29f8ed63769_11_figure.png)

*图 11：即使从 L3，Skylake 仍接近 3.5 IPC；Haswell 为 2.2～2.5，仍足以在 Backend 等 Cache 时提供指令。Piledriver 从 L2 仅略高于 4 B/cycle。*

## Rename 与 Backend：97 项 Scheduler 被拆成两块

Rename 仍为四宽，两代都能识别 Zeroing Idiom、消除 Register-to-register Copy。PMU 显示 `XOR r,r` 与 `SUB r,r` 可在 Rename 完成，不占 ALU；Piledriver 只解除依赖，仍要占两条 ALU 之一。

![图 12：Move/Zero Elimination](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/0f3890aa5160f18b_12_figure.jpg)

*图 12：Rename Optimization 可以省执行资源，但长依赖链等模式下 Move Elimination 并非总能成功。*

![图 13：Skylake 与 Haswell 乱序资源容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/ceda77705fb79600_13_figure.jpg)

*图 13：Scheduler、Integer RF 与 Store Queue 扩大。更深 Window 有助于绕过长延迟，收益会递减。*

P6 传统的大统一 Scheduler 随 Port/Entry 增加变得昂贵。Skylake 把 97 项拆为 58-entry Math/Store-data Queue 与 39-entry AGU Queue。

![图 14：Skylake Backend Die 区域](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/4dc7259f1d4a0deb_14_figure.jpg)

*图 14：正式图注称 Backend 由大型 OoO Engine 与巨型 Vector Unit 主导。拆分降低多端口阵列复杂度，却可能带来局部 Queue 失衡。*

Skylake 另设 x87/MMX PRF。Client 程序很少混用旧 FP 与 SSE/AVX，单看 Client 像不必要；真正原因是 Server Skylake 的 AVX-512 Mask Register 可复用该阵列，避免 Mask Write 与 Integer Register 争容量。

![图 15：Skylake 的 RF 变化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/4297c953c6e3799f_15_figure.png)

*图 15：单独 RF 也释放主 256-bit Vector RF 的容量；Client 没有 AVX-512，因此承担工程与面积成本却用不到主要目的。*

![图 16：Haswell Backend 对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/8bbba636293c3cc9_16_figure.jpg)

*图 16：正式图注要求注意新增 x87/MMX RF 与分离 Scheduler；Haswell Die Photo 来自 Cole L。*

![图 17：Backend Resource Stall](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/9a41e41ba0fb8db6_17_figure.png)

*图 17：Skylake 比 Haswell 略少 Backend-bound，提升不大，符合 Buffer 增大边际收益递减。*

### 体系结构视角：Client 为 Server 可配置性付了成本

同一核心要扩展到 AVX-512、1 MB L2 和 Mesh Server，早期就需为 Mask RF、Cache Geometry 和 Port 留接口。它提升产品复用，却让 Client Die 上出现暂时无收益的结构。架构评价不能只看单个 SKU，也要看一套 Core 如何覆盖整个产品族。

## Execution 与 Load/Store

Client Port Layout 类似 Haswell：四条 Integer Port、两条通用 AGU、一条 Store-only AGU；Port 0/1/5 兼做 FP/Vector。

![图 18：Haswell/Skylake Vector Port](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/664d717ad9b441b8_18_figure.png)

*图 18：正式图注说明是简化图，未画全部 Unit/Forwarding，图中没标不代表没有。FP Add/Multiply/FMA 统一 4-cycle、每周期两条，说明两 FMA Unit 可能承接全部 FP Math。*

![图 19：向量 Operation 可达 Port](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/f335254341242152_19_figure.jpg)

*图 19：Vector Integer Multiply 复制到 Port 0/1，Add 可到 0/1/5，`vorps` 等 Bitwise 也可到三条 Port；Haswell 多项集中 Port 5，Skylake 降低热点。*

![图 20：Load/Store Die 区域](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/55fdb75490c8d2b8_20_figure.jpg)

*图 20：两 General AGU 加一 Store-only AGU 延续 Haswell。*

![图 21：Skylake Store Forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/2195d47cfa3ea917_21_figure.png)

*图 21：Henry Wong 方法。Haswell Forward 为 5～6 cycle，Skylake 几乎总为 5，精确地址偶尔更短。*

![图 22：Haswell Store Forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/3995c48a9db813b8_22_figure.png)

*图 22：两代都可能先按 4-byte Region 粗比较，再做完整检查；Partial Overlap 失败后 Skylake 约 15 cycle。*

![图 23：Piledriver Store Forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/c3fb16c28b02f24f_23_figure.png)

*图 23：FX-8350 多约 3 cycle，跨 16-byte Boundary 的 Partial Case 不能转发，失败惩罚也更高。Intel Misalignment 边界为 64 B。*

两代 Intel Store 跨 64 B 需两 Cycle；Load 常可一 Cycle，可能因为两个 Load Port。安全边界上，AMD 不会唤醒依赖 Faulting Load 的指令，因此不受 Meltdown；Skylake 会让错误 Load 产生 Speculative Side Effect。Whiskey Lake 以后让 Faulting Load Result 恒为零，缩小 Attack Surface，但不如完全不产生结果严格。

### 体系结构视角：性能优化也可能成为侧信道窗口

若 Permission Check 晚于 Data Forward，依赖指令能在 Trap 退休前用秘密值改变 Cache State。Architectural State 最终回滚，Microarchitectural State 却泄露。安全验证必须检查 Faulting Load 是否 Wake Dependent、哪些 Cache/TLB/Port 状态被污染，而不只是确认 Exception 精确发生。

## Client Cache：几何基本不变，TLB 与 L3 MLP 小步提升

Client 仍是 32 KB L1D、256 KB L2、每 Core 一片 Ring L3。L2 从 8-way 降至 4-way，很可能为 Server 通过加 Way 扩到 1 MB 做准备；若从 256 KB/8-way 直接加容量，1 MB 会变成过度的 32-way。

![图 24：Cache Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/d506223a5e70193a_24_figure.png)

*图 24：Skylake/Haswell Absolute L3 低于 10 ns、L2 略高于 3 ns；超过 L2 时曲线更平缓，暗示 Replacement Policy 改变。Piledriver 各级更慢。*

![图 25：4 KB Page 下的 Translation+Cache Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/e8424e42e3d8c0ed_25_figure.png)

*图 25：Piledriver 2 MB L2 在 256 KB～2 MB 有容量优势，但 L2 TLB 代价吃掉大部分 Latency 优势。*

L2 TLB 从 Haswell 1024/8-way 增至 1536/6-way（CPUID 口径），容量增长补过较低相联度，Miss 减少。

![图 26：L2 TLB Miss](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/9d1e9e47389d4987_26_figure.png)

*图 26：翻译 Reach 是 Cache 访问前的隐藏层；只画 Cache Hit Latency 会漏掉 4 KB Page 下的真实代价。*

L2↔L3 Queue 从 16 增至 32 Entry，很可能增加 L3/DRAM MLP。

![图 27：单线程 Cache 带宽（Absolute）](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/802b940ff5f0e02d_27_figure.png)

*图 27：正式图注上方 Absolute、下方 B/core-cycle。Haswell 已是 256-bit AVX Bandwidth Monster，Skylake 主要改善 L2 之后。*

![图 28：单线程 Cache 带宽（归一化）](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/4cc7a7969705460a_28_figure.png)

*图 28：Piledriver 单线程 L2 Bandwidth 甚至不及 Intel L3。*

![图 29：多线程 Cache 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/cc9ba55b75ac1b70_29_figure.png)

*图 29：Piledriver 的 2 MB Private L2 在特定 Working Set 有容量窗口，但 L3 不 Inclusive、总容量较多仍只略低于 40 GB/s；Intel L3 高数倍。*

## Skylake-X：Mesh、1 MB L2、Non-inclusive L3 与 AVX-512

Server 版转向 Mesh，把 Monolithic Die 扩到 28 Core，Haswell 最多 18。但 Mesh Node 四向连接、频率较低，平均 Hop 更少未兑现为低延迟。

![图 30：Skylake-X Mesh Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/5c9b0b9cc8fffcf7_30_figure.png)

*图 30：Mesh L3 Latency 明显升高，Topology 扩展性不是免费收益。*

![图 31：Skylake-X L3 Bandwidth](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/5387f46d358261bd_31_figure.png)

*图 31：正式图注仅显示 1T；匹配 Core Count 下 L3 Bandwidth 也更低。原网页 Caption 句子本身未完整显示，不能补造缺失结论。*

因此 Server 把 Private L2 扩到 1 MB，用高带宽 L2 隔离慢 L3，也为 AVX-512 提供数据。L3 转 Non-inclusive，避免大 L2 内容在 LLC 重复占位。

![图 32：Skylake-X 与 Client 差异](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/6628bce11019342f_32_figure.jpg)

*图 32：正式图注为 Skylake-X 标注图，照片来自 Fritzchens Fritz。*

![图 33：为 Server Variant 预留的核心变化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/e192256443b7aba2_33_figure.jpg)

*图 33：AVX-512 让 L1D 每周期支持 2×512-bit Load+1×512-bit Store，带宽是 Client Skylake 两倍，虽然 Server Clock 通常更低。*

![图 34：Client IPC 世代提升](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/779304e47425d9dd_34_figure.jpg)

*图 34：AnandTech 给出的 Skylake/Haswell Per-clock 提升约 5.7%，明显低于 Haswell/Ivy Bridge 的 11.2%。Client 为产品族灵活性让步。*

### 体系结构视角：Mesh 解决连接数，Private L2 解决每核供给

Ring 随 Stop 增多拉长最远距离；Mesh 降低二维平均 Hop，却增加 Router Port 与 Clock/Power 压力。Server 的补偿是把更多 Working Set 留在 Private L2，并把 LLC 定位为容量与 Coherence 层。Topology 与 Cache Policy 必须共同设计。

## 六年续命：14 nm、更多 Core 与更大 Ring

14 nm+ 调整扩展 Power/Frequency Curve，既能拉高峰值，也改善低功耗。

![图 35：Kaby Lake Power/Frequency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/22802552f02c7321_35_figure.png)

*图 35：正式图注说明 Kaby Lake 可用更高功耗换 Clock，也在低功耗区扩展更好。*

![图 36：六核 Coffee Lake Die](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/a437e5cd09e0f13d_36_figure.jpg)

*图 36：Intel 利用 Modular Ring/L3 Slice 增至六核；照片来自 Fritzchens Fritz。*

![图 37：八核 Coffee Lake Refresh Die](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/c24cf4cd5127b8c4_37_figure.jpg)

*图 37：继续增至八核，更大 L3 也帮助低线程。*

![图 38：四到十 Ring Stop 的 L3 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/2bacb3f3338a5df9_38_figure.png)

*图 38：正式图注上方 ns、下方 cycle，Comet Lake 数据由 Mohamexiety 测试。四到十 Stop 增约 11 cycle，Absolute 从 8～9 ns 到略高于 10 ns，仍很合理。*

![图 39：L3 扩展的另一种表示](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/0b66a90460f0468c_39_figure.png)

*图 39：更大容量、更多 Core 与更长 Ring 同时变化，不能把 Cycle 增量只归因于容量。*

AMD 随 Zen 追上：Zen 1 的 32 KB L1D、512 KB/12-cycle L2 与每四核以内共享 L3，已让 Cache Cycle 接近 Kaby Lake。

![图 40：Zen 1/2 与 Skylake Cache Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/1ece918259a5f679_40_figure.png)

*图 40：Zen 2 L3 翻倍，TSMC 7 nm 帮助增频，3950X L3 略高于 8 ns，并让单线程可见 16 MB。*

![图 41：Cache Bandwidth（Absolute）](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/7567736670bf2c16_41_figure.png)

*图 41：正式图注说明上方 Absolute、下方按 Core Cycle 归一化，以校正 EPYC 较低 Clock。*

![图 42：Cache Bandwidth（归一化）](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/622b20dcb9086293_42_figure.png)

*图 42：Zen 2 全宽 256-bit Vector 追平 Intel 的 L1D 优势，L3 在多方面超过 Skylake。*

![图 43：Backend 容量的代际追赶](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/8f3e83bbae7d11f2_43_figure.jpg)

*图 43：Zen 逐代扩大 Buffer；Renamer 可在长依赖链消除 MOV，5 Instruction/6 Micro-op 每周期，使其有效五宽，而 Skylake 仍四宽。*

![图 44：Op Cache 与大 Footprint Fetch](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/ba39b4d46d223ae7_44_figure.png)

*图 44：Zen 自带更大 Op Cache，Zen 2 到 4096 Op，令 Skylake 1536 项显小；大代码 Footprint 取指差距也被抹平。*

Skylake 仍保留两项强点：256-bit Vector 很有竞争力；大量 Taken Branch 下 Target Following 快于 Zen 1/2，后者会在 Taken 后浪费 Cycle。

![图 45：Taken Branch Handling 对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/890c9a273ac2fd92_45_figure.png)

*图 45：到 Zen 3，AMD 才在包括 Taken Handling 的多数方面全面超过这条老核心。*

## 最后的评价：它本应只是过渡，却改变了市场

Client Skylake 没有 Sandy Bridge 的 AVX、Haswell 的 FMA/AVX2 那类场景跃升。更合理的历史解释是：Intel 把这一代工程重点放在 Client/Server 可配置性，预计 Cannon Lake 10 nm 很快带 AVX-512 下放，Sunny Cove 再用大 Buffer 重启 Client 增长。

![图 46：Skylake 后端 Die](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skylake_wechat_article_zh/3f47e8946964bbac_46_figure.jpg)

*图 46：为 Server/AVX-512 留出的结构后来确有价值，但 10 nm 延期让 Client Skylake 被迫长年留守。*

Cannon Lake 未进 Desktop/高性能 Laptop；Sunny Cove 直到 14 nm Backport 的 Rocket Lake 才进桌面，且表现不理想。Zen 1 用 Core Count 竞争，Zen 2 令 Per-core 接近，Zen 3 最终在几乎各方面超过 Skylake。

这对 Intel 是停滞，却可能让 PC 市场重新获得竞争。2015 年 Intel 高性能 CPU 几乎垄断；Skylake 被迫服役半个十年，给 AMD 留出恢复窗口。高频、多核后期 Skylake Variant 至今仍能承担日常任务，也说明它本身确实扎实。

### 体系结构视角：从 Skylake 可以归纳出的六点认识

第一，产品族复用会改变 Client Core 的最优点。Mask RF、L2 Geometry 与 AVX-512 预留并非都服务首发桌面性能。

第二，Frontend 局部六宽不等于核心六宽。四宽 Rename 截住 Op-cache/Decoder 峰值，只有大 Footprint Fetch 改善更易兑现。

第三，大 Buffer 收益递减但可延长设计寿命。Skylake 增长有限，却让后续增频、增核仍有平衡基础。

第四，安全是投机时序的一部分。Faulting Load 何时产生 Value 与 Wakeup，决定 Meltdown Attack Surface。

第五，Server Mesh 必须配更大 Private Cache。连接更多核心的同时，不能指望慢 LLC 持续喂 AVX-512。

第六，长寿既是设计成功，也是 Roadmap 失败。Skylake 的稳健让 Intel 能等待，却也让 Zen 有时间逐项超越。

## 参考资料

- Chips and Cheese：[*Skylake: Intel’s Longest Serving Architecture*](https://chipsandcheese.com/p/skylake-intels-longest-serving-architecture)
- Intel Optimization Materials、Fritzchens Fritz/Cole L Die Photos、Henry Wong Store-forwarding Methodology（正文援引）

网页末尾提供 Patreon、PayPal 与 Discord 支持入口。
