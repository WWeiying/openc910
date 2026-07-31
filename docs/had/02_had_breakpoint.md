# C910 HAD 断点 模块详细教学文档

> RTL 源文件：
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_bkpt.v`（328 行，硬件内存断点 A/B，每个实例化一份）
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_nirv_bkpt.v`（153 行，non-IRV 退休元数据断点路径）
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
10. [non-IRV 断点 ct_had_nirv_bkpt](#10-non-irv-断点-ct_had_nirv_bkpt)
11. [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 这一层做什么

C910 提供 **2 个硬件内存断点**（memory breakpoint，简称 bkpt A 与 bkpt B），由 `ct_had_bkpt.v` 实例化两份完成（`ct_had_private_top.v:544` 的 `x_ct_had_bkpta`、`:591` 的 `x_ct_had_bkptb`）。版本 ID 字段 `id_reg[15:12]=4'd2` 就是在声明"本核有 2 个硬件断点"（`ct_had_regs.v:419`）。

每个硬件断点都提供基址、低 8 位逐 bit 比较使能、比较结果取反、BC 类型过滤和 8 位命中计数。若软件把 mask 配成“高位连续为 1、最低 k 位连续为 0”，它可以表达常见的 `2^k` 字节对齐范围；但 RTL 不强制 mask 连续，任意稀疏 mask 都合法，所以硬件本质上实现的是**掩码相等类**，不是只能表示单一连续区间的范围比较器。配置为连续 mask 时，才可以通俗理解为“对某地址块上的第 N 次 store 触发”。

地址比较本身**不在 `ct_had_bkpt` 里做**。当前有效 RTL 的指令地址比较位于 IFU `ct_ifu_ifdp.v`，它并行比较一个取指窗口内 8 个、以 2 字节递增的候选 PC；load/store 地址比较分别位于 LSU 的 `ct_lsu_ld_dc.v` 和 `ct_lsu_st_dc.v`。RTU 中还能看到旧地址比较代码，但该段已经注释，不能当成现行实现。比较结果随指令/访存元数据流到 RTU，再以 `rtu_had_inst_bkpt_vld` / `rtu_had_data_bkpt_vld` 送入 `ct_had_bkpt`。因此职责划分是：

```text
HAD regs：保存 base/mask/RC/BC/MBC
IFU/LSU ：执行地址匹配，并把命中位附着到流水线元数据
RTU     ：在指令边界提供命中、类型、split、retire 和 ack 信息
HAD bkpt：做 NIRVEN 屏蔽、BC 类型过滤、计数、pending 和请求生成
```

另有一条 RTL 命名为 **non-IRV** 的断点路径（`ct_had_nirv_bkpt.v`）。源码没有给出 `IRV` 的英文全称，所以本文保留信号原名，不自行扩展成 “non-irreversible” 或“不可撤销”。该路径直接消费 RTU 随三条退休槽传来的 4 位断点元数据，不经过普通路径的 BC、MBC 和 SQC；但它仍会被 `flush` 清除，进入 debug 前还要经过 HAD 请求和 RTU 接受条件。因此准确说法是“独立于普通过滤链的退休元数据断点路径”，不是“命中后无条件必停”。

### 1.2 两类断点对比

| 维度 | 内存断点（ct_had_bkpt × 2） | non-IRV 路径（ct_had_nirv_bkpt） |
|------|-----------------------------|----------------------------------|
| 使能 | `ctrl_bkpt_en = \|regs_xx_bc[4:0]`（BC 非零）| HCR.NIRVEN=1（`hcr_reg[31]`）且 ctrl_bkpta/b_en |
| 地址匹配 | BABA/BAMA + RC；IFU 比较指令 PC，LSU 比较访存地址 | HAD 不重新比较地址；使用 RTU 随退休槽传来的 `rtu_had_instN_non_irv_bkpt[3:0]` 元数据 |
| 条件类型 | BC[4:0] 译码：取指/分支/load/store + 特权级 | 仅区分 bkpt a / bkpt b（位编码固定）|
| 过 N 次计数 | 有，8 位 MBC 计数器 | 无 |
| `flush` 行为 | data pending 会被 `rtu_yy_xx_flush` 清除 | pending 和已锁存的 `non_irv_bkpt_vld` 都会被 `flush` 清除 |
| 过滤链 | BC → MBC → SQC/FDB 等控制 | 绕过 BC、MBC、SQC/FDB；仍需 RTU 在可接受的退休边界确认 |

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

#### 流水线命中与 RTU 资格输入

| 信号 | 含义 |
|------|------|
| `rtu_had_inst_bkpt_vld` | 随流水线送到 HAD 的指令地址断点命中，源比较点在 IFU，`:37` |
| `rtu_had_data_bkpt_vld` | 随流水线送到 HAD 的数据访问断点命中，源比较点在 LSU，`:35` |
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
| `bkpt_ctrl_xx_ack` | RTU 已给出 inst/data mbkpt ack，且计数器当前为 0、本断点使能时的组合确认，`:77,:299-300` |
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
| out | `non_irv_bkpt_vld` | non-IRV 路径的锁存请求；可被 flush 或进入 debug 清除，送 ctrl，`:52,:126-136` |
| out | `nirv_bkpta` | 命中的是 A（1）还是 B（0），供 MBIR 记录，`:51` |

---

## 3. 参数与关键寄存器

断点的配置寄存器物理上**位于 `ct_had_regs.v`**，`ct_had_bkpt` 只接收它们译码后的信号：

| 寄存器 | 位置 | 字段 | 出处 |
|--------|------|------|------|
| BABA / BABB | 64 位可串行读写；当前仅低 `PA_WIDTH` 位输出 | 断点 A/B 基址 | `ct_had_regs.v:228-229,408,925-926` |
| BAMA / BAMB | 8 位 | 低 8 个地址 bit 的**比较使能**：1=参与比较，0=忽略 | `:230-231,928-930` |
| HCR.BCA | `hcr_reg[4:0]` | 断点 A 条件类型 → `regs_xx_bca` | `:894` |
| HCR.BCB | `hcr_reg[10:6]` | 断点 B 条件类型 → `regs_xx_bcb` | `:892` |
| HCR.RCA | `hcr_reg[5]` | 断点 A 范围取反（Range Compare）| `:932` |
| HCR.RCB | `hcr_reg[11]` | 断点 B 范围取反 | `:934` |
| HCR.NIRVEN | `hcr_reg[31]` | non-IRV 断点使能 → `regs_xx_nirven` | `:896` |
| MBCA / MBCB | 8 位 | 断点 A/B 过 N 次计数器（在 `ct_had_bkpt` 内）| `ct_had_bkpt.v:81`, 写 `:272-282` |

BAMA/BAMB 复位为 0。由于地址 bit[7:0] 全部被忽略，这并不表示“精确匹配 BABA 单地址”，而是在高位相等时覆盖低 8 位的全部 256 种组合。是否会实际停核还取决于 BC 是否非零以及后续过滤链。

---

## 4. 断点的四级判定模型（level one~four）

`ct_had_bkpt.v:141-162` 的大段注释定义了断点判定的**四级流水**，这是理解整个模块的骨架，必须先建立这张图：

```
level one  : 外部流水线已完成地址匹配及其时序资格判断；
             本模块只对 RTU 命中输入施加 !NIRVEN
             → inst_bkpt_occur / data_bkpt_occur                  (ct_had_bkpt.v:168-169)
level two  : 条件类型匹配（BC 译码：取指/分支/load/store + 特权级）
             → 信号 inst_bkpt_vld / data_bkpt_vld                (:218-223)
level three: 断点请求（vld + 计数器到 0/1 + 不在 debug）
             → 信号 bkpt_ctrl_inst_req / bkpt_ctrl_data_req      (:302-303)
level four : 满足 SQC（顺序限定）条件 → 真正的停核请求
             → 在 ct_had_ctrl.v 里完成（见 03_had_ctrl_ddc.md §debug 请求）
```

RTL 顶部注释把地址 trap、enable、正常退休和非 split 都归入 level one，但 `ct_had_bkpt` 内的两个 `occur` 连续赋值实际上只有“RTU 命中输入 AND `!regs_xx_nirven`”。其它条件已在 IFU/LSU/RTU 或后续逻辑中完成。阅读分级注释时要把它理解成**跨模块功能分层**，不能误认为四个条件都在 `ct_had_bkpt` 的 level-one 赋值中再次验证。

---

## 5. 地址匹配：BABA 基址 + BAMA 掩码 + RC 取反

地址比较本身在 IFU/LSU，但其**语义由 HAD 的三个量控制**：

- **BABA/BABB**：寄存器可按 64 位串行读写，但当前比较通路只输出低 `PA_WIDTH` 位。
- **BAMA/BAMB**：8 位低地址比较使能。对 bit `i`，mask[i]=1 时要求 base[i]=addr[i]，mask[i]=0 时忽略该位；bit[PA_WIDTH-1:8] 始终参与比较。
- **RCA/RCB**：对最终“掩码相等”结果做异或。RC=0 保持相等匹配，RC=1 取补集。

RTL 顶部注释一句话点明了 RC 的语义（`ct_had_bkpt.v:145`）：

```
address trap (addr equal & rc clear  or  addr not equal & rc set)
```

抽象公式为：

```text
equal = (base & full_mask) == (addr & full_mask)
trap  = equal XOR RC
full_mask[PA_WIDTH-1:8] = 全 1
full_mask[7:0]          = BAMA/BAMB
```

若低 k 位 mask=0、其余低 8 位 mask=1，匹配集合是一个 `2^k` 字节对齐块；若 mask 稀疏，匹配集合会在 256 字节低位空间中形成离散别名，不能写成单一 `[X, X+2^k)`。RC=1 则对整个匹配集合取补集。把它用于越界检查是软件层用途示例，不是 RTL 自动识别“合法栈/堆”。

IFU 在 `ct_ifu_ifdp.v:1684-1699` 对 8 个 2 字节粒度候选 PC 并行执行上述公式。LSU store 路径做单地址匹配；load 路径还会检查可能跨越边界的两个地址片段及有效字节条件，所以“一个 load 的断点命中”不能机械等同于只比较其起始字节地址。

---

## 6. BC 条件类型译码（取指/分支/load/store/特权级）

`regs_xx_bc[4:0]`（5 位 BC 字段）经过 `ct_had_bkpt.v:177-197` 译码成五类"断点类型"组合逻辑。这段是模块最密集的真值表，逐个看：

### 6.1 特权级先验

```verilog
assign user_mode = cp0_yy_priv_mode[1:0] == 2'b00;   // :174
assign priv_mode = !user_mode;                        // :175
```

`user_mode` 只精确识别编码 `2'b00`；`priv_mode=!user_mode` 把所有非零编码合为一类。也就是说，本模块不在 BC 层细分 S/M 等不同特权级，甚至不会单独排除保留编码。BC 也不是“若干正交 bit 可任意拼接”，而是下面这些**明确枚举值**：

| 访问语义 | 不限模式 | 仅 `priv_mode==0`（用户态） | 仅 `priv_mode==1`（任意非零模式） |
|----------|----------|-----------------------------|-----------------------------------|
| 普通指令命中 | `00001`、`00010` | `10001`、`10010` | `11001`、`11010` |
| 改流指令命中 | `00100` | `10100` | `11100` |
| 普通数据命中 | `00001`、`00011` | `10001`、`10011` | `11001`、`11011` |
| store 命中 | `00101` | `10101` | `11101` |
| load 命中 | `00110` | `10110` | `11110` |

其中 `00001` 等编码可同时落入普通指令和普通数据译码，这由 RTL 明确决定；软件不应仅按某一 bit 的直觉解释 BC。

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

这里的 `bc[2]` 只在上述三个精确编码中对应“改流”；不能推广成“只要 bit2=1 就是改流”，因为 `00101`/`00110` 分别表示 store/load。BC=0 不落入任何译码，同时顶层通常用 `|BC` 作为断点使能。

### 6.3 打一拍 + level two 汇总

这些组合译码结果先打一拍（`:198-216`，存进 `*_bkpt_ff`），与地址命中（level one 的 `inst_bkpt_occur`/`data_bkpt_occur`）相与，得到 level two 的 vld（`:218-223`）：

```verilog
assign inst_bkpt_vld = inst_bkpt_occur && rtu_had_xx_mbkpt_chgflow && changeflow_inst_bkpt_ff
                    || inst_bkpt_occur && normal_inst_bkpt_ff;             // :218-219

assign data_bkpt_vld = data_bkpt_occur && normal_data_bkpt_ff
                    || data_bkpt_occur && rtu_had_bkpt_data_st && st_data_bkpt_ff
                    || data_bkpt_occur &&!rtu_had_bkpt_data_st && load_data_bkpt_ff;  // :221-223
```

注意 store/load 的区分靠 RTU 给的 `rtu_had_bkpt_data_st`。五个 BC 译码无条件每拍寄存；`inst_bkpt_vld_f/data_bkpt_vld_f` 则只在 `rtu_had_inst_bkpt_inst_vld=1` 时更新，否则保持旧值而不是清零。这个保持语义是后续计数和请求时序的一部分，波形分析时必须同时看资格信号，不能把保持的 `*_vld_f=1` 单独当作每拍都有新命中。

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
- 每个满足 `bkpt_counter_dec_1` 的周期只减 1。
- 初值 `N>=1` 时，第 N 个合格周期会通过 `bkpt_counter_eq_0_raw` 提前看到“本拍减后为 0”，从而允许 raw 请求；初值为 0 时首个合格命中无需递减即可请求。

### 7.2 减 1 的条件

```verilog
assign bkpt_counter_dec_1 = (inst_bkpt_vld_f && !rtu_had_xx_split_inst || data_bkpt_vld_f) &&
                            ctrl_bkpt_en && rtu_yy_xx_retire0_normal &&
                           !bkpt_counter_eq_0 && !inst_bkpt_dbgreq && !rtu_yy_xx_dbgon;   // :261-268
```

含义：只有保存的 inst/data vld 至少一个有效、本断点使能、retire0 正常、计数器非 0、没有 `inst_bkpt_dbgreq`、且尚未处于 debug 时才减。源码注释 `:230-238` 仍描述“同时命中减 2”的旧设计意图，但当前数据通路只有 `bkpt_counter - 1`，也没有 `dec_2` 信号；inst 与 data 同周期同时有效仍然只使布尔条件为 1，计数器只减 1。文档必须以有效 RTL 为准。

### 7.3 请求生成

```verilog
assign bkpt_counter_eq_0 = bkpt_counter == 8'b0;       // :284
assign bkpt_counter_eq_1 = bkpt_counter == 8'b1;       // :285
assign bkpt_regs_mbc = bkpt_counter;                   // :287 回送 regs 供 JTAG 读出
```

`bkpt_counter_eq_0_raw = bkpt_counter_dec_1 ? bkpt_counter_eq_1 : bkpt_counter_eq_0`。它只预测“一次减 1 后是否为 0”：正在递减且当前等于 1时为真；不递减时则直接反映当前是否等于 0。这也再次证明当前没有减 2 逻辑。

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

raw 路径直接基于本拍 `inst_bkpt_vld/data_bkpt_vld`、raw enable 和预测后的计数结果，减少等待寄存版本的时延；同步路径基于保持寄存器并附加退休资格。这里能由 RTL确认的是两条路径的组合/寄存层次不同；“为了更容易精确停住”属于合理的微结构目的解释，不是模块接口本身给出的完成保证。最终是否进入 debug 仍取决于 `ct_had_ctrl` 和 RTU 的接受条件。

`bkpt_ctrl_xx_ack` 这个名字容易读反：它不是 HAD 发给 RTU 的 ack，而是把 RTU 的 `_inst_ack/_data_ack` 与“计数器当前为 0、本断点使能”相与后的组合结果，再供 HAD 控制/状态逻辑使用。应把它理解为“本断点实例观察到合格 RTU ack”。

---

## 9. split 指令与 data_bkpt_pending

C910 会把某些指令拆成内部操作。若 raw 数据断点请求出现时 `rtu_had_inst_split=1`，`ct_had_bkpt` 先置 `data_bkpt_pending`：

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

raw 请求落在非 split 周期时直接放行；落在 split 周期时置 pending。pending 路径的释放条件仅是后续某拍 `!rtu_had_inst_split && rtu_had_inst_bkpt_inst_vld`，RTL 没有保存 IID 或显式比对“仍是原来那条宏指令”，所以文档不能比 RTL 更强地宣称它精确等待“该 split 指令整体退休”。pending 只在 reset、flush 或进入 debug 时清除，释放请求本身不会清零；设计依赖该请求较快促成 debug 或 flush，观察波形时可能看到 pending 在接受前保持并重复参与组合请求。

---

## 10. non-IRV 断点 `ct_had_nirv_bkpt`

源码只使用 `non_irv`/`nirv` 命名，没有定义缩写展开。它结构比普通断点简单：本模块**不做地址比较、不做 BC 译码、不做 MBC 计数**，而是组合三条退休槽附带的 4 位断点元数据。该元数据上游如何产生，应回到 IFU/LSU/RTU 链路核查；不能因为本模块没有比较器就说它“没有地址条件”。

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

只有 NIRVEN 置 1且对应 A/B 断点 enable，`kbpt_occur` 才成立；同时普通 A/B 实例的 `occur` 被 `!NIRVEN` 屏蔽。因此从 HAD 本地过滤路径看，两者互斥。需要注意，`ctrl_bkpta_en/b_en` 仍由各自 BC 非零产生，所以 non-IRV 并非完全忽略 BC 寄存器：它不使用 BC 的类型译码，却仍借用“BC 非零”作为 A/B 总使能。

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

`non_irv_bkpt_vld` 一旦置 1会保持，直到 `rtu_yy_xx_flush` 或 `rtu_yy_xx_dbgon` 清除；而且 flush 的清零优先级高于同拍新 occur。`ct_had_ctrl` 直接把它送到 `had_rtu_non_irv_bkpt_dbgreq`，不经过普通断点的 MBC、SQC 和 FDB 过滤，并把它纳入 `had_cp0_xx_dbg` 请求表达式。这里的边界是：

- “进入 CP0 debug 请求/唤醒条件”不等于当拍已经唤醒并进入 debug；
- RTU 接受 non-IRV 请求仍要求 retire0 有效、非 split 等条件，并受最终 debug-disable 门控；
- flush 能清掉 pending 和已锁存 vld，所以不能称为绝对不可撤销或“命中即必停”；
- `nirv_bkpta` 记录 A/B 归属，A 为 1、B 为 0；若同拍 A/B 都命中，`nirv_bkpta_occur` 为 1，因此记录偏向 A。

## 本章小结

当前每个核心实例化 A、B 两个硬件断点，ID 能力字段也报告断点数为 2。一条 HAD 断点从地址比较到处理器停核要经过多层资格判断：HAD 保存 base、低 8 位 mask 和 RC 条件，IFU 或 LSU 在地址实际出现的流水级完成比较，并把命中元数据随指令或访存向后传递；`ct_had_bkpt` 再按照完整的 5 位 BC 编码筛选指令、改流、load、store 和特权模式。BC 是枚举真值表而不是五个可任意组合的独立开关。mask 位为 1 的地址位才参与相等比较，RC 决定采用相等或不等结果；只有低位连续的 mask 才自然表示一个对齐范围，稀疏 mask 对应的是离散匹配集合。

合格事件进入 MBC 后，每个周期最多使 8 位计数器递减一次，初值 N 在第 N 个合格事件上放行 raw 请求。raw 组合路径尽早送往 RTU，以便在精确指令边界停核；同步打拍路径则更新 HSR 等软件可读状态，两者不能混为同一个时序点。split 指令命中时，RTL 只保存 pending 和 A/B 归属，没有保存 IID，因此它表示等待后续合格边界，而不是完整跟踪一条宏指令。non-IRV 是 RTL 保留的独立路径名称，它在 NIRVEN 控制下与普通路径互斥，并绕过普通 BC、MBC、SQC 和 FDB 过滤，但仍受 flush、debug-disable 和 RTU 接受条件约束。由此可见，地址比较器命中只是候选事件，最终进入 debug 还必须经过 HAD 控制和 RTU 的精确边界处理，后续链路见 `03_had_ctrl_ddc.md`。
