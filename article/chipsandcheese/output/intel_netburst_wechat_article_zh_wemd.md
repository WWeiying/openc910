---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "intel_netburst_wechat_article_zh"
---

> 英文标题：Intel’s Netburst: Failure is a Foundation for Success<br>
> 撰文：Chester Lam<br>
> 首发：Chips and Cheese，2022 年 6 月 17 日<br>
> 原始链接：https://chipsandcheese.com/p/intels-netburst-failure-is-a-foundation-for-success

今天的高性能核心很少彻底推翻基础架构；沿成熟设计迭代更快、更便宜、风险也低。二十多年前格局尚未稳定，Intel 两次试图替换 P6：Itanium 用超宽顺序执行回避乱序与 x86 变长译码复杂度；Pentium 4 的 NetBurst 则用极长流水线追求极高频率，并一次引入大量新机制。

它没有达到预期，却成为 Intel 理解物理寄存器文件、微操作缓存、SMT 和高频流水线的重要实验。本篇主要测试较晚的 90 nm Prescott 与 65 nm Cedar Mill，均支持 64 bit；主平台为 Pentium Extreme Edition 965。

## 一个远超时代规模的大核心

![图 1：NetBurst 与 Pentium III、Athlon 64、Merom 的核心结构规模](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/a07209b691d61237_01_figure.png)

NetBurst 相比 P6 Pentium III 拥有更多执行资源和数倍大的乱序结构，也大于同期 Athlon 64，甚至大于后继 Merom。

![图 2：P6 与 NetBurst 三发射流水线的资源对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/09942fd6407f9658_02_figure.png)

两者同为 3-wide，但 ROB、scheduler、load/store tracking 都不在一个量级。巨大容量并不等于高 IPC，后文会看到它很大程度上是在补偿重放与错误路径清理的低效。

## 分支预测：快速路径惊人，跌出快速层后代价惊人

长流水线让误预测恢复尤其昂贵，巨大乱序窗口也只有在前端方向正确时才有价值，因此 branch predictor 是 NetBurst 的重点。

![图 3：Prescott 裸片上的前端与预测相关区域；裸片图来自 Martijn Boer](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/fdabc23ccbe30bc7_03_figure.jpg)

Agner Fog 记载 Pentium 4 使用带 16-bit global history 的 two-level adaptive predictor；Pentium EE 965 实测可识别长度 24 的重复模式，可能在 65 nm 版扩展。它甚至强于后继 Merom，但 24 是行为观察，不等同于公开 GHR 位宽。

![图 4：不同历史模式长度下的预测能力](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/9fdd8fcefc3fd85c_04_figure.png)

![图 5：NetBurst 与后继核心的相关模式预测对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/b8739122786a9366_05_figure.png)

Trace cache 配合大型 BTB，可让超过 1024 条 taken branch 零气泡，分支非常密集时甚至超过 2048 条。Intel 直到 2021 年 Gracemont、AMD 直到 2020 年 Zen 3 才提供相近的小 footprint 零气泡能力。

![图 6：小分支 footprint 下的 taken branch 吞吐](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/a900675ecbbf650c_06_figure.png)

一旦超过快速跟踪能力，处理器可能转到 4096-entry 主 BTB，每条 taken branch 超过 13 周期，即约 12 个 bubble。

![图 7：越过快速层后的主 BTB 路径](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/e21f33a988549a53_07_figure.png)

再发生 BTB miss，代价高达 36 周期；此时可能从 L2 取指并用 branch address calculator 求目标。

![图 8：多代处理器 taken branch 代价；纵轴截在 20 周期以免 NetBurst 破坏比例](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/e854e39bb13e69da_08_figure.png)

Merom 仅 4 条、Westmere 仅 8 条后就出现 1 周期 bubble，小 footprint 不如 NetBurst；超过 BTB 容量后，两者却比 NetBurst 的 4096 项路径更快。

### 体系结构视角：高频设计最怕快速路径之外的悬崖

分支前端不是一个单一 BTB，而可能是若干延迟/容量层级。NetBurst 用极强小 footprint 路径掩盖长流水线，却让 miss 路径达到 36 周期。真实程序若频繁跨过这个边界，平均 IPC 会被长尾支配。验证时必须扫 footprint 与 branch density，并分别观察方向错、目标 miss 和取指 miss；只报“小循环 taken 无气泡”会严重高估整体能力。

## Trace Cache：不缓存字节，而缓存执行路径

NetBurst 没有传统 L1I，而是 12K-entry trace cache。它存放已译码 uop，并按动态执行顺序组织 trace；同一指令若是多个分支目标，可能在多个 trace 中重复出现。目标是从取指角度把 taken branch 变成 trace 内连续流，避免越过分支的 fetch/decode 槽浪费。

![图 9：Prescott 前端；decoder 区可能包含复杂 trace building 逻辑](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/4f12d5fd07470d78_09_figure.jpg)

命中时可跳过变长 x86 译码，以更低延迟、功耗和更高带宽供给 uop。

![图 10：8-byte NOP 的前端带宽；Goldmont Plus 与 Haswell L1I 均为 16 B/cycle](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/4d13f2e9bbf16fb4_10_figure.png)

长指令会卡住传统 L1I 字节带宽，trace cache 不受此限。但面积效率糟糕：90 nm Pentium 4 uop 据称为 64 bit，12K 项仅原始数据就约 96 KB；Intel 白皮书却称命中率只类似 8—16 KB 传统 I-cache。变长 x86 字节编码本来紧凑，uop 更宽，再重复缓存同一指令，容量问题加剧；同期 Athlon 有 64 KB L1I。

Trace miss 后只能从 L2 取字节并经过 1-wide decoder，吞吐断崖式下降；传统宽译码核心即便 L1I miss，也可让下级缓存继续喂多条指令。

![图 11：大指令 footprint 下 NetBurst 与传统 32 KB L1I/3-wide Goldmont Plus 的吞吐](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/82b7b7d44025588a_11_figure.png)

Decoder 输出既进后端又用于建 trace。短 trace 少重复、容量高；长 trace 跨越更多 taken branch、吞吐高，构建逻辑很难调优。

这条路线并未完全消失。Sandy Bridge 重新引入更小 uop cache，并配强大传统 decoder/L1I，用正常 miss 路径补足；其 8-way、6-uop line 与 NetBurst trace cache 相似。现代 Intel uop cache 也不像 Zen 那样缓存 microcode sequencer 输出，而是存 microcode ROM 指针，与 NetBurst 类似。不能据此确认电路复用，但技术血缘很可能存在。AMD、Arm、Samsung 后来也采用不同形式的 uop cache。

## Rename：从 ROB+RRF 转向 PRF

![图 12：trace cache、microcode ROM 与推测 renamer 位置](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/df1291f19bcbd7b0_12_figure.jpg)

NetBurst rename/allocate 为 3-wide。它似乎不做 move elimination，却能识别 zeroing idiom、打断依赖，而且不同 zero idiom 表现不同。

![图 13：寄存器 MOV 与多种归零写法的吞吐](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/d64f3f58df2a1e64_13_figure.png)

P6 把未退休结果存在 ROB result field，退休时复制到 retired register file（RRF）；scheduler 还保存等待指令的输入值，若来源已退休，renamer 需读 RRF。Agner Fog 称 Nehalem/Westmere RRF 仅 3 read port，可能解释其独立 register-to-register MOV 吞吐。NetBurst 改用同时保存 speculative 与 architectural value 的独立 physical register file（PRF），消除了这类退休搬运瓶颈。

## 乱序后端：大容量是在为浪费买单

PRF 方案让 ROB 和 RAT 只保存物理寄存器指针，例如 128-entry file 只需 7-bit index，而不是搬 64/128-bit 值。ROB 与寄存器文件还能独立定容；branch/store 不写寄存器，扩 ROB 不必同步加同量 data storage；move elimination 也可通过改 RAT pointer 完成。

![图 14：裸片上清晰可见的独立寄存器文件](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/35d7facabdcacbd6_14_figure.jpg)

但 Agner Fog 发现 NetBurst 的错误路径 uop 似乎不能在 branch mispredict 后立即 squash，要一直跟踪到 retirement。省掉中途清理可简化高频流水线，却长期占用 ROB、PRF 和 scheduler，巨大结构因而是在补偿有效容量损失。

![图 15：NetBurst 与多代核心的调度容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/af7dc111682eaddd_15_figure.png)

![图 16：分布式 math scheduler 与共享 dispatch port](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/eaab0021c0e3285e_16_figure.png)

NetBurst 把 math scheduler 分区，降低每队列端口数、面积和功耗；多个 queue 又仲裁同一 dispatch port。图中极大容量也可能混入 non-scheduling queue，本文未测试，不能全部当成可唤醒选择 entry。

四条 dispatch port 中两条接 hot-clocked integer ALU，每核心周期可执行两次，于是 3-wide 核心理论有 4 ALU/cycle，正常情况下必然喂不满。原因在于大量无效工作：错误路径不能及时清除；load 默认按 L1D hit 发射，miss 后回 scheduler 反复 replay，依赖指令也跟着重放。额外 ALU 不是为真实整数 IPC，而是为 replay 与错误路径留余量。

### 体系结构视角：恢复逻辑是 PRF 设计的核心，不是附属功能

P6 的 ROB 若兼作结果存储，回滚可借 circular buffer 恢复指针；PRF 架构还要把错误路径分配的每个 entry 归还 free list，并恢复 RAT checkpoint。若为高频简化恢复，让错误 uop 等退休释放，就会把一次误预测的成本从前端 bubble 扩散到所有后端资源。现代设计通常为分支保存 rename map/checkpoint，快速 squash，并用 walk 或 freelist 重建保证精确状态。

## Load/Store：正常转发正常，异常路径灾难

Load 必须判断是否读取更老 store 的数据。NetBurst 只有地址完全一致且不跨 cache line 时能以 5—6 周期转发。

![图 17：按 Henry Wong 方法测试 Pentium EE 965 的 store-to-load forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/404e17a9acccf218_17_figure.png)

若 load 被 store 覆盖但起始地址不同，超过 50 周期；load 跨 line 为 89 周期，store 跨 line 125 周期，两者都跨 line 高达 165 周期。它们虽是边界情况，其他核心通常只需数十周期。

![图 18：Goldmont Plus 同类测试；4-byte 粒度模式相近，但惩罚小得多](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/dfd57ae4028431d5_18_figure.png)

即便没有邻近内存次序冲突，NetBurst 跨 line load 约 23 周期，store 约 105 周期。现代乱序核心可把拆成两次的轻微代价隐藏，百周期慢路径却会占满队列、阻塞退休。

### 体系结构视角：Store forwarding 是字节覆盖与年龄匹配问题

地址相同只是最简单情况。硬件还要处理大小不同、部分覆盖、跨 line、跨页与多个老 store 合并。保守实现若不能证明安全，就会 replay load 或等待 store 退休；NetBurst 极高惩罚说明慢路径恢复十分昂贵。可用 offset×size 矩阵验证，配合 machine clear、memory ordering replay、LD/ST stall 事件；不能由单个数值猜测比较器数量。

## Cache 与地址翻译

晚期 NetBurst L1D 为 16 KB/4 周期，已好于 Willamette/Northwood 的 8 KB，却比 Athlon 的 64 KB/3 周期又小又慢。

![图 19：NetBurst、Athlon 与后继核心的数据缓存参数](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/f16095b69236e518_19_figure.jpg)

![图 20：Pentium EE 965 与 Athlon X2 6000+ 的纳秒延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/f361341dcc30ceb9_20_figure.png)

Pentium 频率优势不足以弥补 L1D 周期差；Athlon 在 64 KB 容量下维持 indexed addressing 3 周期是很强的实现。

每核 2 MB L2 约 25 周期。Athlon L2 更小、周期更少，但 NetBurst 高频把纳秒差距拉平；Core 2 改为双核共享、特征更接近 AMD。

![图 21：L1/L2 延迟与容量对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/46121602a3153032_21_figure.png)

当时多为两级缓存，L2 miss 通过 front-side bus 到北桥内存控制器，额外片外 hop 让 Pentium EE 与 Core 2 都比集成内存控制器的 Athlon 延迟高。

![图 22：4 KB 与 2 MB 页下的延迟差](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/0609811b12db22c3_22_figure.png)

512 KB 工作集时，4 KB 页已比 2 MB 页多 18.35 周期、4.92 ns；工作集增大，page walk 自身也 miss cache，差距继续扩大。用 2 MB 页压低翻译开销后，DRAM 约 90 ns，竟与多年后的 Tiger Lake i7-11800H 相近，但平台和内存配置完全不同，只能说明纳秒量级。

## 带宽与 Write-through L1D

NetBurst 相对 Pentium M 把 L1D load width 翻倍，并把 P6 时代背面总线/外置 SRAM 的 L2 更紧密集成。

![图 23：NetBurst 与 Pentium M 单线程缓存带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/1d6e7c29c94002b3_23_figure.png)

对 Westmere 则各级落后；后者 L3 容量大数倍，单线程带宽仍接近 NetBurst L2。NetBurst 唯一亮点是 16 B/cycle 配合高频，使 L1D 绝对带宽略高。

![图 24：NetBurst 与 Westmere 单线程带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/5a73265815200596_24_figure.png)

![图 25：双核四线程 Pentium EE 965 与四核 Goldmont Plus 聚合带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/19ad3d1048425b9a_25_figure.png)

J4125 同为总计 4 MB L2、但四核共享，聚合 L2 仍更高。Pentium EE DRAM 单线程约 6.8 GB/s；四线程反降到 5.86 GB/s，说明争用处理不佳。双通道 DDR2-533 单线程效率约 80%，全线程 68.7%；J4125 单通道 DDR4-2133 四核 76.9%，单核只有 38.8%。NetBurst 单线程能吃满内存，也因为总带宽很低。

NetBurst L1D 使用 write-through：store 立即写到 L2；write-back 则只在 eviction/coherence 时回写 dirty line。

![图 26：NetBurst 读写带宽；写带宽不足读的四分之一](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/e82c5efb36e3233e_26_figure.png)

L2 工作集内写入不到 4 B/cycle，约 13.27 GB/s。libx264 在 Sandy Bridge 上 load/store 指令比约 2.41:1，而 NetBurst 读写带宽比高达 4.46:1；小 L1D 和低容量效率 trace cache 又制造更多 L2 读流量，与写穿流量竞争。

![图 27：采用 write-back L1D 的常规核心读写带宽对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/d9e6006f22ddac13_27_figure.png)

Write-through 简化 dirty tracking 和错误恢复，L1 不保留唯一修改副本；代价是所有 store 都受下级带宽限制。后继 Intel 高性能架构没有沿用这套小型 write-through L1D。

## 为什么失败，又留下了什么

NetBurst 是“优秀快速路径 + 恐怖异常路径”的集合：trace 命中和小 BTB footprint 很快；trace miss、BTB miss、跨 line、转发失败则是几十到上百周期。Replay 与不能及时清除错误路径让流水线做大量无用功，带来低 IPC 与低能效；工艺也没有提供设想中的极高频率，无法靠 MHz 覆盖问题。

![图 28：Prescott 裸片推测标注，所有区域识别都需谨慎](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/6e591cf43a2f3d1b_28_figure.jpg)

![图 29：NetBurst 相对 P6 几乎所有主要模块都重做](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/501c028181eb3825_29_figure.jpg)

一次引入 trace cache、PRF、Hyper-Threading、分布式 scheduler、replay、高频 ALU 和长流水线，使各机制负面效应互相放大。PRF 需要独立 freelist 与恢复；若 mispredict 回滚复杂，设计可能选择等退休释放，继而迫使 ROB/scheduler 继续膨胀。

但 NetBurst 不只是失败。Intel 在真实产品上积累了 PRF、SMT 和 decoded-uop caching 的数据，并花多年调优 Hyper-Threading。

![图 30：NetBurst 技术如何在 Sandy Bridge 重新组合](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/e3a2dad0499c20b6_30_figure.jpg)

Sandy Bridge 没有简单复刻，而是把可用思想放进更均衡的管线：uop cache 配传统强前端、PRF 配快速恢复、成熟 SMT 配合理执行资源。它无需内部从零发明对应机制，落地即形成成功架构。随后 Intel 用保守代际演进和工艺移植巩固优势；NetBurst 的试错构成了这段成功的基础。

## Northwood 补充与测试配置

主平台为 Asus P5W64 WS Pro、Intel i975X、1066 MT/s FSB、双通道 DDR2-533 3-3-3-9。Athlon 64 X2 6000+（65 nm Brisbane）由 catsay 测试，Asus M2N4-SLI/nForce4 SLI、双通道 DDR2-800 5-5-5-18。跨平台延迟包含主板、北桥和 DRAM 差异。

130 nm Northwood 使用更早 NetBurst，8 KB L1D 仅 2 周期；Cedar Mill L2 周期数相近但容量更大。

![图 31：Northwood 与 Cedar Mill 按周期的缓存延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/a94e9ed03dfc2de6_31_figure.png)

![图 32：两者按纳秒的缓存延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_netburst_wechat_article_zh/3fa97fe1a9fc8d9f_32_figure.png)

Cedar Mill 高频使 L2 更大也更快，L1 却仍是 Northwood 更低延迟。Prescott/Cedar Mill 扩到 16 KB/4 周期，可能因为 8 KB 对 64-bit 更大 footprint 太小，也可能为高频放宽 timing。图 31—32 数据由 Ashley89 提供，平台为 Intel i865P、DDR-400 3-4-4-8。

## 结语

NetBurst 的根本错误不是“长流水线”四个字，而是把高频优先级放到极端，并让常见慢路径承担不可接受代价。高速 ALU、巨大 scheduler 与 4096 项 BTB 看似豪华，很多资源却在处理 replay、错误路径和容量悬崖。

它的历史价值同样具体：PRF、SMT 和 decoded-uop caching 没有消失，而是在 Sandy Bridge 中以更平衡的恢复、缓存和执行组织重新出现。失败不是成功的反义词；当失败提供足够真实数据，并让下一代知道哪些机制必须重构，它就能成为技术地基。
