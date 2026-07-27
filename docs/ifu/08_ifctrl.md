# 08 ct_ifu_ifctrl —— IF 级控制中枢详解

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_ifctrl.v`（1396 行）

---

## 1. 模块概述

`ct_ifu_ifctrl` 是 C910 IFU（指令获取单元）中 **IF 流水级的控制核心**。它不参与任何数据通路运算，专注于"这一拍 IF 级能不能动、能不能向 IP 级输出有效指令"这一问题，并向上游（pcgen）、下游（ifdp、ipctrl）、以及各协同模块（L1 ICache、L0 BTB、BHT、BTB、l1_refill）发出协调信号。

其主要职责可以归纳为五类：

| 职责 | 核心信号 |
|---|---|
| 汇聚所有 stall 源，决定 IF 级是否停顿 | `if_stage_stall`, `ifctrl_pcgen_stall` |
| 传播 cancel / pipedown，控制指令有效流水 | `ifctrl_ifdp_cancel`, `ifctrl_ifdp_pipedown`, `ifctrl_ipctrl_vld` |
| 驱动 I-Cache Invalidation 状态机 | `icache_inv_cur_state`, `icache_inv_cnt` |
| 发起/完成 BHT、BTB、Ind-BTB 的 invalidation | `ifctrl_bht_inv`, `ifctrl_btb_inv`, `ifctrl_ind_btb_inv` |
| 协调 L0 BTB 的 stall 和 inv | `ifctrl_l0_btb_stall`, `ifctrl_l0_btb_inv` |

---

## 2. Stall 信号汇聚与生成

### 2.1 if_self_stall：IF 级本身的停顿原因

```verilog
// 行 542-551
assign if_self_stall = (l1_refill_ifctrl_refill_on &&
                        !(l1_refill_ifctrl_trans_cmplt && refill_pc_hit)) ||
                       !if_pc_vld ||
                       icache_inv_on ||
                       bht_inv_on ||
                       btb_inv_on ||
                       ind_btb_inv_on ||
                       vector_ifctrl_sm_on ||
                       pcgen_ifctrl_way_pred_stall ||
                       rtu_ifu_xx_dbgon;
```

每一项的含义与原因：

| 条件 | 含义 | 为什么要 stall |
|---|---|---|
| `l1_refill_on && !(trans_cmplt && pc_hit)` | Refill 进行中，但数据还没回来或 PC 不匹配 | 数据无效，不能流水 |
| `!if_pc_vld` | MMU 翻译未完成（`!mmu_ifu_pavld`）或低功耗 `no_op` | 物理地址未知，不能做 tag 比较 |
| `icache_inv_on` | I-Cache 正在做 invalidation | inv 期间 cache 内容不可信 |
| `bht_inv_on` | BHT 正在做 invalidation | 预测结构不稳定 |
| `btb_inv_on` | BTB 正在做 invalidation | 分支目标不可信 |
| `ind_btb_inv_on` | Indirect BTB 正在做 invalidation | 间接跳转目标不可信 |
| `vector_ifctrl_sm_on` | 异常/中断向量 SM 激活 | 需要跳转到向量地址，当前取指无意义 |
| `pcgen_ifctrl_way_pred_stall` | Way 预测为 2'b00（无预测信息） | 不知道读哪路 cache，读出数据无效 |
| `rtu_ifu_xx_dbgon` | 调试模式激活 | 调试接管 PC，普通取指停止 |

### 2.2 if_stage_stall：全局停顿 = 自身 stall + 下游 stall

```verilog
// 行 552-558
assign if_stage_stall      = if_self_stall || ipctrl_ifctrl_stall;
assign ifctrl_pcgen_stall  = if_stage_stall;
assign ifctrl_bht_stall    = if_stage_stall;
assign ifctrl_ifdp_stall   = if_stage_stall;
assign ifctrl_l0_btb_stall = if_stage_stall;
// 时序优化版本：用更短路径的 stall_short
assign ifctrl_pcgen_stall_short = if_self_stall || ipctrl_ifctrl_stall_short;
```

`ipctrl_ifctrl_stall` 来自 IP 级（指令预处理级），当 IP 级发生反压时，IF 级也必须停顿，防止覆盖 IP 级还未消费的数据。

`if_stage_stall` 被扇出到所有上游和协同模块，一旦置位，整个 IF 级及以上均停止前进。

**为什么要有 `stall_short`？** pcgen 是 if 的上游，pcgen 的时序路径较长（它要产生下一个 PC）。如果用完整的 `if_stage_stall`，时序会很紧。因此专门为 pcgen 准备了一条去掉部分 late-arriving 信号的 `stall_short` 信号，以放松时序约束。

### 2.3 if_inst_data_vld 与 if_pc_vld 的区别

```verilog
// 行 506-521
assign if_inst_data_vld = (!l1_refill_ifctrl_refill_on &&
                           !(pcgen_ifctrl_way_pred[1:0] == 2'b0)) ||
                          (l1_refill_ifctrl_refill_on &&
                           l1_refill_ifctrl_trans_cmplt &&
                           refill_pc_hit);

assign if_pc_vld = mmu_ifu_pavld && !ifu_no_op_req;
```

- `if_inst_data_vld`：指令数据面是否有效（来自 cache 或 refill）
- `if_pc_vld`：PC 地址面是否有效（MMU 翻译完成）

两者相"与"才能构成有效的 IF 输出：

```verilog
// 行 568-571
assign if_vld = if_inst_data_vld && if_pc_vld && !if_cancel && !if_self_stall;
```

**设计原因**：数据和地址来自不同路径——数据来自 ICache/Refill（SRAM 访问），地址来自 MMU（TLB 查找），它们可以并行进行，但都必须有效才能产生合法的取指结果。

---

## 3. Cancel / Pipedown 信号传播

### 3.1 cancel 的来源与传播

```verilog
// 行 526-527
assign if_cancel = pcgen_ifctrl_cancel;
assign ifctrl_ifdp_cancel = if_cancel;
```

`cancel` 来自 `pcgen`，当发生跳转（分支预测、异常、中断等）时由 pcgen 发出。cancel 直接透传给 ifdp，告知"本拍 IF 级数据作废"。

**cancel 与 stall 的区别**：
- `stall`：数据暂时无效，流水停止但状态保持，等条件满足后继续
- `cancel`：数据被丢弃，流水中的指令作废，PC 要重新取

### 3.2 ifctrl_ifdp_pipedown：IF→IP 的流水有效信号

```verilog
// 行 623-624
assign ifctrl_ifdp_pipedown = !ipctrl_ifctrl_stall && if_vld;
```

只有当 IP 级没有反压（`!ipctrl_ifctrl_stall`）且 IF 级有有效数据（`if_vld`）时，才会产生 pipedown，驱动 ifdp 中的所有寄存器将 IF 级结果锁存到 IP 级寄存器中。

**为什么 pipedown 不包含 cancel 屏蔽？** 因为 `if_vld` 的定义已经包含了 `!if_cancel`（见上文）。cancel 通过否定 `if_vld` 间接阻止了 pipedown 的产生。

### 3.3 ifctrl_ipctrl_vld：向 IP 级汇报本次取指是否有效

```verilog
// 行 654-664
always @(posedge if_vld_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    ifctrl_ipctrl_vld <= 1'b0;
  else if(pcgen_ifctrl_pipe_cancel)    // pipe_cancel 优先清零
    ifctrl_ipctrl_vld <= 1'b0;
  else if(!ipctrl_ifctrl_stall)        // IP 级不 stall 时更新
    ifctrl_ipctrl_vld <= if_vld;
  else
    ifctrl_ipctrl_vld <= ifctrl_ipctrl_vld;  // stall 时保持
end
```

注意 `pcgen_ifctrl_pipe_cancel` 具有最高优先级，可以在 IP 级 stall 期间强制清零 vld。这是因为 `pipe_cancel` 代表深层跳转（如分支误预测恢复），必须无条件作废流水中的指令。

---

## 4. L0 BTB 协调

### 4.1 ifctrl_l0_btb_stall

```verilog
// 行 556
assign ifctrl_l0_btb_stall = if_stage_stall;
```

L0 BTB 的 stall 与整个 IF 级的 stall 完全同步——IF 级停，L0 BTB 也停，不做新的方向预测更新。

### 4.2 ifctrl_l0_btb_inv

```verilog
// 行 1206-1207
assign ifctrl_l0_btb_inv = cp0_ifu_btb_inv && !btb_inv_ff;
```

L0 BTB 的 inv 信号与 BTB（L1）的 inv 信号来源相同，都是 `cp0_ifu_btb_inv`，并且都使用了边沿检测（见 4.3 节）。即执行 `fence.i` 或 CP0 软件触发 BTB inv 时，L0 BTB 和 L1 BTB 同时被清空。

### 4.3 L0 BTB pcload 的产生

```verilog
// 行 713-728
assign ifctrl_pcload = l0_btb_ifctrl_chglfw_vld
                     && !ipctrl_ifctrl_stall
                     && !ifctrl_pcgen_reissue_pcload
                     && if_inst_data_vld
                     && !if_self_stall;
```

当 L0 BTB 命中（`l0_btb_ifctrl_chglfw_vld`）时，ifctrl 会产生 `ifctrl_pcgen_chgflw_vld` 通知 pcgen 修改 PC。产生条件：
1. IP 级没有反压
2. 上一拍没有 reissue（reissue 优先于分支预测）
3. 指令数据有效
4. IF 级没有自身 stall

---

## 5. I-Cache Invalidation 状态机（重点）

### 5.1 状态定义

```verilog
// 行 748-757
parameter IDLE        = 4'b0000;  // 空闲，等待 inv 请求
parameter READ_REQ    = 4'b0010;  // CP0 诊断读：发送读请求
parameter READ_RD     = 4'b0011;  // CP0 诊断读：等待 SRAM 输出
parameter READ_ST     = 4'b0100;  // CP0 诊断读：将结果上报 CP0
parameter INV_ALL     = 4'b0101;  // 全部 invalidation（CP0 发起）
parameter INS_TAG_REQ = 4'b1001;  // 按地址 inv：读取对应 Tag
parameter INS_TAG_RD  = 4'b1010;  // 按地址 inv：等待 Tag 从 SRAM 出来
parameter INS_CMP     = 4'b1011;  // 按地址 inv：比较 Tag 与请求的 PA
parameter INS_INV     = 4'b1100;  // 按地址 inv：清除命中行的 valid 位
parameter INS_INV_ALL = 4'b1101;  // LSU 发起的全部 invalidation
```

共 10 个状态，分三条业务路径：
1. **CP0 诊断读**（READ_*）：软件通过 CP0 寄存器直接读取 I-Cache 内容
2. **CP0 全量 inv**（INV_ALL）：`cp0_ifu_icache_inv`，遍历所有 cache 行清 valid
3. **LSU 发起的 inv**（INS_*）：`fence.i` 或 DCache 写后的 I-Cache 一致性维护

### 5.2 完整状态转移图

```
                     ins_all_inv_req
          ┌──────────────────────────────────────► INS_INV_ALL
          │                                              │
          │                                    icache_all_inv_done
          │                                              │
          │          ins_addr_inv_req                    ▼
          │     ┌────────────────────────────► IDLE ◄────┘
          │     │                             │  │
          │     │                   all_inv   │  │  icache_read_req
          │     │                   _req      │  │
          │     │               INV_ALL◄──────┘  └──────► READ_REQ
          │     │                  │                         │
          │     ▼              inv_over                   READ_RD
          │ INS_TAG_REQ           │                         │
          │     │                 ▼                      READ_ST
          │  INS_TAG_RD       IDLE ◄────────────────────────┘
          │     │
          │  INS_CMP
          │     │
          │  hit? ──yes──► INS_INV
          │     │               │
          │  no, cnt>0          │ cnt>0
          │     │               │
          └─────┘           INS_TAG_REQ
                                │
                            cnt==0
                                │
                              IDLE
```

### 5.3 按地址精确 inv（INS_TAG_* 路径）详解

这是最复杂的路径，用于处理 VIPT（虚拟索引、物理标记）I-Cache 的一致性问题。

**为什么需要反复遍历多个索引？**

C910 的 I-Cache 是 VIPT 结构：使用虚拟地址的低位做 index，物理地址的高位做 tag。对于 32K I-Cache，index 使用 VA[12:5]（8 位，256 组）；对于 64K I-Cache，index 使用 VA[13:5]（9 位，512 组）。

当 LSU 发出 `icache.ipa` 或 `icache.iva` 时，给出的是物理地址（PA）。同一个 PA 可能映射到不同的 VA（别名，aliasing），因此同一个 PA 的数据可能以不同 VA 的 index 存入了不同 cache 行。为了保证完全 invalidate，**必须遍历所有可能被此 PA 的数据占用的 index**。

```verilog
// 行 893-904（以 32K cache 为例）
`ifdef ICACHE_32K
parameter CNT_REG_VAL = 5'b00011;  // 初始值 3，需遍历 4 次（3,2,1,0）
`endif
`ifdef ICACHE_64K
parameter CNT_REG_VAL = 5'b00111;  // 初始值 7，需遍历 8 次
`endif
```

计数器 `addr_inv_count_reg[4:0]` 控制遍历次数：
- 32K cache：VA[12:11] 不确定（2 位），需遍历 4 次（`CNT_REG_VAL = 3`）
- 64K cache：VA[13:11] 不确定（3 位），需遍历 8 次（`CNT_REG_VAL = 7`）
- 128K cache：4 位不确定，遍历 16 次
- 256K cache：5 位不确定，遍历 32 次

遍历 index 的构造方式：

```verilog
// 行 1067
assign icache_line_inv_index[PC_WIDTH-2:0] =
    {23'b0, addr_inv_count_reg[4:0], lsu_ifu_icache_index[5:0], 5'b0};
```

其中 `lsu_ifu_icache_index[5:0]` 是 LSU 提供的 PA[10:5]（确定的 index 低位），`addr_inv_count_reg[4:0]` 对应不确定的高位，每次循环递减 1，从而覆盖所有可能的别名行。

**INS_TAG_REQ → INS_TAG_RD → INS_CMP → INS_INV 路径时序**：

| 拍 | 状态 | 动作 |
|---|---|---|
| T+0 | INS_TAG_REQ | 向 ICache 发 tag 读请求，index = 当前遍历地址 |
| T+1 | INS_TAG_RD | SRAM 读出结果，等待一拍 |
| T+2 | INS_CMP | 将 SRAM 输出的 tag 与 `ins_inv_ptag_flop`（保存的 PA）比较 |
| T+3 | INS_INV 或回 INS_TAG_REQ | 命中则写 invalid；不命中或已全部扫描则结束 |

### 5.4 Tag 比较逻辑

```verilog
// 行 1060-1061
assign ins_tag_cmp[1] = (tag_data1_reg[28:0] == {1'b1, ins_inv_ptag_flop[27:0]});
assign ins_tag_cmp[0] = (tag_data0_reg[28:0] == {1'b1, ins_inv_ptag_flop[27:0]});
```

- `tag_data0/1_reg[28:0]`：在 `INS_TAG_RD` 拍时锁存的 ICache Way0/Way1 tag 数据
- `{1'b1, ins_inv_ptag_flop[27:0]}`：要求 valid 位为 1（bit[28]），且 tag[27:0] 匹配 PA
- `ins_tag_cmp[1:0]`：bit[1] 对应 Way1 命中，bit[0] 对应 Way0 命中

### 5.5 icache_inv_cnt：全量 inv 的行计数器

```verilog
// 行 1085-1101
assign icache_inv_cnt_sub[12:0] = (vector_ifctrl_reset_on) ? 13'b1 : 13'b100;

always @(posedge icache_inv_clk or negedge cpurst_b)
begin
  if(!cpurst_b) icache_inv_cnt[12:0] <= 13'b0;
  else if(icache_inv_cnt_initial) icache_inv_cnt[12:0] <= INV_CNT_VAL;
  else if(icache_inv_cnt_on)
    icache_inv_cnt[12:0] <= icache_inv_cnt[12:0] - icache_inv_cnt_sub[12:0];
  ...
end
assign icache_inv_over = ~(|icache_inv_cnt[12:2]) &&
                         !(vector_ifctrl_reset_on && (|icache_inv_cnt[1:0]));
```

- 全量 inv 时，`icache_inv_cnt` 从 `INV_CNT_VAL`（例如 32K cache = 511）倒计数
- 正常 inv 每拍递减 4（因为每次 tag 写操作同时 inv 4 组），加速遍历
- 复位时（`vector_ifctrl_reset_on`）每拍递减 1，逐行清除
- `icache_inv_over` = 计数器到 0，触发 `icache_all_inv_done`

**为什么普通 inv 每次减 4？** ICache 的 tag SRAM 通常每次写一个 word 可以同时控制多行的 valid 位。每次写入 4 组的 valid，因此计数器步进为 4，减少 inv 所需拍数，降低停顿时间。

### 5.6 icache_inv_tag_wen[2:0] 写使能编码

```verilog
// 行 956-964
always @(...)
begin
  if(INS_INV_ALL)    icache_inv_tag_wen[2:0] = 3'b0;    // 全量：让 ICache 自己处理
  else if(INV_ALL)   icache_inv_tag_wen[2:0] = 3'b0;    // 全量：让 ICache 自己处理
  else if(INS_INV)   icache_inv_tag_wen[2:0] = {1'b0, ~tag_cmp_result[1:0]}; // 精确：只写命中路
  else               icache_inv_tag_wen[2:0] = 3'b111;  // 默认：写全部
end
```

| 状态 | wen[2:0] | 含义 |
|---|---|---|
| INV_ALL / INS_INV_ALL | 3'b000 | 全量 inv 由 ICache 接口自行驱动（计数器控制） |
| INS_INV（精确单行 inv） | `{0, ~Way1_hit, ~Way0_hit}` | 只清除命中的那路；bit[1]=0 表示写 Way1，bit[0]=0 表示写 Way0 |
| 其他 | 3'b111 | 全部不写（or: 读操作不需要 wen） |

**为什么是取反？** ICache 的 wen 是低有效——0 表示"允许写这一路"，1 表示"屏蔽这一路"。`~tag_cmp_result[1:0]` 将"命中路"转换为"需要写（清除）的路"。

---

## 6. BHT / BTB / Ind-BTB INV 协调

### 6.1 电平信号转脉冲信号

CP0 发出的 `cp0_ifu_btb_inv`、`cp0_ifu_bht_inv`、`cp0_ifu_ind_btb_inv` 都是**电平信号**（level，保持高电平直到 done），而 BTB/BHT 模块通常需要一个**脉冲（pulse）**来触发清除操作。ifctrl 在这里起到边沿检测的作用：

```verilog
// 行 1197-1205
always @(posedge btb_inv_flop_clk ...)
  btb_inv_ff <= cp0_ifu_btb_inv;  // 延迟一拍

assign ifctrl_btb_inv    = cp0_ifu_btb_inv && !btb_inv_ff;  // 上升沿 = 脉冲
assign ifctrl_l0_btb_inv = cp0_ifu_btb_inv && !btb_inv_ff;
```

同理，`ifu_cp0_btb_inv_done` 也是边沿检测：

```verilog
// 行 1218-1219
assign btb_inv_dn = btb_ifctrl_inv_done;
assign ifu_cp0_btb_inv_done = btb_inv_dn && !btb_inv_dn_ff;  // done 信号的上升沿
```

### 6.2 inv 期间的 stall 关系

```verilog
// 行 1216, 1266, 1314
assign btb_inv_on     = btb_ifctrl_inv_on;
assign bht_inv_on     = bht_ifctrl_inv_on;
assign ind_btb_inv_on = ind_btb_ifctrl_inv_on;
```

这三个 `inv_on` 信号直接来自 BTB/BHT 模块，表示该模块正在执行内部的 invalidation 操作。只要任何一个为高，就会通过 `if_self_stall` 阻止 IF 级前进，避免在清除期间读取到错误的预测信息。

### 6.3 fence.i 时的 inv 顺序

执行 `fence.i` 指令时，需要同时 invalidate I-Cache、BTB、BHT、L0 BTB，防止缓存了旧的指令编码或旧的跳转预测。顺序如下：

1. `fence.i` 由 LSU 执行完毕后，LSU 发出 `lsu_ifu_icache_all_inv`
2. ifctrl 检测到后进入 `INS_INV_ALL` 状态，开始 I-Cache 全量 inv，同时将 `ifctrl_ipb_inv_on` 置高，阻止 prefetch buffer 继续提供旧指令
3. 同一时刻，CP0 也会发出 `cp0_ifu_btb_inv` 和 `cp0_ifu_bht_inv`（通过软件配合）
4. ifctrl 检测到上升沿，发出 `ifctrl_btb_inv` 和 `ifctrl_bht_inv` 脉冲
5. 各模块完成后回报 `done`，ifctrl 检测 done 上升沿后向 CP0 回报

整个过程中 `if_self_stall` 持续为高，流水线在 IF 级冻结。

---

## 7. L1 Refill 协调

### 7.1 ifctrl 如何感知 refill 状态

```verilog
// 行 768
assign icache_refill_on = l1_refill_ifctrl_refill_on;
```

`l1_refill_ifctrl_refill_on` 表示 L1 Refill 状态机正在从总线取数据回填 I-Cache。此时：
- I-Cache 的 SRAM 可能正在被回填数据占用，不能同时做 inv 操作
- 因此 `all_inv_req` 和 `ins_addr_inv_req` 的产生都要排除 refill_on：

```verilog
// 行 879-884
assign all_inv_req    = icache_all_inv &&
                        !icache_refill_on &&     // 必须等 refill 完成
                        !vector_ifctrl_sm_start;
```

**例外：CTC（Cache-Through-Coherent）模式**

```verilog
// 行 865-871
assign ins_all_inv_req = lsu_ifu_icache_all_inv &&
                         (!icache_refill_on && !vector_ifctrl_sm_start ||
                          l1_refill_ifctrl_ctc);   // CTC 时可以同时 inv
```

`l1_refill_ifctrl_ctc` 表示当前 refill 是 Cache-Through 模式（不写 cache，只透传），此时 cache 不会被修改，可以安全地进行 inv。

### 7.2 ifctrl 向 L1 Refill 发送的信号

```verilog
// 行 1150-1164
assign ifctrl_l1_refill_inv_on   = (icache_inv_cur_state != IDLE) ||
                                   (IDLE && 有 inv 请求);
assign ifctrl_l1_refill_inv_busy = (icache_inv_cur_state != IDLE);
assign ifctrl_l1_refill_ins_inv  = lsu_ifu_icache_line_inv || lsu_ifu_icache_all_inv;
assign ifctrl_l1_refill_ins_inv_dn = ifu_lsu_icache_inv_done;
```

- `inv_on`：通知 L1 Refill 不要现在开始新的 refill（会冲突）
- `inv_busy`：更严格的信号，表示 SM 已经进入 inv 状态
- `ins_inv`：通知 L1 Refill 是 LSU 发起的 inv（需要等待 wfd，即 write-fence-done）
- `ins_inv_dn`：通知 L1 Refill LSU inv 已完成

---

## 8. 与 MMU 的配合

### 8.1 mmu_ifu_pavld

```verilog
// 行 520-521
assign if_pc_vld = mmu_ifu_pavld && !ifu_no_op_req;
```

`mmu_ifu_pavld`（Physical Address Valid）来自 MMU，表示本拍的 VA→PA 翻译成功（TLB 命中，且没有页访问异常）。当 MMU 在做 TLB 重填（TLB refill）时，`pavld` 为低，IF 级通过 `!if_pc_vld` 进入 stall。

### 8.2 何时 MMU 会拒绝给 pavld

| 情况 | 原因 | if 的反应 |
|---|---|---|
| TLB miss | MMU 正在做 page walk | `!if_pc_vld` → `if_self_stall` |
| Page fault（pgflt） | 虚拟地址无效或权限不足 | `mmu_ifu_pgflt` 由 ifdp 传到 IP 级产生异常 |
| 访问错误（acc_err） | 物理地址范围错误 | `l1_refill_ifdp_acc_err` 在 ifdp 中处理 |

注意：**MMU 的 abort 不是 ifctrl 发出的**。ifctrl 只是被动接收 `mmu_ifu_pavld` 信号来决定 IF 级是否有效。向 MMU 的 abort（取消当前翻译请求）由更上层逻辑控制，与 ifctrl 中的 cancel/stall 无直接关联。

---

## 9. No-op 低功耗机制

```verilog
// 行 457-495
assign ifu_no_op = l1_refill_ifctrl_idle &&
                   !l1_refill_ifctrl_start &&
                   ipb_ifctrl_prefetch_idle;
```

当 refill 空闲、prefetch buffer 也空闲时，IFU 进入 no_op 状态。此时 `ifu_no_op_flop` 触发，向全芯片广播 `ifu_yy_xx_no_op`，各模块可以据此关闭时钟以节省功耗。

同时 `ifu_no_op_req = cp0_ifu_no_op_req`，当 CP0 主动要求 IFU 停止取指时（如 wfi 指令），通过 `!ifu_no_op_req` 使 `if_pc_vld` 变为 0，间接停止 IF 流水。

---

## 10. CP0 诊断读（READ_* 路径）

这条路径支持软件通过 CP0 读取 I-Cache 内部 SRAM 的原始内容（用于调试或测试）：

```verilog
// 行 1374-1381
assign ifu_cp0_icache_read_data_vld    = (icache_inv_cur_state == READ_ST);
assign ifu_cp0_icache_read_data[127:0] =
    (icache_read_tag)
    ? (icache_read_way)
      ? {96'b0, tag_data1_reg[19:0], 11'b0, tag_data1_reg[20]}
      : {96'b0, tag_data0_reg[19:0], 11'b0, tag_data0_reg[20]}
    : (icache_read_way)
      ? icache_if_ifctrl_inst_data1_reg[127:0]
      : icache_if_ifctrl_inst_data0_reg[127:0];
```

流程：CP0 写入 `cp0_ifu_icache_read_req`+`read_index`+`read_tag`+`read_way`，SM 进入 `READ_REQ`→`READ_RD`（等 SRAM 出数）→`READ_ST`（将数据锁存并上报），然后回到 IDLE。

---

## 11. 关键信号一览

| 信号名 | 方向 | 描述 |
|---|---|---|
| `if_stage_stall` | 内部 | IF 级全局停顿信号 |
| `if_vld` | 内部 | IF 级本拍输出有效 |
| `ifctrl_pcgen_stall` | → pcgen | 通知 pcgen 停止更新 PC |
| `ifctrl_ifdp_cancel` | → ifdp | 通知 ifdp 当前数据作废 |
| `ifctrl_ifdp_pipedown` | → ifdp | 触发 ifdp 寄存器更新（IF→IP 流水） |
| `ifctrl_ipctrl_vld` | → ipctrl | 告知 IP 级本次取指是否有效 |
| `ifctrl_l0_btb_stall` | → L0 BTB | L0 BTB 停止 |
| `ifctrl_l0_btb_inv` | → L0 BTB | 清除 L0 BTB |
| `ifctrl_btb_inv` | → BTB | 清除 L1 BTB（脉冲） |
| `ifctrl_bht_inv` | → BHT | 清除 BHT（脉冲） |
| `ifctrl_ind_btb_inv` | → Ind-BTB | 清除 Indirect BTB（脉冲） |
| `icache_inv_cur_state` | 内部 | I-Cache Inv SM 当前状态 |
| `icache_inv_cnt` | 内部 | 全量 inv 行计数器（13 位） |
| `addr_inv_count_reg` | 内部 | 精确 inv VIPT 别名遍历计数器（5 位） |
| `ifctrl_icache_if_tag_wen[2:0]` | → ICache | Tag SRAM 写使能 |
| `ifu_cp0_icache_inv_done` | → CP0 | I-Cache inv 完成脉冲 |
| `ifu_lsu_icache_inv_done` | → LSU | fence.i inv 完成脉冲 |
