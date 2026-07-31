# ct_ifu_ipdp 详解：IP 级数据通路

## 1. 模块概述

`ct_ifu_ipdp`（IP Stage Data Path）是 C910 IFU 中规模最大的组合/流水数据通路之一，是 IP 流水级的数据核心。其主要职责是：

1. **接收 IF 级取回的 cache 数据**（H1~H8，每个 half-word 16 位）并缓存残留的 H0
2. **实例化两套预解码器**（ct_ifu_ipdecode × 2），分别针对 Way0 和 Way1 并行解码
3. **为窗口内各个可能的指令起点提取属性**（con_br、jal、jalr、call/return 等）
4. **确定预测控制流涉及的第一条分支及其 offset**，整理目标 PC 和 BTB 元数据
5. **融合 BHT、L0 BTB、BTB、RAS** 的预测信息
6. **保留 vtype（vlmul/vsew/vl）预测和向量指令拆分数据通路**
7. **向 IB 级（ibdp）打包指令半字、预解码属性、异常和预测元数据**

模块与 `ct_ifu_ipctrl` 紧密耦合：ipctrl 生成控制信号，ipdp 执行数据操作并反馈诊断信号（ipdp_ipctrl_* 系列）给 ipctrl 做决策。

这里必须区分“RTL 中存在一条功能通路”和“当前生成配置对软件公开该 ISA 能力”。`ct_ifu_ipdp.v`
保留了 `vsetvli`、`vl/vsew/vlmul` 和 split 相关逻辑；但当前仓库生成配置中
`ct_cp0_regs.v` 将 `misa_vector` 固定为 `1'b0`，`ct_idu_id_decd.v` 也将
`x_vec_inst` 固定为 `1'b0`。因此本文会解释这条保留通路的硬件行为，但不把它表述为
当前配置已经可由软件使用的完整 RVV 能力。

---

## 2. 模块结构总览

### 2.1 H0~H8 的含义

C910 的这条 IF→IP 数据通路一次提供一个 128 位、16 字节取指窗口，共 8 个
16-bit half-word，在 ipdp 中命名为 **H1~H8**（8 位属性向量中 bit[7] 对应 H1，
bit[0] 对应 H8）。一个 64 字节 I-Cache line 包含 4 个这样的窗口。

H1~H8 是**物理半字位置**，不是固定的 8 条指令。若全部为 16 位压缩指令，一个窗口
最多包含 8 条指令；若包含 32 位指令，相邻两个半字共同组成一条指令，窗口中的指令数
会相应减少。

另外，**H0** 是一个特殊的缓存寄存器：

```verilog
// 行 5730-5731
h0_cur_pc[35:0] <= ip_vpc[PC_WIDTH-2:3]; // H0 所属的 16 字节取指块号
h0_data[15:0]   <= h8_data[15:0];        // H0 的数据就是上一次取指的 H8
```

H0 产生的场景：当前 16 字节窗口的最后一个 half-word（H8）是一条 32-bit 指令在
低地址处的低 16 位，而该指令的高 16 位位于下一窗口的 H1。IPDP 保存 H8 的数据、
PC 块号和一组预解码属性；下一窗口到来时，`ct_ifu_ipdecode` 同时看到 H0 与新的 H1，
从而恢复这条跨窗口指令。H0 不是第九个新取指槽，而是上一窗口留下的拼接状态。

本文中的 39 位 `ip_vpc[38:0]`、`base_pc_*[38:0]` 等均是**内部半字地址**：
架构字节地址 bit 0 恒为 0，因此 RTL 省略该位。恢复为软件可见地址时应理解为
`arch_pc = {internal_pc, 1'b0}`。所以内部 PC 加 1 表示前进 2 字节，加 8 表示前进
16 字节。

### 2.2 数据流

```
                    ┌─────────────────────────────────────────────┐
                    │              ct_ifu_ipdp                     │
                    │                                              │
ifdp → H1~H8 data  │→  两套 ipdecode（I-Cache Way0 / Way1）     │
       BTB 数据     │→  指令属性提取（con_br、jal、jalr 等）      │
       L0 BTB 数据  │→  分支位置、基址和 offset 选择              │
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
- `ifdp_ipdp_h1_precode_way0[3:0]`：4-bit 预解码结果

RTL 在接口上把每个半字拆为 high(14) 与 low(2)，随后组合成
`h1_data[15:0] = {h1_high_way0[13:0], h1_low_way0[1:0]}`。这种结构使最关键的
RISC-V 指令长度判定低两位可以被直接使用；仅凭功能 RTL 不能进一步断言其物理 SRAM
排布或关键路径收益，后者需要综合网表、布局和 STA 结果证明。

### 3.2 来自 BTB 的信息

```verilog
input [1:0]  ifdp_ipdp_btb_way0_pred;   // 位置槽 0 保存的目标 I-Cache way 预测
input [9:0]  ifdp_ipdp_btb_way0_tag;    // 位置槽 0 的分支 PC 标签
input [19:0] ifdp_ipdp_btb_way0_target; // 位置槽 0 的内部目标 PC 低 20 位
input        ifdp_ipdp_btb_way0_vld;    // 位置槽 0 有效
// 位置槽 1~3 类似
```

这里的 `btb_way0`~`btb_way3` 容易被误认为 4 路组相联。按选择逻辑，它们是一个
取指窗口内按位置固定分组的 4 个 BTB 槽：slot0 对应 H1/H2，slot1 对应 H3/H4，
slot2 对应 H5/H6，slot3 对应 H7/H8。`pred[1:0]` 预测的是目标 PC 所在的
I-Cache way，也不是条件分支方向计数器。

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

两套实例分别对 I-Cache Way0/Way1 候选数据并行生成完整解码结果，随后由
`ipctrl_ipdp_icache_way0_hit` 选择一路。RTL 结构避免了“先选数据、再启动同一个
解码器”的串行依赖；是否因此满足某一周期或获得多少时序收益，仍需以综合网表和
STA 为准。

### 4.2 预解码结果的含义

`ct_ifu_precode.v` 明确将每个半字的 4 位编码组织为
`{ab_br, br, bry1, bry0}`：

| 位 | 含义 |
|----|------|
| bit[0] | `bry0`：假设 H1 不是指令起点时，该半字是否为指令起点 |
| bit[1] | `bry1`：假设 H1 是指令起点时，该半字是否为指令起点 |
| bit[2] | `br`：直接控制流候选，包括条件分支、JAL 和 C.J |
| bit[3] | `ab_br`：直接无条件控制流子集，即 JAL 和 C.J |

`bry0/bry1` 是两种起点假设下的边界链，不是指令宽度位。指令是否为 32 位仍由
半字自身的 `data[1:0] == 2'b11` 判断。`br/ab_br` 也只是早期直接控制流标记；
JALR、return、call、load/store、异常相关属性等仍由两套 `ct_ifu_ipdecode`
读取指令内容产生。因此不能说 IP 级完全不再解析 opcode。

### 4.3 inst[1:0] 决定指令宽度

```verilog
// 行 2399-2414
assign h1_32_way0 = (h1_low_way0[1:0] == 2'b11);
...
assign way0_32[7:0] = {h1_32_way0, h2_32_way0, ..., h8_32_way0};
```

在本设计支持的 16/32 位指令集合中，低 2 位不等于 `2'b11` 表示 16 位压缩指令，
等于 `2'b11` 表示 32 位指令的低半字。这里先对 8 个物理半字并行形成
`way0_32[7:0]`/`way1_32[7:0]` 候选；最终还必须结合 BRY 边界链，才能区分“真正
的 32 位指令起点”和“恰好位于某条 32 位指令高半字位置的数据”。

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

`bry_data[7:0]` 来自 ipctrl（`ipctrl_ipdp_bry_data`），它根据当前 H1 边界状态在
`bry0/bry1` 两条候选链中选出本窗口的指令起点位图。各类“按指令起点解释”的属性
再与它相与，避免把 32 位指令的高半字误识别成另一条指令。这里的 `br` 还会把
`preturn` 纳入早期重定向候选，而 `ab_br` 只表示 JAL/C.J 子集；完整类型以
`con_br/jal/jalr/pcall/preturn` 等独立位图为准。

### 5.2 32-bit 指令的特殊处理

```verilog
// 行 2509-2511
assign inst_32[7] = (h0_vld) ? 1'b0 : inst_32_pre[7];
assign inst_32[0] = (inst_32_pre[0]);
assign inst_32[6:1] = inst_32_pre[6:1];
```

当 `h0_vld=1` 时，H0 是跨窗口指令的低 16 位，当前 H1 是其高 16 位。H1 仍然作为
数据半字传给后续级，但不能再被解释为一条新 32 位指令的低半字，所以
`inst_32[7]` 清零。跨窗口指令自身的属性由保存的 H0 解码状态与当前 H1 共同处理。

H8（bit[0]）先按 cache 数据的 `low[1:0]` 判断 32 位候选；只有它同时位于 BRY
确认的指令边界，并满足下一节的控制流条件时，`h0_vld_pre` 才置 1，H8 才成为
下一窗口可用的 H0。

### 5.3 h0_vld_pre：判断 H0 是否应该有效

```verilog
// 行 5664-5667
assign h0_vld_pre = (inst_32[0] && bry_data[0]) &&  // H8 是 32-bit 指令
                    !(|chgflw[7:1])              &&  // 取指窗口中无跳转（没有被截断）
                    !ipctrl_ipdp_ip_pcload        &&  // IP 级不跳转
                    !ipctrl_ipdp_br_more_than_one_stall; // 没有多分支 stall
```

只有 H8 在 BRY 链上确实是 32 位指令起点，并且 H1~H7 没有已经选中的
`chgflw`、IP 没有发出 `pcload`、当前不是多条件分支重发状态，`h0_vld_pre`
才成立。直观上说，只有控制流仍会顺序到达下一窗口时，保存 H8 才有意义。

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

`h0_vld/h0_vld_dup` 直接使用 `forever_cpuclk`，并在 cancel、stall、访问拒绝和
`h0_update_vld` 条件下更新；H0 payload 则在 `h0_updt_clk` 上、满足
`h0_update_vld && !pipe_stall` 时更新。payload 不只有 16 位数据，还包括窗口块号、
分支种类、目的寄存器有效、断点、no-spec、vtype 预测等跨窗口所需属性。

`h0_updt_clk` 来自通用 `gated_clk_cell`，其 local enable 为
`ipctrl_ipdp_h0_updt_gateclk_en`。不能仅由 local enable 为 0 就断言时钟必停：
`cp0_ifu_icg_en` 可通过 module enable 覆盖；若未定义 `C910_USE_TSMC28_ICG`，
通用单元的 RTL 仿真实现还会把 `clk_out` 直接连到 `clk_in`。门控带来的实际功耗
收益必须在目标工艺实现中评估。

---

## 6. H0 对 H1 解码信息的覆盖

H0 有效时，H0 与当前 H1 共同组成跨窗口 32 位指令：H0 保存低半字，H1 提供高半字。
输出中 H0 payload 和 H1 data 仍是分开的，但 bit[7] 这一“第一条逻辑指令位置”的
分支等属性需要采用保存的 H0 解码状态：

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

H2~H7（bit[6:1]）按当前窗口的解码结果处理。H0 还独立通过
`ipdp_ibdp_h0_data/ipdp_ibdp_h0_vld` 送入 IBDP；不能把该机制理解成物理地用 H0
替换了 `h1_data`。

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

`way0_hit` 来自 ipctrl（`ipctrl_ipdp_icache_way0_hit`）。当 Way0 命中时选择
Way0 候选，否则选择 Way1 候选。正常有效取指依赖 IFCTRL/IPCTRL 已完成命中与异常
归一化；在异常路径中 IPCTRL 会强制选择 Way0，以给组合选择一个确定通路，此时
指令数据本身不应再被当作正常可执行内容。

---

## 8. BHT 数据应用：2-bit 计数器 MSB 作预测方向

### 8.1 选择 taken/ntaken 数组

```verilog
// 行 4826-4828
assign pre_array_data[31:0] = (bht_sel_result[1])
                            ? bht_ipdp_pre_array_data_taken[31:0]
                            : bht_ipdp_pre_array_data_ntake[31:0];
```

BHT 向 IPDP 同时提供 `taken` 与 `ntake` 两组各 16 个 2-bit 项，
`bht_sel_result[1]` 选择其中一组，IPDP 再按 one-hot 索引选一个计数器。该组织可从
RTL 直接确认；把整个 BHT 归类为哪一种经典两级预测器，还需要结合
`ct_ifu_bht.v` 中索引、历史选择和更新路径一起判断，不能仅由这个 mux 得出。

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

IPDP 本身不写 VGHR。它把当前内部 VPC 送给 BHT；IPCTRL 另外提供当前窗口的
`con_br_vld/taken`，BHT 据此进行正常的投机历史推进。这里单独的
`ipdp_bht_h0_con_br` 表示本窗口 H8 将成为下一窗口 H0，且它是条件分支并处于
BHT 有效路径，用来覆盖跨窗口条件分支这一特殊情况。恢复和非投机修正仍由 BJU/RTU
相关接口完成。

---

## 9. 分支目标 PC 计算

### 9.1 branch[7:0] 的确定

```verilog
// 行 4935
assign branch[7:0] = ipctrl_ipdp_branch[7:0];
```

`branch` 是 IPCTRL 根据预解码、BHT 方向、直接/间接控制流和当前重发状态选出的
**预测重定向候选位图**。它描述前端本周期按预测认为应改变控制流的那条指令，
不代表指令已经执行，也不是架构意义上的“实际跳转结果”。

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

这是整个模块最核心的数据选择逻辑之一：根据 `branch[7:0]` 的最高有效位，选择该
预测控制流指令对应的：
- **base_pc**：该分支指令自身的内部 PC（VPC 块号 + half-word 偏移）
- **offset**：分支指令中编码的相对偏移量（由 ipdecode 提取的 21-bit 符号扩展值）

由于内部 PC 省略架构 bit 0，后续 `ct_ifu_addrgen` 使用的是
`sign_extend(offset[20:1])`：

```text
calculated_internal_target = base_internal_pc + sign_extend(encoded_offset[20:1])
```

这个加法不在 IPDP 或 IBDP 内完成，而在 IBDP 将 base/offset 转交给
`ct_ifu_addrgen` 后完成。ADDRGEN 再将计算目标与前端预测目标比较，产生 BTB
mispredict 信息。

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

这 4 个信号组是按位置固定的槽，不是四路替换候选。IPDP 先根据分支位置选择唯一
槽，再检查该槽的 valid 和 tag。槽内 `target[19:0]` 是预测目标内部 PC 的低
20 位，`pred[1:0]` 是目标 I-Cache way 预测。

```verilog
// 行 5550-5552
assign btb_branch_miss = !btb_branch_way_vld ||
                         (btb_branch_tag[9:0] != {btb_index_pc[19:13], btb_index_pc[2:0]}) || 
                         !cp0_ifu_btb_en;
```

`btb_branch_miss` 的精确定义是：所选位置槽无效、标签不匹配，或 CP0 关闭 BTB。
IPDP 将 miss、base、offset、预测结果和索引一起流水送出。IBDP 只负责继续打包和
仲裁；真正的直接目标加法与预测目标比较在 ADDRGEN 中完成，BTB 写请求还要经过
`ib_data_vld`、无异常、无 IB self-stall 等条件过滤。

---

## 10. 条件分支 con_br 的特殊处理

条件分支（beq、bne、blt 等）需要同时保存“方向预测”和“直接目标计算”两类信息。
IPDP 因而独立定位窗口中第一条条件分支，即使窗口里还存在其他直接或间接控制流属性。

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
- 在 8 个物理半字位置中的掩码（`con_br_vmask`，用于多分支处理和状态选择）

### 10.2 传递给 ibdp

```verilog
// 最终输出到 IB 级（寄存器形式）
ipdp_ibdp_con_br_cur_pc     // 条件分支的 PC
ipdp_ibdp_con_br_offset     // 条件分支的 offset
ipdp_ibdp_con_br_inst_32    // 是否 32-bit
ipdp_ibdp_con_br_num        // 条件分支的 half-word 编号（用于 IB 计数）
ipdp_ibdp_con_br_num_vld    // 有效标志
```

IBDP 仍属于前端 Instruction Buffer 数据通路，不是执行级。它把这些字段送给
ADDRGEN；ADDRGEN 计算直接目标、与 `branch_result` 比较，并在下一拍形成前端
纠正信息。条件是否真正成立以及退休后的精确恢复，则属于更后面的 BJU/RTU 路径。

---

## 11. "after_head" 机制：相对 VPC 的偏移重排

C910 允许当前 VPC 从一个 16 字节窗口内任意半字位置开始。IPDP 先按
`vpc_onehot` 去掉 VPC 之前的物理半字，并把 VPC 指向的半字移到逻辑 H1
（bit[7]）位置，这就是 `*_after_head`。它处理的是“窗口从哪里开始有效”，不是
分支后的尾部截断。

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

IBDP/IBUF 接口采用固定的 H1~H8 逻辑位置。提前折叠窗口头部后，下游无需为
8 种 VPC 起点分别实现一套索引控制。这里可以理解为一个并行“左对齐器”；是否采用
环形存储属于 IBUF 自身实现，不能从 IPDP 的移位逻辑直接推出。

### 11.3 hn_vld_after_head：每个 H 的有效性

```verilog
// 伪代码：先按 vpc_onehot 左对齐物理半字可用位图
hn_vld_after_head = left_align(physical_halfword_valid, vpc_onehot);
```

`hn_vld_after_head` 表示左对齐后哪些**物理半字槽**可以送入下游，并不等同于
“独立指令起点位图”。32 位指令的两个半字都需要有效，但只有低地址半字对应的
`bry_data`/`hn_32_start` 表示指令起点。窗口末尾若只有一条跨窗 32 位指令的低半字，
RTL 会避免把不完整指令当作完整数据包送出，并由 H0 机制接续。

---

## 12. "after_tail" 机制：分支截断

`tail_vld` 有两个来源：

```verilog
tail_vld = (con_br_first_branch && bht_result)
         || ipctrl_ipdp_br_more_than_one_stall;
```

第一种是窗口内按程序顺序遇到的第一条控制流是条件分支，且 BHT 预测 taken；
第二种是同一窗口出现多个条件分支，IPCTRL 通过 stall/reissue 分段处理。此时当前
数据包只能保留到第一条条件分支为止，后面的半字留给后续片段重新处理。

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

`mask_*` 系列以第一条 `con_br_after_head` 为截断点，并在该条件分支是 32 位时保留
它的第二个半字。另一个 `chgflw_mask` 则以选中的 `chgflw_after_head` 为界，描述
本数据包允许覆盖到哪个半字：

```verilog
// 行 4475-4498
casez(chgflw_after_head[7:0])
  8'b1??????? : chgflw_mask[7:0] = (inst_32_after_head[7]) 
                                 ? 8'b11000000  // 32-bit：chgflw 占 2 个 half-word
                                 : 8'b10000000; // 16-bit：只占 1 个
  // ...
```

`chgflw_mask` 中的 1 表示从逻辑头部到重定向指令末尾仍属于当前包的范围；没有
`chgflw` 时为 `8'hff`。最终应同时观察 `ip_hn_vld`、`ip_bry_data` 和
`chgflw_mask`：前者说明半字是否存在，BRY 说明指令从哪里开始，mask 说明控制流
边界在哪里。三者语义不同。

并非每一种辅助属性都单独复制一套 tail mask。RTL 明确让
`inst_ldst/no_spec/vl_pred/vsetvli` 只做 `after_head`，而最终有效范围由
`ip_hn_vld` 和后续数据包 valid 共同约束。读波形时若看到 tail 之后某个辅助位仍为
1，不能直接认定错误路径指令已进入 IBUF，必须同时检查对应半字的 `hn_vld`。

---

## 13. vtype 维护（当前配置未启用的保留通路）

IPDP RTL 保留向量长度 `vl`、元素宽度 `vsew`、寄存器分组 `vlmul` 及
`vsetvli` 预测传播逻辑。该逻辑反映了一个重要的前端问题：若一条指令的拆分方式依赖
前序 `vsetvli`，同一宽窗口内必须按程序顺序传播状态。当前生成配置关闭 `misa.V`
和 IDU 向量指令识别，因此本节是对保留微结构的说明，不代表当前 ELF 可以使用 RVV。

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
else if(lbuf_ipdp_vtype_updt_vld) loop buffer（LBUF）回送更新
else                           IP 级 vsetvli 指令（推测性更新）
```

IP 级更新让同一窗口和紧随其后的指令可以使用预测状态；控制流恢复、异常或 flush
时，优先从 CP0 或上游恢复接口重建状态。这里不能简化为“RTU 只在 vsetvli 预测错时
纠正”：RTL 的恢复条件覆盖更广的控制流和异常场景。

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

链式表达式使当前位置若识别到 `vsetvli`，该位置以及后续位置可以取得新的预测值；
否则继承前一位置状态。它是组合级的前端预测传播，不等价于该 `vsetvli` 已执行或
退休；错误路径上的状态最终必须由前述恢复源覆盖。

---

## 14. RAS（Return Address Stack）支持

### 14.1 RAS Push PC 计算

当窗口内检测到 `pcall` 时，IPDP 在 IP 级计算顺序返回地址，并通过
`ipdp_l0_btb_ras_pc/ipdp_l0_btb_ras_push` 请求 RAS 更新：

```verilog
// 行 5557-5616
assign ipdp_h1_next_pc = (h0_vld)
                       ? {ip_vpc[high:3], 3'b001}  // H0 存在：下一条指令在 H2 处
                       : (inst_32_vpc_mask[7])
                         ? {ip_vpc[high:3], 3'b010} // 32-bit：跳过两个 half-word
                         : {ip_vpc[high:3], 3'b001}; // 16-bit：只跳过一个 half-word
// ... 类似生成 h2~h8 的 next_pc
```

`pcall_vpc_mask = pcall & ipctrl_ipdp_vpc_mask` 先排除 VPC 之前的 call，再按最靠前
的位置选择返回地址。所有值都是省略架构 bit 0 的内部 PC；32 位 call 前进两个内部
单位，16 位 call 前进一个内部单位，H7/H8 跨窗口时内部 `+8` 即字节地址 `+16`。

```verilog
// 行 5604-5616
casez(pcall_vpc_mask[7:0])
  8'b1??????? : ipdp_ras_push_pc = ipdp_h1_next_pc; // call 在 H1，返回地址是 H2 的 PC
  8'b01?????? : ipdp_ras_push_pc = ipdp_h2_next_pc; // call 在 H2，返回地址是 H3 的 PC
  // ...
```

真正的 push valid 还要求 `!pipe_cancel && ip_data_vld && |pcall_vpc_mask`，因此仅有
组合解码命中不会更新 RAS。

### 14.2 RAS 命中验证

```verilog
// 行 5563
assign l0_btb_ras_pc_hit = (ras_target_pc == ifdp_ipdp_l0_btb_target);
```

若 RAS 提供有效数据则 `ras_target_pc` 取 RAS 栈顶，否则退化为当前默认 VPC。
`l0_btb_ras_pc_hit` 只表示这个候选目标与 L0 BTB 目标逐位相等；是否需要纠正还要由
IBCTRL/IBDP 结合 L0 命中、RAS 标志、有效性和当前 stall 判断，不能单凭该比较信号
断言“无需纠正”。

---

## 15. L0 BTB 更新逻辑

### 15.1 L0 结果与常规 BTB 的一致性验证

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

`ifdp_ipdp_l0_btb_hit` 才是来自 L0 BTB 的原始命中。这里生成的
`l0_btb_wayX_hit` 不是再次查 L0 表，而是验证 L0 给出的目标/way 预测是否与对应的
常规 BTB 位置槽一致，条件包括：

1. 对应常规 BTB 位置槽有效；
2. L0 目标与该槽目标的高段比较命中；
3. L0 目标与该槽目标的低段比较命中；
4. L0 保存的目标 I-Cache way 预测与该槽的 `pred[1:0]` 相等。

`ipdp_ipctrl_l0_btb_hit_way[3:0]` 把四个位置槽的一致性结果送回 IPCTRL。它回答的是
“L0 的快速预测能否被较完整的常规 BTB 信息确认”，而不是“哪一个四路组相联 way
命中”。

### 15.2 L0 BTB 更新条件

```verilog
// 行 5850-5875
assign l0_btb_not_saturate = ip_if_pcload && l0_btb_hit_l1_btb && ip_pcload
                          && !l0_btb_ras && con_br
                          && (bht_pre_result == 2'b10);

assign l0_btb_counter_zero = l0_btb_hit && !l0_btb_counter && ip_pcload
                          && con_br && (bht_pre_result == 2'b11);

assign l0_btb_mistaken = ipctrl_ipdp_ip_mistaken;
// IF 级跳转但 IP 级判断不需要跳转

assign l0_btb_update_vld = ip_data_vld && (not_saturate || mistaken || counter_zero);
```

注意比较对象是 2 位 `bht_pre_result`，不是 1 位 `bht_result`。三类局部维护条件为：

- `l0_btb_not_saturate`：IF 与 IP 都发生 pcload、L0 被常规 BTB 确认、不是 RAS，
  当前是条件分支且 BHT 为弱 taken（`10`）；
- `l0_btb_counter_zero`：L0 原始命中但其一位 counter 为 0，同时满足一致性、
  非 RAS、IP pcload、条件分支和强 taken（`11`）；
- `l0_btb_mistaken`：IPCTRL 判定 IF 级 L0 重定向是 mistaken。

`l0_btb_wen[3:0]` 在后续 IBDP 中解释为 `{valid, counter, ras, data}` 写使能：
前两类分别控制 valid/counter 位，mistaken 也参与 valid 位维护。完整的 miss、
mispredict、RAS miss/mispredict 更新还在 IBDP 中汇合。因此这段只是 L0 更新协议的
一部分，不能概括为“只在饱和 taken 时更新整个 L0 条目”。

---

## 16. 向 IB 级（ibdp）的输出

### 16.1 流水寄存器结构

主要输出先构建 `pipe_*` 组合值，再由 IP→IB 流水寄存器采样为
`ipdp_ibdp_*`。公共元数据和 H1~H8 payload 使用 `ip_ib_pipe_clk`；H0 payload
另有 `ip_ib_pipe_h0_clk`，只在 `pipe_h0_vld && !pipe_stall` 时需要写入：

```verilog
// 示例（H1 数据，行 5931）
assign pipe_h1_data[15:0] = (rtu_yy_xx_dbgon) ? had_ifu_ir[15:0] : ip_h1_data[15:0];
// debug 模式下 H1 来自 HAD（调试端口）
```

`ip_ib_pipe_clk` 的 local enable 是
`pipe_vld_for_gateclk && !pipe_stall || had_ifu_ir_vld`。与 H0 门控相同，实际时钟是否
停以及功耗收益取决于 module/global enable、宏配置和物理实现，不能仅由 local
enable 推断。

debug 模式下，H1/H2 数据分别由 `had_ifu_ir[15:0]` 和 `[31:16]` 替换，配套的
valid、控制流、load/store、split、vtype 等位图也切换到 HAD 解码结果。H3~H8 的
data 组合线上仍接正常值，但 `ip_had_vld` 和 `chgflw_mask=8'hc0` 使其不作为调试
指令有效载荷；H0 valid 同时被压低。

### 16.2 每个 Hn 的完整信息

发往 ibdp 的每个 H 包括：
- `ipdp_ibdp_hN_data[15:0]`：指令原始数据
- `ipdp_ibdp_hN_base[2:0]`：该 H 在 16 字节取指块中的半字偏移编号
- `ipdp_ibdp_hN_split0_type[2:0]`、`split1_type[2:0]`：保留 split 类型
- `ipdp_ibdp_hN_vlmul[1:0]`、`hN_vsew[2:0]`、`hN_vl[7:0]`：保留 vtype 状态

H0 另有 data、块号、split、fence、断点、load/store、no-spec、异常和 vtype 字段，
以便 IBDP 恢复跨窗口 32 位指令的完整上下文。

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
ipdp_ibdp_hn_split0[7:0]   // 保留的 split0 位图
ipdp_ibdp_hn_split1[7:0]   // 保留的 split1 位图
ipdp_ibdp_chgflw_mask[7:0] // 分支截断掩码
```

此外还有 `hn_32_start`、`hn_pc_oper`、`hn_dst_vld`、`hn_no_spec`、`hn_vl_pred`、
breakpoint、访问错误、MMU access deny 和 page fault 等字段。它们描述最多 8 个
**半字槽**，不是固定 8 条指令；IBDP/IBUF 结合 `hn_vld`、`hn_32_start` 和 H0
状态组装实际指令。

### 16.4 分支专属信息

```verilog
ipdp_ibdp_branch_base[38:0]    // 第一条分支的 PC
ipdp_ibdp_branch_offset[20:0]  // 第一条分支的 offset（21-bit 符号扩展）
ipdp_ibdp_branch_result[38:0]  // IPCTRL 已选择的预测重定向内部 PC
ipdp_ibdp_branch_btb_miss      // 所选常规 BTB 位置槽是否 miss
ipdp_ibdp_branch_way_pred[1:0] // 目标 I-Cache way 预测
```

`branch_result` 直接来自 `ipctrl_ipdp_chgflw_pc`，可能由 BTB、L0/RAS 或其他前端
选择路径形成，不能限定为“BTB 命中目标”。ADDRGEN 用
`branch_base + sign_extend(branch_offset[20:1])` 得到直接目标，与
`branch_result` 比较；满足有效性与仲裁条件后，IBDP/BTB 才产生相应更新。

### 16.5 异常、断点与 SFP 属性

IPDP 不只传“普通指令数据”，还必须保证特殊语义与同一条指令对齐：

- `ip_acc_err`、`ip_mmu_pgflt` 和 `ip_mmu_acc_deny` 分别来自 I-Cache/总线和
  MMU 路径，三者合成内部 `ip_expt`。其中 `ip_mmu_acc_deny` 在 pipe/self/multi-branch
  stall 时由寄存器保留，避免 MMU 的当前拍输出变化后丢失原请求的异常状态。
- `bkpta/bkptb` 来自 IFDP 的逐半字断点匹配结果，和普通属性一起做 `after_head`
  与条件分支 tail mask；H0 也保存跨窗口指令对应的断点位。
- SFP（speculation-failure predictor）给出命中 PC 低位和 4 类命中类型。IPDP
  将 PC 低 3 位译成 H1~H8 one-hot；`sf` 类型与 store 相交、`bar` 类型与 load
  相交后形成 `inst_no_spec`，使曾经表现出投机风险的访存可以携带 no-spec 属性。
- SFP 的 `vl/vl_raw` 类型只与 `vsetvli` 相交，形成保留向量通路的 `vl_pred`
  属性。当前配置未启用 RVV，但这部分逻辑仍存在。

这些字段说明前端预解码的价值不只是“早点看见分支”：它还把异常、调试和历史学习
得到的投机约束精确附着到正确的指令边界上。波形分析时应把
`hn_vld/hn_32_start` 与这些属性位图同时观察，单看 `*_vld` 汇总位无法定位是哪一个
半字槽触发。

---

## 17. 调试模式（HAD）支持

```verilog
// 行 5325-5336
assign had_br = (had_data[6:0] == 7'b1101111) ||  // jal
                ({had_data[14:12], had_data[6:0]} == 10'b000_1100011) ||  // beq
                // ... 其他条件分支
                ({had_data[15:14], had_data[1:0]} == 4'b1101);  // c.beqz/c.bnez
```

当 HAD（Hardware-Assisted Debugging）注入指令时，IPDP 对 32 位注入字独立识别
分支、JAL/JALR、load/store、fence、split 等属性。注入字低/高半字分别占逻辑
H1/H2；`ip_had_vld` 根据 16/32 位长度决定 `8'h80` 或 `8'hc0`。这条旁路替换
流水 payload 与属性，并清除正常取指异常字段，但不意味着 H3~H8 数据线物理清零。

---

## 18. Half-Word 编号计算

IB 级需要知道当前数据包覆盖多少个半字、第一条条件分支或 change-flow 位于何处。
IPDP 因而计算几个不同语义的数量：

```verilog
// 行 5332-5476
// half_num_before_con_br：第一条 con_br 之前的 half-word 数
// half_num_chgflw：发生 chgflw 处的 half-word 编号
// half_num_con_br：第一条 con_br 的 half-word 编号
// half_num_no_chgflw：无 chgflw 时，总有效 half-word 数
```

这些 4-bit 值通过 `casez` 对最靠前的置位位置编码，并把跨窗口 H0 可能额外占用的
半字计入。`con_br_num_vld` 只在“第一条控制流为预测 taken 条件分支”或多分支重发
且无取指异常时成立；`chgflw_num_vld` 则取决于 `chgflw_after_head`。分析波形时不能
只看数值而忽略对应的 `*_vld`。

---

## 19. 模块内关键寄存器总结

| 寄存器名 | 位宽 | 更新时机 | 含义 |
|---------|------|---------|------|
| `h0_vld/h0_vld_dup` | 1+1 | `forever_cpuclk`；cancel/stall/update 条件控制 | H0 有效位及送 IPCTRL 的复制 |
| `h0_data[15:0]` | 16 | `h0_updt_clk` 且 update、非 stall | 上一窗口 H8 的低 16 位 |
| `h0_cur_pc[35:0]` | 36 | `h0_updt_clk` 且 update、非 stall | H0 所在 16 字节窗口号，即内部 PC `[38:3]` |
| `h0_con_br` | 1 | h0_updt_clk | H0 是否是条件分支 |
| `vlmul_reg[1:0]` | 2 | `forever_cpuclk`、`vtype_updt_vld` | 保留通路的向量寄存器分组状态 |
| `vsew_reg[2:0]` | 3 | `forever_cpuclk`、`vtype_updt_vld` | 保留通路的向量元素宽度状态 |
| `vl_reg[7:0]` | 8 | `forever_cpuclk`、`vtype_updt_vld` | 保留通路的向量长度状态 |
| `ipdp_ibdp_*` | 各 | 主要由 `ip_ib_pipe_clk` 在 pipe valid、非 stall 时采样 | 向 IB 级输出的流水数据包 |
| `bht_pre_result[1:0]` | 2 | 组合逻辑（BHT 读取） | 当前条件分支的 2-bit 计数器值 |

---

## 20. 设计总结与关键思想

### 20.1 并行预解码 + 运行时选择

两路 `ipdecode` 对两个 I-Cache way 候选并行解码，再由命中结果选择。体系结构上，
这是一种用重复组合逻辑缩短“缓存选择→预解码”串行依赖的结构；面积代价和实际
关键路径收益必须由综合与 STA 定量确认，功能 RTL 本身不能证明“恰好节省一周期”。

### 20.2 投机性操作

- **GHR 投机接口**：IPDP/IPCTRL 向 BHT 提供 VPC、条件分支有效和预测方向，BHT
  维护历史；BJU/RTU 路径负责恢复
- **vtype 预测传播**：保留通路在 IP 级传播 `vsetvli` 预测状态，并由控制流、异常
  和上游状态接口恢复；当前生成配置未公开 RVV
- **H0 提前缓存**：本周期就决定是否需要保存 H8 作为 H0，为下一周期做准备

### 20.3 位图操作的高效性

8 个 half-word 的同类属性用 8-bit 位图表示，`casez` 从高位向低位找最靠前事件。
这既适合并行窗口，也便于统一做 head 对齐和 tail 截断。综合后究竟形成多少级 mux、
是否处于关键路径，应查看综合网表和 STA，不能由一段 `casez` 源码直接断言。

### 20.4 after_head / after_tail 的两次变换

- **after_head**：按 vpc_onehot 做左移，将起始偏移折叠
- **after_tail**：在预测 taken 的首个条件分支或多分支分段状态下，按首个条件分支
  截断；另行生成按 change-flow 位置计算的 `chgflw_mask`

两次变换后，IB 级总是从固定的逻辑位置（H1=bit[7]）开始读取，且已经做好了分支截断，大幅简化了 IB 级的控制逻辑。

### 20.5 完整的流水线数据包

IPDP 输出的是面向 IBDP/IBUF 的**前端预解码数据包**：原始半字、边界、分支、
load/store、目的寄存器有效、no-spec、异常、预测历史和保留的 split/vtype 信息
同步前推。它显著减少下游重做边界和早期控制流工作的需要，但不是完整 ISA 解码；
IDU 仍会对组装后的指令执行完整译码、寄存器依赖分析和发射分类。
