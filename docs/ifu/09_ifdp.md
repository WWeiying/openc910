# 09 ct_ifu_ifdp —— IF 级数据通路详解

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_ifdp.v`（2085 行）

---

## 1. 模块概述

`ct_ifu_ifdp` 是 C910 IFU 的 **IF 级数据通路（Data Path）**，与 `ct_ifu_ifctrl`（控制通路）构成 IF 流水级的完整实现。

ifdp 的核心工作是：
1. 接收来自 ICache 或 L1 Refill 的 128 位、16 字节取指块，将其分解为 8 个 16 位 half-word（H1~H8）
2. 同时对每个 half-word 提供预解码信息（precode）
3. 进行 Tag 比较，判断 cache 是否命中（Way0/Way1）
4. 接收常规 BTB（相对 L0 BTB 也可称为 L1 BTB）和 L0 BTB 的预测信息，打拍传给 IP 级
5. 处理 VPC one-hot 编码、BRY 指令边界和直接控制流预解码信息
6. 传递异常信息（acc_err、pgflt）
7. 在 `ifctrl_ifdp_pipedown` 触发时，将所有 IF 级结果寄存到 IP 级寄存器

```
         ICache/Refill                   BTB/L0 BTB
              │                               │
              ▼                               ▼
    ┌─────────────────────────────────────────────┐
    │               ct_ifu_ifdp                    │
    │                                              │
    │  inst_data → half-word 分解 (H1~H8)          │
    │  tag_data  → tag 比较 (Way0/Way1 hit)        │
    │  precode   → BRY 分支预解码                  │
    │  vpc[2:0]  → one-hot 编码                    │
    │  BTB data  → 打拍寄存                        │
    │  MMU PA    → 异常信息                        │
    └───────────────────┬─────────────────────────┘
                        │ pipedown
                        ▼
                    IP 级 (ipdp/ipctrl)
```

---

## 2. 时钟门控设计

```verilog
// 行 846-864
gated_clk_cell  x_ifdp_clk (
  .clk_in             (forever_cpuclk),
  .clk_out            (ifdp_clk),
  .local_en           (ifdp_clk_en),
  ...
);
assign ifdp_clk_en = ipctrl_ifdp_gateclk_en;
```

`ifdp_clk` 是 IF→IP 主流水寄存器的工作时钟，而不是本模块所有寄存器唯一的时钟；异常寄存器和 I-Cache 配置对齐寄存器还分别使用 `ifdp_spe_clk`、`icache_flop_clk`。其本地使能来自 `ipctrl_ifdp_gateclk_en`，表明 IP 级会参与决定这些流水寄存器何时需要更新或维持可更新状态。

还需结合通用 `gated_clk_cell` 的完整门控条件理解：

```text
门控请求 = (global_en && (module_en || local_en)) || external_en
```

这里 `module_en` 接 `cp0_ifu_icg_en`，`external_en` 接扫描使能。因此，`ipctrl_ifdp_gateclk_en=0` 并不单独构成“时钟必然停止”的充分条件；模块级强制使能和扫描模式均可打开时钟。更重要的是，未定义 `C910_USE_TSMC28_ICG` 时，通用门控单元的 RTL 分支直接令 `clk_out=clk_in`，功能仿真中时钟不会真正被截断。文档所说的门控关系描述的是控制协议；实际门控单元、功耗收益和时序效果还要结合编译宏、综合网表与功耗分析确认。

---

## 3. 指令数据来源选择

```verilog
// 行 874-887
// Way0：可以来自 cache 或 refill
assign ifdp_inst_data0[127:0] = (l1_refill_ifdp_refill_on)
                              ? l1_refill_ifdp_inst_data[127:0]
                              : icache_if_ifdp_inst_data0[127:0];

// Way1：只来自 cache；refill 旁路统一映射到逻辑 Way0 通道
assign ifdp_inst_data1[127:0] = icache_if_ifdp_inst_data1[127:0];

// precode 同理
assign ifdp_inst_precode0[31:0] = (l1_refill_ifdp_refill_on)
                                 ? l1_refill_ifdp_precode[31:0]
                                 : icache_if_ifdp_precode0[31:0];
assign ifdp_inst_precode1[31:0] = icache_if_ifdp_precode1[31:0];
```

**这里的“Way0 通道”不等于“物理回填到 I-Cache Way0”。**

当 `l1_refill_ifdp_refill_on=1` 时，refill 返回的数据、precode 和 tag 被统一送入 IFDP 的**逻辑 Way0 处理通道**，同时所有 Way1 分段命中结果被强制为 0。这样，后续 IP 级仍可复用原有的“两路候选 + 命中选择”接口，不必另加第三条 refill 数据通路。

物理 I-Cache 最终写 Way0 还是 Way1，由 refill/替换控制逻辑选择，不能从 `ifdp_inst_data0` 这个信号名反推。该旁路复用只是完整 miss/refill 协议中的一环；数据一致性还依赖 refill 状态机、返回有效、tag/valid 写入以及流水 cancel/stall 控制共同保证。

---

## 4. 128 位数据分解为 8 个 Half-Word

C910 IFU 每次从 ICache 取出 128 位（16 字节）数据，对应 8 个 16 位（2 字节）的 half-word，编号 H1（最高位）到 H8（最低位）：

```verilog
// 行 893-946（Way1 为例，Way0 同理）
assign half1_inst_high_way1[13:0] = ifdp_inst_data1[127:114];  // H1 高 14 位
assign half1_inst_low_way1[1:0]   = ifdp_inst_data1[113:112];  // H1 低 2 位
assign half1_precode_way1[3:0]    = ifdp_inst_precode1[31:28]; // H1 预解码

assign half2_inst_high_way1[13:0] = ifdp_inst_data1[111: 98];
assign half2_inst_low_way1[1:0]   = ifdp_inst_data1[ 97: 96];
assign half2_precode_way1[3:0]    = ifdp_inst_precode1[27:24];
...
assign half8_inst_high_way1[13:0] = ifdp_inst_data1[ 15:  2];
assign half8_inst_low_way1[1:0]   = ifdp_inst_data1[  1:  0];
assign half8_precode_way1[3:0]    = ifdp_inst_precode1[3 : 0];
```

### 4.1 Half-Word 的内部结构

每个 16 位 half-word 被拆分为两部分：

| 字段 | 位宽 | 含义 |
|---|---|---|
| `inst_high` | 14 位 | half-word 的高 14 位（bit[15:2]） |
| `inst_low` | 2 位 | half-word 的低 2 位（bit[1:0]） |
| `precode` | 4 位 | I-Cache 预先存储的预解码结果 |

**为什么要把 16 位拆成 14+2？**

RTL 直接表明低 2 位与高 14 位通过不同信号传递。RISC-V 中，低 2 位不是 `11` 的 half-word 可作为 16 位压缩指令，低 2 位为 `11` 时则至少需要继续取得后续 half-word 来组成更长指令。因此，单独暴露低 2 位可让 IP 级先做长度和边界判断，再组织完整指令。

这种拆分具有减少长度判断路径输入位数的结构优势，可以理解为面向前端边界识别的实现方式；它是否缩短了芯片上的关键路径、缩短多少，需要由综合和 STA 结果确认，不能仅从 RTL 连线得出频率结论。

### 4.2 Precode 字段含义

每个 half-word 对应 4 位 precode，来自 ICache 预解码器（在 cache 填充时预计算好存入）：

| precode 位 | 含义（每个 half-word 对应） |
|---|---|
| bit[3]（`ab_br`） | 直接无条件跳转子集；当前 precode 方程只识别 `JAL` 和 `C.J` |
| bit[2]（`br`） | 直接控制流候选；覆盖条件分支、`JAL` 和 `C.J` |
| bit[1]（`b1_bry`） | 假设 H1 是新指令起点时，该 half-word 是否为合法指令起点 |
| bit[0]（`b0_bry`） | 假设 H1 不是新指令起点时，该 half-word 是否为合法指令起点 |

IP 级先用 BRY 位确定指令边界，再把 `br`/`ab_br` 限定到合法起点。由于 `br XOR ab_br` 恰好留下条件分支，BHT 预测 taken 时可选择 `br` 集合，预测 not-taken 时仍用 `ab_br` 让直接无条件跳转改流。JALR/return 等间接控制流不在这两个 precode 方程中，由 Ind-BTB/RAS 等路径处理。

---

## 5. Tag 比较逻辑（VIPT Cache 命中判断）

### 5.1 分段比较设计

C910 I-Cache 采用 VIPT（虚拟索引、物理标记）方式，tag 字段使用物理地址信息。RTL 将 tag 比较拆分为 4 段并行进行：

```verilog
// 行 1228-1275（Way0 为例）
// 段1：bit[28:24]，包含 valid 位（bit[28]）
assign ifdp_icache_way0_28_24_hit = (l1_refill_ifdp_refill_on)
                                  ? refill_tag_28_24_hit
                                  : cp0_ifu_icache_en_flop &&
                                    icache_tag_way0_28_24_hit;
assign refill_tag_28_24_hit      = (l1_refill_ifdp_tag_data[28:24] == {1'b1, mmu_ifu_pa[27:24]});
assign icache_tag_way0_28_24_hit = (icache_if_ifdp_tag_data0[28:24] == {1'b1, mmu_ifu_pa[27:24]});

// 段2：bit[23:16]
assign ifdp_icache_way0_23_16_hit = ...;
assign icache_tag_way0_23_16_hit  = (icache_if_ifdp_tag_data0[23:16] == mmu_ifu_pa[23:16]);

// 段3：bit[15:8]
assign ifdp_icache_way0_15_8_hit  = ...;
assign icache_tag_way0_15_8_hit   = (icache_if_ifdp_tag_data0[15:8] == mmu_ifu_pa[15:8]);

// 段4：bit[7:0]
assign ifdp_icache_way0_7_0_hit   = ...;
assign icache_tag_way0_7_0_hit    = (icache_if_ifdp_tag_data0[7:0] == mmu_ifu_pa[7:0]);
```

### 5.2 Tag 字段布局

```
tag_data[28:0] 字段分配：

bit[28]    = valid 位（1 = cache line 有效）
bit[27:0]  = 物理地址标记 = mmu_ifu_pa[27:0]

完整命中条件 = tag[28] == 1 && tag[27:0] == pa[27:0]
```

分段比较后，IP 级（ipctrl）将 4 段结果进行 AND，得到最终命中结论。

**怎样理解分段比较？**

tag 比较的数据路径是：MMU 给出 `mmu_ifu_pa[27:0]`，IFDP 将其与 I-Cache SRAM 给出的 tag/valid 字段比较。RTL 没有先产生一个完整的 29 位命中结果，而是分别生成 `[28:24]`、`[23:16]`、`[15:8]`、`[7:0]` 四段比较结果并寄存，IPCTRL 再组合这些结果。

从结构上看，这样做有两点意义：

1. 把一个宽比较结果分解成多个局部条件，便于在下一级与 way 选择、refill 状态等控制共同组合；
2. 可针对高扇出的 Way0 局部结果保存独立副本，给后续不同逻辑锥使用。

“为了改善时序和布线”是符合结构特征的设计动机推断，但具体关键路径、扇出和频率收益必须由综合报告、布局布线结果及 STA 证明。

### 5.3 Way0 Hit 结果的复制（Duplicate）

```verilog
// 行 1361-1381
// 原始版本
ifdp_ipctrl_way0_28_24_hit <= ifdp_icache_way0_28_24_hit;
...
// 复制版本（相同逻辑，不同寄存器）
ifdp_ipctrl_way0_28_24_hit_dup <= ifdp_icache_way0_28_24_hit;
```

RTL 确实把同一组 Way0 分段命中条件写入两组独立寄存器：原始版本和 `_dup` 版本。这样可以让后续逻辑分别使用不同寄存器输出；减少单一寄存器输出的逻辑扇出是合理的实现动机。至于物理布线是否实际复制、负载减少多少，仍由综合与后端工具决定。

### 5.4 Way1 的特殊处理

```verilog
// 行 1235-1239
assign ifdp_icache_way1_28_24_hit = (l1_refill_ifdp_refill_on)
                                  ? 1'b0   // refill 时 Way1 强制不命中
                                  : cp0_ifu_icache_en_flop &&
                                    icache_tag_way1_28_24_hit;
```

当 `l1_refill_ifdp_refill_on` 时，refill 数据和 tag 统一借用逻辑 Way0 通道，因此 Way1 的四段命中都被强制为 0。RTL 能直接证明的是“refill 模式只允许逻辑 Way0 候选命中”；它没有在 IFDP 内说明 Way1 SRAM 数据此时是否不可信，也不能据此判断物理写入的是哪一路。

### 5.5 ICache 使能标志的打拍

```verilog
// 行 1302-1314
always @(posedge icache_flop_clk ...)
  if(!ifctrl_ifdp_stall || ifctrl_ifdp_cancel)
    cp0_ifu_icache_en_flop <= cp0_ifu_icache_en;
  else
    cp0_ifu_icache_en_flop <= cp0_ifu_icache_en_flop;
```

`cp0_ifu_icache_en` 是 CP0 中控制是否使能 I-Cache 的配置位，在 pcgen 级（取 PC 那拍）采样，但在 IF 级（tag 比较那拍）才被用到。需要打一拍对齐流水。当 stall 且无 cancel 时保持旧值，防止 stall 期间 icache_en 状态变化造成错误命中判断。

---

## 6. VPC One-Hot 编码

### 6.1 if_vpc_2_0_onehot 的生成

```verilog
// 行 1425-1437
always @(pcgen_ifdp_pc[2:0])
begin
case(pcgen_ifdp_pc[2:0])
  3'b000: if_vpc_2_0_onehot[7:0] = 8'b10000000;  // 从 H1 开始
  3'b001: if_vpc_2_0_onehot[7:0] = 8'b01000000;  // 从 H2 开始
  3'b010: if_vpc_2_0_onehot[7:0] = 8'b00100000;  // 从 H3 开始
  3'b011: if_vpc_2_0_onehot[7:0] = 8'b00010000;  // 从 H4 开始
  3'b100: if_vpc_2_0_onehot[7:0] = 8'b00001000;  // 从 H5 开始
  3'b101: if_vpc_2_0_onehot[7:0] = 8'b00000100;  // 从 H6 开始
  3'b110: if_vpc_2_0_onehot[7:0] = 8'b00000010;  // 从 H7 开始
  3'b111: if_vpc_2_0_onehot[7:0] = 8'b00000001;  // 从 H8 开始
endcase
end
```

`pcgen_ifdp_pc[2:0]` 是半字地址的低 3 位，对应架构字节 VPC `[3:1]`。one-hot 编码将其转换为 8 位掩码，指示当前取指从 16 字节取指块的第几个 half-word 开始。一个 64 字节 I-Cache line 包含 4 个这样的取指块。

**为什么需要 one-hot？**

IP 级（ipctrl）需要知道"这一次取指从哪个 half-word 起，到哪个 half-word 止"，进而判断哪些 half-word 需要分派给 IDU（指令解码单元）。用 one-hot 编码可以直接做掩码运算，避免 IP 级再做解码，节省逻辑层级。

### 6.2 vpc_bry_mask 屏蔽掩码

```verilog
// 行 1647-1659
always @(pcgen_ifdp_pc[2:0])
begin
case(pcgen_ifdp_pc[2:0])
  3'b000: vpc_bry_mask[7:0] = 8'b11111111; // PC 从 H1，后续 8 个都有效
  3'b001: vpc_bry_mask[7:0] = 8'b01111111; // PC 从 H2，H1 无效
  3'b010: vpc_bry_mask[7:0] = 8'b00111111; // PC 从 H3，H1~H2 无效
  ...
  3'b111: vpc_bry_mask[7:0] = 8'b00000001; // PC 从 H8，只有 H8 有效
endcase
end
```

`vpc_bry_mask` 与 `if_vpc_2_0_onehot` 类似但用途不同：one-hot 指示起始位置，而 vpc_bry_mask 是从起始位置到取指块末尾的连续 1 掩码，用于屏蔽 VPC 之前、本次不应处理的 half-word。

```verilog
// 行 1668-1671
ifdp_ipctrl_vpc_bry_mask[7:0] <= vpc_bry_mask[7:0] & {8{~ifdp_expt_vld}};
```

如果有异常（`ifdp_expt_vld`），BRY 掩码全部清零——异常情况下不做任何分支预测。

---

## 7. BRY 边界预解码信息

### 7.1 整体架构

BRY 是 RTL 对 half-word 指令边界预解码位的命名。它将两种 H1 起点假设下的合法指令边界打拍到 IP 级，再与直接控制流类型位组合，使 IP 级能够判断“哪些位置是指令起点，其中哪些是可直接预测的控制流”。本文不把 BRY 擅自扩写为固定英文全称，因为 RTL 本身没有给出该缩写定义。

ifdp 中的 BRY 信息有两个维度：
- **Way 维度**：Way0（`w0`）和 Way1（`w1`）分别独立
- **Bank 维度**：每个 Way 有两个 Bank（`b0` 和 `b1`）

```
precode[31:0]  布局（以 Way0 为例）：
bit[31,27,23,19,15,11,7,3]  → w0_ab_br[7:0]   (H1~H8 的直接无条件跳转子集)
bit[30,26,22,18,14,10,6,2]  → w0_br[7:0]       (H1~H8 的直接控制流候选)
bit[29,25,21,17,13, 9,5,1]  → w0b1_bry[7:0]    (H1 是起点假设下的边界)
bit[28,24,20,16,12, 8,4,0]  → w0b0_bry[7:0]    (H1 非起点假设下的边界)
```

### 7.2 Precode 字段提取

```verilog
// 行 1509-1540
// Way0 bank0 BRY 位（precode bit[28,24,20,16,12,8,4,0]）
assign w0b0_bry[7:0] = {ifdp_inst_precode0[28],
                         ifdp_inst_precode0[24],
                         ifdp_inst_precode0[20],
                         ifdp_inst_precode0[16],
                         ifdp_inst_precode0[12],
                         ifdp_inst_precode0[ 8],
                         ifdp_inst_precode0[ 4],
                         ifdp_inst_precode0[ 0]};
// 对应 H1~H8，bit[7] = H1，bit[0] = H8
```

每个 half-word（H1~H8）的各类预解码位，在 `precode[31:0]` 中以步长 4 间隔分布，通过"重新排列"（将第 0、4、8...、28 位聚合到一个 8 位向量）的方式提取。

**怎样理解这种位布局？**

每个 half-word 对应连续的 4 位 precode，因此单个位置的四类属性在存储向量中相邻；IFDP 再把八个位置的同一类属性“转置”为一个 8 位向量。这样既能按位置取得完整 precode，也能按属性一次观察整个取指窗口，并直接与 VPC one-hot 或有效范围掩码进行逐位运算。RTL 没有给出“保证 SRAM 字对齐”这一物理原因，因此这里只描述可验证的数据布局和使用方式。

### 7.3 BRY hit 的判断

```verilog
// 行 1549-1552
assign w0_bry0_hit = |(w0b0_bry[7:0] & if_vpc_2_0_onehot[7:0]);
assign w0_bry1_hit = |(w0b1_bry[7:0] & if_vpc_2_0_onehot[7:0]);
```

用 one-hot（指示 VPC 起始位置）与 BRY 向量做点积（AND + OR），可以判断“当前 VPC 在某套边界假设下是否为合法指令起点”。该结果用于选择 Bank0/Bank1；是否为分支还要继续看 `br`/`ab_br` 类型位。

### 7.4 BRY 数据的完整传递

```verilog
// 行 1543-1563
assign w0b0_bry_data[7:0] = w0b0_bry[7:0] & vpc_bry_mask[7:0];  // 屏蔽 VPC 前面的
assign w0b0_br_taken[7:0] = w0_br[7:0] & vpc_bry_mask[7:0] & w0b0_bry[7:0];
assign w0b0_br_ntake[7:0] = w0_ab_br[7:0] & vpc_bry_mask[7:0] & w0b0_bry[7:0];
```

- `bry_data`：经 VPC 范围掩码过滤后的合法指令起点候选；
- `br_taken`：合法边界上的直接控制流候选集合；
- `br_ntake`：合法边界上的直接无条件跳转子集。

所有这些 8 位向量在 `pipedown` 时锁存到 `ifdp_ipctrl_w*b*_*` 寄存器，供 IP 级使用。

### 7.5 BRY 数据的反向更新

```verilog
// 行 1606-1623（else 分支，即 stall 时）
ifdp_ipctrl_w0b0_bry_data[7:0] <= ipctrl_ifdp_w0b0_bry_updt_data[7:0];
...
ifdp_ipctrl_w0_bry0_hit <= ipctrl_ifdp_w0_bry0_hit_updt;
```

当 IF 级 stall（无 pipedown）时，IP 级可以通过 `ipctrl_ifdp_w*_bry*_updt` 信号反向更新 IFDP 中保存的 BRY 寄存器。典型原因包括多条件分支窗口拆分和 missigned 边界重建：IPCTRL 保留尚未处理的位置、更新 VPC one-hot，并让下一轮从剩余片段继续，而不是简单“清掉已分派的分支位”。

---

## 8. BTB 数据打拍与传递

### 8.1 常规 BTB 的 4 个位置槽

I-Cache 是 **2 路组相联**，其 Way0/Way1 与这里的 BTB `way0~way3` 不是同一维度。常规 BTB 每个索引行提供 4 个固定分支位置槽，分别对应一个取指窗口内可记录的分支位置；RTL 沿用 `way0~way3` 命名，但它们不能按常规 cache 的四路组相联和 LRU 替换方式解释。每个位置槽包含：

```verilog
// 行 451-466（寄存器声明）
reg [1:0]  btb_way0_pred;       // 2 位 I-Cache way 预测信息
reg [9:0]  btb_way0_tag;        // 10 位 tag（用于命中判断）
reg [19:0] btb_way0_target;     // 20 位目标地址（PC 低 20 位）
reg        btb_way0_vld;        // 有效位
```

在 `pipedown` 时，4 路数据全部从 IF 级锁存到 IP 级：

```verilog
// 行 1838-1855
else if(ifctrl_ifdp_pipedown)
begin
  btb_way0_tag[9:0]     <= btb_ifdp_way0_tag[9:0];
  btb_way0_target[19:0] <= btb_ifdp_way0_target[19:0];
  btb_way0_pred[1:0]    <= btb_ifdp_way0_pred[1:0];
  btb_way0_vld          <= btb_ifdp_way0_vld;
  ...（way1~way3 同理）
end
```

**为什么把 4 个槽的数据全部传给 IP 级，而不在 IF 级就只留一个？**

后续 IPCTRL/IPDP 会结合取指窗口中的分支位置、各槽 tag/valid 和预测控制选择实际匹配的 BTB 项，因此 IFDP 保留并寄存全部四个候选槽。与此同时，IFDP 还独立地把每个槽的 target 与 L0 BTB target 分成高、低两段预比较，供下一流水级判断 L0 快速重定向是否与常规 BTB 信息一致。

因此，这里存在两类不同判断：**选择哪个常规 BTB 位置槽**，以及**该槽的目标是否与 L0 BTB 目标相同**。后者依赖 L0 target，前者不能简化为“用 L0 target 做 BTB tag 比较”。

### 8.2 L0 BTB vs 常规 BTB 目标地址预比较

```verilog
// 行 1807-1815
// 在 IF 级预先比较常规 BTB 各位置槽 target 与 L0 BTB target
assign btb_way0_high_hit = btb_ifdp_way0_target[19:10] == l0_btb_ifdp_chgflw_pc[19:10];
assign btb_way0_low_hit  = btb_ifdp_way0_target[9:0]   == l0_btb_ifdp_chgflw_pc[9:0];
...
assign btb_mispred_pc[PC_WIDTH-2:0] = pcgen_ifdp_inc_pc[PC_WIDTH-2:0];
```

这个比较的目的：当 L0 BTB 已经给出较早目标，而 IP 级随后选中的常规 BTB 位置槽目标与之不同时，需要纠正前端取指流。IFDP 先把 4 个位置槽的 target 与 L0 target 各自拆成高、低 10 位比较，得到 `way*_high_hit`/`way*_low_hit` 并寄存，IPCTRL 再按实际分支位置选择对应结果。把比较前移具有减少 IP 级组合工作的结构意图，实际时序收益仍需 STA 证明。

`btb_mispred_pc` 取自 `pcgen_ifdp_inc_pc`，表示没有沿用 L0 跳转目标时的顺序取指回退地址。这里的 `inc_pc` 不是“下一条指令 PC+2/4”：PCGEN 的内部 PC 省略架构 PC bit0，正常情况下令内部 `if_pc[38:3]` 加 1，因此推进到下一个 **16 字节取指窗口**；reissue 时则保持相应低位。该地址用于恢复前端取指流，而不是由 IFDP 解码当前指令长度后计算下一条架构指令地址。

### 8.3 L0 BTB 命中信息打拍

```verilog
// 行 1878-1914
else if(ifctrl_ifdp_pipedown)
begin
  l0_btb_hit                     <= l0_btb_ifdp_hit;
  l0_btb_target[PC_WIDTH-2:0]    <= l0_btb_ifdp_chgflw_pc[PC_WIDTH-2:0];
  l0_btb_way_pred[1:0]           <= l0_btb_ifdp_chgflw_way_pred[1:0];
  l0_btb_counter                 <= l0_btb_ifdp_counter;   // 1 位 L0 重定向资格状态
  l0_btb_ras                     <= l0_btb_ifdp_ras;       // 是否是 RAS 预测
  l0_btb_entry_hit[15:0]         <= l0_btb_ifdp_entry_hit[15:0];  // 命中的 entry 索引
  l0_btb_way0_high_hit           <= btb_way0_high_hit;    // 常规 BTB 槽0预比较结果
  ...
  l0_btb_mispred_pc[PC_WIDTH-2:0] <= btb_mispred_pc[PC_WIDTH-2:0];
end
```

L0 BTB 的所有预测结果，加上常规 BTB 各位置槽的 target 预比较结果，在 pipedown 时一并锁存到 IP 级寄存器，命名为 `ifdp_ipdp_l0_btb_*`。其中 `l0_btb_counter` 只有 1 位，在当前实现中用于限定 L0 命中能否直接形成前端快速重定向；它不是 2 位饱和方向预测计数器。其写入、清除和训练条件详见 `02_l0_btb.md`。

---

## 9. VPC 和物理地址传递

### 9.1 VPC 传递

```verilog
// 行 1452-1460
always @(posedge ifdp_clk ...)
  if(ifctrl_ifdp_pipedown)
    ifdp_ipdp_vpc[PC_WIDTH-2:0] <= pcgen_ifdp_pc[PC_WIDTH-2:0];
```

当前取指的虚拟地址（VPC），直接从 pcgen 经 ifdp 打拍传到 IP 级的数据通路（ipdp）。

### 9.2 VPC One-Hot 更新逻辑的特殊处理

```verilog
// 行 1439-1448
always @(posedge ifdp_clk ...)
  if(rtu_yy_xx_dbgon)
    ifdp_ipctrl_vpc_2_0_onehot[7:0] <= 8'b10000000;   // 调试模式固定从 H1 开始
  else if(ifctrl_ifdp_pipedown)
    ifdp_ipctrl_vpc_2_0_onehot[7:0] <= if_vpc_2_0_onehot[7:0];
  else
    ifdp_ipctrl_vpc_2_0_onehot[7:0] <= ipctrl_ifdp_vpc_onehot_updt[7:0];
```

三种情况：
1. **调试模式**：强制 one-hot = `10000000`，把 IP 级保存的窗口起点掩码归一为 H1；该赋值本身不修改 PC，也不能单独“保证 PC 对齐”
2. **pipedown**：用 IF 级 VPC 的低 3 位重新计算
3. **stall（无 pipedown）**：接受 IP 级的更新（`vpc_onehot_updt`），IP 级消费了若干 half-word 后推进 one-hot 指针

### 9.3 物理地址传递

```verilog
// 行 1465-1473
always @(posedge ifdp_clk ...)
  if(ifctrl_ifdp_pipedown)
    ifdp_ipctrl_pa[27:0] <= mmu_ifu_pa[27:0];
```

MMU 翻译得到的物理地址 PA（28 位），在 pipedown 时锁存到 `ifdp_ipctrl_pa`，供 IP 级用于 L1 Refill 请求（向 BIU/总线发起 cache miss 填充请求）。

---

## 10. 异常信息传递

### 10.1 异常来源

```verilog
// 行 1743-1746
assign if_mmu_expt_vld    = mmu_ifu_pgflt;          // MMU 页访问异常
assign if_refill_expt_vld = l1_refill_ifdp_acc_err; // Refill 总线访问错误
assign ifdp_expt_vld      = if_refill_expt_vld || if_mmu_expt_vld;
```

两种异常来源：
1. **`mmu_ifu_pgflt`（Page Fault）**：MMU 汇总后送给 IFU 的取指页故障指示；它可能来自地址翻译、页表项合法性或权限检查等路径，IFDP 本身无法再区分具体原因
2. **`l1_refill_ifdp_acc_err`（Access Error）**：L1 Refill 从总线取数据时总线返回错误响应（如访问非法物理地址）

### 10.2 异常信息打拍

```verilog
// 行 1771-1793
always @(posedge ifdp_spe_clk ...)
  if(ifctrl_ifdp_pipedown)
  begin
    ifdp_ipdp_expt_vld  <= ifdp_expt_vld;
    ifdp_ipctrl_expt_vld_dup <= ifdp_expt_vld;   // 复制一份给 ipctrl（减少扇出）
    ifdp_ipdp_mmu_pgflt <= mmu_ifu_pgflt;         // 具体是页访问异常
    ifdp_ipdp_acc_err   <= l1_refill_ifdp_acc_err; // 具体是访问错误
  end
```

这里使用专用的门控时钟 `ifdp_spe_clk`（Special Clock），本地使能为 `ifdp_ipdp_expt_vld || ifdp_expt_vld`。包含“上一拍异常”的原因是：异常撤销后仍需获得时钟机会，把已保存的异常有效位清零。寄存器真正改写仍受 `ifctrl_ifdp_pipedown` 控制。

不能把本地使能为 0直接写成“完全关门、零功耗”：`cp0_ifu_icg_en` 可作为模块级强制使能，扫描使能也可开钟；非工艺 ICG 的 RTL 分支还会直接透传时钟。即使门控生效，局部组合逻辑和时钟树之外的电路也不等于零功耗。

### 10.3 异常如何影响 BRY 掩码

```verilog
// 行 1668
ifdp_ipctrl_vpc_bry_mask[7:0] <= vpc_bry_mask[7:0] & {8{~ifdp_expt_vld}};
```

异常情况下，BRY 掩码全部清零（`& {8{0}} = 0`）。原因：发生异常时，IP 级不能继续正常分派指令，必须进入异常处理流程。清零 BRY 掩码确保 IP 级不会错误地尝试基于分支预测来推进 PC。

---

## 11. 硬件断点（HAD Breakpoint）

```verilog
// 行 1684-1716
// 断点 A 匹配：逐 half-word 检查地址是否在断点范围内
assign bkpta_hit_0 = ((bkpta_base & bkpta_mask) == ({pcgen_ifdp_pc[PC_WIDTH-2:3],4'b0000} & bkpta_mask))
                     ^ had_yy_xx_bkpta_rc;  // rc=0: hit when match; rc=1: hit when not match
assign bkpta_hit_1 = ... // PC+2
assign bkpta_hit_2 = ... // PC+4
...
assign if_bkpta[7:0] = {bkpta_hit_0, bkpta_hit_1, ..., bkpta_hit_7};
```

ifdp 在 IF 级同时计算本次取指窗口（128 位 = 8 个 half-word）中每个 half-word 地址是否命中调试断点（HAD，Hardware Advanced Debugger）。结果以 8 位掩码形式打拍传给 IP 级，IP 级据此在相应位置插入调试陷阱。

`had_yy_xx_bkpta_rc`（Range Complement）：为 1 时取反条件，变成"地址不在范围内时触发"，支持地址范围外断点。

---

## 12. MMU 属性位传递到 L1 Refill

当发生 cache miss 时，L1 Refill 需要向总线发起取数请求，请求参数来自 MMU 翻译结果：

```verilog
// 行 2001-2071
ifdp_l1_refill_tsize       <= cp0_ifu_icache_en && mmu_ifu_ca;  // cacheable 且 cache 使能才填 cache
ifdp_l1_refill_bufferable  <= mmu_ifu_buf;    // MMU 给出的 bufferable 总线属性
ifdp_l1_refill_secure      <= mmu_ifu_sec;    // 安全属性
ifdp_l1_refill_cacheable   <= mmu_ifu_ca;     // 可缓存性
ifdp_l1_refill_machine_mode <= (cp0_yy_priv_mode[1:0] == 2'b11);  // 机器模式
ifdp_l1_refill_supv_mode   <= cp0_yy_priv_mode[0];  // 特权编码 bit0 的原样派生
```

这些属性在 pipedown 时锁存，当 IP 级发出 cache miss 时，L1 Refill 从这里读取属性，正确发起总线请求。

| 属性 | 来源 | 用途 |
|---|---|---|
| `tsize` | `icache_en && ca` | 选择四拍 cache-line refill 并允许写 I-Cache；为 0 时走一拍、不填 I-Cache 的返回路径 |
| `bufferable` | `mmu_ifu_buf` | 原样传递给 refill/IPB/BIU 的 memory attribute；IFDP 不解释为乱序或写缓冲合并 |
| `cacheable` | `mmu_ifu_ca` | 数据是否可缓存 |
| `secure` | `mmu_ifu_sec` | 原样传递的安全属性；不能仅凭该信号认定采用某一特定安全体系 |
| `machine_mode` | `priv_mode == 2'b11` | 特权级（影响 PMP 检查） |
| `supv_mode` | `priv_mode[0]` | 特权编码 bit0；S 模式和 M 模式该位都可能为 1，需结合 `machine_mode` 解读 |

`tsize` 的行为可由 `ct_ifu_l1_refill` 状态机直接验证：为 1 时，返回路径从 WFD1 继续经过 WFD2、WFD3、WFD4，并在有效返回拍产生 I-Cache 写请求；为 0 时，WFD1 后结束且不写 I-Cache。因此它表达的是“本次取指请求是否采用 cache-line 填充规模”，比笼统称为 write-allocate 更准确。

---

## 13. 向 IP 级的输出汇总

| 信号组 | 说明 |
|---|---|
| `ifdp_ipdp_h1~h8_inst_high/low_way0/1` | 8 个 half-word × 2 路 × (14+2) 位指令数据 |
| `ifdp_ipdp_h1~h8_precode_way0/1` | 8 个 half-word × 2 路 × 4 位预解码 |
| `ifdp_ipctrl_way0/1_28_24/23_16/15_8/7_0_hit` | tag 比较分段结果（Way0 × 4 段，Way1 × 4 段）|
| `ifdp_ipctrl_way0_*_hit_dup` | Way0 hit 的复制（减少扇出） |
| `ifdp_ipctrl_fifo` | I-Cache 两路替换/FIFO 选择状态；不是完整 LRU 次序 |
| `ifdp_ipctrl_vpc_2_0_onehot` | VPC 低 3 位 one-hot（8 位） |
| `ifdp_ipctrl_vpc_bry_mask` | VPC BRY 掩码（8 位） |
| `ifdp_ipctrl_w0/1_b0/1_bry_data` | BRY 有效位（4 组 × 8 位） |
| `ifdp_ipctrl_w0/1_b0/1_br_taken` | 直接控制流候选（4 组 × 8 位） |
| `ifdp_ipctrl_w0/1_b0/1_br_ntake` | 无条件跳转位（4 组 × 8 位） |
| `ifdp_ipctrl_w0/1_bry0/1_hit` | 当前 VPC 是否符合各 way/bank 的边界假设（4 位） |
| `ifdp_ipctrl_pa` | 物理地址（28 位）|
| `ifdp_ipctrl_refill_on` | 当前是否处于 refill 状态 |
| `ifdp_ipctrl_expt_vld/dup` | 异常有效位及复制 |
| `ifdp_ipctrl_tsize` | Cache 属性（同 `ifdp_l1_refill_tsize`） |
| `ifdp_ipctrl_way_pred` | Way 预测结果（2 位）|
| `ifdp_ipdp_vpc` | 虚拟 PC（39 位）|
| `ifdp_ipdp_mmu_pgflt` | 页访问异常标志 |
| `ifdp_ipdp_acc_err` | 总线访问错误标志 |
| `ifdp_ipdp_bkpta/bkptb` | 硬件断点命中掩码（各 8 位）|
| `ifdp_ipdp_btb_way0~3_*` | 常规 BTB 的 4 个位置槽数据 |
| `ifdp_ipdp_l0_btb_*` | L0 BTB 预测结果及常规 BTB target 预比较 |
| `ifdp_ipdp_sfp_*` | 特殊失败预测（SFP）信息 |
| `ifdp_l1_refill_*` | 向 L1 Refill 的 MMU 属性 |

---

## 14. 关键设计模式总结

### 14.1 数据流 = SRAM 输出 → 组合处理 → pipedown 寄存

ifdp 的设计模式非常统一：所有信号都在 IF 级做组合逻辑处理（tag 比较、BRY 提取、VPC one-hot 等），然后在 `ifctrl_ifdp_pipedown` 的上升沿统一锁存到 IP 级寄存器。这样做：
1. 使 IF→IP 的流水级边界非常清晰
2. 所有 IP 级信号都是寄存器输出，时序可以更好控制
3. 在 stall 期间（无 pipedown）保持上一个有效值

### 14.2 多路数据并行处理

Way0 和 Way1 的数据、BRY 的 bank0 和 bank1，都是并行处理的。IP 级根据 tag 命中结果和预测信息，从中选择实际使用的候选。这种“并行准备、后级选择”的结构减少了 IF 级内先选路再处理的逻辑依赖；它是否构成芯片频率的关键因素，仍需结合综合与 STA 判断。

### 14.3 时序关键路径保护

从 RTL 结构可识别出多处面向较短组合锥或较低扇出的实现：
- tag 分 4 段比较，每段 8 位以内
- Way0 hit 结果做 `_dup` 复制，减少扇出
- BTB target 预比较在 IF 级完成，减轻 IP 级负担
- BRY 信息在 IF 级预计算好掩码，IP 级直接使用

这些是结构事实及其合理的体系结构解释，不等同于物理实现已经达到某一频率。学习 IFDP 时，应先看“每类信息在哪一级产生、在哪一级寄存、下一拍由谁消费”，再用综合时序报告验证哪一条逻辑锥真正限制频率。
