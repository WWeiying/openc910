# ct_ifu_ipdp 详解：IP 级数据通路

## 1. 模块概述

`ct_ifu_ipdp`（IP Stage Data Path）是 C910 处理器 IFU 中**代码量最大的模块**（6872 行），是 IP 流水级的数据通路核心。其主要职责是：

1. **接收 IF 级取回的 cache 数据**（H1~H8，每个 half-word 16 位）并缓存残留的 H0
2. **实例化两套预解码器**（ct_ifu_ipdecode × 2），分别针对 Way0 和 Way1 并行解码
3. **提取每条指令的分支属性**（con_br、jal、jalr、call/return 等）
4. **确定第一条分支指令及其 offset**，并计算目标 PC 范围信息
5. **融合 BHT、L0 BTB、BTB、RAS** 的预测信息
6. **维护 vtype（vlmul/vsew/vl）寄存器**，支持 RVV 扩展的向量长度预测
7. **向 IB 级（ibdp）打包每个 Hn 的完整解码信息**

模块与 `ct_ifu_ipctrl` 紧密耦合：ipctrl 生成控制信号，ipdp 执行数据操作并反馈诊断信号（ipdp_ipctrl_* 系列）给 ipctrl 做决策。

---

## 2. 模块结构总览

### 2.1 H0~H8 的含义

C910 每个周期从 I-Cache 读取一个 128 位、16 字节取指块，共 8 个 16-bit half-word，在 ipdp 中命名为 **H1~H8**（bit[7:0] 各对应一个 half-word，bit[7] = H1，bit[0] = H8）。一个 64 字节 cache line 包含 4 个这样的取指块。

另外，**H0** 是一个特殊的缓存寄存器：

```verilog
// 行 5730-5731
h0_cur_pc[35:0] <= ip_vpc[PC_WIDTH-2:3]; // H0 所属的 16 字节取指块号
h0_data[15:0]   <= h8_data[15:0];        // H0 的数据就是上一次取指的 H8
```

H0 产生的场景：当前 16 字节取指块的最后一个 half-word（H8）是一条 32-bit 指令的低半字。此时 H8 存入 H0，下一取指块到来后再与新的 H1 拼成完整的 32-bit 指令。

### 2.2 数据流

```
                    ┌─────────────────────────────────────────────┐
                    │              ct_ifu_ipdp                     │
                    │                                              │
ifdp → H1~H8 data  │→  两套 ipdecode（Way0 / Way1）              │
       BTB 数据     │→  分支信息提取（br, con_br, ab_br, etc.）   │
       L0 BTB 数据  │→  分支 offset 计算                          │
                    │→  第一分支定位（casez on branch[7:0]）       │
                    │→  BHT 数据读取（bht_pre_result）             │
                    │→  vtype 寄存器维护                           │
                    │→  H0 寄存器维护                              │
                    │→  chgflw_mask / hn_vld 生成                  │
                    │↓                                              │
ipctrl ←           │   ipdp_ipctrl_* 反馈信号                     │
ibdp ←             │   ipdp_ibdp_hn_* 系列（每周期打包输出）      │
                    └─────────────────────────────────────────────┘
```

---

## 3. 端口结构总览

ipdp 的输入/输出极其丰富（约 200 个端口）。以下按功能分组列出关键信号：

### 3.1 来自 ifdp 的指令数据

每个 half-word（H1~H8）对应：
- `ifdp_ipdp_h1_inst_high_way0[13:0]`：16-bit 指令的高 14 位（来自 Way0）
- `ifdp_ipdp_h1_inst_low_way0[1:0]`：16-bit 指令的低 2 位
- `ifdp_ipdp_h1_precode_way0[3:0]`：4-bit 预解码结果（bit[2]=br, bit[3]=ab_br）

> 指令被拆分为 high(14) + low(2) 传输，是因为 cache SRAM 的物理排布（低位与高位可能来自不同的 way 存储单元），合并后得到完整的 `h1_data[15:0] = {h1_high_way0[13:0], h1_low_way0[1:0]}`。

### 3.2 来自 BTB 的信息

```verilog
input [1:0]  ifdp_ipdp_btb_way0_pred;   // Way0 命中时该分支的 way 预测
input [9:0]  ifdp_ipdp_btb_way0_tag;    // BTB Way0 标记（用于验证命中）
input [19:0] ifdp_ipdp_btb_way0_target; // BTB Way0 存储的目标 PC 低 20 位
input        ifdp_ipdp_btb_way0_vld;    // BTB Way0 条目有效
// Way1~Way3 类似
```

BTB 是 4-way 组相联结构，每 way 对应取指窗口中不同位置的分支。

### 3.3 来自 L0 BTB 的信息

```verilog
input        ifdp_ipdp_l0_btb_hit;         // L0 BTB 命中
input [38:0] ifdp_ipdp_l0_btb_target;      // L0 BTB 预测的目标 PC
input [38:0] ifdp_ipdp_l0_btb_mispred_pc;  // L0 BTB 错误预测的 PC（用于 mistaken 纠正）
input        ifdp_ipdp_l0_btb_ras;         // L0 BTB 是否使用 RAS
input [15:0] ifdp_ipdp_l0_btb_entry_hit;   // L0 BTB 命中的 entry 位图（16位）
input [1:0]  ifdp_ipdp_l0_btb_way_pred;    // L0 BTB 记录的 way 预测
```

### 3.4 来自 BHT 的预测数据

```verilog
input [31:0] bht_ipdp_pre_array_data_ntake; // not-taken 表的 16 个 2-bit 计数器
input [31:0] bht_ipdp_pre_array_data_taken; // taken 表的 16 个 2-bit 计数器
input [15:0] bht_ipdp_pre_offset_onehot;    // PC 低位与 GHR 哈希后的计数器 one-hot 编号
input [1:0]  bht_ipdp_sel_array_result;     // 选择哪个数组的结果（taken 或 ntaken）
input [21:0] bht_ipdp_vghr;                 // 当前的全局历史寄存器（VGHR）
```

---

## 4. 预解码器实例化

### 4.1 双路并行解码

ipdp 同时实例化两个 `ct_ifu_ipdecode`，分别处理 Way0 和 Way1 的数据：

```verilog
// 行 2128-2206
ct_ifu_ipdecode  x_ct_ifu_ipdecode0 (
  .h0_data (h0_data),         // H0（残留字，两路共享）
  .h1_data (h1_data_way0),    // H1 来自 Way0
  ...
  .ipdecode_ipdp_branch (way0_branch),  // 各 half-word 是否是分支
  .ipdecode_ipdp_con_br (way0_con_br),  // 各 half-word 是否是条件分支
  .ipdecode_ipdp_jal    (way0_jal),
  .ipdecode_ipdp_jalr   (way0_jalr),
  .ipdecode_ipdp_h0_offset (way0_h0_offset), // H0 的分支 offset（21位）
  ...
);
ct_ifu_ipdecode  x_ct_ifu_ipdecode1 (
  ...  // Way1 相同结构，输出前缀 way1_
);
```

**为什么需要两路同时解码？** 在 IP 级进入时，还不知道哪个 way 命中（tag 比较结果在本周期才稳定），因此必须对 Way0 和 Way1 同时解码，等 `way0_hit` 信号稳定后再 mux 选择正确的结果。

### 4.2 预解码结果的含义

precode[3:0] 的每一位：

| 位 | 含义 |
|----|------|
| bit[0] | 32-bit 指令（low[1:0]==2'b11） |
| bit[1] | 未使用（原始 bry 信息） |
| bit[2] | **br**：是分支指令（con_br 或 ab_br 或 preturn） |
| bit[3] | **ab_br**：是无条件分支（absolute branch） |

precode 在 IF 级（ifdp）预先计算并存入 I-Cache，IP 级直接读取，无需重新解析指令 opcode。

### 4.3 inst[1:0] 决定指令宽度

```verilog
// 行 2399-2414
assign h1_32_way0 = (h1_low_way0[1:0] == 2'b11);
...
assign way0_32[7:0] = {h1_32_way0, h2_32_way0, ..., h8_32_way0};
```

RISC-V C 扩展规定：若指令的低 2 位 ≠ 2'b11，则是 16-bit 压缩指令；等于 2'b11 则是 32-bit 指令。此处通过每个 half-word 的 low 2 bits 一次性判断所有 8 个 half-word 是否是 32-bit 指令的起始位，生成 `way0_32[7:0]` 位图。

---

## 5. 指令有效性与边界处理

### 5.1 bry_data 掩码控制每个 half-word 的有效性

```verilog
// 行 2488-2499
assign br[7:0]      = br_pre[7:0]     & bry_data[7:0];
assign ab_br[7:0]   = ab_br_pre[7:0]  & bry_data[7:0];
assign con_br[7:0]  = con_br_pre[7:0] & bry_data[7:0];
assign jal[7:0]     = jal_pre[7:0]    & bry_data[7:0];
// ...
```

`bry_data[7:0]` 来自 ipctrl（`ipctrl_ipdp_bry_data`），它标记了当前取指窗口中哪些 half-word 是**合法的指令起始位置**。所有解码属性都要与 bry_data 做 AND，确保只有位于指令边界处的 half-word 产生有效信号。

### 5.2 32-bit 指令的特殊处理

```verilog
// 行 2509-2511
assign inst_32[7] = (h0_vld) ? 1'b0 : inst_32_pre[7];
assign inst_32[0] = (inst_32_pre[0]);
assign inst_32[6:1] = inst_32_pre[6:1];
```

当 `h0_vld=1` 时，H1（bit[7]）被 H0 的高半字占用，H1 本身是 32-bit 指令的**高半字**，不是新指令的起始，所以强制将 inst_32[7] 清零（表示 H1 不是一条 32-bit 新指令的起始）。

H8（bit[0]）始终按照 cache 中的实际值处理：如果 H8 的 `low[1:0]==2'b11`，说明 H8 是下一条 32-bit 指令的低半字，该指令跨到下一个 16 字节取指块，此时 `h0_vld_pre` 置 1，H8 内容存入 H0。

### 5.3 h0_vld_pre：判断 H0 是否应该有效

```verilog
// 行 5664-5667
assign h0_vld_pre = (inst_32[0] && bry_data[0]) &&  // H8 是 32-bit 指令
                    !(|chgflw[7:1])              &&  // 取指窗口中无跳转（没有被截断）
                    !ipctrl_ipdp_ip_pcload        &&  // IP 级不跳转
                    !ipctrl_ipdp_br_more_than_one_stall; // 没有多分支 stall
```

只有 H8 是 32-bit 指令**且**本次取指未发生跳转时，才将 H8 存为 H0。若发生跳转，顺序取指被中断，H0 无意义。

### 5.4 H0 数据更新时机

```verilog
// 行 5634-5661
always @(posedge forever_cpuclk or negedge cpurst_b)
begin
  if(!cpurst_b)        h0_vld <= 1'b0;
  else if(pipe_cancel) h0_vld <= 1'b0;  // 流水线取消时清零
  else if(pipe_stall)  h0_vld <= h0_vld; // stall 时保持
  else if(h0_update_vld && !ip_mmu_acc_deny)  // 有效更新
    h0_vld <= h0_vld_pre;
  else h0_vld <= h0_vld;
end
```

H0 的数据在 `h0_updt_clk`（门控时钟）上沿采样，该时钟的使能条件是 `ipctrl_ipdp_h0_updt_gateclk_en`，从而在不需要更新 H0 时关闭时钟，降低功耗。

---

## 6. H0 对 H1 解码信息的覆盖

H0 有效时，H1 实际上是 H0（上条指令的高半字），不是新指令起始。此时 H1 处（bit[7]）的所有解码信息应当来自 H0 的解码结果：

```verilog
// 行 2522-2530（Way0，bit[7] 位的处理）
assign way0_br_pre[7]      = (h0_vld) ? (h0_ab_br || h0_con_br || h0_preturn) 
                                       : (way0_br[7] || way0_preturn[7]);
assign way0_ab_br_pre[7]   = (h0_vld) ? h0_ab_br   : way0_ab_br[7];
assign way0_con_br_pre[7]  = (h0_vld) ? h0_con_br  : way0_con_br[7];
assign way0_jal_pre[7]     = (h0_vld) ? h0_jal     : way0_jal[7];
assign way0_jalr_pre[7]    = (h0_vld) ? h0_jalr    : way0_jalr[7];
```

同理，H8（bit[0]）的处理需要考虑该 half-word 是否是 32-bit 指令的低半字（如果是，则 H8 本身不是一条完整的指令起始，不能产生分支信号）：

```verilog
// 行 2543-2547
assign way0_br_pre[0]      = (inst_32_pre[0]) ? 1'b0 
                                              : (way0_br[0] || way0_preturn[0]);
assign way0_ab_br_pre[0]   = (inst_32_pre[0]) ? 1'b0 : way0_ab_br[0];
```

H2~H7（bit[6:1]）无特殊情况，直接使用预解码结果。

---

## 7. Way 选择：确定最终解码信息

```verilog
// 行 2640-2657
assign br_pre[7:0]     = (way0_hit) ? way0_br_pre[7:0]     : way1_br_pre[7:0];
assign ab_br_pre[7:0]  = (way0_hit) ? way0_ab_br_pre[7:0]  : way1_ab_br_pre[7:0];
assign con_br_pre[7:0] = (way0_hit) ? way0_con_br_pre[7:0] : way1_con_br_pre[7:0];
assign inst_32_pre[7:0]= (way0_hit) ? way0_32[7:0]         : way1_32[7:0];
// ...
```

`way0_hit` 来自 ipctrl（`ipctrl_ipdp_icache_way0_hit`）。当 Way0 命中时使用 Way0 的解码结果；否则使用 Way1。两套解码器并行运行，命中确定后一路 mux 完成。

---

## 8. BHT 数据应用：2-bit 计数器 MSB 作预测方向

### 8.1 选择 taken/ntaken 数组

```verilog
// 行 4826-4828
assign pre_array_data[31:0] = (bht_sel_result[1])
                            ? bht_ipdp_pre_array_data_taken[31:0]
                            : bht_ipdp_pre_array_data_ntake[31:0];
```

BHT 维护两个并行数组：taken 表和 ntaken 表。`bht_sel_result[1]` 决定选哪个，这是 2-level 自适应预测的实现之一。

### 8.2 用 pre_offset_onehot 定位当前分支

```verilog
// 行 4838-4858
case(bht_ipdp_pre_offset_onehot[15:0])
  16'b1000000000000000: bht_pre_result[1:0] = pre_array_data[31:30];
  16'b0100000000000000: bht_pre_result[1:0] = pre_array_data[29:28];
  // ...
  16'b0000000000000001: bht_pre_result[1:0] = pre_array_data[1:0];
  default             : bht_pre_result[1:0] = {2{1'bx}};
endcase
```

BHT 一次从 Taken 和 Not-Taken 两组各读出 16 个 2-bit 计数器。
`pre_offset_onehot[15:0]` 由内部半字地址 PC `[6:3]`（即字节 PC `[7:4]`）
与 GHR 低 4 位异或后生成，用它从选定的一组中取出对应的 2-bit 计数器。它表示
哈希后的表内编号，不是分支在 cache line 中的物理位置。

```verilog
// 行 4860-4863
assign bht_result = bht_pre_result[1];  // MSB 作为预测方向（1=taken）
assign ipdp_ipctrl_bht_result = bht_result;
assign ipdp_ipctrl_bht_data[1:0] = bht_pre_result[1:0];
```

2-bit 计数器的 MSB（最高位）作为预测方向。计数器值：
- 11 = Strongly Taken
- 10 = Weakly Taken
- 01 = Weakly Not Taken
- 00 = Strongly Not Taken

### 8.3 vghr 投机更新（Speculative GHR）

```verilog
// 行 5064-5071（con_br 处理逻辑）
// 向 BHT 反馈 con_br，BHT 模块用 bht_result 更新 vghr
assign ipdp_bht_vpc[PC_WIDTH-2:0]   = ip_vpc[PC_WIDTH-2:0];
assign ipdp_bht_h0_con_br            = h0_vld_pre && h0_con_br_pre && ipctrl_ipdp_bht_vld;
```

ipdp 将当前 VPC 和是否有条件分支（`ipdp_bht_h0_con_br`）发给 BHT 模块，BHT 在每个周期根据预测方向将一位追加到 GHR（Global History Register）中，实现投机更新。

---

## 9. 分支目标 PC 计算

### 9.1 branch[7:0] 的确定

```verilog
// 行 4935
assign branch[7:0] = ipctrl_ipdp_branch[7:0];
```

`branch` 是经过 ipctrl 综合 BHT 方向后产生的"本周期实际跳转的分支位图"：BHT 预测 taken 时取 `ip_chgflw_taken[7:0]`，预测 not taken 时取 `ip_chgflw_ntake[7:0]`。

### 9.2 base_pc_branch：分支基地址计算

```verilog
// 行 4975-5053（casez on branch[7:0]）
casez(branch[7:0])
  8'b1??????? : begin
    base_pc_branch[PC_WIDTH-2:0] = (h0_vld) 
                                 ? {h0_cur_pc[35:0], 3'b111}  // H0 有效，基地址=H0的PC
                                 : {ip_vpc[PC_WIDTH-2:3], 3'b000};  // 否则是 H1 的 PC
    btb_index_pc[PC_WIDTH-2:0]  = {ip_vpc[PC_WIDTH-2:3], 3'b000};
    offset_branch[20:0]         = (h0_vld) ? h0_offset[20:0] : h1_offset[20:0];
    end
  8'b01?????? : begin
    base_pc_branch = {ip_vpc[PC_WIDTH-2:3], 3'b001};  // H2 的 PC
    offset_branch  = h2_offset[20:0];
    end
  // ...
```

这是整个模块最核心的数据选择逻辑之一：根据 `branch[7:0]` 的最高有效位（第一条分支的位置），选择该分支对应的：
- **base_pc**：该分支指令自身的 PC（VPC 高位 + half-word 偏移）
- **offset**：分支指令中编码的相对偏移量（由 ipdecode 提取的 21-bit 符号扩展值）

> 分支目标 PC = base_pc + sign_extend(offset)，这一加法在 ibdp（IB 级数据通路）中完成。

### 9.3 BTB 目标 PC 的选择优先级

```verilog
// 行 5502-5547（BTB 命中选择）
if(|branch[7:6])      // H1~H2 处有分支
  使用 Way0 的 BTB 数据
else if(|branch[5:4]) // H3~H4 处有分支
  使用 Way1 的 BTB 数据
else if(|branch[3:2]) // H5~H6 处有分支
  使用 Way2 的 BTB 数据
else                  // H7~H8 处有分支
  使用 Way3 的 BTB 数据
```

4 路 BTB 的存储槽位对应取指窗口中不同位置的分支，按位置高低（H1 最高优先级）分配到 Way0~Way3。若某路 BTB valid 且 tag 匹配，则命中。

```verilog
// 行 5550-5552
assign btb_branch_miss = !btb_branch_way_vld ||
                         (btb_branch_tag[9:0] != {btb_index_pc[19:13], btb_index_pc[2:0]}) || 
                         !cp0_ifu_btb_en;
```

`btb_branch_miss` 为 1 时，BTB 中没有该分支的记录，需要通过计算值（base + offset）作为目标 PC，并在 IB 级将此信息写入 BTB（通过 `ipdp_ibdp_branch_btb_miss` 信号通知 ibdp）。

---

## 10. 条件分支 con_br 的特殊处理

条件分支（beq、bne、blt 等）与无条件分支（jal）不同，其目标 PC 在预测阶段可能不确定，需要额外的信息传递到 IB 级。

### 10.1 con_br 的位置定位

```verilog
// 行 5106-5196（casez on con_br[7:0]）
casez(con_br[7:0])
  8'b1??????? :
    base_pc_con_br = (h0_vld) ? {h0_cur_pc, 3'b111} : {ip_vpc[high:3], 3'b000};
    offset_con_br  = (h0_vld) ? h0_offset : h1_offset;
    inst_32_con_br = (h0_vld) ? 1'b1 : inst_32[7];  // H0 存在则必是 32-bit
    con_br_vmask   = 8'b10000000;  // 只有第一条 con_br 有效
  // ...
```

找到第一条条件分支的位置，记录：
- 其 PC（base_pc_con_br）
- 其 offset（offset_con_br）
- 是否是 32-bit 指令（inst_32_con_br）
- 在 8 个 half-word 中的掩码（con_br_vmask，用于 vtype 更新边界）

### 10.2 传递给 ibdp

```verilog
// 最终输出到 IB 级（寄存器形式）
ipdp_ibdp_con_br_cur_pc     // 条件分支的 PC
ipdp_ibdp_con_br_offset     // 条件分支的 offset
ipdp_ibdp_con_br_inst_32    // 是否 32-bit
ipdp_ibdp_con_br_num        // 条件分支的 half-word 编号（用于 IB 计数）
ipdp_ibdp_con_br_num_vld    // 有效标志
```

IB 级（ibdp）在执行阶段（EX）会用这些信息重新计算跳转目标并与 IFU 的预测结果比较。

---

## 11. "after_head" 机制：相对 VPC 的偏移重排

C910 中，IB 级接收的是每个 H 相对于 VPC 对齐基地址的偏移编号。ipdp 将所有 8 个 half-word 的属性信息"重排"，使得 H1 始终对应 VPC 起始位置处的第一个有效 half-word。

### 11.1 原理

以 vpc_onehot = 8'b01000000（从 H2 开始取指）为例，重排后：
- ipdp_ibdp_h1_data 实际上是原始 H2 的数据
- ipdp_ibdp_h2_data 是原始 H3 的数据
- ...以此类推

```verilog
// 行 4033-4042（inst_32_after_head 的例子）
case(vpc_onehot[7:0])
  8'b10000000: inst_32_after_head[7:0] =  inst_32[7:0];       // 从 H1 开始，无偏移
  8'b01000000: inst_32_after_head[7:0] = {inst_32[6:0], 1'b0}; // 从 H2 开始，左移 1
  8'b00100000: inst_32_after_head[7:0] = {inst_32[5:0], 2'b0}; // 从 H3 开始，左移 2
  // ...
```

所有属性（con_br、jal、jalr、fence、split0、split1、bkpta、bkptb 等）都做相同的位移操作，统称为 `*_after_head`。

### 11.2 为什么要重排？

IB 级（ibdp）接收来自 ipdp 的信息并维护一个环形指令缓冲。IB 级期望总是从"位置 0"（H1）开始填充，因此 ipdp 必须将起始偏移折叠掉，确保 IB 级总能从相同的基准位置读取指令。

### 11.3 hn_vld_after_head：每个 H 的有效性

```verilog
// hn_vld_after_head 由 ipdecode 的 bry_data 和 inst_32 共同决定
// 规则：bry_data[n]=1 且 inst_32[n]=0 → Hn 单独占一个槽（16-bit）
//       bry_data[n]=1 且 inst_32[n]=1 → Hn 和 Hn+1 一起（32-bit），Hn+1 不单独占槽
```

该信号标记了哪些 half-word 是独立指令起始，IB 级据此分配指令 entry。

---

## 12. "after_tail" 机制：分支截断

当条件分支 taken 时（`tail_vld = con_br_first_branch && bht_result`），分支后面的指令不该进入 IB 级（它们是错误路径）。ipdp 用 `chgflw_after_head[7:0]` 作为截断标记，将分支之后的所有属性位清零：

```verilog
// 行 4270-4463
casez(con_br_after_head[7:0])
  8'b1??????? :  // 第一个 con_br 在 bit[7]（H1 位置）
    mask_ab_br[7:0]  = {ab_br_after_head[7], 7'b0};   // 只保留 H1 的 ab_br
    mask_con_br[7:0] = {con_br_after_head[7], 7'b0};  // 只保留 H1 的 con_br
    mask_hn_vld[7:0] = (inst_32_after_head[7])
                     ? {hn_vld_after_head[7:6], 6'b0} // 32-bit：保留 H1+H2（高半字）
                     : {hn_vld_after_head[7],   7'b0}; // 16-bit：只保留 H1
  // ...
```

同时，`chgflw_mask[7:0]` 用于标记哪些 half-word 在分支后、应该被 mask：

```verilog
// 行 4475-4498
casez(chgflw_after_head[7:0])
  8'b1??????? : chgflw_mask[7:0] = (inst_32_after_head[7]) 
                                 ? 8'b11000000  // 32-bit：chgflw 占 2 个 half-word
                                 : 8'b10000000; // 16-bit：只占 1 个
  // ...
```

`chgflw_mask` 输出给 ibdp，ibdp 据此知道在第几个 half-word 之后停止加载（即"有效 half-word 数"）。

---

## 13. vtype 维护（RVV 向量扩展支持）

C910 支持 RISC-V V 扩展（RVV），指令解码时需要知道当前的向量长度（vl）、向量元素宽度（vsew）、向量寄存器分组（vlmul）。这三个值由 `vsetvli` 指令设置，ipdp 中维护这些寄存器并做周期内的传播。

### 13.1 vl/vsew/vlmul 寄存器

```verilog
// 行 2749-2776
always @(posedge forever_cpuclk or negedge cpurst_b)
begin
  if(!cpurst_b)
    vlmul_reg[1:0] <= 2'b0; vsew_reg <= 3'b0; vl_reg <= 8'b0;
  else if(vtype_updt_vld)
    vlmul_reg <= vlmul_updt_value; vsew_reg <= vsew_updt_value; vl_reg <= vl_updt_value;
  else  /* 保持 */;
end
```

### 13.2 更新来源（优先级顺序）

```verilog
// 行 2828-2876（优先级从高到低）
if(had_vtype_updt_vld)         使用 HAD（调试）注入的值
else if(rtu_ifu_chgflw_vld || rtu_ifu_flush)  从 CSR 恢复（cp0 的值）
else if(rtu_ifu_xx_expt_vld)   异常，从 CSR 恢复
else if(iu_ifu_chgflw_vld)     执行单元（IU）提交的 vsetvli 结果
else if(addrgen_xx_pcload)     向量地址生成单元的 chgflw
else if(ibctrl_ipdp_pcload)    IB 级 chgflw
else if(lbuf_ipdp_vtype_updt_vld) load buffer 更新
else                           IP 级 vsetvli 指令（推测性更新）
```

> **为什么 IP 级就更新 vtype？** 与 GHR 投机更新类似，在 vsetvli 指令解码时就推测性更新 vtype，让后续指令（vector 指令）能立刻使用新的 vl/vsew/vlmul。若 vsetvli 最终预测错误（目标寄存器实际值不同），RTU 会通过 `rtu_ifu_chgflw_vld` 纠正。

### 13.3 周期内传播（形成正确的 Hn vtype）

同一个取指窗口内可能有多条 vsetvli 指令（虽然罕见）。因此 vtype 在 H0~H8 之间做链式传播：

```verilog
// 行 2893-2909
assign h0_vlmul = (h0_vld && h0_vsetvli) ? h0_vlmul_pre : vlmul_reg;
assign h1_vlmul = (h0_vld) ? h0_vlmul
                           : (vsetvli[7]) ? h1_vlmul_pre : vlmul_reg;
assign h2_vlmul = (vsetvli[6]) ? h2_vlmul_pre : h1_vlmul;
assign h3_vlmul = (vsetvli[5]) ? h3_vlmul_pre : h2_vlmul;
// ... h4~h8 类似
```

每个 H 首先查看自己是否是 vsetvli（若是则用新值），否则继承前一个 H 的值。这保证了 H_n 的 vtype 反映的是**在 H_n 之前最近一条 vsetvli 指令执行后**的状态。

---

## 14. RAS（Return Address Stack）支持

### 14.1 RAS Push PC 计算

当检测到 call 指令（pcall）时，ipdp 在 IP 级就计算好返回地址（call 的下一条指令的 PC）并推入 RAS：

```verilog
// 行 5557-5616
assign ipdp_h1_next_pc = (h0_vld)
                       ? {ip_vpc[high:3], 3'b001}  // H0 存在：下一条指令在 H2 处
                       : (inst_32_vpc_mask[7])
                         ? {ip_vpc[high:3], 3'b010} // 32-bit：跳过两个 half-word
                         : {ip_vpc[high:3], 3'b001}; // 16-bit：只跳过一个 half-word
// ... 类似生成 h2~h8 的 next_pc
```

根据 pcall 在取指窗口中的位置（`pcall_vpc_mask[7:0]`），选择对应的 next_pc 作为返回地址：

```verilog
// 行 5604-5616
casez(pcall_vpc_mask[7:0])
  8'b1??????? : ipdp_ras_push_pc = ipdp_h1_next_pc; // call 在 H1，返回地址是 H2 的 PC
  8'b01?????? : ipdp_ras_push_pc = ipdp_h2_next_pc; // call 在 H2，返回地址是 H3 的 PC
  // ...
```

### 14.2 RAS 命中验证

```verilog
// 行 5563
assign l0_btb_ras_pc_hit = (ras_target_pc == ifdp_ipdp_l0_btb_target);
```

若 RAS 栈顶 PC 与 L0 BTB 记录的目标 PC 一致，则 `l0_btb_ras_pc_hit=1`，说明 L0 BTB 和 RAS 对该 return 的预测是一致的，无需纠正。

---

## 15. L0 BTB 更新逻辑

### 15.1 L0 BTB 命中判定

```verilog
// 行 5782-5797
assign l0_btb_way0_hit = ifdp_ipdp_btb_way0_vld 
                      && ifdp_ipdp_l0_btb_way0_high_hit 
                      && ifdp_ipdp_l0_btb_way0_low_hit
                      && (ifdp_ipdp_l0_btb_way_pred == ifdp_ipdp_btb_way0_pred);
// Way1~Way3 类似
assign ipdp_ipctrl_l0_btb_hit_way[3:0] = {l0_btb_way3_hit, l0_btb_way2_hit,
                                           l0_btb_way1_hit, l0_btb_way0_hit};
```

L0 BTB 命中要求：
1. BTB 条目有效（`btb_wayX_vld`）
2. PC 的高位匹配（`l0_btb_wayX_high_hit`）
3. PC 的低位匹配（`l0_btb_wayX_low_hit`）
4. way 预测字段一致（确保是同一条分支）

### 15.2 L0 BTB 更新条件

```verilog
// 行 5850-5875
assign l0_btb_not_saturate = ip_if_pcload && l0_btb_hit_l1_btb && ip_pcload
                          && !l0_btb_ras && con_br && (bht_result == 2'b10);
// BHT 弱 taken 时，L0 BTB 计数器可能还未饱和，需要 +1

assign l0_btb_counter_zero = l0_btb_hit && !l0_btb_counter && ip_pcload
                          && con_br && (bht_result == 2'b11);
// L0 BTB 计数器为 0（新写入），但 BHT 强 taken，需要设置计数器

assign l0_btb_mistaken = ipctrl_ipdp_ip_mistaken;
// IF 级跳转但 IP 级判断不需要跳转

assign l0_btb_update_vld = ip_data_vld && (not_saturate || mistaken || counter_zero);
```

L0 BTB 的更新是保守的：只在 BHT 高度可信（saturated taken）或预测出错时才更新，避免频繁写入不稳定的分支。

---

## 16. 向 IB 级（ibdp）的输出

### 16.1 流水寄存器结构

所有发往 ibdp 的信号都先构建 `pipe_*` 形式（组合选择），然后在 IP→IB 的流水寄存器中采样，输出为 `ipdp_ibdp_*`：

```verilog
// 示例（H1 数据，行 5931）
assign pipe_h1_data[15:0] = (rtu_yy_xx_dbgon) ? had_ifu_ir[15:0] : ip_h1_data[15:0];
// debug 模式下 H1 来自 HAD（调试端口）
```

在 debug 模式（`rtu_yy_xx_dbgon`）下，所有 H1/H2 的数据被替换为 HAD 注入的指令，用于单步调试。

### 16.2 每个 Hn 的完整信息

发往 ibdp 的每个 H 包括：
- `ipdp_ibdp_hN_data[15:0]`：指令原始数据
- `ipdp_ibdp_hN_base[2:0]`：该 H 在 16 字节取指块中的半字偏移编号
- `ipdp_ibdp_hN_split0_type[2:0]`：向量指令拆分类型（short）
- `ipdp_ibdp_hN_split1_type[2:0]`：向量指令拆分类型（long）
- `ipdp_ibdp_hN_vlmul[1:0]`、`hN_vsew[2:0]`、`hN_vl[7:0]`：此 H 对应的 vtype

### 16.3 全局（8-bit 位图）输出

```verilog
ipdp_ibdp_hn_vld[7:0]      // 每个 H 是否有效（经过 after_head + after_tail 处理）
ipdp_ibdp_hn_con_br[7:0]   // 条件分支位图
ipdp_ibdp_hn_ab_br[7:0]    // 无条件分支位图
ipdp_ibdp_hn_jal[7:0]      // JAL 位图
ipdp_ibdp_hn_jalr[7:0]     // JALR 位图
ipdp_ibdp_hn_pcall[7:0]    // Call 位图
ipdp_ibdp_hn_preturn[7:0]  // Return 位图
ipdp_ibdp_hn_fence[7:0]    // Fence 位图
ipdp_ibdp_hn_ldst[7:0]     // Load/Store 位图
ipdp_ibdp_hn_split0[7:0]   // 需要 split（向量拆分）位图
ipdp_ibdp_hn_chgflw[7:0]   // change flow 位图
ipdp_ibdp_chgflw_mask[7:0] // 分支截断掩码
```

这些位图使 IB 级（ibdp）能够一次性处理 8 条潜在指令的信息，并根据位图快速定位指令 entry 边界。

### 16.4 分支专属信息

```verilog
ipdp_ibdp_branch_base[38:0]    // 第一条分支的 PC
ipdp_ibdp_branch_offset[20:0]  // 第一条分支的 offset（21-bit 符号扩展）
ipdp_ibdp_branch_result[38:0]  // 跳转目标 PC（来自 BTB 或计算值）
ipdp_ibdp_branch_btb_miss      // BTB 是否 miss（需要 ibdp 写入 BTB）
ipdp_ibdp_branch_way_pred[1:0] // 命中分支的 way 预测
```

`branch_result` 是当 BTB 命中时的目标 PC；若 `branch_btb_miss=1`，则 IB 级需要将实际跳转目标写回 BTB。

---

## 17. 调试模式（HAD）支持

```verilog
// 行 5325-5336
assign had_br = (had_data[6:0] == 7'b1101111) ||  // jal
                ({had_data[14:12], had_data[6:0]} == 10'b000_1100011) ||  // beq
                // ... 其他条件分支
                ({had_data[15:14], had_data[1:0]} == 4'b1101);  // c.beqz/c.bnez
```

当 HAD（Hardware-Assisted Debugging）注入指令时，ipdp 对 HAD 指令做独立的分支检测，并通过 `ip_had_*` 系列信号替换正常的流水信号，确保调试注入的指令能够被正确处理。

---

## 18. Half-Word 编号计算

IB 级需要知道"本次取指共有多少个有效的 half-word"，以便正确分配指令 entry。ipdp 计算了几个关键的 half-word 数量：

```verilog
// 行 5332-5476
// half_num_before_con_br：第一条 con_br 之前的 half-word 数
// half_num_chgflw：发生 chgflw 处的 half-word 编号
// half_num_con_br：第一条 con_br 的 half-word 编号
// half_num_no_chgflw：无 chgflw 时，总有效 half-word 数
```

这些计数值（4-bit，最大 9）通过 casez 分别根据 `con_br_after_head[7:0]` 或 `chgflw_after_head[7:0]` 的位置计算，并将 H0 的影响（+1）考虑在内。

---

## 19. 模块内关键寄存器总结

| 寄存器名 | 位宽 | 更新时机 | 含义 |
|---------|------|---------|------|
| `h0_vld` | 1 | 每周期（pipe vld 时） | H0 缓存是否有效 |
| `h0_data[15:0]` | 16 | h0_updt_clk | H0 的指令数据（上一取指块的 H8） |
| `h0_cur_pc[35:0]` | 36 | h0_updt_clk | H0 所在的 16 字节取指块号（内部半字地址 `[38:3]`） |
| `h0_con_br` | 1 | h0_updt_clk | H0 是否是条件分支 |
| `vlmul_reg[1:0]` | 2 | vtype_updt_vld | 当前向量寄存器分组 |
| `vsew_reg[2:0]` | 3 | vtype_updt_vld | 当前向量元素宽度 |
| `vl_reg[7:0]` | 8 | vtype_updt_vld | 当前向量长度 |
| `ipdp_ibdp_*` | 各 | pipe_vld（非 stall） | 所有向 IB 级输出的流水寄存器 |
| `bht_pre_result[1:0]` | 2 | 组合逻辑（BHT 读取） | 当前条件分支的 2-bit 计数器值 |

---

## 20. 设计总结与关键思想

### 20.1 并行预解码 + 运行时选择

两路 ipdecode 并行运行，等 tag 比较结果稳定后一路 mux。这是牺牲面积换取时序的经典做法，因为等待 tag 比较结果再启动解码会浪费一个周期。

### 20.2 投机性操作

- **GHR 投机更新**：IP 级根据 BHT 预测方向更新 GHR，使后续分支得到更准确的历史
- **vtype 投机更新**：vsetvli 在 IP 级解码时就更新 vtype，使紧接着的 vector 指令能使用新 vtype
- **H0 提前缓存**：本周期就决定是否需要保存 H8 作为 H0，为下一周期做准备

### 20.3 位图操作的高效性

所有 8 个 half-word 的属性用 8-bit 位图表示，`casez` 结合 one-hot 位图做优先级选择，既清晰又高效，关键路径上只有一级 mux。

### 20.4 after_head / after_tail 的两次变换

- **after_head**：按 vpc_onehot 做左移，将起始偏移折叠
- **after_tail**：按 con_br 位置做截断，将分支后的无效 half-word 清零

两次变换后，IB 级总是从固定的逻辑位置（H1=bit[7]）开始读取，且已经做好了分支截断，大幅简化了 IB 级的控制逻辑。

### 20.5 完整的流水线数据包

ipdp 的输出是真正的"完整数据包"，每个 half-word 携带所有 IB 级、EX 级所需信息（decode 类型、split 类型、vtype、PC 基地址等），后续流水级无需重新解析指令内容，大幅降低了后级的时序压力。
