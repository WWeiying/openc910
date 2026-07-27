# C910 分支预测机制完整梳理

> 本文是跨模块专题，把散落在 IFU（预测）、IU/BJU（检查纠错）、RTU（退休/flush）
> 中的分支预测逻辑串成一条完整闭环。读完应理解：5 个预测器各在哪个流水级工作、
> 不同指令类型走哪条预测路径、预测如何被检查纠错、预测器如何更新与恢复。
>
> 模块级行级细节见 `ifu/01_pcgen.md`、`02_l0_btb.md`、`03_btb.md`、`04_bht.md`、`05_ras.md`。

---

## 目录

1. [分支预测要解决什么问题](#1-分支预测要解决什么问题)
2. [预测器全景与流水级映射](#2-预测器全景与流水级映射)
3. [五个预测器的分工](#3-五个预测器的分工)
4. [各流水级的预测活动](#4-各流水级的预测活动)
5. [按指令类型分类的预测逻辑](#5-按指令类型分类的预测逻辑)
6. [一次预测的完整时序](#6-一次预测的完整时序)
7. [预测检查与纠错（BJU 三级流水）](#7-预测检查与纠错bju-三级流水)
8. [预测器更新闭环](#8-预测器更新闭环)
9. [双 GHR 机制与恢复](#9-双-ghr-机制与恢复)
10. [flush 与状态恢复](#10-flush-与状态恢复)
11. [完整闭环全景图](#11-完整闭环全景图)

---

## 1. 分支预测要解决什么问题

C910 是深流水乱序处理器，从取指（IFU）到分支执行（IU/BJU EX1）间隔多个流水级。
若不预测，每条分支都要等执行确认后才能继续取指，流水线大量空转。

分支预测要回答**两个独立问题**：

| 问题 | 含义 | 负责的预测器 |
|------|------|--------------|
| **方向**（direction） | 条件分支跳还是不跳？ | BHT（Bi-Mode） |
| **目标**（target） | 若跳，跳到哪个地址？ | L0 BTB / BTB / Indirect BTB / RAS |

不同指令类型需要的预测组合不同：
- 条件分支（BEQ/BNE/...）：需要**方向 + 目标**
- 直接跳转（JAL）：目标编码在指令里，方向恒 taken，主要靠 BTB 提前给目标
- 间接跳转（JALR）：方向恒 taken，但目标在寄存器里 → Indirect BTB
- 函数返回（RET = JALR x0, ra, 0）：目标是返回地址 → RAS

---

## 2. 预测器全景与流水级映射

IFU 内部三级流水：**PCGEN → IF → IP → IB**（IB 后进 IBUF）。各预测器工作在不同级：

```
流水级    PCGEN          IF              IP                IB
          ─────          ──              ──                ──
          PC 选择        I-Cache 读      预解码/分支决策    打包送出
          ↓              ↓               ↓                 ↓
预测器:   L0 BTB ★       BTB 读出        BTB tag 比较      Indirect BTB 检查
          (零延迟)       BHT sel 读出    BHT pred 读出      addrgen 确认
                                         RAS 读栈顶
                                         → 形成预测跳转

★ L0 BTB 在 PCGEN 当拍即可改变下一 PC，零额外延迟
```

| 预测器 | 工作流水级 | 延迟 | 容量 | 解决的问题 |
|--------|-----------|------|------|-----------|
| **L0 BTB** | PCGEN | 0 拍 | 16 项（寄存器） | 目标（热点） |
| **BTB** | IF 读 / IP 用 | 1 拍 | 1024×4 路 SRAM | 目标 |
| **BHT** | IF 读 / IP 用 | 2 拍 | 64K bits Bi-Mode | 方向 |
| **RAS** | IP | 0 拍（栈顶寄存器） | 18 项 | 返回目标 |
| **Indirect BTB** | IP 检查 / IB | — | 独立 SRAM | 间接目标 |

> 设计哲学：**分级预测**。最常用的少量分支用零延迟的 L0 BTB 覆盖；
> 更大范围用有 1~2 拍延迟但容量大的 BTB/BHT；间接跳转和返回用专用结构。
> 精度逐级提高，延迟逐级增加。

### 2.1 本文的 PC 位号约定

C910 IFU/RTU 内部多数 39 位 PC 使用半字地址：

```text
rtl_pc[38:0] = byte_pc[39:1]
byte_pc      = {rtl_pc, 1'b0}
```

因此本文写 `rtl_vpc[n]` 时指 RTL 信号位号，它对应架构字节地址位 `byte_vpc[n+1]`。
`iu_ifu_chgflw_pc[62:0]` 同理保存架构 VA `[63:1]`。IU PCFIFO 的 `[39:0]`
以及 `rtu_cp0_epc[63:0]` 已经是完整字节地址，是例外。

---

## 3. 五个预测器的分工

### 3.1 L0 BTB（零延迟目标预测）
- 16 项全寄存器实现，在 PCGEN 当拍并行比较 16 路 tag，命中即在下一拍改流。
- 消除 BTB 的 1 拍 SRAM 读延迟，专门加速热点分支/小循环。
- 由 addrgen（IB+1）更新；命中信息直接送 ifctrl 触发 IF 级 chgflw。

### 3.2 BTB（主目标预测）
- 1024 项 ×4 路组相联，存 `{valid, tag, target[19:0], way_pred[1:0]}`。
- index = `rtl_vpc[12:3]` = 字节 PC `[13:4]`，tag = `{rtl_vpc[19:13], rtl_vpc[2:0]}` = `{byte_pc[20:14],byte_pc[3:1]}`。
- 读 2 拍：PCGEN 送 index → IF 读出 → IP 做 tag 比较定命中路。
- **Refill Buffer 延迟写**：way_pred 在 miss 时还不知道，先缓存待 2 拍后补全再写 BTB。

### 3.3 BHT（Bi-Mode 方向预测）
- 双预测表（Taken 表 + Not-Taken 表）+ 选择表（Select Array）。
- Select Array 用 PC 索引、在 IF 级读；Predict Array 用 VGHR 折叠索引、在 IP 级读。
- 最终：`sel_array_result[1]` 选哪张表 → 该表 2-bit 计数器 MSB 即方向预测。
- Bi-Mode 把"偏跳"和"偏不跳"的分支分表存放，消除别名干扰。

### 3.4 RAS（返回地址栈）
- **双栈**：IFU 侧 12 项投机栈 + RTU 侧 6 项退休栈（又一处投机/退休双轨，见第 9 节统一模式）。
- 每项存 `{pc, priv_mode[1:0], filled}`——存特权级，不同特权级的返回地址不可混用。
- **5 位指针**：低 4 位指栈顶，最高 1 位作"圈数奇偶"标志。因为 12 项不是 2 的幂，
  不能靠低位直接比较判满/空：两指针低 4 位相同且最高位相同 → 空；最高位不同 → 满。
  环绕在 12（`top_ptr[3:0]==11` 时翻转 bit[4]、低位归 0），而非 16。
- call（`ibctrl_ras_pcall_vld`）压栈、ret（`ibctrl_ras_preturn_vld`）弹栈；ibctrl 按
  RISC-V 的 rd/rs1 约定识别 call/ret，区别于普通 JALR。
- IP 级提供栈顶作为 ret 的预测目标，配对正确时精度接近 100%。
- **恢复**：误预测/flush 时，IFU 投机栈从 RTU 退休栈恢复（同 GHR、PATH 的双轨模式）。

### 3.5 Indirect BTB（间接跳转目标预测）

针对 JALR（非 ret 的间接跳转，如虚函数、函数指针、switch 跳转表）。同一条 JALR
在不同上下文可能跳到不同目标，所以不能像 BTB 那样只用 PC 索引——必须用**执行路径历史**
区分。Indirect BTB 是 C910 分支预测里结构最特殊的一个，以下是完整微结构。

**容量与存储项**（`ct_ifu_ind_btb.v:283`）
```
256 项（8 位 index）SRAM，每项 23 位：
  data_in = {vld(1), priv_mode[1:0], target[19:0]}
```
注意存了 `priv_mode`——不同特权级的间接目标不能混用，读出时要校验特权级。

**PATH 寄存器：投机/退休双轨（与 GHR 完全对称的设计）**

间接跳转预测的"上下文"由一组**路径历史移位寄存器**表示，共 4×8 位，分两套：

| 套 | 寄存器 | 更新时机 | 用途 |
|----|--------|----------|------|
| 投机 | `path_reg_0/1/2/3` | IB 级检测到间接跳转（`ibctrl_ind_btb_check_vld`） | 取指时算读索引 |
| 退休 | `rtu_path_reg_0/1/2/3` | RTU 退休间接跳转（`rtu_jmp_check_vld`） | 算写索引 + 恢复投机侧 |

投机侧每检测到一条间接跳转就**移位**（`ct_ifu_ind_btb.v:522`）：
```
reg0 ← 本条 jalr 的 chk_idx（ibctrl_ind_btb_path）
reg1 ← 旧 reg0,  reg2 ← 旧 reg1,  reg3 ← 旧 reg2   （历史路径左移一格）
```
退休侧按一拍最多 3 条退休（retire0/1/2）的组合做多级移位（:399 起的 8 路 case）。

**索引：PATH 与 GHR 分段异或折叠**（`:309`、`:316`）
```
读索引（投机，取指用）：
  ind_btb_rd_index[7:0] = { path_reg_3_pre[7:6] ^ vghr[7:6],
                            path_reg_2_pre[5:4] ^ vghr[5:4],
                            path_reg_1_pre[3:2] ^ vghr[3:2],
                            path_reg_0_pre[1:0] ^ vghr[1:0] }
写索引（退休，更新用）：用 rtu_path_reg 与 rtu_ghr 同样折叠
```
把路径历史和全局分支历史（GHR）两种信息异或折叠成 8 位索引——既区分上下文，又复用 BHT 的 GHR。

**读时机**：只有 IP 级检测到 JMP 指令（`ipdp_ind_btb_jmp_detect`）时才读（`:206`），省功耗。

**写（更新）时机**：只在 RTU 退休确认间接跳转**误预测**（`rtu_ifu_retire0_jmp_mispred`，:207）
时写入真实目标 `rtu_ifu_retire0_next_pc[19:0]`。写优先级高于读（:259）。

**恢复**：`path_reg_rtu_updt = rtu_ifu_retire0_mispred || rtu_ifu_flush`（:254）。
即任何误预测退休或 flush 时，投机 `path_reg ← 退休 rtu_path_reg_pre`（:522）——
和 BHT 的 `VGHR ← RTUGHR` 完全对称：投机路径被错误路径污染后，用退休侧的精确路径恢复。

**INV**：`ind_btb_inv_on_reg` 拉高时用 `ind_btb_inv_cnt` 倒计数逐项清零（256 项）。

---

## 4. 各流水级的预测活动

### PCGEN 级
```
1. 从 10 个来源选下一 PC（pcgen 优先级 MUX）
2. L0 BTB 并行查（零延迟）：命中则下一拍就跳到 target
3. 把 PC 的 index 送 I-Cache、BTB、BHT-sel 开始读（1 拍后出结果）
```

### IF 级
```
1. I-Cache tag/data 读出，ifdp 做命中判断
2. BTB 读出 4 路 {tag, target, way_pred}
3. BHT Select Array 读出
4. precode（预解码）标记哪些半字是分支
```

### IP 级（分支决策核心）
```
1. ipctrl/ipdp 用 precode + BRY 定位分支指令
2. BTB tag 比较 → 命中则得 target
3. BHT Predict Array 读出 → sel 选表 → 得方向预测
4. RAS 读栈顶（若是 ret）
5. Indirect BTB 读（若是 JALR）
6. 综合：若预测 taken → 生成 ipctrl_pcgen_chgflw → 通知 PCGEN 改流
7. 投机更新 VGHR（追加本次分支方向）
```

### IB 级
```
1. ibctrl 打包指令写 IBUF
2. 识别 call/ret → RAS push/pop
3. Indirect BTB 检查（IB 级 check ind_btb inst → 更新 PATH）
4. addrgen（IB+1）计算实际直接分支目标，与预测比对，更新 L0 BTB / BTB
```

---

## 5. 按指令类型分类的预测逻辑

### 5.1 条件分支（BEQ / BNE / BLT / BLTU / BGE / BGEU）
```
目标：BTB（或 L0 BTB）提供——目标是 PC+offset，编译期确定，BTB 记忆
方向：BHT 预测 taken/not-taken
决策：
  BHT 预测 taken + BTB 有目标 → 跳到 BTB target
  BHT 预测 not-taken          → 顺序执行（PC+2/+4）
```

### 5.2 直接无条件跳转（JAL）
```
方向：恒 taken
目标：PC + offset（编码在指令里）
预测：BTB / L0 BTB 提供 target（让 IFU 不必等译码算 offset 就能提前跳）
precode 的 ab_br 位标记 JAL，可早期识别
```

### 5.3 间接跳转（JALR，非返回）
```
方向：恒 taken
目标：rs1 + offset（运行时寄存器值，编译期未知）
预测：Indirect BTB（用历史路径区分同一 JALR 的多个目标，如虚函数/跳转表）
```

### 5.4 函数返回（RET = JALR x0, ra, 0）
```
方向：恒 taken
目标：返回地址（调用点的下一条）
预测：RAS 弹栈（call 时已压入返回地址）
ibctrl 通过 rd/rs1 寄存器约定识别 ret，区别于普通 JALR
```

---

## 6. 一次预测的完整时序

以条件分支命中 BTB+BHT 为例：

```
周期 N   (PCGEN)：if_pc=分支所在行 → 送 index 给 BTB/BHT-sel/I-Cache
                  L0 BTB 并行查（此例未命中，走 BTB 路径）

周期 N+1 (IF)   ：BTB 读出 4 路 target；BHT Select 读出
                  ifdp tag 比较；BHT Predict Array 用 VGHR 索引开始读

周期 N+2 (IP)   ：BTB tag 命中 → 得 target
                  BHT：sel 选表 → 2-bit 计数器 MSB = taken
                  ipctrl 决策：taken → ipctrl_pcgen_chgflw_pcload=1
                  同拍投机更新 VGHR（左移，追加 taken）

周期 N+2 (PCGEN 同拍)：if_pc ← BTB target（chgflw 优先于顺序推进）
                       从目标地址重新取指

→ 若预测正确：流水线无气泡继续
→ 若后续 BJU 发现预测错：见第 7 节纠错
```

L0 BTB 命中时更快：PCGEN 当拍就改流，省掉 N+1、N+2 的等待。

---

## 7. 预测检查与纠错（BJU 三级流水）

分支指令最终在 **IU 的 BJU 单元**（`ct_iu_bju.v`，对应 pipe2）真正执行并检查预测。
BJU 有三个执行级，分工明确：

```
EX1：执行 + 检查（算真实方向/目标，与预测比对，生成 chgflw）
EX2：写回 + 反馈（结果写回 PCFIFO，反馈 IFU 更新 BHT，发 complete bus，发 chgflw 给 IFU）
EX3：PCFIFO bypass（处理 PCFIFO 读写同拍冲突的旁路）
```

### 7.0 PCFIFO：预测元数据的生命周期载体（关键前置）

要理解 BJU 怎么"检查"预测，必须先理解 **PCFIFO**（`ct_iu_bju_pcfifo.v`，3323 行）。
它是一个按 **PID**（PCFIFO entry 指针）索引的队列，保存每条分支的预测元数据，
贯穿四个单元：

```
IFU（取指）── create ──▶ PCFIFO ── assign PID ──▶ 随指令流到 IDU dispatch
                          │                              │（指令带着 PID 走）
RTU（退休）◀── pop ───────┤                              ▼
                          └──────── read ◀──────── BJU（EX1 用 PID 读回比对）
```

**每个 entry 的核心数据**（`ct_iu_bju_pcfifo.v:1868-1926`，67 位）：
```
[39:0]  pc       —— 对 jalr 存"预测目标 - offset"，其他存 cur_pc（巧妙复用，见下）
[40]    bht_pred —— IFU 当初的方向预测
[41]    jmp_mispred —— IFU 已标记的间接跳转误预测
[66:42] chk_idx[24:0] —— BHT / Indirect BTB 的检查索引（更新预测器时定位表项）
```

**生命周期四步**：
1. **Create**（IFU 取指时，`ifu_iu_pcfifo_create0/1_*`）：把预测信息写入 PCFIFO，一拍最多 2 条。
2. **Assign PID**（`:2055`）：分配 PID，随指令经 IDU dispatch（`iu_idu_pcfifo_dis_inst0~3_pid`）。
   指令此后一直带着 PID，执行时凭 PID 找回自己的预测元数据。
3. **Read**（BJU EX1）：BJU 凭 PID 读出 `pcfifo_bju_pc / bht_pred / chk_idx / jmp_mispred`，与实际算出的比对。
4. **Pop**（RTU 退休，`iu_rtu_pcfifo_pop0/1/2_data`）：弹出给 RTU，用于退休时更新 GHR/RAS/Ind-BTB 与 flush 恢复。

> **jalr 的巧妙比较**（`:740` 注释）：PCFIFO 对 jalr 存的 pc 是"预测目标 − offset"。
> 而 jalr 实际目标 = src0(基址) + offset。所以 `预测pc == src0` ⟺ 预测正确——
> BJU 只需比较 `ex1_pipe2_pc`（PCFIFO 读出）和 `src0`，省去一次加法，正是 7.2 的 `bju_tarpc_cmp_fail`。

### 7.1 方向检查（BHT Check，EX1）
```verilog
// ct_iu_bju.v:732
assign bju_bht_mispred = bju_inst_condbr && (condbr_taken ^ ex1_pipe2_bht_pred)
                       || (condbr || uncondbr) && bju_br_page_fault;
```
- `condbr_taken`：BJU 实际算出的方向（比较 src0/src1，见 :635-661）
- `ex1_pipe2_bht_pred`：IFU 当初的方向预测（随指令流水带下来）
- 二者异或 → 方向预测错。
- 目标地址非法（msb 非全 0/全 1）也算 mispred（页错误）。

### 7.2 目标检查（间接跳转 / RAS Check）
```verilog
// ct_iu_bju.v:742
assign bju_tarpc_cmp_fail = (ex1_pipe2_pc[39:0] != ex1_pipe2_src0[39:0]);
// :744
assign bju_jmp_mispred = bju_inst_jump && bju_tarpc_cmp_fail
                       || bju_inst_jump && !ex1_pipe2_rts && ex1_pipe2_jmp_mispred
                       || bju_inst_jump && bju_jump_page_fault;
```
- BJU 用 PCFIFO 保存 IFU 的预测 PC，jalr 的预测 PC 减 offset 后应等于实际 src0；
  不等 → 目标预测错。
- `ex1_pipe2_rts` 标记是否 ret（RAS 预测）。

### 7.3 IID 年龄比较（关键正确性保证）
```verilog
// ct_iu_bju.v:752
assign bju_older_inst_vld = ex1_pipe2_inst_vld && ex1_pipe2_iid_oldest;
assign bju_chgflw_vld = bju_mispred && !rtu_iu_flush_chgflw_mask && bju_older_inst_vld;
```
- 乱序执行下可能有多条分支在飞，只有**最老的（程序序最早）误预测分支**才有资格纠错。
- 用 IID（7 位，对应 128 项 ROB）做年龄比较，时序上把比较提前到 RF 级（:479）。
- 这避免了一条更年轻的误预测分支错误地冲刷了它前面本应正确执行的指令。

### 7.4 纠错动作
```
bju_chgflw_vld=1 →
  iu_ifu_chgflw_vld + iu_ifu_chgflw_pc  → IFU 重定向取指（pcgen 优先级 4）
  iu_idu_mispred_stall / iu_ifu_mispred_stall → 暂停前端，等错误路径排空
  同时把真实方向/目标反馈给 IFU 更新预测器（见第 8 节）
```

**两个 mispred_stall 的微妙差异**（`ct_iu_bju.v:798`、:822）——都由 `bju_chgflw_vld` 置位，但清除条件不同：
- `iu_idu_mispred_stall`：只被 `rtu_yy_xx_flush`（误预测分支真正退休）清除。
  IDU 必须一直 stall，直到误预测指令退休，避免错误路径的新指令进入后端。同时锁存
  `mispred_iid`，供 RTU 做年龄比较。
- `iu_ifu_mispred_stall`：被 `rtu_yy_xx_flush` **或** `rtu_iu_flush_fe`（前端冲刷）提前清除。
  因为前端冲刷后已无错误路径的 RAS/JMP 指令在飞，IFU 可以提前恢复取指——但此时 IDU
  仍需 stall。这个"IFU 早放、IDU 晚放"的拆分（:828 注释）让取指尽早重启、减少气泡，
  同时保证后端不被污染。其作用是阻止 IFU 在 PATH/RAS 恢复完成前取新的 RAS/JMP 指令（:821）。

误预测代价：冲刷 IFU+IDU 前端（约 5~ 拍气泡）。这正是要把预测做准的原因。

### 7.5 EX2/EX3：写回、反馈与 bypass

EX1 检查完，结果在 **EX2** 落地（`ct_iu_bju.v:971-1019`）：

**① 写回 PCFIFO**（供退休用）：把真实执行结果写回该分支的 PCFIFO entry：
```verilog
bju_pcfifo_ex2_bht_mispred / _jmp / _pret / _pcall / _condbr
bju_pcfifo_ex2_pc = {真实目标, 1'b0}   // 真实目标覆盖预测
bju_pcfifo_ex2_bht_pred              // 保留当初预测，供 Bi-Mode 更新对比
```
退休时 RTU pop 出的就是这份"含真实结果"的数据，据此更新预测器。

**② 反馈 IFU 更新 BHT**（`:1008-1019`）：
```verilog
iu_ifu_chgflw_vld / iu_ifu_chgflw_pc[62:0]  // 重定向（含高 24 位 msb）
iu_ifu_bht_check_vld    = ex2_pipe2_conbr_vld    // 这是需更新 BHT 的条件分支
iu_ifu_bht_condbr_taken = ex2_pipe2_conbr_taken  // 真实方向
iu_ifu_bht_pred         = ex2_pipe2_bht_pred     // 当初预测（Bi-Mode 更新要用）
iu_ifu_chk_idx[24:0]    = ex2_pipe2_chk_idx      // 定位 BHT/Ind-BTB 表项
```

**③ Complete Bus + Cancel**（`:989-1003`）：经 complete bus 上报 iid/mispred 给 RTU；
`iu_yy_xx_cancel = ex2_pipe2_chgflw_vld` 取消错误路径。

**EX3**（`:1022`）：处理 PCFIFO 的读写同拍冲突——当某 entry 正被 EX2 写、又同时被退休读时，
EX3 做 bypass，保证 RTU 读到最新结果，避免 RAW 冒险。

---

## 8. 预测器更新闭环

预测器在**三个时间点**更新，精度逐点提高：

### 8.1 投机更新（IP 级，最早）
- **VGHR**：IP 级每检测到条件分支，立即把预测方向左移进 VGHR（投机，可能错）。
- **BTB Refill Buffer**：BTB miss 时缓存目标，2 拍后补全 way_pred 再写入 BTB。

### 8.2 执行反馈（BJU EX2，较准）
BJU 在 EX2 算出真实方向/目标后反馈给 IFU 更新 BHT（信号见 7.5 ②）。
BHT 收到后，决定是否经 Write Buffer 更新两张表。更新遵循两条规则（`ct_ifu_bht.v:932-954`）：

**① Predict Array（2-bit 饱和计数器）—— 饱和则跳过**
```verilog
pred_array_check_updt_vld = !( (bju_pred_rst==2'b00 && !taken)   // 已饱和"强不跳"且确实没跳
                            || (bju_pred_rst==2'b11 &&  taken) ) // 已饱和"强跳"且确实跳了
```
即：计数器已经在饱和端、且这次结果与之一致 → 无需写（省一次 SRAM 写、省功耗）；
否则朝实际方向调整计数器（taken 则 +1、not-taken 则 −1，饱和钳位）。

**② Select Array（Bi-Mode 选择表）—— 饱和跳过 + 双模特例**
```verilog
sel_array_check_updt_vld = !( (bju_sel_rst==2'b00 && !taken)        // 饱和一致，跳过
                           || (bju_sel_rst==2'b11 &&  taken)        // 饱和一致，跳过
                           || (bju_sel_rst[1]==0 && taken  && !chgflw) // 双模特例
                           || (bju_sel_rst[1]==1 && !taken && !chgflw) ) // 双模特例
```
后两条是 Bi-Mode 的精髓：选择表 MSB 决定用 Taken 表还是 NotTaken 表。
当选择表当前指向某张表、而该表**预测正确（未 chgflw）**时，即便方向与选择表的偏置不完全一致，
也**不去拉动选择表**——避免"正确预测的偏置分支"反复抖动选择表，把别名冲突保持为良性。
只有预测错误（chgflw）时才允许选择表朝实际方向调整。

> Write Buffer 的作用（详见 `ifu/04_bht.md`）：SRAM 同周期不能边读边写，更新先入 4 项写缓冲，
> 趁无读操作的空隙回写；若读地址命中写缓冲则直接旁路最新值。

### 8.3 退休更新（RTU，最准）
- **RTUGHR**：RTU 按程序序退休条件分支，把确定的真实方向推入 RTUGHR（每拍最多 3 条）。
- **Indirect BTB**：`rtu_ifu_retire0_jmp_mispred` 在退休确认间接跳转误预测时，
  用真实目标更新其 SRAM（`ct_ifu_ind_btb.v:207`）；退休侧 `rtu_path_reg` 同步移位推进，
  并在 `rtu_ifu_retire0_mispred || rtu_ifu_flush` 时把投机 `path_reg` 恢复回退休侧（:254、:522）。
- RAS 的 RTU 侧 6 项也在退休时维护，用于恢复 IFU 侧投机栈。

---

## 9. 双 GHR 机制与恢复

BHT 维护两套 22 位全局历史寄存器（GHR）：

```
VGHR（虚拟/投机）          RTUGHR（退休/精确）
─────────────────          ──────────────────
IP 级每预测一条分支         RTU 每退休一条分支
就左移追加预测方向          就左移追加真实方向
（快，但可能含错误路径）    （慢，但绝对正确）
        │                          │
        │   预测出错时             │
        └──────◀───────────────────┘
         VGHR ← RTUGHR（用精确值恢复投机值）
```

VGHR 用于取指时索引 BHT（要快）；预测错或 flush 时，VGHR 从 RTUGHR 恢复到正确历史，
保证后续预测基于正确的分支历史。这是"用精度换吞吐、出错时再校正"的典型设计。

VGHR 更新优先级（`ct_ifu_bht.v:653`）：
```
RTU flush     → vghr = rtughr        （最高，精确恢复）
IU chgflw     → vghr = bju_ghr       （执行纠错后的历史）
lbuf con_br   → vghr 左移（循环缓冲分支）
IP con_br     → vghr 左移（正常投机）
```

### 9.1 贯穿全局的"投机/退休双轨"模式（重要总纲）

C910 所有**带历史状态**的预测结构都遵循同一范式——这是理解整个分支预测的总钥匙：

| 预测结构 | 投机侧（取指时快速更新，可能被错误路径污染） | 退休侧（按程序序精确更新） | flush/误预测时恢复 |
|----------|------------------------------|------------------------|-------------------|
| BHT 方向历史 | VGHR | RTUGHR | VGHR ← RTUGHR |
| Indirect BTB 路径 | path_reg | rtu_path_reg | path_reg ← rtu_path_reg |
| RAS 返回栈 | IFU 12 项投机栈 | RTU 6 项退休栈 | IFU 栈 ← RTU 栈 |

**为什么都这样设计？** 投机侧要快（取指当拍就更新，跟得上预测节奏），代价是会被错误路径写脏；
退休侧慢但绝对正确（只在指令按序退休时更新）。平时用投机侧预测，一旦预测错/flush，
就用退休侧把投机侧"擦回"正确状态。**这是用一致的范式同时拿到速度和正确性**——
记住这条主线，三个结构的恢复逻辑就都通了。

而 BTB / L0 BTB / PCFIFO 不是"历史累积"型（它们是 PC 关联的目标记忆 / 元数据队列），
所以不需要双轨，而是各自用 Refill Buffer 延迟写、IID 年龄比较等机制保证正确性。

---

## 10. flush 与状态恢复

误预测/异常触发的冲刷与恢复链：

```
BJU 检测最老误预测（EX1）
   │
   ├─ iu_ifu_chgflw → IFU 重定向到正确 PC
   ├─ iu_idu_mispred_stall → 暂停 IDU 前端
   │
   └─ 错误路径指令继续流到 RTU
         │
RTU 退休到误预测分支
   │
   ├─ rtu_ifu_flush → 冲刷 IFU 错误路径
   ├─ VGHR ← RTUGHR（BHT 历史恢复）
   ├─ Indirect BTB PATH 寄存器恢复
   ├─ RAS IFU 侧 ← RTU 侧恢复
   └─ 重命名表（IDU）恢复到正确映射
```

**两阶段冲刷**：BJU EX1 先做"轻量"重定向（让 IFU 尽快从正确地址取指），
RTU 退休时做"重量"恢复（精确恢复所有预测器状态）。
中间用 `mispred_stall` 锁住前端，并阻止 IFU 取 RAS/JMP 指令直到误预测分支退休
（`ct_iu_bju.v:821`），避免在未恢复状态下污染 RAS/Indirect BTB。

---

## 11. 完整闭环全景图

```
┌─────────────────────────────────────────────────────────────────────┐
│                          IFU（预测）                                  │
│                                                                       │
│  PCGEN ──[L0 BTB 零延迟]──┐                                          │
│    │                       │                                          │
│    ├─index→ BTB ──────────▶│                                          │
│    ├─index→ BHT-sel ──────▶│ IP 级综合决策：                         │
│    │                        │  • BTB target（直接/条件目标）          │
│    │   IP级: BHT-pred ─────▶│  • BHT 方向（条件分支）                 │
│    │         RAS 栈顶 ─────▶│  • RAS（ret 目标）                      │
│    │         Ind-BTB ──────▶│  • Ind-BTB（jalr 目标）                 │
│    │                        ▼                                         │
│    └────◀── chgflw ── 预测 taken → 重定向取指                         │
│         投机更新 VGHR / BTB-refill-buf                                │
└───────────────────────────────┬───────────────────────────────────┘
                                 │ 指令流（带预测信息）
                                 ▼
                         IDU（biq 分支队列）→ 发射到 pipe2
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      IU / BJU（EX1 检查纠错）                         │
│  • 算真实方向（condbr_taken）与目标                                   │
│  • 比对预测：bht_mispred / jmp_mispred                                │
│  • IID 年龄比较：仅最老误预测纠错                                     │
│  • bju_chgflw → iu_ifu_chgflw（重定向）                              │
│  • iu_ifu_bht_* → 反馈更新 BHT                                        │
└───────────────────────────────┬───────────────────────────────────┘
                                 │ 指令继续流向退休
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        RTU（退休/精确更新）                           │
│  • 按序退休，更新 RTUGHR（精确历史）                                  │
│  • rtu_ind_btb_mispred → 更新 Indirect BTB                            │
│  • rtu_ifu_flush → 冲刷 + VGHR←RTUGHR + RAS/PATH 恢复                 │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 关键要点速查

| 主题 | 结论 |
|------|------|
| 方向预测 | BHT（Bi-Mode），IP 级出结果 |
| 目标预测 | L0 BTB（0 拍）/ BTB（2 拍）/ Ind-BTB（jalr）/ RAS（ret） |
| 预测发生级 | PCGEN（L0 BTB）→ IF（读）→ IP（决策出 chgflw） |
| 检查发生级 | IU/BJU 的 EX1（pipe2） |
| 纠错正确性 | IID 年龄比较，仅最老误预测可改流 |
| 预测更新三时点 | IP 投机 → BJU 执行反馈 → RTU 退休精确 |
| 历史寄存器 | VGHR（投机，索引用）/ RTUGHR（精确，恢复用） |
| 误预测代价 | 冲刷前端约 5+ 拍气泡 |
| 状态恢复 | BJU 轻量重定向 + RTU 重量恢复（两阶段） |

---

*相关模块文档*：
`ifu/01_pcgen.md` · `ifu/02_l0_btb.md` · `ifu/03_btb.md` · `ifu/04_bht.md` ·
`ifu/05_ras.md` · `ifu/10_ipctrl.md` · `ifu/11_ipdp.md` · `idu/14_is_biq.md`
（BJU 详见 IU 单元，RAS/Ind-BTB 退休恢复详见 RTU 单元）

*文档版本：基于 OpenC910 开源代码（Apache-2.0）*

---

## 12. Verdi 观察指南

> **层次前缀约定**（以下表格中用 `IFU_TOP` / `BJU` 代替完整路径）：
>
> ```
> IFU_TOP = tb.x_soc.x_cpu_sub_system_axi.x_rv_integration_platform
>           .x_cpu_top.x_ct_top_0.x_ct_core.x_ct_ifu_top
>
> BJU     = tb.x_soc.x_cpu_sub_system_axi.x_rv_integration_platform
>           .x_cpu_top.x_ct_top_0.x_ct_core.x_ct_iu_top.x_ct_iu_bju
> ```
>
> 在 Verdi 信号浏览器中展开上述路径，可直接拖拽信号到波形窗口。

---

### 12.1 BHT（方向预测）关键信号

**模块路径**：`IFU_TOP.x_ct_ifu_bht`

| 信号名 | 位宽 | 流水级 | 功能说明 |
|--------|------|--------|---------|
| `vghr_reg` | [21:0] | IP 持续 | **投机全局历史寄存器**。每预测一条条件分支就左移追加预测方向（bit0=最新）。错误路径下会被污染，flush 后从 `rtughr_reg` 恢复。高位是最旧历史，低位是最新。 |
| `rtughr_reg` | [21:0] | RTU 持续 | **退休全局历史寄存器**。只在 RTU 按程序序退休条件分支时更新，始终保存精确历史。误预测时用它恢复 `vghr_reg`。 |
| `bht_ipdp_vghr` | [21:0] | IP | 送给 ipdp 的当前 VGHR 值，用于 IP 级计算 Predict Array 读索引。 |
| `bht_ipdp_sel_array_result` | [1:0] | IP | Select Array 的 2-bit 选择计数器。bit[1]=1 选 Taken 表，=0 选 Not-Taken 表；bit[0] 是选择计数器的低位，不是最终方向。最终方向来自所选 Predict Array 计数器的 MSB。 |
| `bht_ipdp_pre_array_data_taken` | [31:0] | IP | Taken 表读出的 16 个 2-bit 计数器打包值。 |
| `bht_ipdp_pre_array_data_ntake` | [31:0] | IP | Not-Taken 表读出的数据，同上。 |
| `bht_ipdp_pre_offset_onehot` | [15:0] | IP | 内部 PC `[6:3]`（字节 PC `[7:4]`）与 GHR 低位哈希后的 one-hot 编号，用于从 16 个 2-bit 计数器中选择一路。 |
| `bht_ind_btb_vghr` | [7:0] | IP | 送给 Indirect BTB 的 VGHR 低 8 位，用于计算间接跳转读索引（折叠异或）。 |
| `bht_ind_btb_rtu_ghr` | [7:0] | RTU | 送给 Indirect BTB 的 RTUGHR 低 8 位，用于计算间接跳转写索引。 |

**行为说明**：
- 观察 `vghr_reg` 与 `rtughr_reg` 之差：正常预测期间两者相差 0~几位（投机超前）；误预测后立即看到 `vghr_reg` 跳变（ `← rtughr_reg`）。
- `bht_ipdp_sel_array_result[1]` 每次 IP 级有分支就更新，0→1 或 1→0 表示同一 PC 的预测在两张表之间切换（Bi-Mode 行为）。

---

### 12.2 L0 BTB（零延迟目标预测）关键信号

**模块路径**：`IFU_TOP.x_ct_ifu_l0_btb`

| 信号名 | 位宽 | 流水级 | 功能说明 |
|--------|------|--------|---------|
| `l0_btb_ifdp_hit` | 1 | PCGEN | **L0 BTB 命中标志**。=1 表示当前 PC 在 16 项 L0 BTB 中命中，下一拍直接用 L0 BTB 目标取指，无需等 BTB。 |
| `l0_btb_ifdp_entry_hit` | [15:0] | PCGEN | 16 项 entry 各自的命中 one-hot 向量。哪一位为 1 表示哪个 entry 命中，可用来追踪是哪条热点分支在驱动 L0 BTB。 |
| `l0_btb_ifctrl_chglfw_vld` | 1 | PCGEN | L0 BTB 触发改流有效。=1 且 hit=1 时，IF 级接受 L0 BTB 提供的目标。 |
| `l0_btb_ifctrl_chgflw_pc` | [38:0] | PCGEN | L0 BTB 提供的半字地址目标；完整字节 PC 为 `{signal,1'b0}`。 |
| `l0_btb_ifctrl_chgflw_way_pred` | [1:0] | PCGEN | 对应 BTB 的 way_pred，传递给 BTB 做 way 预测更新。 |
| `entry0_vld` ~ `entry15_vld` | 1×16 | — | 每个 entry 的有效位。冷启动时全 0，热点分支 addrgen 更新后置 1。 |
| `entry0_tag` ~ `entry15_tag` | [14:0]×16 | — | 各 entry 存储内部 PC `[14:0]`，对应架构字节 PC `[15:1]`，用于命中比对。 |
| `entry0_target` ~ `entry15_target` | [19:0]×16 | — | 各 entry 存储内部目标 `[19:0]`，对应字节 PC `[20:1]`；高位沿用当前内部 PC `[38:20]`，不是符号扩展。 |
| `l0_btb_update_vld_bit` | 1 | IB+1 | addrgen 触发 L0 BTB 更新有效脉冲。 |

**行为说明**：
- 对比 `l0_btb_ifdp_hit` 与 `ipctrl_ibctrl_l0_btb_miss`：hit 说明提前改流成功，miss 说明该分支还未入 L0 BTB（首次或被替换），将走 BTB 路径，多花 1 拍。
- 观察 `entry_hit` 的 one-hot 分布可知哪几条分支被 L0 BTB 覆盖（热点）。

---

### 12.3 BTB（主目标预测）关键信号

**模块路径**：`IFU_TOP.x_ct_ifu_btb`

| 信号名 | 位宽 | 流水级 | 功能说明 |
|--------|------|--------|---------|
| `btb_ifdp_way0_vld` ~ `way3_vld` | 1×4 | IF→IP | 4 路各自的有效位，读出后在 IP 做 tag 比较。 |
| `btb_ifdp_way0_target` ~ `way3_target` | [19:0]×4 | IF→IP | 4 路各自的内部目标 `[19:0]`，对应字节 PC `[20:1]`。 |
| `btb_ifdp_way0_pred` ~ `way3_pred` | [1:0]×4 | IF→IP | 4 路的 way_pred（2 位 LRU/PLRU 替换预测），用于下次命中时直接选路。 |
| `refill_buf_target_pc` | [19:0] | — | **Refill Buffer**：BTB miss 时暂存目标，等 2 拍 way_pred 确定后才真正写入 SRAM。 |
| `refill_buf_way_pred` | [1:0] | — | Refill Buffer 中等待写入的 way_pred。 |
| `after_addrgen_btb_chgflw_first` | 1 | IB+1 | addrgen 第 1 周期更新 BTB 触发的改流标志。 |
| `after_addrgen_btb_chgflw_second` | 1 | IB+2 | addrgen 第 2 周期（写 way_pred 补全）触发的改流。 |
| `btb_target_pc_record` | [19:0] | — | 暂存上一次 BTB target，用于 addrgen 写时比对是否仍需更新。 |

**行为说明**：
- 4 路 `vld/target/pred` 同时出现：用 `ipctrl_btb_way_pred` 看 IP 级最终选了哪路（即命中路的 way_pred）。
- `refill_buf_target_pc` 非零时说明有 BTB miss 正在等待补全写入，此时若同一分支再次到来会从 refill buffer bypass。

---

### 12.4 RAS（返回地址栈）关键信号

**模块路径**：`IFU_TOP.x_ct_ifu_ras`

| 信号名 | 位宽 | 流水级 | 功能说明 |
|--------|------|--------|---------|
| `top_ptr` | [4:0] | IB 持续 | **IFU 投机栈栈顶指针**。低 4 位是栈顶 index（0~11），bit[4] 是圈数奇偶标志（用于区分空/满，因为 12 非 2 的幂）。call 时 +1（环绕于 12），ret 时 -1。 |
| `rtu_ptr` | [4:0] | RTU | **RTU 退休栈栈顶指针**（6 项），与投机栈对称。误预测/flush 后投机栈从这里恢复。 |
| `status_ptr` | [4:0] | IB | 投机栈 status 指针，用于追踪"当前最新压栈后的指针"（区别于 top_ptr 在 pop 之后的值）。 |
| `ibctrl_ras_pcall_vld` | 1 | IB | **call 压栈有效**。=1 表示 IB 级识别到 call 指令（JAL/JALR rd=ra），触发 RAS push。 |
| `ibctrl_ras_preturn_vld` | 1 | IB | **ret 弹栈有效**。=1 表示 IB 级识别到 ret（JALR x0,ra,0），触发 RAS pop，用栈顶值作预测目标。 |
| `ras_ipdp_data_vld` | 1 | IP | RAS 在 IP 级提供的目标有效。=1 表示当前 IP 处理的是 ret 且 RAS 非空，目标有效。 |
| `ras_l0_btb_push_pc` | [38:0] | IB | push 时写入 RAS 的半字地址返回 PC；与反汇编比较时补最低零位。 |
| `ras_l0_btb_ras_push` | 1 | IB | push 触发信号，与 `ibctrl_ras_pcall_vld` 同步。 |

**行为说明**：
- 跟踪函数调用时：每次看到 `ibctrl_ras_pcall_vld=1`，`top_ptr` 应 +1（环绕）；`ibctrl_ras_preturn_vld=1` 时 -1。
- 若 `top_ptr` 和 `rtu_ptr` 偏差超过几项，说明有大量投机 call/ret 还未退休。
- flush 后观察 `top_ptr ← rtu_ptr` 的恢复动作（通常 1 拍内完成）。

---

### 12.5 Indirect BTB（间接跳转预测）关键信号

**模块路径**：`IFU_TOP.x_ct_ifu_ind_btb`

| 信号名 | 位宽 | 流水级 | 功能说明 |
|--------|------|--------|---------|
| `path_reg_0` ~ `path_reg_3` | [7:0]×4 | IB 持续 | **投机路径历史寄存器**（共 32 位有效历史）。每检测到一条间接跳转，`path_reg_0 ← ibctrl_ind_btb_path`，其余依次右移。用于计算 Indirect BTB 读索引。 |
| `rtu_path_reg_0` ~ `rtu_path_reg_3` | [7:0]×4 | RTU | **退休路径历史寄存器**。RTU 按序退休间接跳转时移位更新。误预测/flush 时投机 `path_reg ← rtu_path_reg`（与 BHT 的 VGHR ← RTUGHR 完全对称）。 |
| `ind_btb_rd_index` | [7:0] | IP | Indirect BTB **读索引**（8 位）：`path_reg[3:0]` 各取 2 位与 `vghr[7:0]` 对应位异或折叠。决定从哪个 SRAM 行读预测目标。 |
| `ind_btb_wr_index` | [7:0] | RTU | Indirect BTB **写索引**：用 `rtu_path_reg` 与 `rtu_ghr` 同样折叠，退休更新时写入真实目标。 |
| `ibctrl_ind_btb_check_vld` | 1 | IB | IB 级检测到间接跳转，触发 `path_reg` 投机更新的有效脉冲。 |
| `ibctrl_ind_btb_path` | [7:0] | IB | 本条间接跳转贡献给 path_reg 的 8 位 hash 值（通常是 PC 的部分位）。 |
| `ipctrl_ind_btb_con_br_vld` | 1 | IP | IP 级检测到间接跳转（JMP 指令），触发 SRAM 读的有效信号。 |

**行为说明**：
- `path_reg_0` 存最新一条间接跳转的历史，`path_reg_3` 存最旧。观察多条 JALR 连续执行时，`path_reg` 整体移位变化。
- `rd_index` 与 `wr_index` 一致时，说明当前路径上下文与训练时完全一致，命中概率最高。
- `rtu_path_reg` 和 `path_reg` 偏差增大时说明有较多投机间接跳转在飞（未退休）。

---

### 12.6 IP 级预测决策关键信号

**模块路径**：`IFU_TOP.x_ct_ifu_ipctrl`

| 信号名 | 位宽 | 流水级 | 功能说明 |
|--------|------|--------|---------|
| `ipctrl_pcgen_chgflw_pcload` | 1 | IP | **IP 级改流触发**。=1 表示 IP 级综合各预测器决策为"预测 taken"，通知 PCGEN 立即改流到 `ipctrl_pcgen_chgflw_pc`。这是分支预测改变取指流向的核心信号。 |
| `ipctrl_pcgen_chgflw_pc` | [38:0] | IP | IP 级给出的半字地址预测目标（来自 BTB/RAS/Ind-BTB 之一）。 |
| `ipctrl_pcgen_branch_taken` | 1 | IP | BHT 预测该条件分支为 taken（方向预测结果）。 |
| `ipctrl_pcgen_branch_mistaken` | 1 | IP | BTB 预测的目标与 addrgen 算出的真实目标不匹配（BTB target 错误），触发目标纠正。 |
| `ipctrl_bht_con_br_vld` | 1 | IP | 通知 BHT "IP 级有条件分支"，触发 BHT 投机更新 VGHR。 |
| `ipctrl_bht_con_br_taken` | 1 | IP | 告诉 BHT 本次条件分支的预测方向（taken/not-taken），BHT 据此左移 VGHR。 |
| `ipctrl_btb_chgflw_vld` | 1 | IP | BTB 命中且改流有效。 |
| `ipctrl_btb_way_pred` | [1:0] | IP | IP 级最终命中的 BTB way（经 tag 比较后确认）。 |
| `ipctrl_btb_way_pred_error` | 1 | IP | BTB way_pred 预测错误（命中但选路错误），需要更新 way_pred。 |
| `ipctrl_ibctrl_l0_btb_hit` | 1 | IP | 本条分支已被 L0 BTB 处理（命中）的标志，IP 级看到时无需再触发改流。 |
| `ipctrl_ibctrl_l0_btb_miss` | 1 | IP | 分支在 L0 BTB 中 miss，将在 IB+1 的 addrgen 后更新 L0 BTB。 |
| `ipctrl_ipdp_chgflw_pc` | [38:0] | IP | 半字地址改流 PC（同 `ipctrl_pcgen_chgflw_pc`，送给 ipdp 做记录）。 |

**行为说明**：
- `ipctrl_pcgen_chgflw_pcload=1` 是最重要的"预测生效"信号：每次拉高说明 IP 级发出了一次跳转预测，IFU 从下一拍开始从目标地址取指。
- `ipctrl_bht_con_br_vld` 拉高同拍观察 `vghr_reg`（BHT 模块内），可以看到 GHR 左移追加新方向。
- `ipctrl_btb_way_pred_error=1` 说明 BTB 命中但选错了 way，此时 addrgen 会用真实目标更新。

---

### 12.7 BJU 预测检查关键信号

**模块路径**：`BJU`（即 `IFU_TOP` 路径前缀中将 `x_ct_ifu_top` 替换为 `x_ct_iu_top.x_ct_iu_bju`）

| 信号名 | 位宽 | 流水级 | 功能说明 |
|--------|------|--------|---------|
| `bju_bht_mispred` | 1 | EX1 | **BHT 方向预测失败**。条件分支实际方向 `condbr_taken` 与 PCFIFO 中保存的 `bht_pred` 异或为 1。这是最常见的误预测。 |
| `bju_jmp_mispred` | 1 | EX1 | **间接跳转目标预测失败**。实际 `src0 ≠ PCFIFO.pc`（jalr 预测目标与寄存器值不符）。 |
| `bju_tarpc_cmp_fail` | 1 | EX1 | 目标 PC 比较失败原始信号（`ex1_pipe2_pc != ex1_pipe2_src0`）。`bju_jmp_mispred` 由此派生。 |
| `ex1_pipe2_iid_oldest` | 1 | EX1 | **IID 年龄最老标志**。=1 表示 pipe2 当前执行的分支是 ROB 中程序序最老的，才有资格触发纠错改流。乱序下保证正确性的关键。 |
| `iu_ifu_chgflw_vld` | 1 | EX2 | **BJU 纠错改流有效**。=1 说明误预测确认，IFU 收到后立即从 `iu_ifu_chgflw_pc` 重新取指。 |
| `iu_ifu_chgflw_pc` | [62:0] | EX2 | BJU 给出的架构目标 VA `[63:1]`；完整 64 位字节地址为 `{signal,1'b0}`。 |
| `iu_idu_mispred_stall` | 1 | EX1→清 | **IDU 误预测 stall**。误预测时拉高，直到 RTU 退休该分支（`rtu_yy_xx_flush`）才清除。期间 IDU 不接受新指令分发，防止错误路径污染后端。 |
| `iu_ifu_mispred_stall` | 1 | EX1→清 | **IFU 误预测 stall**。与上类似但可被 `rtu_iu_flush_fe` 提前清除，让取指更早重启。 |
| `bju_top_mispred_iid` | [6:0] | EX1 | 锁存的误预测分支 IID（ROB 入口号），供 RTU 做年龄比较（只 flush 该 IID 及以后的指令）。 |
| `ex2_pipe2_bht_mispred` | 1 | EX2 | EX2 级寄存的 BHT 方向误预测结果（EX1 打拍）。写回 PCFIFO 和 complete bus 的值。 |
| `ex2_pipe2_jmp_mispred` | 1 | EX2 | EX2 级寄存的 JMP 目标误预测结果。 |
| `ex2_pipe2_chgflw_vld` | 1 | EX2 | EX2 级的改流有效（综合 bht+jmp+page_fault），驱动 `iu_ifu_chgflw_vld` 输出。 |
| `iu_ifu_bht_check_vld` | 1 | EX2 | 通知 IFU/BHT 更新：本条条件分支已执行完毕，请用真实方向 `iu_ifu_bht_condbr_taken` 更新 BHT 计数器。 |
| `iu_ifu_bht_condbr_taken` | 1 | EX2 | 真实分支方向（taken=1），BHT 更新计数器的依据。 |

**行为说明**：
- 观察误预测全链路：`bju_bht_mispred=1`（EX1）→ 下一拍 `ex2_pipe2_bht_mispred=1`（EX2）→ `iu_ifu_chgflw_vld=1` + `iu_idu_mispred_stall=1`（EX2）→ 几拍后 RTU flush → `iu_idu_mispred_stall` 清零 → `vghr_reg ← rtughr_reg`。
- `ex1_pipe2_iid_oldest=0` 时即使 `bju_bht_mispred=1` 也不会触发改流（被更老的误预测抑制），观察这种情况可以理解乱序下的年龄仲裁。
- `iu_ifu_mispred_stall` 比 `iu_idu_mispred_stall` 先清零可以在波形中直接看到，对应"IFU 提前恢复取指但 IDU 仍 stall"的两阶段设计。

---

### 12.8 推荐 Verdi 观察分组

观察分支预测时建议按以下分组在波形窗口中建立书签：

#### 组 1：预测发出（IP 级）
```
IFU_TOP.x_ct_ifu_ipctrl.ipctrl_pcgen_chgflw_pcload
IFU_TOP.x_ct_ifu_ipctrl.ipctrl_pcgen_chgflw_pc[38:0]
IFU_TOP.x_ct_ifu_ipctrl.ipctrl_pcgen_branch_taken
IFU_TOP.x_ct_ifu_l0_btb.l0_btb_ifdp_hit
IFU_TOP.x_ct_ifu_btb.btb_ifdp_way0_vld  （及 way1/2/3）
IFU_TOP.x_ct_ifu_bht.bht_ipdp_sel_array_result[1:0]
IFU_TOP.x_ct_ifu_bht.vghr_reg[21:0]
```

#### 组 2：BHT 历史（GHR 投机/退休对比）
```
IFU_TOP.x_ct_ifu_bht.vghr_reg[21:0]
IFU_TOP.x_ct_ifu_bht.rtughr_reg[21:0]
IFU_TOP.x_ct_ifu_bht.bht_ipdp_vghr[21:0]
```

#### 组 3：纠错检查（BJU EX1/EX2）
```
BJU.bju_bht_mispred
BJU.bju_jmp_mispred
BJU.bju_tarpc_cmp_fail
BJU.ex1_pipe2_iid_oldest
BJU.iu_ifu_chgflw_vld
BJU.iu_ifu_chgflw_pc[62:0]
BJU.iu_idu_mispred_stall
BJU.iu_ifu_mispred_stall
```

#### 组 4：RAS 压/弹栈
```
IFU_TOP.x_ct_ifu_ras.top_ptr[4:0]
IFU_TOP.x_ct_ifu_ras.rtu_ptr[4:0]
IFU_TOP.x_ct_ifu_ibctrl.ibctrl_ras_pcall_vld
IFU_TOP.x_ct_ifu_ibctrl.ibctrl_ras_preturn_vld
IFU_TOP.x_ct_ifu_ras.ras_ipdp_data_vld
```

#### 组 5：Indirect BTB 路径历史
```
IFU_TOP.x_ct_ifu_ind_btb.path_reg_0[7:0]
IFU_TOP.x_ct_ifu_ind_btb.path_reg_1[7:0]
IFU_TOP.x_ct_ifu_ind_btb.rtu_path_reg_0[7:0]
IFU_TOP.x_ct_ifu_ind_btb.ind_btb_rd_index[7:0]
IFU_TOP.x_ct_ifu_ind_btb.ibctrl_ind_btb_check_vld
```
