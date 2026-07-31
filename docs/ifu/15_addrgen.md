# ct_ifu_addrgen 模块详解

## 1. 模块概述

### 1.1 addrgen 在 IFU 流水线中的位置

C910 的取指流水线大致分为以下几个阶段：

```
IF  -->  IP  -->  IB  -->  addrgen 结果拍
```

- **IF 级（Instruction Fetch）**：以当前取指 PC 发起 I-Cache 和 BTB 相关读取。
- **IP 级（Instruction Pre-decode）**：对取回的指令做初步解码，并组合 IF 级返回的
  BTB/L0-BTB、BHT 和 I-Cache way 信息，选择本次预测改流及其目标。这里不是到
  IP 级才开始读取 BTB。
- **IB 级（Instruction Buffer / Decode）**：指令从 ibdp（IB Data Path）中被分析，提取出分支类型、偏移量、基地址等真实信息。
- **addrgen**：接收由 IPDP 形成、经 IBDP 条件过滤后的直接控制流信息，在组合
  加法和比较后再打一拍。它重新计算被选中直接分支/JAL 的 PC 相对目标，与前端
  当时采用的目标比较；不一致时向 pcgen 发出较晚的 pcload，并向 BTB 或
  L0-BTB 提供修正控制。

### 1.2 事后验证，而非实时预测

IP 级形成的改流目标是**推测性**的：它使用 IF 级返回的预测器信息和 IP 级
预译码结果，把所选目标送给 pcgen，流水线继续向前走。这个目标可能来自 BTB
命中，也可能包含 L0-BTB 失配时的回退选择；BTB target 陈旧、tag/valid 不匹配
或 BTB 被关闭，都可能使较晚的 addrgen 校验发现目标不一致。

addrgen 的职责是**前端较晚一级的目标核验**：IPDP 已经从指令位中选出直接分支
的 PC 和立即数，addrgen 将二者相加，再与 IP 级记录的改流目标比较。若不相等，
它通过 pcload 把重新计算的目标送回 pcgen，并取消相关前端在途状态。这里的
“重新计算目标”对 PC 相对直接控制流是确定性的，但它仍是前端预测恢复机制，
不能替代 IU/BJU 对指令语义、条件结果和架构异常的最终解析。

这种“预测先行、较晚校验”允许目标命中时继续流水；目标不一致时才付出前端重定向
和错误路径清除代价。实际惩罚周期还取决于当时的流水线位置、取指命中情况以及
更高优先级改流，不能仅由本模块的一级寄存器确定。

### 1.3 驱动 BTB / L0-BTB 更新

addrgen 检测到目标不一致时把 index、tag 和重新计算的 target 送给 BTB。BTB
先将这些字段放入 refill buffer，随后还要结合 I-cache way-pred 信息和自身更新
条件完成写入，因此不是 addrgen 当拍直接写 SRAM，也不能保证下一次必然命中。

L0-BTB 路径的动作不同：当 IBDP 指示本次涉及 L0-BTB miss/分配项且 addrgen 又
发现目标不一致时，addrgen 对选中项写 `valid=0`，即撤销该项，而不是把 target
写回。第 6 节给出位级证据。

---

## 2. 端口说明

### 2.1 来自 ibdp 的输入

| 信号名 | 宽度 | 含义 |
|--------|------|------|
| `ibdp_addrgen_branch_valid` | 1 | IBDP 接受的直接目标校验候选；精确定义见 3.1 节，不等于任意分支有效 |
| `ibdp_addrgen_branch_base[38:0]` | 39 | IPDP 选中直接控制流指令的 PC，采用半字地址形式 `[39:1]` |
| `ibdp_addrgen_branch_offset[20:0]` | 21 | IPDP 已重排并符号扩展的 PC 相对字节位移，bit0 为对齐零位 |
| `ibdp_addrgen_branch_result[38:0]` | 39 | IPCTRL 选出的 IP 级改流目标，由 IPDP 寄存后经 IBDP 透传；对本模块接受的候选可视为待校验的预测目标 |
| `ibdp_addrgen_btb_index_pc[38:0]` | 39 | IPDP 为 BTB 查找/更新保留的身份 PC；普通 Hn 情形等于相应半字位置，跨窗口 H0 情形有专门编码，不能无条件称为架构分支 PC |
| `ibdp_addrgen_l0_btb_hit` | 1 | 名称含 `hit`，但当前 IBDP 实际驱动为“`l0_btb_ras_miss` 或 `l0_btb_br_miss`”，表示需由 addrgen 后续处理的 L0-BTB miss/分配情形 |
| `ibdp_addrgen_l0_btb_hit_entry[15:0]` | 16 | 一热 entry 选择；IBDP 可在命中项与 FIFO 分配项之间选择，并非始终是“命中编号” |
| `ibdp_addrgen_branch_vl[7:0]` | 8 | 候选随流水携带的向量长度状态，addrgen 改流时送回 IPDP |
| `ibdp_addrgen_branch_vlmul[1:0]` | 2 | 候选随流水携带的 LMUL 状态 |
| `ibdp_addrgen_branch_vsew[2:0]` | 3 | 候选随流水携带的 SEW 状态 |

这些向量状态端口表明 RTL 源码保留了前端向量状态恢复接口，不等于当前开源配置
一定启用了 RVV。当前配置中 `ct_cp0_regs.v` 将 `misa_vector` 置为 0，普通 IDU
译码路径也把 `x_vec_inst` 置为 0；观察这些端口时应把“源码保留能力”和“当前
配置可达功能”分开。

### 2.2 来自 lbuf（Loop Buffer）的输入

| 信号名 | 含义 |
|--------|------|
| `lbuf_addrgen_active_state` | LBUF 状态位 `lbuf_cur_state[3]`，仅表示 `ACTIVE` |
| `lbuf_addrgen_cache_state` | LBUF 状态位 `lbuf_cur_state[2]`，仅表示 `CACHE`，不包含 `FRONT_CACHE` |
| `lbuf_addrgen_chgflw_mask` | LBUF 正在接管特定循环末尾改流时的组合屏蔽；精确条件见 9.1 节 |

### 2.3 其他输入

| 信号名 | 含义 |
|--------|------|
| `pcgen_addrgen_cancel` | 清除 `addrgen_vld`；既包含 HAD/Vector/RTU/IU 的高优先级改流，也包含 addrgen 自己的 `pcload`，后者用于消费当前结果并形成单拍请求 |

### 2.4 送往 pcgen 的输出

| 信号名 | 含义 |
|--------|------|
| `addrgen_pcgen_pcload` | 目标不一致时的 PC 更新请求；在 pcgen 主 PC 多路器中位于 HAD、Vector、RTU、IU 改流之后 |
| `addrgen_pcgen_pc[38:0]` | addrgen 按直接分支 PC+位移重新计算的目标地址 |
| `addrgen_xx_pcload` | 与 `addrgen_pcgen_pcload` 同表达式的并行输出，当前顶层连接到 IPDP 的取消/改流处理 |

### 2.5 送往 BTB 的输出

| 信号名 | 含义 |
|--------|------|
| `addrgen_btb_update_vld` | 本周期向 BTB refill buffer 提交目标修正信息 |
| `addrgen_btb_index[9:0]` | 待修正控制流 PC 形成的 BTB index |
| `addrgen_btb_tag[9:0]` | 待修正控制流 PC 形成的 BTB tag |
| `addrgen_btb_target_pc[19:0]` | 重算半字目标 PC 的低 20 位，即架构字节 PC `[20:1]`，交给 BTB refill buffer |

### 2.6 送往 L0-BTB 的输出

| 信号名 | 含义 |
|--------|------|
| `addrgen_l0_btb_update_vld` | L0-BTB 条件失效请求有效 |
| `addrgen_l0_btb_wen[3:0]` | L0-BTB 字段写使能；当前仅 bit3=1，即只写 valid 字段 |
| `addrgen_l0_btb_update_entry[15:0]` | 来自 IBDP 的一热 entry 选择，可能是原命中项或 FIFO 分配项 |
| `addrgen_l0_btb_update_vld_bit` | 恒为 0；与 `wen[3]` 组合后把选中 entry 的 valid 清零 |

### 2.7 送往 ibctrl 与 ipdp 的输出

| 信号名 | 含义 |
|--------|------|
| `addrgen_ibctrl_cancel` | addrgen 目标不一致时取消相应 IB 前端状态，与 `addrgen_pcgen_pcload` 同表达式 |
| `addrgen_ipdp_chgflw_vl/vlmul/vsew` | addrgen 改流时送回 IPDP 的随流水向量状态；当前配置可达性见 2.1 节说明 |

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

三个层次的条件共同决定本模块是否锁存候选：

1. IBDP 的 `branch_valid` 本身只覆盖
   `((|hn_con_br) && bht_result) || (|hn_ab_br)`，并且要求 IB 数据有效、无 IP
   异常、无 IB self-stall。也就是说，它处理**预测 taken 的条件分支**以及
   JAL/C.J 直接无条件跳转，不把未 taken 条件分支或 JALR/C.JR 间接目标送入
   本加法校验路径。
2. Loop Buffer 不处于 active 或 cache 状态。
3. `lbuf_addrgen_chgflw_mask` 未屏蔽本次校验。

`branch_vld_for_gateclk` 比 `branch_vld` 少最后一个 mask 条件。其目的不是在
mask 时锁存新结果，而是让本地时钟使能覆盖输入候选出现的时段；真正写入
`addrgen_vld` 和各数据寄存器仍受 `branch_vld` 约束。还应结合
`gated_clk_cell` 的 `module_en` 覆盖和编译宏判断实际时钟是否被门控。

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

普通译码器也会为 JALR 形成立即数字段，供其他 IFU 元数据路径使用；但
addrgen 的 `branch_valid` 不选择 JALR。本段移位只能解释当前直接 PC 相对候选
如何统一成半字单位，不能推导 JALR 的 `rs1+imm` 在此计算。

### 3.3 base 地址选择

```verilog
// 行 177
assign branch_base[PC_WIDTH-2:0] = ibdp_addrgen_branch_base[PC_WIDTH-2:0];
```

`ibdp` 在这里基本是透传：该值由 `ipdp` 的 `base_pc_branch` 形成。IPDP 在
`branch[7:0]` 中选出当前窗口最早需要核验的直接控制流位置，并用窗口 VPC 加
半字位置构造该指令 PC；跨窗口的 `h0` 则使用其保存的当前 PC。由于
`ibdp_addrgen_branch_valid` 不包含 JALR/C.JR，本接口在当前 RTL 中不是
“JALR 的 rs1 基址”。间接跳转目标由其他预测、PCFIFO 和后端执行路径处理。

### 3.4 最终加法

```verilog
// 行 183
assign branch_cal_result[PC_WIDTH-2:0] =
    branch_base[PC_WIDTH-2:0] + branch_offset[PC_WIDTH-2:0];
```

这是 39 位半字地址加法。`branch_cal_result` 是本模块按已解码 PC 相对位移得到
的目标；恢复成架构字节地址时最低位补 0。称其为“addrgen 重算目标”比笼统的
“所有分支真实目标”更准确，因为本路径不覆盖间接跳转，也不解析条件是否成立。

---

## 4. Misprediction 检测

```verilog
// 行 182
assign branch_pred_result[PC_WIDTH-2:0] = ibdp_addrgen_branch_result[PC_WIDTH-2:0];

// 行 184
assign branch_mispred = (branch_pred_result[PC_WIDTH-2:0] != branch_cal_result[PC_WIDTH-2:0]);
```

`ibdp_addrgen_branch_result` 是 IPCTRL 形成的 IP 级改流目标，经 IPDP 寄存、再由
IBDP 透传。对本模块实际接受的预测 taken 条件分支和直接无条件跳转，它就是
addrgen 要校验的目标；但从全局前端看，`ipctrl_ipdp_chgflw_pc` 的选择还包含
L0-BTB 失配回退等来源，不能把这个接口机械等同于“某个 BTB SRAM 项的数据”。

比较是 39 位全字宽比较，任何一位不同都算 mispred。

**注意**：`branch_mispred` 这个名字在本模块只表示两个目标地址不相等。BTB
miss、way-pred 错误或陈旧 target 都可能最终形成不相等，但不能仅凭本模块 RTL
断言 miss 时 `branch_pred_result` 必定等于某个 PC+2/PC+4；该值实际来自
`ipctrl_ipdp_chgflw_pc`，由 IPCTRL 的目标选择逻辑形成。

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

addrgen 这一路只在其有效候选发生**目标不一致**时提出 BTB 更新请求。对同一个
addrgen 候选而言，地址相等便不从本端口发请求；这不表示整个 BTB 没有其他更新
来源，way-pred error、IBDP BTB miss 和 invalidation 仍由 `ct_ifu_btb` 自己处理。

### 5.2 BTB 写入字段

```verilog
// 行 276-278
assign addrgen_btb_index[9:0]      = addrgen_branch_index[9:0];
assign addrgen_btb_tag[9:0]        = addrgen_branch_tag[9:0];
assign addrgen_btb_target_pc[19:0] = addrgen_cal_result_flop[19:0];
```

三个字段分别是 BTB 的行地址（index）、匹配标签（tag）和半字目标地址低位。
`target_pc[19:0]` 对应架构字节地址 `[20:1]`，架构最低位 `PC[0]` 没有存入。

### 5.3 index 和 tag 的编码规则

```verilog
// 行 185-187
assign branch_index[9:0] = ibdp_addrgen_btb_index_pc[12:3];
assign branch_tag[9:0]   = {ibdp_addrgen_btb_index_pc[19:13],
                             ibdp_addrgen_btb_index_pc[2:0]};
```

这里的 PC 位号属于内部半字地址。普通 Hn 情形下，它与被选控制流所在的半字
位置一致；但 IPDP 对跨窗口 H0 有特殊处理：

```verilog
// branch[7] 且 h0_vld 时
base_pc_branch = {h0_cur_pc[35:0], 3'b111};
btb_index_pc   = {ip_vpc[38:3], 3'b000};
```

此时 `base_pc_branch` 指向上一取指窗口末尾的 H0，用来做精确的 PC+offset；
`btb_index_pc` 则保持当前窗口基址，用来匹配该跨窗口预测在 BTB 组织中的身份。
因此以下 index/tag 位映射描述的是 **BTB 身份 PC**，不是所有情况下都可直接
当作架构分支 PC：

- index `rtl_pc[12:3]` 对应架构字节 PC `[13:4]`，以 16 字节取指块为粒度，10 位模式跨度为 16 KiB；
- tag 高 7 位 `rtl_pc[19:13]` 对应字节 PC `[20:14]`；
- tag 低 3 位 `rtl_pc[2:0]` 对应字节 PC `[3:1]`，表示块内半字位置。

index 与 tag 合起来覆盖这个 BTB 身份 PC 对应的字节地址 `[20:1]`。RVC 下只有
架构 `PC[0]` 恒为 0，`PC[1]` 可以为 0 或 1。

这些字段与 BTB 的读取组织相匹配，使 refill buffer 能描述原控制流 PC。最终
写入还经过 BTB 内部请求优先级、refill buffer 和写掩码，不能把这里的组合编码
直接等同于“本拍 SRAM 写地址”。

### 5.4 为什么 addrgen 不能独立完成 BTB 写入

addrgen 当下能确定直接目标、原分支 PC 对应的 index/tag，却没有同时获得最终
I-cache way-pred 字段。`ct_ifu_btb` 因而先保存 addrgen 的 index/tag/target，
随后通过 `after_addrgen_btb_chgflw_first/second` 等状态取得
`ipctrl_btb_way_pred`，再在 BTB miss 或 way-pred error 等条件下发起实际
array 更新。这里不是一个普通的“两路组相联 + LRU/PLRU”写回；当前 RTL 的
tag/data SRAM 行、四个逻辑输出 way 和 way-pred 字段有专门编码，具体组织见
`03_btb.md`。

---

## 6. L0-BTB 条件失效

### 6.1 更新条件

```verilog
// 行 293-295
assign l0_btb_update_vld = addrgen_vld
                        && addrgen_btb_mispred
                        && addrgen_l0_btb_hit;
```

L0-BTB 的更新比 BTB 多一个条件：**`addrgen_l0_btb_hit` 必须为 1**。

变量名容易造成误读。其上游赋值为：

```verilog
assign ibdp_addrgen_l0_btb_hit = l0_btb_ras_miss || l0_btb_br_miss;
```

因此这个附加条件不是简单的“L0-BTB 命中过”，而是 IBDP 判定本次属于
L0-BTB RAS/branch miss 并保留了待处理 entry。只有该情形又出现 addrgen 目标
不一致，才需要撤销先前分配或关联的 L0-BTB 项。

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

- `ct_ifu_l0_btb_entry.v` 明确规定 `entry_wen[3]` 写 `entry_vld`，
  `entry_wen[2]` 写计数位，`entry_wen[1]` 写 RAS 位，`entry_wen[0]` 才写
  tag/way-pred/target 数据。
- addrgen 输出 `wen=4'b1000` 且 `update_vld_bit=0`，所以实际动作是把一热
  `update_entry` 选中的 entry 置为无效；target 数据没有在此路径写入。
- 这是一种“先撤销不可靠 L0 项，再由后续正常学习重建”的恢复方式。它避免保留
  错误项，但下一次是否以及何时重新建立 entry 仍取决于后续控制流和更新仲裁。

---

## 7. 流水线时序与寄存器打拍

### 7.1 时序示意图

```
相对周期       C-1                    C                         C+1
-----------------------------------------------------------------------
上游       IP 形成预测目标      IBDP 给出有效候选
addrgen                         加法、比较为组合量        寄存结果有效
输出                                                       pcload/update
```

以 IBDP 候选在周期 C 被本模块接受为基准，`branch_vld`、`branch_cal_result` 和
`branch_mispred` 都是该周期的组合量；它们在周期末边沿被锁存，周期 C+1 再由
`addrgen_vld && addrgen_btb_mispred` 驱动 pcload/update。图中只表达模块接口的
相对寄存器关系，不承诺从 I-Cache 请求开始计算的固定总周期数。

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

有效位和负载数据都在同一个门控时钟边沿更新，但它们的控制条件不同：

| 寄存器 | 含义 |
|--------|------|
| `addrgen_vld` | 本周期 addrgen 有有效结果 |
| `addrgen_cal_result_flop` | 对当前直接控制流候选重新计算的 PC 相对目标 |
| `addrgen_branch_index/tag` | BTB 更新用的 index/tag |
| `addrgen_btb_mispred` | mispred 标志 |
| `addrgen_l0_btb_hit` | 名称保留为 `hit`，实际锁存 IBDP 的 L0-BTB miss/分配后处理标志 |
| `addrgen_l0_btb_hit_entry` | 与上述事件关联的一热 entry 选择，可能来自命中向量或 FIFO 分配向量 |
| `addrgen_branch_vl/vlmul/vsew` | 向量状态 |

`addrgen_vld` 在 reset 或 `pcgen_addrgen_cancel` 时清零；负载寄存器只在 reset
时清零、只在 `branch_vld=1` 时改写，cancel 并不会清空它们。因此波形中
`addrgen_vld=0` 时看到旧 target/index/tag 是正常的，不能把这些残留位解释成
有效更新。若 cancel 与新 `branch_vld` 同拍，valid 仍按 cancel 优先清零，而
独立的负载寄存器可能锁存新组合值；下游必须始终以 valid 为准。

**为什么要打拍后再用？**

从本模块边界可见的组合路径主要是：上游已形成的 base/offset 进入 39 位加法，
再与记录目标进行 39 位比较，并生成待锁存字段。这里没有 rs1 寄存器读端口。
寄存器把该组合路径与后续 pcgen/BTB/L0-BTB 控制隔开；是否属于芯片关键路径、
余量多少，仍需综合网表和 STA 证明，不能仅凭 RTL 结构断言“无法满足时序”。

`pcgen_addrgen_cancel` 的精确定义是：

```verilog
pcgen_addrgen_cancel =
    had_ifu_pcload       || vector_pcgen_pcload ||
    rtu_ifu_chgflw_vld  || iu_ifu_chgflw_vld   ||
    addrgen_pcgen_pcload;
```

前四项保证更高优先级改流覆盖 addrgen 在途结果；最后一项让 addrgen 自己的
纠错请求在发出后于下一边沿清掉 `addrgen_vld`，从而形成单拍脉冲。这里的
“cancel”同时承担“外部作废”和“自身消费完成”两种语义。

### 7.3 门控时钟

```verilog
// 行 263-265
assign addrgen_flop_clk_en = branch_vld_for_gateclk ||
                             addrgen_vld ||
                             pcgen_addrgen_cancel;
```

三种情况需要开启时钟：
1. IBDP 侧出现新的候选（为可能的写入提供时钟）
2. `addrgen_vld` 当前有效（若没有新候选，需要在下一边沿把 valid 拉低）
3. pcgen 发来 cancel，包括高优先级覆盖和 addrgen 自身 pcload 后的 valid 清除

开源 `gated_clk_cell` 的使能表达式是
`global_en && (module_en || local_en) || external_en`；因此本地
`addrgen_flop_clk_en=0` 时，`cp0_ifu_icg_en=1` 仍可开钟。若没有定义
`C910_USE_TSMC28_ICG`，该 wrapper 更直接把 `clk_out` 接到 `clk_in`。上述三项
是本地更新意图，不等价于任何构建配置下都能观察到物理门控。

---

## 8. 性能计数器接口

```verilog
// 行 282-283
assign ifu_hpcp_btb_mispred = addrgen_vld && addrgen_btb_mispred;
assign ifu_hpcp_btb_inst    = addrgen_vld;
```

- `ifu_hpcp_btb_inst`：`addrgen_vld` 有效时脉冲，即统计进入本模块的直接目标
  校验候选，不是全部条件分支、全部跳转或退休分支数。
- `ifu_hpcp_btb_mispred`：该候选的记录目标与重算目标不等时脉冲，统计的是本
  路径的目标不一致事件，不等同于 BHT 方向误预测。

软件可用二者之比观察这类候选的目标不一致率，但分母受 BHT taken 选择、
Loop Buffer 状态、异常和 stall 过滤。若要得到体系结构意义上的总分支误预测率，
还需结合 RTU/IU 的退休分支、方向误预测和间接跳转事件。

---

## 9. Loop Buffer 的特殊处理

```verilog
// 行 169-174（注释）
//The reason why addrgen should not chgflw when lbuf cache state:
//When lbuf cache state, the miss/mispred branch can only be loop end
//While for loop end branch, we will not use BTB target as target PC
//We use Loop Buffer adder get its target and it will not mispred/miss
```

当 Loop Buffer 处于精确的 `ACTIVE` 或 `CACHE` 状态时，RTL 直接从
`branch_vld_for_gateclk` 排除 addrgen 候选；另有
`lbuf_addrgen_chgflw_mask` 做更细的屏蔽。源码注释给出的设计意图是循环末尾目标
由 Loop Buffer 加法路径处理，而不是采用普通 BTB target。准确结论是“该场景不
由 addrgen 校验”，不能由此单独证明 Loop Buffer 目标在所有条件下绝不会出错；
其正确性还取决于 LBUF 自身状态机、取消和恢复逻辑。

### 9.1 `lbuf_addrgen_chgflw_mask` 到底屏蔽什么

这个信号并不是“LBUF 启用就屏蔽 addrgen”。在 `cp0_ifu_lbuf_en=1` 且没有
`lbuf_flush` 时，只有下面三类循环末尾接管事件会置位：

1. LBUF 为 `IDLE`，当前回跳命中已填充 record，且没有 I-Cache 指令失效进行中；
2. LBUF 为 `FILL`，当前再次到达记录的循环末尾，而且本轮填充满足规则；
3. LBUF 为 `FRONT_FILL`，当前再次到达循环末尾，而且前段补填满足规则。

这三类条件分别对应准备直接使用已有循环、正常填充完成和跨前端边界补填完成。
屏蔽的目的，是避免普通 addrgen 与 LBUF 在同一个循环末尾同时提出前端改流。
它是一次特定状态转换的所有权仲裁信号，不是笼统的 LBUF 工作状态指示器。

---

## 10. 模块完整数据流总结

```
ibdp_addrgen_branch_valid
ibdp_addrgen_branch_base[38:0]   ─┐
ibdp_addrgen_branch_offset[20:0] ─┤─ 组合逻辑 ──> branch_cal_result[38:0]
                                   │                      │
ibdp_addrgen_branch_result[38:0] ─┘              branch_mispred
                                                          │
                                             addrgen_flop_clk（周期 C 末边沿）
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
    pcload→pcgen      BTB update request   条件满足时 L0-BTB 失效
    (chgflw)          (进入 refill buffer) (选中 entry 的 valid 清零)
```

### 10.1 在波形里按因果链观察

建议按下面的顺序，而不是只盯着最终 `pcload`：

1. **确认候选来源**：查看 `ibdp_addrgen_branch_valid`、`ibdp_addrgen_branch_base`、
   `ibdp_addrgen_branch_offset` 和 `ibdp_addrgen_branch_result`。结合 IBDP 的
   `ibdp_hn_con_br`、`ibdp_hn_ab_br`、`ibdp_bht_result`，确认它是预测 taken
   条件分支或 JAL/C.J。
2. **确认 LBUF 是否接管**：同时查看 `lbuf_addrgen_active_state`、
   `lbuf_addrgen_cache_state` 和 `lbuf_addrgen_chgflw_mask`。上游有候选不代表
   addrgen 一定接受。
3. **确认组合计算**：把内部半字 PC 还原为字节地址：
   `byte_base = branch_base << 1`，`byte_target = branch_cal_result << 1`。
   比较 `branch_cal_result` 与 `branch_pred_result`，解释
   `branch_mispred` 的来源。
4. **跨边沿追踪**：在接受边沿后查看 `addrgen_vld`、
   `addrgen_cal_result_flop` 和 `addrgen_btb_mispred`。有效且不相等时，
   `addrgen_pcgen_pcload`、`addrgen_ibctrl_cancel` 和
   `addrgen_btb_update_vld` 同拍出现。
5. **区分请求与真正更新**：BTB 侧还要查看
   `pcgen_btb_chgflw_higher_than_addrgen`、`refill_buf_index/tag/target_pc`、
   `after_addrgen_btb_chgflw_first/second` 和 `refill_buf_valid`；L0-BTB 侧则
   查看一热 `addrgen_l0_btb_update_entry` 及最终 entry 的 valid 位。只有这样
   才能证明请求被下游接受并产生了存储状态变化。

以下恒等关系适合作为波形检查点：

```text
addrgen_pcgen_pcload
  = addrgen_xx_pcload
  = addrgen_ibctrl_cancel
  = addrgen_btb_update_vld
  = ifu_hpcp_btb_mispred
  = addrgen_vld && addrgen_btb_mispred

addrgen_l0_btb_update_vld
  = addrgen_pcgen_pcload && addrgen_l0_btb_hit
```

第一组信号相等，表示同一个目标不一致事件被广播到不同消费者；它们不是五次
独立的错误。第二个关系说明 L0-BTB 失效是更窄的子集。反过来，
`addrgen_pcgen_pcload=1` 并不保证 L0-BTB 一定被写，也不保证 BTB SRAM 已在
同拍更新。
