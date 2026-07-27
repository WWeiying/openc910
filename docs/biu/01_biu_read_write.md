# C910 BIU 读通道与写通道 模块详细教学文档

> 本文档解析 BIU 的两个"主角色"通道：
> `ct_biu_read_channel.v`（740 行，AR+R）与 `ct_biu_write_channel.v`（1078 行，AW+W+B）。
> 读懂它们，就理解了"本核主动访存"如何变成 ACE 总线事务、又如何把乱序返回对回请求源。
> 阅读前建议先看 [00_biu_overview.md](00_biu_overview.md) 的第 7 节（AXI ID 思想）。

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [读地址通道（AR）：2 项 ping-pong 缓冲](#4-读地址通道ar2-项-ping-pong-缓冲)
5. [读数据通道（R）：按 AXI ID 路由到 IFU/LSU](#5-读数据通道r按-axi-id-路由到-ifulsu)
6. [RACK 自发机制](#6-rack-自发机制)
7. [写地址通道（AW）：store/victim 两路与 ws/wns](#7-写地址通道awstorevictim-两路与-wswns)
8. [写数据通道（W）：12 项保序 FIFO + 三缓冲](#8-写数据通道w12-项保序-fifo--三缓冲)
9. [写响应通道（B）与 BACK 自发](#9-写响应通道b与-back-自发)
10. [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 两通道的职责

| 通道模块 | ACE 子通道 | 干什么 |
|----------|-----------|--------|
| `read_channel` | AR（读地址）、R（读数据） | 把仲裁后的读请求发到总线；把总线回来的数据按 ID 送回 IFU 或 LSU |
| `write_channel` | AW（写地址）、W（写数据）、B（写响应） | 把 store/victim 两路写请求保序发到总线；把 B 响应送回 LSU |

两者都属于"本核当 Master 主动访存"的主角色（见 overview 第 8 节），
请求源都来自核内、经 `req_arbiter` 整理后送进来。

### 1.2 共同的设计骨架

读/写通道都遵循同一个"地址通道 + 数据通道 + (RACK/BACK) 自发"骨架：

```
       req_arbiter 整理好的请求
                │
       ┌────────▼────────┐
       │   地址缓冲       │  cur_raddr_buf / cur_waddr_buf
       │ (ping-pong/双路) │
       └────────┬────────┘
                │ biu_pad_ar*/aw*  握手
                ▼
              pad（片外 ACE）
                │ pad_biu_r*/b*  返回
                ▼
       ┌────────▼────────┐
       │   数据/响应缓冲  │  cur_rdata_buf / cur_bresp_buf
       └────────┬────────┘
                │ 按 ID 分发
                ▼
       biu_ifu_rd_* / biu_lsu_r_* / biu_lsu_b_*
```

---

## 2. 端口说明

### 2.1 read_channel 端口（按通道分组）

| 组 | 信号 | 方向 | 含义 |
|----|------|------|------|
| AR 输入（来自仲裁器） | `arvalid/arid/araddr/arlen/arsize/arburst/arcache/arprot/arsnoop/ardomain/arbar/aruser/arlock` | in | 仲裁后的统一读请求（`read_channel.v:75-89`） |
| AR 输入控制 | `arvalid_gate` | in | 门控用 valid（用于装载缓冲，`:89`） |
| AR 输出（送总线） | `biu_pad_arvalid/arid/araddr/...` | out | 发到 pad 的读地址（`:113-125`） |
| AR 握手 | `arready`（out 给仲裁器）/ `pad_biu_arready`（in 来自总线） | both | 缓冲可收 / 总线可收（`:102,94`） |
| R 输入（来自总线） | `pad_biu_rvalid/rdata/rid/rlast/rresp` | in | 返回数据（`:96-100`） |
| R 输出给 IFU | `biu_ifu_rd_data/data_vld/id/last/resp` | out | 路由给 IFU（`:103-107`） |
| R 输出给 LSU | `biu_lsu_r_data/id/last/resp/vld` | out | 路由给 LSU（`:108-112`） |
| R 上游 ready | `ifu_biu_r_ready` / `lsu_biu_r_linefill_ready` | in | 源能否收数据（`:92-93`） |
| RACK | `biu_pad_rack`（out）/`pad_biu_rack_ready`（in） | both | 读完成确认（`:126,95`） |
| 门控/低功耗 | `read_ar_clk_en/read_r_clk_en/read_busy` | out | 给 lowpower（`:128-130`） |

### 2.2 write_channel 端口（按通道分组）

| 组 | 信号 | 方向 | 含义 |
|----|------|------|------|
| AW 输入 store 路 | `st_awvalid/st_awid/st_awaddr/.../st_awvalid_gate` | in | store（WMB）写地址（`write_channel.v:130-145`） |
| AW 输入 victim 路 | `vict_awvalid/vict_awid/.../vict_awvalid_gate` | in | victim（VB）写地址（`:152-167`） |
| AW 握手回仲裁器 | `st_awready` / `vict_awready` | out | 两路各自可收（`:202,206`） |
| AW 输出送总线 | `biu_pad_awvalid/awid/awaddr/awsnoop/awunique/...` | out | 合并后的写地址（`:177-190`） |
| AW 总线 ready | `pad_biu_ws_awready` / `pad_biu_wns_awready` | in | ws/wns 两套握手（`:127,124`） |
| W 输入 store/victim | `st_wdata/st_wstrb/st_wlast/st_wns/st_wvalid`、`vict_w*` | in | 两路写数据（`:146-173`） |
| W 握手回仲裁器 | `st_wready` / `vict_wready` | out | 两路各自可收（`:204,208`） |
| W 输出送总线 | `biu_pad_wdata/wstrb/wlast/wns/wvalid/werr` | out | 写数据（`:193-198`） |
| W 总线 ready | `pad_biu_ws_wready` / `pad_biu_wns_wready` | in | ws/wns 两套（`:128,125`） |
| B 输入 | `pad_biu_bvalid/bid/bresp` | in | 写响应（`:121-123`） |
| B 输出给 LSU | `biu_lsu_b_vld/b_id/b_resp` | out | 路由给 LSU（`:174-176`） |
| BACK | `biu_pad_back`（out）/`pad_biu_back_ready`（in） | both | 写完成确认（`:191,120`） |

---

## 3. 参数与关键寄存器

### 3.1 read_channel 寄存器

| 寄存器 | 宽度/含义 | 出处 |
|--------|-----------|------|
| `cur_raddr_buf0_*` / `cur_raddr_buf1_*` | 读地址缓冲 **2 项**（全套 ar 字段） | `read_channel.v:133-158` |
| `cur_raddr_buf_crt1_sel` | 写入选 buf0/buf1（创建指针，翻转） | `:171, 368-376` |
| `cur_raddr_buf_pop1_sel` | 弹出选 buf0/buf1（消费指针，翻转） | `:172, 378-386` |
| `cur_rdata_buf0_*` / `cur_rdata_buf1_*` | 读数据缓冲 **2 项**（rid/rdata/rresp/rlast/rvalid） | `:173-184` |
| `rack_valid` / `rack_pending` | RACK 状态：有效位 + 挂起位 | `:189-190` |

### 3.2 write_channel 寄存器

| 寄存器 | 宽度/含义 | 出处 |
|--------|-----------|------|
| `bus_arb_w_fifo` | **12 位**，每位记一拍写属于 wmb(0)/vb(1) | `write_channel.v:215`，`parameter W_FIFO_ENTRY=12 (:651)` |
| `bus_arb_w_fifo_create_ptr` | **13 位** one-hot 创建指针（位移 FIFO） | `:216, 665-673` |
| `cur_waddr_st_*` | store 写地址缓冲 **1 项** | `:233-246` |
| `cur_waddr_vict_*` | victim 写地址缓冲 **1 项** | `:247-260` |
| `cur_wdata_buf_pop_sel` | **3 位** one-hot：选 victim/store/round | `:261, 787-797` |
| `cur_wdata_st_*` / `cur_wdata_vict_*` / `cur_wdata_round_*` | 写数据三缓冲各 1 项 | `:267-281` |
| `cur_bresp_buf_*` | 写响应缓冲 1 项（bid/bresp/bvalid） | `:217-219` |
| `back_valid` / `back_pending` | BACK 状态 | `:213-214` |

---

## 4. 读地址通道（AR）：2 项 ping-pong 缓冲

### 4.1 是什么

`cur_raddr_buf` 是一个深度为 2 的 ping-pong 缓冲，用来"接住"仲裁器送来的读请求、
再以总线节奏发出去。结构（注释见 `read_channel.v:284-289`）：每项含全套 ar 字段。

为什么是 2 项而不是 1 项或 FIFO？

- 1 项会导致"上一拍请求还没被总线收走，这一拍就不能再收新请求"——无法背靠背。
- 2 项 ping-pong 刚好让"装入"和"弹出"错开：一项在等总线 `arready`，
  另一项可以同时接收仲裁器的新请求。这是用最小代价换背靠背吞吐。

### 4.2 信号与行号

**就绪/空判断**（`read_channel.v:276-281`）：

```verilog
assign arready          = cur_raddr_buf_ready;     // 给仲裁器：我能收
assign cur_raddr_buf_ready = cur_raddr_buf_empty;
assign cur_raddr_buf_empty = !cur_raddr_buf0_arvalid || !cur_raddr_buf1_arvalid;  // 任一项空即可收
```

**创建指针 crt1_sel / 弹出指针 pop1_sel 翻转**（`:368-386`）：每完成一次握手就翻转，
让两项轮流当"写入口"和"读出口"——这就是 ping-pong 的本质。

```verilog
// 装入握手成功 → 创建指针翻转
else if(arvalid && cur_raddr_buf_ready)
  cur_raddr_buf_crt1_sel <= !cur_raddr_buf_crt1_sel;
// 总线收走 → 弹出指针翻转
else if(cur_raddr_buf_arvalid && pad_biu_arready)
  cur_raddr_buf_pop1_sel <= !cur_raddr_buf_pop1_sel;
```

**发往总线**（`:291-303`）：`biu_pad_ar*` 直接取自当前弹出项（由 pop1_sel 选 buf0/buf1，
组合逻辑 MUX 见 `:308-366`）。注意 `aruser` 透传给 TLB read 用（`:303` 注释）。

### 4.3 为什么这么设计

- **装载用 `arvalid_gate` 而非 `arvalid`**（`:417,478`）：`gate` 信号是为门控时钟服务的
  早版本 valid，让数据在时钟开门的同时被锁存，省一拍、省功耗。
- **valid 与 data 分开写**（valid 用 `arvalid`，data 用 `arvalid_gate`）：valid 路要参与
  `arready` 组合判断不能门控，data 路可以门控——拆开是典型的"控制不门控、数据门控"省电法。

---

## 5. 读数据通道（R）：按 AXI ID 路由到 IFU/LSU

### 5.1 是什么

总线返回的读数据先进 `cur_rdata_buf`（同样 2 项 ping-pong，`:173-184, 577-699`），
再**纯靠 rid 判定该送回 IFU 还是 LSU**。这是 overview 第 7 节"AXI ID 当名牌"思想的落地点。

### 5.2 路由判定（核心逻辑，`read_channel.v:528-536`）

```verilog
assign cur_rdata_is_ifu = cur_rdata_buf_rvalid
                       && ((cur_rdata_buf_rid[4:0]==5'b10000)   // IFU refill
                        || (cur_rdata_buf_rid[4:0]==5'b10001)); // IFU prefetch
assign cur_rdata_is_lsu = cur_rdata_buf_rvalid && !cur_rdata_is_ifu;  // 其余都给 LSU
assign cur_rdata_is_linefill = cur_rdata_buf_rvalid && (cur_rdata_buf_rid[4:3]==2'b00); // LSU linefill
```

- 高位 `10` → IFU；其余 → LSU。一个 5 位名牌就完成了"谁的"分流。
- `rid[4:3]==2'b00` 进一步标出 LSU 中的 linefill 类，因为只有 linefill 才需要等
  `lsu_biu_r_linefill_ready`（`:522-524`），其它 LSU 读不看该 ready，能直接清。

### 5.3 数据清除条件（`read_channel.v:522-526`）

```verilog
assign rd_data_clr_en_raw = (cur_rdata_is_ifu && ifu_biu_r_ready)            // IFU 收
                         || (cur_rdata_is_lsu && lsu_biu_r_linefill_ready)   // LSU linefill 收
                         || (cur_rdata_is_lsu && !cur_rdata_is_linefill);    // LSU 非 linefill 直清
assign rd_data_clr_en = rd_data_clr_en_raw && !rack_full;                    // RACK 满则不清
```

### 5.4 分发输出（`read_channel.v:708-718`）

```verilog
assign biu_lsu_r_vld    = cur_rdata_is_lsu && !rack_full;
assign biu_lsu_r_id[4:0]= cur_rdata_buf_rid[4:0];     // LSU 看完整 5 位 ID
...
assign biu_ifu_rd_data_vld = cur_rdata_is_ifu && !rack_full;
assign biu_ifu_rd_id       = cur_rdata_buf_rid[0];    // IFU 只关心最低位(refill/prefetch)
```

注意 IFU 只取 `rid[0]`——因为 IFU 的 ID 只有 1 位（refill vs prefetch），高 4 位是 BIU 补的常量。

---

## 6. RACK 自发机制

### 6.1 为什么需要

ACE 要求读事务结束时主端发 RACK（read acknowledge）。但在异步 biu/piu 配置下，
总线不会替 BIU 生成它（`read_channel.v:541` 注释："for async biu/piu, biu should generate rack by itself"）。
于是 BIU 自己造一个。顶层把 `pad_biu_rack_ready` 直接拉高（`top.v:1187`），简化握手。

### 6.2 信号与行号（`read_channel.v:542-570`）

```verilog
assign rlast_done = cur_rdata_buf_rvalid && cur_rdata_buf_rlast && rd_data_clr_en; // 末拍清掉
// rack_valid：末拍完成或挂起时置起，rack_ready 时清
// rack_pending：rack 忙时(已 valid 又来一个 rlast)记一个挂起
assign rack_full = rack_valid && rack_pending;   // 两个都占了 → 暂停清数据
assign biu_pad_rack = rack_valid;
```

`rack_full` 反压到 `rd_data_clr_en`/`biu_lsu_r_vld`/`biu_ifu_rd_data_vld`，
保证 RACK 没发出去之前不会丢失下一笔——用 1 个 valid + 1 个 pending 覆盖最多 2 个在途 RACK，
正好匹配 2 项数据缓冲。

---

## 7. 写地址通道（AW）：store/victim 两路与 ws/wns

### 7.1 是什么

写有两个独立来源，各占 1 项缓冲：

- **store 路**（`cur_waddr_st_*`，`write_channel.v:233-246`）：来自 WMB（Write Merge Buffer，写合并缓冲），
  对应 `WriteUnique`/`WriteLineUnique` 等普通写。
- **victim 路**（`cur_waddr_vict_*`，`:247-260`）：来自 VB（Victim Buffer，回写缓冲），
  对应 cache 行被替换时的 `WriteBack`/`Evict`。

### 7.2 victim 优先（关键，`write_channel.v:482`）

合并送往总线的 `cur_waddr_buf` 选哪一路？组合 MUX 明确 victim 优先：

```verilog
if(cur_waddr_vict_awvalid)            // victim 有效就先发 victim
  cur_waddr_buf_* = cur_waddr_vict_*;
else
  cur_waddr_buf_* = cur_waddr_st_*;   // 否则才发 store
```

**为什么 victim 优先？** victim 回写会**释放一个 cache 行**。如果 store 一直压着 victim，
被替换的行迟迟写不回，新的填充就拿不到空位，反过来阻塞读缺失。先放 victim 出去，
能更快腾出 cache 资源，整体流水更顺。

### 7.3 ws/wns 域区分（ACE 比 AXI 多出的复杂度，`write_channel.v:411-420`）

```verilog
parameter WU=3'b000, WLU=3'b001, EVICT=3'b100;
assign aw_ws = ((awsnoop==WU)||(awsnoop==WLU)) && (awdomain==2'b01)   // WriteUnique/LineUnique + Inner Shareable
            || cur_waddr_buf_awbar[0];                                // 或带 barrier
assign pad_awready = aw_ws & pad_biu_ws_awready | !aw_ws & pad_biu_wns_awready;
```

总线为"可写共享（ws）"和"不可写共享（wns）"提供**两套 awready/wready 握手**。
BIU 按本次写的 snoop+domain 类型选用哪一套——这是一致性写与普通写在总线层的分流。

---

## 8. 写数据通道（W）：12 项保序 FIFO + 三缓冲

这是整个 BIU 最精巧的部分，回答一个核心问题：**store 和 victim 两路数据混在一起发，怎么保序？**

### 8.1 问题：AW 与 W 必须按发出顺序配对

ACE 中 AW（地址）和 W（数据）是两个独立通道，但对同一个 ID 而言，
W 数据必须**按 AW 地址的发出顺序**给出。store 和 victim 交替发地址时，
后面的 W 拍必须知道"我这一拍属于哪一路"。

### 8.2 解法：bus_arb_w_fifo 记录每笔写的来源

`bus_arb_w_fifo`（12 位，`write_channel.v:215,651`）每一位记录一笔写事务来自
**wmb(0) 还是 vb(1)**（`:653-654` 注释）。它用**位移机制**而非读写指针来降低时序压力
（`:655` 注释 "use bit shift mechanism to reduce timing"）。

- 创建：地址发出且非 EVICT 时压入一位（`:680`，EVICT 无数据故不入队 `:676-678`）。
- 弹出：当前数据拍是 wlast 且总线收走时弹出一位（`:681-683`）。
- 位移：FIFO 内容随 create/pop 整体右移（`:689-691`），`create_ptr` 是 one-hot 写指针（`:665-673`）。

为什么 12 项？写事务可能多笔在途，FIFO 必须足够深以记下所有"已发地址、数据待发/在发"的写。
12 是 C910 对 WMB+VB 同时在途写数量的工程上界。

### 8.3 三个写数据缓冲 + round buffer（`write_channel.v:725-728` 注释）

```verilog
// use three wbuffer here, one for victim, one for store(wmb)
// and the third is round buffer for both source to cut timing
// use round buffer to support back to back
```

- `cur_wdata_vict_*`（victim 数据 1 项，`:277-281`）
- `cur_wdata_st_*`（store 数据 1 项，`:272-276`）
- `cur_wdata_round_*`（公用轮转缓冲 1 项，`:267-271`）

`cur_wdata_buf_pop_sel`（3 位 one-hot，`:261`）按 FIFO 头部指示选三者之一送总线
（`:750-783` 的 case：`3'b001`→victim、`3'b010`→store、`3'b100`→round）。
round buffer 的作用是"当 victim/store 主缓冲正被消费、下一拍同源数据又到了"时，
先暂存进 round，实现**背靠背**不停顿（`:900-962` 的 round 装载逻辑，
`w_fifo_round_next_victim/st` 判断下一笔是不是同源）。

### 8.4 选源前瞻（`write_channel.v:800-822`）

```verilog
assign pop_next_w_fifo = cur_wdata_buf_wlast
                       ? (bus_arb_w_fifo_less2 ? cur_waddr_vict_awvalid : bus_arb_w_fifo[1])
                       : bus_arb_w_fifo[0];   // 看 FIFO 头/次头决定下一拍取 victim 还是 store
```

提前一拍算好"下一拍该弹哪个缓冲"，避免组合逻辑过长——又一处为时序服务的设计。

### 8.5 数据有效合成（`write_channel.v:729-730`）

```verilog
assign cur_wdata_buf_wvalid = !bus_arb_w_fifo_empty && cur_wdata_buf_wvalid_dp;
```

只有 FIFO 非空（即确有已发地址在等数据）且选中的缓冲有数据时，才向总线声明 wvalid。
这把"地址已发"和"数据就绪"两个条件锁死，保证 AW/W 严格配对。

---

## 9. 写响应通道（B）与 BACK 自发

### 9.1 B 通道（`write_channel.v:963-1003`）

写响应缓冲 `cur_bresp_buf` 只有 1 项。LSU 被设计成**无条件能收 B 响应**
（`:970` 注释 "lsu can receive resp unconditioned"），所以这里只需一个浅缓冲：

```verilog
assign biu_pad_bready = !back_full;            // BACK 没满就能收 B
assign biu_lsu_b_vld  = cur_bresp_buf_bvalid && !back_full;
assign biu_lsu_b_resp = cur_bresp_buf_bresp;
assign biu_lsu_b_id   = cur_bresp_buf_bid;     // 5 位 ID 原样回给 LSU
```

### 9.2 BACK 自发（`write_channel.v:1005-1033`）

与 RACK 完全对称：异步配置下 BIU 自己生成 BACK（`:1006` 注释）。
`back_valid` + `back_pending` 两位状态，`back_full = back_valid && back_pending`（`:1031`）
反压 `biu_pad_bready`/`biu_lsu_b_vld`，保证 BACK 没发出去前不丢响应。顶层 `pad_biu_back_ready=1`（`top.v:1188`）。

---

## 设计取舍小结

1. **读用 2 项 ping-pong，写用 12 项 FIFO**——深度差异完全由"是否需要保序"决定。
   读不需要在 BIU 内排序（乱序靠 ID 分发），故浅；写必须按发出顺序配对 AW/W，故深。

2. **AXI ID 是读通道的灵魂**：`read_channel.v:528-536` 用 5 位 ID 一次性完成
   IFU/LSU 分流 + linefill 识别，无需查找表。这是 overview 通用思想①最直接的代码体现。

3. **三缓冲 + round buffer 全是为时序和背靠背**：写数据路把 store/victim/轮转拆三块、
   把"选下一源"前瞻一拍、用位移 FIFO 代替指针 FIFO，三处都标注 "for timing"/"to cut timing"。

4. **victim > store 体现资源释放优先**：先回写腾出 cache 行，避免反压填充。

5. **RACK/BACK 自发 + 1valid/1pending**：异步总线下自补 ack，用最小状态覆盖 2 个在途确认，
   与 2 项数据缓冲深度匹配，不多不少。

---

*文档覆盖 ct_biu_read_channel.v 全部 740 行、ct_biu_write_channel.v 全部 1078 行逻辑。*
