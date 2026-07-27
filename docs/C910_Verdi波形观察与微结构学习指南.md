# C910 Verdi 波形观察与微结构学习指南

本文面向一个明确目标：不只在 Verdi 中确认“程序跑通了”，而是借助波形理解
C910 的整体架构、乱序超标量处理器的核心机制，以及这些机制在真实程序中的协同方式。

本文的信号名称和层次基于当前 OpenC910 RTL 与 `smart_run/logical/tb/tb.v` 核对。
信号均为现有 RTL 观测点，不要求修改处理器功能逻辑。文中路径使用简称，先在第 2 节
展开为当前 `smart_run` 仿真的完整层次。

---

## 1. 先建立正确的波形观察方法

### 1.1 不要把乱序核当作五级顺序流水线

在简单顺序核中，可以沿着 `IF PC -> ID PC -> EX PC -> WB PC` 跟踪一条指令。
C910 不能这样观察，原因有四个：

1. 指令在译码、重命名之后进入不同发射队列，执行次序不再等于程序次序。
2. 普通执行通路不会在所有阶段都携带完整 PC，PC 主要保存在 IFU 和 RTU。
3. 一条架构指令可能拆成多个内部操作，多条简单指令也可能折叠进一个 ROB 项。
4. 年轻指令可以先完成，但必须等待更老指令之后按序退休。

因此需要同时使用四类“身份证”：

| 身份 | 主要作用 | 使用范围 |
|---|---|---|
| PC | 对应反汇编、函数和程序语义 | IFU、分支、退休端 |
| IID | 跟踪一条在途微操作的发射、执行和完成 | IDU、IU、LSU、VFPU、RTU |
| preg/vreg | 跟踪生产者、消费者和数据依赖 | 重命名、IQ、前递、写回 |
| AXI ID/地址 | 跟踪一次缓存行或外部存储事务 | BIU、CIU、L2、外部存储 |

IID 是 7 位环形编号，会循环复用。只能在一个有限时间窗口中，结合对应 `valid`
信号使用，不能把相隔很远的两个相同 IID 当成同一条指令。

### 1.2 所有数据必须先看有效条件

波形分析最常见的错误，是看见地址、IID 或数据变化就认为发生了事件。正确规则是：

- 流水级数据只有在该级 `*_inst_vld` 为 1 时有效。
- `valid` 表示发送方有请求，`ready/grant` 表示接收方可以接收。
- 握手事件通常是 `valid && ready` 或 `req && grant`。
- `stall=1` 时寄存器可能保持，因此同一 valid 连续多拍不等于多条指令。
- `flush` 后的年轻指令属于错误路径，即使已经执行，也不能算有效工作。
- `full` 是容量状态；只有它向上游形成 stall，才能证明它真正限制了性能。

### 1.3 完成、写回、提交和退休不是同一件事

| 动作 | 含义 |
|---|---|
| 完成 `cmplt` | 执行单元通知 ROB：该 IID 对应的执行工作已经完成 |
| 前递 `fwd` | 结果尚未正式写回，但已直接送给依赖它的消费者 |
| 写回 `wb` | 结果写入物理寄存器堆 |
| 提交 `commit` | ROB 允许该项产生不可回滚的体系结构效果 |
| 退休 `retire` | 指令按程序顺序离开 ROB，体系结构状态正式推进 |

C910 的部分定长执行单元可以提前向 ROB 报告完成，而数据稍后才写回。因此
`cmplt=1` 不自动等价于“消费者现在一定能读到数据”。观察依赖时还必须看前递和写回。

### 1.4 推荐的 Verdi 显示设置

- PC、地址、IID、preg/vreg、指令编码使用十六进制。
- 队列占用数、计数器使用无符号十进制。
- valid/ready/stall/full/flush 使用二进制。
- 每个机制建立独立 Signal Group，不要一次把整个核拖入波形窗口。
- 观察单条指令时使用约 20~100 周期窗口；观察缓存 miss 时扩展到数百周期。
- 始终把 `tb.clk` 放在每个组最上方，并以有效时钟上升沿判断时序。

---

## 2. 当前仿真的层次简称

```text
TB    = tb
CPU   = tb.x_soc.x_cpu_sub_system_axi.x_rv_integration_platform.x_cpu_top
TOP   = CPU.x_ct_top_0
CORE  = TOP.x_ct_core

IFU   = CORE.x_ct_ifu_top
IDU   = CORE.x_ct_idu_top
IU    = CORE.x_ct_iu_top
LSU   = CORE.x_ct_lsu_top
VFPU  = CORE.x_ct_vfpu_top
RTU   = CORE.x_ct_rtu_top
CP0   = CORE.x_ct_cp0_top

MMU   = TOP.x_ct_mmu_top
BIU   = TOP.x_ct_biu_top
PMP   = TOP.x_ct_pmp_top
HPCP  = TOP.x_ct_hpcp_top

CIU   = CPU.x_ct_ciu_top
L2    = CPU.x_ct_l2c_top
```

如果 Verdi 中找不到某个内部组合信号，先确认层次是否匹配当前编译版本，再确认
VCS 是否使用了 `-debug_access`。当前 `smart_run/Makefile` 的 VCS 配置已经包含
`-kdb -debug_access`，`DUMP=on` 时 `tb.v` 调用 `$fsdbDumpvars()`。

当前波形可由用户在 EDA 环境中打开：

```bash
cd smart_run
make verdi
```

当前 CoreMark 波形为 `smart_run/work/novas.fsdb`。该版本的符号文件中
`perf_monitor_start=0x6762`，但 `0x6762` 的指令被前端折叠，没有形成独立退休记录。
因此观察当前 CoreMark 核心区间时，应以首次退休 `0x6764` 为开始、退休 `0x6768`
为结束。以后更换 ELF 时必须重新查看 `smart_run/work/symbols.args` 和对应反汇编，
不能照搬这两个地址。

---

## 3. 第一组：全局架构骨架

建议把以下信号保存为 `00_arch_anchor`。后续每个局部机制组都保留其中的退休、
ROB 和 flush 信号。

| 位置 | 信号 | 作用 | 如何看 |
|---|---|---|---|
| `TB` | `clk`、`rst_b` | 仿真时钟和复位 | 所有时序均按有效上升沿判断 |
| `RTU` | `rtu_yy_xx_retire0/1/2` | 三个退休槽 | 每拍置位数反映退休带宽，但折叠会使“ROB 项数”和“架构指令数”不同 |
| `RTU.x_ct_rtu_rob` | `rob_entry_num[6:0]` | ROB 占用 | 上升表示进入多于退休，下降表示后端正在排空 |
| 同上 | `rob_full`、`rob_empty` | ROB 满/空 | full 可反压派发；empty 时无退休通常是前端断供 |
| `RTU.x_ct_rtu_rob.x_ct_rtu_rob_rt` | `retire_inst0_cur_pc[38:0]` | 退休槽 0 的完整 PC | 与反汇编对照、定位循环和函数 |
| 同上 | `rob_cur_pc[38:0]` | ROB 头部当前 PC | 观察最老指令停在哪里 |
| `RTU` | `rtu_yy_xx_flush` | 后端 flush | 错误路径最终被清理和重命名状态恢复 |
| `RTU` | `rtu_idu_flush_fe`、`rtu_idu_flush_is` | 前端/发射域 flush | 区分清理范围 |
| `RTU.x_ct_rtu_retire` | `flush_cur_state[4:0]` | flush 状态机 | 观察恢复过程而不只看一个脉冲 |

`flush_cur_state` 的 RTL 编码为：

| 编码 | 状态 | 含义 |
|---|---|---|
| `00001` | `FLUSH_IDLE` | 正常运行 |
| `00010` | `FLUSH_IS` | 清理 IS/RF |
| `00100` | `FLUSH_FE` | 清理 IFU 和 ID/IR/IS/RF |
| `01000` | `WF_EMPTY` | 等待相关状态排空 |
| `10000` | `FLUSH_BE` | 恢复 PST 和重命名表 |
| `10010` | `FLUSH_IS_BE` | 同时处理 IS 与后端 |
| `10100` | `FLUSH_FE_BE` | 同时处理前端与后端 |

### 3.1 用骨架信号判断大方向

| 波形组合 | 初步解释 | 下一步 |
|---|---|---|
| `retire*=0` 且 `rob_empty=1` | 没有在途指令，偏前端供给问题 | 查 IFU、I-Cache、前端 stall |
| `retire*=0` 且 ROB 很满 | 最老指令未完成或不可提交 | 查 ROB 头完成位、LSU、长延迟执行 |
| ROB 高位运行且 IQ 经常 full | 调度/执行吞吐跟不上派发 | 查 ready 与 issue |
| ROB 高位运行但 IQ 不满 | 可能是长延迟完成、退休串行化或存储队列 | 查 ROB 头与 LSU |
| 周期性 flush 后出现退休空洞 | 错误推测或异常恢复代价 | 查 BJU、LSU spec-fail、RTU exception |

体系结构上，ROB 是观察全核供需关系的“水库”：前端和派发决定流入，执行完成和
按序退休决定流出。只看 IPC 看不到水位，只看水位也不知道堵点；两者必须结合。

---

## 4. IFU：PC 生成、取指流水和指令供给

### 4.1 PC 与 IF/IP/IB 流水

建立 `01_ifu_flow`：

| 位置 | 信号 | 作用 |
|---|---|---|
| `IFU.x_ct_ifu_pcgen` | `if_pc[38:0]` | 当前 IF PC |
| 同上 | `pcgen_chgflw` | 任一来源要求改变 PC |
| 同上 | `rtu_ifu_chgflw_vld/pc` | 异常、退休级 flush 等精确重定向 |
| 同上 | `iu_ifu_chgflw_vld/pc` | BJU 执行级发现误预测后的早重定向 |
| 同上 | `ibctrl_pcgen_pcload`、`ibctrl_pcgen_pc` | IB 级预测重定向 |
| 同上 | `ipctrl_pcgen_chgflw_pcload`、`ipctrl_pcgen_chgflw_pc` | IP 级预测重定向 |
| 同上 | `ipctrl_pcgen_reissue_pcload`、`ipctrl_pcgen_reissue_pc` | IP 级重发 |
| `IFU.x_ct_ifu_ifctrl` | `if_vld`、`if_self_stall` | IF 级有效与自身停顿 |
| 同上 | `if_frontend_stall` | 汇总前端供给压力 |
| 同上 | `ifctrl_ipctrl_vld` | IF 向 IP 级推进 |
| `IFU.x_ct_ifu_ipctrl` | `ip_vld`、`ipctrl_ibctrl_vld` | IP 有效及向 IB 推进 |
| `IFU` | `ifu_idu_ib_inst0_vld/inst1_vld/inst2_vld` | 最终交给 IDU 的最多三条指令 |

观察顺序：

1. 在没有 stall 和重定向时，确认 `if_pc` 按前端取指块顺序推进。
2. `if_vld` 经 `ifctrl_ipctrl_vld`、`ip_vld`、`ipctrl_ibctrl_vld` 向后传播。
3. 最终看 `ifu_idu_ib_inst0/1/2_vld`，它们才代表 IDU 本拍得到的指令数量。
4. PC 停住时，先判断是 `if_self_stall`，还是下游 IP/IB 反压。
5. PC 跳转时，根据多个 pcload/chgflw 信号的优先级找出来源。

这里体现了“控制流是前端的预测值，退休端才是最终事实”。IFU 可以快速猜测下一
PC；BJU 可以较早纠错；RTU 则在精确状态边界完成最终清理。速度来自投机，正确性来自退休。

### 4.2 IBUF：前端与译码之间的弹性缓冲

建立 `02_ibuf`：

| 位置 | 信号 | 作用与读法 |
|---|---|---|
| `IFU.x_ct_ifu_ibuf` | `ibuf_empty` | IBUF 为空，若 IDU 也无输入，前端已经断供 |
| 同上 | `ibuf_create_num[4:0]` | 32 个 16 位 half-word 槽位的写位置 |
| 同上 | `ibuf_retire_num[4:0]` | half-word 读/弹出位置 |
| `IFU.x_ct_ifu_ibctrl` | `ibctrl_debug_ibuf_full` | IBUF 满导致反压 |
| 同上 | `ibctrl_debug_fifo_full_stall` | PCFIFO 等相关缓冲满 |
| 同上 | `ibctrl_ibuf_create_vld` | 向 IBUF 创建数据 |
| 同上 | `ibctrl_ibuf_retire_vld` | 从 IBUF 消费数据 |
| 同上 | `bypass_inst_vld` | 空缓冲条件下前端直通 IDU |
| 同上 | `merge_inst_vld` | 跨取指块/边界数据合并 |

IBUF 的一个表项不是一条完整指令，而是一个 16 位 half-word；这是为了适配 RVC
的 16/32 位混合指令边界。`ibuf_create_num` 和 `ibuf_retire_num` 是按 half-word
推进的环形位置，不是直接的“指令条数”或占用计数。可以用模 32 的位置距离辅助判断，
但必须同时看 empty/full，避免在位置相等时混淆全空和全满。

判断前端问题时：

- IBUF 经常 empty：取指、预测、I-Cache 或对齐侧供给不足。
- IBUF 经常 full：后端不能及时消费，前端 stall 很可能是后端反压的结果。
- IBUF 有数据但 `ifu_idu_ib_inst*_vld` 不出：检查 fence、flush、译码输入控制。

### 4.3 I-Cache miss、refill 与前端特殊重发

建立 `03_icache_refill`：

| 位置 | 信号 | 含义 |
|---|---|---|
| `IFU.x_ct_ifu_ipctrl` | `ip_refill_pre` | IP 级判定需要 refill |
| 同上 | `icache_refill_reissue` | refill 后重发原访问 |
| 同上 | `l1_refill_ipctrl_busy` | refill 单元忙 |
| 同上 | `miss_under_refill_stall` | 已有 refill 时又遇到 miss |
| 同上 | `way_mispred_reissue` | I-Cache way prediction 错误，需要重发 |
| 同上 | `bry_missigned_stall` | RVC 指令边界判断需要修正 |
| 同上 | `br_more_than_one_stall` | 同一前端块出现多分支冲突 |
| `IFU.x_ct_ifu_l1_refill` | `l1_refill_ifctrl_start` | refill 事务开始 |
| 同上 | `l1_refill_ifctrl_trans_cmplt` | refill 事务完成 |
| `IFU` | `ipb_l1_refill_data_vld` | refill 数据返回 |
| 同上 | `ipb_l1_refill_trans_err` | refill 总线错误 |

一次典型 I-Cache miss 应形成：

```text
IP 判 miss
  -> ip_refill_pre
  -> l1_refill_ifctrl_start
  -> 等待下层返回，前端供给下降
  -> ipb_l1_refill_data_vld
  -> l1_refill_ifctrl_trans_cmplt
  -> icache_refill_reissue
  -> IF/IP/IB 重新出现有效指令
```

不要把所有 `if_frontend_stall` 都算成 I-Cache miss。IBUF full、分支重定向、
way prediction 错误、边界修正和后端反压都可能使前端停顿。

---

## 5. 分支预测：预测、执行校验、重定向与恢复

分支预测必须跨 IFU、IU/BJU 和 RTU 三个单元联合观察。

### 5.1 预测器内部信号

建立 `04_branch_predictor`：

| 位置 | 信号 | 作用 |
|---|---|---|
| `IFU.x_ct_ifu_l0_btb` | `l0_btb_ifdp_hit` | L0 BTB 命中 |
| `IFU.x_ct_ifu_ibctrl` | `ibctrl_ibdp_l0_btb_hit/miss/mispred/wait` | IB 级对 L0 BTB 结果的处理 |
| 同上 | `ibctrl_ind_btb_check_vld`、`ibctrl_ind_btb_fifo_stall` | 间接跳转 BTB 检查和阻塞 |
| `IFU.x_ct_ifu_bht` | `vghr_reg[21:0]` | 投机全局历史 |
| 同上 | `rtughr_reg[21:0]` | 退休后的精确全局历史 |
| 同上 | `bht_ipdp_sel_array_result[1:0]` | Bi-Mode 选择表计数器结果 |
| 同上 | `bht_pred_array_rd`、`bht_sel_array_rd` | 预测表/选择表读取 |
| 同上 | `bht_wr_buf_create_vld`、`bht_wr_buf_retire_vld` | BHT 更新缓冲创建/写回 |
| 同上 | `buf_full`、`wr_buf_hit` | 更新缓冲压力与旁路命中 |
| `IFU.x_ct_ifu_ras` | `ras_push`、`ras_pop` | call/return 对 RAS 的操作 |
| 同上 | `ras_empty`、`ras_full` | RAS 边界状态 |

`vghr_reg` 会随预测结果投机更新，`rtughr_reg` 只包含已退休分支的真实历史。
正常情况下 VGHR 可以领先；误预测恢复后，投机历史必须回到精确历史基础上重新推进。
这是一种典型的“投机副本 + 精确副本”设计，RAT/PST 也采用相同思想。

### 5.2 BJU 中的真实结果和误预测判定

建立 `05_branch_recovery`：

| 位置 | 信号 | 作用 |
|---|---|---|
| `IU.x_ct_iu_bju` | `ex1_pipe2_inst_vld` | EX1 中存在分支指令 |
| 同上 | `ex1_pipe2_bht_pred` | IFU 当初预测的方向 |
| 同上 | `condbr_taken` | ALU 比较得到的真实方向 |
| 同上 | `bju_bht_mispred` | 条件方向误预测 |
| 同上 | `bju_jmp_mispred` | 跳转类型/预测错误 |
| 同上 | `bju_tarpc_cmp_fail` | 预测目标与真实目标不符 |
| 同上 | `bju_chgflw_vld` | EX1 判定需要改变控制流 |
| 同上 | `iu_ifu_chgflw_vld`、`iu_ifu_chgflw_pc[62:0]` | EX2 向 IFU 发正确目标 |
| 同上 | `iu_yy_xx_cancel` | 立即取消年轻错误路径 |
| 同上 | `iu_idu_mispred_stall`、`iu_ifu_mispred_stall` | 恢复期间冻结 IDU/IFU |
| `RTU.x_ct_rtu_retire` | `retire_inst0_mispred` | 误预测分支到达退休端 |
| `RTU` | `rtu_idu_flush_fe`、`rtu_yy_xx_flush` | 晚清理和精确状态恢复 |

观察一次误预测的完整链：

```text
ex1_pipe2_inst_vld
  -> 预测方向/目标与真实结果不一致
  -> bju_bht_mispred、bju_jmp_mispred 或 bju_tarpc_cmp_fail
  -> bju_chgflw_vld
  -> 下一拍 iu_ifu_chgflw_vld + 正确 PC
  -> if_pc 转向，iu_yy_xx_cancel 取消错误路径
  -> mispred_stall 阻止继续扩大错误窗口
  -> 分支到 ROB 头后 RTU 进入 flush 状态机
  -> PST/RAT 恢复，重新开始有效退休
```

这里有两个不同阶段：

- **早重定向**追求性能：BJU 一知道正确目标就让 IFU 重新取指。
- **晚清理**保证正确性：RTU 等该分支成为精确边界后，再恢复 ROB、PST 和重命名状态。

只看 `iu_ifu_chgflw_vld` 会漏掉精确恢复，只看 `rtu_yy_xx_flush` 又会误以为直到退休
才开始取正确路径。把两段放在同一窗口中，才能理解现代分支恢复设计。

---

## 6. IDU：译码、拆分、重命名和派发

### 6.1 三路译码与四路内部操作

建立 `06_decode_rename`：

| 位置 | 信号 | 作用 |
|---|---|---|
| `IDU.x_ct_idu_id_ctrl` | `id_inst0_vld/id_inst1_vld/id_inst2_vld` | ID 级三条指令槽 |
| 同上 | `ctrl_id_pipedown_1_inst/_2_inst/_3_inst` | 本拍实际向 IR 推进几条 |
| 同上 | `ctrl_id_stall` | ID 总停顿 |
| 同上 | `ctrl_id_split_long_stall` | 复杂拆分指令造成的长停顿 |
| `IDU` | `fence_ctrl_id_stall` | fence/串行化指令阻塞译码 |
| `IDU.x_ct_idu_ir_ctrl` | `ir_inst0_vld...ir_inst3_vld` | IR 中最多四个内部操作 |
| 同上 | `ir_pipedown_inst0_vld...inst3_vld` | 实际进入 IS 的操作 |
| 同上 | `ctrl_ir_stall` | IR 停顿 |
| `IDU.x_ct_idu_is_ctrl` | `ctrl_is_dis_stall` | 派发停顿 |
| 同上 | `ctrl_top_is_iq_full`、`ctrl_top_is_vmb_full` | IQ/VMB 资源不足 |

`id_inst*_vld` 是“该槽中有指令”，`ctrl_id_pipedown_*` 才是“本拍发生推进”。
若 `ctrl_id_stall=1`，同一组 ID valid 可以保持多拍，不能重复计算。

三译码但 IR/IS 最多四操作并不矛盾：译码宽度描述架构指令，派发宽度描述内部操作。
复杂指令拆分后，微操作数可能大于架构指令数。这也是为什么只数某一级 valid 无法完整
推导架构 IPC。

### 6.2 物理寄存器分配和 RAT 映射

| 位置 | 信号 | 作用 |
|---|---|---|
| `IDU.x_ct_idu_ir_ctrl` | `idu_rtu_ir_preg0_alloc_vld...preg3_alloc_vld` | IR 请求分配整数物理寄存器 |
| 同上 | `rtu_idu_alloc_preg0_vld...preg3_vld` | RTU/PST 返回分配有效 |
| 同上 | `ctrl_top_ir_preg_not_vld` | 物理寄存器分配失败/不足 |
| `IDU.x_ct_idu_ir_rt` | `dp_rt_inst0_dst_preg` | inst0 新分配的目的 preg |
| 同上 | `rt_dp_inst0_src0_data/src1_data/src2_data` | 源映射，包含 preg、ready、writeback 等状态 |
| 同上 | `rt_dp_inst0_rel_preg` | 被新映射替换的旧 preg，退休后释放 |
| 同上 | `rt_dp_inst01_src_match` 等 | 同一派发包内 RAW 依赖及旁路关系 |
| 同上 | `rt_recover_updt_vld` | flush 时用精确映射恢复 RAT |
| `RTU.x_ct_rtu_pst_preg` | `rtu_idu_rt_recover_preg[223:0]` | 32 个整数架构寄存器的精确映射快照 |

以一条写 `x5` 的指令为例：

```text
旧状态：RAT[x5] = p37
重命名：为新结果分配 p82
记录：dst_preg = p82，rel_preg = p37
消费者：后续读 x5 得到 p82，形成真实 RAW 依赖
退休：x5 的精确映射提交为 p82，旧 p37 最终释放
flush：若该指令在错误路径上，RAT 从 PST 快照恢复，p82 被回收
```

重命名消除的是 WAR/WAW 假依赖；RAW 真依赖不会消失，而是从“等待架构寄存器 x5”
转换成“等待物理寄存器 p82”。这正是后面分析 IQ not-ready 的基础。

---

## 7. 发射队列：乱序执行的核心观察点

C910 有七个主要发射队列：

| 队列 | 位置 | 项数 | 主要去向 |
|---|---|---:|---|
| AIQ0 | `IDU.x_ct_idu_is_aiq0` | 8 | pipe0，整数/除法/特殊操作 |
| AIQ1 | `IDU.x_ct_idu_is_aiq1` | 8 | pipe1，整数/乘法 |
| BIQ | `IDU.x_ct_idu_is_biq` | 12 | pipe2，分支 |
| LSIQ | `IDU.x_ct_idu_is_lsiq` | 12 | pipe3/4，Load/Store 地址 |
| SDIQ | `IDU.x_ct_idu_is_sdiq` | 12 | pipe5，Store 数据 |
| VIQ0 | `IDU.x_ct_idu_is_viq0` | 8 | pipe6，浮点/向量 |
| VIQ1 | `IDU.x_ct_idu_is_viq1` | 8 | pipe7，浮点/向量 |

对每个队列添加同名前缀信号。例如 AIQ0：

```text
aiq0_entry_cnt[3:0]
aiq0_ctrl_empty
aiq0_ctrl_full
aiq0_entry_vld[7:0]
aiq0_entry_ready[7:0]
aiq0_entry_issue_en[7:0]
```

AIQ1、BIQ、LSIQ、SDIQ、VIQ0、VIQ1 分别使用对应前缀；BIQ/LSIQ/SDIQ 的 entry
向量宽度为 12，AIQ/VIQ 为 8。LSIQ 还应加入：

```text
IDU.x_ct_idu_is_lsiq.lsiq_xx_pipe3_issue_en
IDU.x_ct_idu_is_lsiq.lsiq_xx_pipe4_issue_en
IDU.lsu_idu_lsiq_pop_vld
```

### 7.1 用 vld、ready、issue 三层关系定位停顿

| 条件 | 含义 | 体系结构解释 |
|---|---|---|
| `vld=0` | 表项为空 | 没有可调度工作 |
| `vld=1, ready=0` | 指令存在但源未就绪或条件未满足 | 数据依赖、Load 依赖、串行化依赖 |
| `ready=1, issue=0` | 已具备执行条件但未被选中 | 端口冲突、年龄仲裁、功能单元忙 |
| `issue=1` | 本拍选择该表项 | 对 LSIQ 仍需 LSU pop 才表示真正接受 |
| `full=1` | 无空表项 | 只有同时导致 IS/IR stall 才构成容量瓶颈 |

“IQ 中很多 not-ready 指令”只是现象，不是最终原因。必须继续回答：

1. 哪些 entry 不 ready？
2. 它们缺少哪个 src？
3. 该 src 对应哪个 preg？
4. 哪个执行单元应该生产这个 preg？
5. 生产者是在等待 Load miss、乘除法、前递，还是被 flush 取消？

### 7.2 深入一个具体 IQ entry

例如 AIQ0 entry0：

```text
IDU.x_ct_idu_is_aiq0.x_ct_idu_is_aiq0_entry0.vld
IDU.x_ct_idu_is_aiq0.x_ct_idu_is_aiq0_entry0.iid[6:0]
IDU.x_ct_idu_is_aiq0.x_ct_idu_is_aiq0_entry0.opcode[31:0]
IDU.x_ct_idu_is_aiq0.x_ct_idu_is_aiq0_entry0.dst_preg[6:0]
IDU.x_ct_idu_is_aiq0.x_ct_idu_is_aiq0_entry0.read_src0_data
IDU.x_ct_idu_is_aiq0.x_ct_idu_is_aiq0_entry0.read_src1_data
IDU.x_ct_idu_is_aiq0.x_ct_idu_is_aiq0_entry0.read_src2_data
IDU.x_ct_idu_is_aiq0.x_ct_idu_is_aiq0_entry0.x_rdy
```

AIQ0 的 `read_src*_data[11:0]` 来自 `ct_idu_dep_reg_entry`，字段应按 RTL 精确解释：

| 位 | 含义 |
|---:|---|
| `[11]` | 该源与 LSU 在途结果匹配 |
| `[10]` | 可以使用 bypass 的 ready |
| `[9]` | 可以参与本拍 issue 的 ready |
| `[8:2]` | 源物理寄存器 preg |
| `[1]` | 结果已经写回 PRF |
| `[0]` | 依赖项保存的基础 ready 状态 |

因此判断“在等谁”时，先看 `[9]` 是否阻止 issue，再从 `[8:2]` 读出生产者 preg，
并结合 `[10]`、`[1]`、前递广播和正式写回判断它处于依赖生命周期的哪一步。不同
队列的源字段布局不应直接照搬，展开总线时仍要与对应 `*_entry.v` 的字段赋值对照。

发现某源等待 `p82` 后，在写回/前递广播中搜索目的 preg 等于 `0x52` 的事件。若首先
出现 Load Pipe3 的 p82，说明该依赖链由 Load 控制；若来自 IU pipe0/1，则是整数链。

### 7.3 ready 但没有 issue 的分析

当 `entry_ready` 有多个 bit 为 1，而 `entry_issue_en` 只选择一个或完全不选时：

- 比较对应队列的 `aiq0_older_entry_ready`、`aiq1_older_entry_ready`、
  `biq_older_entry_ready`、`sdiq_older_entry_ready` 或 `viq*_older_entry_ready`，
  确认年龄选择器是否优先选择更老的 ready 指令；LSIQ 还叠加访存顺序约束。
- 看对应功能单元 busy/stall，例如 `iu_idu_div_busy`。
- 看 RF 级是否发生 launch fail；发射选择成功不保证读寄存器后一定能进入执行。
- 看同一 pipe 的写回端口是否被长延迟结果预约。

发射队列体现了乱序核的核心价值：它不是让所有指令“随便乱跑”，而是在满足数据依赖、
资源约束和年龄规则的前提下，从窗口中寻找本拍最值得执行的指令。

---

## 8. RF、前递与八条执行管线

### 8.1 统一观察入口

建立 `08_issue_execute`：

| 位置 | 信号 | 作用 |
|---|---|---|
| `IDU.x_ct_idu_rf_ctrl` | `rf_pipe0_inst_vld...rf_pipe7_inst_vld` | 八条 RF 管线的当前有效指令 |
| 同上 | `ctrl_rf_pipe0_inst_vld...pipe7_inst_vld` | 综合 launch 条件后的有效 |
| 同上 | `dp_ctrl_rf_pipe0_src_no_rdy...pipe7_src_no_rdy` | RF 发现源仍未就绪 |
| `IDU` | `idu_hpcp_rf_pipe0_lch_fail_vld...pipe7_lch_fail_vld` | 各 pipe 发射失败 |
| `IDU.x_ct_idu_rf_dp` | `idu_iu_rf_pipe0_iid/pipe1_iid/pipe2_iid` | IU 三条管线 IID |
| 同上 | `idu_lsu_rf_pipe3_iid/pipe4_iid` | Load/Store 地址 IID |
| 同上 | `idu_vfpu_rf_pipe6_iid/pipe7_iid` | VFPU IID |

管线分工：

| Pipe | 主要工作 |
|---:|---|
| 0 | 整数 ALU、除法、特殊/CSR 类 |
| 1 | 整数 ALU、乘法/乘加 |
| 2 | 条件分支、跳转 |
| 3 | Load 地址与数据路径 |
| 4 | Store 地址 |
| 5 | Store 数据 |
| 6/7 | 浮点和向量 |

IQ issue 是“选择候选指令”，RF launch 是“操作数和结构条件满足后真正送入执行”。
若 issue 活跃但 RF launch fail 很多，瓶颈位于选择之后，而不是 IQ 没有工作。

### 8.2 整数 ALU 和前递

```text
IDU.idu_iu_rf_pipe0_sel
IDU.idu_iu_rf_pipe1_sel
IU.x_ct_iu_alu0.alu_ex1_inst_vld
IU.x_ct_iu_alu1.alu_ex1_inst_vld
IU.x_ct_iu_alu0.alu_ex1_dst_preg
IU.x_ct_iu_alu1.alu_ex1_dst_preg
IU.x_ct_iu_alu0.alu_ex1_fwd_data
IU.x_ct_iu_alu1.alu_ex1_fwd_data
IU.x_ct_iu_alu0.alu_ex1_alu_short
IU.x_ct_iu_alu1.alu_ex1_alu_short
IU.x_ct_iu_rbus.iu_idu_ex1_pipe0_fwd_preg_vld
IU.x_ct_iu_rbus.iu_idu_ex1_pipe1_fwd_preg_vld
IU.x_ct_iu_rbus.iu_idu_ex2_pipe0_wb_preg_vld
IU.x_ct_iu_rbus.iu_idu_ex2_pipe1_wb_preg_vld
IU.iu_rtu_pipe0_cmplt / iu_rtu_pipe0_iid
IU.iu_rtu_pipe1_cmplt / iu_rtu_pipe1_iid
```

观察背靠背依赖 `add x5,...`、`add x6,x5,...` 时，生产者的 EX1 前递可以使消费者
不必等到 EX2 正式写回。若 `alu_short=0`，某些较长整数操作不能使用最早前递，消费者
会多等若干拍。这说明旁路网络实质上是在缩短 RAW 依赖的“可见延迟”。

### 8.3 乘法和除法

乘法组：

```text
IU.x_ct_iu_mult.mult_rbus_ex3_data_vld
IU.x_ct_iu_mult.mult_rbus_ex4_data_vld
IU.x_ct_iu_mult.mult_rf_mla_match_ex1
IU.x_ct_iu_mult.mult_rf_mla_match_ex2
IU.x_ct_iu_mult.mult_rf_mla_match_ex3
IU.iu_idu_ex1_pipe1_mult_stall
IU.iu_idu_ex2_pipe1_mult_inst_vld_dup0
```

`mult_rbus_ex3_data_vld` 是写回前的预告，`mult_rbus_ex4_data_vld` 对应真实数据阶段。
连续 MLA 可通过私有前递处理累加源。观察普通乘法和连续乘加的差别，可以理解为什么
工业处理器会为高频模式增加专用旁路，而不是只依赖统一 PRF。

除法组：

```text
IU.x_ct_iu_div.iu_idu_div_busy
IU.x_ct_iu_div.iu_idu_div_wb_stall
IU.x_ct_iu_div.div_ex1_special_result
IU.x_ct_iu_div.x_srt_finish
IU.x_ct_iu_div.div_rbus_pipe0_data_vld
IU.iu_rtu_pipe0_cmplt / iu_rtu_pipe0_iid
```

除法是变延迟执行：特殊输入可走快速路径，普通输入进入迭代过程。`div_wb_stall`
会预约 pipe0 写回资源。比较“完成通知、busy 结束、结果写回”的时刻，能看到 C910
把 ROB 完成管理和数据结果网络分开的设计。

### 8.4 浮点与向量

CoreMark 主要是整数程序，不能用它判断 VFPU 是否工作良好。观察 VFPU 应运行
`bench_fp`、`ISA_FP`、`rvv` 或 `ISA_VECTOR`。

```text
VFPU.idu_vfpu_rf_pipe6_sel / idu_vfpu_rf_pipe7_sel
VFPU.idu_vfpu_rf_pipe6_iid / idu_vfpu_rf_pipe7_iid
VFPU.vfpu_rtu_pipe6_cmplt / vfpu_rtu_pipe6_iid
VFPU.vfpu_rtu_pipe7_cmplt / vfpu_rtu_pipe7_iid
VFPU.vfpu_idu_ex3_pipe6_fwd_vreg_vld
VFPU.vfpu_idu_ex3_pipe7_fwd_vreg_vld
VFPU.vfpu_idu_ex5_pipe6_wb_vreg_vld_dup0
VFPU.vfpu_idu_ex5_pipe7_wb_vreg_vld_dup0
VFPU.x_ct_vfpu_rbus.rbus_pipe6_vreg_wb_vld
VFPU.x_ct_vfpu_rbus.rbus_pipe7_vreg_wb_vld
```

完成可能早于 EX5 写回，消费者能否继续取决于对应前递级。pipe6 还承载不对称的
除法/平方根等单元，因此 pipe6/7 使用率不一定对称。不要把这种结构不对称简单判断为
负载不均；先按指令类型确认它是否是设计约束。

---

## 9. LSU：从地址生成到缓存、重放和写回

### 9.1 Load 四级流水

建立 `09_load_pipeline`：

```text
LSU.x_ct_lsu_ld_ag.ld_ag_inst_vld
LSU.x_ct_lsu_ld_ag.ld_ag_dc_inst_vld
LSU.x_ct_lsu_ld_ag.ld_ag_iid[6:0]
LSU.x_ct_lsu_ld_ag.ld_ag_va[63:0]
LSU.x_ct_lsu_ld_ag.ld_ag_pa[39:0]

LSU.x_ct_lsu_ld_dc.ld_dc_inst_vld
LSU.x_ct_lsu_ld_dc.ld_dc_da_inst_vld
LSU.x_ct_lsu_ld_dc.ld_dc_iid[6:0]

LSU.x_ct_lsu_ld_da.ld_da_inst_vld
LSU.x_ct_lsu_ld_da.ld_da_iid[6:0]
LSU.x_ct_lsu_ld_da.ld_da_dcache_miss
LSU.x_ct_lsu_ld_da.ld_da_wb_cmplt_req
LSU.x_ct_lsu_ld_da.ld_da_wb_data_req

LSU.x_ct_lsu_ld_wb.ld_wb_inst_vld
LSU.x_ct_lsu_ld_wb.lsu_rtu_wb_pipe3_cmplt
LSU.x_ct_lsu_ld_wb.lsu_rtu_wb_pipe3_iid[6:0]
```

一次 L1 命中 Load 应按 IID 呈现 AG -> DC -> DA -> WB/complete 的短路径。
`ld_da_wb_cmplt_req` 和 `ld_da_wb_data_req` 分开，说明“完成状态”和“结果数据”
本来就是两个控制问题。

### 9.2 Store 地址、数据和提交

```text
LSU.x_ct_lsu_st_ag.st_ag_inst_vld
LSU.x_ct_lsu_st_ag.st_ag_dc_inst_vld
LSU.x_ct_lsu_st_dc.st_dc_da_inst_vld
LSU.x_ct_lsu_st_da.st_da_inst_vld
LSU.x_ct_lsu_st_da.st_da_dcache_miss
LSU.x_ct_lsu_st_wb.lsu_rtu_wb_pipe4_cmplt
LSU.x_ct_lsu_st_wb.lsu_rtu_wb_pipe4_iid[6:0]
IDU.x_ct_idu_rf_ctrl.rf_pipe5_inst_vld
IDU.lsu_idu_ex1_sdiq_pop_vld
```

Store 被拆成地址和数据两条协同路径：LSIQ/pipe4 计算地址，SDIQ/pipe5 提供数据。
Store 在 ROB 中完成或退休，并不意味着写请求已经到达总线。它还要经过 SQ 和 WMB，
在不再需要回滚后才对存储层次产生提交效果。

### 9.3 LQ、SQ 和 Store-to-Load forwarding

建立 `10_memory_ordering`：

| 位置 | 信号 | 作用 |
|---|---|---|
| `LSU.x_ct_lsu_lq` | `lq_empty`、`lq_full` | Load Queue 状态 |
| `LSU.x_ct_lsu_sq` | `sq_empty`、`sq_full` | Store Queue 状态 |
| 同上 | `sq_create_success`、`sq_create_vld[11:0]` | 创建 Store 表项 |
| 同上 | `sq_ld_dc_newest_fwd_data_vld_req` | 最新匹配 Store 数据可前递 |
| 同上 | `sq_ld_dc_data_discard_req` | 地址匹配但数据尚不可用，Load 需丢弃/重放 |
| 同上 | `sq_ld_dc_other_discard_req` | 其他 Store 相关冲突 |
| `LSU.x_ct_lsu_wmb` | `wmb_ld_dc_fwd_req` | 从已提交但未排出的 WMB 前递 |
| `LSU` | `lsu_idu_dc_pipe3_load_fwd_inst_vld_dup1` | Load 前递结果已可用于唤醒消费者 |
| `LSU.x_ct_lsu_ld_da` | `ld_da_sq_data_discard_vld` | SQ 数据原因造成重放 |
| 同上 | `ld_da_sq_global_discard_vld` | SQ 全局依赖原因造成重放 |
| 同上 | `ld_da_wmb_discard_vld` | WMB 冲突造成重放 |

典型 Store-to-Load forwarding：

```text
较老 Store 在 SQ/WMB 中，尚未写入 D-Cache
  -> 年轻 Load 地址与其重叠
  -> SQ 或 WMB 发 fwd_req
  -> Load 选择前递数据而不是 Cache 数据
  -> pipe3 load_fwd_inst_vld 唤醒依赖者
```

若地址匹配但 Store 数据尚未准备好，错误地让 Load 继续会违反程序语义。C910 选择
丢弃并重放 Load。波形中的 discard 不是无效工作，而是乱序访存为正确性付出的代价。

### 9.4 顺序违例和 spec-fail

```text
LSU.x_ct_lsu_ld_da.ld_da_wb_spec_fail
LSU.x_ct_lsu_st_da.st_da_wb_spec_fail
LSU.x_ct_lsu_ld_da.lsu_rtu_da_pipe3_split_spec_fail_vld
LSU.x_ct_lsu_st_da.lsu_rtu_da_pipe4_split_spec_fail_vld
RTU.rtu_lsu_spec_fail_flush
RTU.rtu_lsu_spec_fail_iid[6:0]
LSU.x_ct_lsu_spec_fail_predict.rtu_lsu_spec_fail_flush
```

当年轻 Load 提前执行，之后发现它与更老 Store 存在不允许的顺序冲突时，不能只重写
一个寄存器，因为错误值可能已经沿依赖链传播。处理器必须以该 IID 为边界 flush，
然后重新执行。`spec_fail_predict` 会学习此类失败，降低同一模式再次过度投机的概率。

这体现了内存相关预测和分支预测的共同结构：先投机换取并行度，检测错误后恢复，再用
历史降低未来错误率。

### 9.5 D-Cache 端口仲裁

`LSU.x_ct_lsu_dcache_arb` 同时服务普通 AG、LFB refill、VB 替换、WMB、snoop、
cache maintenance 等请求。至少加入：

```text
ag_dcache_arb_ld_tag_req
ag_dcache_arb_ld_data_req[7:0]
lfb_dcache_arb_ld_req
vb_dcache_arb_ld_req
snq_dcache_arb_ld_req
wmb_dcache_arb_ld_req
dcache_arb_ag_ld_sel
dcache_arb_lfb_ld_grnt
dcache_arb_vb_ld_grnt
dcache_arb_snq_ld_grnt
dcache_arb_wmb_ld_grnt

ag_dcache_arb_st_tag_req
ag_dcache_arb_st_dirty_req
lfb_dcache_arb_st_req
vb_dcache_arb_st_req
wmb_dcache_arb_st_req
dcache_arb_ag_st_sel
dcache_arb_lfb_st_sel
dcache_arb_vb_st_grnt
dcache_arb_wmb_st_sel
```

只有 request 长时间得不到 grant，且上游流水因此停顿，才能认定 D-Cache 端口冲突
是瓶颈。单看某个 grant 很少，不代表该源受限，也可能只是它没有请求。

### 9.6 miss、RB、LFB、VB 和 WMB

| 结构 | 关键角色 | 推荐信号 |
|---|---|---|
| RB | 记录需重放/向下层请求的访问 | `rb_empty/full`、`rb_create_ld_success`、`rb_biu_ar_req`、`rb_lfb_create_vld`、`rb_ld_wb_cmplt_req` |
| LFB | 管理缓存行填充和 miss 合并 | `lfb_empty`、`lfb_addr_full`、`lfb_addr_entry_rb_create_vld[7:0]`、`lfb_data_create_vld`、`lfb_biu_r_id_hit`、`lfb_depd_wakeup[11:0]` |
| VB | 保存被替换的脏行并写回 | `vb_empty`、`lfb_vb_create_req`、`lfb_vb_create_vld` |
| WMB | 管理已提交 Store、合并、前递和下层写事务 | `wmb_empty`、`wmb_create_vld`、`wmb_biu_aw_req`、`wmb_biu_w_req`、`wmb_entry_pop_vld[7:0]` |

典型 D-Cache miss：

```text
ld_da_inst_vld && ld_da_dcache_miss
  -> RB 创建或命中已有 miss
  -> RB 请求下层，并为新缓存行创建 LFB
  -> BIU/L2 返回数据，LFB 按 AXI ID 接收
  -> LFB 将数据 refill 到 D-Cache
  -> lfb_depd_wakeup 唤醒等待该行的 Load
  -> Load 完成/写回
```

若替换目标是脏行，还会出现 `lfb_vb_create_req/vld`，VB 负责保存旧行并写回。
因此 miss 延迟不仅由下层存储决定，还可能受 RB/LFB 容量、脏替换、端口仲裁和同地址
miss 合并影响。

### 9.7 预取、Fence 和原子操作

预取：

```text
LSU.x_ct_lsu_pfu.pfu_dcache_pref_en
LSU.x_ct_lsu_pfu.pfu_pmb_empty / pfu_pmb_full
LSU.x_ct_lsu_pfu.pfu_sdb_empty / pfu_sdb_full
LSU.x_ct_lsu_pfu.pfu_biu_ar_req
LSU.x_ct_lsu_pfu.pfu_biu_req_addr[39:0]
LSU.x_ct_lsu_pfu.pfu_lfb_create_vld
```

预取是否有效不能只看“发出了多少请求”。需要比较预取地址、后续 demand load、LFB
命中和总线压力：及时且被使用才是有效预取；太晚等于普通 miss，太早可能被替换，错误
预取还会争用带宽和缓存容量。

Fence：

```text
IDU.fence_ctrl_id_stall
LSU.x_ct_lsu_wmb.wmb_has_sync_fence
LSU.x_ct_lsu_wmb.wmb_sync_fence_biu_req_success
LSU.x_ct_lsu_wmb.wmb_empty
```

Fence 的核心不是执行一个算术功能，而是等待之前的访存达到规定的可见顺序。因此看到
前端/译码停顿时，应同时确认 WMB、RB 等旧事务是否已经排空。

LR/SC：

```text
LSU.x_ct_lsu_lm.lm_state[2:0]
LSU.x_ct_lsu_lm.lm_ld_da_hit_idx
```

运行 `ISA_AMO` 后观察 reservation 的建立、地址匹配、snoop/Store 造成的失效，以及
SC 成功或失败。普通 CoreMark 不会充分激活这些路径。

---

## 10. RTU：ROB、按序退休、精确异常和恢复

### 10.1 ROB 创建、完成和退休

建立 `11_rob_retire`：

```text
RTU.idu_rtu_rob_create0_en ... idu_rtu_rob_create3_en
RTU.x_ct_rtu_rob.rob_entry_num[6:0]
RTU.x_ct_rtu_rob.rob_full
RTU.x_ct_rtu_rob.rob_empty

RTU.x_ct_rtu_rob.x_ct_rtu_rob_rt.rob_read0_inst_vld
RTU.x_ct_rtu_rob.x_ct_rtu_rob_rt.rob_read0_cmplted
RTU.x_ct_rtu_rob.x_ct_rtu_rob_rt.rob_read0_commit
RTU.x_ct_rtu_rob.x_ct_rtu_rob_rt.rob_read0_expt_entry_vld
RTU.x_ct_rtu_rob.x_ct_rtu_rob_rt.rob_commit0/1/2
RTU.rtu_yy_xx_retire0/1/2
```

再加入所有完成总线：

```text
IU.iu_rtu_pipe0_cmplt / iu_rtu_pipe0_iid
IU.iu_rtu_pipe1_cmplt / iu_rtu_pipe1_iid
IU.iu_rtu_pipe2_cmplt / iu_rtu_pipe2_iid
LSU.lsu_rtu_wb_pipe3_cmplt / lsu_rtu_wb_pipe3_iid
LSU.lsu_rtu_wb_pipe4_cmplt / lsu_rtu_wb_pipe4_iid
VFPU.vfpu_rtu_pipe6_cmplt / vfpu_rtu_pipe6_iid
VFPU.vfpu_rtu_pipe7_cmplt / vfpu_rtu_pipe7_iid
```

找到一个年轻 IID 先完成、较老 IID 后完成，然后观察退休仍保持程序顺序。这是最直观的
乱序执行证据：

```text
执行完成顺序：IID 42 -> IID 40 -> IID 41
体系结构退休：IID 40 -> IID 41 -> IID 42
```

### 10.2 ROB 头阻塞分类

当 `rob_read0_inst_vld=1`、`rob_read0_cmplted=0` 时，加入：

```text
rob_read0_pipe0_cmplt
rob_read0_pipe1_cmplt
rob_read0_pipe2_cmplt
rob_read0_pipe3_cmplt
rob_read0_pipe4_cmplt
rob_read0_pipe6_cmplt
rob_read0_pipe7_cmplt
rob_read0_cmplted_no_spec_hit
rob_read0_cmplted_no_spec_miss
rob_read0_cmplted_no_spec_mispred
```

再用该 IID 对照各执行管线：

- Pipe3 长时间未完成：优先追 Load miss、重放或 TLB。
- Pipe0 除法 busy：优先追迭代除法。
- Pipe2 异常/误预测：追 BJU 与 flush。
- `cmplted=1` 但 `commit=0`：检查异常、Store 提交条件、异步异常和串行化。

按序退休会产生 head-of-line blocking：即使 ROB 中大量年轻指令已经完成，只要最老
指令没完成，退休端就不能越过它。这是乱序核隐藏延迟能力的边界，也是 Load miss 能把
整个窗口逐步填满的根本原因。

### 10.3 异常与精确状态

建立 `12_exception_flush`：

```text
RTU.x_ct_rtu_rob.x_ct_rtu_rob_expt.expt_entry_vld
RTU.x_ct_rtu_rob.x_ct_rtu_rob_expt.expt_entry_iid[6:0]
RTU.x_ct_rtu_rob.x_ct_rtu_rob_rt.rob_read0_expt_entry_vld
RTU.rtu_cp0_expt_vld
RTU.rtu_cp0_epc[63:0]
RTU.rtu_cp0_expt_mtval[63:0]
RTU.rtu_yy_xx_expt_vec[5:0]
RTU.x_ct_rtu_retire.retire_inst0_flush
RTU.x_ct_rtu_retire.retire_rob_flush
RTU.x_ct_rtu_retire.flush_cur_state[4:0]
RTU.rtu_ifu_chgflw_vld / rtu_ifu_chgflw_pc
```

异常可以在执行阶段较早被发现，但必须等到它成为 ROB 中最老的有效异常后才真正陷入。
在此之前，比它年轻的执行可以发生，但其结果不能提交。精确异常意味着软件看到的状态
等价于“异常指令之前全部完成，异常指令及之后全部未发生”。

### 10.4 PST：物理寄存器生命周期

选择一个实际参与运行的物理寄存器，例如：

```text
RTU.x_ct_rtu_pst_preg.x_ct_rtu_pst_entry_preg82.lifecycle_cur_state[4:0]
RTU.x_ct_rtu_pst_preg.x_ct_rtu_pst_entry_preg82.wb_cur_state
RTU.x_ct_rtu_pst_preg.x_ct_rtu_pst_entry_preg82.iid[6:0]
RTU.x_ct_rtu_pst_preg.x_ct_rtu_pst_entry_preg82.dst_reg[4:0]
RTU.x_ct_rtu_pst_preg.x_ct_rtu_pst_entry_preg82.rel_preg[6:0]
```

生命周期编码：

| 编码 | 状态 |
|---|---|
| `00001` | DEALLOC，空闲 |
| `00010` | WF_ALLOC，等待分配 |
| `00100` | ALLOC，已分配给在途指令 |
| `01000` | RETIRE，成为精确映射 |
| `10000` | RELEASE，等待安全释放 |

PST 是重命名系统的精确状态基础。RAT 面向快速投机查询，PST 面向退休、回收和恢复。
把某个 preg 的生命周期与对应 IID 的执行、写回、退休放在一起，可以完整理解统一 PRF
式重命名，而不是只停留在“有一张映射表”的概念上。

---

## 11. MMU、PMP、L2 和总线事务

### 11.1 MMU：翻译也是一套存储层次

当前 bare-metal CoreMark 通常不会充分激活分页翻译。观察 MMU 应运行 `MMU` case
或未来的操作系统环境。

建立 `13_mmu_ptw`：

| 路径 | 信号 |
|---|---|
| 指令侧请求/返回 | `MMU.ifu_mmu_va_vld`、`MMU.mmu_ifu_pavld`、`MMU.mmu_hpcp_iutlb_miss` |
| 数据侧请求/返回 | `MMU.lsu_mmu_va0_vld/va1_vld`、`MMU.mmu_lsu_pa0_vld/pa1_vld` |
| 数据侧停顿 | `MMU.mmu_lsu_stall0/stall1`、`MMU.mmu_lsu_tlb_busy` |
| uTLB 到 JTLB | `MMU.iutlb_arb_req/cmplt`、`MMU.dutlb_arb_req/cmplt` |
| JTLB 到 PTW | `MMU.jtlb_ptw_req`、`MMU.mmu_hpcp_jtlb_miss` |
| PTW 访存 | `MMU.ptw_arb_req`、`MMU.mmu_lsu_data_req`、`MMU.lsu_mmu_data_vld` |
| PTW 完成 | `MMU.ptw_jtlb_ref_data_vld`、`MMU.ptw_jtlb_ref_cmplt` |
| 页故障 | `MMU.mmu_lsu_page_fault0/page_fault1` |
| PTW 状态 | `MMU.x_ct_mmu_ptw.ptw_cur_st[4:0]` |

一次 TLB miss：

```text
VA 请求
  -> iTLB/dTLB miss
  -> 请求 JTLB
  -> JTLB miss
  -> PTW 按 Sv39 层级读取 PTE
  -> LSU/Cache/BIU 返回页表数据
  -> PTW 检查权限和叶子 PTE
  -> refill JTLB/uTLB
  -> 原请求得到 PA 或 page fault
```

PTW 状态中的 `FST/SCD/THD` 表示三级页表读取过程，`*_PMP`、`*_DATA`、`*_CHK`
分别表示权限检查、等待数据和检查 PTE。TLB 是“地址翻译的 Cache”，PTW miss 与普通
数据 Cache miss 的结构相似：都通过小而快的命中层隐藏更慢的后备层。

### 11.2 PMP

```text
PMP.mmu_pmp_pa0 ... mmu_pmp_pa4
PMP.pmp_mmu_flg0 ... pmp_mmu_flg4
PMP.cp0_pmp_mpp
PMP.cp0_pmp_mprv
PMP.x_ct_pmp_regs.pmpcfg0_value
PMP.x_ct_pmp_regs.pmpcfg2_value
```

PMP 根据物理地址、当前特权级、MPRV 和配置项产生读/写/执行属性，结果再由 MMU
形成最终访问权限或异常。观察权限错误时必须把“地址翻译成功”和“物理访问被允许”
分开，TLB 命中并不保证 PMP 允许访问。

### 11.3 L2 Cache

L2 有两个 sub-bank，分别观察：

```text
L2.x_ct_l2c_sub_bank_0.cmp_stage_vld
L2.x_ct_l2c_sub_bank_0.cmp_stage_addr[32:0]
L2.x_ct_l2c_sub_bank_0.x_ct_l2c_cmp.l2c_cache_hit
L2.x_ct_l2c_sub_bank_0.x_ct_l2c_cmp.l2c_cache_miss
L2.x_ct_l2c_sub_bank_0.tag_stage_vld
L2.x_ct_l2c_sub_bank_0.data_stage_vld
L2.x_ct_l2c_sub_bank_0.l2c_pipeline_rdy
```

sub-bank 1 使用同名信号。`l2c_cache_miss` 是 `!hit` 类组合结果，只能在
`cmp_stage_vld=1` 时解释。L2 访问应沿 compare/tag/data/writeback 等流水级推进；
`l2c_pipeline_rdy=0` 时上游请求可能被反压。

### 11.4 BIU 读事务

建立 `14_biu_axi`：

```text
BIU.x_ct_biu_read_channel.biu_pad_arvalid
BIU.x_ct_biu_read_channel.pad_biu_arready
BIU.x_ct_biu_read_channel.biu_pad_araddr[39:0]
BIU.x_ct_biu_read_channel.biu_pad_arid[4:0]
BIU.x_ct_biu_read_channel.biu_pad_arlen[1:0]
BIU.x_ct_biu_read_channel.biu_pad_arsize[2:0]

BIU.x_ct_biu_read_channel.pad_biu_rvalid
BIU.x_ct_biu_read_channel.biu_pad_rready
BIU.x_ct_biu_read_channel.pad_biu_rid[4:0]
BIU.x_ct_biu_read_channel.pad_biu_rdata[127:0]
BIU.x_ct_biu_read_channel.pad_biu_rlast
BIU.x_ct_biu_read_channel.pad_biu_rresp[3:0]
```

- AR 请求在 `arvalid && arready` 时真正发出。
- 每拍 R 数据在 `rvalid && rready` 时真正接收。
- `rid` 将返回数据与在途请求关联。
- `rlast` 标记最后一拍；从 AR 握手到最后一个 R 握手是完整读事务延迟。

### 11.5 BIU 写事务

```text
BIU.x_ct_biu_write_channel.biu_pad_awvalid
BIU.x_ct_biu_write_channel.pad_awready
BIU.x_ct_biu_write_channel.biu_pad_awaddr[39:0]
BIU.x_ct_biu_write_channel.biu_pad_awid[4:0]

BIU.x_ct_biu_write_channel.biu_pad_wvalid
BIU.x_ct_biu_write_channel.pad_wready
BIU.x_ct_biu_write_channel.biu_pad_wdata[127:0]
BIU.x_ct_biu_write_channel.biu_pad_wlast

BIU.x_ct_biu_write_channel.pad_biu_bvalid
BIU.x_ct_biu_write_channel.biu_pad_bready
BIU.x_ct_biu_write_channel.pad_biu_bid[4:0]
BIU.x_ct_biu_write_channel.pad_biu_bresp[1:0]
```

AXI 写地址、写数据和写响应是三个独立通道，不能只看 AW 就认为写已经完成。
完整路径是 AW 握手、所有 W 拍握手、最后收到 B 响应。这里的 `pad_awready` 和
`pad_wready` 是写通道根据当前事务的 shareable/non-shareable 属性，从两套外部
ready 中选择出的实际握手条件；应使用它们与对应 valid 配对。当前 `smart_run`
外部存储是仿真模型，其延迟不能直接代表真实 DDR，但握手、并发和反压机制仍可用于
架构学习。

### 11.6 ACE snoop 和多核一致性

普通单核 CoreMark 不会充分展示一致性。双核/一致性测试时加入：

```text
BIU.x_ct_biu_snoop_channel.pad_biu_acvalid
BIU.x_ct_biu_snoop_channel.biu_pad_acready
BIU.x_ct_biu_snoop_channel.pad_biu_acaddr[39:0]
BIU.x_ct_biu_snoop_channel.biu_pad_crvalid
BIU.x_ct_biu_snoop_channel.pad_biu_crready
BIU.x_ct_biu_snoop_channel.biu_pad_cdvalid
BIU.x_ct_biu_snoop_channel.pad_biu_cdready
BIU.x_ct_biu_snoop_channel.biu_pad_cddata[127:0]
BIU.x_ct_biu_snoop_channel.biu_pad_cdlast
```

AC 是 snoop 地址，CR 是一致性响应，CD 是需要回传的脏数据。一次 snoop 可能只需
CR，也可能需要 CR+CD。将其与 LSU 的 SNQ、D-Cache tag/dirty 状态和 CIU SNB 放在
一起，可以观察“另一个主设备请求一行，本核检查私有 Cache 并决定是否提供数据”的过程。

---

## 12. CP0、中断、特权切换和低功耗

建立 `15_trap_privilege`：

```text
CP0.cp0_yy_priv_mode[1:0]
CP0.rtu_cp0_expt_vld
CP0.rtu_cp0_epc[63:0]
CP0.rtu_cp0_expt_mtval[63:0]
CP0.rtu_yy_xx_expt_vec[5:0]
CP0.cp0_mret
CP0.cp0_sret
CP0.hpcp_cp0_int_vld
RTU.rtu_idu_retire_int_vld
RTU.rtu_ifu_chgflw_vld
RTU.rtu_ifu_chgflw_pc[38:0]
```

异常与中断都改变控制流，但边界不同：

- 同步异常由某条指令触发，`epc/mtval/expt_vec` 对应该指令。
- 异步中断在合法退休边界被接收，不应破坏之前已经提交的指令。
- `mret/sret` 恢复特权状态并重定向到保存的返回 PC。

低功耗/时钟门控观察：

```text
CP0.cp0_yy_clk_en
CORE.forever_cpuclk
各模块内部的 *_clk、*_clk_en
```

内部 gated clock 不翻转通常表示模块空闲，并不等于仿真卡死。先看 `cp0_yy_clk_en`
和局部 `clk_en`，再判断数据通路为何没有活动。时钟门控信号主要用于理解功耗设计，
不应作为性能事件直接累计，因为一个模块可能因没有工作而合理地关钟。

---

## 13. 十个端到端波形实验

### 13.1 实验一：一条普通整数指令

1. 在退休 PC 中选一条反汇编已知的 `add/xor/shift`。
2. 找到对应时间附近 AIQ0/AIQ1 中的 entry 和 IID。
3. 观察 `entry_ready -> entry_issue_en -> rf_pipe*_inst_vld`。
4. 用 IID 跟到 `iu_rtu_pipe*_cmplt`。
5. 用 dst preg 跟踪 EX1 前递和 EX2 写回。
6. 最后观察该指令按序退休。

目标：区分“选择、发射、执行、前递、写回、完成、退休”七个动作。

### 13.2 实验二：RAW 依赖链

选择连续使用前一结果的代码：

```text
producer.dst_preg
  -> consumer.src_preg 相同
  -> consumer entry ready=0
  -> producer fwd/wb
  -> consumer ready=1
  -> consumer issue
```

目标：看到重命名没有消除 RAW，但前递缩短了等待时间。

### 13.3 实验三：双整数发射

并排观察 AIQ0、AIQ1、pipe0、pipe1 的 issue/RF/ALU/complete。选择两条无依赖整数
指令同时发射的周期，再找一组存在依赖而不能双发射的周期。

目标：理解“有两个 ALU”只是能力上限，实际双发射还取决于可用 ILP、队列映射和依赖。

### 13.4 实验四：分支预测正确与错误

先选一个正确预测分支，确认没有 redirect/flush；再选一个 mispred，观察第 5.2 节
完整链路并测量从 BJU 发现错误到重新退休有效指令的周期数。

目标：把预测准确率和单次误预测惩罚区分开。性能损失约由二者乘积决定。

### 13.5 实验五：L1 D-Cache hit

按 IID 跟踪一条 Load 的 AG/DC/DA/WB，确认 `ld_da_dcache_miss=0`，并观察消费者是在
Load 前递时被唤醒，还是等正式写回。

目标：理解 Load-use latency，而不只看 Load 总数。

### 13.6 实验六：D-Cache miss

从 `ld_da_dcache_miss` 开始，跟踪 RB、LFB、BIU/L2、refill、dependency wakeup 和最终
Load complete，同时观察 ROB 水位和退休空洞。

目标：理解一次 miss 如何从局部延迟扩大成 ROB 头阻塞，以及乱序窗口能隐藏多少延迟。

### 13.7 实验七：Store-to-Load forwarding

选择同地址 Store 后紧跟 Load 的测试，观察 SQ/WMB fwd request、Load 前递有效和消费者
唤醒；再构造 Store 数据较晚到达的情况，观察 discard/replay。

目标：理解访存乱序不是简单的“Load 可以越过 Store”，而是带地址比较、数据前递和恢复。

### 13.8 实验八：除法长延迟

观察 AIQ0 发射、`div_busy`、SRT finish、写回预约和最终数据，比较普通除法与除零、
特殊值或重复商余数路径。

目标：理解变延迟功能单元如何与统一发射和写回端口协同。

### 13.9 实验九：精确异常

运行 exception case，观察异常在执行端被发现、进入最老异常记录、到达 ROB 头、
CP0 接收 epc/mtval、RTU flush、IFU 跳转异常向量。

目标：用波形证明“年轻指令可以先执行，但不能越过异常提交”。

### 13.10 实验十：TLB miss 与 PTW

运行 MMU case，观察 VA、uTLB/JTLB miss、三级 PTW、PTE 数据返回、TLB refill 和原访问
恢复。若触发 page fault，再与正常 refill 路径对比。

目标：把虚拟内存理解为一条真实的硬件流水，而不是软件层的抽象概念。

---

## 14. 从波形定位性能瓶颈

### 14.1 先按“供给、调度、执行、退休”四层归因

| 层次 | 关键组合 | 结论方向 |
|---|---|---|
| 供给 | IBUF empty、ID valid 少、ROB 低占用 | 取指、预测、I-Cache、对齐 |
| 调度 | ROB 有工作、IQ 高占用、ready 少 | 数据依赖或 Load 依赖 |
| 执行 | ready 多但 issue 少，或 RF launch fail | 端口、功能单元、PRF/写回冲突 |
| 退休 | 大量已完成但 ROB 头不可提交 | 长延迟头阻塞、异常、Store/串行化 |

### 14.2 常见组合的严格解释

**前端瓶颈**

```text
retire 低
+ ROB 经常空或低占用
+ IBUF 经常空
+ ID 输入 valid 少
+ IFU refill/redirect/特殊 stall 可解释这些空洞
```

只有 `if_frontend_stall` 高不够，因为它可能是后端反压传播到前端。

**数据依赖瓶颈**

```text
ROB 有足够在途指令
+ IQ 占用不低
+ entry_vld 很多但 entry_ready 很少
+ 不就绪源集中等待少数 preg
+ 这些 preg 的生产者是长延迟 Load/乘除法
```

**执行端口瓶颈**

```text
IQ 中 ready 指令多
+ issue_en 受限
+ 对应功能单元或写回端口 busy/stall
+ 其他 pipe 可能空闲但不能执行该类型指令
```

不能仅以“总执行管线未满”否定端口瓶颈。功能单元是异构的，分支不能借用 VFPU，
Load 也不能借用普通 ALU 完成 Cache 访问。

**存储层次瓶颈**

```text
Load miss/TLB miss/replay 活跃
+ LSIQ、LQ、RB、LFB 中至少一处积压
+ ROB 头等待 pipe3 完成
+ 后续 IQ 出现 load-dependent not-ready
+ 退休产生长空洞
```

这条链比“D-Cache miss 率高”更强，因为它证明 miss 真正处于关键路径。

**退休瓶颈**

```text
ROB 高占用
+ 多条年轻 IID 已完成
+ rob_read0_cmplted 或 commit 长时间为 0
+ 头部原因可由具体 pipe、异常或 Store 条件解释
```

### 14.3 波形和性能计数器应互相验证

波形适合回答“为什么这一段发生停顿”，计数器适合回答“整个程序中这种现象有多少”。
正确研究流程是：

1. 从 `.detail.perf` 找到占比高的事件。
2. 在 FSDB 中找到该事件的代表性时间段。
3. 用本指南的跨模块信号链确认因果关系。
4. 修改 RTL 后，用计数器验证全程序改善，用波形确认机制按预期改变。
5. 同时检查 IPC、错误恢复、Cache miss、面积和时序，避免局部优化转移瓶颈。

微结构优化不是把某个计数器压低，而是减少关键路径上的无效等待，同时不制造更大的
新瓶颈。波形负责证明机制，统计负责证明代表性，两者缺一不可。

---

## 15. 推荐的 Verdi Signal Group

| 组名 | 内容 | 建议工作负载 |
|---|---|---|
| `00_arch_anchor` | retire、ROB、PC、flush | 所有程序 |
| `01_ifu_flow` | PCGEN、IF/IP/IB valid/stall | CoreMark、bench_frontend |
| `02_ibuf` | IBUF 指针、empty/full、bypass | CoreMark、bench_frontend |
| `03_icache_refill` | miss/refill/reissue | 大代码工作集、SPEC kernel |
| `04_branch_predictor` | BTB/BHT/GHR/RAS | bench_br_*、CoreMark |
| `05_branch_recovery` | BJU 校验、redirect、flush | bench_branch、bench_br_* |
| `06_decode_rename` | ID/IR、split、preg 分配 | CoreMark、bench_ilp |
| `07_issue_queues` | 七个 IQ 的 cnt/vld/ready/issue | CoreMark、SPEC kernel |
| `08_issue_execute` | RF、IID、ALU/MUL/DIV、前递 | bench_ilp、CoreMark |
| `09_load_pipeline` | Load AG/DC/DA/WB | bench_mem、SPEC memory kernel |
| `10_memory_ordering` | LQ/SQ/WMB、forward/replay | bench_mem、ISA_AMO |
| `11_rob_retire` | create/complete/commit/retire | 所有程序 |
| `12_exception_flush` | exception、CP0、flush FSM | exception/csr case |
| `13_mmu_ptw` | TLB/JTLB/PTW/PMP | MMU |
| `14_biu_axi` | AR/R/AW/W/B | Cache miss、MMU |
| `15_trap_privilege` | 中断、异常、mret/sret | interrupt、csr、OS |
| `16_vfpu` | VIQ、pipe6/7、forward/writeback | bench_fp、ISA_FP、RVV |
| `17_coherence` | AC/CR/CD、SNQ、CIU/L2 | 双核一致性测试 |

第一次学习不要同时打开 18 组。推荐顺序是：

```text
arch_anchor
  -> ifu_flow
  -> decode_rename
  -> issue_queues
  -> issue_execute
  -> load_pipeline
  -> rob_retire
  -> branch_recovery
  -> MMU/L2/BIU/一致性等专题
```

---

## 16. 必须避免的误判

1. `valid=1` 不等于发生传输，必须看 ready/grant。
2. stall 期间 valid 保持不代表重复执行。
3. `entry_cnt` 高不等于队列瓶颈，必须证明 full 或等待传播到上游。
4. `entry_ready=0` 不等于执行端口不足，它通常先指向操作数依赖。
5. `entry_ready=1` 不等于本拍一定发射，还要看选择、功能单元和 RF launch。
6. `cmplt=1` 不等于数据已写回，也不等于指令已退休。
7. `retire0/1/2` 是退休槽，折叠和拆分会使其不总等于架构指令条数。
8. `l2c_cache_miss` 必须与 `cmp_stage_vld` 同看。
9. 一次 `ld_da_dcache_miss` 不等于一定产生新的外部请求，可能命中已有 LFB/RB。
10. Store 退休不等于已经写到外部存储，WMB 仍可能持有它。
11. IFU stall 不一定是纯前端原因，后端反压可以一路传播回来。
12. 相同 IID 在远距离时间点可能是编号回绕后的不同指令。
13. flush 前已经执行的年轻指令可能属于错误路径，不能作为有效工作解释。
14. CoreMark 不足以激活 MMU、VFPU、原子、一致性和完整异常路径。
15. `smart_run` 的存储模型不是真实 DDR，波形适合看协议和因果，不适合直接推导 DDR 性能。

---

## 17. 配套 RTL 与文档

机制背景可继续查阅：

- `docs/C910_体系结构总览.md`
- `docs/branch_prediction.md`
- `docs/ifu/00_ifu_overview.md`
- `docs/idu/00_idu_overview.md`
- `docs/iu/00_iu_overview.md`
- `docs/lsu/00_lsu_overview.md`
- `docs/rtu/00_rtu_overview.md`
- `docs/mmu/00_mmu_overview.md`
- `docs/l2c/00_l2c_overview.md`
- `docs/biu/00_biu_overview.md`
- `smart_run/PERF_DETAIL.md`

关键信号的 RTL 来源：

- `C910_RTL_FACTORY/gen_rtl/ifu/rtl/`
- `C910_RTL_FACTORY/gen_rtl/idu/rtl/`
- `C910_RTL_FACTORY/gen_rtl/iu/rtl/`
- `C910_RTL_FACTORY/gen_rtl/lsu/rtl/`
- `C910_RTL_FACTORY/gen_rtl/vfpu/rtl/`
- `C910_RTL_FACTORY/gen_rtl/rtu/rtl/`
- `C910_RTL_FACTORY/gen_rtl/mmu/rtl/`
- `C910_RTL_FACTORY/gen_rtl/pmp/rtl/`
- `C910_RTL_FACTORY/gen_rtl/biu/rtl/`
- `C910_RTL_FACTORY/gen_rtl/ciu/rtl/`
- `C910_RTL_FACTORY/gen_rtl/l2c/rtl/`

最终应形成一种稳定的观察习惯：

```text
先用退休 PC 确定程序语义
  -> 用 IID 找到在途指令
  -> 用 preg 找到真实依赖
  -> 用 valid/ready/grant 判断事件是否成立
  -> 用 queue/ROB 水位判断压力是否传播
  -> 用 flush/commit 区分投机工作和有效工作
  -> 用 Cache/TLB/AXI ID 追踪长延迟事务
  -> 最后回到退休，确认它是否真的影响体系结构进度
```

这条闭环比单纯记忆模块名称更重要。掌握它以后，换到其他乱序处理器时，信号名会变，
但“供给、重命名、唤醒选择、执行、存储排序、按序退休、错误恢复”这套分析框架仍然成立。
