# C910 VFPU vfdsu（SRT 基-16 除法 / 开方）模块详细教学文档

> RTL 目录：`C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/`
> 核心文件：
> - `ct_vfdsu_top.v`（331 行，顶层封装 + set0/set1 切分）
> - `ct_vfdsu_ctrl.v`（520 行，**SRT 状态机 + srt_cnt 计数器 + 写回状态机**——本文重点）
> - `ct_vfdsu_prepare.v`（操作数预处理、特殊数检测、ex1_div/ex1_sqrt 译码）
> - `ct_vfdsu_srt.v`（691 行，SRT 迭代引擎封装、skip/rem_zero 判定、bound_sel 生成）
> - `ct_vfdsu_srt_radix16_only_div.v`（纯除法基-16 引擎）
> - `ct_vfdsu_srt_radix16_with_sqrt.v`（除法+开方基-16 引擎，含 sqrt 二轮）
> - `ct_vfdsu_srt_radix16_bound_table.v`（1168 行，**商位选择边界查找表**）
> - `ct_vfdsu_round.v`（51K，舍入）/ `ct_vfdsu_pack.v`（打包）/ `ct_vfdsu_ff1.v`（find-first-1）
> - `ct_vfdsu_double.v` / `ct_vfdsu_scalar_dp.v`（精度数据通路 + 写回数据）

---

## 目录

- [1. 模块概述](#1-模块概述)
  - [1.1 vfdsu 是什么](#11-vfdsu-是什么)
  - [1.2 为什么除法/开方是变延迟、只放 pipe6](#12-为什么除法开方是变延迟只放-pipe6)
- [2. 端口说明](#2-端口说明)
- [3. 参数与关键寄存器](#3-参数与关键寄存器)
- [4. 两个状态机：SRT 迭代机 + 写回机](#4-两个状态机srt-迭代机--写回机)
- [5. srt_cnt 计数器与 srt_cnt_ini（13 / 6 / 3）](#5-srt_cnt-计数器与-srt_cnt_ini13--6--3)
- [6. 变延迟：skip_srt / rem_zero 提前结束](#6-变延迟skip_srt--rem_zero-提前结束)
- [7. SRT 基-16 迭代：商位选择与 bound_table](#7-srt-基-16-迭代商位选择与-bound_table)
- [8. 开方为何需要二轮 srt_secd_round](#8-开方为何需要二轮-srt_secd_round)
- [9. EX3 round / EX4 pack / 写回握手](#9-ex3-round--ex4-pack--写回握手)
- [10. VLEN128 切分与各运算延迟总表](#10-vlen128-切分与各运算延迟总表)
- [设计取舍小结](#设计取舍小结)
- [覆盖声明](#覆盖声明)

---

## 1. 模块概述

### 1.1 vfdsu 是什么

vfdsu（Vector / Floating-point Divide & SQRt Unit）负责浮点**除法 `fdiv`** 与**开方 `fsqrt`**。它用 **SRT 基-16（radix-16）** 迭代算法，每轮迭代产生 4 位商（或根），是 VFPU 里唯一的**变延迟、不可流水化**单元（一次只服务一条指令）。

vfdsu 在 VFPU 顶层**只实例化一次**（`ct_vfpu_top.v:1675`），且只挂在 pipe6——这是 VFPU 两处不对称之一。

### 1.2 为什么除法/开方是变延迟、只放 pipe6

- **变延迟**：SRT 迭代轮数随精度（double/single/half）不同，且可因被除数特殊、商提前确定、余数为零而提前结束（§6）。所以不像 fadd（恒 3 拍）/FMA（恒 5 拍）那样定长。
- **不可流水**：SRT 是一个反复读写同一组部分余数寄存器的状态机（`srt_cur_state`，`ct_vfdsu_ctrl.v:89`），一次只能跑一条，无法每拍接收新指令。
- **只放 pipe6**：除法/开方低频、面积大（SRT 引擎 + 1168 行 bound_table + round/pack），复制到 pipe7 性价比极低。IDU 把所有 fdiv/fsqrt 统一发往 pipe6，并靠 `vfdsu_dp_fdiv_busy` / `vfdsu_dp_inst_wb_req` 反压（`ct_vfdsu_ctrl.v:508`-`509`），功能上无需 pipe7 也有除法器。详见 `00_vfpu_overview.md` §7。

---

## 2. 端口说明

`ct_vfdsu_top` 端口（`ct_vfdsu_top.v:18`-`48`）分组：

| 分组 | 代表信号 | 方向 | 含义 |
|---|---|---|---|
| 时钟/复位/低功耗 | `forever_cpuclk` `cpurst_b` `cp0_vfpu_icg_en` `cp0_yy_clk_en` `pad_yy_icg_scan_en` `rtu_yy_xx_flush` | in | 含冲刷 |
| 发射/启动 | `dp_vfdsu_ex1_pipex_sel` `dp_vfdsu_idu_fdiv_issue` `dp_vfdsu_fdiv_gateclk_issue` | in | EX1 选中、发射启动、门控启动 |
| 源操作数 | `dp_vfdsu_ex1_pipex_srcf0/1[63:0]` `idu_vfpu_rf_pipex_func[19:0]` `_imm0[2:0]` | in | 被除数/除数（或被开方数）+ 操作码 |
| 目的寄存器/ID | `dp_vfdsu_ex1_pipex_dst_vreg[6:0]` `_dst_ereg[4:0]` `_iid[6:0]` | in | 写回目标与重排序 ID |
| 舍入/QNaN | `vfpu_yy_xx_rm[2:0]` `vfpu_yy_xx_dqnan` | in | 静态舍入、默认 QNaN |
| 写回（变延迟） | `pipex_dp_vfdsu_inst_vld` `pipex_dp_vfdsu_freg_data[63:0]` `_ereg_data[4:0]` `_vreg[6:0]` `_ereg[4:0]` | out | 写回有效 + 结果 + 目标 |
| 反压/状态 | `vfdsu_dp_fdiv_busy` `vfdsu_dp_inst_wb_req` | out | 除法忙、申请写回端口 |
| 调试 | `vfdsu_ifu_debug_idle` `_ex2_wait` `_pipe_busy` | out | 调试态 |

---

## 3. 参数与关键寄存器

| 名称 | 值/宽度 | 出处 | 含义 |
|---|---|---|---|
| `srt_cur_state` / `srt_nxt_state` | 1 bit（SRT_IDLE=0 / SRT_BUSY=1） | `ct_vfdsu_ctrl.v:89`-`90`,`157`-`158` | SRT 迭代机当前/下一态 |
| `srt_cnt` | 5 位 reg | `ct_vfdsu_ctrl.v:88` | 剩余迭代轮数计数器 |
| `srt_cnt_ini` | 5 位 | `ct_vfdsu_ctrl.v:126`,`246`-`248` | 迭代轮数初值（**double=13 / single=6 / half=3**） |
| `div_cur_state` / `div_next_state` | 4 位 | `ct_vfdsu_ctrl.v:84`-`85` | 写回状态机（IDLE/RF/EX1/EX2/WB_REQ/WB） |
| `ex2_srt_first_round` | 1 bit reg | `ct_vfdsu_ctrl.v:86` | SRT 首轮标记 |
| `ex2_srt_secd_round` | 1 bit reg | `ct_vfdsu_ctrl.v:87` | SRT 第二轮标记（开方用） |
| `vfdsu_ex3_vld` / `vfdsu_ex4_vld` | 各 1 bit reg | `ct_vfdsu_ctrl.v:91`-`92` | EX3/EX4 有效位 |
| bound_sel | 7 位 | `ct_vfdsu_srt.v:652` | 由除数高位索引 bound_table |
| digit_bound_1..9 | 各 12 位 | `ct_vfdsu_srt_radix16_bound_table.v:38`-`46` | 商位选择边界 |

写回状态机的状态编码（`ct_vfdsu_ctrl.v:365`-`370`）：

```
IDLE=4'b0000  RF=4'b0100  EX1=4'b0101  EX2=4'b0110  WB_REQ=4'b0111  WB=4'b1000
```

注意编码不连续：bit2（`div_cur_state[2]`）恰好在 RF/EX1/EX2/WB_REQ 时为 1，被直接拿来当 `vfdsu_dp_fdiv_busy`（`:509`），是一处巧妙的编码复用。

---

## 4. 两个状态机：SRT 迭代机 + 写回机

vfdsu ctrl 里有**两个并行的状态机**，分工不同：

### (a) SRT 迭代机（`srt_cur_state`，2 态）

负责 SRT 基-16 迭代本身。状态转移（`ct_vfdsu_ctrl.v:194`-`211`）：

```verilog
SRT_IDLE : if(ex1_pipedown) srt_nxt_state = SRT_BUSY;  // EX1 选中即进 BUSY
SRT_BUSY : if(srt_last_round) srt_nxt_state = SRT_IDLE; // 最后一轮回 IDLE
```

`srt_sm_on = srt_cur_state`（`:215`）表示「正在迭代」。其时钟 `srt_sm_clk` 仅在 `srt_cur_state || ex1_pipedown || flush` 时翻转（`:179`-`181`），空闲停钟。

### (b) 写回状态机（`div_cur_state`，6 态）

负责把一条 fdiv/fsqrt 从发射走到写回，与 VFPU 流水/写回端口对齐。状态转移（`ct_vfdsu_ctrl.v:404`-`433`）：

```verilog
IDLE   : if(dp_vfdsu_idu_fdiv_issue) -> RF       // IDU 发射
RF     : -> EX1
EX1    : if(dp_vfdsu_ex1_pipex_sel)  -> EX2       // 进入迭代
EX2    : if(srt_last_round)          -> WB_REQ    // 迭代结束，申请写回
WB_REQ : if(ex4_pipedown)            -> WB        // 等 EX4 数据就绪
WB     : if(dp_vfdsu_idu_fdiv_issue) -> RF else IDLE  // 写回完成
```

两机协作：写回机在 EX2 态时（`div_st_ex2`，`:437`）等 SRT 迭代机的 `srt_last_round`；迭代机产出最后余数后，写回机依次走 WB_REQ→WB，在 WB 态置 `pipex_dp_vfdsu_inst_vld`（`:506`）把结果送上 pipe6 的 EX5 写回槽。

`ex2_pipedown = srt_last_round && div_st_ex2`（`:251`）——只有「SRT 跑到最后一轮 **且** 写回机在 EX2」时才把 EX2 结果推向 EX3，这把两个状态机精确同步。

---

## 5. srt_cnt 计数器与 srt_cnt_ini（13 / 6 / 3）

迭代轮数由 5 位计数器 `srt_cnt` 控制。**初值** `srt_cnt_ini` 按精度选（`ct_vfdsu_ctrl.v:246`-`248`）：

```verilog
assign srt_cnt_ini[4:0] = (ex1_double) ? 5'b01101 :   // = 13
                           ex1_single  ? 5'b00110      // = 6
                                       : 5'b00011;     // = 3 (half)
```

计数器逻辑（`ct_vfdsu_ctrl.v:229`-`241`）：

```verilog
if(ex1_pipedown)   srt_cnt <= srt_cnt_ini;   // 启动装初值
else if(srt_sm_on) srt_cnt <= srt_cnt - 5'b1; // 每轮 -1
```

`srt_cnt_zero = ~|srt_cnt`（`:227`）为 0 时触发 `srt_last_round`（§6）。

**为什么是 13 / 6 / 3？** 基-16 每轮出 4 位商。double 尾数 52 位 + 隐藏位 + 守护位 ≈ 需 13 轮 ×4 ≈ 52+ 位；single ≈ 6 轮 ×4 ≈ 24+ 位；half ≈ 3 轮 ×4 ≈ 12+ 位。轮数与精度尾数宽度成正比。

> **重要勘误**：`ct_vfdsu_ctrl.v:244`-`245` 的注释写「double 初值 28、single 14」，这是**历史遗留注释**（对应早期基-4 实现，每轮 2 位 ×28=56），与下方 `:246`-`248` 实际生效的 assign（13 / 6 / 3，基-16）**不符**。一切以代码为准：现版是基-16，初值 13 / 6 / 3。

---

## 6. 变延迟：skip_srt / rem_zero 提前结束

`srt_last_round`（迭代结束信号）有三个触发条件（`ct_vfdsu_ctrl.v:218`-`225`）：

```verilog
assign srt_last_round = (skip_srt || srt_ctrl_rem_zero || srt_cnt_zero) && srt_sm_on;
```

1. **`srt_cnt_zero`**：正常跑满 `srt_cnt_ini` 轮（`:227`）。
2. **`skip_srt = srt_ctrl_skip_srt`**（`:226`）：被除数/操作数是特殊情形，SRT 根本不必迭代。来自 `ct_vfdsu_srt.v:377`：

   ```verilog
   assign srt_ctrl_skip_srt = ex2_of || ex2_id_nor_srt_skip || ...
   ```

   即结果上溢（`ex2_of`，`:352`-`353`）或非规格化/特殊数（`ex2_id_nor_srt_skip`，`:293`）时直接跳过迭代——延迟最短。
3. **`srt_ctrl_rem_zero`**：余数已为零（除尽），无需再迭代。来自 `ct_vfdsu_srt.v:612`-`613`：

   ```verilog
   assign vfdsu_ex3_rem_zero = ~|srt_remainder[60:0];
   assign srt_ctrl_rem_zero  = vfdsu_ex3_rem_zero;
   ```

这三条让 vfdsu 成为**变延迟**：正常情况跑满轮数，特殊/除尽时提前结束。`00_vfpu_overview.md` §12 给出的「double≈18 / single≈11 / half≈8 拍」是跑满轮数的典型值（迭代轮数 + EX1 prepare + EX3 round + EX4 pack + 写回握手等固定开销）。

---

## 7. SRT 基-16 迭代：商位选择与 bound_table

SRT 除法每轮要从冗余商位集合里选一个商位 q，使部分余数收敛。基-16 一次选 4 位商，靠**查表比较**实现：

**bound_sel 生成**（`ct_vfdsu_srt.v:652`）：取除数高位作为查表索引：

```verilog
assign initial_bound_sel_in[6:0] = ex1_div ? initial_divisor_in[55:49] : {7{1'b0}};
```

**bound_table 查表**（`ct_vfdsu_srt_radix16_bound_table.v`，1168 行）：以 7 位 `bound_sel` 为输入，输出 9 个 12 位边界 `digit_bound_1..9`（`:38`-`46`）。这 9 个边界把部分余数的取值区间划分成商位 q ∈ {-8..-1, 0, +1..+8}（基-16 冗余表示，对称约 17 个候选）的选择门限。

**迭代引擎**（`ct_vfdsu_srt_radix16_only_div.v` 纯除法 / `ct_vfdsu_srt_radix16_with_sqrt.v` 除法+开方）：每轮把当前部分余数与这些 `digit_bound` 比较，选出商位 q，再算下一部分余数 `partial_rem = 16*partial_rem - q*divisor`（用进位保留形式 `div_qt_*_rem_add_op1[70:0]` 避免每轮全加器进位，`ct_vfdsu_srt_radix16_only_div.v:141`-`160`）。

把 bound_table 单独做成 1168 行的大查找表，是为了把「商位选择」这条 SRT 关键路径压成一次表查找 + 比较，而非每轮现算——这是基-16（高基数）实现能高频运行的关键，代价就是这张大表的面积（vfdsu 最大单块之一）。

---

## 8. 开方为何需要二轮 srt_secd_round

除法只需一轮 SRT；**开方需要二轮**（`srt_secd_round`）。原因：开方的部分根每步要用「已确定的部分根」参与下一步的余数更新（`rem = rem - (2*Q + q*16^-k)*q`），第一轮先求出初步根，第二轮做修正/补足精度。

`with_sqrt` 引擎有专门的 `srt_sel_sqrt`（`ct_vfdsu_srt_radix16_with_sqrt.v:69`）在开方时选择 sqrt 专用的余数更新算子（`sqrt_qt_*_rem_add_op1`，`:218`-`232`）。二轮标记由 ctrl 产生（`ct_vfdsu_ctrl.v:266`-`280`）：

```verilog
always @(posedge srt_sm_clk ...)
  ex2_srt_secd_round <= ex2_srt_secd_round_pre;
assign srt_secd_round         = ex2_srt_secd_round;             // :275
assign ex2_srt_secd_round_pre = srt_sm_on && srt_secd_round_pre; // :278
assign srt_secd_round_pre     = vfdsu_ex2_double ? srt_cnt==5'b01101 :   // 计数回到初值时
                                vfdsu_ex2_single ? srt_cnt==5'b00110 : srt_cnt==5'b00011; // :279-280
```

即当 `srt_cnt` 走回到初值（13/6/3）时，标记进入第二轮——开方因此比同精度除法多走一轮的拍数（`00_vfpu_overview.md` §12 注明 FSQRT 比同精度 FDIV 多若干拍）。`ex2_srt_first_round`（`:254`-`264`）则标记首轮，初始化部分根/余数。

---

## 9. EX3 round / EX4 pack / 写回握手

SRT 产出最终部分余数后，还要做规格化舍入与打包，这是 EX3/EX4 两级固定开销：

- **EX3（round）**：`vfdsu_ex3_vld`（`ct_vfdsu_ctrl.v:309`-`320`）有效时，`ct_vfdsu_round.v` 用余数符号/sticky 做最后一位的舍入决策（基-16 SRT 商是冗余表示，需在末轮转成非冗余并按 rm 舍入）。EX3 同时计算 `vfdsu_ex3_rem_zero`（除尽判定，§6）。
- **EX4（pack）**：`vfdsu_ex4_vld`（`:350`-`361`）有效时，`ct_vfdsu_pack.v` 把符号/阶码/尾数拼成 IEEE 格式，输出 `ex4_out_result[63:0]` + `ex4_out_expt[4:0]`（`ct_vfdsu_top.v:111`-`112`,`276`-`277`）。
- **写回握手**：
  - `vfdsu_dp_inst_wb_req = vfdsu_ex3_vld`（`:508`）—— EX3 就向 dp 申请写回端口（提前一拍占位，避免与定长指令撞端口）。
  - `vfdsu_dp_fdiv_busy = div_cur_state[2]`（`:509`）—— 回报 IDU 除法器忙，停止再发除法。
  - `pipex_dp_vfdsu_inst_vld = (div_cur_state == WB)`（`:506`）—— 写回机到 WB 态时拉高，把 `ex4_out_result` 经 `ct_vfdsu_scalar_dp` 输出 `pipex_dp_vfdsu_freg_data`（`ct_vfdsu_top.v:321`）送 pipe6 EX5 槽 → RBUS。

这一套握手让变延迟的 vfdsu 能在任意拍「插队」申请 pipe6 的写回端口，而不打乱定长 fadd/FMA 的写回时序——这正是 CBUS/RBUS 双轨设计的受益点（`00_vfpu_overview.md` §9）。

---

## 10. VLEN128 切分与各运算延迟总表

**VLEN128 切分**（`ct_vfdsu_top.v:139`-`224` 的 `&Instance`/`&Connect` 规则）：128 位源拆成 **set0（低 64b）+ set1（高 64b）**，每 set 内按精度再切：

| 实例 | 数据片 | 出处 |
|---|---|---|
| `x_ct_vfdsu_double_set0` | `ex1_src0[63:0]` | `ct_vfdsu_top.v:146` |
| `x_ct_vfdsu_double_set1` | `ex1_src0[127:64]` | `ct_vfdsu_top.v:189` |
| `x_ct_vfdsu_single_set0` | `ex1_src0[63:32]` | `ct_vfdsu_top.v:167` |
| `x_ct_vfdsu_half0_set0` | `ex1_src0[31:16]` | `ct_vfdsu_top.v:158` |
| `x_ct_vfdsu_half1_set0` | `ex1_src0[63:48]` | `ct_vfdsu_top.v:178` |

`srt_secd_round` 与 `ex2_srt_first_round` 是按 lane 的位向量（如 double 用 `[0]`/`[2]`、half 用 `[1]`/`[3]`），让各 lane 的开方二轮独立计时（`ct_vfdsu_top.v:149`,`160`,`192`,`203` 等的 `&Connect`）。

**各运算延迟**（跑满轮数的典型值，迭代轮数来自 srt_cnt_ini）：

| 运算 | 精度 | srt_cnt_ini | 总延迟（拍，含固定开销） | 出处 |
|---|---|---|---|---|
| FDIV | double | 13 | 约 18 | `ct_vfdsu_ctrl.v:246` |
| FDIV | single | 6 | 约 11 | `ct_vfdsu_ctrl.v:247` |
| FDIV | half | 3 | 约 8 | `ct_vfdsu_ctrl.v:248` |
| FSQRT | 各精度 | 同上 | 比同精度 FDIV 多（需二轮 `srt_secd_round`） | `ct_vfdsu_ctrl.v:275`-`280` |

固定开销 = EX1 prepare + EX3 round + EX4 pack + WB_REQ/WB 握手。`skip_srt`（特殊数）或 `rem_zero`（除尽）可让总延迟更短（§6）。

---

## 设计取舍小结

1. **SRT 基-16（每轮 4 位商）**：用高基数把迭代轮数压到 double 13 / single 6 / half 3 轮，远少于基-4；代价是商位选择需要 1168 行 bound_table 大查找表 + 冗余商位集合。
2. **双状态机分工**：SRT 迭代机（2 态）专注迭代本身；写回状态机（6 态）对齐 VFPU 流水/写回端口；两机靠 `srt_last_round` + `div_st_ex2` 精确同步。
3. **变延迟 + 提前结束**：`skip_srt`（特殊数）/ `rem_zero`（除尽）/ `srt_cnt_zero`（跑满）三条任一即结束，按数据自适应延迟。
4. **只放 pipe6、单实例**：除法/开方低频、面积大（SRT+bound_table+round/pack），单份省面积，IDU 调度 + busy 反压兜底。
5. **开方二轮**：开方部分根需迭代修正，比除法多一轮 `srt_secd_round`。
6. **EX3 提前申请写回端口**：`vfdsu_dp_inst_wb_req = vfdsu_ex3_vld`，让变延迟指令能插队占用 pipe6 写回端口而不扰乱定长指令。
7. **VLEN128 = set0/set1 双套 + 精度切分**：复用成熟 lane，向量只是多激活 set/lane，每 lane 的开方二轮独立计时。

## 覆盖声明

本文覆盖 vfdsu 的 SRT 基-16 除法/开方：两个状态机（SRT 迭代机 + 6 态写回机）、`srt_cnt_ini` 初值（**double=13 (5'b01101) / single=6 (5'b00110) / half=3 (5'b00011)**，`ct_vfdsu_ctrl.v:246`-`248`）、`skip_srt`/`rem_zero` 变延迟提前结束、商位选择 bound_table（`ct_vfdsu_srt_radix16_bound_table.v`）、开方二轮 `srt_secd_round`、EX3 round / EX4 pack / 写回握手与 VLEN128 set0/set1 切分。所有 srt_cnt 值、状态编码、流水级与延迟拍数（FDIV double≈18 / single≈11 / half≈8）均直接引自上述 RTL 行号，未作推测；其中 `ct_vfdsu_ctrl.v:244`-`245` 注释的 28/14 为历史遗留注释，**实际生效值以 `:246`-`248` 的 assign（13/6/3）为准**。vfdsu 在 VFPU 顶层的接线见 `01_vfpu_top.md` §8，整体定位见 `00_vfpu_overview.md` §7/§12。
