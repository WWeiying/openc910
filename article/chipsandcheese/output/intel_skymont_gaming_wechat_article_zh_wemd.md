---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "intel_skymont_gaming_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Skymont in Gaming Workloads*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2025 年 8 月 20 日
> - 链接：https://chipsandcheese.com/p/skymont-in-gaming-workloads

E-Core 是 Intel 提高单位面积多线程性能的关键。Skymont 在 Arrow Lake 桌面平台上最高 4.6 GHz，重命名/分配宽度达到八个微操作，单核性能已经不能只用“数量多、每颗弱”概括。游戏仍更偏爱频率更高、窗口更深的 Lion Cove P-Core，但单独让 16 颗 Skymont 跑游戏，可以看到密度核心离主流性能到底还有多远。

测试使用 Core Ultra 9 285K、Arc B580 和 DDR5-6000 28-36-36-36。游戏场景、系统后台、驱动和帧时间误差没有形成统一 Benchmark 套件，文章主要借 PMU 分析流水线瓶颈，不做完整产品评测。

![图 1：Intel Arrow Lake 的 P-Core/E-Core 定位](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_gaming_wechat_article_zh/afa9ea7e8a4f4d57_01_figure.jpg)

*图 1：Intel 把 Lion Cove 用于最高每线程性能，Skymont 用于高面积效率。实际测试说明后者并不只适合后台轻任务。*

## 一、Top-Down：宽度为何没有被用满

Top-Down 分析在重命名/分配级给每个 Pipeline Slot 分类。Skymont 的八宽是流水线最窄的吞吐门槛之一；槽位若在这里空掉，后端再快也无法追回。

![图 2：Skymont 游戏负载的 Top-Down 分类](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_gaming_wechat_article_zh/1346d8ab9916c833_02_figure.png)

*图 2：Palworld、Cyberpunk 2077、Call of Duty 等多数时间受后端限制；Retiring 比例不高，说明游戏是低 IPC、长等待工作负载。*

Skymont 没有直接把 Backend Bound 分成 Core Bound 与 Memory Bound 的事件。测试用“退休被 Load 阻塞的 cycle”近似 Memory Bound，再用带 `cmask=1` 与 invert 的退休槽事件得到所有退休停顿周期。这个方法与 AMD 定义并不完全相同：ROB 在误预测或异常后为空，也会让退休停止，却不一定有未完成指令。

## 二、后端：416 项 ROB 往往不是先满的资源

Skymont 有 416 项 ROB，接近 Zen 5 的 448 项，低于 Lion Cove 的 576 项。理论窗口很大，现实中分布式调度器常先限制分配。Zen 5 的统一调度组织在相近总 Entry 下更灵活，因此更常填满 ROB，而不容易因某一类 Scheduler 单独耗尽。

![图 3：Skymont 的 Dispatch Stall 组成](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_gaming_wechat_article_zh/6a5163520f8060b1_03_figure.png)

*图 3：红色资源限制占大头，此外还有 Allocation Restriction、内存/Store 资源与 Serialization。寄存器文件和内存排序队列总体够用，并非每次都由 ROB 决定窗口边界。*

Intel 没有在优化手册中公开每类 Scheduler 每周期能接收多少微操作，只有 PMU 暗示分配限制。Arm 对 Cortex-X1 则明确给过每类管线的 Dispatch 上限，可作为可能机制参照。

![图 4：Cortex-X1 的分布式 Dispatch 约束示例](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_gaming_wechat_article_zh/5ea689edacd0708c_04_figure.png)

*图 4：同一八宽组若集中到相同管线，可能无法全部下发。它解释一种通用风险，但不能据此断言 Skymont 采用相同规则。*

即使消除这些限制，长延迟指令仍会逐渐填满后端资源，因此收益不会等于当前所有 Allocation Stall。

### Serialization：不是所有指令都允许绕过去

`IQ_JEU_SCB` 表示 Instruction Queue/Jump Scoreboard 要等较老微操作退休或 Jump 执行后才允许继续分配。Intel 明确列出 `LFENCE`、`MFENCE` 等常见 Scoreboard 指令；文章无法确定游戏中具体是哪类 Jump 触发。

![图 5：游戏中的 Serialization 原因](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_gaming_wechat_article_zh/d5410edce8bfe66e_05_figure.png)

*图 5：`IQ_JEU_SCB` 是主要序列化来源。`NON_C01_MS_SCB` 与微码序列器有关，常见于 `PAUSE`；它可能来自游戏的 Spinlock。`C01_MS_SCB` 对应 UMWAIT/TPAUSE 进入轻睡眠，图中极少。*

与 Crestmont 对照可看到窗口扩大的收益。Crestmont 只有 256 项 ROB，在 Cyberpunk 2077 更容易先触及 ROB；Skymont 的压力转向非内存 Scheduler、分配约束与序列化。

![图 6：Crestmont 与 Skymont 的 Dispatch Stall](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_gaming_wechat_article_zh/47ff1ff382801f5b_06_figure.png)

*图 6：两颗核心不在同一平台，Crestmont 来自无独显的 Meteor Lake 笔记本，因此只能比较资源瓶颈构成的粗趋势，不能比较绝对帧率。*

### 体系结构视角：ROB 大，不代表有效窗口一定大

乱序窗口由最先耗尽的资源决定。若指令集中在整数 Scheduler，即使 ROB 还有空位，分配也会停下；若物理寄存器、Load Queue 或 Store Buffer 先满，结果同样如此。验证“窗口大小”要用不同指令组合分别施压，并同时看 ROB full、Scheduler full、Register Stall 与 LSQ Stall，而不是只引用最大 ROB Entry。

## 三、Cache 与内存：DRAM 仍是最难隐藏的等待

Skymont 有 32 KB L1D，每四核共享 4 MB L2；Arrow Lake 的 36 MB L3 由全体核心共享。相比 Lion Cove 的 48 KB L1D＋192 KB L1.5＋3 MB L2，Skymont 更依赖大簇级 L2。L3 约 14 ns，明显慢于 AMD 低于 9 ns 的桌面 L3。

![图 7：三款游戏的 Cache Miss/千指令](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_gaming_wechat_article_zh/ae1c38cf3424c370_07_figure.png)

*图 7：Palworld 的 L1 miss 最多，约 35.52 MPKI；大多数由 L2 截住，L3 与 DRAM miss 少得多。Miss 数量与每次代价需要一起看。*

PMU 可统计核心因 L1D Demand Miss 等待不同层次的 Active Cycle。Demand 只说明由指令发起，不保证最终退休；“核心被阻塞”的精确定义也没有像老 Skylake 事件那样完整披露。

![图 8：L2、L3 与 DRAM Memory Bound Cycle](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_gaming_wechat_article_zh/ab01bac2e21fc610_08_figure.png)

*图 8：L2 Bound 很低，4 MB L2 和大窗口能隐藏大部分延迟；DRAM 占比最大，L3 居中。Skymont 较低频率也意味着相同纳秒延迟对应的潜在损失较少，这不是延迟本身变快。*

![图 9：每次 Memory Bound Stall 的平均持续时间](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_gaming_wechat_article_zh/4ee529a266c9221d_09_figure.png)

*图 9：L2/L3 平均 Stall 甚至长于独立微基准的 Cache 延迟。可能因为一条阻塞链需要多个输入，也可能因为事件统计的是“仍有指令等待该层”的整个区间，而非单次 Load-to-use。*

### 体系结构视角：PMU 事件名不是机制本身

“L3 Bound”可能表示至少有一条请求在 L3，也可能要求当周期没有可发射微操作；不同核心定义会改变百分比。解释时应先读事件公式，再用独立延迟、Miss 数和 Occupancy 交叉验证。若平均 Stall 大于物理 Cache 延迟，优先怀疑多请求依赖和事件窗口，不应立刻推断 Cache 变慢。

## 四、前端：很强，却被后端瓶颈遮住

Intel 对 Skymont 的 Frontend Bound 分类与 Zen 5/Lion Cove 略有不同：如果 Decoder 有输入却不能高效处理，算 Bandwidth Bound；因分支预测、I-Cache 或 TLB 等导致前端无输入，则算 Latency Bound。这种定义适合 Skymont 的 Clustered Decoder，因为 Taken Branch 对持续译码吞吐的影响不同于直线 Decoder。

![图 10：Skymont Frontend Bound PMU Unit Mask](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_gaming_wechat_article_zh/baf37bf197aa2c54_10_figure.png)

*图 10：表中列出 ITLB、L1I、BAClear、Branch Prediction、Predecode、Decode Stall 与 Microcode Sequencer 等类别。它展示事件定义，不代表每类都对游戏重要。*

![图 11：前端停顿的具体来源](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_gaming_wechat_article_zh/67d0a047321f08eb_11_figure.png)

*图 11：所有前端损失都较小；Decode Stall 与 Microcode 相对更显眼。Intel 只说明 Decoder 负载不平衡或其他限制会落入 Decode Stall，没有公开具体指令序列。*

密度核心通常没有面积为所有罕见复杂指令做快路径，会让它们拆成多个微操作或进入 Microcode。设计者必须依据实际指令频率，在面积与慢路径之间选择。

Skymont 在三款游戏中的分支预测已经足够准确。Palworld 与 Call of Duty 误差可能较大；Cyberpunk 2077 中，Skymont 甚至比 Lion Cove 少约 25% 的每指令误预测。它说明前端不是 E-Core 游戏性能的首要短板，也不能据此推出 Skymont 预测器普遍优于 P-Core。

## 五、能玩，不等于可以取代 P-Core

16 颗 E-Core 上实际游玩，多款游戏都达到可玩帧率，卡顿也不明显。Cyberpunk 2077 内置 Benchmark 中，同平台 Zen 5 约 151.33 FPS、Lion Cove 148.38、Skymont 141.68。

![图 12：Cyberpunk 2077 平均帧率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_skymont_gaming_wechat_article_zh/828276af69ff97cc_12_figure.png)

*图 12：Skymont 与 Lion Cove 差距不大，展示密度核心能力；它不是跨平台 CPU 排名，也没有给出 1% Low、功耗与误差条。*

几条结论比“E-Core 能不能玩游戏”更重要：

1. Skymont 的 416 项 ROB 让它不再像早期小核那样很快撞上窗口上限，但分布式 Scheduler 与分配限制会更早形成瓶颈。
2. 大 4 MB L2 有效挡住 L3，真正困难的是少量 DRAM miss；游戏低 IPC 的核心问题仍是长延迟，而不是算术单元不够。
3. 前端、分支预测和八宽分配已经很强，很多改进会被后端等待遮住，体现继续加宽的收益递减。
4. PMU 分类是诊断视角，不是可直接跨厂商比较的统一“百分比”。
5. 能稳定提供可玩性能说明 Skymont 是完整的高性能核心，但要取代 P-Core，还需在更多单线程负载中达到或超过它。

历史上，P6 衍生的 Pentium M 在大量任务中击败 NetBurst Pentium 4，最终预示 Core 2 路线。Skymont 尚未处在相同位置：Lion Cove 没有 NetBurst 那种明显低效，P-Core 仍有更高峰值和更深窗口。但 Intel E-Core 团队已经证明，单位面积优化与相当强的单线程性能可以同时存在。

## 参考资料

- Chester Lam，*Skymont in Gaming Workloads*：https://chipsandcheese.com/p/skymont-in-gaming-workloads
- Intel，Skymont Optimization Manual / Performance Monitoring Events
- Arm，Cortex-X1 Software Optimization Guide（图 4 的分配限制参照）
