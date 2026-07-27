# C910 BIU 侦听通道 模块详细教学文档

> 本文档解析 BIU 的"从角色"通道：`ct_biu_snoop_channel.v`（563 行，AC+CR+CD）。
> 它实现 ACE 一致性中"本核被别人侦听"的那一半——把核外 CIU 的侦听请求接进来转给 LSU，
> 再把 LSU 的响应/数据吐回总线。阅读前建议先看 [00_biu_overview.md](00_biu_overview.md) 第 8 节
> （ACE 主+从双角思想）。

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [AC 通道：把侦听请求转给 LSU SNQ](#4-ac-通道把侦听请求转给-lsu-snq)
5. [CR 通道：把侦听响应吐回总线](#5-cr-通道把侦听响应吐回总线)
6. [CD 通道：把脏数据吐回总线](#6-cd-通道把脏数据吐回总线)
7. [snoop_vld：被侦听时不许熄火](#7-snoop_vld被侦听时不许熄火)
8. [ACE 一致性全景：snoop 在其中的位置](#8-ace-一致性全景snoop-在其中的位置)
9. [设计取舍小结](#设计取舍小结)

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
   │  CD ◀── LSU 给脏数据      │   lsu_biu_cd_* → biu_pad_cd*
   └──────────────────────────┘
              ▲
              │  LSU 查 D-Cache（SNQ = Snoop Queue 侦听队列）
        LSU（核内）
```

- **AC（snoop address）**：CIU → BIU → LSU。CIU 问"地址 X 你 cache 里有吗？"。
- **CR（snoop response）**：LSU → BIU → CIU。本核答"有/无/脏/...（5 位 resp）"。
- **CD（snoop data）**：LSU → BIU → CIU。**若本核有脏副本**，把数据交出去（不是每次侦听都有 CD）。

### 1.2 为什么 BIU 只做"转发"

注意 snoop_channel 不查 cache、不判一致性状态——它只是把 AC 请求**缓冲后转给 LSU 的 SNQ**
（Snoop Queue），真正去 D-Cache 里查 tag、读脏数据、改状态的是 LSU。
BIU 在这里依然是"薄边界层"：缓冲 + 跨节奏 + 转发。

这与读写通道一致：BIU 永远不碰数据语义，只管"忠实搬运 + 不丢拍"。

---

## 2. 端口说明

| 组 | 信号 | 方向 | 含义 |
|----|------|------|------|
| AC 输入（来自总线） | `pad_biu_acvalid/acaddr/acsnoop/acprot` | in | 侦听地址请求（`snoop_channel.v:66-69`） |
| AC 握手 | `biu_pad_acready` | out | BIU 能收侦听请求（`:78`） |
| AC 输出（给 LSU） | `biu_lsu_ac_req/ac_addr/ac_snoop/ac_prot` | out | 转给 LSU SNQ（`:72-75`） |
| AC 上游 ready/empty | `lsu_biu_ac_ready` / `lsu_biu_ac_empty` | in | LSU 能收 / LSU SNQ 空（`:60,59`） |
| CR 输入（来自 LSU） | `lsu_biu_cr_valid/cr_resp[4:0]` | in | LSU 侦听响应（`:64-65`） |
| CR 输出（给总线） | `biu_pad_crvalid/crresp[4:0]` | out | 发到 pad（`:83-84`） |
| CR 握手 | `pad_biu_crready`（in）/ `biu_lsu_cr_ready`（out） | both | 总线可收 / BIU 可收 LSU（`:71,77`） |
| CD 输入（来自 LSU） | `lsu_biu_cd_valid/cd_data[127:0]/cd_last` | in | LSU 侦听脏数据（`:61-63`） |
| CD 输出（给总线） | `biu_pad_cdvalid/cddata[127:0]/cdlast/cderr` | out | 发到 pad（`:79-82`） |
| CD 握手 | `pad_biu_cdready`（in）/ `biu_lsu_cd_ready`（out） | both | （`:70,76`） |
| snoop 标志 | `biu_xx_snoop_vld` | out | 本核正被侦听（`:85`） |
| 门控时钟 | `accpuclk/crcpuclk/cdcpuclk` + `snoop_ac/cr/cd_clk_en` | both | 三通道独立门控（`:54-57,86-88`） |

---

## 3. 参数与关键寄存器

三个通道各有一对 ping-pong 缓冲（深度 **2**），结构完全同构：

| 通道 | 缓冲寄存器 | 内容 | 出处 |
|------|-----------|------|------|
| AC | `cur_acaddr_buf0/1_*` | acaddr(40)/acsnoop(4)/acprot(3)/acvalid | `snoop_channel.v:92-99` |
| CR | `cur_craddr_buf0/1_*` | crresp(5)/crvalid | `:115-118` |
| CD | `cur_cddata_buf0/1_*` | cddata(128)/cdlast/cdvalid | `:105-110` |
| 三通道公用 | `*_crt1_sel` / `*_pop1_sel` | 创建/弹出 ping-pong 指针 | `:103-104,113-114,119-120` |
| 核侦听标志 | `core_snoop_vld` | 1 位，被侦听期间保持 | `:91, 537-547` |

> 每个通道 2 项缓冲，原因与读通道相同：用最小代价支持背靠背（一项在等对端 ready，
> 另一项接新数据）。AC/CR/CD 不需要保序排队，故都是浅 ping-pong，没有像写通道那样的 12 项 FIFO。

---

## 4. AC 通道：把侦听请求转给 LSU SNQ

### 4.1 接收侧（`snoop_channel.v:182-188`）

```verilog
assign snoop_req_create_en = cur_acaddr_buf_ready && pad_biu_acvalid;   // 总线有请求且缓冲能收
assign cur_acaddr_buf_ready = !cur_acaddr_buf0_acvalid || !cur_acaddr_buf1_acvalid; // 任一项空
assign biu_pad_acready = cur_acaddr_buf_ready;                          // 回告总线：能收
```

装入由 `crt1_sel` 选 buf0/buf1（`:195-203, 219, 247`），数据锁存在 `accpuclk` 域
（`:227-241, 255-269`，注意地址/snoop/prot 用的是无复位的 `always @(posedge accpuclk)`，省复位线）。

### 4.2 转发侧（`snoop_channel.v:297-300`）

```verilog
assign biu_lsu_ac_req        = cur_acaddr_buf_acvalid;          // 通知 LSU：有侦听
assign biu_lsu_ac_addr[39:0] = cur_acaddr_buf_acaddr[39:0];
assign biu_lsu_ac_snoop[3:0] = cur_acaddr_buf_acsnoop[3:0];     // snoop 类型(由 CIU 给)
assign biu_lsu_ac_prot[2:0]  = cur_acaddr_buf_acprot[2:0];
```

弹出由 `pop1_sel` 选当前项（组合 MUX `:273-295`），握手条件是 `lsu_biu_ac_ready`（`:209,221,249`）。
LSU 收到后把地址压进自己的 SNQ（Snoop Queue），去 D-Cache 查。

### 4.3 为什么 AC 用 `accpuclk` 而非 `coreclk`

注意 lowpower 里 AC 门控时钟的源是 `forever_coreclk`（不被门控的核时钟），
见 [03_biu_arbiters_lp.md](03_biu_arbiters_lp.md)。因为侦听请求是**核外随时可能到来**的，
即使本核已门控休眠，AC 通道也必须随时能醒来接收——否则别的核会因为等不到 CR 响应而卡死。

---

## 5. CR 通道：把侦听响应吐回总线

CR 方向是 LSU → 总线，结构是 AC 的镜像。

### 5.1 接收 LSU 响应（`snoop_channel.v:306-311`）

```verilog
assign biu_lsu_cr_ready = crready;
assign crready = cur_craddr_buf_ready;
assign cur_craddr_buf_ready = !cur_craddr_buf0_crvalid || !cur_craddr_buf1_crvalid;
```

`lsu_biu_cr_resp[4:0]` 锁进缓冲（`:362-365, 384-387`）。5 位 resp 编码本核对该侦听地址的
一致性状态（是否持有、是否脏、是否需要 passdirty 等，具体由 CIU/LSU 协议定义）。

### 5.2 发往总线（`snoop_channel.v:317-324`）

```verilog
assign biu_pad_crvalid     = cur_craddr_buf_crvalid;
assign biu_pad_crresp[4:0] = cur_craddr_buf_pop1_sel ? cur_craddr_buf1_crresp : cur_craddr_buf0_crresp;
```

握手用 `pad_biu_crready`（`:340,352,374`）。

---

## 6. CD 通道：把脏数据吐回总线

### 6.1 是什么

CD 只在"本核持有脏副本、需要把数据交出去"时才有数据流动——**不是每次侦听都伴随 CD**
（`:391-392` 注释 "not every snoop req has data"）。结构仍是 2 项 ping-pong。

### 6.2 接收 LSU 数据（`snoop_channel.v:394-399`）

```verilog
assign biu_lsu_cd_ready = cdready;
assign cdready = cur_cddata_buf_ready;
assign cur_cddata_buf_ready = !cur_cddata_buf0_cdvalid || !cur_cddata_buf1_cdvalid;
```

`lsu_biu_cd_data[127:0]` / `lsu_biu_cd_last` 锁进缓冲（`:472-481, 503-512`）。
128 位宽，一个 64B 脏 cache line 需 4 拍（cdlast 标末拍）。

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

### 7.2 为什么需要它

C910 的核会在空闲时做 ICG（时钟门控）熄火省电。但如果此刻正有侦听在处理
（AC 已收、CR/CD 还没吐完），核绝不能熄火——否则 LSU 没法查 cache、CR/CD 发不出去，
别的核会一直等不到一致性响应而死锁。

`biu_xx_snoop_vld` 就是给核 ICG 逻辑的"刹车"：只要它为 1，核就保持唤醒。
它用 `forever_coreclk`（永不门控的时钟）驱动，确保即使核已休眠，这个标志也能正确翻起来。
这正是 overview 第 8 节"从角色"的硬件代价——为了能随时响应别人，必须留一条永不断电的醒来通路。

---

## 8. ACE 一致性全景：snoop 在其中的位置

把主角色（读写通道）和从角色（snoop 通道）拼起来，看一次跨核一致性读：

```
核A 要读地址 X（X 在核B 的 D-Cache 里是脏的）

  核A：LSU miss → BIU read_channel → AR(ardomain=Shareable) → CIU
                                                                │
  CIU 查目录，发现核B 可能有 X，向核B 发侦听 ──── AC ──────────┐│
                                                              ▼▼
  核B：BIU snoop_channel 收 AC → 转 LSU SNQ → LSU 查 D-Cache  │
       命中且脏 → LSU 经 CR 报"我有且脏" → BIU → 总线 ─ CR ─▶ CIU
                 LSU 经 CD 把脏数据交出 → BIU → 总线 ─ CD ─▶ CIU
                                                                │
  CIU 拿到核B 的脏数据，回给核A（也可能顺便写回 L2）            │
                                                                ▼
  核A：BIU read_channel 收 R 数据(按 rid 认领) → 送回 LSU → 完成读
```

可见同一时刻：

- 核A 的 BIU 在演**主**（read_channel 发 AR、收 R）。
- 核B 的 BIU 在演**从**（snoop_channel 收 AC、发 CR/CD）。

两个 BIU 端口、四组通道，靠 CIU 居中撮合，完成了一次一致的跨核读。
这就是为什么"一个 ACE 端口必须同时具备主、从两套通道"。

---

## 设计取舍小结

1. **三通道同构的 2 项 ping-pong**：AC/CR/CD 结构几乎一模一样（`:182-300`/`:306-388`/`:394-513`），
   不需要保序故都浅，与读通道一致、与写通道（12 项 FIFO）形成对比。

2. **BIU 只转发不判定**：snoop_channel 不查 cache、不解读一致性状态，把语义留给 LSU SNQ。
   保持 BIU"薄边界层"定位，时序与验证都简单。

3. **AC 走 `forever_coreclk`、snoop_vld 防熄火**：从角色必须随时能被外部叫醒，
   这条永不断电的醒来通路是一致性对称性的硬件成本（`:537` 用 forever_coreclk）。

4. **CD 不强制存在**：只有脏副本才发数据，省带宽——一致性协议本身就只在必要时搬数据。

---

*文档覆盖 ct_biu_snoop_channel.v 全部 563 行逻辑。*
