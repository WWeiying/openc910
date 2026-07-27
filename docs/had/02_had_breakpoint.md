# C910 HAD 断点 模块详细教学文档

> RTL 源文件：
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_bkpt.v`（328 行，硬件内存断点 A/B，每个实例化一份）
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_nirv_bkpt.v`（153 行，不可撤销断点 non-IRV bkpt）
>
> 配套寄存器在 `ct_had_regs.v`（BABA/BAMA/BABB/BAMB 基址掩码、HCR 的 BC/RC/NIRVEN 字段），相关行号在文中逐处标注。
>
> 前置阅读：`00_had_overview.md` §2（停核思想）、§7（2 个硬件断点 + N 次计数的设计决策）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [断点的四级判定模型（level one~four）](#4-断点的四级判定模型level-onefour)
5. [地址匹配：BABA 基址 + BAMA 掩码 + RC 取反](#5-地址匹配baba-基址--bama-掩码--rc-取反)
6. [BC 条件类型译码（取指/分支/load/store/特权级）](#6-bc-条件类型译码取指分支loadstore特权级)
7. [8 位过 N 次计数器（MBC）](#7-8-位过-n-次计数器mbc)
8. [断点请求生成与 raw/同步两条路径](#8-断点请求生成与-raw同步两条路径)
9. [split 指令与 data_bkpt_pending](#9-split-指令与-data_bkpt_pending)
10. [不可撤销断点 ct_had_nirv_bkpt](#10-不可撤销断点-ct_had_nirv_bkpt)
11. [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 这一层做什么

C910 提供 **2 个硬件内存断点**（memory breakpoint，简称 bkpt A 与 bkpt B），由 `ct_had_bkpt.v` 实例化两份完成（`ct_had_private_top.v:544` 的 `x_ct_had_bkpta`、`:591` 的 `x_ct_had_bkptb`）。版本 ID 字段 `id_reg[15:12]=4'd2` 就是在声明"本核有 2 个硬件断点"（`ct_had_regs.v:419`）。

每个硬件断点都能匹配一段**地址范围**（基址 + 掩码 + 范围取反），并附加**条件类型**（取指/分支改流/load/store，再叠加特权级过滤），命中后还要**过 N 次计数**（8 位计数器，第 N 次命中才真正请求停核）。这套机制让调试器可以表达"对地址区间 [X, X+2^k) 上的第 5 次 store 触发断点"这种丰富语义。

地址比较本身**不在 HAD 里做**——HAD 只把基址/掩码/取反位通过 `had_yy_xx_bkpta_base/mask/rc`（`ct_had_regs.v:925-934`）送给 RTU/LSU，由它们在退休/访存通路上完成地址比较，再把"命中"脉冲 `rtu_had_inst_bkpt_vld` / `rtu_had_data_bkpt_vld` 回送给 `ct_had_bkpt`。`ct_had_bkpt` 负责的是**命中之后的条件过滤、计数、请求生成**。

另有一个 **non-IRV 断点**（non-irreversible，不可撤销断点，`ct_had_nirv_bkpt.v`）：它走的是一条更"硬"的路径，命中后无条件、不可被推测撤销地进入 debug。它由 HCR 的 NIRVEN 位（`hcr_reg[31]`，`ct_had_regs.v:896`）使能，并与普通内存断点互斥（NIRVEN 置 1 时普通断点的 `inst_bkpt_occur`/`data_bkpt_occur` 被关掉，见 `ct_had_bkpt.v:168-169`）。

### 1.2 两类断点对比

| 维度 | 内存断点（ct_had_bkpt × 2） | 不可撤销断点（ct_had_nirv_bkpt） |
|------|-----------------------------|----------------------------------|
| 使能 | `ctrl_bkpt_en = |regs_xx_bc[4:0]`（BC 非零）| HCR.NIRVEN=1（`hcr_reg[31]`）且 ctrl_bkpta/b_en |
| 地址匹配 | BABA/BAMA + RC，RTU/LSU 比较 | 由 RTU 直接给出 `rtu_had_instN_non_irv_bkpt[3:0]` |
| 条件类型 | BC[4:0] 译码：取指/分支/load/store + 特权级 | 仅区分 bkpt a / bkpt b（位编码固定）|
| 过 N 次计数 | 有，8 位 MBC 计数器 | 无 |
| 撤销性 | 命中可被流水线 flush 撤销（有 raw/pending 处理）| 不可撤销，命中即 latch（`non_irv_bkpt_vld`）|
| 用途 | 常规数据/取指断点、循环第 N 次断点 | 关键路径、不能被推测执行掩盖的断点 |

---

## 2. 端口说明

### 2.1 ct_had_bkpt 主要端口

#### 配置输入（来自 regs / ir）

| 信号 | 位宽 | 含义 |
|------|------|------|
| `regs_xx_bc` | [4:0] | 断点条件类型 BC（来自 HCR.BCA/BCB），`ct_had_bkpt.v:58` |
| `regs_xx_nirven` | 1 | NIRVEN，置 1 时本断点让位给 non-IRV 断点，`:59` |
| `ctrl_bkpt_en` | 1 | 本断点使能（同步版，`:53`）|
| `ctrl_bkpt_en_raw` | 1 | 本断点使能（组合 raw 版，`:54`）|
| `ir_xx_mbc_reg_sel` | 1 | MBC 计数器被 JTAG 选中（写计数初值），`:30` |
| `ir_xx_wdata` | [63:0] | JTAG 写数据（写 MBC 初值），`:57` |
| `x_sm_xx_update_dr_en` | 1 | Update-DR 脉冲（写寄存器时机），`:46` |
| `cp0_yy_priv_mode` | [1:0] | 当前特权级（条件类型按用户/特权过滤），`:50` |

#### RTU/LSU 命中输入

| 信号 | 含义 |
|------|------|
| `rtu_had_inst_bkpt_vld` | 取指/分支类断点地址命中，`:37` |
| `rtu_had_data_bkpt_vld` | 数据访存断点地址命中，`:35` |
| `rtu_had_bkpt_data_st` | 命中的访存是 store（1）还是 load（0），`:34` |
| `rtu_had_inst_bkpt_inst_vld` | 命中所在指令本周期有效，`:36` |
| `rtu_had_xx_mbkpt_chgflow` | 命中指令是改流（分支）指令，`:39` |
| `rtu_had_xx_mbkpt_inst_ack` / `_data_ack` | RTU 对该断点的 ack，`:41,:40` |
| `rtu_had_xx_split_inst` / `rtu_had_inst_split` | 命中指令是被拆分（split）指令，`:42,:38` |
| `rtu_yy_xx_dbgon` | 已在 debug mode，`:43` |
| `rtu_yy_xx_retire0_normal` | 第 0 条正常退休，`:45` |
| `rtu_yy_xx_flush` | 流水线 flush，`:44` |

#### 输出（到 ctrl / regs）

| 信号 | 含义 |
|------|------|
| `bkpt_ctrl_inst_req` / `bkpt_ctrl_data_req` | 同步断点请求（送 ctrl），`:75,:73` |
| `bkpt_ctrl_inst_req_raw` / `bkpt_ctrl_data_req_raw` | 组合 raw 请求（早一拍），`:76,:74` |
| `bkpt_ctrl_xx_ack` | 断点 ack（计数到 0 时），`:77` |
| `bkpt_regs_mbc` | [7:0] 当前计数值（回送给 regs 供读出），`:78` |

> 注：`xx` 是实例名占位符。bkpt A 实例对应 HCR.BCA/RCA/BABA/BAMA/MBCA，bkpt B 对应 HCR.BCB/RCB/BABB/BAMB/MBCB。

### 2.2 ct_had_nirv_bkpt 主要端口

| 方向 | 信号 | 含义 |
|------|------|------|
| in | `ctrl_bkpta_en` / `ctrl_bkptb_en` | A/B 断点使能，`ct_had_nirv_bkpt.v:39,:40` |
| in | `regs_xx_nirven` | NIRVEN 总开关，`:41` |
| in | `rtu_had_inst0/1/2_non_irv_bkpt[3:0]` | 3 条退休指令各自的 non-IRV 命中位，`:42-44` |
| in | `rtu_yy_xx_retire0_normal/retire1/retire2` | 三发退休有效位，`:48-50` |
| in | `rtu_had_xx_split_inst` / `rtu_yy_xx_flush` / `rtu_yy_xx_dbgon` | split / flush / 已 debug，`:45,:47,:46` |
| out | `non_irv_bkpt_vld` | non-IRV 断点有效（latch），送 ctrl，`:52` |
| out | `nirv_bkpta` | 命中的是 A（1）还是 B（0），供 MBIR 记录，`:51` |

---

## 3. 参数与关键寄存器

断点的配置寄存器物理上**位于 `ct_had_regs.v`**，`ct_had_bkpt` 只接收它们译码后的信号：

| 寄存器 | 位置 | 字段 | 出处 |
|--------|------|------|------|
| BABA / BABB | 64 位 | 断点 A/B 基地址 | `ct_had_regs.v:228-229`, 写逻辑 `:448-470`，输出 `:925-926` |
| BAMA / BAMB | 8 位 | 断点 A/B 地址掩码 | `:230-231`, 写逻辑 `:477-500`，输出 `:928-930` |
| HCR.BCA | `hcr_reg[4:0]` | 断点 A 条件类型 → `regs_xx_bca` | `:894` |
| HCR.BCB | `hcr_reg[10:6]` | 断点 B 条件类型 → `regs_xx_bcb` | `:892` |
| HCR.RCA | `hcr_reg[5]` | 断点 A 范围取反（Range Compare）| `:932` |
| HCR.RCB | `hcr_reg[11]` | 断点 B 范围取反 | `:934` |
| HCR.NIRVEN | `hcr_reg[31]` | non-IRV 断点使能 → `regs_xx_nirven` | `:896` |
| MBCA / MBCB | 8 位 | 断点 A/B 过 N 次计数器（在 `ct_had_bkpt` 内）| `ct_had_bkpt.v:81`, 写 `:272-282` |

BAMA/BAMB 复位为 0（RTL 注释明确写 "reset BAMA to zero for low power design"，`ct_had_regs.v:475,490`）。

---

## 4. 断点的四级判定模型（level one~four）

`ct_had_bkpt.v:141-162` 的大段注释定义了断点判定的**四级流水**，这是理解整个模块的骨架，必须先建立这张图：

```
level one  : 地址命中（RTU/LSU 给）+ bkpt_en + retire normal + 非 split
             → 信号 inst_bkpt_occur / data_bkpt_occur            (ct_had_bkpt.v:168-169)
level two  : 条件类型匹配（BC 译码：取指/分支/load/store + 特权级）
             → 信号 inst_bkpt_vld / data_bkpt_vld                (:218-223)
level three: 断点请求（vld + 计数器到 0/1 + 不在 debug）
             → 信号 bkpt_ctrl_inst_req / bkpt_ctrl_data_req      (:302-303)
level four : 满足 SQC（顺序限定）条件 → 真正的停核请求
             → 在 ct_had_ctrl.v 里完成（见 03_had_ctrl_ddc.md §debug 请求）
```

**为什么要分级**：地址命中只是必要条件。一次访存命中地址范围后，还要看它是不是"调试器关心的那种访问"（条件类型），再看"是不是第 N 次"（计数器），最后还要看多断点之间的顺序约束（SQC）。把这些正交的判据拆成四级，每一级一个清晰的命名（occur → vld → req → debug_req），可读性和可验证性都更好。

---

## 5. 地址匹配：BABA 基址 + BAMA 掩码 + RC 取反

地址比较本身在 RTU/LSU，但其**语义由 HAD 的三个量控制**：

- **BABA（Base Address of Breakpoint A）**：64 位基地址，`ct_had_regs.v:925` 输出 `had_yy_xx_bkpta_base`。
- **BAMA（Base Address Mask）**：8 位掩码，`:928` 输出 `had_yy_xx_bkpta_mask`。掩码决定地址比较时**忽略低多少位**，从而把"单地址命中"扩展成"地址区间命中"——例如掩码让低 4 位免比较，就匹配一段 16 字节区间。
- **RC（Range Compare / Reverse Compare）**：HCR.RCA（`hcr_reg[5]`，`:932`）。

RTL 顶部注释一句话点明了 RC 的语义（`ct_had_bkpt.v:145`）：

```
address trap (addr equal & rc clear  or  addr not equal & rc set)
```

也就是：
- RC=0：地址**落在**范围内才命中（在区间内 trap）；
- RC=1：地址**落在范围外**才命中（在区间外 trap，即"范围取反"）。

"范围取反"非常实用：想在某段合法栈/堆区间之外的任意访问上设陷阱（越界检测），只需把区间设为合法区、RC 置 1 即可。

这三个量在 HAD 内只是寄存器读写 + 直连输出，真正的 `==`/掩码比较发生在 RTU/LSU，HAD 拿到的就是比较结果脉冲 `rtu_had_inst_bkpt_vld` / `rtu_had_data_bkpt_vld`。

---

## 6. BC 条件类型译码（取指/分支/load/store/特权级）

`regs_xx_bc[4:0]`（5 位 BC 字段）经过 `ct_had_bkpt.v:177-197` 译码成五类"断点类型"组合逻辑。这段是模块最密集的真值表，逐个看：

### 6.1 特权级先验

```verilog
assign user_mode = cp0_yy_priv_mode[1:0] == 2'b00;   // :174
assign priv_mode = !user_mode;                        // :175
```

BC 的高位（bit4/bit3）用来表达"只在用户态"或"只在特权态"才生效，所以每个条件式都会附带 `priv_mode` / `!priv_mode` 项。

### 6.2 五类条件

| 信号 | 含义 | 行号 |
|------|------|------|
| `changeflow_inst_bkpt` | 命中点是**改流（分支/跳转）指令**才停 | `:177-179` |
| `normal_inst_bkpt` | 命中点是**任意取指**就停 | `:180-185` |
| `normal_data_bkpt` | 命中点是**任意数据访存**就停（load+store）| `:186-191` |
| `st_data_bkpt` | 只在**store** 命中时停 | `:192-194` |
| `load_data_bkpt` | 只在**load** 命中时停 | `:195-197` |

以 `changeflow_inst_bkpt` 为例（`:177-179`）：

```verilog
assign changeflow_inst_bkpt =
     !bc[4]&&!bc[3]&& bc[2]&&!bc[1]&&!bc[0]                       // 00100：不分特权
  ||  bc[4]&&!bc[3]&& bc[2]&&!bc[1]&&!bc[0]&&!priv_mode           // 10100：仅用户态
  ||  bc[4]&& bc[3]&& bc[2]&&!bc[1]&&!bc[0]&& priv_mode;          // 11100：仅特权态
```

可见 `bc[2]` 选"改流"语义，`bc[4]`/`bc[3]` 进一步缩窄到某个特权级。其余四类同理，构成一张 BC[4:0] → 断点语义的完整真值表。

### 6.3 打一拍 + level two 汇总

这些组合译码结果先打一拍（`:198-216`，存进 `*_bkpt_ff`），与地址命中（level one 的 `inst_bkpt_occur`/`data_bkpt_occur`）相与，得到 level two 的 vld（`:218-223`）：

```verilog
assign inst_bkpt_vld = inst_bkpt_occur && rtu_had_xx_mbkpt_chgflow && changeflow_inst_bkpt_ff
                    || inst_bkpt_occur && normal_inst_bkpt_ff;             // :218-219

assign data_bkpt_vld = data_bkpt_occur && normal_data_bkpt_ff
                    || data_bkpt_occur && rtu_had_bkpt_data_st && st_data_bkpt_ff
                    || data_bkpt_occur &&!rtu_had_bkpt_data_st && load_data_bkpt_ff;  // :221-223
```

注意 store/load 的区分靠 RTU 给的 `rtu_had_bkpt_data_st`（`:222-223`），与 BC 译码出的 `st_data_bkpt`/`load_data_bkpt` 相与。打一拍是为了和 RTU 的命中时序对齐。

---

## 7. 8 位过 N 次计数器（MBC）

调试器常需要"循环里第 N 次命中才停"。这由 8 位 **MBC 计数器**（Memory Breakpoint Counter）实现（`ct_had_bkpt.v:81`，`bkpt_counter[7:0]`）。

### 7.1 计数器三态

```verilog
always @(posedge cpuclk or negedge cpurst_b)            // :272-282
  if (!cpurst_b)
    bkpt_counter <= 8'b0;
  else if (x_sm_xx_update_dr_en && ir_xx_mbc_reg_sel)   // JTAG 写初值 N
    bkpt_counter <= ir_xx_wdata[7:0];
  else if (bkpt_counter_dec_1)                          // 命中一次减 1
    bkpt_counter <= bkpt_counter - 8'b1;
  else
    bkpt_counter <= bkpt_counter;
```

- 调试器通过 JTAG 选中 MBC 寄存器（`ir_xx_mbc_reg_sel`）写入初值 N。
- 每发生一次"够格的命中"，计数器减 1（`bkpt_counter_dec_1`，`:261-268`）。
- 减到 0 时，断点请求才放行。

### 7.2 减 1 的条件

```verilog
assign bkpt_counter_dec_1 = (inst_bkpt_vld_f && !rtu_had_xx_split_inst || data_bkpt_vld_f) &&
                            ctrl_bkpt_en && rtu_yy_xx_retire0_normal &&
                           !bkpt_counter_eq_0 && !inst_bkpt_dbgreq && !rtu_yy_xx_dbgon;   // :261-268
```

含义：只有 vld、使能、正常退休、计数器非 0、当前没有别的断点请求、且不在 debug 时才减。注释里还区分了"减 1"与"减 2"的语义（`:230-238`）：当 inst 与 data 断点在同一周期都命中时计数会减 2（角点处理），这就是为什么 level three 的请求条件要把 `bkpt_counter_eq_1` 也算进"即将到 0"（`:289`、`:296-298`）。

### 7.3 请求生成

```verilog
assign bkpt_counter_eq_0 = bkpt_counter == 8'b0;       // :284
assign bkpt_counter_eq_1 = bkpt_counter == 8'b1;       // :285
assign bkpt_regs_mbc = bkpt_counter;                   // :287 回送 regs 供 JTAG 读出
```

`bkpt_counter_eq_0_raw`（`:289`）在"本周期正好要减到 0"时提前给出 0，让 raw 路径无需等一拍。

---

## 8. 断点请求生成与 raw/同步两条路径

level three 的请求有**两套**：同步版（打过拍）和 raw 版（组合早出）。

```verilog
// 同步版（基于打拍后的 *_vld_f）
assign bkpt_ctrl_inst_req = bkpt_counter_eq_0 && inst_bkpt_vld_f && !rtu_yy_xx_dbgon
                         && ctrl_bkpt_en && inst_bkpt_inst_vld_f;          // :302
assign bkpt_ctrl_data_req = bkpt_counter_eq_0 && data_bkpt_vld_f && !rtu_yy_xx_dbgon
                         && ctrl_bkpt_en && rtu_yy_xx_retire0_normal;      // :303

// raw 版（基于组合 *_vld 与 _raw 使能、_raw 计数到 0）
assign inst_bkpt_req_raw = bkpt_counter_eq_0_raw && inst_bkpt_vld && !rtu_yy_xx_dbgon
                        && ctrl_bkpt_en_raw && rtu_had_inst_bkpt_inst_vld; // :305
assign data_bkpt_req_raw = bkpt_counter_eq_0_raw && data_bkpt_vld && !rtu_yy_xx_dbgon
                        && ctrl_bkpt_en_raw && rtu_had_inst_bkpt_inst_vld; // :306
```

**为什么要 raw 路径**：停核请求送 RTU 时，越早送、RTU 越容易在指令边界精确停住。raw 路径用组合逻辑提前一拍给出请求，让 `ct_had_ctrl` 能在更早的窗口把请求送给 RTU（`had_rtu_inst_bkpt_dbgreq` / `had_rtu_data_bkpt_dbgreq`，见 `ct_had_ctrl.v:507-508`）；而同步版用于更新 HSR 状态位（mbo/sqa/sqb）这类不要求极致时序的地方。

`bkpt_ctrl_xx_ack`（`:299-300`）在计数到 0 且使能时对 RTU 的 mbkpt ack 做应答，用于 HSR 的 mbo/bkpt vld 记录（`ct_had_ctrl.v:559,564-569`）。

---

## 9. split 指令与 data_bkpt_pending

C910 会把某些指令拆成多个 micro-op（split inst）。如果数据断点命中发生在一条 split 指令上，请求不能立刻发，否则会停在指令中间。`ct_had_bkpt` 用 `data_bkpt_pending` 把请求**挂起到 split 指令整体退休**：

```verilog
always @(posedge cpuclk or negedge cpurst_b)            // :312-322
  if (!cpurst_b)              data_bkpt_pending <= 1'b0;
  else if (rtu_yy_xx_flush)   data_bkpt_pending <= 1'b0;          // flush 取消挂起
  else if (data_bkpt_req_raw && rtu_had_inst_split)
                              data_bkpt_pending <= 1'b1;          // split 上命中 → 挂起
  else if (rtu_yy_xx_dbgon)   data_bkpt_pending <= 1'b0;

assign bkpt_ctrl_data_req_raw = data_bkpt_req_raw && !rtu_had_inst_split
                             || data_bkpt_pending && !rtu_had_inst_split && rtu_had_inst_bkpt_inst_vld;  // :309-310
```

逻辑：raw 请求若落在非 split 指令上直接放行；若落在 split 指令上则置 pending，等到 split 结束（`!rtu_had_inst_split` 且下一条 inst 有效）再放行。flush 会清掉挂起（命中指令被撤销了）。

---

## 10. 不可撤销断点 ct_had_nirv_bkpt

non-IRV（non-irreversible）断点用于"命中后不可被推测执行撤销"的关键场景。它结构比普通断点简单——**没有地址比较、没有 BC 译码、没有计数器**，命中信息直接由 RTU 给出。

### 10.1 命中信号来源

RTU 对每条退休指令给出 4 位 non-IRV 命中向量，HAD 用退休有效位做门控（`ct_had_nirv_bkpt.v:85-87`）：

```verilog
assign inst0_non_irv_bkpt = rtu_had_inst0_non_irv_bkpt[3:0] & {4{rtu_yy_xx_retire0_normal}};
assign inst1_non_irv_bkpt = rtu_had_inst1_non_irv_bkpt[3:0] & {4{rtu_yy_xx_retire1}};
assign inst2_non_irv_bkpt = rtu_had_inst2_non_irv_bkpt[3:0] & {4{rtu_yy_xx_retire2}};
```

4 位向量里，bit[1]/bit[2] 归断点 **A**，bit[0]/bit[3] 归断点 **B**（`:89-95`）：

```verilog
assign nirv_bkpta_occur = inst0_non_irv_bkpt[1] || inst0_non_irv_bkpt[2] || ... ;   // :89-91
assign nirv_bkptb_occur = inst0_non_irv_bkpt[0] || inst0_non_irv_bkpt[3] || ... ;   // :93-95
```

### 10.2 使能与互斥

```verilog
assign kbpt_occur = regs_xx_nirven &&
                    (nirv_bkpta_occur && ctrl_bkpta_en || nirv_bkptb_occur && ctrl_bkptb_en);  // :97-98
```

只有 NIRVEN（HCR.NIRVEN=`hcr_reg[31]`）置 1，且对应 A/B 断点使能，命中才成立。同时回看 `ct_had_bkpt.v:168-169`：NIRVEN 置 1 时普通断点的 occur 被关掉。**二者互斥**——同一断点要么走普通（带计数/条件）路径，要么走 non-IRV（不可撤销）路径。

### 10.3 split 挂起与 latch

与普通断点类似，命中若落在 split 指令上要挂起（`nirv_bkpt_pending`，`:100-110`），并记住命中的是 A 还是 B（`nirv_bkpta_pending`，`:112-120`）。最终：

```verilog
assign nirv_bkpt_occur_raw = kbpt_occur && !rtu_had_xx_split_inst ||
                             nirv_bkpt_pending && !rtu_had_xx_split_inst && rtu_yy_xx_retire0_normal;  // :122-123

always @(...)                                          // :126-136
  if      (rtu_yy_xx_flush)      non_irv_bkpt_vld <= 1'b0;
  else if (nirv_bkpt_occur_raw)  non_irv_bkpt_vld <= 1'b1;   // latch 住，直到进 debug
  else if (rtu_yy_xx_dbgon)      non_irv_bkpt_vld <= 1'b0;
```

`non_irv_bkpt_vld` 一旦置 1 就 latch 住，只有 flush 或真正进入 debug 才清。`ct_had_ctrl.v:510` 据此产生 `had_rtu_non_irv_bkpt_dbgreq`，而且这条请求**不经过 SQC/计数器/fdb 过滤**，优先级最高（它甚至直接进入 `had_cp0_xx_dbg` 的唤醒条件，`ct_had_ctrl.v:522`，能把核从低功耗态唤醒）。`nirv_bkpta`（`:140-148`）告诉 regs 命中的是 A 还是 B，写进 MBIR 索引（`ct_had_regs.v:842-852`）。

**这就是"不可撤销"的含义**：它一旦 latch，不依赖计数器、不依赖条件类型、也不受 SQC 顺序约束，命中即必停。

---

## 设计取舍小结

| 决策 | 内容 | 出处 | 为什么 |
|------|------|------|--------|
| 2 个硬件断点 | bkpt A/B 各实例化一份 `ct_had_bkpt` | `ct_had_private_top.v:544,591`；`id_reg[15:12]=2` `ct_had_regs.v:419` | 覆盖最常见的"取指 + 数据"双断点需求，面积可控 |
| 地址比较外置 RTU/LSU | HAD 只出 base/mask/rc，比较在退休/访存通路做 | `ct_had_regs.v:925-934`；命中回 `:168-169` | 避免在 HAD 复制一份地址比较器，复用流水线已有的比较点 |
| BAMA 掩码 + RC 取反 | 掩码扩区间、RC 选区间内/外 trap | `ct_had_bkpt.v:145` 注释 | 一套机制覆盖"区间断点 + 越界检测" |
| BC 真值表 | 5 位 BC 译码取指/分支/load/store + 特权级 | `ct_had_bkpt.v:177-197` | 用窄字段表达丰富条件，正交可组合 |
| 8 位 MBC 过 N 次 | 命中减 1，到 0 才停；inst+data 同周期减 2 | `ct_had_bkpt.v:272-298` | 循环调试"第 N 次断点"刚需 |
| raw / 同步双路径 | raw 组合早出送 RTU，同步打拍更新 HSR | `ct_had_bkpt.v:302-310` | RTU 要尽早收请求才能精确停核 |
| split 挂起 | 命中 split 指令时 pending 到整体退休 | `ct_had_bkpt.v:312-322`；nirv `:100-110` | 不能停在指令中间 |
| non-IRV 与普通互斥 | NIRVEN 置 1 关普通 occur，命中即 latch | `ct_had_bkpt.v:168-169`；`ct_had_nirv_bkpt.v:97`,`:126-136` | 关键断点不可被推测撤销，必停 |

---

## 覆盖声明

本篇覆盖 `ct_had_bkpt.v`（地址匹配语义、BC 条件译码真值表、8 位 MBC 计数、四级判定、raw/同步双路径、split 挂起）与 `ct_had_nirv_bkpt.v`（不可撤销断点的命中来源、A/B 编码、使能互斥、latch 行为），并对齐 `ct_had_regs.v` 中 BABA/BAMA/HCR 各字段。所有信号名、位宽、行号均按 RTL 实读标注，未对 RTL 行为做虚构。断点请求如何进一步过 SQC 条件并发给 RTU，见 `03_had_ctrl_ddc.md`。
