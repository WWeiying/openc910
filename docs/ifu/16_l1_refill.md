# ct_ifu_l1_refill 模块详解

## 1. 模块概述

### 1.1 I-Cache Miss 的完整处理流程

当 C910 IFU 的 IP 级检测到取指数据不能由当前 I-Cache 正常提供时，
`ct_ifu_l1_refill` 负责保存本次请求的地址/属性、控制 refill 状态机、接收 IPB
返回 beat，并产生 I-Cache 写入、旁路数据、错误和 reissue 信号。它不是整个 miss
处理的唯一模块：IPCTRL 发起 miss，IPB 可用预取缓冲命中或向 BIU 发请求，
`icache_if` 仲裁并驱动 SRAM，IFCTRL/PCGEN 负责 stall 与重发。

这里的“不能正常提供”既包括普通 refill 条件，也包括 IPCTRL 寄存后的 I-Cache
check-error refill。虽然接口名是 `miss_req`，它并不严格等于“tag compare
miss”这一种事件。

完整流程如下：

```
IP 级 icache miss
       │
       ▼
ipctrl 发出 miss_req
       │
       ▼
l1_refill 进入 REQ 状态，向 IPB 发出取数请求
       │
       ▼
IPB（Instruction Pre-fetch Buffer）经 BIU 发出读请求，由后续系统存储层次响应
       │
       ▼
IPB 以预取缓冲命中或 BIU 返回 grant；cache-line 请求随后按 WRAP 顺序返回 4 个 128 位 beat
       │
       ▼
l1_refill 依次接收 WFD1→WFD2→WFD3→WFD4
首 beat 是 miss 所在的 16B critical block，可直接旁路给 IFDP；正常 line 路径每拍同时写 I-Cache
       │
       ▼
WFD4 完成后提交 tag valid、回到 IDLE，并通知 ifctrl reissue（重取指）
       │
       ▼
无传输错误、无 invalidation 干扰时，该 line 在最后 beat 后有效；重发请求可重新查 I-Cache
```

这里同时存在两条不同的数据可见路径：

- **refill bypass**：正常 WFDn 收到当前 IF PC 所在 16B block 时，返回数据和
  precode 直接送入 IFDP。前端可以在整条 64B line 尚未有效时使用 critical
  block；这属于 critical-block-first 加 early restart。
- **I-Cache fill**：`tsize=1` 时，每个正常 beat 写 Data/Predecode Array；首 beat
  先清替换 way 的 valid，末 beat 才写 ptag 并置 valid。这个路径决定后续普通
  I-Cache 命中。

因此，“首拍数据可被当前取指使用”和“整条 cache line 已完整发布”是两个时刻。
WFD4 的 reissue 仍有必要，因为末拍到达时 PCGEN 的当前 PC 可能尚未通过普通
I-Cache 访问，需要在 line 发布后重新发起取指。

### 1.2 l1_refill 与各模块的关系

```
ipctrl ─── miss_req ──────────────────────> l1_refill
                                                │
                  l1_refill_ipb_req             │
l1_refill ──────────────────────────────> IPB  │
                  ipb_l1_refill_grnt            │
IPB ────────────────────────────────────> l1_refill
                  ipb_l1_refill_rdata           │
                  ipb_l1_refill_data_vld        │
                                                │
              l1_refill_icache_if_wr            │
l1_refill ──────────────────────────────> icache_if（写入 I-Cache）
              l1_refill_icache_if_inst_data
              l1_refill_icache_if_first/last
              l1_refill_icache_if_ptag
              l1_refill_icache_if_pre_code
                                                │
              l1_refill_ifctrl_refill_on        │
l1_refill ──────────────────────────────> ifctrl（流控协调）
              l1_refill_ifctrl_idle
              l1_refill_ifctrl_reissue
              l1_refill_ifctrl_ctc
                                                │
pcgen ───── pcgen_l1_refill_chgflw ──────> l1_refill（改变流方向通知）
```

**IPB（Instruction Pre-fetch Buffer）** 位于 refill 状态机与 BIU 接口之间。
它既维护指令预取缓冲，也仲裁 refill/预取请求：若请求命中已有 prefetch line，
`pref_grnt_ref` 和 pbuf 回写可直接服务 refill；否则 IPB 形成 BIU 读请求。
所以 `ipb_l1_refill_grnt` 是 `pref_grnt_ref || biu_ref_grnt`，不能一概解释成
“BIU/L2 已 grant”。

---

## 2. 端口说明

### 2.1 来自 ipctrl 的输入

| 信号名 | 含义 |
|--------|------|
| `ipctrl_l1_refill_miss_req` | IPCTRL 的实际 refill 请求；覆盖正常 `ip_refill_pre` 路径和寄存后的 I-Cache check-error refill，并受异常、已有 refill busy 和低功耗条件过滤 |
| `ipctrl_l1_refill_req_for_gateclk` | 更早且略宽的请求准备条件，用于门控时钟和地址预捕获，不等同于实际 miss_req |
| `ipctrl_l1_refill_ppc[38:0]` | miss 指令的物理 PC（写 tag array 用） |
| `ipctrl_l1_refill_vpc[38:0]` | miss 指令的虚拟 PC（写 index / ifctrl pc 用） |
| `ipctrl_l1_refill_chk_err` | 地址检查错误标志 |
| `ipctrl_l1_refill_fifo` | 地址检查错误路径提供的替换 way/FIFO 位；当前 IPCTRL 将其固定为 0 |

### 2.2 来自 ifdp 的输入（访存属性）

| 信号名 | 含义 |
|--------|------|
| `ifdp_l1_refill_cacheable` | 地址是否 cacheable |
| `ifdp_l1_refill_bufferable` | 地址是否 bufferable |
| `ifdp_l1_refill_tsize` | 1 表示 4×128-bit WRAP line 请求，0 表示单个 128-bit beat；上游取 `icache_en && mmu_ifu_ca` |
| `ifdp_l1_refill_supv_mode` | 送往 BIU protection 字段的监督态属性，当前由 `cp0_yy_priv_mode[0]` 形成 |
| `ifdp_l1_refill_machine_mode` | 送往 BIU user 字段的 M-mode 属性 |
| `ifdp_l1_refill_secure` | MMU 的 `sec` 总线属性；其系统语义由 SoC/互连定义，不能仅凭名称等同于完整“安全世界” |
| `ifdp_l1_refill_fifo` | 当前 set 的 I-Cache 1-bit 替换选择，决定本次 refill 写 Way0 还是 Way1 |

### 2.3 来自 IPB 的输入（数据返回接口）

| 信号名 | 含义 |
|--------|------|
| `ipb_l1_refill_grnt` | IPB 已接受 refill：可能来自 prefetch-buffer 命中，也可能来自 BIU grant |
| `ipb_l1_refill_data_vld` | 当前返回 beat 的 128 位数据有效；该信号只说明这一 beat 有效，不单独表示整个 64B line 已完成 |
| `ipb_l1_refill_rdata[127:0]` | 128 位原始数据 |
| `ipb_l1_refill_trans_err` | 总线传输错误 |

### 2.4 来自 ifctrl 的输入

| 信号名 | 含义 |
|--------|------|
| `ifctrl_l1_refill_ins_inv` | 精确等于 `lsu_ifu_icache_line_inv \|\| lsu_ifu_icache_all_inv`，用于让已获 grant、尚未收首 beat 的 refill 让 LSU cache-control invalidation 先执行 |
| `ifctrl_l1_refill_ins_inv_dn` | 精确等于 `ifu_lsu_icache_inv_done`，表示上述 LSU invalidation 已完成 |
| `ifctrl_l1_refill_inv_busy` | IFCTRL 的 I-Cache invalidation FSM 已离开 IDLE；用于地址递增屏蔽和 `pre_cancel` |
| `ifctrl_l1_refill_inv_on` | 更宽的 invalidation 启动/进行指示：除 FSM busy 外，还覆盖待启动的 CP0 all-invalidate、LSU line/all invalidate 和 I-Cache read；用于屏蔽新 refill start |

### 2.5 来自 pcgen 的输入

| 信号名 | 含义 |
|--------|------|
| `pcgen_l1_refill_chgflw` | 流水线发生了方向改变（chgflw），refill 地址已过期 |

### 2.6 送往 icache_if 的输出

| 信号名 | 含义 |
|--------|------|
| `l1_refill_icache_if_wr` | 当前周期向 I-Cache 写入数据 |
| `l1_refill_icache_if_first` | 正常四 beat refill 的首 beat 有效；I-Cache 接口据此将所选替换 way 的 valid 清 0，并把该 way 的 tag data 写 0 |
| `l1_refill_icache_if_last` | 正常四 beat refill 的末 beat 有效；I-Cache 接口据此写入所选 way 的物理 tag 和 valid=1，并翻转该 set 的替换位 |
| `l1_refill_icache_if_index[38:0]` | I-Cache index（来自虚拟 PC） |
| `l1_refill_icache_if_ptag[27:0]` | I-Cache 物理 tag（内部 PC `[38:11]`，对应架构 PA `[39:12]`） |
| `l1_refill_icache_if_inst_data[127:0]` | 经 16-bit half-word lane 反序排列后的 128 位指令数据；任一 half-word 内部的两个字节没有在本模块交换 |
| `l1_refill_icache_if_pre_code[31:0]` | 预解码信息（同时写入 predecode array） |
| `l1_refill_icache_if_fifo` | 锁存的 I-Cache 替换 way/FIFO 位：0 写 Way0，1 写 Way1 |

### 2.7 送往 ifctrl 的输出

| 信号名 | 含义 |
|--------|------|
| `l1_refill_ifctrl_refill_on` | refill 状态机处于 REQ、正常 WFDn 或 CTC_INV；IFCTRL 将其作为取指有效、stall 和 invalidation 仲裁的一个条件，而不是把它直接等同于“整个 IFU 已停止” |
| `l1_refill_ifctrl_idle` | refill 状态机空闲（回到 IDLE） |
| `l1_refill_ifctrl_reissue` | 正常单 beat/最后 beat 完成或 WFDn 传输错误时，请求 IFCTRL 记录一次 reissue |
| `l1_refill_ifctrl_ctc` | 处于 CTC_INV，即 cache-control invalidation 优先、原 refill 首 beat 暂停接收的等待状态 |
| `l1_refill_ifctrl_trans_cmplt` | 组合等于 `ipb_l1_refill_data_vld \|\| ipb_l1_refill_trans_err`，本模块没有再用状态限定；IFCTRL 仅在 refill 上下文并匹配当前 block 时把它当作有效返回 |
| `l1_refill_ifctrl_pc[38:0]` | refill 当前处理的 PC（虚拟地址） |
| `l1_refill_ifctrl_start` | 已通过 `!ifctrl_l1_refill_inv_on` 屏蔽后的实际 `refill_start` |
| `l1_refill_ifctrl_start_for_gateclk` | 由提前请求形成的门控时钟预使能，不表示 FSM 已接受请求 |
| `l1_refill_inv_wfd_back` | CTC_INV 完成后是否还需回到 INV_WFD1 排空；该位可在返回 IDLE 后继续保持到下一次 refill start |

### 2.8 送往 ifdp 的输出（旁路数据）

| 信号名 | 含义 |
|--------|------|
| `l1_refill_ifdp_refill_on` | 与 `refill_sm_on` 相同，表示 REQ/WFDn/CTC_INV 上下文；并不单独证明当前拍有有效返回数据 |
| `l1_refill_ifdp_inst_data[127:0]` | IPB 128 位返回经 half-word lane 重排后的组合旁路数据 |
| `l1_refill_ifdp_precode[31:0]` | 对应的预解码信息 |
| `l1_refill_ifdp_tag_data[28:0]` | `{当前 WFDn beat 数据有效, ptag[27:0]}`，用于 refill 旁路匹配，不是 SRAM tag array 的持久读出 |
| `l1_refill_ifdp_acc_err` | 访存错误标志 |

### 2.9 送往 IPCTRL、IPB、PMU 和调试逻辑的输出

| 信号名 | 含义 |
|--------|------|
| `l1_refill_ipctrl_busy` | FSM 不是 IDLE；包含正常 WFD、INV_WFD 和 CTC_INV，用于阻止 IPCTRL 发起下一笔 refill |
| `l1_refill_ipb_req` | 当前为 REQ，IPB 据此形成 refill/prefetch-buffer/BIU 请求 |
| `l1_refill_ipb_req_pre` | IPB 请求组合前瞻：IDLE 的提前 start，或仍在等待 grant 且未改流/失效的 REQ |
| `l1_refill_ipb_req_for_gateclk` | IPB 请求路径的门控时钟预使能；REQ 中比 `req_pre` 更宽，不代表有效总线请求 |
| `l1_refill_ipb_refill_on` | `REQ && !change_flow`，表示该 demand refill 仍属于当前控制流，也参与后续预取启动资格 |
| `l1_refill_ipb_ctc_inv` | CTC_INV 期间通知 IPB 暂停 refill 返回；IPB 将 `ifu_biu_r_ready` 拉低 |
| `l1_refill_ipb_pre_cancel` | 改流或 I-Cache invalidation busy 时取消 IPB 已寄存的下一 line 预取 tag 查询 |
| `l1_refill_ipb_ppc/vpc` | 恢复最低零位后的 40 位物理/虚拟字节地址 |
| `l1_refill_ipb_tsize/cacheable/bufferable` | 本次请求锁存的传输大小和内存属性 |
| `l1_refill_ipb_supv_mode/machine_mode/secure` | 本次请求锁存并送往 BIU prot/user 的属性 |
| `ifu_hpcp_icache_miss_pre` | 正常 WFD1 的首个 data/error 响应事件，精确定义见第 10 节 |
| `l1_refill_debug_refill_st[3:0]` | 当前 refill FSM 编码 |

---

## 3. 状态机（核心）

### 3.1 状态定义

```verilog
// 行 269-280
parameter IDLE     = 4'b0000;  // 空闲，等待 miss 请求
parameter REQ      = 4'b0001;  // 已提交请求，等待 grant 或 chgflw
parameter WFD1     = 4'b0100;  // 等待第 1 个返回 beat（正常接收）
parameter WFD2     = 4'b0101;  // 等待第 2 个返回 beat
parameter WFD3     = 4'b0110;  // 等待第 3 个返回 beat
parameter WFD4     = 4'b0111;  // 等待第 4 个返回 beat
parameter INV_WFD1 = 4'b1000;  // 等待第 1 个返回 beat（仅排空，不写 I-Cache）
parameter INV_WFD2 = 4'b1001;  // 等待第 2 个返回 beat（仅排空）
parameter INV_WFD3 = 4'b1010;  // 等待第 3 个返回 beat（仅排空）
parameter INV_WFD4 = 4'b1011;  // 等待第 4 个返回 beat（仅排空）
parameter CTC_INV  = 4'b0011;  // cache-control invalidation 优先等待
```

注意编码规律：
- `bit[2]=1` 表示处于 WFDn 系列（正常接收），即 WFD1/2/3/4。
- `bit[3]=1` 表示处于 INV_WFDn 系列（接收但丢弃）。
- 这使得 `refill_cur_state[2]` 可作为"是否在正常写入状态"的快速判断条件。

### 3.2 完整状态转移图

```text
正常四 beat 路径

IDLE --refill_start--> REQ --grant && !change_flow--> WFD1
WFD1 --data_vld && tsize--> WFD2 --data_vld--> WFD3
WFD3 --data_vld--> WFD4 --data_vld--> IDLE

单 beat：WFD1 --(data_vld || trans_err) && !tsize--> IDLE

首 beat 前废弃/排空路径

REQ  --change_flow && !grant-------------------------------> IDLE
REQ  --change_flow && grant----┐
WFD1 --change_flow-------------┼--> INV_WFD1
                              │      |  tsize 下每个 data/error 前进一步
                              │      v
                              │   INV_WFD2 -> INV_WFD3 -> INV_WFD4 -> IDLE
                              │
WFD1/INV_WFD1 --ins_inv------> CTC_INV
CTC_INV --ins_inv_dn && inv_wfd_back-----------------------> INV_WFD1

错误跳转：WFD1 error -> INV_WFD2，WFD2 error -> INV_WFD3，
          WFD3 error -> INV_WFD4，WFD4 error -> IDLE。
```

注：当前 RTL 只有 REQ 和 **尚未收到首 beat 的 WFD1** 响应 `change_flow`。
WFD2/WFD3/WFD4 没有 change-flow 分支；一旦首 beat 已进入正常 refill，状态机
继续完成该 cache line，而不是转入同编号 INV_WFD。

### 3.3 状态转移详细条件

以下按状态逐一分析：

#### IDLE

```verilog
// 行 344-347
IDLE : if(refill_start)
       refill_next_state = REQ;
       else
       refill_next_state = IDLE;
```

`refill_start = ipctrl_l1_refill_miss_req && !ifctrl_l1_refill_inv_on`

若 `ifctrl_l1_refill_inv_on=1`，`refill_start` 被组合屏蔽，本拍不会从 IDLE
进入 REQ。该接口只说明两类操作互斥；被屏蔽的 miss 是否以及何时重新提出，由
IPCTRL/IFCTRL 的 stall、reissue 和 invalidation 完成逻辑共同决定，不能从这里
假定请求会在本模块内部排队保存。

#### REQ

```verilog
// 行 348-357
REQ : if(change_flow && !refill_grnt)
      refill_next_state = IDLE;     // 未 grant 时改流：FSM 撤回请求并返回 IDLE
      else if(!change_flow && refill_grnt)
      refill_next_state = WFD1;     // 正常：grant 来了，开始等数据
      else if(change_flow && refill_grnt)
      refill_next_state = INV_WFD1; // 同时来：接收数据但最终 inv
      else if(ifctrl_l1_refill_ins_inv)
      refill_next_state = IDLE;     // 收到 instruction-cache invalidation：取消未 grant 请求
      else
      refill_next_state = REQ;
```

关键设计：
- **`change_flow && !refill_grnt`**：状态机下一拍回 IDLE。源码注释说明 IPB/BIU
  取消逻辑会忽略尚未 grant 的请求；这是本设计接口协议，不应外推为任意总线协议
  都允许相同取消方式。
- **`change_flow && refill_grnt`**：下一拍进入 INV_WFD1。grant 可能来自 pbuf
  命中或 BIU，状态机均按“已有返回事务需要排空”处理，后续不触发 I-Cache 写。
- **先 grant 后进入 WFD1、但首 beat 尚未到达时发生 change_flow**：WFD1 同样
  转 INV_WFD1。首 beat 已被 WFD1 正常接收后，下一拍已经进入 WFD2，此后
  change_flow 不再改变 refill 状态。

#### WFD1～WFD4（正常接收，以 WFD1 为例）

```verilog
// 行 388-407
WFD1 : if(ipb_refill_data_vld)
       begin
         if(tsize)
         refill_next_state = WFD2;     // 4-beat 传输，继续等第 2 个 beat
         else
         refill_next_state = IDLE;     // 单-beat 传输（128 位），完成
       end
       else if(ipb_refill_trans_err)
       begin
         if(tsize)
         refill_next_state = INV_WFD2; // 第 1 个 beat 出错，后续 3 个 beat 仅排空
         else
         refill_next_state = IDLE;
       end
       else if(change_flow)
       refill_next_state = INV_WFD1;   // 等待首 beat 期间改流：转入仅排空路径
       else if(ifctrl_l1_refill_ins_inv)
       refill_next_state = CTC_INV;    // instruction-cache invalidation 请求
       else
       refill_next_state = WFD1;
```

WFD2/WFD3 只有 data_vld、trans_err 两个出口。即使控制流随后改变，已开始的
cacheable line 仍继续写完；代价是新路径取指可能继续受 `refill_on` 约束直到
WFD4 结束：

```verilog
// 行 408-419
WFD2 : if(ipb_refill_data_vld) refill_next_state = WFD3;
       else if(ipb_refill_trans_err) refill_next_state = INV_WFD3;
       else refill_next_state = WFD2;

WFD3 : if(ipb_refill_data_vld) refill_next_state = WFD4;
       else if(ipb_refill_trans_err) refill_next_state = INV_WFD4;
       else refill_next_state = WFD3;
```

WFD4 接收最后一个返回 beat 后直接回 IDLE（不管返回事件是 `data_vld` 还是
`trans_err`）：

```verilog
// 行 420-425
WFD4 : if(ipb_refill_data_vld || ipb_refill_trans_err)
       refill_next_state = IDLE;
       else refill_next_state = WFD4;
```

#### INV_WFD1～INV_WFD4（无效接收）

```verilog
// 行 365-387
INV_WFD1 : if(ipb_refill_data_vld || ipb_refill_trans_err)
            begin
              if(tsize)
              refill_next_state = INV_WFD2;
              else
              refill_next_state = IDLE; // 单-beat 传输完成
            end
            else if(ifctrl_l1_refill_ins_inv)
            refill_next_state = CTC_INV; // invalidation 到来，转 CTC_INV
            else
            refill_next_state = INV_WFD1;

INV_WFD2 → INV_WFD3 → INV_WFD4 → IDLE：每消费一个 data/error 返回事件前进一步
```

INV_WFD 系列按预期 beat 数消费 data/error 事件后回 IDLE。由于这些状态的
bit2=0，`l1_refill_icache_if_wr` 始终为 0，既不写 Data/Predecode，也不额外
写 tag valid=0。“不写”与“再写一次无效 tag”是不同硬件动作。

#### CTC_INV（cache-control invalidation 优先等待）

```verilog
// 行 426-431
CTC_INV : if(ifctrl_l1_refill_ins_inv_dn && inv_wfd_back)
          refill_next_state = INV_WFD1; // inv 完成 + 有待接收数据，转 INV_WFD1
          else
          refill_next_state = CTC_INV;
```

CTC_INV 是让 cache invalidation 优先于尚未接收首 beat 的 refill 的等待状态。
它只从 WFD1/INV_WFD1 的 `ifctrl_l1_refill_ins_inv` 分支进入；同拍
`inv_wfd_back_record` 把待排空事实置 1。状态期间
`l1_refill_ipb_ctc_inv=1`，IPB 将 `ifu_biu_r_ready` 拉低并屏蔽 refill
data/error。待 `ins_inv_dn && inv_wfd_back` 后进入 INV_WFD1，再恢复接收并丢弃
原事务。该 invalidation 可能是行失效或全失效，不能统一写成“清空整个 I-Cache”。

`inv_wfd_back` 只在 invalidation 于 WFD1 或 INV_WFD1 到来时置位，并在下一次
IDLE 中接受新 `refill_start` 时清零。它不是任意 WFD 深度计数器；当前 FSM 也不
允许从 WFD2/3/4 进入 CTC_INV。

这也意味着 `inv_wfd_back` 可以在 CTC_INV 排空结束、FSM 已回到 IDLE 后仍为 1，
直到下一次真正开始 refill 才清零。该位表达“上一笔 CTC 路径留下的返回目的地
记录”，不能脱离 `refill_cur_state` 单独解释成“当前正在 INV_WFD”。

CTC_INV 没有 `ins_inv_dn && !inv_wfd_back` 的返回 WFD1 分支；源码中的该分支已
被注释。设计依赖一个状态不变量：凡进入 CTC_INV 的同一边沿，都必须由
WFD1/INV_WFD1 的 `ins_inv` 同时把 `inv_wfd_back` 置 1。若波形出现
`CTC_INV && ins_inv_dn && !inv_wfd_back`，FSM 会继续停在 CTC_INV，这应首先
作为控制协议或采样异常排查，而不是正常状态。

### 3.4 为什么不能在 chgflw 时直接丢弃？

这是该状态机设计的核心原因之一：

从当前接口行为可确定：grant 后若在首 beat 前取消，FSM 进入 INV_WFD 并继续
等待相应 data/error 事件；CTC_INV 则用 ready=0 暂停后再排空。IPB 对 BIU 使用
四 beat WRAP 或单 beat 请求，但开源 RTL 接口本身不应被笼统称为“AXI/CHI
协议保证”。更稳妥的体系结构理解是：控制流是否仍需要数据，与互连事务是否仍
必须完成是两个独立问题；INV_WFD 保持事务层状态完整，同时禁止过期数据进入
I-Cache。

另一方面，首 beat 已在 WFD1 正常接收后，WFD2/3/4 不再检查 change-flow。此后
即使前端转向另一条路径，旧 line 仍会写完并最终置 valid。这相当于把已经启动的
错误路径 fill 当作一次机会性填充，可能在未来有用，也可能形成 cache pollution；
同时 `refill_on` 会让新路径在 line 完成前受到约束，且唯一 refill 上下文不能服务
新 miss。RTL 能证明这种策略和资源串行化，是否值得改成“晚改流也转 INV_WFD”
则需要用错误路径 fill 比例、剩余 beat 数和新路径 miss 延迟共同评估。

---

## 4. Miss 请求发起

### 4.1 进入 REQ 状态

```verilog
// 行 438-439
assign refill_start = ipctrl_l1_refill_miss_req &&
                      !ifctrl_l1_refill_inv_on;
```

`ipctrl_l1_refill_miss_req` 是 IPCTRL 给出的实际 refill 请求。其上游核心关系是：

```verilog
ip_icache_refill =
    ((ip_refill_pre &&
      !ipdp_ipctrl_ip_expt_vld &&
      !icache_chk_err_refill) ||
      icache_chk_err_refill_ff) &&
    !l1_refill_ipctrl_busy &&
    !(cp0_ifu_no_op_req && ibctrl_ipctrl_low_power_stall);

ipctrl_l1_refill_req_for_gateclk =
    (ip_refill_pre || icache_chk_err_refill_ff) &&
    !l1_refill_ipctrl_busy &&
    !(cp0_ifu_no_op_req && ibctrl_ipctrl_low_power_stall);
```

所以实际请求既可来自普通 `ip_refill_pre`，也可来自 check-error 重填；提前版本
没有正常请求上的 IP exception/check-error 互斥项，只用于提前开钟和准备地址。
随后本模块再用
`!ifctrl_l1_refill_inv_on` 防止 refill FSM 与正在进行的 invalidation 同时启动；
这首先是状态一致性约束，减少无效工作只是可能的附带效果。

### 4.2 向 IPB 发送请求

```verilog
// 行 752
assign l1_refill_ipb_req = (refill_cur_state[3:0] == REQ);
```

在 REQ 状态期间，持续向 IPB 拉高 req 信号。IPB 先检查请求能否由已有
prefetch buffer line 服务；未命中时才把 refill 与自身预取请求仲裁后送往 BIU。

本次 refill 的事务属性
`tsize/cacheable/bufferable/supv_mode/machine_mode/secure` 在
`ipctrl_l1_refill_miss_req` 时从 IFDP 采样并保持：

```verilog
// 行 688-689
else if(ipctrl_l1_refill_miss_req)
    tsize <= ifdp_l1_refill_tsize;
```

### 4.3 `tsize`：传输大小的关键标志

`tsize=1` 时 IPB 输出 `arlen=3`、`arsize=16B`、`arburst=WRAP`，形成 4 个
128-bit beat 的 64B line 请求。`tsize=0` 时为 `arlen=0` 的单 128-bit beat。
上游当前将 `tsize` 置为 `cp0_ifu_icache_en && mmu_ifu_ca`，所以 0 既可能表示
地址不可缓存，也可能表示 I-Cache 被关闭；不应只归因于 cache-through 地址。

`tsize` 是状态机区分 line refill 与单-beat 访问的关键锁存属性：WFD1 收到
首个 data/error 返回事件后，`tsize=1` 时继续处理剩余三个 beat，`tsize=0` 时
直接结束。WFD2～WFD4 只可能由 `tsize=1` 的路径到达。

### 4.4 地址、属性和替换 way 并非由同一根 valid 锁存

本模块把“提前开钟”和“真正接受 miss”分开处理，波形分析时必须区分三组触发：

| 寄存内容 | 更新条件 | 说明 |
|----------|----------|------|
| `physical_pc`、`virtual_pc` | 在 `l1_refill_clk` 边沿且 `ipctrl_l1_refill_req_for_gateclk=1` | 提前请求到来时准备地址，随后正常 WFDn 每消费一个非末 beat 的 line 响应按 WRAP 顺序递增 |
| `tsize` 及五类内存/权限属性 | 在 `l1_refill_clk` 边沿且 `ipctrl_l1_refill_miss_req=1` | 实际 miss 请求时准备事务属性 |
| `l1_refill_icache_if_fifo` | 在 `l1_refill_clk` 边沿且 `refill_start=1` | 只有实际开始 refill 才锁存替换 way；正常请求取 `ifdp_l1_refill_fifo`，tag 检查错误路径取 `ipctrl_l1_refill_fifo` |

状态机只在
`refill_start = miss_req && !ifctrl_l1_refill_inv_on` 时从 IDLE 进入 REQ。
注意，前两组 always block 的数据更新条件使用原始提前请求或 miss 请求，而本地
时钟使能使用屏蔽 invalidation 后的 `refill_start_for_gateclk`；是否真的出现
边沿还取决于 ICG wrapper、模块使能和当前状态。因此地址或属性寄存器出现新值，
不足以证明请求已被接受；应以
`refill_cur_state`、`l1_refill_ifctrl_start` 和随后 REQ 为准。

这种“提前数据准备 + 有效状态单独控制”的写法能给门控时钟和请求组合逻辑留出
准备时间，但也意味着无效状态下的数据寄存器可保留旧值或预先捕获新值。硬件接口
的通用原则是：payload 必须和自己的 valid/状态一起解释。

### 4.5 本地门控时钟

```verilog
assign l1_refill_clk_en =
    refill_start_for_gateclk || (refill_cur_state != IDLE);
```

本地意图是：IDLE 时只有提前 start 打开 refill 时钟，离开 IDLE 后持续开钟，
保证状态、地址和事务属性可前进。但开源 `gated_clk_cell` 还包含
`cp0_yy_clk_en`、`cp0_ifu_icg_en` 和 scan 使能；未定义工艺 ICG 宏时 wrapper
甚至可能直接透传时钟。因此 `l1_refill_clk_en=0` 只能说明本模块没有提出本地
开钟请求，不能单凭 RTL 波形推导实际物理时钟树已经关闭或量化功耗收益。

---

## 5. 数据接收（WFD1~WFD4）

### 5.1 每个 beat 128 位，cacheable line 共 4 个 beat

```
64B cache line = 4 × 16B
WFD1 = miss 地址所在的 16B critical block
WFD2/WFD3/WFD4 = WRAP burst 后续三个 16B block
```

IPB 将 BIU 地址低 4 位清零，并在 `tsize=1` 时请求 4-beat WRAP burst。因此若
miss 首块并非 line 的最低 16B，四个 beat 会在 64B 边界内循环回绕。例如首块
偏移为 32B 时，逻辑顺序是 32B、48B、0B、16B。不能固定写成
WFD1→line[127:0]、WFD4→line[511:384]。L1 refill 用 `physical_pc/virtual_pc`
的内部 `[4:3]` 加一并自然截断为 2 位，采用相同的 mod-4 block 顺序写各数据行。

### 5.2 128 位总线布局到 IFU half-word 布局的转换

RTL 将输入的八个 16-bit half-word lane 反序排列，使最低地址 half-word 位于
IFU 128 位窗口的高端。它**没有交换任一 half-word 内部的两个字节**，所以不能
把这段逻辑解释成“总线大端转 RISC-V 小端”或“相邻字节互换”：

```verilog
// 行 473-498
assign ipb_l1_refill_data_aft_v2trans[127:0] = {
    {byte1[7:0],  byte0[7:0]},    // 输入 rdata[15:0]   -> 输出 [127:112]
    {byte3[7:0],  byte2[7:0]},    // 输入 rdata[31:16]  -> 输出 [111:96]
    {byte5[7:0],  byte4[7:0]},
    {byte7[7:0],  byte6[7:0]},
    {byte9[7:0],  byte8[7:0]},
    {byte11[7:0], byte10[7:0]},
    {byte13[7:0], byte12[7:0]},
    {byte15[7:0], byte14[7:0]}
};
```

等价伪代码是：

```text
for lane in 0..7:
    out[127-16*lane -: 16] = rdata[16*lane +: 16]
```

这个方向与 IPDP/Precode 的约定一致：窗口高位对应较低地址 half-word。讨论
ISA endian 时还需同时看 BIU 对每个 16-bit lane 的字节含义，不能由这一个拼接式
单独推出总线端序。

### 5.3 `ipb_l1_refill_data_vld`：有效信号

每当 IPB 送来一个有效 beat 时，`ipb_l1_refill_data_vld` 使状态机前进一步。
RTL 不要求相邻 beat 连续，因此两次有效之间可以等待；延迟来源可能是 pbuf/IPB、
BIU、缓存层次或互连，不能只归因于 L2/DDR。

### 5.4 Critical-block-first 与 refill bypass

`tsize=1` 时 IPB 发出的 WRAP 请求从 miss 所在 16B block 开始，因此 WFD1 返回
critical block。该 beat 一方面写入 I-Cache，另一方面直接旁路到 IFDP：

```verilog
// l1_refill
l1_refill_ifdp_inst_data = ipb_l1_refill_data_aft_v2trans;
l1_refill_ifdp_precode   = pre_code_info;
l1_refill_ifdp_tag_data  = {
    refill_cur_state[2] && ipb_refill_data_vld,
    physical_pc[38:11]
};

// ifctrl
refill_pc_hit =
    (pcgen_ifctrl_pc[38:3] == l1_refill_ifctrl_pc[38:3]);
if_inst_data_vld =
    ... ||
    (l1_refill_ifctrl_refill_on &&
     l1_refill_ifctrl_trans_cmplt &&
     refill_pc_hit);
```

内部 PC `[38:3]` 对应架构字节 PC `[39:4]`，所以 `refill_pc_hit` 比较的是当前
16B block。命中时，本拍返回数据可以成为 IF 级数据源；不命中时，即使别的
refill beat 到达，当前 IF PC 仍不能错误消费它。IFDP 在 refill_on 时把 refill
数据接到 way0 通路，并用 `{data_vld, physical_tag}` 与当前 MMU 物理地址分段
比较，way1 在 refill 模式下强制不命中。

因此一个正常 cacheable miss 的恢复并非只有“等待 WFD4”这一条路径：

1. WFD1 的 critical block 可使原 miss PC 提前继续；
2. 若后续顺序 PC 正好跟随 WRAP 返回的 block，后续 beat 也可逐块旁路；
3. 当下一条所需 block 尚未返回时，IFCTRL 继续 stall；
4. WFD4 最终写 tag valid 并触发 reissue，使当前保留 PC 重新走普通 I-Cache
   访问。

这是一种以 16B 为旁路粒度、以 64B 为缓存发布粒度的
critical-block-first/early-restart 设计。它能缩短“首条有用指令可见”的等待，
但实际节省周期取决于返回间隔、当前 PC 走向、分支改流和下游 stall，不能只由
RTL 结构给出固定数字。

### 5.5 `ipb_l1_refill_trans_err`：传输错误

若当前 WFDn 收到 `ipb_l1_refill_trans_err`，该状态把错误响应视作当前 beat 已
终止：WFD1/2/3 跳到对应的下一 INV_WFD，WFD4 或单 beat WFD1 回 IDLE。同时
`l1_refill_ifdp_acc_err` 在正常 WFDn 状态拉高。当前 IPB 对 BIU 返回用
`biu_ifu_rd_resp[1]` 将正常 data-valid 和 transfer-error 分成互斥路径：
正常响应产生 `biu_ref_data_vld`，错误响应产生 `biu_ref_trans_err`。因此 BIU
错误拍不会同时触发本模块的 I-Cache 数据写：

```verilog
// 行 670-671
assign l1_refill_ifdp_acc_err = refill_cur_state[2] && //WFDn
                                ipb_l1_refill_trans_err;
```

错误仍被视为一次 `trans_cmplt`，允许 IFCTRL 对命中当前 refill block 的取指
形成有效流水事件；此时 IFDP 同拍给出 `acc_err`，后续流水携带访问异常，而不是
把返回数据当作正常指令。若错误发生在 WFD1/2/3，余下 burst beat 进入 INV_WFD
排空；已经在错误前写入的 data 行不会被逐行回滚，但因为首拍已清 valid、错误后
又不会产生正常 WFD4 `last`，整条替换 line 不会发布为有效。

---

## 6. 数据写入 I-Cache

### 6.1 写使能信号

```verilog
// 行 574-583
assign l1_refill_icache_if_wr = refill_cur_state[2] &&  // WFDn 系列
                                ipb_l1_refill_data_vld &&
                                tsize;
assign l1_refill_icache_if_first = (refill_cur_state[3:0] == WFD1) &&
                                   ipb_l1_refill_data_vld && tsize;
assign l1_refill_icache_if_last  = (refill_cur_state[3:0] == WFD4) &&
                                   ipb_l1_refill_data_vld;
```

关键条件：`refill_cur_state[2]` 为 1 意味着处于 WFD1/2/3/4（bit 编码 0b0100~0b0111），而 INV_WFD（0b1000~0b1011）的 bit[2] 为 0，因此 INV_WFD 系列**不触发 wr**——即"静默接收，不写缓存"。

`tsize=0` 时也不写 I-Cache；其返回仍可通过 refill-to-IFDP 旁路服务当前取指。
当前上游在不可缓存或 I-Cache 关闭时形成该模式。

### 6.2 first/last 信号的含义与 Tag Valid 控制

这是防止"脏命中"的关键机制：

| 信号 | 时序 | 操作 |
|------|------|------|
| `first=1` | WFD1 收到首 beat 时 | 选择替换 way，将该 way 的 valid 清 0，并把 tag data 写 0；FIFO 位保持 |
| 中间包（WFD2/3） | 收到数据时 | 只写 Data Array |
| `last=1` | WFD4 收到最后 beat 时 | 写最后一个 Data/Predecode 行，并将所选 way 的 ptag+valid 写入 Tag Array，同时翻转 FIFO 位 |

**为什么这么做？**

如果首 beat 到来时就设 valid=1，随后对同一 line 的访问可能看见尚未全部更新的
Data/Predecode 行。当前 RTL 先清所选 way 的 valid；只有 WFD4 的有效数据 beat
才产生 `last=1` 并写入 ptag+valid。若中途发生传输错误，状态机会转 INV_WFD，
不会出现 last 写，因此该替换 way 保持无效。

在没有并发 invalidation/复位写干扰、四个 beat 都有效并被 SRAM 接受的正常路径
中，这一两阶段提交使 line 只在完整写入后可命中。它是 cache-line refill 的
“先隐藏、后发布”机制，而不是四个 data 行各自拥有独立 valid。

### 6.3 物理 Tag 构建

```verilog
// 行 501
assign l1_refill_icache_if_ptag[27:0] = physical_pc[PC_WIDTH-2:11];
```

I-Cache 是 VIPT（Virtual Index, Physical Tag）结构。这里的 `physical_pc` 是省略架构 `PA[0]` 的半字地址，所以内部 `[38:11]` 对应架构物理字节地址 `[39:12]`。这 28 位写入 Tag Array；不能把 RTL `[38:11]` 直接标成架构 PA `[38:11]`。

### 6.4 Index 地址递增

正常 line refill 每消费一个 128-bit data/error 返回事件，内部半字地址的
`[4:3]` 加 1，并将 `[2:0]` 清零。内部 `[4:3]` 对应架构字节地址 `[5:4]`，
所以该操作让地址前进一个 16-byte block；这里按返回事件推进，发生
`trans_err` 时也需要维持后续 WRAP beat 的地址位置：

```verilog
// 行 509-511（physical_pc 递增）
else if(index_inc_vld)
    physical_pc[PC_WIDTH-2:0] <= {physical_pc[PC_WIDTH-2:5],
                                  physical_pc[4:3] + 2'b1, 3'b0};
```

`index_inc_vld` 在 WFD1/2/3 收到 data 或 error 响应时触发；WFD1 还要求
`tsize=1`，三个状态都要求 `!icache_inv_busy`。低两位 block 编号 mod-4 递增，
所以既支持顺序起点，也支持 WRAP 起点：

```verilog
// 行 536-554
assign index_inc_vld = (refill_cur_state == WFD1) && !icache_inv_busy && (data_vld || trans_err) && tsize
                    || (refill_cur_state == WFD2) && !icache_inv_busy && (data_vld || trans_err)
                    || (refill_cur_state == WFD3) && !icache_inv_busy && (data_vld || trans_err);
```

`icache_inv_busy=1` 时该表达式抑制地址递增。注意 FSM 的 WFD2/3 转移本身并未
同时检查 `icache_inv_busy`；正确理解是 invalidation/refill 的上层互斥应避免
在这些状态收到正常 beat，而不是由本地计数器自动“等待后重放”。分析异常波形时
应同时核对 IFCTRL invalidation 状态和 IPB ready/data。

### 6.5 预解码信息写入

```verilog
// 行 589-598
ct_ifu_precode  x_ct_ifu_precode (
  .inst_data (ipb_l1_refill_data_aft_v2trans),
  .pre_code  (pre_code_info)
);
assign l1_refill_icache_if_pre_code[31:0] = pre_code_info[31:0];
```

每个返回 beat 经 lane 重排后同时送入 `ct_ifu_precode`；对应 32 位 precode 与
128 位数据使用同一个 refill write 条件和地址写入 Predecode/Data Array。命中
时可从并行数组取得已经保存的边界/直接分支候选信息。RTL 连接能证明数据与
precode 同粒度写入，但“节省固定一拍”或具体关键路径收益仍需流水级定义与 STA
支持，不能仅凭该实例化断言。

---

## 7. Invalidation 后处理（INV_WFD）

### 7.1 进入 INV_WFD 的条件

有三种情况会触发 INV_WFD 路径：

1. **REQ 状态收到 change_flow 同时 grant 到来**（`change_flow && refill_grnt`）→ 直接进 INV_WFD1
2. **WFD1 状态收到 change_flow**（流水线方向已改变，这块数据不需要了）→ 进 INV_WFD1
3. **WFD1/2/3 收到 trans_err**（传输出错）→ 进 INV_WFD2/3/4（把剩余包接完）

WFD1 的优先级是 `data_vld > trans_err > change_flow > ins_inv`。例如 data_vld 与
change_flow 同拍时，首 beat 仍按正常路径写入并转 WFD2，不会进入 INV_WFD1；
分析波形不能只看 change_flow 为高，还必须看同拍更高优先级条件。

### 7.2 INV_WFD 期间的行为

```verilog
// 行 574-576（写使能条件）
assign l1_refill_icache_if_wr = refill_cur_state[2] && // 只有 WFDn（bit[2]=1）才写
                                ipb_l1_refill_data_vld && tsize;
```

INV_WFD 的 bit[2]=0，因此 `l1_refill_icache_if_wr=0`，数据被静默接收但不写入 I-Cache。

### 7.3 `inv_wfd_back` 标志

```verilog
// 行 461-463
assign inv_wfd_back_record = ifctrl_l1_refill_ins_inv &&
                             (refill_cur_state == INV_WFD1 || refill_cur_state == WFD1);
```

当 IFCTRL 已接受的 instruction-cache invalidation 在 WFD1 或 INV_WFD1 期间
到来时，`inv_wfd_back` 记录“invalidation 完成后仍需回到 INV_WFD1 排空原事务”。
CTC_INV 只有在 `ins_inv_dn && inv_wfd_back` 时才跳回 INV_WFD1。这里不能仅凭
接口名把请求限定为 ISA `FENCE.I`：上游 IFCTRL 还接收 LSU 发起的 line/all
cache-control invalidation。

---

## 8. 与 ifctrl 的协调

### 8.1 Stall 机制（refill_on）

```verilog
// 行 606-608
assign refill_sm_on = (refill_cur_state == REQ)     ||
                      (refill_cur_state == CTC_INV) ||
                       refill_cur_state[2];  // WFDn
```

```verilog
// 行 614
assign l1_refill_ifctrl_refill_on = refill_sm_on;
```

状态机处于 REQ、WFDn 或 CTC_INV 时向 IFCTRL 报告 `refill_on=1`。IFCTRL 将它
并入 `icache_refill_on` 以及取指 valid/stall、invalidation 仲裁等逻辑。最终某拍
是否发 I-Cache 请求还受 pcgen、IPCTRL 和 cancel 条件控制，因此不应把这一根线
单独解释为“无条件停止整个 IFU”。

**IDLE 和 INV_WFD 系列不在 refill_on 范围内**：INV_WFD 数据不会写 cache，
状态机允许前端不再因这笔 refill 的正常服务路径而停住；实际能否继续取指仍取决于
触发改流本身和其他 stall。特别是另一个输出

```verilog
refill_sm_busy = (refill_cur_state != IDLE);
l1_refill_ipctrl_busy = refill_sm_busy;
```

在 INV_WFD 中仍为 1，所以 IPCTRL 不能发起下一笔 refill。前端可以继续执行新
路径上的 I-Cache hit，却不能在旧 burst 尚未排空时并行建立第二笔 demand refill。
这揭示了当前结构的资源上限：本模块只有一个 demand-refill 上下文，没有 MSHR
式多 miss 并发能力。

在正常 WFDn 中，`refill_on=1` 也不等于每拍都 stall。IFCTRL 的条件是：

```verilog
stall =
    refill_on && !(trans_cmplt && refill_pc_hit);
```

当前返回 beat 与 IF PC 的 16B block 匹配时，旁路可以暂时解除 stall；等待下一
beat 或 PC 指向尚未返回 block 时又会停住。性能上应分别观察“REQ 等首响应”
和“WFD beat 间空隙”，而不是把整段 refill_on 都归成同一种停顿原因。

### 8.2 Idle 通知

```verilog
// 行 653
assign l1_refill_ifctrl_idle = (refill_cur_state[3:0] == IDLE);
```

该输出是当前状态的组合译码；状态寄存器在时钟边沿写成 IDLE 后，`idle` 为 1。
它只是 IFCTRL 判断条件之一，不等于所有其他 stall 同时解除。

### 8.3 Reissue 机制

```verilog
// 行 644-650
assign l1_refill_ifctrl_reissue =
    (refill_cur_state == WFD1) && ipb_refill_data_vld && !tsize ||  // 单包完成
    (refill_cur_state == WFD4) && ipb_refill_data_vld ||              // 4包全部完成
    (refill_cur_state[2]) && ipb_l1_refill_trans_err;                 // 出错
```

WFD4 正常 data beat、WFD1 单 beat data 或 WFDn error 会组合产生
`l1_refill_ifctrl_reissue`。IFCTRL 在自己的 `ifctrl_reissue_clk` 上将其锁存为
`ifctrl_pcgen_reissue_pcload`；PCGEN 看到该寄存信号时选择当前保持的 `if_pc`
作为重装地址，并令 `inc_pc` 不前进。正常四 beat 情形中，最后 data/predecode
行和 tag valid 在 refill 写边沿提交，随后重发才重新访问 I-Cache。

因此 reissue 的作用是“让未推进的 IF PC 再走一次取指访问”，不是
`l1_refill` 直接把 `virtual_pc` 当作新 PC 送给 pcgen。正常、无冲突时重访应命中；
传输错误时则携带/传播访问错误路径，不能宣称必然命中。固定节省多少周期还取决于
IFCTRL/PCGEN 的边沿关系和存储宏读时序。

末拍 reissue 也不表示 miss 后第一条有用指令只能等到 WFD4：前面的 WFDn
refill bypass 已经可能逐块向 IFDP 供给指令。reissue 解决的是 line 发布边界和
当前 PC 的普通 I-Cache 访问衔接问题，early restart 解决的是首个有用 block 的
等待时间，两者属于同一 miss 恢复流程的不同阶段。

注释中对三种 reissue 场景有详细说明（行 622-643）：
1. 正常完成：WFD4 data_vld 或 WFD1（单包）data_vld
2. 传输错误：WFDn trans_err，根据 if_pc 是否命中 refill_pc 决定是否有意义
3. INV_WFD：`refill_cur_state[2]=0`，本模块根本不产生 error reissue；流水线已
   改道，排空返回不再作为当前 IF 数据

### 8.4 CTC cache-control 状态通知

```verilog
// 行 655
assign l1_refill_ifctrl_ctc = (refill_cur_state[3:0] == CTC_INV);
```

CTC_INV 期间，该信号允许 IFCTRL 在一般 `icache_refill_on` 仍为 1 时接受 LSU
发起的 I-Cache line/all invalidation，并使相关 loop-buffer invalidation 路径
得到协调；同时 L1-refill 侧通过 `l1_refill_ipb_ctc_inv` 暂停 IPB 返回。它不是
“cache-through 模式”指示，也不是一个泛化的流水线 flush 信号。

---

## 9. 接口到 IPB 的完整逻辑

### 9.1 req 与 refill_on 的区别

```verilog
// 行 752
assign l1_refill_ipb_req = (refill_cur_state == REQ);

// 行 769-770
assign l1_refill_ipb_refill_on = (refill_cur_state == REQ) && !change_flow;

assign l1_refill_ipb_req_pre =
    (refill_cur_state == IDLE && refill_start_for_gateclk) ||
    (refill_cur_state == REQ && !change_flow && !refill_grnt &&
     !ifctrl_l1_refill_ins_inv);

assign l1_refill_ipb_req_for_gateclk =
    (refill_cur_state == IDLE && refill_start_for_gateclk) ||
    (refill_cur_state == REQ && !ifctrl_l1_refill_ins_inv);
```

- `ipb_req`：只要在 REQ 状态就拉高，是 IPB refill 请求状态机及 BIU 请求形成的
  基本请求条件。
- `ipb_refill_on`：只在 `REQ && !change_flow` 时拉高。IPB 将它别名为
  `ref_for_pref_on`，并用作 `pref_launch_vld` 的条件之一：只有 refill 仍属于
  当前控制流，BIU refill grant 后才允许顺带启动下一 line 的预取。该信号撤销
  不等于它自身直接取消 BIU 请求；请求取消/排空还由 L1-refill 与 IPB 两侧状态机、
  grant 和 change-flow 共同决定。
- `ipb_req_pre`：反映“请求应继续保持”的组合判断。IPB 用它更新内部 `req_gate`，
  其 REQ 分支明确排除了 change-flow、grant 和 instruction invalidation。
- `ipb_req_for_gateclk`：覆盖范围故意更宽，REQ 中只排除 instruction
  invalidation。IPB 把它用于请求门控时钟的变化检测，不把它直接当成
  `ifu_biu_rd_req`。因此 grant 或 change-flow 同拍时，它仍可能为 1。

IPB 真正对 BIU 的 demand-refill 请求最终由
`l1_refill_ipb_req && (pref_idle || !ref_hit_pref)` 形成，还要与预取请求仲裁并受
`cp0_yy_clk_en` 约束。`req_pre`、`req_for_gateclk`、`req` 和 `refill_on` 是四种
不同语义，不能在波形中任选一根都称为“总线请求有效”。

### 9.2 `pre_cancel` 信号

```verilog
// 行 762-763
assign l1_refill_ipb_pre_cancel = pcgen_l1_refill_chgflw ||
                                  ifctrl_l1_refill_inv_busy;
```

尽管名称含 `pre_cancel`，当前 IPB RTL 只用它屏蔽已寄存的
`ipb_icache_if_req`，即取消 IPB 对 I-Cache 的预取 tag 查询请求。BIU 读请求的
状态转移另由 `l1_refill_ipb_req/refill_on`、grant 和 IPB FSM 处理；不能由这根
线推导“提前一拍撤回总线请求”或量化 latency 收益。

### 9.3 地址传递

```verilog
// 行 759-760
assign l1_refill_ipb_ppc[39:0] = {physical_pc[PC_WIDTH-2:0], 1'b0};
assign l1_refill_ipb_vpc[39:0] = {virtual_pc[PC_WIDTH-2:0], 1'b0};
```

低 1 位补 0 是因为 `physical_pc/virtual_pc` 存储的是半字（2 字节）地址，即架构地址 `[39:1]`；传给 IPB 时恢复成完整字节地址 `[39:0]`。

---

## 10. 性能计数器接口

```verilog
// 行 784-785
assign ifu_hpcp_icache_miss_pre =
    (refill_cur_state == WFD1) &&
    (ipb_refill_data_vld || ipb_refill_trans_err);
```

该事件在**正常 WFD1** 收到首个 data 或 error 响应时拉高。REQ 中被
change-flow 取消、或已转入 INV_WFD1 的事务不计；传输错误却会计。因此它更准确
地表示“未在首 beat 前取消的 demand refill 首响应”，通常可作为 I-Cache miss
事件，但不等于成功填充数，也不等于所有原始 `miss_req` 脉冲数。

该 raw 事件还要经过 `ct_ifu_icache_if` 的 HPCP 寄存器：

```verilog
if (cp0_ifu_icache_en && hpcp_ifu_cnt_en)
    ifu_hpcp_icache_miss_reg <= ifu_hpcp_icache_miss_pre;

ifu_hpcp_icache_miss = ifu_hpcp_icache_miss_reg;
```

所以送到 PMU 的 `ifu_hpcp_icache_miss` 相对这里的 `_pre` 多一个寄存边界，并受
I-Cache enable 和 HPCP 计数使能控制。由于 `_pre` 在首响应时产生，它不能直接
测出 miss 服务时延；要量化 latency，应从 `refill_start` 或 REQ 首周期开始，
统计到 WFD1 首响应、critical block 可用以及 WFD4 line 发布的多个距离。

---

## 11. 调试接口

```verilog
// 行 788
assign l1_refill_debug_refill_st[3:0] = refill_cur_state[3:0];
```

该输出直接反映四位状态寄存器，适合在 RTL 波形或 SoC 已连接的调试通路中观察。
本模块本身没有证明该信号一定接入 JTAG 或片上逻辑分析仪，具体可见性取决于顶层
集成和综合保留。

---

## 12. 完整处理流程时序示例

以一次正常的 I-Cache miss 为例，`tsize=1`（4-beat 传输）：

```
周期  状态      信号
----  -----     -----
T0    IDLE      ipctrl_l1_refill_miss_req=1 → refill_start=1
T1    REQ       l1_refill_ipb_req=1（向 IPB 发请求）
T2    REQ       等待 grant...
T3    REQ       ipb_l1_refill_grnt=1 → 下一拍进 WFD1
T4    WFD1      等待第 1 个返回 beat...
T5    WFD1      critical block 有效；旁路给匹配的 IF PC，同时写对应 16B 块
                first=1，所选 way valid=0；前端可能提前继续
T6    WFD2      等待第 2 个返回 beat...
T7    WFD2      第 2 beat 有效；按 WRAP 顺序写下一 16B 块，也可服务匹配的 IF PC
T8    WFD3      等待第 3 个返回 beat...
T9    WFD3      第 3 beat 有效；按 WRAP 顺序写下一 16B 块
T10   WFD4      等待第 4 个返回 beat...
T11   WFD4      最后 beat 有效；写最后 16B 块（last=1，写 ptag+valid 并翻转 FIFO）
               l1_refill_ifctrl_reissue=1
T12   IDLE      refill_on=0, idle=1；IFCTRL 已寄存 reissue 请求
后续边沿          PCGEN 保持/重装当前 if_pc，并重新发起 I-Cache 访问
```

周期编号只是展示“状态可等待多个周期”，不是固定 miss latency。grant 和每个
data beat 均可晚到；IFCTRL、PCGEN 与 SRAM wrapper 的寄存边沿也应结合波形读取。
正常路径最终重访通常命中新 line，但更高优先级改流、invalidation 或错误可覆盖它。
若 T5 的 `refill_pc_hit=1`，首个有用指令窗口可能在 T5 就经旁路进入 IFDP；
T11/T12 描述的是整条 line 发布与普通 I-Cache 访问衔接，而不是首次恢复供给的
唯一时刻。

如果在 WFD1 **首 beat 到来之前** `pcgen_l1_refill_chgflw=1`，例如：

```
周期  状态       信号
----  ------     -----
T5    WFD1       chgflw=1 → 下一拍进 INV_WFD1
T6    INV_WFD1   等待第 1 个返回 beat（事务已获 grant，需要按 FSM 排空）
T7    INV_WFD1   ipb_l1_refill_data_vld=1，不写 Cache（wr=0）
T8    INV_WFD2   等待第 2 个返回 beat...
...   ...
T11   INV_WFD4   最后一个返回 beat 消费完毕 → 回 IDLE
T12   IDLE       ifctrl 从 chgflw 后的新 PC 取指（与 refill 无关）
```

若 change_flow 在首 beat 已于 WFD1 正常接收、状态进入 WFD2 之后到来，当前 RTL
不会转 INV_WFD；它继续填完 line。这个差异是观察波形时判断“过期事务被排空”还是
“已启动 line 继续完成”的关键。

---

## 13. 波形观察与性能归因

### 13.1 一次 demand miss 的因果链

建议至少同时观察以下信号组：

```text
请求形成：
  ipctrl_l1_refill_miss_req
  ipctrl_l1_refill_req_for_gateclk
  ifctrl_l1_refill_inv_on
  refill_start
  refill_cur_state

请求与返回：
  l1_refill_ipb_req
  l1_refill_ipb_req_pre
  l1_refill_ipb_refill_on
  ipb_l1_refill_grnt
  ipb_l1_refill_data_vld
  ipb_l1_refill_trans_err
  tsize

地址与旁路：
  physical_pc
  virtual_pc
  l1_refill_ifctrl_trans_cmplt
  refill_pc_hit                    // 位于 ct_ifu_ifctrl
  l1_refill_ifdp_tag_data
  l1_refill_ifdp_acc_err
  ifctrl_ifdp_pipedown

缓存提交：
  l1_refill_icache_if_wr
  l1_refill_icache_if_first
  l1_refill_icache_if_last
  l1_refill_icache_if_fifo
  l1_refill_icache_if_index
  l1_refill_icache_if_ptag

恢复与废弃：
  pcgen_l1_refill_chgflw
  l1_refill_ifctrl_reissue
  l1_refill_ifctrl_refill_on
  l1_refill_ipctrl_busy
  ifctrl_l1_refill_ins_inv
  ifctrl_l1_refill_ins_inv_dn
  inv_wfd_back
```

按 `miss_req -> REQ -> grant -> WFD1 首响应 -> WFD4 last -> reissue` 逐段追踪。
若发生改流，则从 `change_flow` 追到 `INV_WFD1`；若发生 cache-control
invalidation，则追到 `CTC_INV -> INV_WFD1`。只观察 `data_vld` 无法判断该 beat
是在正常写入、异常传播还是废弃排空。

### 13.2 把 miss 延迟拆开

| 区间 | 波形定义 | 主要含义 |
|------|----------|----------|
| 请求建立 | `refill_start` 到进入 REQ | 本模块启动边界，通常是一拍状态转换 |
| grant 等待 | REQ 首周期到 `ipb_l1_refill_grnt` | IPB/prefetch-buffer/BIU 接受延迟 |
| 首响应等待 | 进入 WFD1 到首个 data/error | demand first-response latency |
| 首个有用数据 | `refill_start` 到 WFD1 `data_vld && refill_pc_hit` | critical-block 可被前端消费的等待 |
| burst 间隙 | WFD2/3/4 各状态内等待 data/error 的周期 | 后续 beat 返回节奏与互连停顿 |
| line 完成 | `refill_start` 到 WFD4 正常 data | 整条 64B line 发布延迟 |
| 废弃占用 | INV_WFD1 到 INV_WFD4/IDLE | 错路径事务继续占用唯一 refill 上下文的时间 |
| CTC 干扰 | CTC_INV 驻留周期 | invalidation 对返回接收的暂停时间 |

这些区间回答的是不同问题。前端 IPC 更直接受“首个有用数据”和后续所需 block
是否及时旁路影响；I-Cache 容量状态何时恢复取决于 line 完成；下一笔 miss 能否
启动还取决于包括 INV_WFD 在内的 `busy` 时间。只报告平均 miss penalty 会把
三种机制混在一起。

### 13.3 可直接检查的 RTL 关系

```text
refill_on = REQ || CTC_INV || normal_WFD
busy      = state != IDLE
refill_on -> busy
busy - refill_on = INV_WFD 系列

icache_wr    = normal_WFD && data_vld && tsize
icache_first = WFD1 && data_vld && tsize
icache_last  = WFD4 && data_vld

ifdp_tag_valid = normal_WFD && data_vld
ifdp_acc_err   = normal_WFD && trans_err

INV_WFD -> !icache_wr
CTC_INV -> l1_refill_ipb_ctc_inv -> !ifu_biu_r_ready
```

在可达状态下 WFD4 只来自 `tsize=1` 的 line 请求，因此 `icache_last` 也应伴随
`icache_wr`。若波形违反这一点，应检查 `tsize` 锁存、状态跳转或 X 传播。类似地，
`INV_WFD && icache_wr`、`CTC_INV && ifu_biu_r_ready` 都与当前 RTL 定义矛盾，
适合作为断言或离线波形检查条件。

从体系结构角度看，该模块的核心取舍是：用 WRAP+critical-block bypass 缩短首用
延迟，用首拍清 valid/末拍提交保证 line 原子可见，同时只维护一个 demand refill
上下文来控制复杂度。其潜在性能限制也由此产生：长首响应会直接停前端，beat
间隙会造成间歇供给，错误路径 INV_WFD 会阻塞下一笔 miss，而没有多 MSHR 去隐藏
这些等待。后续若优化 IFU 存储层次，应先用上述分段指标确认主要损失落在哪一段，
再决定增强预取、优化下层延迟、增加返回缓冲，还是引入更多 miss 并发。
