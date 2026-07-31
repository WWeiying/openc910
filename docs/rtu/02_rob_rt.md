# C910 ROB 退休读与 PC 重建详解（ct_rtu_rob_rt）

> RTL 源文件：`C910_RTL_FACTORY/gen_rtl/rtu/rtl/ct_rtu_rob_rt.v`（2768 行）
>
> rob_rt 在 ct_rtu_rob 内部例化，负责：维护 3 个退休读项的有效性、
> 生成退休所需的全部表项信息、以及全文档最有特色的一段逻辑——
> **用增量加法按序重建退休 PC**。

---

## 1. 为什么退休 PC 需要"重建"

ROB 表项不存 PC（`docs/rtu/01_rob.md` 第 1.1 节），但退休时必须知道每条
指令的精确 PC：

- 异常要填 epc；
- 中断要记返回点；
- HPCP/调试器要逐条退休 PC（`rtu_hpcp_inst0/1/2_cur_pc`、`rtu_pad_retire*_pc`）。

C910 的方案：**RTU 自己维护一个"退休游标 PC"（rob_cur_pc），每退休一项就
加上该项的 pc_offset；遇到跳转指令则从 PCFIFO 弹出的真实目标重新装载**。
本质上是用少量固定的退休侧加法逻辑，代替每个 ROB 表项各保存一份 39 位 PC。
RTL 对退休槽 PC、当前基准 PC 和 split FOF 修正分别写有加法表达式；综合工具
是否共享这些运算取决于时序与物理实现，因此这里描述的是存储压缩思想，而不是
断言网表中恰好只有一个加法器。

这里所有 39 位 PC 信号都省略了恒为 0 的字节地址最低位：

```text
RTL 编码 PC = byte_pc[39:1]
真实字节地址 = {RTL 编码 PC, 1'b0}
```

因此，`rob_cur_pc + 1` 表示字节地址前进 2 字节，而不是 1 字节。下文中的
`pc_offset`、`+2` 和跳转目标都必须先按这个单位理解，才能与反汇编地址对齐。

```
            非跳转项: cur_pc += pc_offset(折叠总长)
 rob_cur_pc ────────────────────────────────────────►
            跳转项(bju=1): cur_pc = PCFIFO 弹出的 next_pc(真实目标)
```

## 2. 三条退休指令的 PC 级联（rob_rt.v:2128-2302）

一拍退休 3 项时，inst1/inst2 的 PC 依赖前面项的结果，形成级联选择：

```verilog
// inst0: 就是当前游标（L2145-2147）
assign rob_read0_cur_pc = rob_cur_pc;

// inst1: 前一项是跳转？用它的目标；否则游标+offset0（L2149-2152）
assign rob_read1_cur_pc_addend0 = rob_read0_data[ROB_BJU] ? rob_read0_next_pc
                                                          : rob_cur_pc;
assign rob_read1_cur_pc_addend1 = rob_read0_pc_offset;   // bju 时 offset 为 0

// inst2: 看 inst1、再看 inst0 是否跳转，三选一（L2154-2173）
if(read1 是 bju)      addend0 = read1_next_pc,           addend1 = 0
else if(read0 是 bju) addend0 = read0_next_pc,           addend1 = offset1
else                  addend0 = rob_cur_pc,              addend1 = offset0+offset1

// 游标更新值 = inst2 的 next_pc，四选一（L2179-2216）
```

**实现技巧：addend 选择打拍、加法后置**（L2251-2298）。表项进入退休读缓冲时
先把 `addend0/addend1` 选好锁存，输出端才做 39 位基值与零扩展 5 位偏移量的
加法。这里“偏移输入只有 5 位”不等于整个加法器只有 5 位：输出和进位传播仍按
39 位地址宽度实现。该组织方式的可确认作用是把主要选择逻辑与输出加法分到不同
阶段；实际综合后的门级深度和是否成为关键路径仍应以时序报告为准。
注释（L2221-2222）说明 inst0 的 PC 还要为 flush/断点打拍输出给 IFU/HAD。

`rob_read*_next_pc` 来自 **PCFIFO 弹出数据**（`iu_rtu_pcfifo_pop0/1/2_data`，
经 L1710 的 "PCFIFO Pop Data select" 对位到退休槽位）——这正是
`docs/iu/03_bju_pcfifo.md` 第 4.3 节所述三个 48 位弹出口的消费处。表项的
`ROB_PCFIFO` 位指示本项是否占用 PCFIFO 弹出槽，`rtu_iu_rob_read*_pcfifo_vld`
就据此生成。

**游标装载**（L2310-2357）：复位后由 `ifu_rtu_cur_pc_load` 用 IFU 的初始 PC
装载；`rte/rfi`（异常返回）时下一 PC 是 CP0 给的 EPC（L2334-2337 注释：
异常返回是 fence 类指令，单独退休，游标直接装 efpc）；
split FOF flush（向量 fault-only-first 拆分）时，对编码 PC 加 2
（L2348-2353）。由于编码省略了 `PC[0]`，这等价于字节地址加 4，用于把
退休观察点推进到该 32 位架构指令之后。这里的“+2”既不是加 2 字节，也不是
“跳过两个微操作”；微操作数量与 PC 编码增量不是同一个量。

## 3. 退休读项的有效性维护（rob_rt.v:1006-1709）

三个退休读项是 ROB 头部的"展示窗"：

- **补位**（L1290 起 "Prepare retire entry update valid signal"）：每拍按
  退休数把后续 ROB 项滑入读缓冲（弹 N 项则 readN~N+2 数据前移）；
- **完成追踪**（L1023-1289）：指令可能在进入退休窗后才完成，7 管线 cmplt
  对 3 个读项也要做 iid 匹配递减（"ROB read 0/1/2 cmplting"、
  "Prepare fold inst cmplt number"）——这就是读缓冲必须是完整 rob_entry
  实例的原因；
- **特殊事件只打在 inst0**（L2013-2048）：中断（`rob_retire_int_srt_en`）、
  调试请求、CTC flush 都强制**单退休模式**（srt），保证事件精确命中
  退休流第一条指令。

## 4. 输出汇总

| 输出 | 去向 | 内容 |
|------|------|------|
| `rob_retire_inst0/1/2_vld + 各字段` | retire 模块 | 退休判定原料 |
| `rob_retire_inst0/1/2_cur_pc/next_pc` | retire/CP0/HAD/HPCP | 重建的精确 PC |
| `rtu_hpcp_inst0/1/2_cur_pc[39:0]` | HPCP | 性能计数采样 PC |
| `rob_retire_inst0_iid` 等 | PST | 退休 iid 匹配（见 05） |
| `rtu_iu_rob_read0/1/2_pcfifo_vld` | IU PCFIFO | 弹出使能 |

## 5. Verdi 观察建议

层次：`...x_ct_rtu_rob.x_ct_rtu_rob_rt`

| 信号 | 看什么 |
|------|--------|
| `rob_cur_pc[38:0]` | 退休游标的 `byte_pc[39:1]` 编码；拼接低位 0 后才是字节地址 |
| `retire_inst0_cur_pc` vs 反汇编 | 验证 PC 重建正确性（对照 coremark.asm） |
| `rob_read0_data[9]`（ROB_BJU 位） | 跳转项触发游标重装 |
| `retire_rob_split_fof_flush` | 向量 fof 的 +2 特例 |

把 `{rob_cur_pc,1'b0}` 加进波形再对照 `smart_run/work/coremark.asm`，
就能逐拍追踪退休到了哪个函数——这是性能分析时定位热点最直接的手段。
