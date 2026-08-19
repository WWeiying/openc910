---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "arm_a710_n2_fp_scheduler_correction_wechat_article_zh"
---

> 英文标题：Correction for A710/Neoverse N2’s FP Scheduler Layout<br>
> 撰文：Chester Lam<br>
> 首发：Chips and Cheese，2023 年 8 月 20 日<br>
> 原始链接：https://chipsandcheese.com/p/correction-for-a710-neoverse-n2s-fp-scheduler-layout

用微基准反推处理器内部结构并不容易。此前对 Cortex-A710 的测试把一类转换指令映射到了错误的执行端口，进而画出了错误的浮点调度队列容量。重新选择指令并把 non-scheduling queue（NSQ，非调度队列）纳入模型后，更合理的结论是：A710 两条 FP/向量流水线各有约 19 项调度队列，前方共享约 11 项 NSQ；此前看到的“每边 30 项”并不全是可参与唤醒选择的调度项。

## 如何从外部测量队列深度

测试沿用 Henry Wong 的方法：在两次 cache miss 之间塞入一组 filler instruction，并让这些指令依赖 pointer-chasing load 的结果。如果 filler 耗尽后端资源，重命名阶段会停住，第二次 cache miss 就无法与第一次重叠，最终表现为单次迭代时间突然升高。

这套方法最初常用于测量重排序缓冲区（ROB）和寄存器文件，也可以用来测 scheduler。难点在于调度器可能是统一式，也可能是分布式。统一式调度器让多个执行端口共享等待池；分布式布局则为不同端口配置独立队列，甚至还可能出现部分端口共享、其余端口独立的混合结构。

因此，未知核心不能只跑一种指令。要把分别只能走不同端口的指令混合起来：若混合后可容纳的等待指令数增加，通常说明它们位于不同队列；若容量不增加，则更像共享一个队列。但这一推断还必须排除前置缓冲、微操作拆分和指令端口选择等干扰。

![图 1：Arm 优化指南公开的 Cortex-A710 核心流水线；其中没有给出 issue queue 深度](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_a710_n2_fp_scheduler_correction_wechat_article_zh/99719b9379cf3a45_01_figure.png)

Arm 公布了流水线与端口能力，却没有公布各 issue queue 大小，所以测量只能从零开始。浮点/ASIMD 部分最初选择 FP add 和 `SCVTF`：FP add 从独立数组加载数据，并以 pointer chase 的结果作索引；`SCVTF` 则直接把 chase load 的整数结果转换成浮点数。

![图 2：最初的 A710 调度容量曲线；不同指令在约 20 项和约 52 项附近出现拐点](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_a710_n2_fp_scheduler_correction_wechat_article_zh/1a2f834c990f096c_02_figure.png)

## 错误来自同名指令的不同形式

Arm 优化指南里 `SCVTF` 出现多次，而且操作数形式不同，所走端口也不同。

![图 3：优化指南中的 SCVTF 端口表；不同寄存器形式对应不同执行流水线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_a710_n2_fp_scheduler_correction_wechat_article_zh/be1bb88f6ecf16e1_03_figure.png)

最初使用的是“通用整数寄存器输入、浮点寄存器输出”的形式，它实际进入 M0 多周期整数流水线，而不是预期的 V0。于是测到的是 M0 的队列容量，却被误认为 V0。若使用两个 ASIMD/FP 寄存器参与的形式，本可避免这个问题。

错误是在测试 Cortex-X2 时暴露的。`FJCVTZS`（JavaScript 浮点转有符号定点、向零舍入）在该核心上是少数只能走单一端口的操作，只进入 V0，很适合判断 V0 是否有独立队列。把测试拿回 A710 后，结果与旧数据不一致；重查手册才发现旧测试选错了形式。

![图 4：改用 FJCVTZS、ADDV 后得到的 A710 FP 调度容量曲线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_a710_n2_fp_scheduler_correction_wechat_article_zh/769cc8880f23213a_04_figure.png)

V1 端口使用 `ADDV`（向量横向加法）测试。这里也有陷阱：byte 元素版本会解码成两个微操作，一个固定用 V1，另一个可去任意向量端口；halfword（16-bit）元素版本才是只进入 V1 的单微操作。

这样，`FJCVTZS` 表示 V0 可见容量，halfword `ADDV` 表示 V1。两者单独测试容量相同，还不能证明是否共享队列；继续混合两类指令，或使用两端口均可执行的 `FADD`，可见容量接近翻倍，说明更像两个独立的约 30 项等待池。

![图 5：第一轮修正后的模型，把两条 FP/向量流水线解释为各 30 项调度队列](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_a710_n2_fp_scheduler_correction_wechat_article_zh/4236f12e52c40275_05_figure.png)

## 30 项仍不是实际 scheduler 深度

对低功耗核心来说，每条流水线 30 项已经偏大。更重要的是，“核心能跟踪多少条未完成指令”并不等于“scheduler 能同时检查多少项”。Zen 的浮点调度器前方就有一个 64 项非调度队列；若只观察重命名何时停止，会看到约 96 项容量，但真正参与调度选择的只有约 36 项调度队列条目。

要分离 scheduler 与 NSQ，可以在两次 pointer-chasing load 之间放入超过已知容量的指令，并让其中一部分独立。独立指令可以离开 scheduler，为后续指令腾出位置；逐步改变“依赖指令在独立指令之前的数量”，就能找到真正会阻塞唤醒选择窗口的边界。

![图 6：测试代码示意；依赖指令无法离开队列，独立指令可先执行并释放调度项](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_a710_n2_fp_scheduler_correction_wechat_article_zh/9ae1197d52d5d188_06_figure.png)

![图 7：排除 NSQ 容量后的测量曲线，真正的 scheduler 拐点约为 19 项](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_a710_n2_fp_scheduler_correction_wechat_article_zh/a61cc9e710d936fe_07_figure.png)

结果显示，原先可见的 30 项应拆为约 19 项 scheduler 加约 11 项 NSQ。混合 V0、V1 时，可见的调度容量翻倍，NSQ 容量却没有翻倍，因此两条流水线很可能各有独立的 19 项 scheduler，并共享前方 NSQ。

![图 8：修正后的 A710 FP/向量后端模型：共享 NSQ，两个约 19 项的分布式 scheduler](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_a710_n2_fp_scheduler_correction_wechat_article_zh/29aa7dddbbbabf11_08_figure.png)

这里的 `~14 entry` 是早期示意图上的近似标注；依据正文测试拆分，作者给出的具体解释是 19 项 scheduler 与 11 项 NSQ。微基准拐点和模型并非官方 RTL，数值应理解为观测支持的组织方式。

![图 9：更新后的 Cortex-A710 核心框图](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_a710_n2_fp_scheduler_correction_wechat_article_zh/e6a561b504beaffc_09_figure.jpg)

### 体系结构视角：容量测试测到的是背压链，而不一定是单个物理队列

重命名停顿只说明从 rename 到执行端之间的某处失去接收能力。scheduler、NSQ、物理寄存器、ROB、load queue，以及一条指令拆成几个微操作，都可能改变拐点。要把总容量分解成真实结构，必须构造能“选择性排空”某一级的测试，并用严格的端口受限指令隔离执行资源。

异常或 cache miss 发生时，依赖微操作留在 scheduler 中等待操作数；独立微操作可先发射。NSQ 则允许更多微操作先被重命名，却不能扩大每周期参与 wakeup/select 的窗口。这种分层可以减少大范围比较器和广播网络的能耗，但深依赖链会更容易被有限 scheduler 窗口卡住。硬件上可结合 rename stall、scheduler full、issue occupancy 与端口发射计数器验证；没有公开计数器或 RTL 时，本文只能通过延迟拐点间接识别。

## 为什么公开纠错很重要

在厂商几乎不公布队列深度时，框图只能依靠大量交叉测试。测试越多、可用时间越少，选错指令形式或忽略微操作拆分的概率就越高。下图是对 Cortex-X2 的初步模型：它也因未计入 NSQ 而暂时不正确。

![图 10：Cortex-X2 的初步调度器示意；作者明确指出该版本仍未计入 NSQ](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_a710_n2_fp_scheduler_correction_wechat_article_zh/e4cdca3ec07428c8_10_figure.png)

常规整机 benchmark 往往有多家媒体交叉复现，微结构反推却缺乏这种校验网络。更可靠的做法是公开测试方法、指令编码和错误修订，让其他人能复测；也希望 Arm、Intel、AMD 公布更多实现细节。

这类工作并非不可复制：熟悉 C、汇编和典型乱序结构，再从论文或博士论文中改造方法，就能测量不同资源。对 A710 和 Neoverse N2 的旧文也需要据此修订。最值得留下的结论不只是“19+11”这个数字，而是容量、可调度容量和端口归属必须分开验证。
