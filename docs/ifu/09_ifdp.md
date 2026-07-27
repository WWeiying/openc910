# 09 ct_ifu_ifdp —— IF 级数据通路详解

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_ifdp.v`（2085 行）

---

## 1. 模块概述

`ct_ifu_ifdp` 是 C910 IFU 的 **IF 级数据通路（Data Path）**，与 `ct_ifu_ifctrl`（控制通路）构成 IF 流水级的完整实现。

ifdp 的核心工作是：
1. 接收来自 ICache 或 L1 Refill 的 128 位、16 字节取指块，将其分解为 8 个 16 位 half-word（H1~H8）
2. 同时对每个 half-word 提供预解码信息（precode）
3. 进行 Tag 比较，判断 cache 是否命中（Way0/Way1）
4. 接收 BTB（L1）和 L0 BTB 的预测信息，打拍传给 IP 级
5. 处理 VPC one-hot 编码和 BRY（Branch Ready）分支信息
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

`ifdp_clk` 是整个 ifdp 模块的主工作时钟。其时钟使能 `ifdp_clk_en` 由 IP 级的 `ipctrl_ifdp_gateclk_en` 控制，而不是由 IF 级自身决定。这样做的原因是：ifdp 中保存的是 **IP 级正在使用的数据**（它是 IF→IP 流水寄存器），因此它的时钟门控应由 IP 级消费者来控制。

---

## 3. 指令数据来源选择

```verilog
// 行 874-887
// Way0：可以来自 cache 或 refill
assign ifdp_inst_data0[127:0] = (l1_refill_ifdp_refill_on)
                              ? l1_refill_ifdp_inst_data[127:0]
                              : icache_if_ifdp_inst_data0[127:0];

// Way1：只来自 cache（refill 只填 Way0）
assign ifdp_inst_data1[127:0] = icache_if_ifdp_inst_data1[127:0];

// precode 同理
assign ifdp_inst_precode0[31:0] = (l1_refill_ifdp_refill_on)
                                 ? l1_refill_ifdp_precode[31:0]
                                 : icache_if_ifdp_precode0[31:0];
assign ifdp_inst_precode1[31:0] = icache_if_ifdp_precode1[31:0];
```

**为什么 Way1 只来自 cache？**

L1 Refill 从总线取回一个 cache line，回填时写入 Way0 或 Way1 中的某一路（由替换策略决定），但在同一拍 refill 结束时，ifctrl 使用的是 `l1_refill_ifdp_refill_on` 信号，此时 refill 数据直接旁路给 Way0 通道使用，同时 Way1 通道不参与（`refill_on` 时 Way1 命中强制为 0）。这样设计简化了电路，且保证了数据一致性。

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

这是出于时序优化考虑。低 2 位（bit[1:0]）是 RISC-V 压缩指令的判断依据：`00/01/10` 表示 16 位 RVC 指令，`11` 表示 32 位标准指令。IP 级的指令流处理需要先用低 2 位做"指令宽度判断"，确定指令边界，这个判断在关键路径上。将低 2 位单独提取，可以让这条路径更短。

### 4.2 Precode 字段含义

每个 half-word 对应 4 位 precode，来自 ICache 预解码器（在 cache 填充时预计算好存入）：

| precode 位 | 含义（每个 half-word 对应） |
|---|---|
| bit[3]（`ab_br`） | 无条件跳转（JAL/JALR 等）有效位 |
| bit[2]（`br`） | 条件分支（branch taken 候选）有效位 |
| bit[1]（`b1_bry`） | BRY 数组 bank1 有效位 |
| bit[0]（`b0_bry`） | BRY 数组 bank0 有效位 |

IP 级通过这 4 位可以快速判断 "这个 half-word 是否是分支指令的起始位置"，无需重新解码指令。

---

## 5. Tag 比较逻辑（VIPT Cache 命中判断）

### 5.1 分段比较设计

C910 I-Cache 采用 VIPT（虚拟索引、物理标记）方式，tag 字段为物理地址高位。为了缩短关键路径，tag 比较被拆分为 4 段并行进行：

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

**为什么要分段比较？**

tag 比较的输入路径是：MMU 翻译 → `mmu_ifu_pa`（28 位）与 ICache SRAM 输出 `tag_data`（28 位）做比较器。28 位比较器的传播延迟本身不算长，但扇出问题严重——tag 命中结论需要驱动很多后续逻辑（way 选择、数据 MUX 等）。将比较拆分为 4 段，各段结果分别通过寄存器传到 IP 级，可以：
1. 将 28 位比较拆为四个 8/7/5 位比较，每段延迟更小
2. 各段结果独立存寄存器，便于复制（`_dup` 信号），减少扇出负担
3. 时序裕量更大，支持更高频率

### 5.3 Way0 Hit 结果的复制（Duplicate）

```verilog
// 行 1361-1381
// 原始版本
ifdp_ipctrl_way0_28_24_hit <= ifdp_icache_way0_28_24_hit;
...
// 复制版本（相同逻辑，不同寄存器）
ifdp_ipctrl_way0_28_24_hit_dup <= ifdp_icache_way0_28_24_hit;
```

Way0 的命中结果是 IP 级选择数据通路的关键信号，扇出极大，会增加 wire 上的负载和延迟。设计上通过寄存两份相同的数据（`_dup` 后缀），让不同的逻辑消费不同的拷贝，从而减小单个信号的驱动负担，改善时序。

### 5.4 Way1 的特殊处理

```verilog
// 行 1235-1239
assign ifdp_icache_way1_28_24_hit = (l1_refill_ifdp_refill_on)
                                  ? 1'b0   // refill 时 Way1 强制不命中
                                  : cp0_ifu_icache_en_flop &&
                                    icache_tag_way1_28_24_hit;
```

当 `l1_refill_ifdp_refill_on` 时，Way1 的命中强制为 0。原因是 refill 数据通过 Way0 通道旁路，Way1 的 SRAM 输出在 refill 期间不可信（可能正在被写入），因此直接屏蔽。

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

## 7. BRY 数组（Branch Ready 信息）

### 7.1 整体架构

BRY（Branch Ready）是 IFU 内部的一个重要数据结构，将每个 half-word 的预解码分支信息打拍存入 IP 级寄存器，让 IP 级可以快速判断 "当前取指 window 中哪些位置有分支指令"。

ifdp 中的 BRY 信息有两个维度：
- **Way 维度**：Way0（`w0`）和 Way1（`w1`）分别独立
- **Bank 维度**：每个 Way 有两个 Bank（`b0` 和 `b1`）

```
precode[31:0]  布局（以 Way0 为例）：
bit[31,27,23,19,15,11,7,3]  → w0_ab_br[7:0]   (H1~H8 的无条件跳转位)
bit[30,26,22,18,14,10,6,2]  → w0_br[7:0]       (H1~H8 的条件分支位)
bit[29,25,21,17,13, 9,5,1]  → w0b1_bry[7:0]    (H1~H8 的 BRY bank1 位)
bit[28,24,20,16,12, 8,4,0]  → w0b0_bry[7:0]    (H1~H8 的 BRY bank0 位)
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

**为什么用这种分散存储格式？**

I-Cache 的 precode 存储需要在 cache line 内逐 half-word 存放，且每个 half-word 的 4 位 precode 紧跟着该 half-word 存储，以保证 SRAM 字对齐。提取时做"转置"，把分散的第 k 类信息汇聚成一个字节，便于后续用 one-hot 做点乘运算。

### 7.3 BRY hit 的判断

```verilog
// 行 1549-1552
assign w0_bry0_hit = |(w0b0_bry[7:0] & if_vpc_2_0_onehot[7:0]);
assign w0_bry1_hit = |(w0b1_bry[7:0] & if_vpc_2_0_onehot[7:0]);
```

用 one-hot（指示 VPC 起始位置）与 BRY 向量做点积（AND + OR），可以判断"当前取指起始的 half-word 是否是一个分支起始"。这是 IP 级快速推进 PC 的基础。

### 7.4 BRY 数据的完整传递

```verilog
// 行 1543-1563
assign w0b0_bry_data[7:0] = w0b0_bry[7:0] & vpc_bry_mask[7:0];  // 屏蔽 VPC 前面的
assign w0b0_br_taken[7:0] = w0_br[7:0] & vpc_bry_mask[7:0] & w0b0_bry[7:0];
assign w0b0_br_ntake[7:0] = w0_ab_br[7:0] & vpc_bry_mask[7:0] & w0b0_bry[7:0];
```

- `bry_data`：经 VPC 掩码过滤后的 BRY 有效位（哪些 half-word 有分支）
- `br_taken`：对应位置的"条件分支"位（branch taken 候选）
- `br_ntake`：对应位置的"无条件跳转"位（always taken）

所有这些 8 位向量在 `pipedown` 时锁存到 `ifdp_ipctrl_w*b*_*` 寄存器，供 IP 级使用。

### 7.5 BRY 数据的反向更新

```verilog
// 行 1606-1623（else 分支，即 stall 时）
ifdp_ipctrl_w0b0_bry_data[7:0] <= ipctrl_ifdp_w0b0_bry_updt_data[7:0];
...
ifdp_ipctrl_w0_bry0_hit <= ipctrl_ifdp_w0_bry0_hit_updt;
```

当 IF 级 stall（无 pipedown）时，IP 级可以通过 `ipctrl_ifdp_w*_bry*_updt` 信号反向更新 ifdp 中保存的 BRY 寄存器。这是因为：IP 级消费 BRY 信息后（分派了几个 half-word），需要"推进" BRY 状态（清掉已处理的分支位），以便下一次 stall 解除时能正确接续。

---

## 8. BTB 数据打拍与传递

### 8.1 L1 BTB 4 路数据

I-Cache 采用 4 路组相联，BTB 也对应提供 4 路数据（way0~way3），每路包含：

```verilog
// 行 451-466（寄存器声明）
reg [1:0]  btb_way0_pred;       // 2 位饱和计数器预测值
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

**为什么把 4 路数据全部传给 IP 级，而不在 IF 级就选出命中路？**

在 IF 级，L1 BTB tag 比较（判断哪路命中）依赖 L0 BTB 的预测目标地址（用于和 L1 BTB 对比），这需要额外一拍时间。因此 IF 级只做 L0 BTB 与 L1 BTB 的 target 局部比较，完整的 tag 命中判断留到 IP 级完成。将 4 路都传过去让 IP 级选择，避免在 IF 级引入额外的依赖。

### 8.2 L0 BTB vs L1 BTB 目标地址预比较

```verilog
// 行 1807-1815
// 在 IF 级预先比较 L1 BTB 各路的 target 与 L0 BTB 预测的 target
assign btb_way0_high_hit = btb_ifdp_way0_target[19:10] == l0_btb_ifdp_chgflw_pc[19:10];
assign btb_way0_low_hit  = btb_ifdp_way0_target[9:0]   == l0_btb_ifdp_chgflw_pc[9:0];
...
assign btb_mispred_pc[PC_WIDTH-2:0] = pcgen_ifdp_inc_pc[PC_WIDTH-2:0];
```

这个比较的目的：当 L0 BTB 预测了一个跳转目标，但 IP 级发现 L1 BTB 的目标地址不同时（mis-prediction），需要在 IP 级发出 chgflw 纠正 PC。为了节省 IP 级的时序，在 IF 级预先将 L1 BTB 各路 target 与 L0 BTB target 的高 10 位和低 10 位分别比较，得到 `way*_high_hit`/`way*_low_hit`，打拍传到 IP 级供组合使用。

`btb_mispred_pc`（用 `inc_pc`，即 PC+2/4）记录"如果 L0 BTB 预测错误，应该回到哪个 PC"。

### 8.3 L0 BTB 命中信息打拍

```verilog
// 行 1878-1914
else if(ifctrl_ifdp_pipedown)
begin
  l0_btb_hit                     <= l0_btb_ifdp_hit;
  l0_btb_target[PC_WIDTH-2:0]    <= l0_btb_ifdp_chgflw_pc[PC_WIDTH-2:0];
  l0_btb_way_pred[1:0]           <= l0_btb_ifdp_chgflw_way_pred[1:0];
  l0_btb_counter                 <= l0_btb_ifdp_counter;   // 饱和计数器预测位
  l0_btb_ras                     <= l0_btb_ifdp_ras;       // 是否是 RAS 预测
  l0_btb_entry_hit[15:0]         <= l0_btb_ifdp_entry_hit[15:0];  // 命中的 entry 索引
  l0_btb_way0_high_hit           <= btb_way0_high_hit;    // L1 BTB 预比较结果
  ...
  l0_btb_mispred_pc[PC_WIDTH-2:0] <= btb_mispred_pc[PC_WIDTH-2:0];
end
```

L0 BTB 的所有预测结果，加上 L1 BTB 的各路 target 预比较结果，在 pipedown 时一并锁存到 IP 级寄存器，命名为 `ifdp_ipdp_l0_btb_*`。

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
1. **调试模式**：强制 one-hot = `10000000`（从 H1 开始），保证调试时 PC 对齐
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
1. **`mmu_ifu_pgflt`（Page Fault）**：TLB 命中但页表项无效或权限不足，由 MMU 直接报告
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

这里使用了专用的门控时钟 `ifdp_spe_clk`（Special Clock），其使能条件是 `ifdp_ipdp_expt_vld || ifdp_expt_vld`——即只有当前有异常或上一拍有异常时才开门，平时（正常取指）这部分逻辑完全关门，零功耗。

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
ifdp_l1_refill_bufferable  <= mmu_ifu_buf;    // 是否可以乱序（bufferable）
ifdp_l1_refill_secure      <= mmu_ifu_sec;    // 安全属性
ifdp_l1_refill_cacheable   <= mmu_ifu_ca;     // 可缓存性
ifdp_l1_refill_machine_mode <= (cp0_yy_priv_mode[1:0] == 2'b11);  // 机器模式
ifdp_l1_refill_supv_mode   <= cp0_yy_priv_mode[0];  // 监督模式
```

这些属性在 pipedown 时锁存，当 IP 级发出 cache miss 时，L1 Refill 从这里读取属性，正确发起总线请求。

| 属性 | 来源 | 用途 |
|---|---|---|
| `tsize` | `icache_en && ca` | 决定 Refill 是否写入 cache（Write-Allocate） |
| `bufferable` | `mmu_ifu_buf` | 总线属性，是否允许 write buffer 合并 |
| `cacheable` | `mmu_ifu_ca` | 数据是否可缓存 |
| `secure` | `mmu_ifu_sec` | TrustZone 安全属性 |
| `machine_mode` | `priv_mode == 2'b11` | 特权级（影响 PMP 检查） |
| `supv_mode` | `priv_mode[0]` | Supervisor 模式标志 |

---

## 13. 向 IP 级的输出汇总

| 信号组 | 说明 |
|---|---|
| `ifdp_ipdp_h1~h8_inst_high/low_way0/1` | 8 个 half-word × 2 路 × (14+2) 位指令数据 |
| `ifdp_ipdp_h1~h8_precode_way0/1` | 8 个 half-word × 2 路 × 4 位预解码 |
| `ifdp_ipctrl_way0/1_28_24/23_16/15_8/7_0_hit` | tag 比较分段结果（Way0 × 4 段，Way1 × 4 段）|
| `ifdp_ipctrl_way0_*_hit_dup` | Way0 hit 的复制（减少扇出） |
| `ifdp_ipctrl_fifo` | Cache line 的 FIFO（LRU）位 |
| `ifdp_ipctrl_vpc_2_0_onehot` | VPC 低 3 位 one-hot（8 位） |
| `ifdp_ipctrl_vpc_bry_mask` | VPC BRY 掩码（8 位） |
| `ifdp_ipctrl_w0/1_b0/1_bry_data` | BRY 有效位（4 组 × 8 位） |
| `ifdp_ipctrl_w0/1_b0/1_br_taken` | 条件分支位（4 组 × 8 位） |
| `ifdp_ipctrl_w0/1_b0/1_br_ntake` | 无条件跳转位（4 组 × 8 位） |
| `ifdp_ipctrl_w0/1_bry0/1_hit` | 当前 VPC 位置是否有分支（4 位） |
| `ifdp_ipctrl_pa` | 物理地址（28 位）|
| `ifdp_ipctrl_refill_on` | 当前是否处于 refill 状态 |
| `ifdp_ipctrl_expt_vld/dup` | 异常有效位及复制 |
| `ifdp_ipctrl_tsize` | Cache 属性（同 `ifdp_l1_refill_tsize`） |
| `ifdp_ipctrl_way_pred` | Way 预测结果（2 位）|
| `ifdp_ipdp_vpc` | 虚拟 PC（39 位）|
| `ifdp_ipdp_mmu_pgflt` | 页访问异常标志 |
| `ifdp_ipdp_acc_err` | 总线访问错误标志 |
| `ifdp_ipdp_bkpta/bkptb` | 硬件断点命中掩码（各 8 位）|
| `ifdp_ipdp_btb_way0~3_*` | L1 BTB 4 路数据 |
| `ifdp_ipdp_l0_btb_*` | L0 BTB 预测结果及 L1 BTB 预比较 |
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

Way0 和 Way1 的数据、BRY 的 bank0 和 bank1，都是完全并行处理的。IP 级根据 tag 命中结果和预测信息，从中选择正确的那一路使用。这种"并行处理、延后选择"的模式避免了 IF 级的串行依赖，是保证高频率运行的关键。

### 14.3 时序关键路径保护

多处设计专门针对时序优化：
- tag 分 4 段比较，每段 8 位以内
- Way0 hit 结果做 `_dup` 复制，减少扇出
- BTB target 预比较在 IF 级完成，减轻 IP 级负担
- BRY 信息在 IF 级预计算好掩码，IP 级直接使用
