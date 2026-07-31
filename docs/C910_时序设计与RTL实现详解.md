# C910 时序设计与 RTL 实现详解

## 1. 时序设计究竟在解决什么问题

处理器“跑得快”至少包含两个不同目标。第一个目标是让时钟周期足够短，也就是提高可达频率；第二个目标是让完成一段程序所需的周期足够少，也就是降低 CPI。把组合逻辑切成更多流水级通常有利于第一个目标，却可能增加分支误预测恢复、load-use 依赖和异常清空的周期数，从而损害第二个目标。C910 的 RTL 中经常能看到这种平衡：复杂比较被切片并行完成，长算术被分级或迭代执行，高扇出状态被分散到局部队列；与此同时，设计又使用旁路、提前比较、推测唤醒和 create-to-issue bypass，尽量把流水化引入的额外等待隐藏起来。本文要解释的不是“有多少级流水”这一孤立数字，而是这些结构怎样共同约束频率、延迟、吞吐和恢复代价。

本文仍然区分三类证据。模块中的寄存器边界、组合表达式、握手、状态机和注释属于可由 RTL 直接确认的事实；某种拆分通常为什么有利于频率、为什么可能增加 CPI，属于依据数字电路与体系结构原理做出的工程解释；最终哪一条是最差路径、可签核频率是多少，则必须由特定网表、工艺库、PVT、SDC、布局布线寄生和 MCMM STA 决定。仓库带有一份综合时序快照，本文会用它验证 RTL 分析与工具结果是否相互印证，但不会把该快照写成 C910 商业芯片的流片频率或最终 signoff 结论。

时序分析还必须锁定“当前真正参与综合的数据通路”，不能根据接口名补全不存在的硬件。当前公开生成 RTL 中，[`ct_idu_rf_prf_fregfile.v`](../C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_rf_prf_fregfile.v) 实现了 64×64 bit 的浮点物理寄存器存储，而 [`ct_idu_top.v`](../C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_top.v) 另外例化的两个 [`ct_idu_rf_prf_vregfile.v`](../C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_rf_prf_vregfile.v) 包装把读输出固定为零；D-cache 与 L2 中也保留了若干 ECC 端口和状态名，但当前生成配置的部分 ECC 编解码、纠错和错误重放路径被注释或常量关闭。因此，本文讨论当前有效标量/浮点、cache 和流水控制路径，不把未生效的向量寄存器或 ECC 逻辑算进关键路径。若另一配置恢复这些逻辑，端口 mux、宽数据线、syndrome/纠错选择和额外流水控制都要重新做 STA，不能沿用本文引用的路径排序。

后文保留若干时序和微结构常用缩写，以便与 RTL、SDC 和报告直接对应。CPI 是每条退休指令平均消耗的周期数，Fmax 是满足全部约束时的最高时钟频率；STA 是静态时序分析，MCMM 表示多工作模式、多 PVT 角联合检查，WNS 和 TNS 分别是最差负裕量与总负裕量。IFU、IDU、LSU、MMU 分别表示取指、译码/发射、访存和地址翻译单元；PRF、ROB、PST 分别是物理寄存器文件、重排序缓冲区和物理寄存器状态表。tag、ready、stall、replay、flush 在源码中分别表示标识/标签、操作数就绪、停顿、重放和流水清空。本文在第一次讨论具体机制时仍会解释其因果关系，而不是要求读者只凭缩写猜测。

## 2. 从触发器和晶体管延迟建立正确的时序直觉

对一个最基本的寄存器到寄存器路径，建立时间约束可以写成

```text
T_clk ≥ T_cq + T_comb + T_setup + T_uncertainty + T_skew_effect
```

前级触发器在时钟边沿后经过 `T_cq` 才输出新数据，数据再穿过组合门和连线形成的 `T_comb`，必须在后级触发器采样边沿前至少 `T_setup` 到达。时钟不确定度包含抖动、建模裕量和设计预留；时钟偏斜可能帮助或伤害某条 setup 路径，但不能把偶然有利偏斜当成逻辑设计方法。若数据晚到，后级可能采到旧值或进入亚稳态，这就是 setup violation。频率上限本质上由所有有效路径中最小的可用周期决定，而不是由 RTL 中最慢的一条运算名称决定。

保持时间检查看的是同一边沿之后，新数据是否过早冲到后级。其近似条件是前级最小 `T_cq` 加最小组合延迟必须大于后级 hold 要求和不利偏斜。增加流水级通常缩短最大组合路径，却会产生更多短路径，使 hold 修复更困难；CTS 后的真实 skew 也可能让综合阶段看似安全的短路径发生变化。setup 可通过降低频率来掩盖，hold 与周期无关，必须通过延迟单元、布线或时钟树调整修复。因此，一份只有 WNS 而没有 hold、transition、capacitance、fanout 和 clock-gating check 的报告，并不能证明时序完整。

门延迟来自晶体管给负载电容充放电所需时间。驱动晶体管更宽、阈值电压更低或供电更高，一般能提供更大电流、缩短延迟，却增加输入电容、动态功耗和泄漏。金属线的电阻与长度和截面积有关，电容来自对地及相邻线耦合；在大型乱序核心中，跨模块的广播、one-hot 选择、issue wakeup 和时钟线可能比局部逻辑门本身更慢。高扇出网络不只是“一个门带很多输入”：它通常需要缓冲树，树本身增加级数和功耗，而且远端 sink 的布线差异带来不同延迟。RTL 中的局部队列、重复 valid、分 bank、预比较和专门的 short path，都是在逻辑功能不变的前提下控制这些物理效应。

用一阶关系表示，门延迟大致与 `C_load · V_DD / I_on` 成正比，而导通电流 `I_on` 又强烈依赖 `V_DD - V_th`。这解释了为什么降低电压虽然按平方降低动态功耗，却会在电压接近阈值时迅速拉长延迟；也解释了为什么低阈值 LVT 单元适合挽救关键路径，却要付出更高泄漏。把驱动单元加大并非总能加速整条路径，因为它减小当前级输出电阻的同时，也增加前一级所见输入电容。综合和物理优化所做的 cell sizing、buffer insertion 与 Vt assignment，本质上是在整条 RC 链上重新分配延迟，而不是孤立地寻找“最快单元”。

输入转换时间同样会跨级传播。一个边沿很慢的信号使接收门的上下拉网络更长时间处于过渡区，既增加该门延迟和短路电流，也使输出边沿继续变慢；这就是 SDC 还要约束 max transition，而不能只检查 endpoint slack 的原因。长线适当插入缓冲可以把近似随长度平方增长的分布式 RC 延迟分段，但缓冲过多又增加单元延迟、面积和功耗。处理器中的高扇出 ready、flush、one-hot 选择与 cache 控制，最终都要在逻辑级数和物理线长之间同时优化。

PVT 决定同一网表在不同环境下的速度。慢工艺、低电压和高温常构成 setup 的不利组合，但先进工艺中温度反转等现象要求以库角为准；快工艺、高电压、低温通常更容易暴露 hold。片上变化、串扰、IR drop 和老化又会改变局部延迟。RTL 设计者可以缩短逻辑深度和扇出，却不能仅凭功能仿真证明这些角都收敛。可靠的结论必须经过多模式多角 STA，并在布局后使用提取寄生，而不是只用理想连线或 wire-load 模型。

## 3. C910 的总体时序方法：分割长路径，再补偿分割的性能代价

从源码可以归纳出三种反复出现的方法。第一种是 **空间分解**：把统一大结构拆成多个局部队列、cache bank 或 sub-bank，让比较和选择在较小物理范围内完成。第二种是 **时间分解**：在 SRAM 访问、乘法、浮点乘加、分支执行和 load 数据处理中插入明确寄存器边界，限制每周期的组合工作。第三种是 **信息前移**：某些决定不等完整数据到达才开始，而是在前一级预比较 IID、提前产生 ready、复制高扇出 valid，或者在新建指令进入队列的同周期直接旁路到 issue。前两种方法有利于频率，第三种方法则用额外控制和投机来减少新增流水边界对 CPI 的伤害。

这三种方法互相制约。拆分队列减少局部选择深度，却需要跨队列分配和全局结果广播；增加寄存器能阻断组合路径，却增加时钟负载、旁路距离和误预测恢复周期；提前唤醒能缩短依赖间隔，却可能在 load 发生 replay 时错误唤醒消费者。C910 的设计不能用“深流水所以高频”或“乱序所以能隐藏延迟”一句话概括。真正应观察的是一组具体闭环：生产者在哪一级产生 tag 和 data，消费者何时被标记 ready，旁路数据在哪一级可见，如果推测失败由谁取消，以及 flush 后前端多久重新形成有效退休。

还有一类容易遗漏的时序方向是**反压与恢复控制**。指令和数据的 valid 通常向后流动，而 queue full、stall、ready 等容量信息要向前返回；误预测、异常和 replay 又从执行或退休端横跨许多级取消年轻状态。若“后端满→重命名停止→译码停止→IFU 停止”被写成一条无寄存器的长组合链，或者一个 flush 直接驱动所有 queue entry 和流水 valid，控制路径会比局部 ALU 更难闭合。C910 中的 `stall_short`、`pcgen_chgflw_short`、重复 valid、分模块 cancel 以及提前 IID 比较，本质上都在缩短这些反向或横向路径。教学上应把流水线看成两张重叠的图：一张是操作数和指令向前流动的数据图，另一张是反压、唤醒、取消和重定向传播的控制图；后者虽然不直接计算程序结果，却经常决定 Fmax 和恢复周期。

## 4. 约束和现有综合报告告诉了我们什么

后端参考约束 [`ct_top.sdc`](../backend/syn/ct_top/v1-dc/local_scripts/ct_top.sdc) 将 `pll_core_clk` 建为 0.769 ns 周期，也就是 1300 MHz 目标，并设置 0.30 ns setup uncertainty、0.03 ns hold uncertainty、最大 fanout 32 和最大 transition 0.1 ns。单纯用 `0.769-0.30` 可得到 0.469 ns，但这只是同一时钟、单周期内部路径在进一步扣除 capture setup、clock-to-Q、实际 skew 等项之前的粗略上限，不是每条路径都可直接使用的完整组合预算。0.30 ns uncertainty 占目标周期很大比例，说明这是一套相当严格的综合目标；“约束为 1300 MHz”仍只表示工具被要求向该目标优化，不表示网表已经闭合到 1300 MHz。

该 SDC 同时建立了真实端口时钟 `CPU_CLK` 和虚拟 I/O 时钟 `V_CPUCLK`，普通输入/输出按半周期最大延迟约束，并把内部、输入到寄存器、寄存器到输出、输入到输出分成不同 path group。异步中断、调试和 reset 端口则用负的最大 I/O delay 或上层 `set_max_delay` 表达特殊环境假设；这种写法是约束建模手段，不能解释为外部信号在物理上“提前两个周期到达”。功能场景还用 case analysis 把 `pad_yy_scan_mode`、`pad_yy_icg_scan_en` 和可选 scan enable 固定为 0，所以当前报告只覆盖功能模式。扫描 shift/capture、MBIST、低功耗唤醒和上层 SoC 集成需要各自的时钟、I/O、case analysis 与例外场景；否则功能模式时序通过也不能代表其他模式通过。

仓库当前 [`qor.rpt`](../backend/syn/ct_top/v1-dc/reports/qor.rpt) 正好说明二者的区别。该综合快照在 `tt0p9v25c` 库角下，内部寄存器到寄存器组的最差 setup slack 为 -0.077 ns，TNS 为 -533.641 ns，有 16537 条该组路径违例；最差 hold 也为 -0.104 ns。报告使用理想时钟网络，层次中的 wire-load 又是 `ZeroWireload`，尚未包含真实布局布线、CTS、串扰和片上变化，所以它既不是 signoff 结果，也不能通过简单计算 `1/(0.769+0.077)` 就预测最终芯片频率。它能够证明的是：在这一套库、约束和综合设置下，当前快照尚未时序闭合。

最差路径的细节比汇总数字更有教学价值。[`INTERNAL_REG2REG_max.tim`](../backend/syn/ct_top/v1-dc/reports/INTERNAL_REG2REG_max.tim) 的首条路径从 IFU I-cache predecode SRAM 输出出发，到 `ifdp_ipctrl_w1_bry1_hit_reg` 结束；其中 SRAM clock-to-Q 约 0.500 ns，后续少量逻辑把到达时间推到约 0.536 ns，而扣除 0.30 ns uncertainty 后所需时间约 0.459 ns，最终形成 -0.077 ns slack。靠后的高排名路径还包括 load AG 基址或 D-uTLB 状态到 D-cache SRAM 端口。这个结果与 RTL 中前端 SRAM→预译码/分支边界识别，以及 LSU 地址生成/翻译→D-cache 请求这两类紧路径相互印证，但只能说明本次综合快照的排序，不能推导所有 PVT 和版图后的永久关键路径。

综合脚本 [`dc.tcl`](../backend/syn/ct_top/v1-dc/global_scripts/dc.tcl) 采用 delay 优先的 cost、`compile_ultra`，并输出每个 path group 的前 1000 条路径、transition、capacitance、nets 和 constraint violation。脚本显式关闭自动 register merging 与 register replication，这有助于保留 RTL 作者已经安排的状态边界和手工复制，但也意味着不能期待工具自动替代所有高扇出优化。脚本可选 topographical/SPG 和增量编译，当前报告仍不能替代布局后 STA。正确研究方法是把该快照作为基线，修复约束与路径后重新综合，再观察 WNS、TNS、违例端点分布、面积和功耗是否同时改善。

报告卫生也尚未达到可签核状态。[`check_design.rpt`](../backend/syn/ct_top/v1-dc/reports/check_design.rpt) 汇总了 82585 个未连接端口、28148 条无负载 net、6 个不驱动任何 net 的 cell，以及 322 项“同一 net 接到同一子模块多个 pin”的提示；其中大量项目可能来自生成层次、未启用特性、调试接口和常量折叠，并不等于存在同样数量的功能 bug，但每一类都必须按“有意未用、生成模板残留、约束遗漏、真实连接错误”分类关闭。[`check_timing.rpt`](../backend/syn/ct_top/v1-dc/reports/check_timing.rpt) 只留下检查项目标题和返回值，没有列出足以独立证明无 unconstrained endpoint、无时钟环或 I/O delay 完整的明细。因而，现有 QoR 可用于学习路径和建立相对基线，不能在约束/lint 分类完成前被提升为 signoff 证据。

## 5. PC 生成：控制优先级越丰富，下一 PC 路径越需要被精心分层

[`ct_ifu_pcgen.v`](../C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_pcgen.v) 的下一 PC 不是一个简单的 `PC + 4`。它要在异常/中断、RTU flush、分支执行重定向、预测目标、调试、cache refill 重发、顺序取指等多个来源之间按优先级选择。优先级 mux 的输入越多、条件越复杂，控制信号到 PC 寄存器的组合路径就越容易变长；同时，错误优先级会直接破坏精确异常或控制流，所以不能为了少一级门任意重排。RTL 将 change-flow 选择与正常顺序 `inc_pc` 路径分开，并提供 `pcgen_chgflw_short`、`stall_short` 一类提前或缩短控制路径，反映出作者在关键反馈环上有意识地避免让所有完整条件串联到最后一刻。

理解 `inc_pc` 还必须恢复内部地址编码。C910 内部 PC `[38:0]` 省略架构字节地址 bit 0，正常取指窗口为 16 字节。`inc_pc_hi = {if_pc[38:3]} + 1` 在内部表示上使架构地址前进 16 字节；它既不是 8 字节，也不是 cache line 大小。内部低三位代表 16 字节窗口内以 2 字节为粒度的位置，reissue 时保留当前位置。这个编码省掉一个恒为零的地址位，略微缩窄比较、加法和存储字段，但更重要的是使取指块边界直接参与控制。分析时序或波形若把内部位号当作完整字节地址，就会错误判断加法位宽、bank 选择和 line 边界。

PC 是一个高频闭环：本周期预测与重定向决定下一取指地址，下一周期的 cache/预测结果又继续决定之后的地址。给这条环路随意增加一级寄存器，虽然可能改善 Fmax，却会让每次 redirect 和部分预测事件多损失一个周期。因此，C910 更倾向于对选择条件做短路径、分级寄存和并行计算，而不是简单地把 PC mux 整体再打一拍。这是一类典型的“频率与分支 CPI”联合优化问题：应同时测 PC 路径 slack、mispredict penalty、redirect 到 IFU valid 的周期数以及程序 MPKI，不能只看一个组合门级数。

PC 选择得足够快，还依赖预测信息在第几拍可用。C910 为分支目标设置了容量与延迟分层。[`ct_ifu_l0_btb.v`](../C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_l0_btb.v) 用 16 个寄存器表项并行比较 15 bit tag，比较形成的 `entry_hit[15:0]` 先锁存到 `entry_hit_flop[15:0]`，再据此选择 target、RAS 标志和 I-cache way prediction。因此，L0 BTB 的“快”是相对主 SRAM BTB 而言，不能把它画成 PC 输入后同拍零延迟地产生目标。主 [`ct_ifu_btb.v`](../C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_btb.v) 在当前生成配置中由两块 512×22 tag SRAM 和两块 512×44 data SRAM 组成，同一行读出四个固定位置槽，总计 512 行×4 个物理槽；低位 PC 决定写入哪个槽，不能把它误解为带通用替换选择的常规四路组相联表。同步 SRAM 读出后，IF 级再比较四个候选 tag。这样的分层让少量热点目标走较小寄存器结构，让更大容量留在 SRAM 中，以免把大表访问和目标选择全部压进最早的 PC 反馈环。

目标预测和方向预测还必须分开理解：BTB 回答“若发生转移，目标在哪里”，BHT 回答条件分支“是否 taken”。[`ct_ifu_bht_pre_array.v`](../C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_bht_pre_array.v) 的 1024×64 predict SRAM 与 [`ct_ifu_bht_sel_array.v`](../C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_bht_sel_array.v) 的 128×16 select SRAM 并行提供 Bi-Mode 方向信息，结果再按取指块内分支位置和历史状态选择。BHT 内部同时维护 22 bit 投机历史 `vghr_reg` 和 22 bit 退休历史 `rtughr_reg`：前者随前端预测推进，使后续分支不必等到退休；发生 RTU flush 时，前者恢复为后者。[`ct_ifu_ras.v`](../C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_ras.v) 也采用 12 项前端投机栈和 6 项退休侧恢复副本。体系结构上，这种双状态设计把最新控制流上下文提前供给取指；时序上，它把“等待退休后再预测”的长串行依赖变为“先投机、错了再恢复”，代价是预测快照要随流水传递，flush 时还必须以正确优先级恢复 GHR、RAS 和下一 PC。观察波形时应把 L0/主 BTB 命中、BHT 方向、RAS 目标、预测时携带的历史快照以及最终 BJU 检查对齐，单看一个 `chgflw` 无法判断预测来自哪一层、为何出错。

## 6. I-cache、预译码与 MMU：让 SRAM 访问和物理 tag 判断在受控边界内会合

I-cache 命中路径同时面对三个时间源：SRAM 数据输出、地址翻译/物理 tag、以及预译码和取指窗口控制。[`ct_ifu_ifdp.v`](../C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_ifdp.v) 明确把用于命中判断的 tag 标为 physical tag，并写有 “For Timing consider, Tag compare split to four part”。代码没有用一个宽相等比较器直接完成全部物理 tag 比较，而是把 tag 分成 `28:24`、`23:16`、`15:8` 和 `7:0` 四段并行比较，再组合各段结果。宽相等比较本质上是许多 XNOR 后接归约 AND；切成四段不会消除总逻辑，却能形成平衡的局部比较和较浅的合并树，也便于布局时把比较器靠近相应 tag 位。

命中和预译码结果随后被寄存到 IP 相关状态，而不是让 SRAM 输出、完整 tag compare、指令边界判断和后续选择无边界地连成一条超长路径。前一节引用的综合最差路径落在 predecode SRAM 到 branch-boundary hit 寄存器，说明真正的宏延迟已经占掉大部分周期，宏之后哪怕只有少量逻辑也很敏感。优化这类路径不能只在 RTL 中重写布尔式：还需要检查 SRAM 宏的组织、输出寄存模式、predecode 是否应在 refill 时预计算、宏与 IFDP 的物理距离、输出负载和 uncertainty 设置。若把宏访问多加一级，时序容易改善，但取指 latency、分支发现时点和 miss/replay 控制都会变化，必须用 IPC 与恢复波形验证。

I-cache 的 way prediction 也是时序机制，不只是功耗机制。预测命中时，后续数据选择可以围绕一个 way 展开，避免等两路完整 tag 结果后再经过宽数据 mux；预测关闭或不可信时读取两路，功能更保守，但选择路径和负载更重。tag 在同一 64 字节 line 的后续 16 字节块可复用已有结果，又减少了每个顺序块都重新走 tag 宏和比较的需求。其代价是前端必须可靠维护 line 内位置、way 状态和 change-flow 情况，预测错误时能正确 reissue。这里的核心思想是以预测把一个本来串行的“先比较 tag、再选数据”路径变为并行或提前选择，再用恢复机制保证正确性。

MMU 与 cache 的会合不能被一句“TLB 并行查找”略过。指令侧 [`ct_mmu_iutlb.v`](../C910_RTL_FACTORY/gen_rtl/mmu/rtl/ct_mmu_iutlb.v) 有 32 个全相联比较项，但只有 entry 0、8、16、24 是四个 fast slot，最终快速 PA/属性 mux 从这四项读取。slow entry 命中并不直接当作 JTLB miss，而是与轮转选中的 fast slot 交换，IFU 保持或重新提出请求后再从 fast slot 完成。这个结构把“32 项容量命中判断”和“少量项的快速数据选择”分开：常用项路径较短，slow hit 要付出提升与重试周期。数据侧 [`ct_mmu_dutlb.v`](../C910_RTL_FACTORY/gen_rtl/mmu/rtl/ct_mmu_dutlb.v) 则用 16 个普通项加一个专用 1 GiB 页项服务两个 LSU 查询端口；它处在 AG 到 D-cache CEN 的常见 load/store 路径上，所以全相联 hit、PA 拼接、权限/PMP 和 bank 控制必须共同纳入时序，而不能只看 D-cache SRAM 自身。

两类 uTLB miss 都经仲裁进入 [`ct_mmu_jtlb.v`](../C910_RTL_FACTORY/gen_rtl/mmu/rtl/ct_mmu_jtlb.v) 的 1024 项 JTLB，即 256 组×4 路 SRAM。tag SRAM 每行 196 bit，正好容纳四份 48 bit tag 和 4 bit 替换指针；data 由两个 256×84 SRAM 承担四份 42 bit 数据。由于 4 KiB、2 MiB、1 GiB 页混存，JTLB 的 read FSM 先按 4 KiB VPN 片段索引，miss 后再按 2 MiB，最后按 1 GiB；这不是一次 SRAM 读后同时比较三种页尺寸，而是可能发生三次候选访问。它把大容量翻译和多页尺寸处理移出 L1 hit 关键路径，换来的代价是 uTLB miss latency 随实际页尺寸和前序候选 miss 增长。分析 TLB 时序时，应分别测 fast uTLB hit、slow-entry 提升、JTLB 4K/2M/1G 命中和最终 miss，而不能把它们平均成一个“TLB latency”。

三种 JTLB 候选都 miss 后，[`ct_mmu_ptw.v`](../C910_RTL_FACTORY/gen_rtl/mmu/rtl/ct_mmu_ptw.v) 才按 Sv39 最多读取三级 PTE。它没有独立 PTE cache，而是通过 `mmu_lsu_data_req` 借用 LSU/D-cache 路径，D-cache miss 时还会进入 RB/BIU；每级要等待数据返回、检查 PTE 与 PMP/PMA，再生成下一级地址，最后经仲裁回填 JTLB 和 uTLB。因此 PTW 主要是多周期延迟与资源占用问题，而不是把三次内存访问塞进一个组合关键路径。它仍会通过仲裁、TLB busy、LSU 端口和 refill 形成反压。完整的“cache hit latency”应按层次定义：L1 命中路径包括地址生成、uTLB、权限/PMP、bank CEN、tag compare 和数据选择；uTLB/JTLB miss 则是另一条多周期服务链，二者不能混为一个数字。

## 7. IBUF、PCFIFO 与译码：先解耦供需，再准确理解宽度

I-cache 每次返回的是一个 16 字节窗口，而 IDU 每周期最多接收三条指令；压缩指令又使“字节数”和“指令条数”不再固定对应。C910 用 [`ct_ifu_ibuf.v`](../C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_ibuf.v) 在两者之间建立 32 项 IBUF，每项保存一个 16 bit half-word 及其 PC、指令起始、异常和预译码属性。一次输入包最多涉及当前窗口的八个 half-word 和跨窗口保留的 H0，共九个候选；输出侧要从 32 项循环队列选择最多六个连续 half-word，再根据 16/32 bit 边界拼成最多三条 ISA 指令。这里的 `ibuf_full` 也不是“32 项全部有效”才置位，而是当前写指针向前第九个候选槽仍有效时就反压，提前保留能完整接收最大输入包的空间。这个保守阈值避免部分接收一包后产生复杂回滚，却会让少量尚空的 entry 在某些时刻不能被继续利用。

IBUF 同时提供 stored、merge 和 bypass 路径。若没有更老缓存内容阻挡，当前 IBDP 包可以直接拼装后送往 IDU，省掉“先写 entry、下一拍再读”的固定等待；代价是 half-word 对齐、`casez` 边界识别、异常属性选择和 IDU 接收条件会形成一条较长的前向组合捷径。IDU 的 `idu_ifu_id_bypass_stall` 又会禁止这条捷径，IBUF 的 `ibuf_ibctrl_stall` 则把容量压力返回取指控制。时序分析因此要分别检查正常 entry 读出路径和 bypass 路径，性能分析则要同时测 IBUF occupancy、full 周期、bypass 成功率以及“IFU 有 offer 但 IDU 未 accept”的周期；只测 I-cache hit 仍不能说明前端确实把指令送进了译码器。

控制流元数据还有一条并行队列。[`ct_ifu_pcfifo_if.v`](../C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_pcfifo_if.v) 把分支当前 PC、目标、BHT 预测和检查索引送到 IU 侧的 32 项 [`ct_iu_bju_pcfifo.v`](../C910_RTL_FACTORY/gen_rtl/iu/rtl/ct_iu_bju_pcfifo.v)，后续 BJU 用这些快照核对实际结果。PCFIFO 在写指针向前第五个位置仍有效时就拉高 `iu_ifu_pcfifo_full`，即为一次可能的多项创建预留至少六项窗口，而不是等所有 32 项占满；该 full 又参与 IFU 的更新和 stall 条件。把指令字节放在 IBUF、把控制流检查上下文放在 PCFIFO，可以避免每条普通指令都携带完整预测包，但两条 FIFO 必须保持同一程序顺序语义。若只优化一侧的指针、flush 或 backpressure 拍数，可能出现指令已送到 IDU，而预测快照未能创建，或者旧快照在重定向后仍被误用。波形中应把 IBUF 出队、PCFIFO create/PID、BJU 读取和 flush 对齐，验证解耦没有变成失配。

[`ct_idu_id_dp.v`](../C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_id_dp.v) 实例化三套主译码器，对应前端送入的最多三条架构指令；[`ct_idu_id_ctrl.v`](../C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_id_ctrl.v) 又处理指令拆分。某些复杂指令可拆成多个内部操作，因此 [`ct_idu_ir_dp.v`](../C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_ir_dp.v) 和 rename/dispatch 边界存在 inst0 到 inst3 四个内部槽位。准确表述应是“最多三条 ISA 指令进入主译码，拆分后可形成最多四个内部操作参与后续 rename/dispatch”，而不是简单称为“四发射译码”。这一区分关系到控制复杂度：第四槽位并非独立的第四条任意 ISA 指令，资源检查还要保持拆分操作之间的原子性和顺序。

宽译码的时序压力来自并行译码之外的跨指令检查。指令长度、异常、拆分、寄存器依赖、执行队列类型和下游资源必须共同决定能推进多少条；前一条指令是否拆分还会改变后面槽位的映射。C910 在控制中存在专门的 bypass timing optimization，说明部分条件被提前形成或从常规控制链旁路。设计时不能只优化每个 decoder 的 opcode case，常见关键路径反而是“多个 decoder 结果→跨槽位资源判断→stall/pipedown”。若要实测，应把 ID 输入 valid、各槽 split、IR create valid、stall 原因和下游 full 同周期对齐，区分译码本身慢与资源反压。

重命名进一步引入多端口表查找、free-list 分配和同组内依赖传递。四个内部槽可能在同一周期创建物理目的寄存器，后槽若读取前槽刚写的架构寄存器，必须拿到新映射而非旧映射。这类组内 rename bypass 会形成从前槽译码/目的信息到后槽源映射的组合链。物理寄存器表的多组 create 输入和 one-hot 分配则产生扇出。C910 通过明确的 IR/RT/FRT 模块边界把这些职责拆开，但最终最慢链应由 STA 端点和 cone 分析确认，不能仅凭模块名判断。

## 8. 分布式 issue queue：缩短局部 wakeup-select，但没有消灭广播

统一 issue window 的关键路径通常是“结果 tag 广播→所有源 tag 比较→ready 形成→最老 ready 选择→执行端口 mux”。队列项数和发射端口数增长时，比较器数量、年龄矩阵、归约树和布线长度快速上升。C910 把操作按执行类型分到 AIQ0/1、BIQ、LSIQ、SDIQ、VIQ0/1 等队列，AIQ/VIQ 为 8 项，BIQ/LSIQ/SDIQ 为 12 项。这样，整数 ALU 的 oldest-ready 选择不必穿过所有 load、store-data 和浮点项，布局也可以让队列靠近对应执行端口。它以跨队列均衡灵活性为代价，换取较小的局部比较域和更可控的线长。

[`ct_idu_is_aiq0.v`](../C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_is_aiq0.v) 的 age vector 维护项间新旧关系，并从 ready 项中选最老者。RTL 对部分 age 逻辑做 timing split，同时在队列为空、新建 create0 已 ready 时允许 create-to-issue bypass。没有这个 bypass，一条完全独立的指令也要先写入 entry，至少下一周期才能被选择；加入 bypass 后，新建控制、ready 和执行选择在一个周期会合，降低空队列延迟，却形成一条新的组合捷径。因此它只覆盖受控条件，而不是让所有四个 create 槽都无条件旁路，否则 mux、冲突判断和扇出可能得不偿失。

结果广播仍然存在。每个源操作数需要比较多个潜在生产者，比较命中后更新 ready 或选择旁路数据。分布式队列减少每个选择器的规模，却不能让生产者 tag 不再跨模块传播。物理实现中应重点观察 broadcast tag/data 的扇出、缓冲级数、队列到执行单元距离和门控使能到 entry 的路径。若某类 not-ready 周期很多，原因也不一定是 issue select 慢：它可能在等 load data、乘法结果、分支串行依赖，或者对应生产者根本尚未 issue。时序分析负责回答“信号能否在一个周期到达”，性能计数器和波形负责回答“生产者为何尚未产生信号”，两者必须结合。

## 9. PRF 与旁路：用更多比较和布线换回依赖链周期

若消费者必须等待生产者写回物理寄存器，再从 PRF 读取，紧邻依赖的 ALU 指令会多出若干空周期。C910 的 [`ct_idu_rf_fwd_preg.v`](../C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_rf_fwd_preg.v) 对每个整数源寄存器并行比较六类生产来源：pipe0/pipe1 的 EX1 forward、两路 EX2 write-back、LSU DA forward 和 LSU WB。命中向量再选择对应的 64 bit 数据。功能上，这让最新结果绕过 PRF 存储边界直接进入消费者；时序上，它在源寄存器编号到达后同时启动六个 7 bit 比较，并在多路 64 bit 数据之间选择，是典型的高扇出、高布线成本网络。

旁路网络的困难不是 RTL case 只有六项，而是同类逻辑会复制到多个源端和执行 pipe，生产者数据又要驱动许多远端 mux。为了满足时序，物理设计可能需要复制 tag/valid、分层数据 mux、把执行单元靠近消费者或减少不常用路径。[`ct_idu_rf_fwd.v`](../C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_rf_fwd.v) 中有一处明确注释，出于 timing optimization，某条 VFPU 到 LSU mask source 的 forwarding 没有在该路径启用。这体现了实际设计原则：全连接旁路理论上能把所有依赖延迟降到最低，但低使用率的长旁路可能拖慢所有普通路径；有选择地让少数情况多等一拍，反而能提高整体频率和能效。

PRF 本身有 96 个整数物理寄存器、多个读写需求。扩大寄存器数可以容纳更深的乱序窗口，却会增加编号位宽、译码、读取 mux 和布线。C910 对写入采用 one-hot 逐项门控，但读取和旁路仍要在周期预算内完成。分析 PRF 时序时应区分三类路径：issue 选择到读地址、寄存器数据到执行输入、执行结果经 forward mux 到下一依赖。仅修复 write-back 到寄存器的路径，可能对真正的 back-to-back dependency 没有帮助。

## 10. 分支执行与恢复：为什么结果在 EX1 算出，却从 EX2 重定向

[`ct_iu_bju.v`](../C910_RTL_FACTORY/gen_rtl/iu/rtl/ct_iu_bju.v) 在 RF/EX1 边界接收分支操作数，EX1 组合逻辑计算条件方向、目标地址和预测是否错误，然后把结果寄存到 EX2；面向 IFU 的 change-flow、PCFIFO 更新和完成信号由 EX2 寄存状态产生。RTL 还明确把 IID age compare 移到 RF 级作为 timing optimization，并在 EX2 展开 PID 以减轻后续时序。也就是说，设计没有强迫“操作数比较、目标加法、误预测判定、年龄判断、全局重定向”全部在同一周期末端串行完成，而是把可提前的信息放到 RF，并让 EX1 结果经过 EX2 边界再驱动恢复。

这个选择提高了分支路径的可实现性，却使真实误预测从执行到前端重定向至少经过明确的 EX2 边界。每增加一个恢复周期，错误路径可能继续取指、译码或占用后端资源，分支密集程序的 CPI 会明显上升；反过来，若硬把 redirect 提前到 EX1，长距离 IFU 反馈和高扇出 cancel 可能降低全核频率。评价分支设计必须同时测 BJU RF→EX1 与 EX1→EX2 slack、EX2 redirect 到新路径 fetch/retire 的周期数、分支 MPKI 和每次误预测损失，而不是只比较预测准确率。

年龄比较前移还有精确状态含义。乱序执行中可能同时出现多个 change-flow 或异常候选，系统必须选择体系结构上最老、真正应生效的事件。把 IID compare 提前不代表放松顺序，而是预先计算“谁更老”的控制信息，使最终 redirect 级只做较短选择。类似手法在 LSU replay、PST retire 和 ROB 控制中反复出现，说明年龄/IID 比较是宽乱序机器的重要时序负担。

## 11. 乘法、除法和浮点：不同操作采用不同的延迟/吞吐取舍

[`ct_iu_mult.v`](../C910_RTL_FACTORY/gen_rtl/iu/rtl/ct_iu_mult.v) 将 65×65 乘法计算跨 EX1 到 EX3 流水推进，并在 EX4 寄存与选择最终 64 bit 结果。完全组合的 65 bit 乘法会包含部分积生成、压缩树和末级加法，很难在短周期内完成；分成多级后，每级逻辑深度受控，并可让连续乘法重叠执行。其代价是单条依赖链仍要等待多个周期，所以 ready/tag 何时提前广播、真实数据何时 forward 必须严格匹配。提前唤醒若比数据早一拍，可以把消费者送到 RF 等待数据；若生产者异常或被取消，则还要保证消费者不会使用无效值。

浮点乘加控制 [`ct_vfmau_ctrl.v`](../C910_RTL_FACTORY/gen_rtl/vfmau/rtl/ct_vfmau_ctrl.v) 明确维护 EX1 至 EX5，各级有自己的 pipedown 和门控时钟。FMA 需要乘法部分积、加数对齐、加法/压缩、规格化、舍入和异常标志等步骤，分级可以把复杂数据通路切开，也让吞吐与单次 latency 分离：一条结果需要多周期，但流水填满后可接受更密集的独立操作。前提是每一级都能按目标周期闭合，且旁路、异常与 write-back 端口没有形成新的瓶颈。

整数除法 [`ct_iu_div.v`](../C910_RTL_FACTORY/gen_rtl/iu/rtl/ct_iu_div.v) 与浮点除法/开方 [`ct_vfdsu_ctrl.v`](../C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_ctrl.v) 采用迭代 SRT。状态机先做绝对值和特殊情况处理、移位/规格化，再在执行状态中重复迭代，完成后进入结果和写回级。迭代结构避免把许多轮除法逻辑完全展开，容易达到较高时钟频率并节省面积，但吞吐和延迟取决于迭代次数，单元忙时后续除法必须等待。对除法性能的时序判断应分成“每一轮 SRT 能否闭合目标周期”和“算法需要多少轮”两层；前者是 STA 问题，后者是微结构 latency 问题。

## 12. Load 流水：地址、翻译、SRAM、转发和推测唤醒形成最复杂的闭环之一

C910 的 load 主路径可按 RF→AG→DC→DA→WB 理解。[`ct_lsu_ld_ag.v`](../C910_RTL_FACTORY/gen_rtl/lsu/rtl/ct_lsu_ld_ag.v) 在 AG 级完成基址加偏移、地址属性和翻译接口，并形成 D-cache tag/data 请求；[`ct_lsu_ld_dc.v`](../C910_RTL_FACTORY/gen_rtl/lsu/rtl/ct_lsu_ld_dc.v) 接收 cache 输出、做两路 tag 预比较和数据预选择；[`ct_lsu_ld_da.v`](../C910_RTL_FACTORY/gen_rtl/lsu/rtl/ct_lsu_ld_da.v) 再处理 SQ/WMB 字节转发、cache way 选择、数据合并、旋转与符号扩展，并决定正常前递、replay 或创建 refill buffer。每一级都只承担一部分工作，否则“地址加法→TLB/PMP→SRAM→tag compare→store forwarding→对齐扩展→旁路”不可能在一个短周期内完成。

AG 级有多处直接针对时序的代码。跨页判断利用低 12 bit 加法的 carry 与高位检查，避免所有地址属性都等待完整宽加法；AG stall 时允许特定更老 RF 指令继续推进，减少一个局部阻塞把整条 LSU pipe 冻结；送往 DC 前还预比较 IID，缩短下一阶段决定 restart 的年龄判断。DC 级对 valid 做复制，以减轻单一控制位驱动大量逻辑的扇出，并提前形成 way/tag 与数据旋转信息。DA 级才汇总复杂的 byte forwarding 和最终数据选择。这些“预计算、复制、分级”的共同目的，是不让任何一级同时承担全部地址和数据语义。

load-use 性能又迫使设计在数据完全确认前提供快速路径。DC/DA 可以在预计 cache hit、无冲突时产生提前 write-back/forward 信息，使依赖消费者较早唤醒；如果随后发现 store-load 顺序冲突、cache miss、权限问题或其他 hazard，就必须产生 spec-fail/restart，取消错误推进并重放。C910 还有专门的 spec-fail predictor，用历史行为避免反复对高风险 load 做同样激进的推测。这里形成一个清晰的体系结构权衡：推测越激进，常见 hit 依赖链越短，但 replay 的概率和恢复能量越高；推测越保守，正确性控制简单，却让所有 load-use 都按最坏情况等待。

ECC 在这一段必须按当前配置单独说明。[`ct_lsu_ld_da.v`](../C910_RTL_FACTORY/gen_rtl/lsu/rtl/ct_lsu_ld_da.v) 虽然保留 `ecc_stall`、`ecc_spec_fail` 等控制接口，八个 32 bit decoder 实例却被注释，相关 stall/error/spec-fail 输出固定为零；L2 的 ECC array 和部分修复响应也有同类常量关闭。因此，当前网表的 load replay 原因不能把 ECC 计入，现有 STA 也不包含完整 syndrome 生成、纠错 mux 和修复写回路径。若产品配置恢复 SECDED 一类保护，常见做法可能是让未纠错数据用于推测旁路、随后校验失败再 replay，或把纠错直接放进返回路径；前者增加恢复复杂度，后者增加 hit latency。究竟采用哪一种必须由启用后的 RTL 证明，不能从当前预留信号名反推。

现有综合报告中，load AG 基址寄存器或 D-uTLB entry 到八个 D-cache bank SRAM 的路径进入高排名路径，正好表明“在一个周期内生成可用物理索引和 SRAM 控制”很紧。优化方向可能包括缩短 AG 加法/属性 cone、降低 TLB 命中输出扇出、提前 bank select、调整 SRAM setup 模式或改善物理邻近性，但每一种都可能改变 cache latency、跨页 replay 或端口冲突。不能仅通过把 D-cache CEN 寄存一拍就宣布修复，因为这会系统性增加所有 L1 hit latency，可能让 CPI 损失大于频率收益。

store 路径则把地址与数据解耦到 LSIQ 和 SDIQ，LSU pipe4 处理 store address/control，pipe5 处理 store data。地址可以先用于内存顺序检查和 cache/tag 操作，数据在准备好后再汇合；WMB 让已退休 store 在后台完成下层写出。解耦减少“地址依赖未好”和“数据依赖未好”互相阻塞，也允许两个较小选择网络代替一个同时等待所有源的大队列。代价是地址、数据、IID 和字节掩码必须可靠配对，flush 与异常还要同步取消。时序优化不能破坏这一配对协议。

## 13. ROB、PST 与退休：精确状态的宽控制同样需要提前计算

C910 的 ROB 有 64 个物理 entry，一个 entry 可通过完成计数折叠表示最多三条 ISA 指令，退休端有 commit0、commit1、commit2 三个槽。折叠减少 ROB 元数据容量压力，却使 head entry 的完成、异常和指令数解码更复杂：退休逻辑不仅要判断 entry 是否完成，还要知道其中有几条架构指令、异常属于哪一条、后续 entry 能否同周期继续退休。若把“head 选择→完成判断→异常优先级→PST 更新→free list 释放→前端 flush”全放在一条组合链上，退休会成为全核控制关键路径。

[`ct_rtu_pst_preg_entry.v`](../C910_RTL_FACTORY/gen_rtl/rtu/rtl/ct_rtu_pst_preg_entry.v) 为物理寄存器维护 DEALLOC、等待分配、ALLOC、RETIRE、RELEASE 等状态，并明确在前一周期预比较 retire IID。这样，真正退休周期到来时，不必让 96 个物理寄存器项都从零开始做宽 IID 比较，再生成释放向量。信息前移缩短了退休控制，却要求前一周期的候选与下一周期实际 retire 保持一致，遇到 flush、异常或 stall 时要正确屏蔽。它与 BJU 把年龄判断前移、LSU 预比较 IID 属于同一类方法：顺序信息是乱序核心中的高扇出控制，应尽早在局部形成。

ROB/PST 还是许多全局恢复的起点。一次异常或误预测会取消年轻指令、恢复映射、释放资源并重定向 IFU。恢复信号若直接广播到每个 queue entry、PRF 状态和流水寄存器，物理扇出巨大；若分级传播，恢复又可能多花周期。RTL 中的局部门控、entry cancel 和模块化 flush 共同承担这个问题。最终应从 STA 中按 flush/cancel net 查 fanout 和 endpoint，并在波形中测从 BJU/RTU 事件到各级 valid 清空的周期，才能判断设计是在频率还是恢复 latency 上受限。

## 14. L2 与 CIU：用可配置宏延迟和分 bank 限制共享层次的路径

1 MiB、16 路 L2 不可能按一个小寄存器阵列的方式处理。[`ct_l2c_sub_bank.v`](../C910_RTL_FACTORY/gen_rtl/l2c/rtl/ct_l2c_sub_bank.v) 把请求依次组织为 tag、compare、data 和 write-back 相关 stage，tag/status SRAM 输出后并行比较 16 路，再由 compare 状态决定 data 访问、响应或 refill。16 路并行比较扩大比较器数量，但避免串行检查 way；后续 one-hot hit、替换和一致性状态选择则必须控制归约深度与布线。两个 sub-bank 让独立请求在较小局部范围内处理，减少单体 1 MiB 结构的控制扇入，也使物理布局可以围绕各自 SRAM 宏展开。

[`ct_l2c_top.v`](../C910_RTL_FACTORY/gen_rtl/l2c/rtl/ct_l2c_top.v) 先把 `tag_setup + tag_latency` 相加并钳位到 0 至 4，把 `data_setup + data_latency` 相加并钳位到 0 至 8，再分别送给 [`ct_l2c_tag.v`](../C910_RTL_FACTORY/gen_rtl/l2c/rtl/ct_l2c_tag.v) 与 [`ct_l2c_data.v`](../C910_RTL_FACTORY/gen_rtl/l2c/rtl/ct_l2c_data.v) 的访问倒计数器。setup 模式还会先寄存 SRAM 的 CEN、index 和写数据，使外部组合输入不必直接压到宏端口。这个接口说明 RTL 没把某个特定 SRAM 宏的固定延迟硬编码到协议中，而是允许实现根据宏时序选择输入 setup 和等待周期。计数字段只描述宏包装内部的等待，不等于完整请求到响应 latency；tag、compare、data、WB stage、仲裁和下游 backpressure 仍会增加周期。代价是 L2 hit latency 随配置变化，CIU 和完成队列必须依赖 valid/ready 关系，不能假设一个未经配置确认的固定拍数。

CIU 的 PIU 按 cacheable 请求地址 bit 6 把读写路由到 SNB0 或 SNB1，可在 [`ct_piu_top.v`](../C910_RTL_FACTORY/gen_rtl/ciu/rtl/ct_piu_top.v) 中直接看到。由于 cache line 是 64 字节，bit 6 让相邻 line 在两个 snoop node bank 间交织。这样既提高并发，也避免所有请求、snoop 地址匹配和 response arbitration 汇聚到一个巨大节点；但跨 bank 的 barrier、victim、外部总线和一致性响应仍需要仲裁。共享层次的时序重点通常不只是 tag compare，还包括多主请求仲裁、地址依赖比较、宽 512 bit 数据返回和 backpressure。RTL 分 bank 是控制物理复杂度的前提，最终还要靠 floorplan 让相关 SRAM、SNB 和数据通道真正邻近。

## 15. 时钟门控本身也有时序，不能把门控条件当普通数据随意处理

统一 [`gated_clk_cell.v`](../C910_RTL_FACTORY/gen_rtl/clk/rtl/gated_clk_cell.v) 在 ASIC 宏模式下把 `global_en`、`module_en`、`local_en` 和 `external_en` 汇合后送入集成 ICG。集成门控单元通常在时钟低相位锁存 enable，避免 enable 在高相位改变时截断脉冲；这意味着 enable 有专门的 clock-gating setup/hold 要求。一个由复杂队列状态在周期末端才形成的 `local_en`，可能让数据路径本身闭合而门控检查失败。门控越细，使能逻辑越多，越需要 STA 单独审查 ICG enable path。

这里的 `module_en` 不是模块关闭信号。其有效表达式是 `(global_en && (module_en || local_en)) || external_en`，所以 `module_en=1` 会在 global 允许时强制局部门控开钟。[`ct_cp0_regs.v`](../C910_RTL_FACTORY/gen_rtl/cp0/rtl/ct_cp0_regs.v) 用 `MHINT2[22:14]` 分别控制 IFU、IDU、IU/regs/HPCP、LSU、MMU/PMP、BIU、RTU、VFPU 和 core 的强制开钟，复位后全为零。这个机制对时序调试很有用：逐模块强制开钟可区分功能数据路径问题与 ICG enable/门控时钟问题；但最终 STA 仍要同时检查默认门控模式和必要的 force-open/测试模式，因为使能常量不同会改变传播路径、时钟树活动与被分析端点。

测试使能 `pad_yy_icg_scan_en` 能强制传播门控时钟，但它也是高扇出控制，功能模式约束通常用 case analysis 固定为 0，扫描模式则需要另一套时序场景。全局 [`ct_clk_top.v`](../C910_RTL_FACTORY/gen_rtl/clk/rtl/ct_clk_top.v) 在通用 RTL 路径使用 `BUFGCE` 模型，ASIC 流程中的真实时钟源、门控和 CTS 映射必须由实现环境确认。功能仿真中一个透明门控模型能避免大量时钟 X 与工具兼容问题，却不能替代 generated-clock 建模和 CTS 后 skew 分析。

时钟门控还会改变 hold 与偏斜。门控单元插在某个分支根部后，下游时钟树深度与相邻未门控分支不同；跨门控边界的数据路径可能看到不同 insertion delay。合理 floorplan 会把 ICG 放在它驱动的局部寄存器群附近，并限制 fanout；过于分散的 sink 会让门控树重新长成大树，既损功耗也损时序。RTL 只能表达逻辑层次，实际门控收益和偏斜必须在 CTS 后检查。

## 16. 为什么 RTL 看起来合理仍不等于时序闭合

逻辑综合阶段可能使用理想或粗略线模型，而处理器最困难的路径往往恰好是长线主导：结果广播、flush、ready、one-hot release、cache 数据和跨模块 redirect。布局后，宏位置决定 SRAM 输出到逻辑的距离，电源网压降改变单元速度，拥塞迫使关键网络绕行，串扰又改变有效延迟。某条 RTL 上门级很少的路径，可能因一根跨核长线成为关键；另一条逻辑较深的局部路径，则可通过紧凑布局和 LVT 单元轻松闭合。

因此，完整流程至少包括约束审查、综合 STA、floorplan 与宏摆放、placement 优化、CTS、route、寄生提取和 MCMM signoff。每一步都应检查 setup/hold、max transition、max capacitance、max fanout、clock-gating checks、recovery/removal、CDC/RDC 和例外路径。false path 与 multicycle path 必须有功能协议证明，不能为了让报告变绿而添加。对于 L2 可配置 latency、异步中断同步、调试 JTAG 和低功耗唤醒，尤其要确认模式与 generated clock 定义覆盖完整。

异步 reset 和异步唤醒还需要把“功能同步正确”与“时序例外正确”分开。异步复位的 assertion 可不依赖时钟，但 deassertion 必须满足 recovery/removal，通常要求在各目标时钟域同步释放；中断、调试和 snoop 唤醒即使通过同步器进入核心，也要对同步器首级做恰当的 CDC/false-path 建模，并继续检查同步器之后的功能路径。把整个信号从输入到所有终点都设成 false path 会掩盖同步器之后的真实问题，完全按普通单周期路径约束又会制造无意义违例。当前 SDC 对这些端口采用特殊 I/O delay，因此上层集成时必须用真实协议和时钟关系复核，而不能只继承文件中的占位假设。

现有综合快照还暴露出一个常见误区：WNS 只差 0.077 ns 看似很小，但 TNS 超过 500 ns、违例路径上万，说明问题不是孤立单元换大一档就一定解决；同时 0.30 ns uncertainty 很保守，约束意图也需要确认。应先按 endpoint/cone 聚类路径，判断大量违例是否由同一 SRAM 宏延迟、同一时钟不确定度、同一高扇出控制或同一层次建模造成，再决定修改 RTL、宏配置、约束还是 floorplan。只修报告第一条路径，下一批同构路径会立即顶上来。

## 17. 用体系结构指标指导时序优化，而不是盲目加寄存器

对 IFU 路径，应同时观察 SRAM→predecode/tag 的 slack、前端每周期 offer/accept、I-cache miss、L0/主 BTB 命中、BHT/RAS 预测类型、IBUF 水位、PCFIFO full、redirect 恢复和分支 MPKI。若路径违例来自 predecode 宏，而前端供给本来充足，可以考虑增加边界并量化额外 latency；若前端已经是性能瓶颈，再加一拍可能使 IPC 更差，此时优先研究宏组织、预译码生成时点和物理布局。对 issue 路径，应把 wakeup/select slack 与 not-ready 原因、队列 occupancy、满队列反压和执行端口利用率结合；队列缩小可能改善时序，却可能让 dispatch 更频繁被 full 阻塞。

对 load 路径，应把 AG/TLB/D-cache 时序与 L1 hit latency、load-use 间隔、forward 命中、spec-fail/replay 和 miss 并行度结合。把 hit latency 从三拍变四拍也许能提高频率，但若程序含大量串行 load-use，频率收益未必补得回 CPI；相反，若工作负载有足够内存级并行度，乱序窗口能隐藏额外一拍，较高频率可能净获益。对分支路径，则比较 redirect 提前一拍带来的 MPKI×penalty 收益，与 EX1 到 IFU 长反馈导致的全核周期损失。

对地址翻译还要单独记录 fast iuTLB hit、slow iuTLB 提升、duTLB hit、JTLB 按 4K/2M/1G 的访问次数、PTW 次数及每级 PTE 的 cache 命中。这样才能判断一个 MMU 改动是在缩短常见 L1 路径，还是只减少少见但很长的 miss 服务时间。若为了缩短 32 项比较而让更多 iuTLB 命中走 slow-slot 提升，Fmax 可能改善但前端供给率下降；若给 PTW 增加 PTE cache，它通常不影响每次 uTLB hit 的关键路径，却会增加面积、泄漏和维护一致性。时序实验必须把路径类与事件频率相乘，才知道哪一类值得优先优化。

把上述路径放在一起，统一评价量应是固定工作负载的执行时间：

```text
Execution time = Instruction count × CPI × T_clk
```

而不是单独最大化 `1/T_clk`。

实验时每次只改变一个可解释机制，先用轻量 kernel 验证功能和局部周期，再对同一基线全量运行代表性程序。时序侧保留 WNS/TNS、违例端点分类、面积、buffer/LVT 数和功耗；体系结构侧保留 IPC、退休宽度、前后端 stall、分支恢复、issue not-ready、load replay 和 cache miss。若 Fmax 改善但程序时间变差，说明流水代价超过频率收益；若综合 slack 改善而版图后恶化，说明修改可能扩大了线长或拥塞；若某条路径只在不真实的模式下违例，应修正约束或模式证明，而不是改功能 RTL。

## 18. 总结：C910 的高频设计是一组闭环取舍

C910 在前端用 PC 短控制路径、L0/主 BTB 分层、投机历史恢复、way prediction、同 line tag 复用、物理 tag 分段比较和预译码边界控制取指环路，再以 IBUF 和 PCFIFO 分别承接指令流与控制流检查快照；在地址翻译中用四个 fast iuTLB 槽承担快速 PA 选择，把 1024 项 SRAM JTLB 和最多三级 PTW 移出常见命中路径；在译码与重命名中区分三条 ISA 输入和最多四个拆分后内部操作，避免用错误宽度理解资源链；在后端用分布式 issue queue、局部 age vector、create-to-issue bypass、PRF 多源旁路和提前 IID 比较限制 wakeup、选择与精确状态路径；在执行端把乘法、FMA 和除法按其运算特征分别做深流水或迭代；在 LSU 中把地址、翻译、cache、转发和对齐分到 AG/DC/DA/WB，并用推测唤醒与 replay 补偿 load latency；在 L2/CIU 中用 sub-bank、分 stage 和可配置 SRAM 访问周期适配共享存储层次。

贯穿这些机制的原则不是无限加深流水，而是把每周期必须完成的工作压到可实现范围，同时把关键依赖所需的信息尽量提前。寄存器边界解决逻辑深度，分区解决物理跨度，复制解决扇出，旁路和推测解决新增延迟，恢复协议解决推测错误。任何一项单独加强都会把压力转移到另一项：更强旁路增加布线，更大窗口增加选择，更早 redirect 增加长反馈，更深流水增加恢复代价。因而，C910 的时序设计应被理解为 Fmax、CPI、面积、功耗和验证复杂度共同形成的闭环，而最终结论必须由 RTL 路径、STA 证据和程序级实测三者共同支撑。
