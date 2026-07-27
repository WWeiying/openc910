# ct_ifu_addrgen 模块详解

## 1. 模块概述

### 1.1 addrgen 在 IFU 流水线中的位置

C910 的取指流水线大致分为以下几个阶段：

```
IF  -->  IP  -->  IB  -->  addrgen（IB 级的后一拍）
```

- **IF 级（Instruction Fetch）**：访问 I-Cache，取回原始指令数据。
- **IP 级（Instruction Pre-decode）**：对取回的指令做初步解码，同时查询 BTB（Branch Target Buffer）做分支预测，预测目标地址 `branch_pred_result` 随即送入 pcgen，驱动下一拍的 PC。
- **IB 级（Instruction Buffer / Decode）**：指令从 ibdp（IB Data Path）中被分析，提取出分支类型、偏移量、基地址等真实信息。
- **addrgen**：IB 级完成后的下一拍（寄存器打一拍），拿到 IB 级的分析结果，**重新精确计算**分支目标地址，与 IP 级的预测值做比较，发现错误时向 pcgen 发出 chgflw（改变流水）请求，并驱动 BTB / L0-BTB 更新。

### 1.2 事后验证，而非实时预测

IP 级的 BTB 预测是**推测性**的：它在一个周期内完成查找，把预测目标直接喂给 pcgen，流水线继续向前走。但 BTB 可能预测错误（target 错误或根本没有命中）。

addrgen 的职责正是**事后核验**：在 IB 级拿到完整的指令信息后，用硬件加法器精确算出真正的目标地址，与 IP 级当时的预测地址比较，若不符则触发一次流水线冲刷（pcload/chgflw），把正确地址重新注入 pcgen。

这种"预测先行、验证纠错"的架构可以在大多数情况下隐藏分支延迟，仅在预测失败时才付出冲刷代价。

### 1.3 驱动 BTB / L0-BTB 更新

addrgen 发现 mispred 时，顺便把正确的 target 写回 BTB，使下次执行同一分支时能预测正确。L0-BTB（小型全相联缓冲，覆盖热点分支）也在同样条件下被更新。

---

## 2. 端口说明

### 2.1 来自 ibdp 的输入

| 信号名 | 宽度 | 含义 |
|--------|------|------|
| `ibdp_addrgen_branch_valid` | 1 | IB 级本周期存在有效分支指令 |
| `ibdp_addrgen_branch_base[38:0]` | 39 | 分支基地址的半字地址形式，保存架构地址 `[39:1]` |
| `ibdp_addrgen_branch_offset[20:0]` | 21 | RISC-V 编码的分支偏移字段（含符号位，按 RISC-V 位域排列） |
| `ibdp_addrgen_branch_result[38:0]` | 39 | IP 级预测的目标地址（由 ipdp 传入 ibdp 再透传） |
| `ibdp_addrgen_btb_index_pc[38:0]` | 39 | 分支指令自身的 PC，用于计算 BTB index/tag |
| `ibdp_addrgen_l0_btb_hit` | 1 | IP 级 L0-BTB 是否命中 |
| `ibdp_addrgen_l0_btb_hit_entry[15:0]` | 16 | L0-BTB 命中时的 entry 编号 |
| `ibdp_addrgen_branch_vl[7:0]` | 8 | 向量长度寄存器 vl（供 chgflw 传递给 ipdp） |
| `ibdp_addrgen_branch_vlmul[1:0]` | 2 | 向量 LMUL |
| `ibdp_addrgen_branch_vsew[2:0]` | 3 | 向量 SEW |

### 2.2 来自 lbuf（Loop Buffer）的输入

| 信号名 | 含义 |
|--------|------|
| `lbuf_addrgen_active_state` | Loop Buffer 正在活跃运行（处于循环体内） |
| `lbuf_addrgen_cache_state` | Loop Buffer 正在缓存阶段 |
| `lbuf_addrgen_chgflw_mask` | Loop Buffer 要求 addrgen 屏蔽 chgflw |

### 2.3 其他输入

| 信号名 | 含义 |
|--------|------|
| `pcgen_addrgen_cancel` | pcgen 告知 addrgen 本结果已被取消（高优先级 chgflw 覆盖） |

### 2.4 送往 pcgen 的输出

| 信号名 | 含义 |
|--------|------|
| `addrgen_pcgen_pcload` | mispred 时的 PC 更新请求（优先级 5） |
| `addrgen_pcgen_pc[38:0]` | 正确的分支目标地址 |
| `addrgen_xx_pcload` | 广播给全局的 pcload 信号（与 pcgen_pcload 同） |

### 2.5 送往 BTB 的输出

| 信号名 | 含义 |
|--------|------|
| `addrgen_btb_update_vld` | 本周期需要更新 BTB |
| `addrgen_btb_index[9:0]` | BTB 写入的 index |
| `addrgen_btb_tag[9:0]` | BTB 写入的 tag |
| `addrgen_btb_target_pc[19:0]` | 正确目标地址的低 20 位（BTB target 字段） |

### 2.6 送往 L0-BTB 的输出

| 信号名 | 含义 |
|--------|------|
| `addrgen_l0_btb_update_vld` | 需要更新 L0-BTB |
| `addrgen_l0_btb_wen[3:0]` | L0-BTB 的写使能（仅 bit[3] 有效） |
| `addrgen_l0_btb_update_entry[15:0]` | 命中时的 entry 号，写回相同 entry |
| `addrgen_l0_btb_update_vld_bit` | 恒为 0（valid bit 更新），由 BTB 本身管理 |

### 2.7 送往 ibctrl 与 ipdp 的输出

| 信号名 | 含义 |
|--------|------|
| `addrgen_ibctrl_cancel` | mispred 时取消 IB 级流水 |
| `addrgen_ipdp_chgflw_vl/vlmul/vsew` | chgflw 时携带的向量状态信息 |

---

## 3. 分支目标地址计算

### 3.1 branch_vld：本周期是否处理分支

```verilog
// 行 172-176
assign branch_vld_for_gateclk   = ibdp_addrgen_branch_valid &&
                                  !lbuf_addrgen_active_state &&
                                  !lbuf_addrgen_cache_state;
assign branch_vld               =  branch_vld_for_gateclk &&
                                  !lbuf_addrgen_chgflw_mask;
```

两个条件都要满足：
1. IB 级存在有效分支（`ibdp_addrgen_branch_valid`）
2. Loop Buffer 既未 active 也未 cache（Loop Buffer 自己负责循环分支，不需要 addrgen 介入）
3. Loop Buffer 没有屏蔽 chgflw

`branch_vld_for_gateclk` 比 `branch_vld` 少了一个 mask 条件，专门用于门控时钟使能——即便 mask 成立（不需要做 chgflw），也应保持时钟开启，让寄存器正常工作。

### 3.2 offset 字段提取与符号扩展

```verilog
// 行 178
assign branch_offset[PC_WIDTH-2:0] =
    {{19{ibdp_addrgen_branch_offset[20]}}, ibdp_addrgen_branch_offset[20:1]};
```

**为什么是 `[20:1]` 而不是 `[20:0]`？**

分支和跳转目标至少 2 字节对齐，传入的偏移字段保留了一个恒为 0 的字节地址 bit 0。addrgen 的基地址却采用半字单位，因此必须丢弃这个最低零位，使偏移和基地址具有相同单位：

```
ibdp_addrgen_branch_offset[20]    = 符号位（imm[20]）
ibdp_addrgen_branch_offset[19:1]  = 有效偏移位 imm[19:1]
ibdp_addrgen_branch_offset[0]     = 未使用（bit 0 恒为 0）
```

`ibdp_addrgen_branch_offset[20:1]` 是字节偏移除以 2 后的半字偏移。它与 `branch_base = byte_base >> 1` 相加，结果仍是半字地址；最终恢复字节目标时再在最低位补 0。这里不是把偏移左移到字节单位。

JALR 的寄存器目标检查主要在 IU/BJU 路径完成；本模块只按 IFU 上游已经形成的 `branch_base/branch_offset` 接口约定做加法，不应从这一行 RTL 推导额外的“预先左移适配”。

### 3.3 base 地址选择

```verilog
// 行 177
assign branch_base[PC_WIDTH-2:0] = ibdp_addrgen_branch_base[PC_WIDTH-2:0];
```

ibdp 根据指令类型在内部选择：
- **B 型分支（BEQ/BNE/BLT 等）**：base = 指令自身 PC
- **JAL**：base = 指令自身 PC
- **JALR**：base = rs1 寄存器值（通用寄存器读端口）

addrgen 不关心指令类型，直接使用 ibdp 传来的 `branch_base`，做到逻辑简洁。

### 3.4 最终加法

```verilog
// 行 183
assign branch_cal_result[PC_WIDTH-2:0] =
    branch_base[PC_WIDTH-2:0] + branch_offset[PC_WIDTH-2:0];
```

单拍组合逻辑加法器，39 位加法。结果 `branch_cal_result` 即为精确的分支目标地址。

---

## 4. Misprediction 检测

```verilog
// 行 182
assign branch_pred_result[PC_WIDTH-2:0] = ibdp_addrgen_branch_result[PC_WIDTH-2:0];

// 行 184
assign branch_mispred = (branch_pred_result[PC_WIDTH-2:0] != branch_cal_result[PC_WIDTH-2:0]);
```

`ibdp_addrgen_branch_result` 是 IP 级预测时记录的预测目标（经 ibdp 透传）。

比较是 39 位全字宽比较，任何一位不同都算 mispred。

**注意**：如果 IP 级 BTB 完全没有命中该分支（branch miss），则 `branch_pred_result` 通常是顺序 PC（PC+4 或 PC+2），同样会导致 mispred 检测成立，从而触发 chgflw。

### 4.1 chgflw 触发逻辑

mispred 信号在 IB 级当拍产生，但 chgflw 需要在下一拍（addrgen 打拍后）才生效：

```verilog
// 行 270-271
assign addrgen_pcgen_pcload           = addrgen_vld && addrgen_btb_mispred;
assign addrgen_xx_pcload              = addrgen_vld && addrgen_btb_mispred;
```

`addrgen_vld` 和 `addrgen_btb_mispred` 都是寄存器，是 IB 级结果打拍后的值（见第 7 节）。

---

## 5. BTB 更新触发

### 5.1 更新条件

```verilog
// 行 279
assign addrgen_btb_update_vld = addrgen_pcgen_pcload;
```

BTB 只在 **mispred 发生时**才更新（`addrgen_pcgen_pcload == 1`）。没有 mispred 说明 BTB 预测正确，无需修改。

### 5.2 BTB 写入字段

```verilog
// 行 276-278
assign addrgen_btb_index[9:0]      = addrgen_branch_index[9:0];
assign addrgen_btb_tag[9:0]        = addrgen_branch_tag[9:0];
assign addrgen_btb_target_pc[19:0] = addrgen_cal_result_flop[19:0];
```

三个字段分别是 BTB 的行地址（index）、匹配标签（tag）和目标地址低位。

### 5.3 index 和 tag 的编码规则

```verilog
// 行 185-187
assign branch_index[9:0] = ibdp_addrgen_btb_index_pc[12:3];
assign branch_tag[9:0]   = {ibdp_addrgen_btb_index_pc[19:13],
                             ibdp_addrgen_btb_index_pc[2:0]};
```

这里的 PC 位号属于内部半字地址：

- index `rtl_pc[12:3]` 对应架构字节 PC `[13:4]`，以 16 字节取指块为粒度，10 位模式跨度为 16 KiB；
- tag 高 7 位 `rtl_pc[19:13]` 对应字节 PC `[20:14]`；
- tag 低 3 位 `rtl_pc[2:0]` 对应字节 PC `[3:1]`，表示块内半字位置。

三者共同覆盖字节 PC `[20:1]`。RVC 下只有架构 `PC[0]` 恒为 0，`PC[1]` 可以为 0 或 1。

与 BTB 读取时的 index/tag 计算方式完全对称，保证读写能定位到同一个 entry。

### 5.4 为什么 addrgen 只更新 target，way_pred 由 BTB 自己管理

BTB 是双路组相联结构。`way_pred`（预测应读哪路）的更新需要 BTB 自己根据命中情况延迟决策（下次访问时 BTB 内部 LRU 或 plru 逻辑自动更新），addrgen 无需也无法直接写 `way_pred`。addrgen 只提供"正确的 target 是什么"这一信息，BTB 内部根据 index/tag 匹配后把 target 字段写入对应的 way，`way_pred` 的更新由 BTB 在下次读命中时处理。

---

## 6. L0-BTB 更新触发

### 6.1 更新条件

```verilog
// 行 293-295
assign l0_btb_update_vld = addrgen_vld
                        && addrgen_btb_mispred
                        && addrgen_l0_btb_hit;
```

L0-BTB 的更新比 BTB 多一个条件：**`addrgen_l0_btb_hit` 必须为 1**。

这是因为：
- 若 L0-BTB 没有命中，说明 IP 级使用的是 BTB 的预测（或顺序 PC），L0-BTB 中并不存在这条记录，无需更新 L0-BTB（BTB 更新已经处理了）。
- 若 L0-BTB 命中但预测目标错误，说明 L0-BTB 中存的 target 有误，需要把正确 target 写回。

### 6.2 L0-BTB 写入字段

```verilog
// 行 296-302
assign l0_btb_wen[3]     = l0_btb_update_vld;
assign l0_btb_wen[2:0]   = 3'b0;

assign addrgen_l0_btb_update_vld         = l0_btb_update_vld;
assign addrgen_l0_btb_wen[3:0]           = l0_btb_wen[3:0];
assign addrgen_l0_btb_update_vld_bit     = 1'b0;
assign addrgen_l0_btb_update_entry[15:0] = addrgen_l0_btb_hit_entry[15:0];
```

- `l0_btb_wen[3:0]`：4 位写使能，bit[3] 用于写 target，bit[2:0] 置 0（L0-BTB 对应的 valid 位不通过这里写，`update_vld_bit=0`）。
- `addrgen_l0_btb_update_entry`：直接用命中时记录的 entry 号回写，定向更新那条预测错误的 entry，不需要重新计算 hash。

---

## 7. 流水线时序与寄存器打拍

### 7.1 时序示意图

```
时钟周期   T          T+1         T+2
------------------------------------------
IP 级     BTB 预测   (预测结果已用于 pcgen)
IB 级                branch_valid=1
addrgen                           mispred 判断 + pcload
```

IB 级在 T+1 输出 `branch_vld`、`branch_cal_result`、`branch_mispred` 等，这些是**组合逻辑**。addrgen 在 T+2 周期生效（寄存器打拍），通过 `addrgen_vld` 和 `addrgen_btb_mispred` 驱动 pcgen。

### 7.2 寄存器组

```verilog
// 行 193-241（always @posedge addrgen_flop_clk）
always @(posedge addrgen_flop_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    addrgen_vld <= 1'b0;
  else if(pcgen_addrgen_cancel)  // 被更高优先级 chgflw 取消
    addrgen_vld <= 1'b0;
  else
    addrgen_vld <= branch_vld;   // 锁存 IB 级的有效信号
end
```

所有关键信号都在同一拍打拍：

| 寄存器 | 含义 |
|--------|------|
| `addrgen_vld` | 本周期 addrgen 有有效结果 |
| `addrgen_cal_result_flop` | 精确计算的目标地址 |
| `addrgen_branch_index/tag` | BTB 更新用的 index/tag |
| `addrgen_btb_mispred` | mispred 标志 |
| `addrgen_l0_btb_hit` | L0-BTB 命中标志 |
| `addrgen_l0_btb_hit_entry` | L0-BTB 命中 entry |
| `addrgen_branch_vl/vlmul/vsew` | 向量状态 |

**为什么要打拍后再用？**

组合逻辑路径：ibdp 对指令的完整解析（包括 rs1 寄存器读取）+ 39 位加法 + 比较，时序路径较长。若直接用组合结果驱动 pcgen，关键路径会很长，可能无法满足时序约束。打一拍后，时序变为两段：
1. IB 级：解析 + 加法 + 比较（结果存入寄存器）
2. addrgen 级：寄存器输出直接驱动 pcgen（短路径）

另一个原因是：`pcgen_addrgen_cancel` 需要在 addrgen_vld 被锁存后才能清零，实现有效的取消逻辑。

### 7.3 门控时钟

```verilog
// 行 263-265
assign addrgen_flop_clk_en = branch_vld_for_gateclk ||
                             addrgen_vld ||
                             pcgen_addrgen_cancel;
```

三种情况需要开启时钟：
1. IB 级有新的分支（需要写入寄存器）
2. addrgen 本身有效（需要保持寄存器值或清零）
3. pcgen 发来 cancel（需要把 `addrgen_vld` 清零）

---

## 8. 性能计数器接口

```verilog
// 行 282-283
assign ifu_hpcp_btb_mispred = addrgen_vld && addrgen_btb_mispred;
assign ifu_hpcp_btb_inst    = addrgen_vld;
```

- `ifu_hpcp_btb_inst`：每次 addrgen 处理一条分支指令时脉冲一次，用于统计总分支数。
- `ifu_hpcp_btb_mispred`：每次预测失败时脉冲，用于统计 BTB 误预测率。

PMU（Performance Monitor Unit）用这两个信号计算 BTB 预测准确率。

---

## 9. Loop Buffer 的特殊处理

```verilog
// 行 169-174（注释）
//The reason why addrgen should not chgflw when lbuf cache state:
//When lbuf cache state, the miss/mispred branch can only be loop end
//While for loop end branch, we will not use BTB target as target PC
//We use Loop Buffer adder get its target and it will not mispred/miss
```

当 Loop Buffer 处于 active（正在从 buffer 内取指）或 cache（正在把指令写入 buffer）状态时，分支的目标由 Loop Buffer 自己的地址加法器计算，保证不出错，因此 addrgen 不应介入——即便计算出来的结果和"预测"不一致也无需冲刷，直接屏蔽。这避免了 Loop Buffer 场景下不必要的流水线冲刷。

---

## 10. 模块完整数据流总结

```
ibdp_addrgen_branch_valid
ibdp_addrgen_branch_base[38:0]   ─┐
ibdp_addrgen_branch_offset[20:0] ─┤─ 组合逻辑 ──> branch_cal_result[38:0]
                                   │                      │
ibdp_addrgen_branch_result[38:0] ─┘              branch_mispred
                                                          │
                                             addrgen_flop_clk (T+1 上升沿)
                                                          │
                                             ┌────────────▼──────────────┐
                                             │  addrgen_cal_result_flop  │
                                             │  addrgen_btb_mispred      │
                                             │  addrgen_vld              │
                                             └─────────┬─────────────────┘
                                                       │
                          ┌────────────────────────────┤
                          │                            │
                    mispred=1?                   mispred=0
                          │                            │
          ┌───────────────┼────────────┐          (不操作)
          │               │            │
    pcload→pcgen      BTB update   L0-BTB update
    (chgflw)          (target写回) (hit entry写回)
```
