---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "amd_zen5_gaming_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Running Gaming Workloads through AMD’s Zen 5*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2025 年 8 月 2 日
> - 链接：https://chipsandcheese.com/p/running-gaming-workloads-through

Zen 5 相比 Zen 4 拥有更大的乱序窗口、重组的执行引擎和更宽流水线，在 SPEC CPU2017 与生产力软件中都有清楚进步；非 X3D 型号的游戏提升却常受质疑。这并不一定意味着核心“对游戏没优化”，而可能说明游戏把压力放在了峰值吞吐之外的路径。

测试平台是 AMD 提供的 Ryzen 9 9900X 与 Radeon RX 9070，内存为 64 GB DDR5-5600 36-36-36-89。游戏仍是 Palworld、Call of Duty: Cold War 和 Cyberpunk 2077，但不能与此前 Lion Cove 数据直接逐项对比：Palworld 基地已变化，COD 多人局不可重复，Cyberpunk 更新还强制 60 FPS Cap。这里看宽泛的 PMU 趋势，不做同场景胜负。

![图 1：被测 Ryzen 9 9900X](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_gaming_wechat_article_zh/75aff717b717ad54_01_figure.jpg)

*图 1：9900X 是双 CCD、每 CCD 六核的非 X3D Zen 5。平台 Cache、内存和 Windows 调度都会进入结果。*

## 一、Top-Down：Zen 5 的主要损失在前端

重命名/分配每周期最多接收八个微操作。Top-Down 把空槽分成 Frontend Latency、Frontend Bandwidth、Backend Core/Memory Bound、Bad Speculation 与 SMT Contention。后端 Bound 表示有微操作可下发，但各种队列、寄存器或 Buffer 无法继续接受；AMD 再按退休被未完成 Load 或其他指令挡住来分类。

SMT Contention 不代表核心总吞吐丢失，而是当前线程有工作却由兄弟线程获得该周期分配机会。三款游戏中该项不高，Retiring 比例也不高，符合低 IPC 工作负载特征。

![图 2：Zen 5 游戏负载的 Top-Down 结果](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_gaming_wechat_article_zh/a68f4dd148a18959_02_figure.png)

*图 2：三款游戏中 Frontend Latency 最大，Backend Memory 次之，Bad Speculation 很小。这与 Lion Cove“后端内存占首位”的顺序相反。*

### 体系结构视角：低 IPC 不等于前端窄

前端可以标称 8/12-wide，却因某些 cycle 完全拿不到正确路径微操作而得到低平均 IPC。加宽只改善“已有一串连续工作”时的吞吐，无法缩短 BTB Override、误预测恢复或 L2 Code Fill。分析宽度前应先区分“有供给但不满”和“整拍没有供给”。

## 二、Op Cache、L1I 与 24K BTB

Zen 5 使用约 6K Entry Op Cache、32 KB L1I 和解耦分支预测器。BTB 总计约 24K Entry，分成 16K 第一层与 8K 第二层，让预测器在取指之前沿控制流前跑。

![图 3：Op Cache 覆盖、L1I/L2 Code 命中与分支准确率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_gaming_wechat_article_zh/c2315508a058ea0b_03_figure.png)

*图 3：Op Cache 覆盖三款游戏的大部分指令流，优于 Lion Cove 的 5.2K Entry；L1I 每千指令仍约有 20～30 次 Refill，1 MB L2 接住绝大多数，少数落到 L3。*

分支预测准确率很高，却在三款游戏里略低于此前的 Lion Cove 数据。Zen 5 在 SPEC 541.leela 等难预测子项上明明更强；由于场景已变化、跨平台事件口径不同，这个一致差距值得注意，却不能证明预测器普遍更差。

![图 4：Zen 5 与 Lion Cove 的前端事件](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_gaming_wechat_article_zh/b868cbfa1d5c20da_04_figure.png)

*图 4：Zen 5 在游戏里出现略更多 Branch Mispredict/千指令、Decoder Override 与 L1I miss；Lion Cove 的 64 KB L1I 是明显优势。*

误预测会同时造成 Bad Speculation 与 Frontend Latency：错误路径工作被丢弃，Ahead Predictor 也失去领先距离。Decoder Override（Intel 称 BAClear）则是 Predictor 未跟踪某条分支，后续前端发现后重定向；它不产生同等错误路径，却暴露取指 Cache 延迟。

![图 5：前端 Latency Bound 的平均持续时间](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_gaming_wechat_article_zh/afceca9996f601f4_05_figure.png)

*图 5：约 11～12 cycle，与 Zen 5 L2 延迟接近。平均值同时混入更短的 Op Cache/L1I 重定向和更长的 L3/DRAM Code Fill，只能作为线索。*

BTB 第二层或间接预测器 Override 也会产生短气泡；但 Predictor 仍可继续前跑，低 IPC 游戏的后端 Stall 又可能遮住几 cycle，因此文章认为它们是次要因素。

## 三、前端带宽：标称 12-wide，平均只有约 6

Zen 5 大多数活跃周期运行在 Op Cache 模式。它标称每周期可交付 12 个微操作，实测平均却约 6，低于填满八宽重命名所需的 8。

![图 6：Op Cache 与 Decoder 活跃周期占比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_gaming_wechat_article_zh/a9e9223aaa368270_06_figure.png)

*图 6：Op Cache 活跃约 14%～21% 的总 cycle，Decoder 约 4.5%～5.3%；剩余时间大量处于后端停顿或无供给。百分比不能直接当成前端空闲原因。*

![图 7：Op Cache 与 Decoder 的平均微操作吞吐](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_gaming_wechat_article_zh/3929170aafc4a87a_07_figure.png)

*图 7：Op Cache 活跃时约 5.3～6.2 uops/cycle，Decoder 略低于 4。Decoder 只覆盖小部分周期，因此把 Decoder 再加宽，对整体影响有限。*

Taken Branch 会切断连续块，降低宽取指收益。Op Cache 吞吐与动态分支密度呈负相关，三款游戏位于 SPEC CPU2017 工作负载的中间区域。

![图 8：Op Cache 吞吐与分支比例](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_gaming_wechat_article_zh/113d3127875acb11_08_figure.png)

*图 8：分支越密，单次可连续交付的微操作越少。它说明平均 6 uops/cycle 的一种来源，但相关性并不等于所有差异都由分支造成。*

### 体系结构视角：标称宽度要乘上连续可用概率

实际供给近似由“每次传多少”与“有多少 cycle 能传”共同决定。块边界、Taken Branch、Bank 冲突和 Entry 对齐会减少单拍交付，Miss 与 Redirect 则让整拍为零。提升性能可能来自更灵活的块拼接、每拍多分支，也可能来自更大 L1I；单纯增加峰值 uop 数只覆盖第一类。

## 四、后端：448 项 ROB 能填满，整数寄存器先吃紧

后端无法接收时，说明某类资源已经耗尽。Zen 5 的整数物理寄存器文件经常比 448 项 ROB 更早成为热点；仍有一部分 Stall 无法被 PMU 细分。

![图 9：Zen 5 Dispatch Resource Stall](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_gaming_wechat_article_zh/b29c724e1728a1e8_09_figure.png)

*图 9：Integer Register 与未归类原因较显眼；统一 Scheduler 很少成为限制。重新组织后的 FPU 把 FP Register Allocation 放到大型非调度队列之后，几乎消除了 FP 资源 Stall。*

与分布式 Scheduler 相比，统一队列可让不同端口共享 Entry，因而更不容易一侧满、一侧闲。Zen 5 常能真正填到 448 项 ROB，说明窗口资源配比总体较均衡。

退休被 Load 阻塞时，平均会停约 18～20 cycle，比普通指令更久。

![图 10：后端与 L1D Miss 的平均持续时间](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_gaming_wechat_article_zh/8fbc54d6876e8e97_10_figure.png)

*图 10：Retire Blocked by Load 约 18～20 cycle，L1D Miss Latency 可到数十或上百 cycle。Palworld 的平均 miss 较短，不代表更轻松，而是它有更多落在 L2 的 miss。*

![图 11：Demand L1D Fill 来源/千指令](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_gaming_wechat_article_zh/88e5484bb6e3ea63_11_figure.png)

*图 11：Palworld L2 Fill 约 19.33/千指令，显著高于另外两款；Cross-CCX 与 DRAM 很少。数量与延迟一起决定总影响。*

跨厂商对照还存在计数位置差异。Intel 多在退休时为 Load 标注数据来源，只算真正退休的指令；AMD 在 Load/Store Unit 计数，可能包含误预测后的 Load。本文使用 Demand Data Load 尽量接近，但仍不完全可比。

![图 12：Zen 5 与 Lion Cove 的 L1D Miss 来源](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_gaming_wechat_article_zh/bda4db8f586cea53_12_figure.png)

*图 12：Palworld 显示 Lion Cove 192 KB L1.5 的价值；Intel 3 MB L2 也把更多请求留在核心。Zen 5 的 1 MB L2 更快，32 MB L3 延迟又低于 Arrow Lake。*

Zen 5 三款游戏的 Demand L3 Hit Rate 分别约 64.5%、67.6% 和 55.43%。大多数 L3 miss 去 DRAM，跨 CCX 占比很小；从 L3 采样看，跨 CCX 延迟接近或略优于 DRAM。

![图 13：L3 Miss 的本地 DRAM 与跨 CCX 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_gaming_wechat_article_zh/416cd4f925d03751_13_figure.png)

*图 13：正常调度下跨 CCX 既少、又没有比 DRAM 更慢到足以主导，因此 PMU 不支持“只要降低跨 CCX 延迟就会显著提升这三款游戏”的说法。*

## 五、强行跨 CCX 会发生什么

双 CCD Ryzen 把最高频核心集中在一个 CCD，Windows 也偏向把游戏线程放在那里，所以正常运行时跨 CCX 很少。为了制造问题，测试把 Cyberpunk 进程亲和性拆成每个 CCX 三颗核心，使用 Low Preset、FSR Quality、最高 Crowd Density，并关闭 Boost 消除核心频率差异。

![图 14：单 CCX 与跨两个 CCX 的 Cyberpunk 结果](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_gaming_wechat_article_zh/89ebdd9653dc5b6b_14_figure.png)

*图 14：固定在一个 CCX 约 157.54 FPS，拆成 3＋3 核约 146.51 FPS，下降约 7%。内置 Benchmark 本身有几个百分点波动，但 7% 超出观察误差。*

所有 L1D Fill 来源事件显示跨 CCX 明显增加。这个事件也包含 Prefetch 和最终不退休的访问，甚至会记入无用 Prefetch，因此比 Demand/Retired 口径更宽。结果能证明人为放置增加跨区流量，不能精确分解每一帧的因果。

### 体系结构视角：拓扑问题通常先是调度问题

若工作集能留在一个 CCX，跨区硬件延迟几乎没有机会影响性能；只有线程数、迁移或共享数据把请求推出本地时，拓扑才成为一阶因素。硬件可缩短链路，操作系统也可通过 Fast Core 集中、CCD Parking 和 Affinity 避免触发。评价时应先测自然调度，再用人工拆分建立上界。

## 六、Zen 5 与 Lion Cove 在游戏里卡在不同位置

游戏的数据与代码局部性都差，是典型低 IPC 工作负载。Zen 5 的 L2/L3/DRAM 延迟较低，数据侧有优势；前端却因 32 KB L1I、更多 Redirect 和指令 miss 而明显限制后端利用率。Lion Cove 的 64 KB L1I 很强，却被 Arrow Lake 较慢的 L3/DRAM 削弱。

![图 15：游戏与 SPEC CPU2017 的 Zen 5 平均 IPC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_gaming_wechat_article_zh/ebc00f4ffa443baa_15_figure.png)

*图 15：游戏约 1～1.6 IPC，远低于 `548.exchange2` 等高 IPC 子项。宽执行端最适合“已有数据和指令可连续处理”的区域。*

Zen 5 与 Lion Cove 都强化分支预测和重排序，但继续推进会遇到收益递减：抓住最后少数难分支需不成比例的表容量与能量；扩大窗口则要同步增加寄存器、LSQ、Scheduler 和恢复状态。

Intel 的 64 KB L1I 值得肯定，不过 Redwood Cove 已经采用；Zen 5 的 1 MB L2、32/96 MB L3 基本延续 Zen 4。若一颗核心能结合 Intel 更大 L1I 与 AMD 低延迟数据层次，会更适合游戏这类难负载。

![图 16：Cyberpunk 运行期间的 Windows 调度时间线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_gaming_wechat_article_zh/c8cf720b4dbd48d2_16_figure.jpg)

*图 16：自然调度把主要工作集中在一颗 CCD。线程出现在哪颗逻辑处理器，比“芯片有两个 CCD”这个静态事实更直接影响跨区流量。*

![图 17：AMD 对跨 CCX Refill 的路径说明](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_gaming_wechat_article_zh/473360d08586720a_17_figure.png)

*图 17：跨 CCX Refill 要经 IOD/Fabric 与 Home 机制，成本高于簇内。图来自 Zen 2 优化资料，只用于说明拓扑原则，不等于 Zen 5 的精确周期。*

可以归纳出六点：

1. Zen 5 的游戏限制首先是前端 Latency，而不是八宽执行能力不够。
2. 大 Op Cache 覆盖率高，32 KB L1I 和少数 L2/L3 Code Miss 仍会在 Redirect 后暴露长等待。
3. 448 项 ROB 与统一 Scheduler 能有效容忍后端延迟；整数寄存器文件成为更现实的窗口限制。
4. Lion Cove 的大 L1I/L1.5/L2 与 Zen 5 的低延迟 L2/L3 是不同解法，各自在不同游戏/数据局部性下占优。
5. 正常游戏很少跨 CCX；本次强制 3＋3 核测得约 7% 损失，说明硬件问题存在，也说明调度策略正在有效规避它。
6. 继续提升高 IPC 峰值，对低 IPC 游戏的收益越来越小；下一代更值得把预算投向难分支、指令足迹和长延迟路径。

AMD 与 Intel 必须同时服务生产力、HPC、服务器和游戏。文章并不要求架构只为游戏重做，而是希望设计重心从“让容易的高 IPC 片段更快”稍微转向“让困难片段少停一些”。这也是 Zen 5 游戏表现看似平淡背后的真正体系结构问题。

## 参考资料

- Chester Lam，*Running Gaming Workloads through AMD’s Zen 5*：https://chipsandcheese.com/p/running-gaming-workloads-through
- AMD，Zen 5 Performance Monitoring / Processor Programming Reference
- AMD，Zen 2 Software Optimization Guide（跨 CCX 路径图）
