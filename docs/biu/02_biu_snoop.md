# C910 BIU 侦听通道 模块详细教学文档

> 本文档解析 BIU 的被侦听端通道：`ct_biu_snoop_channel.v`（563 行，AC+CR+CD）。
> 它把 CIU 侧 AC 请求接入 LSU，再把 LSU 产生的 CR 响应和可选 CD 数据送回 CIU。
> 阅读前建议先看 [00_biu_overview.md](00_biu_overview.md) 第 8 节
> （ACE 主+从双角思想）。

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [AC 通道：把侦听请求转给 LSU SNQ](#4-ac-通道把侦听请求转给-lsu-snq)
5. [CR 通道：把侦听响应吐回总线](#5-cr-通道把侦听响应吐回总线)
6. [CD 通道：把可选 snoop 数据送回 CIU](#6-cd-通道把可选-snoop-数据送回-ciu)
7. [snoop_vld：被侦听时不许熄火](#7-snoop_vld被侦听时不许熄火)
8. [ACE 一致性全景：snoop 在其中的位置](#8-ace-一致性全景snoop-在其中的位置)
9. [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 是什么

snoop_channel 实现 ACE 的三个一致性通道，方向与读写通道**相反**：

```
        CIU（核外，一致性互联）
              │  AC：你有这块地址吗？
              ▼
   ┌──────────────────────────┐
   │   snoop_channel（BIU）    │
   │  AC ──▶ 转给 LSU SNQ      │   biu_lsu_ac_*
   │  CR ◀── LSU 报状态        │   lsu_biu_cr_* → biu_pad_cr*
   │  CD ◀── LSU 给返回数据    │   lsu_biu_cd_* → biu_pad_cd*
   └──────────────────────────┘
              ▲
              │  LSU 查 D-Cache（SNQ = Snoop Queue 侦听队列）
        LSU（核内）
```

- **AC（snoop address）**：CIU → BIU → LSU，携带物理地址、4 位 snoop 类型和 3 位保护属性。
- **CR（snoop response）**：LSU → BIU → CIU，携带 5 位协议响应；BIU 不解码这 5 位。
- **CD（snoop data）**：LSU → BIU → CIU，携带 128 位数据和 `last`。不是每个 AC 都产生 CD；
  是否需要数据由 LSU/一致性协议决定，BIU RTL 没有用 dirty 条件检查 CD valid。

### 1.2 为什么 BIU 只做"转发"

`snoop_channel` 不查 cache tag，也不解码 CR 语义。它把 AC 请求缓冲后转给 LSU，
并缓冲 LSU 返回的 CR/CD。LSU 内部 SNQ、D-Cache 及一致性状态逻辑负责请求执行；
具体是否读数据、是否更新状态应继续沿 LSU RTL 核查。

这与读写通道的边界定位相似，但“BIU 永远不碰协议语义”并不准确：例如写通道会按
ACE 字段分类 ready。对 snoop_channel 本身，能够确认的是 payload 基本透传且没有
CR/CD 语义判断。“不丢拍”则依赖 valid/ready 协议和两项缓冲不被违规覆盖。

---

## 2. 端口说明

| 组 | 信号 | 方向 | 含义 |
|----|------|------|------|
| AC 输入（来自总线） | `pad_biu_acvalid/acaddr/acsnoop/acprot` | in | 侦听地址请求（`snoop_channel.v:66-69`） |
| AC 握手 | `biu_pad_acready` | out | BIU 能收侦听请求（`:78`） |
| AC 输出（给 LSU） | `biu_lsu_ac_req/ac_addr/ac_snoop/ac_prot` | out | 转给 LSU SNQ（`:72-75`） |
| AC LSU 反馈 | `lsu_biu_ac_ready` / `lsu_biu_ac_empty` | in | 当前请求可被 SNQ/CTCQ 接收 / LSU snoop 活动链为空；`empty` 还覆盖 SDB、CTCQ 和待交付 `biu_lsu_ac_req`，不只是 SNQ（`:60,59`，定义见 LSU snoop arbiter） |
| CR 输入（来自 LSU） | `lsu_biu_cr_valid/cr_resp[4:0]` | in | LSU 侦听响应（`:64-65`） |
| CR 输出（给总线） | `biu_pad_crvalid/crresp[4:0]` | out | 发到 pad（`:83-84`） |
| CR 握手 | `pad_biu_crready`（in）/ `biu_lsu_cr_ready`（out） | both | 总线可收 / BIU 可收 LSU（`:71,77`） |
| CD 输入（来自 LSU） | `lsu_biu_cd_valid/cd_data[127:0]/cd_last` | in | LSU 提供的 snoop 数据 beat；BIU 不判断数据产生原因（`:61-63`） |
| CD 输出（给总线） | `biu_pad_cdvalid/cddata[127:0]/cdlast/cderr` | out | 发到 pad（`:79-82`） |
| CD 握手 | `pad_biu_cdready`（in）/ `biu_lsu_cd_ready`（out） | both | （`:70,76`） |
| snoop 标志 | `biu_xx_snoop_vld` | out | 粗粒度 snoop 活动/唤醒状态，不是精确 outstanding 数（`:85,537-549`） |
| 门控时钟 | `accpuclk/crcpuclk/cdcpuclk` + `snoop_ac/cr/cd_clk_en` | both | 三通道独立门控（`:54-57,86-88`） |

---

## 3. 参数与关键寄存器

三个通道各有一对 ping-pong 缓冲（深度 **2**）。控制骨架相似，但 payload、
时钟源和清除条件不同，不能称为完全同构：

| 通道 | 缓冲寄存器 | 内容 | 出处 |
|------|-----------|------|------|
| AC | `cur_acaddr_buf0/1_*` | acaddr(40)/acsnoop(4)/acprot(3)/acvalid | `snoop_channel.v:92-99` |
| CR | `cur_craddr_buf0/1_*` | crresp(5)/crvalid | `:115-118` |
| CD | `cur_cddata_buf0/1_*` | cddata(128)/cdlast/cdvalid | `:105-110` |
| 三通道公用 | `*_crt1_sel` / `*_pop1_sel` | 创建/弹出 ping-pong 指针 | `:103-104,113-114,119-120` |
| 核侦听标志 | `core_snoop_vld` | 1 位，被侦听期间保持 | `:91, 537-547` |

> 两项缓冲允许一个已占用槽等待目的端 ready 时，另一个空槽仍可接受新 payload。
> 创建/弹出指针同时维持接收顺序，因此不能说 AC/CR/CD“不需要保序”；准确说法是：
> 该模块没有跨独立 AW/W 通道记录数据来源的需求，所以不使用 12 项写来源队列。

---

## 4. AC 通道：把侦听请求转给 LSU SNQ

### 4.1 接收侧（`snoop_channel.v:182-188`）

```verilog
assign snoop_req_create_en = cur_acaddr_buf_ready && pad_biu_acvalid;   // 总线有请求且缓冲能收
assign cur_acaddr_buf_ready = !cur_acaddr_buf0_acvalid || !cur_acaddr_buf1_acvalid; // 任一项空
assign biu_pad_acready = cur_acaddr_buf_ready;                          // 回告总线：能收
```

`pad_biu_acvalid && biu_pad_acready` 才表示 AC 在 BIU 边界被接受。该组合条件在
时钟边沿前成立，边沿后 `crt1_sel` 翻转并置对应 valid。地址/snoop/prot 的寄存块
没有复位；只有对应 valid=1 时 payload 才有协议意义，复位后看到 X 或旧值不表示有效请求。

### 4.2 转发侧（`snoop_channel.v:297-300`）

```verilog
assign biu_lsu_ac_req        = cur_acaddr_buf_acvalid;          // 通知 LSU：有侦听
assign biu_lsu_ac_addr[39:0] = cur_acaddr_buf_acaddr[39:0];
assign biu_lsu_ac_snoop[3:0] = cur_acaddr_buf_acsnoop[3:0];     // snoop 类型(由 CIU 给)
assign biu_lsu_ac_prot[2:0]  = cur_acaddr_buf_acprot[2:0];
```

弹出由 `pop1_sel` 选当前项（组合 MUX `:273-295`）。严格的接受条件是
`biu_lsu_ac_req && lsu_biu_ac_ready`。当前
`ct_lsu_snoop_req_arbiter.v:203-213` 中，`lsu_biu_ac_ready` 本身又组合依赖
`biu_lsu_ac_req` 及其普通 snoop/CTC 分类，所以它不是与 valid 独立的标准 ready：
无请求时通常为 0，有请求且目标 entry、ICC/LM 条件允许时才为 1。波形统计仍建议
统一使用 `req && ready`，并把该事件解释为“请求进入 LSU 队列”，不是 snoop 已执行完成。

### 4.3 为什么 AC 用 `accpuclk` 而非 `coreclk`

lowpower 里 AC 门控时钟的源是 `forever_coreclk`，而非普通 `coreclk`。
这使普通 core clock 被上层门控时，AC 路径仍具有时钟来源。它是响应外部 snoop 的必要条件之一，
但完整唤醒是否成立还取决于上层时钟/电源控制，不能由这一根时钟连接单独证明。

---

## 5. CR 通道：把侦听响应吐回总线

CR 方向是 LSU → 总线，结构是 AC 的镜像。

### 5.1 接收 LSU 响应（`snoop_channel.v:306-311`）

```verilog
assign biu_lsu_cr_ready = crready;
assign crready = cur_craddr_buf_ready;
assign cur_craddr_buf_ready = !cur_craddr_buf0_crvalid || !cur_craddr_buf1_crvalid;
```

`lsu_biu_cr_resp[4:0]` 锁进缓冲（`:362-365, 384-387`）。此 BIU 文件没有参数或
位切片定义各位含义，因此仅凭这里不能可靠给出 DataTransfer、PassDirty、IsShared 等
具体位号；应以 CIU/LSU 生成和消费该总线的 RTL 为准。BIU 只原样寄存并输出。

### 5.2 发往总线（`snoop_channel.v:317-324`）

```verilog
assign biu_pad_crvalid     = cur_craddr_buf_crvalid;
assign biu_pad_crresp[4:0] = cur_craddr_buf_pop1_sel ? cur_craddr_buf1_crresp : cur_craddr_buf0_crresp;
```

握手用 `pad_biu_crready`（`:340,352,374`）。

---

## 6. CD 通道：把可选 snoop 数据送回 CIU

### 6.1 是什么

源码只明确说明“不是每个 snoop 请求都有数据”（`:391-392`）。在常见一致性场景中，
脏数据转移会使用 CD，但其它要求返回数据的 snoop 类型也可能产生 CD。BIU 不检查
cache 状态，只要 LSU 提供 `lsu_biu_cd_valid` 就按握手接收。

### 6.2 接收 LSU 数据（`snoop_channel.v:394-399`）

```verilog
assign biu_lsu_cd_ready = cdready;
assign cdready = cur_cddata_buf_ready;
assign cur_cddata_buf_ready = !cur_cddata_buf0_cdvalid || !cur_cddata_buf1_cdvalid;
```

`lsu_biu_cd_data[127:0]` / `lsu_biu_cd_last` 锁进缓冲（`:472-481, 503-512`）。
数据宽度是 128 位。若一次响应返回完整 64B line，数据量对应 4 个 beat；
`cdlast` 标识该 CD burst 的最后一拍，但本模块不强制 burst 一定是 4 拍。

### 6.3 发往总线（`snoop_channel.v:406-409`）

```verilog
assign biu_pad_cdvalid       = cur_cddata_buf_cdvalid;
assign biu_pad_cddata[127:0] = cur_cddata_buf_cddata[127:0];
assign biu_pad_cdlast        = cur_cddata_buf_cdlast;
assign biu_pad_cderr         = 1'b0;     // BIU 不产生 CD 错误
```

---

## 7. snoop_vld：被侦听时不许熄火

### 7.1 是什么（`snoop_channel.v:530-549`）

```verilog
assign core_ac_empty = lsu_biu_ac_empty               // LSU SNQ 空
                    && !cur_craddr_buf_crvalid         // 且 CR 缓冲空
                    && !cur_cddata_buf_cdvalid;        // 且 CD 缓冲空
// core_snoop_vld：snoop 请求到来时置 1，三者全空时清 0
always @(posedge forever_coreclk ...) begin
  if(snoop_req_create_en)  core_snoop_vld <= 1'b1;
  else if(core_ac_empty)   core_snoop_vld <= 1'b0;
end
assign biu_xx_snoop_vld = core_snoop_vld;
```

`core_ac_empty` 没有直接检查 BIU 的 `cur_acaddr_buf_acvalid`，也没有维护 CR/CD
事务计数；只看本文件容易怀疑“AC 尚在 BIU 缓冲、LSU 仍报告 empty”会使活动标志
提前清零。沿接口反查 `ct_lsu_snoop_req_arbiter.v:155-158,216` 可排除这个正常路径
漏洞：

```verilog
lsu_snoop_clk_en = biu_lsu_ac_req
                 || lsu_snq_not_empty
                 || lsu_sdb_not_empty
                 || lsu_ctcq_not_empty;
lsu_biu_ac_empty = !lsu_snoop_clk_en;
```

只要 BIU AC 缓冲非空，`biu_lsu_ac_req=1`，LSU 就返回
`lsu_biu_ac_empty=0`；AC 被接收后，SNQ/CTCQ/SDB 的非空状态继续维持活动。
因此当前 BIU+LSU 连接形成了“待交付 AC + LSU 内部处理 + BIU CR/CD 缓冲”的跨模块
保持链。它仍不是精确 outstanding 计数，也不覆盖脱离这些状态保存的其它系统事务，
但不能再把“未直接写入 AC valid”误判成必然提前关钟。

### 7.2 为什么需要它

C910 使用 ICG 降低空闲动态功耗。`biu_xx_snoop_vld` 可向核级控制表明存在需要关注的
snoop 活动。若核级门控忽略仍需 LSU 处理的 snoop，可能阻塞一致性响应；但本文件
只产生提示信号，最终哪些时钟被保持或唤醒要由上层连接确认。

`core_snoop_vld` 用 `forever_coreclk` 更新，因此普通 `coreclk` 被门控时仍具备更新条件。
不过 `forever_coreclk` 不等于电源域永不掉电。还要注意
`snoop_ac_clk_en = cur_acaddr_buf_ready || lsu_biu_ac_ready` 为时序考虑忽略了 AC valid；
只要 AC 缓冲未满，它通常就会使 `accpuclk` 活动，并非只在真正收到 snoop 时开钟。

---

## 8. ACE 一致性全景：snoop 在其中的位置

把主角色（读写通道）和从角色（snoop 通道）拼起来，看一次跨核一致性读：

```
核A 要读地址 X（X 在核B 的 D-Cache 里是脏的）

  核A：LSU miss → BIU read_channel → AR(ardomain=Shareable) → CIU
                                                                │
  CIU 根据其内部状态决定向核B 发侦听 ─────── AC ────────────────┐│
                                                              ▼▼
  核B：BIU snoop_channel 收 AC → 转 LSU SNQ → LSU 查 D-Cache  │
       LSU 生成 CR → BIU → 总线 ─ CR ─▶ CIU
       若该响应需要数据，LSU 再经 CD → BIU → 总线 ─ CD ─▶ CIU
                                                                │
  CIU 按一致性协议组合响应，并向核A返回数据/状态                  │
                                                                ▼
  核A：BIU read_channel 收 R 数据(按 rid 认领) → 送回 LSU → 完成读
```

可见同一时刻：

- 核A 的 BIU 在演**主**（read_channel 发 AR、收 R）。
- 核B 的 BIU 在演**从**（snoop_channel 收 AC、发 CR/CD）。

该图用于解释通道方向，不是从 BIU RTL 单独还原出的完整一致性状态机。目录命中、
是否更新 L2、最终状态转换都必须以 CIU/LSU RTL 为准。

---

## 本章小结

BIU snoop 通道由 AC 请求入口和 CR/CD 响应出口组成，三者都使用两项 ping-pong 缓冲并按创建、弹出指针维持各自的局部先入先出顺序，但方向和语义并不相同。AC 把 CIU 发来的探测请求交给 LSU，CR 返回一致性响应，CD 只在 LSU 明确提供数据 valid 时发送相应数据；它们的 payload、时钟、复位和清除条件也分别定义。因此不能假设每个 AC 都必然产生 CD，也不能从该模块推导“只有脏副本才发数据”，cache 状态判定和是否需要数据响应由 LSU 的一致性处理逻辑完成，snoop_channel 只承担边界缓冲和握手转换。

AC 活动锁存及其派生时钟使用 `forever_coreclk`，使外部探测到达时不必依赖普通 core clock 已经活跃。请求进入 LSU 后，`lsu_biu_ac_empty` 又把 BIU 请求、SNQ、SDB 和 CTCQ 等后续非空状态串成处理生命周期，防止仅因入口槽清空就过早报告空闲。这只能证明当前 RTL 对本地 snoop 活动有持续保持路径，不能替代 SoC 级电源域和唤醒契约。波形分析时应从 AC valid/ready 开始，继续观察 LSU 队列接收、CR 生成、可选 CD 数据发送以及全部状态清空，避免只看到入口握手便认为一致性事务已经完成。
