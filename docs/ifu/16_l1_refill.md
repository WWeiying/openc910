# ct_ifu_l1_refill 模块详解

## 1. 模块概述

### 1.1 I-Cache Miss 的完整处理流程

当 C910 IFU 的 IP 级（Instruction Pre-decode）访问 I-Cache 未命中时，需要从 L2 Cache 或 BIU（Bus Interface Unit）重新取回数据，写入 I-Cache，然后重试取指。这一过程称为 **L1 I-Cache Refill（重填）**，由 `ct_ifu_l1_refill` 模块全权负责。

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
IPB（Instruction Pre-fetch Buffer）向 BIU/L2 发出总线请求
       │
       ▼
BIU/L2 返回 grant，随后分 4 包传回 128 位×4 = 512 位 cache line 数据
       │
       ▼
l1_refill 依次接收 WFD1→WFD2→WFD3→WFD4，每包写入 I-Cache
       │
       ▼
写入完成后（WFD4 done）→ 回到 IDLE，通知 ifctrl reissue（重取指）
       │
       ▼
PC 对应 cache line 现在已在 I-Cache，命中，正常取指继续
```

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

**IPB（Instruction Pre-fetch Buffer）** 是 IFU 与 BIU/L2 之间的缓冲，l1_refill 通过 IPB 而非直接访问总线。IPB 处理总线握手、数据对齐等细节，向 l1_refill 呈现干净的 `grnt` / `data_vld` / `rdata` 接口。

---

## 2. 端口说明

### 2.1 来自 ipctrl 的输入

| 信号名 | 含义 |
|--------|------|
| `ipctrl_l1_refill_miss_req` | IP 级检测到 miss，请求 refill 开始 |
| `ipctrl_l1_refill_req_for_gateclk` | miss_req 的提前版本，用于门控时钟使能 |
| `ipctrl_l1_refill_ppc[38:0]` | miss 指令的物理 PC（写 tag array 用） |
| `ipctrl_l1_refill_vpc[38:0]` | miss 指令的虚拟 PC（写 index / ifctrl pc 用） |
| `ipctrl_l1_refill_chk_err` | 地址检查错误标志 |
| `ipctrl_l1_refill_fifo` | 是否使用 FIFO 模式（cache through 情况） |

### 2.2 来自 ifdp 的输入（访存属性）

| 信号名 | 含义 |
|--------|------|
| `ifdp_l1_refill_cacheable` | 地址是否 cacheable |
| `ifdp_l1_refill_bufferable` | 地址是否 bufferable |
| `ifdp_l1_refill_tsize` | Transfer size：1 = 512 位（4×128）标准 cache line，0 = 128 位单包 |
| `ifdp_l1_refill_supv_mode` | Supervisor 模式 |
| `ifdp_l1_refill_machine_mode` | Machine 模式 |
| `ifdp_l1_refill_secure` | 安全世界访问 |
| `ifdp_l1_refill_fifo` | FIFO 属性 |

### 2.3 来自 IPB 的输入（数据返回接口）

| 信号名 | 含义 |
|--------|------|
| `ipb_l1_refill_grnt` | BIU/L2 批准传输请求 |
| `ipb_l1_refill_data_vld` | 当前有一包 128 位数据有效 |
| `ipb_l1_refill_rdata[127:0]` | 128 位原始数据 |
| `ipb_l1_refill_trans_err` | 总线传输错误 |

### 2.4 来自 ifctrl 的输入

| 信号名 | 含义 |
|--------|------|
| `ifctrl_l1_refill_ins_inv` | 需要做 instruction invalidation（软件 fence.i 等） |
| `ifctrl_l1_refill_ins_inv_dn` | instruction invalidation 已完成 |
| `ifctrl_l1_refill_inv_busy` | I-Cache invalidation 正在进行，不能开始新 refill |
| `ifctrl_l1_refill_inv_on` | invalidation 进行中，屏蔽新 refill 请求 |

### 2.5 来自 pcgen 的输入

| 信号名 | 含义 |
|--------|------|
| `pcgen_l1_refill_chgflw` | 流水线发生了方向改变（chgflw），refill 地址已过期 |

### 2.6 送往 icache_if 的输出

| 信号名 | 含义 |
|--------|------|
| `l1_refill_icache_if_wr` | 当前周期向 I-Cache 写入数据 |
| `l1_refill_icache_if_first` | 这是 cache line 的第一包（写 tag 但 valid=0） |
| `l1_refill_icache_if_last` | 这是 cache line 的最后一包（写 tag valid=1） |
| `l1_refill_icache_if_index[38:0]` | I-Cache index（来自虚拟 PC） |
| `l1_refill_icache_if_ptag[27:0]` | I-Cache 物理 tag（内部 PC `[38:11]`，对应架构 PA `[39:12]`） |
| `l1_refill_icache_if_inst_data[127:0]` | 经字节序转换后的 128 位指令数据 |
| `l1_refill_icache_if_pre_code[31:0]` | 预解码信息（同时写入 predecode array） |
| `l1_refill_icache_if_fifo` | cache through FIFO 属性 |

### 2.7 送往 ifctrl 的输出

| 信号名 | 含义 |
|--------|------|
| `l1_refill_ifctrl_refill_on` | refill 状态机正在运行，通知 ifctrl stall 取指 |
| `l1_refill_ifctrl_idle` | refill 状态机空闲（回到 IDLE） |
| `l1_refill_ifctrl_reissue` | refill 完成，请求 ifctrl 触发 reissue |
| `l1_refill_ifctrl_ctc` | 处于 CTC_INV 状态（Cache Through 后处理） |
| `l1_refill_ifctrl_trans_cmplt` | 本包传输完成（供 ifctrl 判断数据有效） |
| `l1_refill_ifctrl_pc[38:0]` | refill 当前处理的 PC（虚拟地址） |
| `l1_refill_ifctrl_start` | refill 开始 |

### 2.8 送往 ifdp 的输出（旁路数据）

| 信号名 | 含义 |
|--------|------|
| `l1_refill_ifdp_refill_on` | 通知 IF data path：此时指令数据来自 refill 路径而非 I-Cache |
| `l1_refill_ifdp_inst_data[127:0]` | 从 IPB 拿到的最新 128 位数据（旁路给 IF stage） |
| `l1_refill_ifdp_precode[31:0]` | 对应的预解码信息 |
| `l1_refill_ifdp_tag_data[28:0]` | {valid, ptag[27:0]}，IF stage 判断 tag 匹配用 |
| `l1_refill_ifdp_acc_err` | 访存错误标志 |

---

## 3. 状态机（核心）

### 3.1 状态定义

```verilog
// 行 269-280
parameter IDLE     = 4'b0000;  // 空闲，等待 miss 请求
parameter REQ      = 4'b0001;  // 已提交请求，等待 grant 或 chgflw
parameter WFD1     = 4'b0100;  // 等待第 1 包数据（正常接收）
parameter WFD2     = 4'b0101;  // 等待第 2 包数据
parameter WFD3     = 4'b0110;  // 等待第 3 包数据
parameter WFD4     = 4'b0111;  // 等待第 4 包数据
parameter INV_WFD1 = 4'b1000;  // 等待第 1 包数据（接收后丢弃/inv）
parameter INV_WFD2 = 4'b1001;  // 等待第 2 包数据（接收后丢弃）
parameter INV_WFD3 = 4'b1010;  // 等待第 3 包数据（接收后丢弃）
parameter INV_WFD4 = 4'b1011;  // 等待第 4 包数据（接收后丢弃）
parameter CTC_INV  = 4'b0011;  // Cache Through 完成后的 invalidation
```

注意编码规律：
- `bit[2]=1` 表示处于 WFDn 系列（正常接收），即 WFD1/2/3/4。
- `bit[3]=1` 表示处于 INV_WFDn 系列（接收但丢弃）。
- 这使得 `refill_cur_state[2]` 可作为"是否在正常写入状态"的快速判断条件。

### 3.2 完整状态转移图

```
                   ┌──────────────────────────────────────┐
                   │ refill_start && !ifctrl_inv_on       │
                   ▼                                      │
               ┌───────┐                             ┌───────┐
          ┌───>│ IDLE  │<────────────────────────────│  REQ  │<──────────────────┐
          │    └───────┘  change_flow && !grnt        └───────┘                  │
          │        │      (BIU 还没 grant，直接撤单)       │  │                   │
          │        │                                       │  │change_flow && grnt│
          │        │                                       │  └──────────┐        │
          │        │                        !change_flow && grnt         │        │
          │        │                                       │             ▼        │
          │        │                                   ┌───────┐   ┌──────────┐  │
          │        │                                   │ WFD1  │   │ INV_WFD1 │  │
          │        │                                   └───────┘   └──────────┘  │
          │        │                           data_vld     │           │         │
          │        │                            && tsize    ▼  data_vld│(tsize)  │
          │        │                                   ┌───────┐       ▼         │
          │        │                                   │ WFD2  │   ┌──────────┐  │
          │        │                                   └───────┘   │ INV_WFD2 │  │
          │        │                           data_vld     │      └──────────┘  │
          │        │                                        ▼  data_vld          │
          │        │                                   ┌───────┐       ▼         │
          │        │                                   │ WFD3  │   ┌──────────┐  │
          │        │                                   └───────┘   │ INV_WFD3 │  │
          │        │                           data_vld     │      └──────────┘  │
          │        │                                        ▼  data_vld          │
          │        │                                   ┌───────┐       ▼         │
          │        │    WFD4: data_vld / trans_err     │ WFD4  │   ┌──────────┐  │
          └────────┼───────────────────────────────────│       │   │ INV_WFD4 │  │
                   │                                   └───────┘   └──────────┘  │
                   │                                                     │ data_vld│
                   └─────────────────────────────────────────────────────┘        │
                                                                                   │
               ┌──────────────────────────────────────────────────────────────────┘
               │  ins_inv_dn && inv_wfd_back
               ▼
          ┌─────────┐
          │ CTC_INV │──────────────> (等待 ins_inv_dn && inv_wfd_back → INV_WFD1)
          └─────────┘
```

注：WFD1/WFD2/WFD3 各自在收到 `change_flow` 时也可跳转到对应的 INV_WFD 状态（见详细条件分析）。

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

如果正在做 instruction invalidation（`inv_on`），则新的 refill 请求被屏蔽，等 inv 完成后才允许。

#### REQ

```verilog
// 行 348-357
REQ : if(change_flow && !refill_grnt)
      refill_next_state = IDLE;     // 还没 grant，chgflw 来了，直接取消
      else if(!change_flow && refill_grnt)
      refill_next_state = WFD1;     // 正常：grant 来了，开始等数据
      else if(change_flow && refill_grnt)
      refill_next_state = INV_WFD1; // 同时来：接收数据但最终 inv
      else if(ifctrl_l1_refill_ins_inv)
      refill_next_state = IDLE;     // fence.i：取消请求回 IDLE
      else
      refill_next_state = REQ;
```

关键设计：
- **chgflw 先于 grant**：说明 BIU 还没有开始传输，可以直接撤回请求（向 IPB 拉低 req），BIU 忽略这笔请求，状态机回 IDLE。
- **grant 先于 chgflw** / **同时到来**：BIU 已经承诺开始传输，无法中途取消。如果同时收到 chgflw，必须进入 INV_WFD1 继续接收，最后不写入 cache 或清除 valid。

#### WFD1～WFD4（正常接收，以 WFD1 为例）

```verilog
// 行 388-407
WFD1 : if(ipb_refill_data_vld)
       begin
         if(tsize)
         refill_next_state = WFD2;     // 4 包传输，继续等第 2 包
         else
         refill_next_state = IDLE;     // 单包传输（128 位），完成
       end
       else if(ipb_refill_trans_err)
       begin
         if(tsize)
         refill_next_state = INV_WFD2; // 第 1 包出错，后续 3 包仍需接收（但最终 inv）
         else
         refill_next_state = IDLE;
       end
       else if(change_flow)
       refill_next_state = INV_WFD1;   // 在等待第 1 包时收到 chgflw
       else if(ifctrl_l1_refill_ins_inv)
       refill_next_state = CTC_INV;    // fence.i 请求
       else
       refill_next_state = WFD1;
```

WFD2/WFD3 的逻辑类似但更简单：只有 data_vld、trans_err 两个出口（WFD2/3 不再响应 change_flow，因为已经在接收数据）：

```verilog
// 行 408-419
WFD2 : if(ipb_refill_data_vld) refill_next_state = WFD3;
       else if(ipb_refill_trans_err) refill_next_state = INV_WFD3;
       else refill_next_state = WFD2;

WFD3 : if(ipb_refill_data_vld) refill_next_state = WFD4;
       else if(ipb_refill_trans_err) refill_next_state = INV_WFD4;
       else refill_next_state = WFD3;
```

WFD4 接收最后一包后直接回 IDLE（不管是 data_vld 还是 trans_err）：

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
              refill_next_state = IDLE; // 单包传输完成
            end
            else if(ifctrl_l1_refill_ins_inv)
            refill_next_state = CTC_INV; // 又来 fence.i？转 CTC_INV
            else
            refill_next_state = INV_WFD1;

INV_WFD2 → INV_WFD3 → INV_WFD4 → IDLE：每收一包就前进一步
```

INV_WFD 系列的行为：**必须把所有包都收完，然后回 IDLE，但不向 I-Cache 写入有效数据（或写 valid=0）。**

#### CTC_INV（Cache Through Invalidation）

```verilog
// 行 426-431
CTC_INV : if(ifctrl_l1_refill_ins_inv_dn && inv_wfd_back)
          refill_next_state = INV_WFD1; // inv 完成 + 有待接收数据，转 INV_WFD1
          else
          refill_next_state = CTC_INV;
```

CTC_INV 是一个等待状态：当 refill 正在进行时收到了 `fence.i` 指令，需要先让 ifctrl 完成 invalidation（清空整个 I-Cache），invalidation 完成后再进入 INV_WFD1 把剩余数据接完（确保总线上的数据被消费），然后回 IDLE。

`inv_wfd_back` 标志记录了"是否有未完成的 WFD/INV_WFD 数据要接收"，防止因为 inv 插队导致数据被遗漏。

### 3.4 为什么不能在 chgflw 时直接丢弃？

这是该状态机设计的核心原因之一：

当 BIU/L2 已经给出 `grant` 信号，意味着数据传输已经在总线上启动。AXI/CHI 协议的特性决定了：
1. 请求方不能单方面取消已被 grant 的传输。
2. BIU 会继续把 4 包数据依次送来，IFU 必须把它们都取走，否则总线状态机会卡死或出错。

因此，即便 chgflw 发生、这些数据不再有用，状态机也必须老老实实地接收完所有数据包（INV_WFD1~4），只是不把它们写入 I-Cache（或最终清除 valid bit）。

---

## 4. Miss 请求发起

### 4.1 进入 REQ 状态

```verilog
// 行 438-439
assign refill_start = ipctrl_l1_refill_miss_req &&
                      !ifctrl_l1_refill_inv_on;
```

`ipctrl_l1_refill_miss_req` 是 IP 级在检测到 I-Cache miss 时给出的请求脉冲。条件 `!ifctrl_l1_refill_inv_on` 保证不在 invalidation 进行期间开始新的 refill（防止 refill 写入的数据又被立即 inv 掉，造成浪费）。

### 4.2 向 IPB 发送请求

```verilog
// 行 752
assign l1_refill_ipb_req = (refill_cur_state[3:0] == REQ);
```

在 REQ 状态期间，持续向 IPB 拉高 req 信号。IPB 内部仲裁后向 BIU 发出总线请求。

同时把本次 refill 的地址属性锁存（tsize/cacheable/bufferable/supv_mode/machine_mode/secure），这些属性在 `miss_req` 时从 ifdp 采样并用寄存器保持：

```verilog
// 行 688-689
else if(ipctrl_l1_refill_miss_req)
    tsize <= ifdp_l1_refill_tsize;
```

### 4.3 `tsize`：传输大小的关键标志

`tsize = 1` 表示这是一次完整的 cache line 填充（512 位，4 包×128 位）。
`tsize = 0` 表示单包传输（128 位，仅适用于 non-cacheable / cache-through 地址）。

整个状态机中 `tsize` 无处不在——它决定了在 WFD1 接收第一包数据后是继续等第 2 包还是直接完成。

---

## 5. 数据接收（WFD1~WFD4）

### 5.1 每包 128 位，共 4 包

```
cache line = 512 位 = 4 × 128 位
WFD1 接收 ipb_l1_refill_rdata[127:0]  → cache line [127:0]
WFD2 接收 ipb_l1_refill_rdata[127:0]  → cache line [255:128]
WFD3 接收 ipb_l1_refill_rdata[127:0]  → cache line [383:256]
WFD4 接收 ipb_l1_refill_rdata[127:0]  → cache line [511:384]
```

### 5.2 字节序转换

来自 AXI/BIU 的数据是大端（big-endian）格式，RISC-V 是小端。l1_refill 做了字节对的交换：

```verilog
// 行 473-498
assign ipb_l1_refill_data_aft_v2trans[127:0] = {
    {byte1[7:0],  byte0[7:0]},    // 字节 0/1 交换
    {byte3[7:0],  byte2[7:0]},    // 字节 2/3 交换
    {byte5[7:0],  byte4[7:0]},
    {byte7[7:0],  byte6[7:0]},
    {byte9[7:0],  byte8[7:0]},
    {byte11[7:0], byte10[7:0]},
    {byte13[7:0], byte12[7:0]},
    {byte15[7:0], byte14[7:0]}
};
```

每两个相邻字节互换位置，完成 16 位宽度的字节序反转，使写入 I-Cache 的数据符合小端存储格式。

### 5.3 `ipb_l1_refill_data_vld`：有效信号

每当 IPB 送来一包有效数据时，`ipb_l1_refill_data_vld` 拉高一个周期，状态机前进一步。两包数据之间可能有若干个周期的等待（L2 或 DDR 的访问延迟）。

### 5.4 `ipb_l1_refill_trans_err`：传输错误

如果某包数据出现总线错误，`ipb_refill_trans_err` 拉高。状态机同样前进（把这包"错误数据"视为已消费），但后续转入 INV_WFD 系列（如果还有剩余包），并向 ifdp 报告 `acc_err`：

```verilog
// 行 670-671
assign l1_refill_ifdp_acc_err = refill_cur_state[2] && //WFDn
                                ipb_l1_refill_trans_err;
```

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

`tsize=0` 时也不写（非 cacheable 地址，走 cache-through 路径，不填 cache）。

### 6.2 first/last 信号的含义与 Tag Valid 控制

这是防止"脏命中"的关键机制：

| 信号 | 时序 | 操作 |
|------|------|------|
| `first=1` | WFD1 收到第 1 包时 | 写 Tag Array，但 valid=0（此 cache line 不可命中）|
| 中间包（WFD2/3） | 收到数据时 | 只写 Data Array |
| `last=1` | WFD4 收到第 4 包时 | 写最后一包 Data Array + 把 Tag valid 置 1 |

**为什么这么做？**

如果第 1 包到来时就设 valid=1，那么在 WFD2/3/4 还在传输时，如果 IF 级恰好访问这个 cache line，就会读到部分有效、部分无效的数据，造成错误。

通过 first 时写 valid=0、last 时写 valid=1 的两步操作，保证只有 512 位数据全部写入后，这个 cache line 才对外"可见"。

### 6.3 物理 Tag 构建

```verilog
// 行 501
assign l1_refill_icache_if_ptag[27:0] = physical_pc[PC_WIDTH-2:11];
```

I-Cache 是 VIPT（Virtual Index, Physical Tag）结构。这里的 `physical_pc` 是省略架构 `PA[0]` 的半字地址，所以内部 `[38:11]` 对应架构物理字节地址 `[39:12]`。这 28 位写入 Tag Array；不能把 RTL `[38:11]` 直接标成架构 PA `[38:11]`。

### 6.4 Index 地址递增

每接收一包数据（128 位 = 16 字节），内部半字地址的 `[4:3]` 加 1并将 `[2:0]` 清零。内部 `[4:3]` 对应架构字节地址 `[5:4]`，所以该操作让地址前进一个 16 字节块：

```verilog
// 行 509-511（physical_pc 递增）
else if(index_inc_vld)
    physical_pc[PC_WIDTH-2:0] <= {physical_pc[PC_WIDTH-2:5],
                                  physical_pc[4:3] + 2'b1, 3'b0};
```

`index_inc_vld` 在 WFD1/2/3 各收到一包数据后触发（WFD4 不需要，因为 WFD4 结束后直接回 IDLE）：

```verilog
// 行 536-554
assign index_inc_vld = (refill_cur_state == WFD1) && !icache_inv_busy && (data_vld || trans_err) && tsize
                    || (refill_cur_state == WFD2) && !icache_inv_busy && (data_vld || trans_err)
                    || (refill_cur_state == WFD3) && !icache_inv_busy && (data_vld || trans_err);
```

`icache_inv_busy` 为 1 时暂停递增（I-Cache 正在 invalidation，写操作需要等待）。

### 6.5 预解码信息写入

```verilog
// 行 589-598
ct_ifu_precode  x_ct_ifu_precode (
  .inst_data (ipb_l1_refill_data_aft_v2trans),
  .pre_code  (pre_code_info)
);
assign l1_refill_icache_if_pre_code[31:0] = pre_code_info[31:0];
```

在 refill 过程中，顺手对每包 128 位数据做预解码（识别指令类型、长度等），结果写入 I-Cache 的 Predecode Array。这样下次命中时可以直接使用预解码结果，节省一拍流水线延迟。

---

## 7. Invalidation 后处理（INV_WFD）

### 7.1 进入 INV_WFD 的条件

有三种情况会触发 INV_WFD 路径：

1. **REQ 状态收到 change_flow 同时 grant 到来**（`change_flow && refill_grnt`）→ 直接进 INV_WFD1
2. **WFD1 状态收到 change_flow**（流水线方向已改变，这块数据不需要了）→ 进 INV_WFD1
3. **WFD1/2/3 收到 trans_err**（传输出错）→ 进 INV_WFD2/3/4（把剩余包接完）

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

当 `fence.i` 在 WFD1 或 INV_WFD1 期间到来时，记录 `inv_wfd_back=1`，表示"之后还需要回到 INV_WFD1 继续接收数据"。CTC_INV 状态在 `inv_wfd_back=1` 且 inv 完成时才跳回 INV_WFD1，防止数据漏接。

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

只要状态机处于 REQ、WFDn 或 CTC_INV，就向 ifctrl 报告 `refill_on=1`，ifctrl 随即 stall 取指流水（不驱动 I-Cache 新的访问请求），等待 refill 完成。

**IDLE 和 INV_WFD 系列不在 refill_on 范围内**：INV_WFD 意味着流水线已经因 chgflw 改道，取指可以继续（即便数据还在路上，反正是废数据）。

### 8.2 Idle 通知

```verilog
// 行 653
assign l1_refill_ifctrl_idle = (refill_cur_state[3:0] == IDLE);
```

进入 IDLE 后立即通知 ifctrl，解除 stall。

### 8.3 Reissue 机制

```verilog
// 行 644-650
assign l1_refill_ifctrl_reissue =
    (refill_cur_state == WFD1) && ipb_refill_data_vld && !tsize ||  // 单包完成
    (refill_cur_state == WFD4) && ipb_refill_data_vld ||              // 4包全部完成
    (refill_cur_state[2]) && ipb_l1_refill_trans_err;                 // 出错
```

reissue 的作用：当 WFD4 数据到来（状态机还在 WFD4，下一拍才到 IDLE），pcgen 已经被冻住等着 refill 完成。在 WFD4 收到最后一包时，ifctrl 立刻发 reissue，让 pcgen 在**下一拍**重新取 miss 地址的指令——此时 cache line 已经写完，命中，可以正常取出。

如果不发 reissue，pcgen 还在等 IDLE，浪费一拍。

注释中对三种 reissue 场景有详细说明（行 622-643）：
1. 正常完成：WFD4 data_vld 或 WFD1（单包）data_vld
2. 传输错误：WFDn trans_err，根据 if_pc 是否命中 refill_pc 决定是否有意义
3. INV_WFD：流水线已改道，ifctrl 不会处理这个 reissue

### 8.4 CTC（Cache Through）状态通知

```verilog
// 行 655
assign l1_refill_ifctrl_ctc = (refill_cur_state[3:0] == CTC_INV);
```

CTC_INV 期间通知 ifctrl 有特殊状态在进行，ifctrl 据此决定是否延迟某些操作。

---

## 9. 接口到 IPB 的完整逻辑

### 9.1 req 与 refill_on 的区别

```verilog
// 行 752
assign l1_refill_ipb_req = (refill_cur_state == REQ);

// 行 769-770
assign l1_refill_ipb_refill_on = (refill_cur_state == REQ) && !change_flow;
```

- `ipb_req`：只要在 REQ 状态就拉高，告诉 IPB 要取数。
- `ipb_refill_on`：在 REQ 状态**且没有 chgflw** 才拉高，一旦 chgflw 来临就撤销，让 IPB 知道可以取消这笔请求（如果还没 grant 的话）。

### 9.2 `pre_cancel` 信号

```verilog
// 行 762-763
assign l1_refill_ipb_pre_cancel = pcgen_l1_refill_chgflw ||
                                  ifctrl_l1_refill_inv_busy;
```

提前一拍告知 IPB 可能要取消，让 IPB 有时间提前撤回总线请求（减少总线 latency）。

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

当从 WFD1 收到第一包数据时触发 PMU 事件，用于统计 I-Cache miss 次数。之所以在 WFD1 而不是 REQ/IDLE 时计数，是因为 WFD1 进入第一包数据表示真正开始了一次有效的 refill 传输（REQ 有可能因 chgflw 被取消）。

---

## 11. 调试接口

```verilog
// 行 788
assign l1_refill_debug_refill_st[3:0] = refill_cur_state[3:0];
```

直接把状态寄存器输出到调试口，便于逻辑分析仪或 JTAG 调试时观察 refill 状态。

---

## 12. 完整处理流程时序示例

以一次正常的 I-Cache miss 为例，`tsize=1`（4 包传输）：

```
周期  状态      信号
----  -----     -----
T0    IDLE      ipctrl_l1_refill_miss_req=1 → refill_start=1
T1    REQ       l1_refill_ipb_req=1（向 IPB 发请求）
T2    REQ       等待 grant...
T3    REQ       ipb_l1_refill_grnt=1 → 下一拍进 WFD1
T4    WFD1      等待第 1 包数据...
T5    WFD1      ipb_l1_refill_data_vld=1, 数据写入 Cache（first=1, valid=0）
T6    WFD2      等待第 2 包数据...
T7    WFD2      ipb_l1_refill_data_vld=1, 数据写入 Cache
T8    WFD3      等待第 3 包数据...
T9    WFD3      ipb_l1_refill_data_vld=1, 数据写入 Cache
T10   WFD4      等待第 4 包数据...
T11   WFD4      ipb_l1_refill_data_vld=1, 数据写入 Cache（last=1, valid=1）
               reissue=1 → ifctrl 在 T12 重取指
T12   IDLE      refill_on=0, idle=1
               pcgen 重新取 miss 地址 → I-Cache 命中，正常取指恢复
```

如果在 T5~T10 期间 pcgen_l1_refill_chgflw=1（例如异常/中断），则：

```
周期  状态       信号
----  ------     -----
T5    WFD1       chgflw=1 → 下一拍进 INV_WFD1
T6    INV_WFD1   等待第 1 包（已经发出去了，必须接收）
T7    INV_WFD1   ipb_l1_refill_data_vld=1，不写 Cache（wr=0）
T8    INV_WFD2   等待第 2 包...
...   ...
T11   INV_WFD4   最后一包收完 → 回 IDLE
T12   IDLE       ifctrl 从 chgflw 后的新 PC 取指（与 refill 无关）
```
