# C910 BIU 读通道与写通道 模块详细教学文档

> 本文档解析 BIU 的两个"主角色"通道：
> `ct_biu_read_channel.v`（740 行，AR+R）与 `ct_biu_write_channel.v`（1078 行，AW+W+B）。
> 读懂它们，就能理解本核主动访存如何形成 ACE 风格事务、局部缓冲怎样解耦握手，
> 以及读返回如何按固定 ID 编码分到 IFU 或 LSU。
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
10. [本章小结](#本章小结)

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
              `pad_*` 边界（通常连接 CIU）
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
| AR 输入控制 | `arvalid_gate` | in | 数据路径/门控活动提示；不等价于真实 AR 请求有效 |
| AR 输出（送总线） | `biu_pad_arvalid/arid/araddr/...` | out | 发到 pad 的读地址（`:113-125`） |
| AR 握手 | `arready`（out 给仲裁器）/ `pad_biu_arready`（in 来自总线） | both | 前者仅表示 BIU 有地址槽；`arvalid&&arready` 才是 BIU 接受。后者与 `biu_pad_arvalid` 同时为 1 才是 CIU 侧接受 |
| R 输入（来自总线） | `pad_biu_rvalid/rdata/rid/rlast/rresp` | in | 返回数据（`:96-100`） |
| R 输出给 IFU | `biu_ifu_rd_data/data_vld/id/last/resp` | out | 路由给 IFU（`:103-107`） |
| R 输出给 LSU | `biu_lsu_r_data/id/last/resp/vld` | out | 路由给 LSU（`:108-112`） |
| R 上游 ready | `ifu_biu_r_ready` / `lsu_biu_r_linefill_ready` | in | 源能否收数据（`:92-93`） |
| RACK | `biu_pad_rack`（out）/`pad_biu_rack_ready`（in） | both | 末个 R beat 已被核内目的端消费后的读确认；不是 AR 被接受的确认 |
| 门控/低功耗 | `read_ar_clk_en/read_r_clk_en/read_busy` | out | 给 lowpower（`:128-130`） |

### 2.2 write_channel 端口（按通道分组）

| 组 | 信号 | 方向 | 含义 |
|----|------|------|------|
| AW 输入 store 路 | `st_awvalid/st_awid/st_awaddr/.../st_awvalid_gate` | in | store（WMB）写地址（`write_channel.v:130-145`） |
| AW 输入 victim 路 | `vict_awvalid/vict_awid/.../vict_awvalid_gate` | in | victim（VB）写地址（`:152-167`） |
| AW 握手回仲裁器 | `st_awready` / `vict_awready` | out | 两个本地 AW 槽的空闲指示；与对应 valid 同时为 1 才表示接受 |
| AW 输出送总线 | `biu_pad_awvalid/awid/awaddr/awsnoop/awunique/...` | out | 合并后的写地址（`:177-190`） |
| AW 总线 ready | `pad_biu_ws_awready` / `pad_biu_wns_awready` | in | ws/wns 两套握手（`:127,124`） |
| W 输入 store/victim | `st_wdata/st_wstrb/st_wlast/st_wns/st_wvalid`、`vict_w*` | in | 两路写数据（`:146-173`） |
| W 握手回仲裁器 | `st_wready` / `vict_wready` | out | 对应数据槽或 round 槽有接收能力；不是 W beat 已被 CIU 接收 |
| W 输出送总线 | `biu_pad_wdata/wstrb/wlast/wns/wvalid/werr` | out | 写数据（`:193-198`） |
| W 总线 ready | `pad_biu_ws_wready` / `pad_biu_wns_wready` | in | ws/wns 两套（`:128,125`） |
| B 输入 | `pad_biu_bvalid/bid/bresp` | in | 写响应（`:121-123`） |
| B 输出给 LSU | `biu_lsu_b_vld/b_id/b_resp` | out | 路由给 LSU（`:174-176`） |
| BACK | `biu_pad_back`（out）/`pad_biu_back_ready`（in） | both | B 响应已在 BIU 被处理后的确认；不是 AW/W 接受事件 |

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
| `bus_arb_w_fifo` | **12 位**，每个已接受且有数据的写事务占一位，记 wmb(0)/vb(1) | `write_channel.v:215`，`parameter W_FIFO_ENTRY=12 (:651)` |
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

为什么使用 2 项而不是单项？

- 若沿用本实现“有空槽才 ready”的寄存缓冲结构，单项在被下游占住时不能再吸收新请求。
  其它带组合旁路或同拍 pop/create 的单项结构可能有不同吞吐，不能泛化为所有单项 FIFO。
- 2 项允许一项等待 CIU 侧 `arready` 时，另一项仍为空并可接受新请求；在创建指针、
  弹出指针和 ready 时序满足条件时，也可支持连续周期接受。
- 这只说明本地容量和可能达到的吞吐，不证明任意上游/下游停顿模式下都不会反压。

### 4.2 信号与行号

**就绪/空判断**（`read_channel.v:276-281`）：

```verilog
assign arready          = cur_raddr_buf_ready;     // 给仲裁器：我能收
assign cur_raddr_buf_ready = cur_raddr_buf_empty;
assign cur_raddr_buf_empty = !cur_raddr_buf0_arvalid || !cur_raddr_buf1_arvalid;  // 任一项空即可收
```

**创建指针 `crt1_sel` / 弹出指针 `pop1_sel` 翻转**（`:368-386`）：
`arvalid && cur_raddr_buf_ready` 在当前边沿接受一项后翻转创建选择；
`cur_raddr_buf_arvalid && pad_biu_arready` 在 CIU 侧接受当前输出后翻转弹出选择。
组合条件成立是边沿更新的前提，指针并不是在组合逻辑中立即翻转。

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

- **valid 与 payload 使用不同条件**：valid 位只在 `arvalid && 槽空` 时置位；
  payload 寄存器在 `arvalid_gate && 槽空` 时锁存。`arvalid_gate` 还参与
  `read_ar_clk_en`，因此它可提前打开数据路径时钟，但不能单独宣告一笔请求。
- 正确性依赖接口约定：真正 `arvalid` 到来时，相应 payload 必须已被
  `arvalid_gate` 捕获或同周期稳定。源码体现了这一时序优化，不能仅凭命名把
  `arvalid_gate` 当作普通 valid。

---

## 5. 读数据通道（R）：按 AXI ID 路由到 IFU/LSU

### 5.1 是什么

总线返回的读数据先进 `cur_rdata_buf`（同样 2 项 ping-pong，`:173-184, 577-699`），
再按 `rid` 的固定编码判定该送回 IFU 还是 LSU。该模块没有 ID 查找表，也不在本地
重排响应；两个 R 槽按到达/弹出顺序保存 beat。

### 5.2 路由判定（核心逻辑，`read_channel.v:528-536`）

```verilog
assign cur_rdata_is_ifu = cur_rdata_buf_rvalid
                       && ((cur_rdata_buf_rid[4:0]==5'b10000)   // IFU refill
                        || (cur_rdata_buf_rid[4:0]==5'b10001)); // IFU prefetch
assign cur_rdata_is_lsu = cur_rdata_buf_rvalid && !cur_rdata_is_ifu;  // 其余都给 LSU
assign cur_rdata_is_linefill = cur_rdata_buf_rvalid && (cur_rdata_buf_rid[4:3]==2'b00); // LSU linefill
```

- **只有精确值** `5'b10000` 和 `5'b10001` → IFU；其它全部 → LSU。
  不能写成“高位 `10` 都属于 IFU”，因为例如 `10100` 并不匹配。
- `rid[4:3]==2'b00` 进一步标出 LSU 中的 linefill 类，因为只有 linefill 才需要等
  `lsu_biu_r_linefill_ready`（`:522-524`）。其它 LSU 返回没有 ready 输入，
  RTL 在其输出有效的同一周期安排清除，因此依赖 LSU 对这类返回无条件接收的接口约定。

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

本模块在一个 R 事务的末个 beat 被核内目的端消费后生成 RACK。源码注释说明该逻辑
服务于异步 BIU/PIU 方案，但当前 `ct_biu_top` 并未实例化注释掉的异步总线封装，
并把 `pad_biu_rack_ready` 恒置为 1（`top.v:1187`）。因此应区分“模块保留的
可反压逻辑”和“当前集成的恒 ready 行为”。

### 6.2 信号与行号（`read_channel.v:542-570`）

```verilog
assign rlast_done = cur_rdata_buf_rvalid && cur_rdata_buf_rlast && rd_data_clr_en; // 末拍清掉
// rack_valid：末拍完成或挂起时置起，rack_ready 时清
// rack_pending：rack 忙时(已 valid 又来一个 rlast)记一个挂起
assign rack_full = rack_valid && rack_pending;   // 两个都占了 → 暂停清数据
assign biu_pad_rack = rack_valid;
```

若 `pad_biu_rack_ready` 可以拉低，`rack_pending` 可记录 `rack_valid` 尚未被接受时
又发生的一次 `rlast_done`，`rack_full` 会暂停 R 数据消费。当前顶层 ready 恒为 1，
`rack_pending` 每拍优先被清零，`rack_full` 不会由正常时序置成 1；RACK 可以连续周期保持
或重新置位来表示连续完成。因而“正好覆盖两个在途 RACK”是泛化推断，不是当前集成状态。

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

RTL 可直接证明的是：只要 `cur_waddr_vict_awvalid=1`，输出 MUX 就选择 victim，
store 只有在 victim valid=0 时才被输出。常见架构动机是优先疏通 victim buffer、
降低替换回写对 refill 的阻塞，但具体设计理由和性能收益需要 LSU 状态及实测数据支撑。

这是严格优先而不是轮转仲裁。若 victim 连续占据其单项地址槽，store 即使已经在
自己的槽中等待，也不能利用该拍 AW 带宽；如果 victim 所使用的 ready 长期不来，
store 还会发生队头阻塞。RTL 没有等待计数或强制让权，因此系统活性依赖总线最终
响应 victim，并依赖上游不会无限连续制造 victim。该结构是否成为性能瓶颈，应统计
`vict_awvalid && st_awvalid`、victim 被接受和 store 等待周期，而不是仅看 AW 总吞吐。

### 7.3 ws/wns 域区分（ACE 比 AXI 多出的复杂度，`write_channel.v:411-420`）

```verilog
parameter WU=3'b000, WLU=3'b001, EVICT=3'b100;
assign aw_ws = ((awsnoop==WU)||(awsnoop==WLU)) && (awdomain==2'b01)   // WriteUnique/LineUnique + Inner Shareable
            || cur_waddr_buf_awbar[0];                                // 或带 barrier
assign pad_awready = aw_ws & pad_biu_ws_awready | !aw_ws & pad_biu_wns_awready;
```

接口提供两组 AW ready。`aw_ws=1` 时选择 `pad_biu_ws_awready`，否则选择
`pad_biu_wns_awready`。W 通道的选择则不是重新解码 AW，而是由当前数据槽保存的
`wns` 位选择两组 W ready。端口中的通用 `pad_biu_awready/pad_biu_wready`
在该 RTL 文件的有效逻辑中没有参与握手。

还存在一条容易遗漏的来源约束：victim 地址槽的清除条件固定使用
`pad_biu_wns_awready`（`:523`），写来源 FIFO 对 victim AW 的创建条件也固定使用
该 ready（`:685`）；victim 数据槽清除固定使用 `pad_biu_wns_wready`（`:832`）。
它们没有使用通用的 `pad_awready/pad_wready` 重新选择。因此合法 victim 事务必须
始终属于 WNS 路径，并令随数据保存的 `vict_wns=1`。LSU 正常生成的
WriteBack/Evict 应满足这个接口约定，但 write_channel 自身没有断言保护；若错误地
送入会被 `aw_ws` 归到 WS 的 victim，外部握手与本地清除可能使用不同 ready。

验证环境至少应检查：

```systemverilog
assert (!(cur_waddr_vict_awvalid && aw_ws));
assert (!vict_wvalid || vict_wns);
```

这些断言表达的是当前实现已经依赖的协议不变量，不是新增的 ACE 语义。

---

## 8. 写数据通道（W）：12 项保序 FIFO + 三缓冲

这是整个 BIU 最精巧的部分，回答一个核心问题：**store 和 victim 两路数据混在一起发，怎么保序？**

### 8.1 问题：AW 与 W 必须按发出顺序配对

AW（地址）和 W（数据）是独立通道。该实现先接受/发出 store 与 victim 的 AW，
随后必须按自己记录的 AW 顺序从正确来源取出对应 W burst。来源队列解决的是
BIU 内部两路数据选择，不应笼统改写成所有 AXI ID 的完整排序规则。

### 8.2 解法：bus_arb_w_fifo 记录每笔写的来源

`bus_arb_w_fifo`（12 位，`write_channel.v:215,651`）每一位记录一笔**有 W 数据**
的写事务来自
**wmb(0) 还是 vb(1)**（`:653-654` 注释）。它用**位移机制**而非读写指针来降低时序压力
（`:655` 注释 "use bit shift mechanism to reduce timing"）。

- 创建：地址发出且非 EVICT 时压入一位（`:680`，EVICT 无数据故不入队 `:676-678`）。
- 弹出：当前数据拍是 wlast 且总线收走时弹出一位（`:681-683`）。
- 位移：FIFO 内容随 create/pop 整体右移（`:689-691`），`create_ptr` 是 one-hot 写指针（`:665-673`）。

RTL 只给出 `W_FIFO_ENTRY=12`，没有给出选择该深度的性能理由。更重要的是，
这里没有 `fifo_full` 检测或返回上游的满反压：13 位 `create_ptr` 的 bit12 可表示
占用达到 12，若满时继续 create，指针可能移成全 0。系统正确性因此依赖 LSU/CIU
协议把“AW 已接受、W 尚未结束”的数据型写事务数限制在 12 以内。这个上界应通过
断言或压力测试验证，而不能仅称为“FIFO 必须足够深”。

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
round buffer 在主 victim/store 槽已占用、新 beat 又从符合当前来源序列的同一路到来时，
可额外保存一个 beat。它提高连续接收的机会；是否真的“每种情况下背靠背不停顿”
还取决于来源 valid、round 槽占用、队列头和所选 W ready。

### 8.4 选源前瞻（`write_channel.v:800-822`）

```verilog
assign pop_next_w_fifo = cur_wdata_buf_wlast
                       ? (bus_arb_w_fifo_less2 ? cur_waddr_vict_awvalid : bus_arb_w_fifo[1])
                       : bus_arb_w_fifo[0];   // 看 FIFO 头/次头决定下一拍取 victim 还是 store
```

该逻辑根据当前 burst 是否到 `wlast`、队列头/次头及 round 状态预选下一数据槽。
源码注释明确写有 `for timing, select pop entry in advance`；“减少哪一条具体
组合路径、改善多少时序”仍需综合报告确认。

### 8.5 数据有效合成（`write_channel.v:729-730`）

```verilog
assign cur_wdata_buf_wvalid = !bus_arb_w_fifo_empty && cur_wdata_buf_wvalid_dp;
```

只有 FIFO 非空（即确有已发地址在等数据）且选中的缓冲有数据时，才向总线声明 wvalid。
这使 W valid 只有在来源队列非空且当前所选数据槽有效时才拉高，是 AW/W 来源配对的
核心约束之一。完整正确性还依赖队列不溢出、EVICT 不带 W、上游按 ready 发送等协议不变量。

---

## 9. 写响应通道（B）与 BACK 自发

### 9.1 B 通道（`write_channel.v:963-1003`）

写响应缓冲 `cur_bresp_buf` 只有 1 项，且 BIU 到 LSU 没有 B-ready。源码注释明确采用
“LSU 无条件接收响应”的接口约定。`cur_bresp_buf_bvalid` 在 `!back_full` 时每拍直接
更新为 `pad_biu_bvalid`，因此它更接近一级响应寄存，而不是可任意停留等待 LSU 的 FIFO。

```verilog
assign biu_pad_bready = !back_full;            // BACK 没满就能收 B
assign biu_lsu_b_vld  = cur_bresp_buf_bvalid && !back_full;
assign biu_lsu_b_resp = cur_bresp_buf_bresp;
assign biu_lsu_b_id   = cur_bresp_buf_bid;     // 5 位 ID 原样回给 LSU
```

### 9.2 BACK 自发（`write_channel.v:1005-1033`）

其结构与 RACK 类似。若 BACK 接口允许反压，`back_valid/back_pending` 可保存当前确认和
一次额外挂起；`back_full` 会反压 B 接收。当前顶层 `pad_biu_back_ready=1`
（`top.v:1188`），所以 pending/full 路径正常情况下不会积累。这里的 B 接收表示
BIU 收到写响应，BACK 表示 BIU 对该响应的确认，二者都不同于 AW 或 W 被接受。

---

## 本章小结

BIU 读路径用两个 AR/R 边界槽保存完整请求或返回 beat，并依据 AXI ID 把返回组合分类给 IFU 或 LSU。ID 在这里充当来源名牌，而不是由 BIU 建立一张可任意重排的事务表；同 ID 顺序、编码合法性以及 LSU linefill 的整体完成仍由总线和源端协议保证。RACK/BACK 虽保留 valid、pending 和 full 结构，但当前顶层把相关 ready 固定为 1，因此正常波形中 pending/full 应长期为 0；若出现持续置位，应优先检查顶层连接、复位或未知态传播，而不是直接解释为正常背压。

写路径把地址和数据解耦处理。12 项来源队列只记录每个待发送数据属于 store 还是 victim，完整地址和数据则保存在各自边界缓冲中；因此队列深度不能简单解释为写 outstanding 数量。数据通路进一步拆成 store、victim 和轮转缓冲，并前瞻选择下一来源，源码明确将这些寄存边界用于缩短时序和支持背靠背传输。victim 对 store 的严格优先是 RTL 可确认的选择关系，它既可能帮助 victim 尽快前进，也可能在持续 victim 流量下延迟 store，实际性能影响需要运行数据验证。victim 的本地清除直接观察 WNS ready，还隐含要求 LSU 不把 victim 分类到 WS；该不变量由上游协议保证，本模块没有动态纠错。完整分析必须同时观察 AW 创建、来源队列入项、W 数据选择、对应 ready 握手和 B 返回，只有五者一致才说明一次写事务真正闭环。
