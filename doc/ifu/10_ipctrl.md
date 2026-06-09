# ct_ifu_ipctrl 详解：IP 级控制器

## 1. 模块概述

`ct_ifu_ipctrl`（IP Stage Control）是 C910 处理器取指单元（IFU）IP 流水级的控制核心，负责将 IF 级取回的原始 I-Cache 数据转化为可供后续流水线消费的分支预测决策。它是贯通分支检测、BTB/BHT 融合、Change Flow 生成、I-Cache Miss 处理以及 Bry（Branch Residual）信息管理五大功能的枢纽模块，共约 2022 行 RTL。

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
| `ifdp_ipctrl_vpc_bry_mask[7:0]` | 8 | 有效 bry 位掩码（哪些 half-word 是合法的指令起始点） |
| `ifdp_ipctrl_w0b0_bry_data[7:0]` | 8 | Way0/Bank0 的 bry 数据（每位对应一个 half-word 是否是分支指令） |
| `ifdp_ipctrl_w0b0_br_taken[7:0]` | 8 | Way0/Bank0 预解码：该 half-word 是否有"taken"分支 |
| `ifdp_ipctrl_w0b0_br_ntake[7:0]` | 8 | Way0/Bank0 预解码：该 half-word 是否有"not taken"分支 |
| `ifdp_ipctrl_way0_*_hit` | 1 | Way0 各地址段 tag 命中标志（分4段：7:0、15:8、23:16、28:24） |
| `ifdp_ipctrl_way_pred[1:0]` | 2 | IF 级预测的命中 way（哪个 way 应该命中） |
| `ifdp_ipctrl_pa[27:0]` | 28 | 物理地址高位（用于 refill 请求） |
| `ifdp_ipctrl_refill_on` | 1 | 当前是否处于 refill 过程中（已有行在填充） |
| `ifdp_ipctrl_tsize` | 1 | 预取尺寸有效标志 |

### 来自 ipdp 的输入（IP 级数据通路反馈）

| 信号 | 位宽 | 含义 |
|------|------|------|
| `ipdp_ipctrl_h0_vld` | 1 | H0 寄存器有效（说明存在上一周期残留的半字） |
| `ipdp_ipctrl_h0_br` | 1 | H0 是分支指令 |
| `ipdp_ipctrl_h0_con_br` | 1 | H0 是条件分支 |
| `ipdp_ipctrl_h0_ab_br` | 1 | H0 是无条件分支（absolute branch） |
| `ipdp_ipctrl_bht_result` | 1 | BHT 预测结果（1=taken，0=not taken） |
| `ipdp_ipctrl_bht_data[1:0]` | 2 | BHT 2-bit 计数器原始值 |
| `ipdp_ipctrl_btb_way0_target[19:0]` | 20 | BTB Way0 存储的目标 PC 低位 |
| `ipdp_ipctrl_btb_way0_pred[1:0]` | 2 | BTB Way0 存储的 way 预测 |
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

C910 每个周期从 I-Cache 取回一个 cache line 段，对应 8 个 16-bit half-word（H1~H8）。由于 RISC-V C 扩展（压缩指令）支持 16-bit 指令，因此指令边界可能在任意 half-word 处。核心问题是：**当前取指窗口中哪些 half-word 是合法指令的起始位置，其中哪些是分支？**

### 3.2 vpc_2_0_onehot：取指起始位置

```verilog
// ifdp.v 中生成，传入 ipctrl
input [7:0] ifdp_ipctrl_vpc_2_0_onehot;
```

`vpc_2_0_onehot[7:0]` 是 VPC（Virtual PC）低三位的 one-hot 编码，表示本次取指从哪个 half-word 开始：

| vpc[2:0] | onehot | 含义 |
|----------|--------|------|
| 3'b000 | 8'b10000000 | 从 H1 开始取 |
| 3'b001 | 8'b01000000 | 从 H2 开始取 |
| 3'b010 | 8'b00100000 | 从 H3 开始取 |
| ... | ... | ... |
| 3'b111 | 8'b00000001 | 从 H8 开始取 |

> **为什么用 one-hot？** 后续所有 casez 逻辑都以 one-hot 为 selector，避免多级 mux，关键路径更短。

### 3.3 vpc_bry_mask：有效 bry 掩码

```verilog
input [7:0] ifdp_ipctrl_vpc_bry_mask;
```

这 8 位表示在当前取指起始点（由 vpc_onehot 确定）后，哪些 half-word 是**有效的指令起始位置**。例如：
- 若取指从 H1 开始，且 H1 是 32-bit 指令的低半字，则 H2 是 H1 指令的高半字，H3 才是下一条指令起始，H1 的 bry_mask[7]=1，H2 的 bry_mask[6]=0，H3 的 bry_mask[5]=1，……

bry_mask 由 ifdp 在 IF 级根据 vpc 和当前 cache line 中的 inst[1:0]（即每条指令的低两位）预先计算并存储。

### 3.4 bry0/bry1 的双 bank 设计

每个 way（Way0、Way1）各有两个 bank（Bank0、Bank1），对应两种假设：
- **Bank0（bry0）**：假设当前取指窗口的 H1 是一条指令的**低半字**（即 H1 处于指令中间）
- **Bank1（bry1）**：假设当前取指窗口的 H1 是一条指令的**起始**（即 H1 是新指令）

之所以要存两份预解码数据，是因为在 IF 阶段无法确知 H1 究竟是不是指令起始（需要等到解码结果）。bry0_hit/bry1_hit 信号决定哪份数据有效：

```verilog
// 行 698-701
assign way0_bry0_hit = h0_vld || ifdp_ipctrl_w0_bry0_hit;
assign way0_bry1_hit = !h0_vld && ifdp_ipctrl_w0_bry1_hit;
assign way1_bry0_hit = h0_vld || ifdp_ipctrl_w1_bry0_hit;
assign way1_bry1_hit = !h0_vld && ifdp_ipctrl_w1_bry1_hit;
```

- **h0_vld=1**：上一周期有残留半字（H0），则当前取指窗口的 H1 不是新指令起始，用 bry0 数据
- **h0_vld=0**：无残留，H1 是新指令起始，由 `ifdp_ipctrl_w0_bry1_hit` 判断用哪 bank

> **设计动机**：这是一种典型的"预先计算两种情况，运行时选择"的优化，避免等待解码完成再索引。

---

## 4. 分支碰撞处理：多条分支 stall

### 4.1 问题描述

同一个取指窗口（8 个 half-word）中可能存在多条条件分支指令。BHT 每周期只能给出一个预测结果（针对第一条分支），后续分支无法同时处理。

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

`br_more_than_one_stall` 会向上游发送 stall（通过 `ipctrl_ifctrl_stall`），同时将 bry_data 更新为"截断到第一条条件分支处"的新掩码，下一周期再处理后续指令。

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

这是一个 3-bit 饱和计数器，用于统计最近访问 way0 还是 way1 更多。当计数器饱和到 0 时，告知 pcgen 当前程序"固定在 way0"，饱和到 7 则"固定在 way1"。这用于优化 way 预测，减少不必要的 tag 查询。

---

## 5. BTB 命中判断与 Way 预测错误

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

tag 命中信号被分为 4 段来自 ifdp，全部为 1 才算命中。`icache_way0_hit_short` 使用 `_dup`（duplicate）版本，是为了**时序优化**——在关键路径上复制一份 FF，降低负载。

> **为什么 expt_vld 也置 hit？** 异常时不需要真正的 cache 数据，但流水线仍需前进，故将 way0 hit 假设为真，以维持流水线状态机的正确。

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
3. 命中的 way 与预测的 way 一致（非 refill 状态）；或 refill 状态下 way0 命中

**为什么 way 必须与预测一致？** 若实际命中的 way 与预测不同，说明 way 预测出错，此时数据来自错误的 cache bank，需要 reissue（重新取指）而不是继续流水。

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

Reissue 用相同的 VPC 但正确的 way pred 重新取指。`ipctrl_btb_way_pred_error` 输出给 BTB，让 BTB 更新 way 预测信息。

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

当 IB 级 stall、bry 对齐错误 stall 或 miss under refill stall 时，BHT 读索引不前进（BHT 是 pipeline 结构，需要知道哪一周期的 VPC 对应哪一次读）。注意 `br_more_than_one_stall` **不**在 `bht_stall` 中，因为多分支 stall 时 VPC 仍然前进到下一个分支处。

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
- `con_br_vld`：本周期有条件分支，BHT 需要更新 GHR（Global History Register）
- `con_br_taken`：预测方向（taken/not-taken）
- `more_br`：还有更多分支（BHT 可能需要多次更新 GHR）

> **为什么 IP 级就更新 GHR？** 这是"投机更新"（Speculative Update）。GHR 在分支实际执行前就根据预测方向更新，让后续分支能使用更新后的 GHR 进行预测。若最终预测出错，退休阶段会用正确历史恢复 GHR。

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
- `ip_chgflw_pre`：本取指窗口有分支（`h0_vld` 表示 H0 是分支，`bry0_hit`/`bry1_hit` 表示 bry 预解码命中）
- `branch_chgflw = bht_result ? branch_taken : branch_ntake`：根据 BHT 方向选择是否真正改变流向

```verilog
// 行 799-803
assign bht_result    = ipdp_ipctrl_bht_result;
assign branch_chgflw = (bht_result)
                       ? branch_taken   // BHT 预测 taken → 必须更改 PC
                       : branch_ntake;  // BHT 预测 ntaken → 若有无条件分支仍需跳转
```

> **branch_taken 和 branch_ntake 的含义**：
> - `branch_taken`：是否有"预解码认为 taken"的分支（来自 bry 预解码 BTB 存储的 taken 信息）
> - `branch_ntake`：是否有"预解码认为 ntaken"的分支（无条件跳转会同时标记 ntaken，表示它是一条无条件分支但 BHT 预测了 not taken 方向——不存在，无条件分支没有 ntaken。实际上 ntake 用于标记"绝对分支但预解码为 not taken"，主要指 BTB miss 的绝对跳转）

### 7.2 ip_chgflw_mask：避免重复改变流向

```verilog
// 行 911-914
assign ip_chgflw_mask = ip_if_pcload 
                     && !ipdp_ipctrl_l0_btb_ras 
                     && l0_btb_hit_l1_btb
                     && !ip_chgflw_mistaken_flop;
```

当 IF 级已经预测到了同一个跳转目标（L0 BTB 命中）时，IP 级不需要再发 chgflw。`l0_btb_hit_l1_btb` 表示当前 IP 级的分支在 L0 BTB 中有记录，并且 IF 级已经按照这个记录取指了。

> **为什么需要 mask？** L0 BTB 是在 IF 级查询的，比 IP 级的 BHT+BTB 早一个周期。如果 L0 BTB 预测正确（`ip_if_pcload`），IP 级再发一次 chgflw 会造成重复跳转，产生错误流。

### 7.3 ipctrl_chgflw_vld：最终 Change Flow 有效

```verilog
// 行 948-950
assign ipctrl_chgflw_vld = (branch_chgflw)
                          ? ip_chgflw_pre && !ip_chgflw_mask
                          : ip_chgflw_mistaken_pre;
```

两种触发情形：
1. **分支 taken**：本周期有分支且未被 L0 BTB mask 掉
2. **分支 mistaken**（预测错误的 not taken 修正）：IF 级预测了 taken 但 IP 级判断应该 not taken

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

`ip_chgflw_mistaken` 为真时：IF 级跳转了（`ip_if_pcload`）但 IP 级判断不应该跳（`!branch_chgflw`），需要纠正。这会触发 `ipctrl_pcgen_branch_mistaken`，让 pcgen 回到正确的顺序 PC。

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
- **低 20 位**：来自 BTB 存储的目标地址（4 个 way 中选一个，依据 `way0_br_taken[7:0]` 的优先级）
- **高位**：taken 时取 VPC 的高位（BTB 目标在同一 64K 范围），mistaken 时取 `l0_btb_mispred_pc`（L0 BTB 中错误预测的 PC）

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
- 正常状态（非 refill_on）：没有命中任何 way → 需要 refill
- Refill 进行中（refill_on）：Way0 未命中 → 填充的数据还没到，继续等待

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

关键约束：`!l1_refill_ipctrl_busy`——当 L1 Refill 状态机正在处理其他 miss 时，不重复发送请求。这防止了 miss 请求的重复发送。

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
| `ibctrl_ipctrl_stall` | IB 级满了（指令 buffer 满） | IP 级所有操作暂停 |
| `bry_missigned_stall` | Bry 对齐出错，需重新计算 | IP 自 stall，重新解析 bry |
| `miss_under_refill_stall` | Miss 且 refill 状态机忙 | 等待 refill 完成 |
| `br_more_than_one_stall` | 多条条件分支 | IP stall 一周期，重新处理 |

---

## 9. Bry Missigned Stall：分支对齐错误处理

### 9.1 问题根源

当取指地址发生 change flow 跳转时，新的 VPC 可能指向 cache line 的任意位置。如果当前 cache line 中的 bry 预解码数据（在 IF 级存入）是按照顺序取指的假设计算的，而实际 VPC 从中间开始，则预解码数据可能无法准确反映新起点后的指令边界，称为"missigned"（对齐错误）。

### 9.2 missigned_bry_vld 的计算

```verilog
// 行 1481-1502（代表性片段）
assign missigned_bry_vld[7] = 1'b1; // H1 永远有效
assign missigned_bry_vld[6] = (vpc_onehot[6])
                            ? 1'b1 
                            : !(bry_vld_32[7] & missigned_bry_vld[7]);
// ...以此类推向低位传播
```

这是一个链式逻辑：从 H1 开始，若某个 half-word 是 32-bit 指令的低半字（`bry_vld_32[7]`），则下一个 half-word 被占用（是其高半字），有效性为 0。该逻辑重新从 VPC 出发构建正确的指令边界。

### 9.3 触发 stall

```verilog
// 行 1521-1522
assign missigned_bry_update_vld = ip_data_vld && 
                                 (!h0_vld && !bry0_hit && !bry1_hit);
```

当 `ip_data_vld` 有效但当前 bry 数据既无 h0 也无 bry0/bry1 命中时，说明 bry 预解码对当前 VPC 无效，触发 1 周期 stall 以更新 bry 数据。

---

## 10. H0 的特殊处理

### 10.1 H0 是什么

H0 是 ipdp 中维护的一个特殊寄存器，保存上一个取指周期残留的 16-bit 半字。当 VPC 落在 32-bit 指令的高半字时（即上一个 cache line 只取到了该指令的低半字），H0 就保存那个低半字。

```verilog
// 行 1527
assign h0_vld = ipdp_ipctrl_h0_vld;
```

### 10.2 H0 在 bry 处理中的特殊地位

```verilog
// 行 698-701
assign way0_bry0_hit = h0_vld || ifdp_ipctrl_w0_bry0_hit;
```

若 `h0_vld=1`，则 `way0_bry0_hit` 强制为 1。这意味着：只要 H0 有效，当前取指窗口的 H1 就对应 bry0（H0 是上一条指令的低半字，H1 是其高半字），bry0 数据是正确的。

### 10.3 H0 对分支预解码的覆盖

```verilog
// 行 712-713
assign w0b0_br_taken[7] = ifdp_ipctrl_w0b0_br_taken[7] || ipdp_ipctrl_h0_br;
assign w0b0_br_ntake[7] = ifdp_ipctrl_w0b0_br_ntake[7] || ipdp_ipctrl_h0_ab_br;
```

H0 所在位置（bit[7]，即最高优先级）的分支信息由 H0 本身覆盖。若 H0 是一条分支指令（`h0_br`），则强制置 taken；若 H0 是无条件分支（`h0_ab_br`），则置 ntake（无条件分支在 BTB 预解码角度标记为 ntake 表示"B 型绝对跳转"）。

### 10.4 ipctrl_pcgen_h0_vld

```verilog
// 行 1922
assign ipctrl_pcgen_h0_vld = h0_vld;
```

`ipctrl_pcgen_h0_vld` 告知 pcgen 当前 IP 级存在 H0。pcgen 据此调整 BHT 读索引：H0 存在时，BHT 的索引应该用 H0 的 PC（前一 cache line 的 VPC+偏移），而不是当前 VPC。

---

## 11. L0 BTB 信号

### 11.1 l0_btb_hit 与 l0_btb_miss

L0 BTB 是一个极小的直接映射 BTB，在 IF 级查询，能比 IP 级 BTB 提前一拍预测跳转。

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

- `l0_btb_hit`：IP 级发现 change flow 且被 L0 BTB mask 掉了 → L0 BTB 预测正确，命中
- `l0_btb_miss`：分支需要跳转但 L0 BTB 没有记录（或记录了 RAS 但不适用）→ 需要更新 L0 BTB

`bht_data == 2'b11` 表示 BHT 计数器完全饱和（Strongly Taken），只有在饱和状态才值得写入 L0 BTB，避免频繁更新不稳定的分支。

### 11.2 l0_btb_wait_next

```verilog
// 行 1994-2000
assign ipctrl_l0_btb_wait_next = (ipdp_ipctrl_h8_br 
                                  || ipdp_ipctrl_no_br && (|vpc_onehot[3:0])
                                  || br_more_than_one_stall)
                              && ip_data_vld && !pcgen_ipctrl_cancel ...;
```

两种情况需要等待下一 cache line：
1. H8（最后一个 half-word）是分支指令——目标地址可能跨 cache line
2. 当前取指窗口没有分支，且有效起始点在 H5~H8 之后（剩余空间太少，有意义的分支可能在下一 cache line）

---

## 12. 接口汇总

### 12.1 向 pcgen 的关键输出

| 信号 | 含义 |
|------|------|
| `ipctrl_pcgen_chgflw_pcload` | 需要改变 PC 流向 |
| `ipctrl_pcgen_chgflw_pc` | 新的目标 PC |
| `ipctrl_pcgen_reissue_pcload` | Way 预测出错，重发取指 |
| `ipctrl_pcgen_branch_taken` | 本周期 taken 分支 |
| `ipctrl_pcgen_branch_mistaken` | IF 级预测方向出错需纠正 |
| `ipctrl_pcgen_h0_vld` | H0 有效，影响 BHT 索引 |

### 12.2 向 BHT 的输出

| 信号 | 含义 |
|------|------|
| `ipctrl_bht_con_br_vld` | 本周期有条件分支，更新 GHR |
| `ipctrl_bht_con_br_taken` | 预测方向 |
| `ipctrl_bht_more_br` | 还有更多分支 |
| `ipctrl_bht_vld` | BHT 操作有效 |

### 12.3 向 L1 Refill 的输出

| 信号 | 含义 |
|------|------|
| `ipctrl_l1_refill_miss_req` | 发送 miss 请求 |
| `ipctrl_l1_refill_vpc` | Miss 对应的虚拟 PC |
| `ipctrl_l1_refill_ppc` | Miss 对应的物理 PC |

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
        ├─── bry0_hit / bry1_hit / h0_vld
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
        └─── con_br_more_than_one ─→ br_more_than_one_stall
                                     + bry_data 更新（截断到第一条分支处）
```

---

## 14. 设计总结

`ct_ifu_ipctrl` 的设计体现了几个重要原则：

1. **预计算两套数据（bry0/bry1）**，运行时根据 h0_vld 选择，避免等待解码完成
2. **分层 stall**：自 stall（ip_self_stall）不向上游传播 valid，下游 stall（ibctrl_stall）阻止 IP 级前进
3. **投机更新 GHR**：IP 级就更新 BHT 的历史寄存器，让后续分支能用到更新的历史，失败时由 RTU 恢复
4. **L0 BTB mask**：避免 IF 级（L0 BTB）和 IP 级（L1 BTB+BHT）对同一跳转重复改变 PC
5. **复制关键信号（_dup）**：减少扇出，在时序关键路径上插入寄存器
