# ct_ifu_icache_if — I-Cache 接口模块深度解析

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_icache_if.v`（832 行）
>
> 本文对该模块全部逻辑做逐段解读，并解释每个设计决策背后的原因。

---

## 目录

1. [模块概述](#1-模块概述)
2. [SRAM 物理结构](#2-sram-物理结构)
3. [Index 仲裁逻辑](#3-index-仲裁逻辑)
4. [Tag Array 控制逻辑](#4-tag-array-控制逻辑)
5. [Data Array 控制逻辑](#5-data-array-控制逻辑)
6. [Predecode Array 控制逻辑](#6-predecode-array-控制逻辑)
7. [数据输出路径](#7-数据输出路径)
8. [PMU 性能计数](#8-pmu-性能计数)
9. [完整信号汇总表](#9-完整信号汇总表)

---

## 1. 模块概述

### 1.1 在 IFU 流水线中的位置

```
                    ┌───────────────────────────────────────────────────┐
                    │              ct_ifu_icache_if                     │
                    │                                                   │
  pcgen ───index──▶ │                                                   │
  ifctrl──index──▶ │   ┌─────────────┐   ┌────────────────────────┐   │
  ipb ─────index──▶ │   │  Tag Array  │   │  Data Array0 (Way0)    │   │──▶ ifdp
  l1_refill──wr──▶  │   │  (59bit)    │   │  4 banks × 128bit      │   │──▶ ifctrl
                    │   └─────────────┘   ├────────────────────────┤   │──▶ ipb
                    │                     │  Data Array1 (Way1)    │   │
                    │                     │  4 banks × 128bit      │   │
                    │                     ├────────────────────────┤   │
                    │                     │  Predecode Array0/1    │   │
                    │                     │  32bit each            │   │
                    │                     └────────────────────────┘   │
                    └───────────────────────────────────────────────────┘
```

### 1.2 职责与边界

`ct_ifu_icache_if` 是 IFU 流水线 **IF 级**中，CPU 软逻辑与物理 SRAM 之间的**唯一接口层**。它不做任何决策，只做两件事：

1. **仲裁**：把来自多个来源（pcgen、ifctrl、l1_refill、ipb）的 SRAM 访问请求，按固定优先级排出唯一赢家，驱动 SRAM 的 index/cen_b/wen 引脚。
2. **路由**：把 SRAM 读出的数据分发给下游的多个消费者（ifdp、ifctrl、ipb）。

该模块**不存储流水级寄存器**，所有输出信号直接来自 SRAM 的异步读出端口（下一周期，SRAM 打一拍给出数据）。

### 1.3 为什么需要这一层？

如果各模块直接连 SRAM，就需要在 SRAM 端做复杂的仲裁逻辑，导致关键路径变长。将所有"谁要读/写 SRAM"的逻辑集中到 `icache_if` 中，有以下好处：
- 各模块只需提出请求，由 `icache_if` 保证互斥和优先级；
- SRAM 的 `cen_b`（Chip Enable，低有效）直接由此模块驱动，减少扇出；
- 方便统一施加门控时钟（ICG）节能逻辑。

---

## 2. SRAM 物理结构

### 2.1 五个 SRAM 实例一览

| 实例名 | 模块名 | 位宽 | 用途 |
|---|---|---|---|
| `x_ct_ifu_icache_tag_array` | `ct_ifu_icache_tag_array` | 59 位 | 存储两路的 valid+tag，以及 FIFO 替换位 |
| `x_ct_ifu_icache_data_array0` | `ct_ifu_icache_data_array0` | 128 位×4 bank | Way0 的指令数据 |
| `x_ct_ifu_icache_data_array1` | `ct_ifu_icache_data_array1` | 128 位×4 bank | Way1 的指令数据 |
| `x_ct_ifu_icache_predecd_array0` | `ct_ifu_icache_predecd_array0` | 32 位 | Way0 的预解码结果 |
| `x_ct_ifu_icache_predecd_array1` | `ct_ifu_icache_predecd_array1` | 32 位 | Way1 的预解码结果 |

C910 的 I-Cache 是**2-way set-associative**，Way0 对应 array0，Way1 对应 array1。

### 2.2 Tag Array 的 59 位格式

Tag Array 每个 entry 存储**一个 cache set** 的全部元数据：

```
  bit[58]       bit[57:29]              bit[28:0]
┌──────────┬────────────────────────┬────────────────────────┐
│ FIFO bit │   Way1: valid[57]+     │   Way0: valid[28]+     │
│  (1 bit) │   tag[56:29] (28 bit)  │   tag[27:0]  (28 bit)  │
└──────────┴────────────────────────┴────────────────────────┘
```

**为什么用一个 SRAM 同时存两路的 tag？**

因为 tag compare 时需要同时拿到两路的 tag，一次 SRAM 读就能取回 59 位全部内容，避免两次读 SRAM 带来的时序问题和功耗浪费。

**28 位 tag 从哪来？**

C910 物理地址 40 位（PA[39:0]）：
- PA[5:0]：cache line 内偏移（64 字节 cache line）
- PA[10:6]：index，寻址 cache set
- PA[38:11]：tag，共 28 位（`l1_refill_icache_if_ptag[27:0]`）

**FIFO bit 的作用：**

C910 I-Cache 的替换策略为简单的 2-way FIFO/伪 LRU。FIFO bit 记录当前 set 中"下一次应该替换哪一路"：
- `fifo_bit = 0`：下次替换 Way0（写入 array0）
- `fifo_bit = 1`：下次替换 Way1（写入 array1）

每次 refill 的最后一拍（`l1_refill_icache_if_last`），FIFO bit 翻转，指向另一路。

### 2.3 Data Array 的 4-bank 结构

每路的 Data Array 被分成 4 个 bank（bank0～bank3），每个 bank 128 位。4 个 bank 共同构成一个 512 位宽的读出数据路径，但在实际使用时：

- **顺序访问（sequential）**：通常只激活需要的 bank，其余保持关闭（`cen_b = 1`），节省功耗；
- **换流（change flow）**：PC 跳转，根据新 PC 所在的 cache line 位置精确激活某几个 bank。

每个 bank 128 位，对应 8 条 16 位半字（half-word）或 4 条 32 位指令。

**为什么是 128 位/bank？**

IP 级（`ct_ifu_ipb`）每次处理 128 位（8 个 half-word），这与 cache line 的 bank 粒度对齐，方便 IP 级按 bank 边界进行流水处理。

### 2.4 Predecode Array 的 32 位格式

每个 Predecode Array entry 存储对应 Data Array entry 中 8 个 half-word 的预解码结果：

```
bit[31:0]: {h1_pre_code[3:0], h2_pre_code[3:0], ..., h8_pre_code[3:0]}
```

每个 half-word 对应 4 位：`{ab_br, br, bry1, bry0}`（详见 07_precode.md）。

---

## 3. Index 仲裁逻辑

### 3.1 整体设计思路

SRAM 每个周期只能接受**一个** index，当多个模块同时发出请求时，必须仲裁。C910 采用**静态优先级**方案：

```
优先级（高 → 低）：
  1. ifctrl 特殊操作（cache 无效化写/复位）
  2. ifctrl 复位请求
  3. l1_refill 写操作
  4. ipb 读请求（prefetch）
  5. ifctrl 读操作（data/tag 单独读）
  6. pcgen 顺序/换流请求（最低）
```

**为什么 refill 优先级高于 pcgen？**

refill 的数据是处理 cache miss 的结果，尽快写入 SRAM 才能让流水线尽早恢复；而 pcgen 的请求在 refill 期间因 cache miss 已经停流水了，让出 SRAM 不影响性能。

### 3.2 两路选择器结构

```verilog
// 第 616-626 行
assign ifu_icache_index[15:0] = (icache_req_higher)
                              ? icache_index_higher[15:0]
                              : pcgen_icache_if_index[15:0];

assign icache_req_higher = ifctrl_icache_if_tag_req          ||
                           ifctrl_icache_if_reset_req        ||
                           l1_refill_icache_if_wr            ||
                           ipb_icache_if_req                 ||
                           ifctrl_icache_if_read_req_data0   ||
                           ifctrl_icache_if_read_req_data1   ||
                           ifctrl_icache_if_read_req_tag;
```

`icache_req_higher` 是"有任何高优先级请求"的汇总信号。只有当所有高优先级来源都无请求时，才把 pcgen 的 index 送到 SRAM。

**为什么这样设计而不用普通多路选择器？**

这里用了一个巧妙优化：**先用 OR 树判断"是否有高优先级"，再用一个 2:1 MUX 选择 index**，而不是用 4:1 MUX 直接选四路 index。这样可以：
1. 减少 MUX 级数，改善时序（pcgen 是关键路径上的信号）；
2. 把 pcgen 路径单独拎出来，便于综合工具做时序优化。

### 3.3 高优先级 index 的四路 case 选择

```verilog
// 第 636-655 行
assign icache_index_sel[3:0] = {ifctrl_icache_if_tag_req || ifctrl_icache_if_reset_req,
                                l1_refill_icache_if_wr,
                                ipb_icache_if_req,
                                icache_read_req};
always @(*)
begin
  case(icache_index_sel[3:0])
    4'b1000: icache_index_higher[15:0] = ifctrl_icache_if_index[15:0];
    4'b0100: icache_index_higher[15:0] = l1_refill_icache_if_index[15:0];
    4'b0010: icache_index_higher[15:0] = {ipb_icache_if_index[10:0], 5'b0};
    4'b0001: icache_index_higher[15:0] = ifctrl_icache_if_read_req_index[15:0];
    default: icache_index_higher[15:0] = {16{1'bx}};
  endcase
end
```

**index 位宽与来源说明：**

| 来源 | 输入位宽 | 说明 |
|---|---|---|
| `ifctrl_icache_if_index` | 39 位 | 取低 16 位，用于 cache 无效化时精确寻址 |
| `l1_refill_icache_if_index` | 39 位 | 取低 16 位，refill 的目标 cache set |
| `ipb_icache_if_index` | 34 位 | 取低 11 位，左移 5 位（cache line 内 byte 偏移），剩余高 5 位为 0 |
| `ifctrl_icache_if_read_req_index` | 39 位 | 取低 16 位，ifctrl 主动发起的读请求 |

**ipb index 为什么要左移 5 位？**

IPB 传来的 `ipb_icache_if_index[10:0]` 本质是 cache set 的编号（去掉了 byte 偏移部分）。SRAM 的 `ifu_icache_index` 是 16 位，包含了 PA[20:5]（其中 PA[10:5] 是 index bits，PA[20:11] 是高位地址用于 way prediction）。左移 5 位相当于把 set 编号放回到正确的地址位置。

**case default 为 `x`：**

`icache_index_sel` 在 `icache_req_higher=1` 时保证是 one-hot（四个请求不同时有效），default 对应全 0（无高优先级请求），此时 `icache_index_higher` 的值无关紧要（因为 2:1 MUX 选了 pcgen 路），设为 x 帮助综合工具优化逻辑。

---

## 4. Tag Array 控制逻辑

### 4.1 cen_b 生成（Chip Enable）

`cen_b` 低有效，为 0 时激活 SRAM。Tag Array 在以下 6 种情况下需要激活：

```verilog
// 第 266-283 行
assign ifu_icache_tag_cen_b =
  !(l1_refill_icache_if_wr &&
    (l1_refill_icache_if_first || l1_refill_icache_if_last) &&
    cp0_ifu_icache_en
   ) &&                              // 情况1: refill 写（first 或 last 拍）
  !(ifctrl_icache_if_tag_req
   ) &&                              // 情况2: ifctrl 的 tag 操作（无效化）
  !(pcgen_icache_if_chgflw &&
    (pcgen_icache_if_way_pred[1:0] != 2'b00) &&
    cp0_ifu_icache_en
   ) &&                              // 情况3: 换流读 tag（way_pred 非 0）
  !(pcgen_icache_if_seq_tag_req &&
    cp0_ifu_icache_en
   ) &&                              // 情况4: 顺序读 tag
  !(ipb_icache_if_req &&
    cp0_ifu_icache_en
   ) &&                              // 情况5: ipb 读 tag（prefetch 后比较）
  !ifctrl_icache_if_read_req_tag;   // 情况6: ifctrl 主动读 tag
```

**情况1 中为什么 refill 只在 first 和 last 激活 tag array？**

这是一个关键设计决策。Refill 可能需要多个周期（一个 cache line 传输多拍），但 tag 只需要写一次（最后一拍写 valid=1）。`first` 拍写 tag 的目的是先把 valid 清 0，防止 refill 中间过程中该 cache line 被意外命中（详见 4.3 节）。

**情况3 中 `way_pred != 2'b00` 的含义：**

`pcgen_icache_if_way_pred[1:0]` 是 way prediction 信号：
- `2'b00`：无预测（cache 关闭或无有效预测），无需读 tag（读 tag 也没意义）
- `2'b01`：预测命中 Way0
- `2'b10`：预测命中 Way1
- `2'b11`：两路都激活（refill 时用）

当 way_pred 为 0 时，cache 根本没有用，跳过 tag array 读取节省功耗。

### 4.2 wen 编码（Write Enable）

Tag array 的写使能是 3 位：`ifu_icache_tag_wen[2:0]`

```
ifu_icache_tag_wen[2]   → FIFO bit 的写使能
ifu_icache_tag_wen[1]   → Way1 的写使能
ifu_icache_tag_wen[0]   → Way0 的写使能
```

**FIFO bit wen（bit[2]）的逻辑：**

```verilog
// 第 305-317 行
always @(*)
begin
  if(ifctrl_icache_if_inv_on)
    ifu_icache_tag_wen[2] = ifctrl_icache_if_tag_wen[2];  // inv 时按 ifctrl 指示
  else if(l1_refill_icache_if_wr && l1_refill_icache_if_last)
    ifu_icache_tag_wen[2] = 1'b0;  // refill last：不更新 FIFO bit（FIFO 在 din 中改变）
  else
    ifu_icache_tag_wen[2] = 1'b1;  // 默认不写 FIFO bit（高有效的 wen 意味着不写）
end
```

注意：这个 SRAM 的 wen 是**高有效（active-high）**写使能。`wen[2]=1` 表示**不写** FIFO bit，`wen[2]=0` 表示**写** FIFO bit。

refill last 时 `wen[2]=0`，允许更新 FIFO bit。refill first 时 `wen[2]=1`，保持 FIFO bit 不变（因为 first 拍只需清 valid，不需要翻 FIFO）。

**Way wen（bit[1:0]）的逻辑：**

```verilog
// 第 320-335 行
always @(*)
begin
  if(ifctrl_icache_if_inv_on)
    ifu_icache_tag_wen[1:0] = ifctrl_icache_if_tag_wen[1:0];  // inv 按 ifctrl 指示
  else if(l1_refill_icache_if_wr &&
           (l1_refill_icache_if_first || l1_refill_icache_if_last))
    ifu_icache_tag_wen[1:0] = {!fifo_bit, fifo_bit};  // 只写目标 way
  else
    ifu_icache_tag_wen[1:0] = 2'b11;  // 非写操作，两路都不写
end
```

`{!fifo_bit, fifo_bit}` 的解码：
- `fifo_bit = 0`（替换 Way0）：`wen[1:0] = 2'b10`，即 wen[1]=1（Way1 不写），wen[0]=0（Way0 写）
- `fifo_bit = 1`（替换 Way1）：`wen[1:0] = 2'b01`，即 wen[1]=0（Way1 写），wen[0]=1（Way0 不写）

**为什么这样编码？**

高有效 wen 中，`1` 表示不写，`0` 表示写。因此 `{!fifo_bit, fifo_bit}` 中恰好有一位为 0，指向应该被替换的那一路。FIFO bit 为 0 替换 way0，为 1 替换 way1，编码非常简洁。

### 4.3 Refill 写入时序：防止伪命中的设计

这是一个精妙的设计，理解它需要考虑 refill 中途的场景：

```
时序图：
Cycle N:   refill first（cache line 第一拍数据到达）
  → 写 tag：valid = 0，tag = 0（清零）
  → 写 data：第一个 128 位数据

Cycle N+1~M-1: refill 中间拍（只写 data，不写 tag）

Cycle M:   refill last（最后一拍数据到达）
  → 写 tag：valid = 1，tag = ptag（设置有效，写真实 tag）
  → 写 data：最后一个 128 位数据
  → FIFO bit 翻转
```

**为什么 first 拍要先写 tag（valid=0）？**

如果不写，假设该 cache set 之前有旧数据（valid=1，旧 tag），在 refill 期间（N 到 M-1 之间），若有另一个 CPU 请求恰好访问这个 cache set 且 tag 匹配旧 tag，就会命中旧的（部分更新的）数据，导致读到脏数据！

通过在 first 拍把 valid 清 0，保证了：整个 refill 过程中，该 way 对外呈现为"invalid"，任何请求都不会命中它，直到 last 拍写完数据后才让它重新有效。

```verilog
// 第 350-357 行
assign tag_fifo_din     = (ifctrl_icache_if_inv_on) ? ifctrl_icache_if_inv_fifo : !fifo_bit;
assign tag_valid_din    = l1_refill_icache_if_last;  // 只有 last 拍，valid 才为 1
assign tag_pc_din[27:0] = (ifctrl_icache_if_inv_on || l1_refill_icache_if_first)
                          ? 28'b0          // inv 或 first：tag 清零
                          : l1_refill_icache_if_ptag[27:0];  // last：写真实 tag
```

`tag_valid_din = l1_refill_icache_if_last`：这意味着当写入的是 first 拍时，`valid_din = 0`；只有 last 拍时，`valid_din = 1`。

### 4.4 tag_din 格式组装

```verilog
// 第 354-357 行
assign ifu_icache_tag_din[58:0] = {tag_fifo_din,
                                   tag_valid_din, tag_pc_din[27:0],
                                   tag_valid_din, tag_pc_din[27:0]};
```

注意两路（Way0 和 Way1）写入**相同的 `tag_valid_din` 和 `tag_pc_din`**。这不是 bug——因为每次 refill 只有一路的 wen 为 0（有效），另一路的 wen 为 1（无效，写入被屏蔽）。所以 din 中同时准备好两路的数据，但 wen 保证只有目标路被实际写入。

---

## 5. Data Array 控制逻辑

### 5.1 way_pred 决定激活哪路

```verilog
// 第 370-372 行
assign icache_way_pred[1:0] = (l1_refill_icache_if_wr) ? 2'b11 : pcgen_icache_if_way_pred[1:0];
```

- **refill 写**时：强制 `way_pred = 2'b11`（两路都要激活，因为要写入 data，但 wen 保证只写一路）——等等，看 cen_b 逻辑会发现，实际上只有目标 way 的 cen_b 会被激活。
- **正常读**时：使用 pcgen 传来的预测值。

实际上，`way_pred[0]` 控制 array0（Way0）的 cen_b，`way_pred[1]` 控制 array1（Way1）的 cen_b，两者独立控制。

### 5.2 Bank 精确激活：节能设计

每路 data array 有 4 个 bank，各 bank 有独立的 `cen_b`。以 array0/bank0 为例：

```verilog
// 第 374-384 行
assign ifu_icache_data_array0_bank0_cen_b = (
    !(l1_refill_icache_if_wr && !fifo_bit) &&  // 不是写 way0
    !(pcgen_icache_if_chgflw_bank0        ) &&  // 不是换流且需要 bank0
    !(pcgen_icache_if_seq_data_req        )     // 不是顺序读
    || !(cp0_ifu_icache_en && icache_way_pred[0])  // 或 way0 未被预测
   ) &&
   !ifctrl_icache_if_read_req_data0 &&  // 不是 ifctrl 强制读 way0
   !icache_reset_inv;                   // 不是复位无效化
```

注意括号优先级：前面大括号内是 `(A || B || C || !D)`，含义是：

- 若 `(A || B || C)` 为真（即有某个读/写需求），**且** `D`（即 `cp0_ifu_icache_en && way_pred[0]`）为真，则 `cen_b = 0`（激活）；
- 若 `A || B || C` 都为假，或 D 为假，则 `cen_b = 1`（不激活）。
- 最后还有两个强制激活条件（ifctrl 读请求、复位无效化）。

**各 bank 激活条件的差异：**

| 条件 | bank0 | bank1 | bank2 | bank3 |
|---|---|---|---|---|
| refill 写 | 全部激活（写整个 cache line） | 同左 | 同左 | 同左 |
| 换流（chgflw） | `chgflw_bank0` | `chgflw_bank1` | `chgflw_bank2` | `chgflw_bank3` |
| 顺序读（seq） | 全部激活 | 同左 | 同左 | 同左 |

`chgflw_bank0~3` 是 pcgen 提供的精确 bank 激活信号。当 PC 跳转到某个地址时，pcgen 知道新 PC 落在哪个 bank，只需激活该 bank 及后续 bank，其余 bank 保持关闭，显著节省功耗。

**为什么顺序读要激活全部 4 个 bank？**

顺序取指时，IP 级需要处理连续的 128 位数据，整个 cache line 都可能被访问，因此必须把所有 bank 都激活。

### 5.3 Way0 vs Way1 的 cen_b 差异

array0（Way0）与 array1（Way1）的 cen_b 几乎相同，只有一处不同：

- **array0**：refill 写条件为 `l1_refill_icache_if_wr && !fifo_bit`（FIFO bit=0，替换 Way0）
- **array1**：refill 写条件为 `l1_refill_icache_if_wr && fifo_bit`（FIFO bit=1，替换 Way1）
- **array0**：way_pred 检查 `icache_way_pred[0]`
- **array1**：way_pred 检查 `icache_way_pred[1]`

这保证了 refill 只写入目标 way，预测读也只激活预测命中的 way。

### 5.4 Write Enable（wen_b，低有效）

```verilog
// 第 535-540 行
assign ifu_icache_data_array0_wen_b = !(l1_refill_icache_if_wr && !fifo_bit) &&
                                      !icache_reset_inv;
assign ifu_icache_data_array1_wen_b = !(l1_refill_icache_if_wr && fifo_bit) &&
                                      !icache_reset_inv;
```

Data array 的 wen_b 是**单比特**（不像 tag 那样 per-way），整个 128 位要么全写要么不写。写使能条件：
1. **refill 写**：由 fifo_bit 决定写哪路；
2. **复位无效化**：`icache_reset_inv = ifctrl_icache_if_reset_req`，两路都写（写入 0）。

### 5.5 写数据（din）

```verilog
// 第 545-546 行
assign ifu_icache_data_array0_din[127:0] = (icache_reset_inv) ? 128'b0 : l1_refill_icache_if_inst_data[127:0];
assign ifu_icache_data_array1_din[127:0] = (icache_reset_inv) ? 128'b0 : l1_refill_icache_if_inst_data[127:0];
```

复位时写 0，正常 refill 时写从 L2 传来的 128 位指令数据。两路写入相同的 din，由 wen_b 决定实际写哪路。

---

## 6. Predecode Array 控制逻辑

### 6.1 与 Data Array 的对应关系

Predecode Array 与 Data Array **严格并行操作**：
- 读：和 Data Array 同时读（cen_b 逻辑相同，除了不分 bank）；
- 写：随 Data Array refill 时同步写入（wen_b 直接复用 data array 的 wen_b）。

```verilog
// 第 804-810 行（predecd_array0 实例化）
ct_ifu_icache_predecd_array0  x_ct_ifu_icache_predecd_array0 (
  .ifu_icache_data_array0_wen_b (ifu_icache_data_array0_wen_b),  // 直接复用 data wen
  .ifu_icache_predecd_array0_wen_b (ifu_icache_predecd_array0_wen_b),
  ...
);
```

### 6.2 Predecode Array 的 cen_b

```verilog
// 第 551-568 行
assign ifu_icache_predecd_array0_cen_b = (
    !(l1_refill_icache_if_wr && !fifo_bit) &&
    !(pcgen_icache_if_chgflw            ) &&  // 注意：不区分 bank！
    !(pcgen_icache_if_seq_data_req      )
    || !(cp0_ifu_icache_en && icache_way_pred[0])
   ) && !icache_reset_inv;
```

与 Data Array 的区别：换流条件使用 `pcgen_icache_if_chgflw`（整体换流标志），而不是 `chgflw_bank0~3`（逐 bank 标志）。

**为什么 Predecode Array 不需要 bank 精确激活？**

Predecode Array 整个 entry 只有 32 位（远小于 data 的 4×128=512 位），即使全部激活功耗也很低，不值得为此引入 bank 拆分的复杂度。而 Data Array 的 4 个 bank 合计 512 位，bank 精确激活节省的功耗是可观的。

### 6.3 为什么在 IP 级前就做预解码？

传统处理器在 ID（译码）级才解析指令类型，此时分支预测已经晚了一拍。C910 的解决方案是：

1. **ct_ifu_precode** 在 refill 期间（或第一次取指时）对指令数据做轻量级预解码；
2. 预解码结果和指令数据一同缓存在 Predecode Array 中；
3. 在 IP 级（`ct_ifu_ipb`），预解码结果和指令数据**同时读出**，IP 级可以立即知道某条 half-word 是否为分支指令，无需等待完整的指令解码。

这相当于把"分支类型识别"的时序压力从 IP 级移到了 refill 路径（非关键路径），减少了流水线气泡。

---

## 7. 数据输出路径

### 7.1 tag_dout 的分解

SRAM 读出 59 位 tag 数据后，立即被分解分发：

```verilog
// 第 662-668 行
assign icache_if_ifdp_tag_data0[28:0]   = icache_ifu_tag_dout[28:0];    // Way0 tag+valid
assign icache_if_ifdp_tag_data1[28:0]   = icache_ifu_tag_dout[57:29];   // Way1 tag+valid
assign icache_if_ifdp_fifo              = icache_ifu_tag_dout[58];       // FIFO bit
assign icache_if_ifctrl_tag_data0[28:0] = icache_ifu_tag_dout[28:0];    // Way0（给 ifctrl）
assign icache_if_ifctrl_tag_data1[28:0] = icache_ifu_tag_dout[57:29];   // Way1（给 ifctrl）
```

**29 位 tag 数据格式：**

```
bit[28]    : valid bit
bit[27:0]  : tag（对应 PA[38:11]）
```

### 7.2 各下游模块接收的信号

| 下游模块 | 接收的信号 | 用途 |
|---|---|---|
| **ifdp** | tag_data0/1、fifo、inst_data0/1、precode0/1 | IF 级数据通路，做 tag compare，缓存指令数据和预解码结果 |
| **ifctrl** | tag_data0/1、inst_data0/1 | IF 级控制，tag compare 后决定是否 hit；数据用于 refill 后读回验证 |
| **ipb** | tag_data0/1 | Prefetch buffer，比较 tag 判断 prefetch 是否命中 |

**为什么 ifctrl 和 ifdp 接收相同的 tag 数据？**

`ifdp` 是数据通路，负责 tag 数据的流水传递；`ifctrl` 是控制逻辑，需要立即使用 tag 数据做判断（如命中/miss 判断）。两者各自有独立的输出线，避免控制逻辑和数据通路互相干扰时序。

### 7.3 precode 的输出

```verilog
// 第 673-677 行
assign icache_if_ifdp_precode0[31:0] = icache_ifu_predecd_array0_dout[31:0];
assign icache_if_ifdp_inst_data0[127:0] = icache_ifu_data_array0_dout[127:0];
assign icache_if_ifdp_precode1[31:0] = icache_ifu_predecd_array1_dout[31:0];
assign icache_if_ifdp_inst_data1[127:0] = icache_ifu_data_array1_dout[127:0];
```

预解码结果只送到 `ifdp`，不送给 `ifctrl` 或 `ipb`（这两个不需要预解码信息）。

---

## 8. PMU 性能计数

### 8.1 计数器信号

C910 内置硬件性能监测单元（HPCP，Hardware Performance Counter），`icache_if` 提供两个性能事件：

- `ifu_hpcp_icache_access`：I-Cache 访问次数（每次 pcgen 发出 data req 或 chgflw）
- `ifu_hpcp_icache_miss`：I-Cache miss 次数（由 `ifu_hpcp_icache_miss_pre` 在外部计算后传入）

### 8.2 access 事件的定义

```verilog
// 第 697 行
assign ifu_hpcp_icache_access_pre = (pcgen_icache_if_seq_data_req || pcgen_icache_if_chgflw) && cp0_ifu_icache_en;
```

**为什么只统计 pcgen 的请求，不统计 refill 或 ifctrl 的请求？**

性能计数的语义是"CPU 主动发起的取指次数"。refill 是 miss 处理的一部分，ifctrl 的读是 cache 管理操作，都不属于"正常取指"。统计 pcgen 的 seq_data_req 和 chgflw 能准确反映取指吞吐量。

### 8.3 寄存器采样与门控时钟

```verilog
// 第 700-741 行
gated_clk_cell x_hpcp_clk (
  .local_en (hpcp_clk_en), ...
);
assign hpcp_clk_en = cp0_ifu_icache_en && hpcp_ifu_cnt_en;

always @(posedge hpcp_clk or negedge cpurst_b) begin
  if(!cpurst_b) begin
    ifu_hpcp_icache_access_reg <= 1'b0;
    ifu_hpcp_icache_miss_reg   <= 1'b0;
  end else if(cp0_ifu_icache_en && hpcp_ifu_cnt_en) begin
    ifu_hpcp_icache_access_reg <= ifu_hpcp_icache_access_pre;
    ifu_hpcp_icache_miss_reg   <= ifu_hpcp_icache_miss_pre;
  end
end
```

PMU 寄存器使用独立的门控时钟 `hpcp_clk`，只有在 cache 使能且 PMU 计数使能（`hpcp_ifu_cnt_en`）时才工作，其他时间关闭时钟节省功耗。这是一个典型的"条件采样"模式：`_pre` 信号是组合逻辑，`_reg` 信号是打拍后送给 HPCP 的稳定值。

---

## 9. 完整信号汇总表

### 9.1 输入信号

| 信号名 | 位宽 | 来源 | 含义 |
|---|---|---|---|
| `cp0_ifu_icache_en` | 1 | CP0 | I-Cache 全局使能 |
| `cpurst_b` | 1 | 复位 | 异步复位（低有效） |
| `forever_cpuclk` | 1 | 时钟 | 主时钟 |
| `pcgen_icache_if_index` | 16 | pcgen | 顺序/换流时的 cache index |
| `pcgen_icache_if_chgflw` | 1 | pcgen | 换流请求 |
| `pcgen_icache_if_chgflw_bank0~3` | 1×4 | pcgen | 换流时各 bank 精确激活信号 |
| `pcgen_icache_if_chgflw_short` | 1 | pcgen | 换流门控时钟使能（提前半周期） |
| `pcgen_icache_if_seq_data_req` | 1 | pcgen | 顺序 data 读请求 |
| `pcgen_icache_if_seq_data_req_short` | 1 | pcgen | 顺序 data 门控使能 |
| `pcgen_icache_if_seq_tag_req` | 1 | pcgen | 顺序 tag 读请求 |
| `pcgen_icache_if_way_pred` | 2 | pcgen | Way 预测（bit0=way0, bit1=way1） |
| `ifctrl_icache_if_index` | 39 | ifctrl | ifctrl tag 操作的 index |
| `ifctrl_icache_if_tag_req` | 1 | ifctrl | ifctrl tag 读写请求 |
| `ifctrl_icache_if_tag_wen` | 3 | ifctrl | ifctrl 的 tag wen（inv 时使用） |
| `ifctrl_icache_if_inv_on` | 1 | ifctrl | cache 无效化进行中 |
| `ifctrl_icache_if_inv_fifo` | 1 | ifctrl | inv 时写入的 FIFO bit |
| `ifctrl_icache_if_reset_req` | 1 | ifctrl | 复位无效化请求 |
| `ifctrl_icache_if_read_req_data0` | 1 | ifctrl | 强制读 way0 data |
| `ifctrl_icache_if_read_req_data1` | 1 | ifctrl | 强制读 way1 data |
| `ifctrl_icache_if_read_req_tag` | 1 | ifctrl | 强制读 tag |
| `ifctrl_icache_if_read_req_index` | 39 | ifctrl | 强制读的 index |
| `l1_refill_icache_if_wr` | 1 | l1_refill | refill 写使能 |
| `l1_refill_icache_if_first` | 1 | l1_refill | refill 第一拍 |
| `l1_refill_icache_if_last` | 1 | l1_refill | refill 最后一拍 |
| `l1_refill_icache_if_index` | 39 | l1_refill | refill 目标 index |
| `l1_refill_icache_if_inst_data` | 128 | l1_refill | refill 的指令数据 |
| `l1_refill_icache_if_pre_code` | 32 | l1_refill | refill 的预解码数据 |
| `l1_refill_icache_if_ptag` | 28 | l1_refill | refill 的物理 tag |
| `l1_refill_icache_if_fifo` | 1 | l1_refill | 本次 refill 写哪路（FIFO bit） |
| `ipb_icache_if_req` | 1 | ipb | prefetch buffer 读 tag 请求 |
| `ipb_icache_if_index` | 34 | ipb | prefetch 的 index |

### 9.2 输出信号

| 信号名 | 位宽 | 去向 | 含义 |
|---|---|---|---|
| `icache_if_ifdp_tag_data0` | 29 | ifdp | Way0 tag 读出（valid+tag） |
| `icache_if_ifdp_tag_data1` | 29 | ifdp | Way1 tag 读出 |
| `icache_if_ifdp_fifo` | 1 | ifdp | FIFO bit 读出 |
| `icache_if_ifdp_inst_data0` | 128 | ifdp | Way0 指令数据读出 |
| `icache_if_ifdp_inst_data1` | 128 | ifdp | Way1 指令数据读出 |
| `icache_if_ifdp_precode0` | 32 | ifdp | Way0 预解码结果读出 |
| `icache_if_ifdp_precode1` | 32 | ifdp | Way1 预解码结果读出 |
| `icache_if_ifctrl_tag_data0` | 29 | ifctrl | Way0 tag（用于命中判断） |
| `icache_if_ifctrl_tag_data1` | 29 | ifctrl | Way1 tag（用于命中判断） |
| `icache_if_ifctrl_inst_data0` | 128 | ifctrl | Way0 指令数据（验证用） |
| `icache_if_ifctrl_inst_data1` | 128 | ifctrl | Way1 指令数据（验证用） |
| `icache_if_ipb_tag_data0` | 29 | ipb | Way0 tag（prefetch 命中检查） |
| `icache_if_ipb_tag_data1` | 29 | ipb | Way1 tag（prefetch 命中检查） |
| `ifu_hpcp_icache_access` | 1 | HPCP | cache 访问事件（打拍后） |
| `ifu_hpcp_icache_miss` | 1 | HPCP | cache miss 事件（打拍后） |

---

## 附录：关键设计决策汇总

| 设计决策 | 原因 |
|---|---|
| Tag array 59 位存两路 | 一次读出完成 tag compare，避免两次 SRAM 读 |
| Refill first 写 valid=0 | 防止 refill 中途被"伪命中"读到脏数据 |
| FIFO 替换位编码为 `{!fifo, fifo}` | 直接 one-hot 驱动 way wen，无需额外译码 |
| Data array 分 4 bank，精确激活 | 顺序取指时省去不需要的 bank 功耗 |
| Predecode array 不分 bank | 32 位功耗极低，分 bank 增加复杂度得不偿失 |
| 两路 MUX + OR 树的 index 选择结构 | pcgen 是关键路径，单独拉出来让综合工具优化 |
| PMU 使用独立门控时钟 | 非 PMU 使用场景完全关闭该寄存器的时钟，省功耗 |
