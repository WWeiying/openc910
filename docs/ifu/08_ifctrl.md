# 08 ct_ifu_ifctrl —— IF 级控制中枢详解

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_ifctrl.v`（1396 行）

---

## 1. 模块概述

`ct_ifu_ifctrl` 是 C910 IFU（指令获取单元）中 **IF 流水级的控制核心**。它以控制逻辑为主，回答“这一拍 IF 级能不能动、能不能向 IP 级输出有效指令”，并向上游（pcgen）、下游（ifdp、ipctrl）及协同模块（I-Cache、L0 BTB、BHT、常规 BTB、l1_refill）发出协调信号。模块内部仍包含 invalidation 地址/计数器、诊断读数据选择等小规模数据处理，因此不宜绝对表述为“不参与任何数据通路运算”。

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
| `!if_pc_vld` | `mmu_ifu_pavld=0`，或 CP0 发出 `no_op` 请求 | 本拍地址/异常翻译结果尚不可提交给 IF 级 |
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

`if_stage_stall` 被送往 PCGEN、BHT、IFDP 和 L0 BTB，使与当前 IF 流水项相关的状态保持一致。它不是全核或整个 IFU 所有状态机的“总冻结”；例如 refill、invalidation 等独立协议仍可继续运行并最终解除 stall。

**为什么要有 `stall_short`？** RTL 注释明确将其标为 timing consideration。`stall_short` 用 `ipctrl_ifctrl_stall_short` 代替完整的 `ipctrl_ifctrl_stall`，同时保留全部 `if_self_stall` 条件，为 PCGEN 提供一条更早形成的下游反压路径。它究竟减少了多少延迟，需要查看综合/STA；不能仅凭名字断言去掉了哪些具体 late-arriving 逻辑。

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

- `if_inst_data_vld`：指令数据面是否有效（来自 I-Cache 或 refill）
- `if_pc_vld`：MMU 是否给出了可继续流入 IF 级的 PA/异常结果，且 CP0 未请求 no-op

两者相"与"才能构成有效的 IF 输出：

```verilog
// 行 568-571
assign if_vld = if_inst_data_vld && if_pc_vld && !if_cancel && !if_self_stall;
```

**设计原因**：数据和地址来自不同路径——数据来自 I-Cache/refill（SRAM 或返回通路），地址和翻译异常来自 MMU。两条路径可以并行，但必须在同一个 IF 流水项上对齐后才能向 IP 级推进。

这里必须注意：`mmu_ifu_pavld` 不等于“TLB 命中且绝无异常”。`ct_mmu_iutlb` 明确在 I-uTLB 命中、MMU 关闭/M 模式直通，以及访问故障、refill 页故障、VA 非法等异常结果形成时都可令 `pavld=1`。异常再由 IFDP 的 `mmu_ifu_pgflt` 等信号随流水传递。因此 `pavld` 更准确的含义是“本次翻译已有可消费结果”，而不只是“成功得到正常 PA”。

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

### 3.4 Reissue：资源恢复后重发当前取指

IF 级因 refill、I-Cache invalidation、诊断读或高优先级 change-flow 中断后，原 PC 对应的 SRAM/MMU 访问不一定仍然有效。IFCTRL 将这些“需要重新访问”的原因汇总并打一拍：

```verilog
assign icache_reissue = l1_refill_ifctrl_reissue ||
                        (icache_inv_done || icache_read_done) &&
                        (!l1_refill_ifctrl_ctc || l1_refill_inv_wfd_back) ||
                        pcgen_ifctrl_reissue;

always @(posedge ifctrl_reissue_clk or negedge cpurst_b)
  if(!cpurst_b)
    ifctrl_pcgen_reissue_pcload <= 1'b0;
  else
    ifctrl_pcgen_reissue_pcload <= icache_reissue;
```

四类来源分别是：

| 来源 | 为什么需要重发 |
|---|---|
| `l1_refill_ifctrl_reissue` | refill 的目标窗口刚返回或返回出错，原先被冻结的 PC 需要重新建立正常取指访问 |
| `icache_inv_done` | invalidation 期间前端读取被禁止，完成后需重新访问当前 PC |
| `icache_read_done` | CP0 诊断读占用了 I-Cache 端口，完成后恢复正常取指 |
| `pcgen_ifctrl_reissue` | PCGEN 自己检测到需要重发的高优先级情况 |

`ifctrl_pcgen_reissue_pcload` 会参与 PCGEN 的 PC 选择，并在 L0 BTB 快速重定向条件中具有更高优先级：`ifctrl_pcload` 明确要求它为 0。这样可避免“恢复当前窗口”和“根据当前窗口的旧预测再次跳转”在同一拍竞争。

### 3.5 Valid、pipedown 与 BHT 推进不是同一个信号

`ifctrl_ifdp_pipedown` 要求 IF 数据有效且 IP 级不 stall，用于真正更新 IF→IP 数据寄存器；`ifctrl_ipctrl_vld` 是带保持和 pipe-cancel 清除语义的流水有效位。另一个容易混淆的输出是：

```verilog
assign ifctrl_bht_pipedown = !ipctrl_ifctrl_bht_stall;
```

BHT 有独立的预测流水和更新条件，所以它使用 IPCTRL 专门返回的 `bht_stall`，并不直接复制 `ifctrl_ifdp_pipedown`。观察波形时，不能用某一个 `pipedown` 替代所有 IFU 子流水级的推进条件。

### 3.6 `ifu_hpcp_frontend_stall` 的统计边界

IFCTRL 生成的前端停顿条件是：

```verilog
if_frontend_stall = !if_inst_data_vld
                  || !if_pc_vld
                  || if_self_stall
                  || ipctrl_ifctrl_stall;
```

当 `hpcp_ifu_cnt_en=1` 时，该条件被寄存为 `ifu_hpcp_frontend_stall` 供性能监控使用。它覆盖 refill/无数据、MMU 结果未就绪、I-Cache/预测结构 invalidation、vector/debug、way-predict stall 以及 IP 级反压等多类原因，是一个**前端未能正常前推的总括事件**。该计数高只能说明前端供给受阻，不能单独归因成 I-Cache miss、分支误预测或纯前端带宽不足；细分归因必须同时观察组成项。

---

## 4. L0 BTB 协调

### 4.1 ifctrl_l0_btb_stall

```verilog
// 行 556
assign ifctrl_l0_btb_stall = if_stage_stall;
```

L0 BTB 的 stall 与 `if_stage_stall` 完全同步。IF 级不能前进时，L0 BTB 不应把当前查找/命中当成新的前端流水项继续推进。L0 BTB 主要保存目标和快速重定向资格，而非 BHT 那样的方向预测表，因此这里不应称为“停止方向预测更新”。

### 4.2 ifctrl_l0_btb_inv

```verilog
// 行 1206-1207
assign ifctrl_l0_btb_inv = cp0_ifu_btb_inv && !btb_inv_ff;
```

L0 BTB 的 inv 信号与常规 BTB 的 inv 信号来源相同，都是 `cp0_ifu_btb_inv` 的上升沿脉冲。因此，软件通过 CP0 `MCOR` 的 BTB invalidation 位发起操作时，IFCTRL 同时触发 L0 BTB 和常规 BTB 清除。

当前 RTL 没有在 IFCTRL 内把 `fence.i` 或 LSU 的 I-Cache invalidation 请求自动转换为 `cp0_ifu_btb_inv`，所以不能笼统写成“执行 `fence.i` 就同时清空 L0 BTB/BTB”。若软件需要同步清预测结构，必须由软件或更上层控制显式发起相应 CP0 操作。

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
3. **LSU/CTCQ 发起的 inv**（INS_*）：处理送到 IFU 的 I-Cache 全量或逐行 invalidation 请求

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

C910 的 I-Cache 是 VIPT 结构：使用虚拟地址中的组索引位访问 SRAM，再用物理 tag 判断命中。C910 IFU 内部 PC 省略了恒为 0 的架构字节地址 bit0，所以阅读 RTL 位号时必须换算：

| 配置 | RTL 内部索引 | 对应架构字节地址 | 组数 |
|---|---|---|---:|
| 32 KiB | 内部 PC `[12:5]` | VA `[13:6]` | 256 |
| 64 KiB（当前 `cpu_cfig.h`） | 内部 PC `[13:5]` | VA `[14:6]` | 512 |

LSU 接口分别提供物理 tag `lsu_ifu_icache_ptag[27:0]` 和页内组索引低位 `lsu_ifu_icache_index[5:0]`。同一个物理页可能通过不同虚拟地址映射到 I-Cache，而超出 4 KiB 页内偏移的虚拟 index 高位无法由物理 tag 唯一确定。为消除 VIPT synonym/alias，IFCTRL 必须遍历这些可能的 index 高位，并在每个候选 set 中比较物理 tag。

```verilog
// 行 893-904（以 32K cache 为例）
`ifdef ICACHE_32K
parameter CNT_REG_VAL = 5'b00011;  // 初始值 3，需遍历 4 次（3,2,1,0）
`endif
`ifdef ICACHE_64K
parameter CNT_REG_VAL = 5'b00111;  // 初始值 7，需遍历 8 次
`endif
```

计数器 `addr_inv_count_reg[4:0]` 控制遍历次数。下列内部 PC 位号换算到架构字节地址后需要整体加 1：

- 32 KiB：内部 VA `[12:11]`，即架构 VA `[13:12]`，共 4 种候选（初值 3）；
- 64 KiB：内部 VA `[13:11]`，即架构 VA `[14:12]`，共 8 种候选（初值 7）；
- 128K cache：4 位不确定，遍历 16 次
- 256K cache：5 位不确定，遍历 32 次

遍历 index 的构造方式：

```verilog
// 行 1067
assign icache_line_inv_index[PC_WIDTH-2:0] =
    {23'b0, addr_inv_count_reg[4:0], lsu_ifu_icache_index[5:0], 5'b0};
```

其中 `lsu_ifu_icache_index[5:0]` 填入内部地址 `[10:5]`，对应架构页内 line index `[11:6]`；`addr_inv_count_reg[4:0]` 填入更高的候选虚拟 index 位。状态机每检查一个候选 set 后将计数器减 1，从而覆盖全部可能别名。

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

- 全量 inv 时，计数器从与容量对应的地址编码初值开始：32 KiB 为 1023，当前 64 KiB 配置为 2047；
- 普通全量 inv 每拍减 4，但 `icache_inv_tag_req` 仅在 `icache_inv_cnt[1:0]==2'b11` 时有效；
- 地址通过 `{icache_inv_cnt, 3'b0}` 构造，而 tag SRAM 再取内部地址 `[WIDTH:5]` 作为 set index；
- 因此普通路径每个有效请求只处理 **一个 set**：32 KiB 共 256 个请求，64 KiB 共 512 个请求；
- `vector_ifctrl_reset_on` 时计数器每拍减 1，并仍只在低两位为 `11` 时发请求，相当于每 4 拍推进一个 set；
- `icache_inv_over` 观察计数器高于低两位的部分；普通路径在最后一个有效 set 请求时即可形成 done。

**为什么计数器减 4？** 这是内部 PC 省略 bit0 后的地址编码步进。tag SRAM 的 set index 从内部地址 bit5 开始，而低两位被 `tag_req` 的节拍条件固定；减 4 正好让 SRAM set index 每拍减 1。它并不表示一次 SRAM 写同时清 4 个 set。

还有一个不明显但很重要的实现细节：`icache_inv_tag_req` 对 `INS_TAG_REQ` 也统一附加了 `&icache_inv_cnt[1:0]`。逐行 invalidation 自己使用的是 `addr_inv_count_reg`，却仍依赖全量计数器低两位处于 `2'b11`。全量 inv 在最后一个 set 完成的时钟沿仍会执行一次减法，计数器下溢后低两位保持为 `11`，随后逐行 inv 才能正常发 tag 请求。也就是说，当前实现把“上电/复位时已经完成过一次全量 inv，并留下正确请求相位”作为隐含时序不变量。验证逐行失效时，应在波形中同时检查：

```text
icache_inv_cur_state == INS_TAG_REQ
&& icache_inv_cnt[1:0] == 2'b11
&& ifctrl_icache_if_tag_req
```

如果只强制状态机进入 `INS_TAG_REQ`，却没有建立计数器相位，SRAM tag 读请求可能不会发出。

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
| INV_ALL / INS_INV_ALL | 3'b000 | FIFO 位、Way1 tag 和 Way0 tag 三组 bit-write 均使能；写入数据把两路 valid 清零 |
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

### 6.3 I-Cache 与预测结构失效是两条独立控制链

从当前 RTL 可验证的关系是：

1. LSU/CTCQ 的 `lsu_ifu_icache_all_inv` 或 `lsu_ifu_icache_line_inv` 驱动 I-Cache `INS_*` 状态机，并经 `ifctrl_ipb_inv_on` 阻止 IPB 在此期间继续工作；
2. CP0 的 `cp0_ifu_icache_inv` 驱动 I-Cache `INV_ALL` 路径；
3. CP0 的 `cp0_ifu_btb_inv`、`cp0_ifu_bht_inv`、`cp0_ifu_ind_btb_inv` 分别驱动常规 BTB/L0 BTB、BHT 和间接 BTB 的清除；
4. 各结构分别返回自己的 done，IFCTRL 再将相应完成脉冲送回 CP0 或 LSU。

这些控制链可以在系统软件安排下组合使用，但 IFCTRL 中没有“任意 I-Cache inv 自动连带清空所有预测结构”的组合逻辑。分析 `fence.i` 的完整实现时，还需继续沿 IDU/LSU 的指令译码、CTCQ 请求类型和软件约定追踪，不能仅根据本模块推断固定顺序。

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

**例外：L1 Refill 的 `CTC_INV` 仲裁状态**

```verilog
// 行 865-871
assign ins_all_inv_req = lsu_ifu_icache_all_inv &&
                         (!icache_refill_on && !vector_ifctrl_sm_start ||
                          l1_refill_ifctrl_ctc);   // CTC 时可以同时 inv
```

`l1_refill_ifctrl_ctc` 在 RTL 中严格等于 refill 状态机处于 `CTC_INV`。该状态发生在 refill 已经等待返回数据（`WFD1`/`INV_WFD1`）时又收到 LSU invalidation 请求：refill 暂停在 `CTC_INV`，等待 `ifctrl_l1_refill_ins_inv_dn`，然后回到 `INV_WFD1` 丢弃/排空原事务的返回数据。此时允许 IFCTRL 启动 invalidation，是两个状态机显式握手的结果，而不是“cache-through、不写 cache”的通用存储属性。

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
- `inv_busy`：更严格的信号，表示 SM 已经进入 inv/read 状态
- `ins_inv`：通知 L1 Refill 当前有 LSU 发起的全量或逐行 inv；若 refill 已在等待返回数据，双方通过 `CTC_INV` 和 inv-done 协调先完成失效，再排空原 refill 返回
- `ins_inv_dn`：通知 L1 Refill LSU inv 已完成

---

## 8. 与 MMU 的配合

### 8.1 mmu_ifu_pavld

```verilog
// 行 520-521
assign if_pc_vld = mmu_ifu_pavld && !ifu_no_op_req;
```

`mmu_ifu_pavld`（Physical Address/result Valid）来自 MMU，表示本拍 VA 翻译已经形成 IFU 可消费的正常或异常结果。`ct_mmu_iutlb` 在 I-uTLB 命中、MMU 关闭/M 模式直通，以及访问故障、refill 页故障、VA 非法时均可令其有效。只有尚未形成结果且没有可旁路命中时，它才保持为低并使 IF 级 stall。

### 8.2 何时 MMU 会拒绝给 pavld

| 情况 | 原因 | if 的反应 |
|---|---|---|
| TLB miss | MMU 正在做 page walk | `!if_pc_vld` → `if_self_stall` |
| Page fault（pgflt） | MMU 汇总出的取指页故障 | `pavld` 可同时为高，`mmu_ifu_pgflt` 由 IFDP 传到 IP 级 |
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

当 refill 空闲、没有新的 refill start 且 prefetch buffer 空闲时，组合条件 `ifu_no_op` 为高。该条件经 `ifu_no_op_flop` 保存，最终输出还会被 `!l1_refill_ifctrl_start_for_gateclk` 再次保护，避免新事务开始时继续报告 no-op。`ifu_yy_xx_no_op` 是供其他模块进行低功耗协调的状态提示，不能单凭它断言“全 IFU 已经关闭时钟”。

同时 `ifu_no_op_req` 直接等于 `cp0_ifu_no_op_req`。CP0 主动请求停止 IFU 正常取指时，它通过令 `if_pc_vld=0` 使 IF 流水停顿；IFCTRL 本身不译码具体是哪条架构指令或低功耗事件发起了该请求。

---

## 10. CP0 诊断读（READ_* 路径）

这条路径支持软件通过 CP0 读取 I-Cache data array，或按规定格式读取 tag array 的部分字段（用于调试或测试）：

```verilog
// 行 1374-1381
assign ifu_cp0_icache_read_data_vld    = (icache_inv_cur_state == READ_ST);
assign ifu_cp0_icache_read_data[127:0] =
    (icache_read_tag)
    ? (icache_read_way)
      ? {96'b0, icache_if_ifctrl_tag_data1_reg[19:0],
                11'b0, icache_if_ifctrl_tag_data1_reg[20]}
      : {96'b0, icache_if_ifctrl_tag_data0_reg[19:0],
                11'b0, icache_if_ifctrl_tag_data0_reg[20]}
    : (icache_read_way)
      ? icache_if_ifctrl_inst_data1_reg[127:0]
      : icache_if_ifctrl_inst_data0_reg[127:0];
```

流程：CP0 写入 `cp0_ifu_icache_read_req`、`read_index`、`read_tag` 和 `read_way`，SM 进入 `READ_REQ`→`READ_RD`（等 SRAM 出数并锁存）→`READ_ST`（上报有效），然后回到 IDLE。

数据读会返回所选 way 的完整 128 位数组输出。tag 读并不是把内部 29 位 `{valid, ptag[27:0]}` 原样平铺到低位：RTL 只把寄存 tag 的 `[19:0]` 放到返回值 `[31:12]`，把 bit20 放到 bit0，其余位置补 0。分析诊断软件时必须按这一硬件打包格式解码，不能把返回值低 29 位直接当成 SRAM tag。

### 10.1 本模块的门控时钟边界

IFCTRL 不是由单一门控时钟驱动，而是按功能拆成多组局部时钟：

| 时钟 | 主要寄存状态 | 本地使能 |
|---|---|---|
| `ifu_no_op_updt_clk` | no-op 状态 | 新旧 no-op 条件发生变化 |
| `hpcp_clk` | frontend-stall 性能事件 | `hpcp_ifu_cnt_en` |
| `if_vld_clk` | IP 级 valid、IF pcload | 当前/已有 valid |
| `ifctrl_reissue_clk` | reissue 打拍 | 本地与全局使能均固定为 1 |
| `icache_inv_clk` | invalidation/read 状态机和计数器 | 有请求或状态非 IDLE |
| `cache_data_flop_clk` | 逐行 inv 的 tag 比较数据 | `INS_TAG_RD` |
| `ins_inv_ptag_flop_clk` | 逐行 inv 的物理 tag | IDLE 接受 line-inv 请求 |
| `btb_inv_flop_clk` / `bht_inv_flop_clk` / `ibp_inv_flop_clk` | inv/done 边沿检测 | 请求或 done 电平变化 |
| `icache_read_clk` | CP0 诊断读返回寄存器 | `READ_RD` |

所有这些实例仍要按通用 `gated_clk_cell` 解释：`module_en=cp0_ifu_icg_en` 可覆盖局部使能，扫描使能也可开钟；未启用工艺 ICG 宏时，RTL 模型直接透传输入时钟。因此表中的“本地使能”说明的是寄存器更新所需的门控协议，不等于任何仿真配置下都能观察到物理时钟停止，也不能直接量化功耗收益。

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
| `ifctrl_btb_inv` | → BTB | 清除常规 BTB（脉冲） |
| `ifctrl_bht_inv` | → BHT | 清除 BHT（脉冲） |
| `ifctrl_ind_btb_inv` | → Ind-BTB | 清除 Indirect BTB（脉冲） |
| `icache_inv_cur_state` | 内部 | I-Cache Inv SM 当前状态 |
| `icache_inv_cnt` | 内部 | 全量 inv 的内部地址编码/节拍计数器（13 位） |
| `addr_inv_count_reg` | 内部 | 精确 inv VIPT 别名遍历计数器（5 位） |
| `ifctrl_icache_if_tag_wen[2:0]` | → ICache | Tag SRAM 写使能 |
| `ifu_cp0_icache_inv_done` | → CP0 | I-Cache inv 完成脉冲 |
| `ifu_lsu_icache_inv_done` | → LSU | LSU/CTCQ 发起的 I-Cache inv 完成 |
