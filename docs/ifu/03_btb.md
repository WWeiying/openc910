# C910 IFU BTB 模块深度解析

> **RTL 源文件**：`C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_btb.v`（861 行）
> 子模块：`ct_ifu_btb_tag_array.v`、`ct_ifu_btb_data_array.v`

---

## 目录

1. [模块概述](#1-模块概述)
2. [物理结构](#2-物理结构)
3. [Index 与 Tag 编码](#3-index-与-tag-编码)
4. [Chip Enable 逻辑](#4-chip-enable-逻辑)
5. [写入逻辑](#5-写入逻辑)
6. [读取流程（两拍）](#6-读取流程两拍)
7. [Refill Buffer 详解](#7-refill-buffer-详解)
8. [Index PC Record](#8-index-pc-record)
9. [INV 机制](#9-inv-机制)
10. [chgflw 优先级信号](#10-chgflw-优先级信号)
11. [完整数据流示例](#11-完整数据流示例)

---

## 1. 模块概述

### 1.1 BTB 在分支预测中的角色

分支预测器要回答两个独立的问题：

| 问题 | 回答模块 |
|------|---------|
| **这条指令是分支吗？如果是，跳还是不跳？** | BHT（Branch History Table）|
| **如果跳，跳到哪里？** | **BTB（Branch Target Buffer）** |

BTB 解决的是"目标地址"问题。没有 BTB，即使 BHT 预测"会跳"，处理器也不知道下一条 PC 应该送给 I-Cache 哪个地址，必须等到分支指令完成解码甚至执行后才能知道目标——这会造成严重的流水线气泡。

BTB 以分支指令的 PC（vpc）为 key，存储其跳转目标地址。当前生成 RTL
不是常规的 N 路组相联表：SRAM 每行有 4 个槽，写入槽由 PC 的块内位置
`rtl_vpc[2:1]` 直接确定，因而没有替换路选择器、LRU 或 FIFO 状态。每次
PCGEN 送出新的 PC 时，BTB 发起同步 SRAM 查询，下一拍把 4 个候选槽交给
IF 级比较 tag。

### 1.2 与其他预测结构的分工

C910 IFU 中存在四个相互配合的分支预测结构：

```
┌─────────────────────────────────────────────────────────────────┐
│                      IFU 分支预测层次                             │
│                                                                 │
│  ┌──────────────┐   低延迟、容量最小                              │
│  │   L0 BTB     │   16 项寄存器阵列，比较结果打拍后供 IF 级早期改流 │
│  │  (l0_btb.v)  │   存储完整目标 PC + icache way 预测              │
│  └──────────────┘                                               │
│         │ miss                                                  │
│         ▼                                                       │
│  ┌──────────────┐   1 拍延迟，容量中等                            │
│  │     BTB      │   512 行×4 个固定位置槽（两个 SRAM bank 并行读）  │
│  │  (btb.v)     │   本文档主题；存储目标 PC 低 20 位 + icache 预测  │
│  └──────────────┘                                               │
│         │ 间接跳转                                               │
│         ▼                                                       │
│  ┌──────────────┐   处理间接跳转（jr rX, jalr）                   │
│  │ Indirect BTB │   基于历史路径预测目标                           │
│  │(ind_btb.v)   │                                               │
│  └──────────────┘                                               │
│                                                                 │
│  ┌──────────────┐   BHT 负责"跳/不跳"方向预测（2-bit 饱和计数器）  │
│  │     BHT      │   与 BTB 并行查询，各司其职                      │
│  └──────────────┘                                               │
└─────────────────────────────────────────────────────────────────┘
```

**关键分工说明**：
- **L0 BTB** 是 BTB 的热点目标缓存：容量极小但避开主 BTB 的同步 SRAM
  读取。它的 16 路比较结果先进入 `entry_hit_flop`，再由 IFCTRL 请求 PCGEN
  重定向，因此不能称为 PCGEN 同拍、端到端零延迟。
- **BTB**（本模块）是主体存储：容量较大，1 拍 SRAM 延迟，负责覆盖大多数跳转。
- BTB 中存储的 `way_pred` 字段是 **icache way 预测**（预测该地址落在 I-Cache 的哪个 way），并非分支方向——方向由 BHT 负责。这是 C910 BTB 设计的一个重要特点。

### 1.3 模块顶层接口概览

```verilog
// 文件：ct_ifu_btb.v，第 17-61 行
module ct_ifu_btb(
  // 来自 addrgen：分支地址已计算完毕，更新 BTB
  addrgen_btb_index,       // [9:0]  用于写入的 index
  addrgen_btb_tag,         // [9:0]  用于写入的 tag
  addrgen_btb_target_pc,   // [19:0] 目标 PC 低 20 位
  addrgen_btb_update_vld,  // 本周期有效的更新请求

  // 来自 pcgen：正常取指的 index
  pcgen_btb_index,         // [9:0]  顺序取指的 index
  pcgen_btb_chgflw,        // 本周期发生了 chgflw（跳转）
  pcgen_btb_stall,         // pcgen 级 stall

  // 来自 ipctrl/ipdp：IP 级 way 预测信息
  ipctrl_btb_chgflw_vld,       // IP 级发生了 chgflw
  ipctrl_btb_way_pred,          // [1:0] 当前 icache way 预测
  ipctrl_btb_way_pred_error,    // way 预测错误
  ipdp_btb_index_pc,            // [38:0] IP 级的 VPC（记录用）
  ipdp_btb_target_pc,           // [19:0] IP 级的目标 PC

  // 来自 ibdp：IB 级 BTB miss 信号
  ibdp_btb_miss,

  // 输出给 ifdp：4 路 BTB 查询结果
  btb_ifdp_way{0..3}_pred,      // [1:0]  icache way 预测
  btb_ifdp_way{0..3}_tag,       // [9:0]  存储的 tag
  btb_ifdp_way{0..3}_target,    // [19:0] 目标 PC 低 20 位
  btb_ifdp_way{0..3}_vld,       // 该路是否有效

  // INV 接口
  ifctrl_btb_inv,          // 来自 ifctrl 的无效化请求
  btb_ifctrl_inv_on,       // INV 进行中
  btb_ifctrl_inv_done,     // INV 完成

  // chgflw 优先级
  pcgen_btb_chgflw_higher_than_ip,
  pcgen_btb_chgflw_higher_than_addrgen,
  pcgen_btb_chgflw_higher_than_if,
  ...
);
```

---

## 2. 物理结构

### 2.1 总体物理组织

BTB 由两个独立的 SRAM 阵列构成，均采用**双 bank 结构**：

```
                    BTB 物理存储
    ┌───────────────────────────────────────────────────┐
    │                Tag Array (ct_ifu_btb_tag_array)   │
    │  bank0: ct_spsram_512x22  ─── btb_tag_dout[21:0]  │
    │  bank1: ct_spsram_512x22  ─── btb_tag_dout[43:22] │
    │  总输出：44 位，同一 index 读出 4 路 tag 数据         │
    └───────────────────────────────────────────────────┘
    ┌───────────────────────────────────────────────────┐
    │               Data Array (ct_ifu_btb_data_array)  │
    │  bank0: ct_spsram_512x44  ─── btb_data_dout[43:0] │
    │  bank1: ct_spsram_512x44  ─── btb_data_dout[87:44]│
    │  总输出：88 位，同一 index 读出 4 路 data 数据        │
    └───────────────────────────────────────────────────┘
```

**为什么接口是 10 位 index，物理地址却只有 9 位？**

`ct_ifu_btb` 仍计算并传递 `btb_index[9:0]`，源码注释也保留了另一种
1024 深度 SRAM 配置；但当前实际例化的两个 `ct_spsram_512x22/44` 的地址端
都只连接 `btb_index[8:0]`。`btb_index[9]` **没有选择 bank**，两个 bank
使用相同的低 9 位地址并在同一拍同时读写。因而当前 RTL 的准确物理组织是：

```
512 个物理行
  × 每行 4 个槽（bank0 打包 slot0/1，bank1 打包 slot2/3）
  = 2048 个物理槽
```

这也意味着内部 PC 位 `rtl_vpc[12]` 虽进入了 10 位逻辑 index，却没有进入
当前 SRAM 地址或存储 tag；该位不同的地址会在 BTB 中发生别名。BTB 是性能
预测结构，别名由后级目标校验纠正，不破坏体系结构正确性，但会增加预测失败。

### 2.2 Tag Array：44 位，4 路格式

```
                    Tag Array 输出 btb_tag_dout[43:0]
 bit：  43  42..33  32  31..22  21  20..11  10   9..0
        ├──┬──────┤├──┬──────┤├──┬──────┤├──┬──────┤
        │V3│ tag3 ││V2│ tag2 ││V1│ tag1 ││V0│ tag0 │
        └──┴──────┘└──┴──────┘└──┴──────┘└──┴──────┘
        Way3(11位)  Way2(11位)  Way1(11位)  Way0(11位)
```

每路 11 位 = 1 位 valid + 10 位 tag。具体分解：

| 字段 | 位域 | 含义 |
|------|------|------|
| Way0 valid | bit[10] | Way0 该行是否有效 |
| Way0 tag   | bit[9:0] | Way0 的标记 |
| Way1 valid | bit[21] | Way1 该行是否有效 |
| Way1 tag   | bit[20:11] | Way1 的标记 |
| Way2 valid | bit[32] | Way2 该行是否有效 |
| Way2 tag   | bit[31:22] | Way2 的标记 |
| Way3 valid | bit[43] | Way3 该行是否有效 |
| Way3 tag   | bit[42:33] | Way3 的标记 |

对应 RTL（第 523-546 行）：

```verilog
// ct_ifu_btb.v 第 523-546 行
assign btb_mem_way3_valid         = ... ? btb_tag_dout[43]    : btb_tag_dout_reg[43];
assign btb_mem_way2_valid         = ... ? btb_tag_dout[32]    : btb_tag_dout_reg[32];
assign btb_mem_way1_valid         = ... ? btb_tag_dout[21]    : btb_tag_dout_reg[21];
assign btb_mem_way0_valid         = ... ? btb_tag_dout[10]    : btb_tag_dout_reg[10];
assign btb_mem_way3_tag_data[9:0] = ... ? btb_tag_dout[42:33] : btb_tag_dout_reg[42:33];
assign btb_mem_way2_tag_data[9:0] = ... ? btb_tag_dout[31:22] : btb_tag_dout_reg[31:22];
assign btb_mem_way1_tag_data[9:0] = ... ? btb_tag_dout[20:11] : btb_tag_dout_reg[20:11];
assign btb_mem_way0_tag_data[9:0] = ... ? btb_tag_dout[9:0]   : btb_tag_dout_reg[9:0];
```

### 2.3 Data Array：88 位，4 路格式

```
                    Data Array 输出 btb_data_dout[87:0]
 bit：  87..86  85..66  65..64  63..44  43..42  41..22  21..20  19..0
        ├──────┬──────┤├──────┬──────┤├──────┬──────┤├──────┬──────┤
        │pred3 │ tar3 ││pred2 │ tar2 ││pred1 │ tar1 ││pred0 │ tar0 │
        └──────┴──────┘└──────┴──────┘└──────┴──────┘└──────┴──────┘
        Way3(22位)       Way2(22位)       Way1(22位)       Way0(22位)
```

每路 22 位 = 2 位 way_pred（icache way 预测）+ 20 位 target PC。

| 字段 | 位域 | 含义 |
|------|------|------|
| Way0 way_pred | bit[21:20] | Way0 的 icache way 预测 |
| Way0 target   | bit[19:0]  | Way0 的目标 PC 低 20 位 |
| Way1 way_pred | bit[43:42] | Way1 的 icache way 预测 |
| Way1 target   | bit[41:22] | Way1 的目标 PC 低 20 位 |
| Way2 way_pred | bit[65:64] | Way2 的 icache way 预测 |
| Way2 target   | bit[63:44] | Way2 的目标 PC 低 20 位 |
| Way3 way_pred | bit[87:86] | Way3 的 icache way 预测 |
| Way3 target   | bit[85:66] | Way3 的目标 PC 低 20 位 |

### 2.4 为什么 target 只存低 20 位？高位如何恢复？

这是一个节省面积的关键设计决策。

先约定本文这一节的位号：RTL 中的 `vpc[38:0]` 是半字地址，等于架构字节地址 `byte_vpc[39:1]`。所以 RTL 位 `vpc[n]` 对应字节地址位 `byte_vpc[n+1]`。

**原因分析**：

C910 运行的是 RISC-V 指令集，所有分支/跳转指令的目标地址都是相对于当前 PC 的**近跳**偏移编码（除 jalr 外）。RISC-V B 型指令偏移量最大 ±4KB，JAL 最大 ±1MB。实际代码中，绝大多数分支目标与分支指令本身在同一个"代码段"（连续映射的地址空间）内，因此高位地址与分支指令的高位相同。

```
  RTL VPC（39位）:  [38:20]高位沿用  |  [19:0] 存入 BTB Data
  字节地址位号：     [39:21]          |  [20:1]，另有隐含 bit[0]=0
```

BTB 的 Tag Array 存储 tag = `{rtl_vpc[19:13], rtl_vpc[2:0]}`。命中时，上游将 BTB 的内部 target `[19:0]` 与当前内部 VPC `[38:20]` 拼接，恢复 39 位半字地址；再在最低位补 0，才得到 40 位字节目标地址。目标字段覆盖字节地址 `[20:1]`，因此高位复用的区域粒度是 2 MiB。

这样做的代价是：若目标与当前 PC 的字节地址 `[39:21]` 不同，BTB 拼接出的高位会错误，由后级检测并纠正；间接跳转另有 Indirect BTB 参与预测。

---

## 3. Index 与 Tag 编码

### 3.1 index = rtl_vpc[12:3]：为什么是这段？

```verilog
// 来自 pcgen 或 addrgen 计算后的 index，例如：
// pcgen_btb_index[9:0] = rtl_vpc[12:3] = byte_vpc[13:4]
```

上游生成 **10 位逻辑 index**，当前 SRAM 实际使用其中的低 9 位：

- **为什么从内部 bit3 开始**：内部 `rtl_vpc[2:0]` 对应字节地址 `[3:1]`，表示一个 16 字节取指块中的 8 个半字位置。这三位不参与 index，而放入 tag 以区分同一块内的不同分支。
- **逻辑 index 为什么到内部 bit12**：`rtl_vpc[12:3]` 对应字节地址
  `[13:4]`。这是 `pcgen`/`addrgen` 的接口定义；
- **当前物理行地址**：`btb_index[8:0] = rtl_vpc[11:3]`，对应字节地址
  `[12:4]`，选择 512 个 SRAM 行；逻辑 index 的 bit9 未接入当前 SRAM；
- **与 cache line 的关系**：BTB index 的基本粒度是 16 字节取指块，不是 64 字节 I-Cache line；一个 cache line 包含 4 个这样的块。

### 3.2 tag = {rtl_vpc[19:13], rtl_vpc[2:0]}：为什么跳过 [12:3]？

```
RTL 半字地址：
  bit：  38..20    19..13    12..3     2..0
         不存       tag高7位   index     tag低3位

对应架构字节地址：
  bit：  39..21    20..14    13..4     3..1   0
         不存       tag高7位   index     tag低3位 0
```

Tag 的构成逻辑：

1. **跳过内部 `vpc[12:3]`**：这段已经作为 index 使用，无需重复存储。
2. **内部 `vpc[19:13]`（7 位）**：对应字节地址 `[20:14]`，用于区分 index 相同但地址区域不同的分支。
3. **内部 `vpc[2:0]`（3 位）**：对应字节地址 `[3:1]`，表示分支位于当前 16 字节取指块中的哪个半字位置。

```
举例：
  字节地址 0x1000_0004：rtl_vpc = 0x0800_0002
  字节地址 0x1000_000c：rtl_vpc = 0x0800_0006
  两者属于同一个 16 字节取指块，rtl_vpc[12:3] 相同，
  但 rtl_vpc[2:0] 不同，因此 tag 能区分两个半字位置。
```

完整 tag 编码在 RTL 注释中（第 230 行）：

```verilog
// ct_ifu_btb.v 第 230 行
//Tag[9:0] = {vpc[19:13], vpc[2:0]};
```

---

## 4. Chip Enable 逻辑

BTB 的两个 SRAM 阵列各有一个 `cen_b`（低有效使能）信号，控制何时激活阵列。

### 4.1 Tag Array 的 cen_b 生成

```verilog
// ct_ifu_btb.v 第 245-256 行
assign btb_tag_cen_b = !btb_inv_on_reg &&               // INV 进行中时必须开启
                       !(cp0_ifu_btb_en && refill_buf_updt_vld) &&  // 写入时必须开启
                       !btb_tag_rd;                      // 读取时必须开启

assign btb_tag_rd    = cp0_ifu_btb_en &&
                       (
                         (pcgen_btb_chgflw &&
                          !ipctrl_btb_way_pred_error &&
                          !ibdp_btb_miss) ||             // chgflw 且无 way pred 错误且无 miss
                         (!pcgen_btb_chgflw &&
                          !pcgen_btb_stall)              // 顺序取指且未 stall
                        );
```

**三种情况均需激活**（`cen_b = 0`）：
1. **INV 期间**：写入无效数据以清空 BTB。
2. **Refill Buffer 更新**：将 refill_buf 的内容写入 SRAM。
3. **读取**：正常取指时，每拍查询 BTB。

**读取的两个子条件**：
- `pcgen_btb_chgflw && !way_pred_error && !btb_miss`：发生了跳转（chgflw），但 way 预测正确、且 IB 级不需要 BTB miss 处理——此时用 chgflw 后的新 PC 查 BTB。注意当 `way_pred_error || btb_miss` 时故意**不读**，因为此时 refill_buf 需要更新到 BTB（后续的写入优先），同时避免 SRAM 竞争。
- `!pcgen_btb_chgflw && !pcgen_btb_stall`：没有发生跳转，正常顺序取指且流水线未 stall，每拍读 BTB 为下一周期预测。

### 4.2 Data Array 的 cen_b 生成

```verilog
// ct_ifu_btb.v 第 324-334 行
assign btb_data_cen_b = !(cp0_ifu_btb_en && refill_buf_updt_vld) &&
                        !btb_data_rd;

assign btb_data_rd    = cp0_ifu_btb_en &&
                        (
                          (pcgen_btb_chgflw &&
                           !ipctrl_btb_way_pred_error &&
                           !ibdp_btb_miss) ||
                          (!pcgen_btb_chgflw &&
                           !pcgen_btb_stall)
                         );
```

与 Tag Array 相比，**Data Array 无 INV 写入使能**——这是因为 INV 只需要清除 valid 位即可使条目失效，valid 位在 Tag Array 中（`tag_vld_din`），Data Array 的内容在 valid=0 时不会被使用，无需单独清零。

### 4.3 三种情况的优先级

```
优先级（高 → 低）：INV 写 > Refill Buffer 写 > 正常读
```

体现在 `btb_tag_cen_b` 的 OR 逻辑上：任何一种需要激活的情况为真，cen_b 就拉低。而 Index 的选择（第 379-391 行）也遵循相同优先级：

```verilog
// ct_ifu_btb.v 第 379-391 行（Index 多路选择）
always @(...) begin
  if(btb_inv_on_reg)           // 最高优先级：INV
    btb_index = btb_inval_cnt;
  else if(refill_buf_updt_vld) // 次级：Refill Buffer 写入
    btb_index = refill_buf_index;
  else                          // 最低：正常顺序取指
    btb_index = pcgen_btb_index;
end
```

---

## 5. 写入逻辑

### 5.1 INV 写入（valid = 0）

INV（Invalidate）是把 BTB 全部 valid 位清零的操作。

```verilog
// ct_ifu_btb.v 第 277-289 行
always @(...) begin
  if(btb_inv_on_reg)                          // INV 优先级最高
    btb_tag_wen[3:0] = 4'b00;                 // 4 路全部选中写入
  else if(cp0_ifu_btb_en && refill_buf_updt_vld)
    btb_tag_wen[3:0] = refill_buf_wen[3:0];   // 只写特定路
  else
    btb_tag_wen[3:0] = 4'b1111;               // 禁止写（全 1 = 全禁止）
end

// 写入数据：valid=0, tag=0
assign tag_vld_din = refill_buf_updt_vld ? 1'b1 : 1'b0;
// INV 时 refill_buf_updt_vld=0 → tag_vld_din=0 → valid=0
assign btb_tag_din[21:0] = {tag_vld_din, refill_buf_tag[9:0],
                            tag_vld_din, refill_buf_tag[9:0]};
```

INV 时：`wen = 4'b0000`（全路使能写入），写入数据 valid=0，tag=0。每拍写一个 index（由 `btb_inval_cnt` 递减给出），逐行清零。

### 5.2 wen 编码：{!fifo_bit, fifo_bit} 的含义

正常更新时每次只写 **1 个槽**。`refill_buf_wen` 是低有效的 4 位 one-hot
写禁止码，决定四个槽中的哪一个被改写：

```verilog
// ct_ifu_btb.v 第 291-294 行
assign refill_buf_wen[3:0] = {~(refill_buf_tag[2:1]== 2'b11),
                              ~(refill_buf_tag[2:1]== 2'b10),
                              ~(refill_buf_tag[2:1]== 2'b01),
                              ~(refill_buf_tag[2:1]== 2'b00)};
```

`refill_buf_tag[2:1]` 来自内部 `rtl_vpc[2:1]`，对应架构字节地址 `[3:2]`。这 2 位共 4 种取值，决定写哪路：

| `tag[2:1]`（= `rtl_vpc[2:1]` = `byte_vpc[3:2]`） | wen[3:0] | 写入路 |
|---------------------------|----------|--------|
| 2'b00 | 4'b1110 | Way0 |
| 2'b01 | 4'b1101 | Way1 |
| 2'b10 | 4'b1011 | Way2 |
| 2'b11 | 4'b0111 | Way3 |

**为什么用字节地址 `[3:2]` 决定槽号？**

四个槽对应 16 字节取指块中的四个 4 字节位置组。这是**确定性放置**，不是
伪随机替换，也不是四路组相联：同一个 4 字节位置内的两个半字起点会映射到
同一槽，`tag[0]` 用于区分它们，但后写者会覆盖前者。这样省掉替换状态和选择
逻辑，代价是固定位置冲突；目标预测错误最终由后级 `addrgen`/BJU 纠正。

从注释中可以看到原始解释（第 274-276 行）：

```verilog
// ct_ifu_btb.v 第 274-276 行
//  wen[1:0] = {!(pc[3]^pc[2]), pc[3]^pc[2]}
```

当前 RTL 的实际实现直接对 `refill_buf_tag[2:1]` 做 4 选 1 译码。阅读历史注释时必须先确认它使用的是字节地址位号还是已经右移一位的内部 PC 位号，不能把两套位号直接混用。

### 5.3 Refill Buffer 写入（正常填充）

当 `refill_buf_updt_vld = 1` 时，将 refill_buf 的内容写入 BTB SRAM：

```verilog
// Tag Array 写入数据（第 304-307 行）
assign tag_vld_din = refill_buf_updt_vld ? 1'b1 : 1'b0;  // valid=1
assign btb_tag_din[21:0] = {tag_vld_din, refill_buf_tag[9:0],
                            tag_vld_din, refill_buf_tag[9:0]};
// 注意：同样的 tag 和 valid 写入 bank0 和 bank1

// Data Array 写入数据（第 365-366 行）
assign btb_data_din[43:0] = {refill_buf_way_pred[1:0], refill_buf_target_pc[19:0],
                             refill_buf_way_pred[1:0], refill_buf_target_pc[19:0]};
// 同样的 (way_pred, target) 写入 bank0 和 bank1
```

tag 和 data 的 `din` 都广播到两个 bank，但低有效 `wen` 只使能一个槽：

- `wen[1:0]` 控制 bank0（way0、way1）
- `wen[3:2]` 控制 bank1（way2、way3）

写入的 valid=1 表示该条目已填充，下次查找可以参与比较。

### 5.4 为什么 first 包写 valid=0，last 包才写 valid=1

这一设计防止了**写写冲突**下的虚假命中。

当 addrgen 开始更新时（`addrgen_btb_update_vld = 1`），refill_buf 先捕获 index/tag/target（第一阶段），但此时 icache way 预测（`way_pred`）还不知道——way_pred 需要等 IP 级流水线走完才能得到，大约 2 拍后。

因此：
1. **addrgen_btb_update_vld 时**：refill_buf_valid 设为 **0**（第 781-783 行）
2. **2 拍后（btb_miss_way_pred_rd 时）**：way_pred 已知，refill_buf_valid 设为 **1**（第 777-778 行）

```verilog
// ct_ifu_btb.v 第 771-786 行
always @(posedge refill_buf_updt_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    refill_buf_valid <= 1'b0;
  else if(btb_inv_on_reg)
    refill_buf_valid <= 1'b0;
  else if(btb_miss_way_pred_rd)       // 2拍延迟后，way_pred 已就绪
    refill_buf_valid <= 1'b1;
  else if(ipctrl_btb_way_pred_error && !chgflw_higher_than_ip)
    refill_buf_valid <= 1'b1;         // way 预测错误时也置位
  else if(ibdp_btb_miss && !chgflw_higher_than_ip ||
          addrgen_btb_update_vld)
    refill_buf_valid <= 1'b0;         // miss/update 时先清零
  else
    refill_buf_valid <= refill_buf_valid;
end
```

只有 `refill_buf_valid = 1` 时，`refill_buf_updt_vld` 才能被拉高，才会真正写入 BTB SRAM。

---

## 6. 读取流程（两拍）

### 6.1 时序图

```
周期：    N         N+1
           │         │
PCGEN    送出 index  ←───── btb_tag_rd/btb_data_rd 激活 SRAM
SRAM     读取中     数据稳定 (btb_tag_dout / btb_data_dout)
btb_rd_flop  0      1   ←── 表示"数据就绪"的标志
IF 级    处理 N-1的结果  处理 N 的 BTB 结果（做 tag 比较）
```

**第 N 拍（pcgen 级）**：`pcgen_btb_index` 送入 SRAM 地址线，`btb_tag_cen_b` / `btb_data_cen_b` 拉低，SRAM 开始读取。

**第 N+1 拍（IF 级）**：SRAM 输出稳定，`btb_rd_flop = 1`，表示本拍的数据来自上拍的读请求（即 `btb_tag_dout` / `btb_data_dout` 有效）。IF 级对 4 路的 tag 做比较，决定哪路命中。

### 6.2 btb_rd_flop：读取完成标志

```verilog
// ct_ifu_btb.v 第 454-464 行
always @(posedge btb_dout_flop_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    btb_rd_flop <= 1'b0;
  else if(btb_inv_on_reg)
    btb_rd_flop <= 1'b0;
  else if(btb_tag_rd)          // 上一拍发起了读请求
    btb_rd_flop <= 1'b1;       // 本拍数据就绪
  else
    btb_rd_flop <= 1'b0;
end
```

`btb_rd_flop` 是一个"读有效"指示：当它为 1 时，`btb_tag_dout` / `btb_data_dout` 的内容是本拍有效的。

### 6.3 btb_tag_dout_reg / btb_data_dout_reg：保持寄存器

```verilog
// ct_ifu_btb.v 第 493-519 行
always @(posedge btb_dout_flop_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    btb_tag_dout_reg[43:0] <= 44'b0;
  else if(btb_inv_on_reg)
    btb_tag_dout_reg[43:0] <= 44'b0;
  else if(btb_rd_flop && !ip_way_mispred)    // 只有 way 预测正确时才更新
    btb_tag_dout_reg[43:0] <= btb_tag_dout[43:0];
  else
    btb_tag_dout_reg[43:0] <= btb_tag_dout_reg[43:0];  // 保持
end
```

**为什么需要这两个寄存器？**

有时 BTB 输出结果不是直接来自 SRAM（如 way_pred 错误时 SRAM 被用于写入，`btb_rd_flop = 0`），IP 级仍然需要有数据可用。这两个寄存器保存"上一次有效读出的值"，作为备份。

**数据选择逻辑**（以 way0 为例）：

```verilog
// ct_ifu_btb.v 第 523-534 行
assign btb_mem_way0_valid = (btb_rd_flop && !ip_way_mispred)
                          ? btb_tag_dout[10]      // 直接用 SRAM 输出（最新）
                          : btb_tag_dout_reg[10]; // 用保持寄存器（备份）
```

### 6.4 ip_way_mispred 时为什么不更新寄存器

```verilog
// ct_ifu_btb.v 第 507 行
assign ip_way_mispred = ipctrl_btb_way_pred_error;
```

当 IP 级检测到 icache way 预测错误时（`ip_way_mispred = 1`）：

1. 流水线需要重新发射（reissue）——这条指令的取指结果不可用。
2. 此时 BTB 的 SRAM 可能正在进行 refill 写入（`refill_buf_updt_vld = 1`），读出的数据并非正常读操作的结果，不能信任。
3. 保留 `btb_tag_dout_reg` 的旧值，等待 reissue 时重新正确读出，下次 `btb_rd_flop=1 && !ip_way_mispred` 时再更新。

注释中明确说明（第 490-492 行）：

```verilog
// ct_ifu_btb.v 第 490-492 行
//When ip_way_mispred, cancel the update of btb_tag_dout_reg
//Maintain the Value of btb_tag_dout_reg as the result of
//Reissue BTB Read
```

---

## 7. Refill Buffer 详解

Refill Buffer 是 BTB 设计中最精巧的部分，理解它需要先理解**为什么不能在 miss 时立刻写 BTB**。

### 7.1 不能立刻写入的根本原因

BTB Data Array 中每个条目存储 `way_pred[1:0]`（icache way 预测）。这个字段的含义是：当 CPU 下次从这个分支目标地址取指时，预计取指包落在 I-Cache 的哪个 way，从而在 IP 级就提前发起 I-Cache 的 way 读，节省 1 拍延迟。

```
时间线（以 addrgen 报告一次 BTB miss 为例）：

  addrgen 级：计算出 target_pc，知道 index/tag/target   ← 第 0 拍
  IF 级：向 I-Cache 发出取指请求                         ← 第 1 拍
  IP 级：I-Cache 返回数据，icache way pred 已知           ← 第 2 拍

  问题：在第 0 拍时，way_pred 还未知，无法完整填充 BTB！
```

如果强行在第 0 拍写入，way_pred 字段只能写入一个"默认值"或"猜测值"，下次命中时 way 预测大概率错误，引发 reissue。

**解决方案**：使用 Refill Buffer，先把已知的字段（index、tag、target）缓存，等 2 拍后 way_pred 可知再一并写入 BTB。

### 7.2 Refill Buffer 的 5 个字段

| 字段 | 宽度 | 来源 | 含义 |
|------|------|------|------|
| `refill_buf_index` | 10 位 | `addrgen_btb_index` 或 `btb_index_pc_record[12:3]` | 写入哪个 SRAM 行 |
| `refill_buf_tag` | 10 位 | `addrgen_btb_tag` 或重构 tag | Tag Array 写入值 |
| `refill_buf_target_pc` | 20 位 | `addrgen_btb_target_pc` 或 `btb_target_pc_record` | 目标 PC 低 20 位 |
| `refill_buf_way_pred` | 2 位 | `ipctrl_btb_way_pred`（2 拍后） | icache way 预测 |
| `refill_buf_valid` | 1 位 | 状态机控制 | 本 buf 内容是否完整可写 |

### 7.3 两拍延迟的实现

```verilog
// ct_ifu_btb.v 第 795-819 行

// 第 1 拍：addrgen 报告 update
always @(posedge refill_buf_updt_clk or negedge cpurst_b)
begin
  ...
  else if(addrgen_btb_update_vld && !chgflw_higher_than_addrgen)
    after_addrgen_btb_chgflw_first <= 1'b1;  // 第 1 拍标记
  else
    after_addrgen_btb_chgflw_first <= 1'b0;
end

// 第 2 拍：等待 IF 级完成（pcgen 不 stall）
always @(posedge refill_buf_updt_clk or negedge cpurst_b)
begin
  ...
  else if(after_addrgen_btb_chgflw_first && !chgflw_higher_than_if && !pcgen_stall)
    after_addrgen_btb_chgflw_second <= 1'b1;  // 第 2 拍标记
  else
    after_addrgen_btb_chgflw_second <= 1'b0;
end

assign btb_miss_way_pred_rd = after_addrgen_btb_chgflw_second;
```

两个移位寄存器 `first`→`second` 构成一个 2 级流水延迟。`after_addrgen_btb_chgflw_second` 为 1 时（即 `btb_miss_way_pred_rd = 1`），此时 IP 级已经完成了 I-Cache 访问，`ipctrl_btb_way_pred` 有效，可以读取 way_pred 并置位 `refill_buf_valid`：

```verilog
// ct_ifu_btb.v 第 756-768 行（way_pred 更新时机）
always @(posedge refill_buf_updt_clk or negedge cpurst_b)
begin
  ...
  else if(btb_miss_way_pred_rd)   // 2 拍延迟后，IP 级 way_pred 已知
    refill_buf_way_pred[1:0] <= ipctrl_btb_way_pred[1:0];
  else if(ipctrl_btb_way_pred_error && !chgflw_higher_than_ip)
    refill_buf_way_pred[1:0] <= ipctrl_btb_way_pred[1:0];
  ...
end
```

### 7.4 refill_buf_valid 的完整置位/清零逻辑

```
refill_buf_valid 状态机：

初始/复位/INV ────────────────────────────────────────► 0

0 ──[btb_miss_way_pred_rd]──────────────────────────► 1
0 ──[ipctrl_btb_way_pred_error && !higher_than_ip]──► 1

1 ──[ibdp_btb_miss && !higher_than_ip]──────────────► 0  (写入触发)
1 ──[addrgen_btb_update_vld]────────────────────────► 0  (新 miss，旧 buf 失效)
1 ──[ipctrl_btb_way_pred_error && !higher_than_ip]──► 1  (更新 buf 内容，保持有效)
1 ──[btb_miss_way_pred_rd]──────────────────────────► 1  (完成填充，保持有效)
```

### 7.5 何时把 refill_buf 写入 BTB SRAM

```verilog
// ct_ifu_btb.v 第 788-791 行
assign refill_buf_updt_vld = (ibdp_btb_miss ||
                              ipctrl_btb_way_pred_error) &&
                              !chgflw_higher_than_ip &&
                              refill_buf_valid;
```

**三个条件必须同时满足**：

1. **触发条件**：`ibdp_btb_miss`（IB 级检测到 BTB miss）或 `ipctrl_btb_way_pred_error`（IP 级 way 预测错误）——下次命中时才写入，是"懒写"（lazy update）策略。
2. **无更高优先级的 chgflw**：如果有更高优先级的跳转（例如来自 EXU 的分支纠错），当前流水线要被清空，这次 refill 没有意义，跳过。
3. **buf 内容完整**：`refill_buf_valid = 1`，即 way_pred 已经获取完毕，buf 内容是完整且可信的。

---

## 8. Index PC Record

### 8.1 用途与背景

`btb_index_pc_record` 是一个 39 位寄存器（`btb_index_pc_record[PC_WIDTH-2:0]`，`PC_WIDTH=40`），保存**上一次在 IP 级发生 chgflw 时的 VPC**。

为什么要记录这个？因为 way 预测错误是在 IP 级检测到的，而此时我们需要重新填充 Refill Buffer（更新正确的 way_pred）。但填充 refill_buf 需要知道**发生 chgflw 的那条分支指令的 VPC**（用于推算 index 和 tag），而在 IP 级检测到 way 预测错误时，pcgen 已经进入了新的状态，原始 VPC 已经"消失"了。

### 8.2 记录时机

```verilog
// ct_ifu_btb.v 第 421-433 行
assign index_pc_record_clk_en = btb_inv_on_reg || ipctrl_btb_chgflw_vld;

always @(posedge index_pc_record_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    btb_index_pc_record[PC_WIDTH-2:0] <= {PC_WIDTH-1{1'b0}};
  else if(btb_inv_on_reg)
    btb_index_pc_record[PC_WIDTH-2:0] <= {PC_WIDTH-1{1'b0}};
  else if(ipctrl_btb_chgflw_vld)
    btb_index_pc_record[PC_WIDTH-2:0] <= ipdp_btb_index_pc[PC_WIDTH-2:0]; // IP 级 VPC
  else
    btb_index_pc_record[PC_WIDTH-2:0] <= btb_index_pc_record[PC_WIDTH-2:0];
end
```

每次 IP 级发生 chgflw（`ipctrl_btb_chgflw_vld = 1`），就用 `ipdp_btb_index_pc` 更新记录。同步也记录了 target PC（第 435-445 行），逻辑相同。

### 8.3 way 预测错误时如何使用记录

当 `ipctrl_btb_way_pred_error = 1` 时（在 IP 级）：

```verilog
// ct_ifu_btb.v 第 719-720 行（refill_buf_index 更新）
else if(ipctrl_btb_way_pred_error && !chgflw_higher_than_ip)
  refill_buf_index[9:0] <= btb_index_pc_record[12:3]; // 用记录的 VPC 推算 index

// ct_ifu_btb.v 第 749-750 行（refill_buf_tag 更新）
else if(ipctrl_btb_way_pred_error && !chgflw_higher_than_ip)
  refill_buf_tag[9:0] <= {btb_index_pc_record[19:13], btb_index_pc_record[2:0]};
  // 用记录的 VPC 重构 tag = {vpc[19:13], vpc[2:0]}
```

**时序关系**：
- 上一拍：IP 级 chgflw，记录 VPC → `btb_index_pc_record`
- 本拍：检测到 way 预测错误，用 `btb_index_pc_record` 更新 refill_buf

这正好是连续两拍：先记录、再用记录做纠错，时序上自洽。

---

## 9. INV 机制

### 9.1 INV 触发与流程

INV（Invalidate）用于**清空整个 BTB**，在以下场景触发：
- 处理器复位之后的初始化
- fence.i 指令（指令 cache 失效）
- 某些异常返回导致地址空间切换

```verilog
// ct_ifu_btb.v 第 636-648 行
parameter INV_CNT_VAL = 10'b0111111111;  // = 511

always @(posedge btb_inv_reg_upd_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    btb_inval_cnt[9:0] <= 10'b0;
  else if(btb_inv_on_reg)
    btb_inval_cnt[9:0] <= btb_inval_cnt[9:0] - 10'b1;  // 每拍减 1
  else if(ifctrl_btb_inv)
    btb_inval_cnt[9:0] <= INV_CNT_VAL;                  // 从 511 开始倒计
  else
    btb_inval_cnt[9:0] <= btb_inval_cnt[9:0];
end

always @(posedge btb_inv_reg_upd_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    btb_inv_on_reg <= 1'b0;
  else if(!(|btb_inval_cnt[9:0]) && btb_inv_on_reg)
    btb_inv_on_reg <= 1'b0;    // 计数到 0，INV 完成
  else if(ifctrl_btb_inv)
    btb_inv_on_reg <= 1'b1;    // 触发 INV
  else
    btb_inv_on_reg <= btb_inv_on_reg;
end
```

### 9.2 为什么是 512 次？

`INV_CNT_VAL=511`，状态机依次访问物理行 511 到 0。两个 SRAM bank 共用
`btb_index[8:0]`、`cen_b` 和时钟，每拍并行写同一行；`wen=4'b0000` 又让
该行的四个槽全部写入 `valid=0`。因此 512 拍恰好覆盖
`512 行 × 4 槽 = 2048 槽`。计数器和接口虽然是 10 位，但本次计数过程中
bit9 恒为 0，而且当前 SRAM 实例本来也不使用该位。

### 9.3 状态输出

```verilog
// ct_ifu_btb.v 第 665-666 行
assign btb_ifctrl_inv_done = !btb_inv_on_reg;  // INV 完成标志（反相）
assign btb_ifctrl_inv_on   = btb_inv_on_reg;   // INV 进行中标志
```

ifctrl 模块根据这两个信号决定是否可以恢复正常取指。

---

## 10. chgflw 优先级信号

### 10.1 三个优先级信号的含义

```verilog
// ct_ifu_btb.v 第 822-825 行
assign chgflw_higher_than_ip      = pcgen_btb_chgflw_higher_than_ip;
assign chgflw_higher_than_addrgen = pcgen_btb_chgflw_higher_than_addrgen;
assign chgflw_higher_than_if      = pcgen_btb_chgflw_higher_than_if;
assign pcgen_stall                = pcgen_btb_stall;
```

这三个信号来自 pcgen，表示**当前周期有某种更高优先级的跳转（chgflw）正在发生，会覆盖/取消流水线某些级的操作**。

| 信号 | 含义 | 在 BTB 中的作用 |
|------|------|----------------|
| `chgflw_higher_than_ip` | 有比 IP 级更高优先级的跳转（如 EXU 纠错） | 阻止 IP 级的 way_pred_error 写入 refill_buf；阻止 refill_buf_updt_vld |
| `chgflw_higher_than_addrgen` | 有比 addrgen 更高优先级的跳转 | 阻止 addrgen 的更新写入 refill_buf（addrgen 的结果会被丢弃） |
| `chgflw_higher_than_if` | 有比 IF 级更高优先级的跳转 | 阻止 `after_addrgen_btb_chgflw_second` 前进（IF 级被冲刷） |

### 10.2 优先级保护的逻辑

以 refill_buf_index 更新为例：

```verilog
// ct_ifu_btb.v 第 717-722 行
else if(addrgen_btb_update_vld && !chgflw_higher_than_addrgen)
  refill_buf_index[9:0] <= addrgen_btb_index[9:0];    // 保护：更高优先跳转时不写
else if(ipctrl_btb_way_pred_error && !chgflw_higher_than_ip)
  refill_buf_index[9:0] <= btb_index_pc_record[12:3]; // 保护：更高优先跳转时不写
```

**为什么需要这些保护？**

C910 的 IFU 是多级流水，多个级之间可以同时有多个"分支跳转"在处理（IP 级在处理一个，addrgen 在处理另一个）。当 EXU（执行单元）发现分支预测错误并发出纠错跳转时，这是最高优先级，会冲刷 IP 级和 addrgen 级。此时这些级的操作（way_pred 更新、target 更新等）基于错误的执行路径，不应写入 refill_buf，否则会污染 BTB。

优先级信号就是这套冲刷机制的"令牌"：谁持有令牌（chgflw 的发起者），谁的操作有效；被令牌覆盖的低优先级操作被屏蔽。

---

## 11. 完整数据流示例

### 11.1 场景：首次遇到一条分支（BTB miss）

```
周期  流水级  事件
──────────────────────────────────────────────────────────────────
 T0   PCGEN   pcgen 取 PC=0x1000，btb_tag_rd=1，送 index=vpc[12:3] 给 SRAM
 T1   IF      SRAM 输出有效，btb_rd_flop=1，IF 比较 4 路 tag，全部 miss
              ibdp_btb_miss（等到 IB 级才确认 miss）
 T2   IP      L0 BTB 也未命中（假设），顺序取指，取到了分支指令
              decode 发现是分支，送给 addrgen 计算目标地址
 T3   addrgen 计算出 target_pc，addrgen_btb_update_vld=1
              refill_buf_index, refill_buf_tag, refill_buf_target_pc 更新
              after_addrgen_btb_chgflw_first = 1
              refill_buf_valid = 0（way_pred 还未知）
 T4   IF      分支目标地址的取指包在 IF 级
              after_addrgen_btb_chgflw_second = 1（first 移位来的）
              btb_miss_way_pred_rd = 1
              ipctrl_btb_way_pred 此时有效（IP 级已看到 icache 命中哪路）
              refill_buf_way_pred 更新为 ipctrl_btb_way_pred
              refill_buf_valid = 1（完整了！）
 T5   IB      IB 级确认之前那条分支 miss（ibdp_btb_miss=1）
              refill_buf_updt_vld = 1（条件满足：miss + !higher + valid）
              btb_index = refill_buf_index
              BTB SRAM 写入：tag array 写 valid=1, tag；data array 写 way_pred, target
──────────────────────────────────────────────────────────────────
```

### 11.2 场景：BTB 命中，icache way 预测正确

```
周期  流水级  事件
──────────────────────────────────────────────────────────────────
 T0   PCGEN   btb_tag_rd=1，送 index
 T1   IF      SRAM 输出，btb_rd_flop=1，tag 比较命中 way2
              btb_ifdp_way2_vld=1, target 送出 → 下一拍取指该地址
 T2   IP      I-Cache 返回数据，way_pred 与存储值吻合，ipctrl_btb_way_pred_error=0
              流水线正常前进，无需任何更新
──────────────────────────────────────────────────────────────────
```

### 11.3 场景：BTB 命中，但 icache way 预测错误

```
周期  流水级  事件
──────────────────────────────────────────────────────────────────
 T0   PCGEN   btb_tag_rd=1，送 index
 T1   IF      SRAM 输出，命中 way2，btb_ifdp_way2_way_pred = 2'b01（预测 way1）
 T2   IP      I-Cache 实际命中 way3，ipctrl_btb_way_pred_error=1
              流水线 reissue，取指重新执行
              btb_index_pc_record（T1 时已更新）→ 用于重算 refill_buf index/tag
              refill_buf_index/tag/target 用 btb_index_pc_record 更新
              refill_buf_way_pred <= ipctrl_btb_way_pred（正确的 way3 = 2'b10）
              refill_buf_valid = 1
 T3   IP(reissue) 或 IB  再次遇到 ibdp_btb_miss 或 way_pred_error
              refill_buf_updt_vld=1，将正确的 way_pred 写入 BTB SRAM
              下次该分支命中时，way 预测将正确
──────────────────────────────────────────────────────────────────
```

---

## 附录：关键信号速查表

| 信号名 | 方向 | 宽度 | 含义 |
|--------|------|------|------|
| `pcgen_btb_index` | in | 10 | 顺序取指时的 BTB index |
| `pcgen_btb_chgflw` | in | 1 | 本周期发生了跳转 |
| `pcgen_btb_stall` | in | 1 | pcgen 级 stall |
| `addrgen_btb_index` | in | 10 | 分支目标地址对应的 BTB index |
| `addrgen_btb_tag` | in | 10 | 分支 PC 对应的 BTB tag |
| `addrgen_btb_target_pc` | in | 20 | 分支目标 PC 低 20 位 |
| `addrgen_btb_update_vld` | in | 1 | addrgen 有效更新（miss 或初次建立） |
| `ibdp_btb_miss` | in | 1 | IB 级确认 BTB miss |
| `ipctrl_btb_chgflw_vld` | in | 1 | IP 级 chgflw 有效 |
| `ipctrl_btb_way_pred` | in | 2 | IP 级的 icache way 预测结果 |
| `ipctrl_btb_way_pred_error` | in | 1 | IP 级 way 预测出错 |
| `ipdp_btb_index_pc` | in | 39 | IP 级 VPC（用于 record） |
| `ipdp_btb_target_pc` | in | 20 | IP 级目标 PC（用于 record） |
| `ifctrl_btb_inv` | in | 1 | INV 触发信号 |
| `btb_ifdp_way{n}_vld` | out | 1 | Way n 是否有效 |
| `btb_ifdp_way{n}_tag` | out | 10 | Way n 的 tag |
| `btb_ifdp_way{n}_target` | out | 20 | Way n 的目标 PC 低 20 位 |
| `btb_ifdp_way{n}_pred` | out | 2 | Way n 的 icache way 预测 |
| `btb_ifctrl_inv_on` | out | 1 | INV 进行中 |
| `btb_ifctrl_inv_done` | out | 1 | INV 完成 |
| `pcgen_btb_chgflw_higher_than_ip` | in | 1 | 有更高优先级跳转（相对 IP 级） |
| `pcgen_btb_chgflw_higher_than_addrgen` | in | 1 | 有更高优先级跳转（相对 addrgen） |
| `pcgen_btb_chgflw_higher_than_if` | in | 1 | 有更高优先级跳转（相对 IF 级） |

---

*文档基于 C910 开源 RTL（Apache 2.0 协议），`ct_ifu_btb.v` 版本共 861 行。*
