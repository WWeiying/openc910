# ct_ifu_ipctrl 详解：IP 级控制器

## 1. 模块概述

`ct_ifu_ipctrl`（IP Stage Control）是 C910 取指单元（IFU）IP 流水级的控制核心。原始指令位主要由并行的 `ct_ifu_ipdp` 处理；IPCTRL 组合 IFDP 给出的 I-Cache tag/预解码信息、IPDP 给出的指令边界和分支类型、BHT 方向结果及 L0/常规 BTB 信息，决定流水能否前推、是否需要改变 PC、是否需要 refill 或 reissue。它还维护 BRY（RTL 对指令边界预解码信息的命名）更新和 L0 BTB 训练分类，共约 2022 行生成 RTL。

### 在 IFU 流水线中的位置

```
pcgen → IF(ifctrl/ifdp) → IP(ipctrl/ipdp) → IB(ibctrl/ibdp) → ...
```

- **上游**：ifctrl 提供 `ifctrl_ipctrl_vld`，ifdp 提供 tag 命中向量、bry（分支预解码）数据、PA、VPC 等。
- **并行**：ipdp 完成指令解码，将 h0~h8 的分支/非分支信息通过 `ipdp_ipctrl_*` 系列信号反馈给 ipctrl，形成联动。
- **下游**：向 pcgen 发出 `chgflw_pcload`（跳转 PC 加载）、`reissue_pcload`（重发）；向 ibctrl 发送 `ip_vld`；向 L1 Refill 状态机发送 miss 请求。

### 关键角色

| 职责 | 关键输出信号 |
|------|-------------|
| 分支预测决策 | `ipctrl_pcgen_chgflw_pcload` |
| Way 预测出错重发 | `ipctrl_pcgen_reissue_pcload` |
| I-Cache Miss 请求 | `ipctrl_l1_refill_miss_req` |
| 流水线 Stall 控制 | `ipctrl_ifctrl_stall` |
| 向 BHT 反馈 | `ipctrl_bht_con_br_vld` |
| 向 BTB 反馈 | `ipctrl_btb_chgflw_vld` |

---

## 2. 端口结构总览

模块端口数量庞大（约 130 个），按来源/目标分组如下：

### 来自 ifdp 的输入（IF 级数据通路）

| 信号 | 位宽 | 含义 |
|------|------|------|
| `ifdp_ipctrl_vpc_2_0_onehot[7:0]` | 8 | VPC\[2:0\] 的 one-hot 编码，确定本次取指从哪个 half-word 开始 |
| `ifdp_ipctrl_vpc_bry_mask[7:0]` | 8 | 从当前 VPC half-word 到窗口末尾的连续有效范围掩码；它本身不判断指令边界 |
| `ifdp_ipctrl_w0b0_bry_data[7:0]` | 8 | Way0/Bank0 的指令起始边界候选，每位对应一个 half-word |
| `ifdp_ipctrl_w0b0_br_taken[7:0]` | 8 | Way0/Bank0 中“直接分支或直接跳转”候选；命名中的 taken 不是实际执行结果 |
| `ifdp_ipctrl_w0b0_br_ntake[7:0]` | 8 | Way0/Bank0 中“无条件直接跳转”子集；用于 BHT 为 not-taken 时仍强制重定向 |
| `ifdp_ipctrl_way0_*_hit` | 1 | Way0 各地址段 tag 命中标志（分4段：7:0、15:8、23:16、28:24） |
| `ifdp_ipctrl_way_pred[1:0]` | 2 | IF 级预测的命中 way（哪个 way 应该命中） |
| `ifdp_ipctrl_pa[27:0]` | 28 | 物理地址高位（用于 refill 请求） |
| `ifdp_ipctrl_refill_on` | 1 | 当前是否处于 refill 过程中（已有行在填充） |
| `ifdp_ipctrl_tsize` | 1 | 本次访问采用 cache-line refill/I-Cache 命中路径；等于 `icache_en && cacheable` |

### 来自 ipdp 的输入（IP 级数据通路反馈）

| 信号 | 位宽 | 含义 |
|------|------|------|
| `ipdp_ipctrl_h0_vld` | 1 | H0 寄存器有效（存在上一取指窗口 H8 留下的跨窗口低 half-word） |
| `ipdp_ipctrl_h0_br` | 1 | H0 是分支指令 |
| `ipdp_ipctrl_h0_con_br` | 1 | H0 是条件分支 |
| `ipdp_ipctrl_h0_ab_br` | 1 | H0+H1 是 precode 所识别的直接无条件跳转 |
| `ipdp_ipctrl_bht_result` | 1 | BHT 预测结果（1=taken，0=not taken） |
| `ipdp_ipctrl_bht_data[1:0]` | 2 | BHT 2-bit 计数器原始值 |
| `ipdp_ipctrl_btb_way0_target[19:0]` | 20 | 常规 BTB 位置槽 0 存储的目标 PC 低位 |
| `ipdp_ipctrl_btb_way0_pred[1:0]` | 2 | 位置槽 0 存储的 I-Cache way 预测 |
| `ipdp_ipctrl_con_br_first_branch` | 1 | 本取指窗口第一条分支是条件分支 |
| `ipdp_ipctrl_con_br_more_than_one` | 1 | 本取指窗口有两条以上条件分支 |
| `ipdp_ipctrl_l0_btb_vld` | 1 | L0 BTB 命中有效 |
| `ipdp_ipctrl_l0_btb_ras` | 1 | L0 BTB 来自 RAS（Return Address Stack） |
| `ipdp_ipctrl_no_br` | 1 | 当前取指窗口没有任何分支指令 |
| `ipdp_ipctrl_inst_32[7:0]` | 8 | 每个 half-word 是否是 32-bit 指令的低半字 |
| `ipdp_ipctrl_w0_br[7:0]` / `w0_ab_br[7:0]` | 8 | Way0 各 half-word 的分支/无条件分支标志 |

---

## 3. 分支指令检测：bry 与 bry_mask

### 3.1 问题背景

C910 每个周期从 I-Cache 取回一个 128 位、16 字节取指块，对应 8 个 16-bit half-word（H1~H8）。一个 64 字节 cache line 包含 4 个取指块。由于 RISC-V C 扩展支持 16-bit 指令，指令边界可能在任意 half-word 处。核心问题是：**当前取指窗口中哪些 half-word 是合法指令的起始位置，其中哪些是分支？**

### 3.2 vpc_2_0_onehot：取指起始位置

```verilog
// ifdp.v 中生成，传入 ipctrl
input [7:0] ifdp_ipctrl_vpc_2_0_onehot;
```

`vpc_2_0_onehot[7:0]` 是内部半字地址 VPC 低三位的 one-hot 编码。内部 `vpc[2:0]` 对应架构字节地址 `[3:1]`，表示本次从 16 字节取指块的哪个 half-word 开始：

| vpc[2:0] | onehot | 含义 |
|----------|--------|------|
| 3'b000 | 8'b10000000 | 从 H1 开始取 |
| 3'b001 | 8'b01000000 | 从 H2 开始取 |
| 3'b010 | 8'b00100000 | 从 H3 开始取 |
| ... | ... | ... |
| 3'b111 | 8'b00000001 | 从 H8 开始取 |

> **为什么用 one-hot？** 后续边界推进和掩码逻辑可以直接对位置位做逐位运算或 `casez` 选择，结构上省去重复的 3-to-8 解码。是否改善了芯片关键路径以及改善多少，需由综合和 STA 验证。

### 3.3 vpc_bry_mask：有效 bry 掩码

```verilog
input [7:0] ifdp_ipctrl_vpc_bry_mask;
```

这 8 位只表示“从当前 VPC 位置到取指窗口末尾”的**连续位置范围**。例如从 H3 开始时，它为 `00111111`，屏蔽 H1、H2 而保留 H3~H8。IFDP 仅根据 `pcgen_ifdp_pc[2:0]` 生成该掩码，不读取指令低位，也不在这里判断 16/32 位边界。

真正的指令起始位置来自 `bry_data`，或者在 missigned 情况下由 IPCTRL 根据 `ipdp_ipctrl_inst_32` 重新构造。最终有效边界通常可理解为：

```text
VPC 之后的位置范围
AND
在某种 H1 边界假设下计算出的指令起始位
```

### 3.4 bry0/bry1 的双 bank 设计

每个 I-Cache way（Way0、Way1）各有两个边界假设（Bank0、Bank1）：

- **Bank0（bry0）**：假设 H1 **不是**新指令起点；典型情况是上一窗口 H8 保存于 H0，H1 是跨窗口 32 位指令的高半字。因此 H1 的 bry0 固定为 0，H2 才固定为新的起点。
- **Bank1（bry1）**：假设 H1 是新指令起点，因此 H1 的 bry1 固定为 1，再依据各 half-word 的低两位递推后续边界。

refill 时，`ct_ifu_precode` 同时计算两套边界并存入 I-Cache precode array。查询时，IFDP/IPCTRL 根据当前 VPC 和 IPDP 保存的跨窗口 H0 状态选择正确假设：

```verilog
// 行 698-701
assign way0_bry0_hit = h0_vld || ifdp_ipctrl_w0_bry0_hit;
assign way0_bry1_hit = !h0_vld && ifdp_ipctrl_w0_bry1_hit;
assign way1_bry0_hit = h0_vld || ifdp_ipctrl_w1_bry0_hit;
assign way1_bry1_hit = !h0_vld && ifdp_ipctrl_w1_bry1_hit;
```

- **`h0_vld=1`**：强制认为 Bank0 假设有效，H1 与 H0 拼成跨窗口指令；
- **`h0_vld=0`**：检查当前 VPC 在 Bank0/Bank1 边界向量中的命中情况，选择能把当前 VPC 解释为合法指令起点的假设；
- 若无 H0 且两种假设在当前 VPC 都不命中，则触发 `bry_missigned_stall`，用真实 `inst_32` 信息重建边界。

特别要避免按名字误读：`bry0_hit`/`bry1_hit` 表示**当前 VPC 与哪套边界假设一致**，不是“发现第 0/1 条分支”。`br_taken`、`br_ntake` 才进一步给出合法边界上的直接控制流类型。

> **设计动机**：同时保存两种跨窗口边界假设，让常见路径可以直接选择预解码结果；只有假设都不适用时才动态重建。这是在存储少量额外 precode 与减少前端串行边界解析之间做的权衡。

---

## 4. 分支碰撞处理：多条分支 stall

### 4.1 问题描述

同一个取指窗口（8 个 half-word）中可能存在多条条件分支。当前 IP/BHT 路径一次围绕第一条条件分支形成方向历史推进和窗口截断，不能在同一拍把所有后续条件分支都作为独立预测事件处理。

### 4.2 检测逻辑

```verilog
// 行 1530-1535
assign masked_bry_update_vld = ip_data_vld && 
                               !bht_result && 
                               con_br_first_branch && 
                               con_br_more_than_one;
```

条件解析：
- `ip_data_vld`：当前 IP 级数据有效
- `!bht_result`：BHT 预测为 not taken（若 taken 则本周期就跳转了，后续分支无需处理）
- `con_br_first_branch`：第一条分支是条件分支
- `con_br_more_than_one`：存在不止一条条件分支

> **为什么 taken 时不 stall？** 若第一条分支预测 taken，整个取指窗口在该分支处截断，后续 half-word 都无效，因此不存在"多条分支冲突"。

### 4.3 stall 信号生成

```verilog
// 行 1408
assign br_more_than_one_stall = masked_bry_update_vld;
```

`br_more_than_one_stall` 被加入 `ipctrl_ifctrl_stall`，冻结 IF 上游的新窗口；同时，IPCTRL 计算 `vpc_onehot_masked_bry_update` 和各 bank 的 `bry_data_masked`，把 IFDP 中保存的起始点/剩余边界推进到第一条条件分支之后，供下一轮处理剩余部分。

它特意**没有**加入 `ip_self_stall`。因此当前 IP 流水项的 `ip_vld` 仍可成立并送往 IB，行为不是“整条 IP 流水停住后原样重做”，而是“先提交当前可处理片段，冻结上游窗口，再处理剩余片段”。如果一个窗口有更多条件分支，这个过程可能重复，不应笼统限定为只多停 1 拍。

### 4.4 hit_cnt：way 预测计数器

```verilog
// 行 1303-1313
always @(posedge forever_cpuclk or negedge cpurst_b)
begin
  if(!cpurst_b)
    hit_cnt[2:0] <= 3'b011;  // 初始值 3，中间值
  else if(icache_way0_hit)
    hit_cnt[2:0] <= hit_cnt_sub[2:0];  // way0 命中则减 1
  else if(icache_way1_hit)
    hit_cnt[2:0] <= hit_cnt_add[2:0];  // way1 命中则加 1
  else
    hit_cnt[2:0] <= hit_cnt[2:0];
end
assign ipctrl_pcgen_inner_way0 = (hit_cnt[2:0] == 3'b000);
assign ipctrl_pcgen_inner_way1 = (hit_cnt[2:0] == 3'b111);
```

这是一个 3-bit 饱和偏置状态：Way0 hit 时向 0 移动，Way1 hit 时向 7 移动；只有达到端点才通过 `inner_way0/1` 告知 PCGEN，可在 cache line 内部顺序取指时形成单路 way 预测，否则 PCGEN 默认 `2'b11`（两路都读）。

这里有一个必须按 RTL 原样理解的边界：`hit_cnt` 每个 `forever_cpuclk` 都观察 `icache_way0_hit/way1_hit`，没有用 `ip_data_vld`、stall 或 pipedown 门控，而且异常会把 `icache_way0_hit` 强制为 1。因此它不是“每个已提交 I-Cache 访问只统计一次”的严格计数器；同一 stalled 流水项可能重复推动它，异常也会向 Way0 方向偏置。它更接近低成本的近期 way 倾向启发式状态，不能当成真实 Way0/Way1 访问比例性能计数器。

---

## 5. I-Cache 命中判断与 Way 预测错误

### 5.1 icache_way0_hit / icache_way1_hit

```verilog
// 行 1284-1298
assign icache_way0_hit = ifdp_ipctrl_way0_28_24_hit && 
                         ifdp_ipctrl_way0_23_16_hit &&
                         ifdp_ipctrl_way0_15_8_hit && 
                         ifdp_ipctrl_way0_7_0_hit || 
                         ifdp_ipctrl_expt_vld; 
assign icache_way0_hit_short = ifdp_ipctrl_way0_28_24_hit_dup && ...
```

tag 命中信号由 IFDP 分成 4 段寄存，四段全部为 1 才构成对应 I-Cache way 命中。`icache_way0_hit_short` 使用 IFDP 保存的 `_dup` 寄存器副本。让不同逻辑锥消费独立寄存器输出具有降低单点扇出的结构意图；物理实现是否真的复制单元、改善多少时序，需要综合与 STA 证明。

> **为什么 expt_vld 也置 Way0 hit？** 异常时 `ip_data_vld` 明确要求 `!ifdp_ipctrl_expt_vld`，所以这个“命中”不会把 I-Cache 数据当作正常指令提交；异常通过独立的 `ip_expt_vld` 进入下游。将共享的选路逻辑归一到 Way0 可避免异常路径出现两路均不命中的不定选择。还要注意它会影响未加 valid 门控的 `hit_cnt`。

### 5.2 ip_data_vld：IP 级数据有效

```verilog
// 行 1267-1280
assign ip_data_vld = ifctrl_ipctrl_vld && 
                     !ifdp_ipctrl_expt_vld && 
                     (
                       (
                         !ifdp_ipctrl_refill_on && 
                         ifdp_ipctrl_tsize && 
                         (icache_way0_hit  && ifdp_ipctrl_way_pred[0] || 
                          icache_way1_hit  && ifdp_ipctrl_way_pred[1])
                       ) || 
                       (
                          ifdp_ipctrl_refill_on && 
                          icache_way0_hit
                       )
                     );
```

`ip_data_vld` 为真要求：
1. IF 级有效（`ifctrl_ipctrl_vld`）
2. 没有异常（非 expt_vld）
3. 正常 cache 路径中 `tsize=1`，且命中的 way 已在 way prediction 中打开；或 refill 旁路状态下逻辑 Way0 命中

**为什么 way 必须与预测一致？** 若实际命中的 way 与预测不同，说明 way 预测出错，此时数据来自错误的 cache bank，需要 reissue（重新取指）而不是继续流水。

`tsize=0` 不一定表示异常或“无数据”，而是 I-Cache 未启用或 MMU 标记为 non-cacheable。此时正常 I-Cache hit 路径被关闭，IPCTRL 会发起一拍的非 cache-line refill/取数事务，返回数据仍通过 `refill_on + 逻辑 Way0` 路径形成 `ip_data_vld`。

### 5.3 Way Pred Error 与 Reissue

```verilog
// 行 1462-1470
assign way_mispred_reissue = ifctrl_ipctrl_vld && 
                             (
                               !ifdp_ipctrl_refill_on && 
                               !ifdp_ipctrl_expt_vld && 
                               ifdp_ipctrl_tsize && 
                               (icache_way0_hit && !ifdp_ipctrl_way_pred[0] || 
                                icache_way1_hit && !ifdp_ipctrl_way_pred[1])
                             );
```

`way_mispred_reissue` 为真时：实际命中的 way 与预测 way 不符。此时触发：

```verilog
// 行 1905-1910
assign ipctrl_pcgen_reissue_pcload        = way_mispred_reissue || icache_refill_reissue;
assign ipctrl_pcgen_reissue_way_pred[1:0] = (way_mispred_reissue)
                                          ? way_mispred_reissue_way_pred[1:0] 
                                          : 2'b11;
assign ipctrl_pcgen_reissue_pc[PC_WIDTH-2:0] = ipdp_ipctrl_vpc[PC_WIDTH-2:0];
```

Reissue 使用相同 VPC 和 `{icache_way1_hit, icache_way0_hit}` 重新取指，从而打开实际命中的数据 bank。`ipctrl_btb_way_pred_error` 同时通知常规 BTB 当前保存的 I-Cache way prediction 不匹配；这里的“way pred error”不是 BTB 位置槽命中错误，也不是分支方向误预测。

---

## 6. BHT 数据融合

### 6.1 ipctrl_bht_vld：BHT 数据何时有效

```verilog
// 行 1252
assign ipctrl_bht_vld = ip_data_vld;
```

BHT 数据有效的前提是 I-Cache 命中（`ip_data_vld`）。BHT 读取在 IF 阶段发出，IP 阶段使用结果。

```verilog
// 行 1933-1936
assign ipctrl_ipdp_bht_vld = ip_data_vld && 
                              !pcgen_ipctrl_cancel && 
                              !miss_under_refill_stall &&
                              !rtu_ifu_xx_dbgon;
```

发给 ipdp 的 `bht_vld` 还额外排除了 cancel、miss stall 和 debug 模式。这样 ipdp 中的 BHT 相关寄存器（vghr 等）只在真正有效的周期更新。

### 6.2 ipctrl_bht_stall（ifctrl_bht_stall）

```verilog
// 行 1418-1420
assign ipctrl_ifctrl_bht_stall = ibctrl_ipctrl_stall || 
                                 bry_missigned_stall || 
                                 miss_under_refill_stall;
```

当 IB 级 stall、BRY 边界重建或 miss-under-refill 时，BHT 预测流水不能接受新的对应项。注意 `br_more_than_one_stall` **不**在 `bht_stall` 中：此时 IF 的新窗口被冻结，但同一窗口的剩余 BRY 和条件分支预测上下文需要继续推进，不能把 BHT 流水也按普通自 stall 原样冻结。

### 6.3 ipctrl_bht_con_br_vld：向 BHT 反馈

```verilog
// 行 1955-1959
assign con_br_vld = con_br_first_branch && 
                    ip_data_vld && 
                    !pcgen_ipctrl_cancel && 
                    !ibctrl_ipctrl_stall;
assign ipctrl_bht_con_br_vld   = con_br_vld;                               
assign ipctrl_bht_con_br_taken = bht_result;
assign ipctrl_bht_more_br      = con_br_more_than_one && !bht_result && ip_data_vld;
```

每当 IP 级处理到条件分支时（第一条分支是条件分支），向 BHT 模块反馈：
- `con_br_vld`：本周期处理一条条件分支，BHT 可投机推进虚拟全局历史（VGHR）
- `con_br_taken`：写入 VGHR 的预测方向，不是分支执行结果
- `more_br`：当前窗口还有后续条件分支，BHT 选择下一候选预测信息时使用

> **为什么 IP 级就更新 GHR？** 这是投机历史更新。`ct_ifu_bht` 的 `vghr_reg` 在 `ipctrl_bht_con_br_vld` 时移入预测方向，让更年轻的分支看到预测后的历史；BJU 误预测可用执行侧历史纠正，RTU flush 时则从由退休条件分支维护的 `rtughr_reg` 恢复。这里更新的是历史上下文，不等于训练 BHT 方向计数器为“正确结果”。

---

## 7. Change Flow 生成：核心分支预测决策

这是 ipctrl 最核心的逻辑，决定取指流向是否需要改变（即是否发生跳转）。

### 7.1 ip_pcload：本周期需要改变 PC

```verilog
// 行 908-916
assign ip_chgflw_pre = ip_data_vld && (h0_vld || bry0_hit || bry1_hit); 
assign ip_pcload     = ip_chgflw_pre && branch_chgflw;
```

其中：
- `ip_chgflw_pre`：当前数据有效，而且 H0 或某套 BRY 边界假设可解释当前窗口；它只建立“分支选择逻辑可以工作”的前提，不单独证明窗口里一定有分支
- `branch_chgflw = bht_result ? branch_taken : branch_ntake`：根据 BHT 方向选择是否真正改变流向

```verilog
// 行 799-803
assign bht_result    = ipdp_ipctrl_bht_result;
assign branch_chgflw = (bht_result)
                       ? branch_taken   // BHT 预测 taken → 必须更改 PC
                       : branch_ntake;  // BHT 预测 ntaken → 若有无条件分支仍需跳转
```

这里最容易被信号名误导。结合 `ct_ifu_precode` 可得到准确语义：

- `*_br_taken` 来自 precode 的 `h*_br`，覆盖可由这条直接目标路径处理的条件分支和直接无条件跳转（`JAL`、`C.J`）；
- `*_br_ntake` 来自 `h*_ab_br`，只覆盖直接无条件跳转（`JAL`、`C.J`）；
- 两者异或得到 `*_con_br`，即条件分支集合；
- JALR/return 等间接控制流由 Ind-BTB/RAS 等专门路径处理，不能因为字段名 `ab_br` 就把 JALR 也算进来。

因此公式的体系结构含义是：

```text
BHT 预测 taken     -> 条件分支或直接无条件跳转都可重定向
BHT 预测 not-taken -> 条件分支顺序执行，但直接无条件跳转仍必须重定向
```

`taken/ntake` 在这里是为两种 BHT 选择路径准备的候选向量名，不是该分支已经执行得到的真实 taken/not-taken 结果。

### 7.2 ip_chgflw_mask：避免重复改变流向

```verilog
// 行 911-914
assign ip_chgflw_mask = ip_if_pcload 
                     && !ipdp_ipctrl_l0_btb_ras 
                     && l0_btb_hit_l1_btb
                     && !ip_chgflw_mistaken_flop;
```

当 IF 级已经根据 L0 BTB 重定向，而且 IP 级选中的常规 BTB 位置槽目标与 L0 目标一致时，IP 级不需要再次发 chgflw。`l0_btb_hit_l1_btb` 是根据当前方向路径、命中 I-Cache way 和分支所在的 half-word 位置组，选择 IFDP 预先计算的 L0/常规 BTB target 比较结果；它不是重新查询一次 L0 tag。

> **为什么需要 mask？** L0 BTB 是在 IF 级查询的，比 IP 级的 BHT+BTB 早一个周期。如果 L0 BTB 预测正确（`ip_if_pcload`），IP 级再发一次 chgflw 会造成重复跳转，产生错误流。

### 7.3 ipctrl_chgflw_vld：最终 Change Flow 有效

```verilog
// 行 948-950
assign ipctrl_chgflw_vld = (branch_chgflw)
                          ? ip_chgflw_pre && !ip_chgflw_mask
                          : ip_chgflw_mistaken_pre;
```

两种触发情形：
1. **本级需要重定向**：合法边界上存在由当前 BHT 选择路径要求重定向的直接控制流，且没有被“L0 已做出相同重定向”屏蔽；
2. **撤销较早重定向**：IF 级已经按非 RAS 的 L0 项跳转，但 IP 级判断当前条件分支应顺序执行，需要回到顺序取指窗口。

### 7.4 ip_chgflw_mistaken：预测方向出错

```verilog
// 行 919-925
assign ip_chgflw_mistaken_pre = ip_if_pcload
                             && !ipdp_ipctrl_l0_btb_ras
                             && !con_br_more_than_one
                             && (h0_vld || bry0_hit || bry1_hit)
                             && ip_data_vld;
assign ip_chgflw_mistaken = ip_chgflw_mistaken_pre && !branch_chgflw;
```

`ip_chgflw_mistaken` 为真时：IF 级按非 RAS L0 项跳转了（`ip_if_pcload`），但 IP 级判断当前路径不应重定向（`!branch_chgflw`），需要纠正。条件还排除了 `con_br_more_than_one`，避免尚未完成窗口内多分支拆分时过早定性。这会触发 `ipctrl_pcgen_branch_mistaken`，并使用 IFDP 保存的 `l0_btb_mispred_pc` 恢复顺序取指。

#### ip_chgflw_mistaken_flop

```verilog
// 行 927-940
always @(posedge forever_cpuclk or negedge cpurst_b)
begin
  if(!cpurst_b)
    ip_chgflw_mistaken_flop <= 1'b0;
  else if(pcgen_ipctrl_pipe_cancel)
    ip_chgflw_mistaken_flop <= 1'b0;
  else if(ibctrl_ipctrl_stall || ip_self_stall || br_more_than_one_stall)
    if(ip_chgflw_mistaken || ip_pcload)
      ip_chgflw_mistaken_flop <= 1'b1;
    else
      ip_chgflw_mistaken_flop <= ip_chgflw_mistaken_flop;
  else
    ip_chgflw_mistaken_flop <= 1'b0;
end
```

当流水线 stall 时，如果本周期已经有 chgflw 或 mistaken，锁存这个状态。这是为了防止 stall 期间信号重复触发，造成 pcgen 多次加载同一 PC。

### 7.5 ipctrl_pcgen_chgflw_pcload 的完整路径

```
ip_data_vld
  && (h0_vld || bry0_hit || bry1_hit)   → ip_chgflw_pre
    && branch_chgflw
      && !ip_chgflw_mask                 → ip_pcload
                                         → ipctrl_chgflw_vld
                                         → ipctrl_pcgen_chgflw_pcload
```

### 7.6 chgflw_pc：跳转目标 PC 的选择

```verilog
// 行 1042-1053
assign chgflw_pc_low[19:0] = (bht_result)
                             ? (icache_way0_hit_short)
                               ? way0_chgflw_pc_taken[19:0]
                               : way1_chgflw_pc_taken[19:0]
                             : (icache_way0_hit_short)
                               ? way0_chgflw_pc_ntake[19:0]
                               : way1_chgflw_pc_ntake[19:0];
assign chgflw_pc_high[PC_WIDTH-22:0] = (branch_chgflw)
                                     ? ipdp_ipctrl_vpc[PC_WIDTH-2:20] 
                                     : ipdp_ipctrl_l0_btb_mispred_pc[PC_WIDTH-2:20];
assign chgflw_pc[PC_WIDTH-2:0] = {chgflw_pc_high[PC_WIDTH-22:0],chgflw_pc_low[19:0]};
```

目标 PC 构造：

- **低 20 个内部 PC 位**：按最早分支位置从常规 BTB 的 4 个固定位置槽中选择；槽0对应 H1/H2，槽1对应 H3/H4，槽2对应 H5/H6，槽3对应 H7/H8。它们不是 I-Cache 的 4 个 way；
- **高位**：真正重定向时取当前 VPC 高位；撤销 L0 重定向时取 `l0_btb_mispred_pc` 高位，同时低位选择逻辑在没有 `br_ntake` 候选时也回退到该地址；
- 内部 PC 省略架构 bit0，所以低 20 位覆盖架构地址 `[20:1]`，对应 2 MiB 区域，不是 64 KiB。跨该高位边界的正确性还需结合常规 BTB 的写入约束、PCGEN 更高位处理和后端纠错路径分析，不能只看本段拼接便断言所有目标都与源 PC 同区。

### 7.7 改流目标和“目标处 I-Cache way”同时预测

常规 BTB 的每个位置槽除 `target[19:0]` 外，还保存 `pred[1:0]`。IPCTRL 用与 target 相同的分支位置优先级选择对应 `pred`：

```text
当前分支位置
  -> 选择 BTB 槽0/1/2/3
  -> 同时得到 target_low[19:0] 和 target_way_pred[1:0]
```

最终 `ipctrl_pcgen_chgflw_way_pred` 在正常重定向时携带该目标 way prediction，使 PCGEN 访问目标窗口时可只打开预测的数据 bank；撤销 L0 重定向时则置 `2'b11`，让两路都可读，优先保证恢复正确。

还要区分另一个同名接口 `ipctrl_btb_way_pred`：它把**当前 IP 窗口实际命中的 I-Cache way**反馈给 BTB 的 pending/update 路径。若当前两路都未命中，或者 refill 数据借用逻辑 Way0 通道，RTL 改用 I-Cache FIFO/替换位构造将要填入的 way。前者是 BTB 读出后随改流送往目标访问的预测，后者是当前窗口到达时供 BTB 记录/校正的实际或替换 way 信息；必须结合 BTB pending 状态关联它属于哪次先前改流，不能仅凭 IPCTRL 单模块把它称为当前分支源或目标。

---

## 8. I-Cache Miss 处理

### 8.1 ip_refill_pre：判断是否需要 refill

```verilog
// 行 1389-1403
assign ip_refill_pre = ifctrl_ipctrl_vld && 
                       !ifdp_ipctrl_expt_vld &&
                       (
                         (
                           !ifdp_ipctrl_refill_on && 
                           !(
                              ifdp_ipctrl_tsize && 
                              (icache_way0_hit || icache_way1_hit)
                            )
                         ) || 
                         (
                           ifdp_ipctrl_refill_on && 
                           !icache_way0_hit
                         )
                       );
```

条件：
- 正常状态（非 refill_on）：`tsize=0`，或者 `tsize=1` 但两路均未命中，都需要通过 refill/BIU 路径取数；
- refill 旁路状态（refill_on）：逻辑 Way0 未命中，说明当前返回 beat 尚未成为本 VPC 的有效数据。

第一项很重要：`ip_refill_pre` 既覆盖 cacheable I-Cache miss，也覆盖 I-Cache 关闭或 non-cacheable 的取指。后者在 L1 Refill 中使用单 beat、不写 I-Cache 的路径，不能全部归类成“cache line miss”。

### 8.2 ipctrl_l1_refill_miss_req：发送 Miss 请求

```verilog
// 行 1428-1437
assign ip_icache_refill = (ip_refill_pre && 
                          !ipdp_ipctrl_ip_expt_vld &&
                          !icache_chk_err_refill ||
                          icache_chk_err_refill_ff
                         ) && 
                         !l1_refill_ipctrl_busy && 
                         !(cp0_ifu_no_op_req && ibctrl_ipctrl_low_power_stall);
assign ipctrl_l1_refill_miss_req = ip_icache_refill;
```

关键约束：`!l1_refill_ipctrl_busy`——L1 Refill 状态机非 IDLE 时不接收新请求。同一组“有取数需要且 refill 当前空闲”的条件还生成 `icache_refill_reissue`，进而产生 `ipctrl_pcgen_reissue_pcload`：PCGEN 保存/重发当前 VPC，而 refill 状态机开始接管该地址的取数。

当前开源 RTL 中 `icache_chk_err_refill` 和其寄存版本均被直接绑为 0，`ipctrl_pcgen_chk_err_reissue` 也为 0。即使数组 wrapper 存在 `L1_CACHE_ECC` 相关配置，不能据此声称 IPCTRL 的 parity/ECC error-refill 路径在当前生成版本中有效。

### 8.3 miss_under_refill_stall：等待 refill 完成

```verilog
// 行 1372-1373
assign miss_under_refill_stall = (ip_refill_pre || icache_chk_err_refill_ff) && 
                                 l1_refill_ipctrl_busy;
```

当需要 refill 但 refill 状态机繁忙时，IP 级自 stall，等待。

### 8.4 stall 信号层次

```verilog
// 行 1363-1422
assign ip_self_stall = bry_missigned_stall || miss_under_refill_stall;
assign ipctrl_ifctrl_stall = ibctrl_ipctrl_stall || 
                             bry_missigned_stall || 
                             miss_under_refill_stall || 
                             br_more_than_one_stall;
```

| stall 类型 | 触发条件 | 影响 |
|-----------|---------|------|
| `ibctrl_ipctrl_stall` | IB 级不能接收新的 IP 输出 | IP→IB valid/exception 保持，IF 上游停止推进 |
| `bry_missigned_stall` | Bry 对齐出错，需重新计算 | IP 自 stall，重新解析 bry |
| `miss_under_refill_stall` | Miss 且 refill 状态机忙 | 等待 refill 完成 |
| `br_more_than_one_stall` | 当前剩余窗口有多条条件分支且第一条预测不跳 | 冻结 IF 上游并推进 BRY 剩余片段，但不取消当前 `ip_vld` |

`ipctrl_ifctrl_stall_short` 只包含 IB stall、bry missigned 和 miss-under-refill，排除了 `br_more_than_one_stall`；完整 `ipctrl_ifctrl_stall` 才包含后者。这与 IFCTRL 的 `stall_short` 构成较早的 PCGEN 反压路径。实际时序收益需要 STA 证明。

### 8.5 `ip_vld`：正常数据和异常共用下行流水

```verilog
assign ip_expt_vld = ifctrl_ipctrl_vld &&
                     (ifdp_ipctrl_expt_vld || ipdp_ipctrl_ip_expt_vld);

assign ip_vld = (ip_data_vld || ip_expt_vld) &&
                !icache_chk_err_refill &&
                !icache_chk_err_refill_ff &&
                !pcgen_ipctrl_cancel &&
                !ip_self_stall &&
                !rtu_ifu_xx_dbgon;
```

正常指令需要 `ip_data_vld`，取指异常则通过 `ip_expt_vld` 单独使流水项有效，因此异常不要求正常 I-Cache 数据命中。两者都受 cancel、自 stall 和 debug 接管控制。`br_more_than_one_stall` 不在 `ip_self_stall` 中，所以前文所述的当前片段仍可下传。

`ipctrl_ibctrl_vld` 和 `ipctrl_ibctrl_expt_vld` 是真正的 IP→IB 寄存有效位：pipe cancel 清零，IB stall 时保持。在 debug 模式下，普通 `ip_vld` 被 `had_ifu_ir_vld` 替代，异常 valid 被清零。这说明 HAD 注入是显式的旁路协议，不能用正常 I-Cache/BRY 条件解释 debug 指令的有效性。

### 8.6 当前 RTL 的时钟实现边界

IPCTRL 中 `ip_chgflw_mistaken_flop`、L0 训练分类寄存器、`hit_cnt` 以及 IP→IB valid/exception 寄存器都直接使用 `forever_cpuclk`，本文件没有实例化有效的局部 `gated_clk_cell`。源码保留了 parity error clock 的注释模板，但对应错误信号在当前版本被绑 0，实例本身未生成。

因此，不能像读取 IFDP 那样把 `ipctrl_ifdp_gateclk_en` 误认为 IPCTRL 自己的门控时钟。该信号是 IPCTRL 输出给 IFDP 的本地门控条件；IPCTRL 自身寄存器是否在综合后由工具自动门控，需要查看综合网表和时钟门控报告。

---

## 9. Bry Missigned Stall：分支对齐错误处理

### 9.1 问题根源

当 change flow 使 VPC 落在 16 字节窗口中部时，预存的 Bank0/Bank1 两套 H1 假设不一定能把该 VPC 解释成合法边界。若无 H0 且当前 VPC 在两套 BRY 中都不命中，IPCTRL 将其归类为 `missigned`，使用 IPDP 已得到的真实 16/32 位长度信息重新递推边界。

### 9.2 missigned_bry_vld 的计算

```verilog
// 行 1481-1502（代表性片段）
assign missigned_bry_vld[7] = 1'b1; // H1 永远有效
assign missigned_bry_vld[6] = (vpc_onehot[6])
                            ? 1'b1 
                            : !(bry_vld_32[7] & missigned_bry_vld[7]);
// ...以此类推向低位传播
```

这是一个链式逻辑。VPC one-hot 指向的位置被强制视为新的起点；随后若某个有效起点是 32 位指令的低 half-word，下一个 half-word 被该指令占用，边界位为 0，否则下一个位置可成为新起点。最后再与 `ifdp_ipctrl_vpc_bry_mask` 相与，屏蔽 VPC 之前的位置。

### 9.3 触发 stall

```verilog
// 行 1521-1522
assign missigned_bry_update_vld = ip_data_vld && 
                                 (!h0_vld && !bry0_hit && !bry1_hit);
```

当 `ip_data_vld` 有效但无 H0且当前 VPC 在 bry0/bry1 都不命中时，触发自 stall，并把重建的 `missigned_bry` 反向写入 IFDP 保存的 BRY 状态。典型无额外反压情况下下一拍即可按新边界继续；若同时存在 IB stall、cancel 等控制，实际持续周期应看握手波形，不能把组合条件机械地固定为永远 1 周期。

---

## 10. H0 的特殊处理

### 10.1 H0 是什么

H0 是 ipdp 中维护的特殊寄存器，保存上一个 16 字节取指块末尾残留的 16-bit 半字。当一条 32-bit 指令跨越两个相邻取指块时，H0 保存前一块末尾的低半字，下一块的 H1 提供高半字。

```verilog
// 行 1527
assign h0_vld = ipdp_ipctrl_h0_vld;
```

### 10.2 H0 在 bry 处理中的特殊地位

```verilog
// 行 698-701
assign way0_bry0_hit = h0_vld || ifdp_ipctrl_w0_bry0_hit;
```

若 `h0_vld=1`，两路的 `way*_bry0_hit` 都强制为 1，而 `way*_bry1_hit` 被压为 0。这意味着当前窗口必须按 Bank0 假设解释：H0 是跨窗口 32 位指令的低 half-word，H1 是其高 half-word，新的独立指令边界从 H2 开始。具体使用 I-Cache Way0 还是 Way1，仍由 tag hit 选择。

### 10.3 H0 对分支预解码的覆盖

```verilog
// 行 712-713
assign w0b0_br_taken[7] = ifdp_ipctrl_w0b0_br_taken[7] || ipdp_ipctrl_h0_br;
assign w0b0_br_ntake[7] = ifdp_ipctrl_w0b0_br_ntake[7] || ipdp_ipctrl_h0_ab_br;
```

跨窗口指令被映射到当前候选向量的 bit7（最高位置优先级）。若 H0+H1 解码为当前直接分支集合中的指令，`h0_br` 把它加入 `br_taken` 候选；若它是 `JAL`/`C.J` 这类直接无条件跳转，`h0_ab_br` 还把它加入 `br_ntake` 子集。这里仍是供 BHT 两种方向选择的**类型候选**，不是把尚未执行的条件分支“强制判为 taken”。

### 10.4 ipctrl_pcgen_h0_vld

```verilog
// 行 1922
assign ipctrl_pcgen_h0_vld = h0_vld;
```

`ipctrl_pcgen_h0_vld` 告知 PCGEN 当前 IP 级存在跨窗口 H0。PCGEN 对它的直接使用点位于 **IP reissue 的 BHT PC 选择**：若 reissue 且 H0 有效，`ifpc_bht_chgflw_pre[6:3]` 使用 reissue PC 的窗口号减 1，低三位保持，从而让重发时的 BHT 上下文回到跨窗口指令开始所在的前一 16 字节块；无 H0 时直接使用 reissue PC。它并不是无条件地改写正常顺序取指的 BHT 索引。

---

## 11. L0 BTB 信号

### 11.1 l0_btb_hit 与 l0_btb_miss

L0 BTB 是 16 项并行 tag 比较的小型前置目标缓存，在 IF 级较早给出快速重定向。它没有地址 index 后只比较单项的“直接映射”读结构；16 个 entry 都参与比较，分配则由循环 FIFO 指针选择。

```verilog
// 行 1153-1161
assign l0_btb_hit  = ip_pcload && ip_chgflw_mask;                       
assign l0_btb_miss = (!ipdp_ipctrl_l0_btb_vld || ipdp_ipctrl_l0_btb_ras && ipdp_ipctrl_l0_btb_vld)
                  && ( 
                      branch_taken && (bht_data[1:0] == 2'b11) ||
                      branch_ntake
                     ) 
                  && l0_btb_ipctrl_st_wait
                  && ip_vld
                  && !ip_expt_vld;
```

- `l0_btb_hit`：IP 级本来会重定向，但确认 IF 级 L0 重定向目标与所选常规 BTB 目标一致，因而被 mask；
- `l0_btb_miss`：在 L0 BTB 的 WAIT 关联窗口内，没有普通 L0 有效项（或当前项标记为 RAS），同时出现值得建立普通 L0 项的直接控制流。

对条件分支，`l0_btb_miss` 只在 `bht_data==2'b11`（strongly taken）时建立候选；直接无条件跳转通过 `branch_ntake` 不受该门槛限制。这是 L0 容量很小时的准入过滤：只让稳定 taken 的条件分支和必跳的直接跳转占用条目。`l0_btb_ipctrl_st_wait` 还要求这次分类与 L0 BTB 先前进入 WAIT 的取指窗口对应，它不是独立的全局 miss 统计脉冲。

### 11.2 `l0_btb_mispred`：已有快速预测需要纠正

```verilog
assign l0_btb_mispred =
       ip_if_pcload
    && !ipdp_ipctrl_l0_btb_ras
    && !l0_btb_hit_l1_btb
    && ip_pcload
    && l0_btb_ipctrl_st_wait
 || ip_chgflw_mistaken
    && l0_btb_ipctrl_st_wait;
```

它覆盖两类情况：

1. IF 级已按普通 L0 项重定向，IP 级也确认当前分支应该重定向，但常规 BTB 目标与 L0 目标不一致；
2. IF 级已按普通 L0 项重定向，IP 级却判断条件分支不应跳转，即 `ip_chgflw_mistaken`。

这与 `l0_btb_miss` 不同：miss 是缺少可用普通项并准备建立稳定分支，mispred 是已有较早预测给出了错误方向/目标，需要使对应项降级、清除或重训。IPCTRL 将 hit/miss/mispred 以及 `st_wait` 打拍送往 IBCTRL/IBDP，真正的 L0 entry 写入控制在后续路径完成。

### 11.3 l0_btb_wait_next

```verilog
// 行 1994-2000
assign ipctrl_l0_btb_wait_next = (ipdp_ipctrl_h8_br 
                                  || ipdp_ipctrl_no_br && (|vpc_onehot[3:0])
                                  || br_more_than_one_stall)
                              && ip_data_vld && !pcgen_ipctrl_cancel ...;
```

三种情况会要求 L0 BTB 的关联状态继续观察后续窗口：

1. H8（最后一个 half-word）呈现分支预解码，控制流指令可能跨窗口；
2. 当前窗口没有分支，且有效起始点位于 H5~H8，当前可观察范围较短；
3. `br_more_than_one_stall` 正在把同一窗口拆成多个条件分支片段。

最终输出还要求 `ip_data_vld`，并排除 cancel、`ip_self_stall` 和 debug。这里的“wait next”是 L0 训练/分类的时间关联控制，不表示 I-Cache 一定顺序读取下一行。

---

## 12. 接口汇总

### 12.1 向 pcgen 的关键输出

| 信号 | 含义 |
|------|------|
| `ipctrl_pcgen_chgflw_pcload` | 需要改变 PC 流向 |
| `ipctrl_pcgen_chgflw_pc` | 新的目标 PC |
| `ipctrl_pcgen_reissue_pcload` | I-Cache way prediction 不匹配，或开始 refill/非缓存取数时重发当前 VPC |
| `ipctrl_pcgen_branch_taken` | IP 级形成了未被 L0 mask 的预测重定向；不是执行完成的真实 taken |
| `ipctrl_pcgen_branch_mistaken` | IP 级撤销较早的普通 L0 重定向；不是 BJU 最终误预测信号 |
| `ipctrl_pcgen_h0_vld` | H0 有效，reissue 时调整 BHT PC 到前一取指窗口 |

### 12.2 向 BHT 的输出

| 信号 | 含义 |
|------|------|
| `ipctrl_bht_con_br_vld` | 本周期处理条件分支，投机推进 VGHR |
| `ipctrl_bht_con_br_taken` | 写入投机历史的预测方向 |
| `ipctrl_bht_more_br` | 同一剩余窗口还有条件分支 |
| `ipctrl_bht_vld` | BHT 操作有效 |

### 12.3 向 L1 Refill 的输出

| 信号 | 含义 |
|------|------|
| `ipctrl_l1_refill_miss_req` | 发送 miss 请求 |
| `ipctrl_l1_refill_vpc` | 请求对应的内部虚拟 PC（省略架构 bit0） |
| `ipctrl_l1_refill_ppc` | `{MMU physical tag, VPC 页内低位}` 拼成的内部物理 PC |

---

## 13. 完整逻辑流程图

```
IF 级取指完成
        │
        ▼
[ifdp] 产生 tag hit / bry 数据 / pa / vpc_onehot
        │
        ▼
[ipctrl] 接收上述信号
        │
        ├─── icache_way0_hit / way1_hit
        │         │
        │         ├─ ip_data_vld ─→ ipctrl_bht_vld
        │         │
        │         └─ way 与 way_pred 不符 ─→ way_mispred_reissue ─→ reissue_pcload
        │
        ├─── bry0_hit / bry1_hit / h0_vld（边界假设有效）
        │         │
        │         └─ ip_chgflw_pre
        │                  │
        │                  ├── branch_chgflw (BHT result + taken/ntake)
        │                  │         │
        │                  │         ├── ip_pcload ─→ (如无 mask) chgflw_pcload
        │                  │         │
        │                  │         └── !branch_chgflw + ip_if_pcload ─→ mistaken
        │                  │
        │                  └── ip_chgflw_mask (L0 BTB 已经处理)
        │
        ├─── miss? ─→ ip_refill_pre
        │                  │
        │                  └── !l1_refill_busy ─→ miss_req
        │                      l1_refill_busy  ─→ miss_under_refill_stall
        │
        └─── con_br_more_than_one ─→ br_more_than_one_stall（只冻结 IF 上游）
                                     + 提交当前片段
                                     + bry_data 推进到剩余片段
```

---

## 14. 设计总结

`ct_ifu_ipctrl` 的设计体现了几个重要原则：

1. **预计算两套边界（bry0/bry1）**：分别覆盖 H1 非起点/是起点，跨窗口时由 H0 强制选择 Bank0，特殊改流则可动态重建。
2. **分层 stall**：`ip_self_stall` 抑制当前正常输出，IB stall 保持下行 valid，多条件分支 stall 只冻结 IF 上游并拆分当前窗口。
3. **投机更新 VGHR**：IP 级移入预测方向，BJU 误预测和 RTU flush 分别提供纠正/恢复来源。
4. **L0 BTB mask 与训练分类**：目标一致时避免重复改流，并把 hit、miss、mispred 送到后续更新路径。
5. **I-Cache way prediction 恢复**：实际 tag hit 与已打开 data bank 不一致时，以相同 VPC 和正确 way mask 重发。
6. **复制关键信号**：IFDP 保存 Way0 分段 hit 的独立寄存副本供不同 IPCTRL 逻辑锥使用；其物理扇出和时序收益需由综合/STA 验证。
