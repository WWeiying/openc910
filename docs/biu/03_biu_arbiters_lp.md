# C910 BIU 仲裁、局部门控与边界寄存 模块详细教学文档

> 本文档解析 BIU 的四个"配套"模块：
> `ct_biu_req_arbiter.v`（567 行，读写请求仲裁）、
> `ct_biu_csr_req_arbiter.v`（101 行，CSR 仲裁）、
> `ct_biu_lowpower.v`（360 行，门控时钟 + no_op）、
> `ct_biu_other_io_sync.v`（445 行，中断/调试双触发器同步、配置与 CSR 边界寄存）。
> 它们不直接搬运 ACE 数据，但决定输入选择、本地状态何时有时钟，以及若干边界信号如何采样。

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [req_arbiter：读写请求仲裁](#4-req_arbiter读写请求仲裁)
5. [csr_req_arbiter：CSR 仲裁（CP0 > HPCP）](#5-csr_req_arbitercsr-仲裁cp0--hpcp)
6. [lowpower：每通道门控 + no_op](#6-lowpower每通道门控--no_op)
7. [other_io_sync：同步器与边界寄存](#7-other_io_sync同步器与边界寄存)
8. [本章小结](#本章小结)

---

## 1. 模块概述

| 模块 | 一句话职责 |
|------|-----------|
| `req_arbiter` | 选择 IFU/LSU 读字段，并把 LSU 的 store/victim 地址与数据字段分别送往写通道 |
| `csr_req_arbiter` | 在 CP0 与 HPCP 两个 CSR 访问源之间选一个，发给 L2 CSR |
| `lowpower` | 例化 12 个门控时钟单元，并由本地 `read_busy/write_busy` 生成 `no_op` |
| `other_io_sync` | 对中断/调试使用双触发器同步；对 CSR、计时和配置采用直连或单级寄存 |

它们围绕三大数据通道（read/write/snoop）服务：仲裁器在通道**前**整理输入，
lowpower 给通道**供时钟**，other_io_sync 处理通道**之外**的杂项 IO。

---

## 2. 端口说明

### 2.1 req_arbiter（按来源/去向分组）

| 组 | 信号 | 方向 | 含义 |
|----|------|------|------|
| IFU 读输入 | `ifu_biu_rd_req/rd_addr/rd_id/rd_len/...` | in | IFU 取指读请求（`req_arbiter.v:153-164`） |
| LSU 读输入 | `lsu_biu_ar_req/ar_dp_req/ar_id/ar_addr/...` | in | LSU 读请求（`:165-179`） |
| 统一读输出 | `arvalid/arvalid_gate/arid/araddr/arsnoop/...` | out | 仲裁后送 read_channel（`:225-238`） |
| 读接收反馈 | `biu_ifu_rd_grnt` / `biu_lsu_ar_ready` | out | IFU 信号含请求选择与本地 ready；LSU 信号只是本地 ready，需与 LSU 自己的 req 组合判断接受 |
| LSU store 写输入 | `lsu_biu_aw_st_*` / `lsu_biu_w_st_*` | in | store 写地址/数据（`:181-195,211-215`） |
| LSU victim 写输入 | `lsu_biu_aw_vict_*` / `lsu_biu_w_vict_*` | in | victim 写地址/数据（`:196-219`） |
| 写输出 | `st_aw*/st_w*` / `vict_aw*/vict_w*` | out | 送 write_channel 两路（`:245-284`） |
| 写容量反馈 | `biu_lsu_aw_vb_grnt/aw_wmb_grnt/w_vb_grnt/w_wmb_grnt` | out | 实际直接连接各本地 `ready`；单独为 1 不表示已经接受一笔写 |

### 2.2 csr_req_arbiter

| 信号 | 方向 | 含义 |
|------|------|------|
| `cp0_biu_sel/op/wdata` | in | CP0 的 CSR 访问（`csr_req_arbiter.v:36-38`） |
| `hpcp_biu_sel/op/wdata` | in | HPCP 的 CSR 访问（`:39-41`） |
| `biu_csr_sel/op/wdata` | out | 仲裁后统一送出（`:44-46`） |
| `biu_csr_cmplt/rdata` | in | CSR 返回有效脉冲/数据；`cmplt` 晚于请求选择（`:34-35`） |
| `biu_cp0_cmplt/rdata` / `biu_hpcp_cmplt/rdata` | out | 回送两个源（`:42-43,47-48`） |

### 2.3 lowpower

| 信号 | 方向 | 含义 |
|------|------|------|
| `coreclk/forever_coreclk/cp0_biu_icg_en/pad_yy_icg_scan_en` | in | 时钟源与门控控制（`lowpower.v:51-53,66`） |
| `*_clk_en`（read_ar/read_r/st_aw/st_w/vict_aw/vict_w/round_w/snoop_ac/cr/cd/bus_arb_w_fifo/write_b） | in | 各通道使能（`:50-67`） |
| `*cpuclk`（arcpuclk/rcpuclk/st_awcpuclk/.../accpuclk/crcpuclk/cdcpuclk/bcpuclk） | out | 各通道门控后时钟（`:68-80`） |
| `read_busy/write_busy` | in | 通道忙标志（`:56,67`） |
| `biu_yy_xx_no_op` | out | 仅由 BIU 本地 read/write busy 计算的空闲提示（`:71,353`） |

### 2.4 other_io_sync

| 组 | 信号 | 方向 | 含义 |
|----|------|------|------|
| 中断输入 | `pad_biu_me/ms/mt/se/ss/st_int` | in | 6 种中断（`other_io_sync.v:83-88`） |
| 中断输出 | `biu_cp0_me/ms/mt/se/ss/st_int`、`biu_xx_int_wakeup` | out | 同步后给 CP0（`:96-102,116`） |
| 调试 | `pad_biu_dbgrq_b` → `biu_had_sdb_req_b`/`biu_xx_dbg_wakeup` | in/out | 调试请求同步（`:81,106,115`） |
| 核 ID/RVBA/APB base | `pad_core_hartid/pad_core_rvba/pad_xx_apb_base` | in | 配置信息（`:89-91`） |
| 计时器 | `pad_xx_time` → `biu_hpcp_time` | in/out | 在 `coreclk` 上每拍采样；不是双触发器同步（`:92,108,388-391`） |
| L2 CSR | `biu_csr_sel/op/wdata` → `biu_pad_csr_sel/wdata`；`pad_biu_csr_cmplt/rdata` → `biu_csr_cmplt/rdata` | both | CSR 请求/响应寄存（`:69-71,110-112,79-80,103-104`） |
| 低功耗/计数 | `cp0_biu_lpmd_b/had_biu_jdb_pm/hpcp_biu_cnt_en/pad_biu_hpcp_l2of_int` | both | 功耗模式/性能计数（`:74,77,78,82`） |

---

## 3. 参数与关键寄存器

| 模块 | 关键寄存器/参数 | 出处 |
|------|----------------|------|
| req_arbiter | `araddr/arid/...` 等 ar 字段为 reg（组合赋值的输出锁存载体） | `req_arbiter.v:287-298` |
| csr_req_arbiter | `biu_csr_sel/op/wdata`（纯组合 MUX 输出） | `csr_req_arbiter.v:51-53` |
| lowpower | 12 个 `gated_clk_cell` 例化 | `lowpower.v:122-350` |
| other_io_sync | 中断 2 级同步 FF：`cp0_*_int_ff1/ff2`（6×2=12 个） | `other_io_sync.v:133-144` |
| other_io_sync | 调试 2 级同步 FF：`had_sdb_req_b_ff1/ff2` | `:145-146` |
| other_io_sync | L2 CSR 寄存：`biu_pad_csr_sel/wdata`、`biu_csr_cmplt/rdata`、`biu_csr_sel_ff` | `:125-130` |
| other_io_sync | 实际 2 个 `gated_clk_cell`（`l2reg_out/in`）；APB 两个例化仅存在于注释 | `:218-265` |

---

## 4. req_arbiter：读写请求仲裁

### 4.1 读仲裁：LSU > IFU（核心，`req_arbiter.v:433-436`）

```verilog
assign ifu_ar_req   = ifu_biu_rd_req && !lsu_biu_ar_dp_req;  // IFU 只有在 LSU 不请求时才赢
assign lsu_ar_req   = lsu_biu_ar_req &&  lsu_biu_ar_dp_req;  // LSU 请求(带 dp_req)
assign arvalid      = ifu_ar_req || lsu_ar_req;
assign arvalid_gate = ifu_ar_req || lsu_biu_ar_dp_req;
```

精确地说，只要 `lsu_biu_ar_dp_req=1`，IFU 就被屏蔽；即使此时
`lsu_biu_ar_req=0`，`arvalid` 也可能为 0，IFU 仍不会被选择。`dp_req` 因而是
选择/数据路径活动条件，不应直接翻译为一笔已经有效的 LSU 请求。

RTL 只能证明这个固定优先关系。常见设计动机是优先处理阻塞执行的数据访问，但 IFU
缺失同样可能停住全前端，实际收益取决于工作负载、缓冲水位和 miss 并发。不能把
“LSU 一定更迫切”写成源码已经证明的事实。

### 4.2 读请求字段拼装（`req_arbiter.v:462-494`）

二选一 MUX，按 `lsu_biu_ar_dp_req` 决定取 IFU 还是 LSU 的字段。最关键的是 **ID 拼装**：

```verilog
if(!lsu_biu_ar_dp_req) begin            // IFU 路
  arid[4:0]  = {4'b1000, ifu_biu_rd_id};// → 5'b10000 refill / 5'b10001 prefetch
  arsnoop    = ifu_biu_rd_snoop;        // ReadNoSnoop
  ardomain   = ifu_biu_rd_domain;       // non-shareable
  aruser     = {1'b0, ifu_biu_rd_user}; // {mmode, mmu}
end else begin                          // LSU 路
  arid[4:0]  = lsu_biu_ar_id[4:0];      // LSU 自带完整 5 位 ID
  ...
end
```

这就是 overview 通用思想①的源头：BIU 在仲裁阶段就给 IFU 请求**盖上 5'b1000x 的名牌**，
read_channel 回来时才能靠 `rid` 把数据认回 IFU（见 [01_biu_read_write.md](01_biu_read_write.md) 第 5 节）。

接收反馈（`:497-498`）：

```verilog
assign biu_ifu_rd_grnt  = ifu_ar_req && arready;  // IFU 赢了且缓冲能收
assign biu_lsu_ar_ready = arready;
```

因此 `biu_ifu_rd_grnt=1` 可以直接视为 IFU 请求在 BIU 输入边界被接受；
`biu_lsu_ar_ready=1` 只表示地址槽可收，LSU 接受事件还需
`lsu_biu_ar_req && lsu_biu_ar_dp_req && biu_lsu_ar_ready`。

### 4.3 写仲裁：store 与 victim 分两路直通（`req_arbiter.v:501-553`）

写**只有 LSU 一个源**，但分 store(WMB) 和 victim(VB) 两路。req_arbiter 在这里**不做优先级合并**，
而是把两路原样透传给 write_channel 的两个缓冲（victim>store 的优先级在 write_channel 里裁，
见 [01](01_biu_read_write.md) 第 7.2 节）：

```verilog
assign vict_awvalid = lsu_biu_aw_vict_req;   assign vict_awid = lsu_biu_aw_vict_id; ...
assign st_awvalid   = lsu_biu_aw_st_req;     assign st_awid   = lsu_biu_aw_st_id;   ...
assign biu_lsu_aw_vb_grnt  = vict_awready;   // victim 地址槽可收
assign biu_lsu_aw_wmb_grnt = st_awready;     // store 地址槽可收
```

W 数据通道同理两路直通（`:540-553`）。这些 `grnt` 名字容易误导：RTL 直接输出
`ready`，源必须与自己的 valid/req 组合后才得到接受事件。`req_arbiter` 负责读选择和
字段拼装，`write_channel` 负责 AW 输出选择以及 W 来源顺序。

---

## 5. csr_req_arbiter：CSR 仲裁（CP0 > HPCP）

### 5.1 是什么

C910 把一组经 BIU 送往 L2 边界的控制/状态访问暴露给两个核内源：

- **CP0**：提供 `sel/op/wdata`。
- **HPCP**：也提供 `sel/op/wdata`。

仅从本仲裁器无法枚举每个 op 的具体寄存器语义；应以 L2 CSR 解码 RTL 为准。

### 5.2 优先级：CP0 > HPCP（`csr_req_arbiter.v:78-89`）

```verilog
if(cp0_biu_sel) begin                  // CP0 优先
  biu_csr_sel   = 1'b1;
  biu_csr_op    = cp0_biu_op;
  biu_csr_wdata = cp0_biu_wdata;
end else begin                         // 否则给 HPCP
  biu_csr_sel   = hpcp_biu_sel;
  biu_csr_op    = hpcp_biu_op;
  biu_csr_wdata = hpcp_biu_wdata;
end
```

RTL 事实只是组合 MUX 在 `cp0_biu_sel=1` 时选择 CP0。把原因解释为“架构控制优先于
性能计数”是合理推测，但本文件没有仲裁状态、等待计数或公平机制，也没有证明 HPCP
只读或只延迟一两拍。若 CP0 长期保持 sel，HPCP 可以长期不被选择。

### 5.3 响应回送（`csr_req_arbiter.v:93-96`）

```verilog
assign biu_cp0_cmplt  = biu_csr_cmplt && cp0_biu_sel;  // 只有 CP0 发起时才回 CP0 完成
assign biu_cp0_rdata  = biu_csr_rdata;
assign biu_hpcp_cmplt = biu_csr_cmplt;                 // HPCP 完成(注意未 &hpcp_sel)
assign biu_hpcp_rdata = biu_csr_rdata;
```

这里没有锁存“本次请求属于谁”的 owner 位：

- `biu_cp0_cmplt` 用**完成当拍的实时** `cp0_biu_sel` 限定；
- `biu_hpcp_cmplt` 对每个 `biu_csr_cmplt` 都拉高，不检查 `hpcp_biu_sel`；
- 两路 rdata 始终共享同一返回总线。

因此正确归属依赖更上层协议，例如请求源在完成前保持 sel、两个源不交叠，或 HPCP
忽略不属于自己的 completion。不能写成仲裁器自身“保证完成回到正确发起者”。

---

## 6. lowpower：每通道门控 + no_op

### 6.1 是什么

lowpower 为多个局部状态组例化 `gated_clk_cell`。结构上具备细粒度门控条件，
但并非每个逻辑空闲时都一定停钟：例如 `write_b_clk_en` 恒为 1，
`snoop_ac_clk_en` 也因时序考虑忽略 `acvalid`。实际动态功耗收益需门级/功耗分析确认。

还必须区分编译分支：

- 未定义 `C910_USE_TSMC28_ICG` 时，`gated_clk_cell.v:56` 直接令
  `clk_out = clk_in`，所有 `local_en/module_en/scan_en` 都不改变输出时钟。常见 RTL
  仿真会落入这一分支，所以波形中门控后时钟可能始终跟随输入；
- `backend/flist/ct_top_dc.f:6` 定义 `C910_USE_TSMC28_ICG`。该 DC 配置实例化
  `CKLNQD4BWP12T40P140`，门控意图才由工艺 ICG 落地；
- 因而“RTL 写了 gated_clk_cell”“仿真中时钟真的停”“综合后实现了 ICG”是三件不同的事。

### 6.2 12 个门控时钟（`lowpower.v:122-350`）

| 时钟输出 | 使能 | 时钟源 | 服务对象 | 出处 |
|----------|------|--------|----------|------|
| `arcpuclk` | `read_ar_clk_en` | coreclk | 读地址缓冲 | `:122-130` |
| `rcpuclk` | `read_r_clk_en` | coreclk | 读数据缓冲 | `:141-149` |
| `vict_awcpuclk` | `vict_aw_clk_en` | coreclk | victim 写地址 | `:162-170` |
| `st_awcpuclk` | `st_aw_clk_en` | coreclk | store 写地址 | `:181-189` |
| `vict_wcpuclk` | `vict_w_clk_en` | coreclk | victim 写数据 | `:200-208` |
| `st_wcpuclk` | `st_w_clk_en` | coreclk | store 写数据 | `:219-227` |
| `round_wcpuclk` | `round_w_clk_en` | coreclk | round 写数据 | `:238-246` |
| `bus_arb_w_fifo_clk` | `bus_arb_w_fifo_clk_en` | coreclk | 写 FIFO | `:257-265` |
| `bcpuclk` | `write_b_clk_en` | coreclk | 写响应 | `:275-283` |
| `accpuclk` | `snoop_ac_clk_en` | **forever_coreclk** | 侦听地址 | `:296-304` |
| `crcpuclk` | `snoop_cr_clk_en` | coreclk | 侦听响应 | `:315-323` |
| `cdcpuclk` | `snoop_cd_clk_en` | coreclk | 侦听数据 | `:334-342` |

**注意 `accpuclk` 用 `forever_coreclk` 而非 `coreclk`**（`:297`），使 AC 路径不依赖
普通 core clock 保持运行。`forever_coreclk` 不是另一个异步频率域；它是另一路
时钟可用性/门控层级。其余门控时钟从 `coreclk` 派生。

两个容易忽略的细节：

- `write_b_clk_en = 1'b1`（`write_channel.v:1056`），所以只要模块级门控配置允许，
  B 通道门控单元没有本地空闲关钟机会；
- `snoop_ac_clk_en = cur_acaddr_buf_ready || lsu_biu_ac_ready`
  （`snoop_channel.v:521-522`），注释明确为时序而忽略 `acvalid`。缓冲未满时该使能通常为 1。

### 6.3 no_op：本地读写空闲组合（`lowpower.v:353`）

```verilog
assign biu_yy_xx_no_op = !read_busy && !write_busy;
```

- `read_busy`（`read_channel.v:732-735`）= 读地址缓冲有效 || 读数据缓冲有效 || rack_valid || rack_pending。
- `write_busy`（`write_channel.v:1059-1063`）= 写地址 || 写数据 || 写响应 || back_valid || back_pending。

只有 `read_busy=0 && write_busy=0` 时，`no_op` 才为 1。但这不能解释成“没有在途事务”：

- AR/AW 一旦离开本地地址缓冲，对应响应尚未回来时，BIU 未必保存完整 outstanding 位；
- 写来源队列非空但当前所选数据槽无 valid 时，`cur_wdata_buf_wvalid` 可为 0；
- snoop、CSR、中断和调试都不进入该表达式。

所以 `no_op` 是上层低功耗协议使用的**本地条件之一**，不是独立的全局 quiescence 证明。
`biu_xx_snoop_vld` 另行提供 snoop 活动提示，但也不是精确计数。

### 6.4 gated_clk_cell 的四个使能

在工艺 ICG 分支中，锁存前使能精确为：

```verilog
clk_en_bf_latch = (global_en && (module_en || local_en)) || external_en;
SE = pad_yy_icg_scan_en;
```

BIU 例化中 `global_en=1`、`external_en=0`，所以功能使能化简为
`cp0_biu_icg_en || local_en`。也就是说 `cp0_biu_icg_en=1` 会强制相应局部时钟开启，
而不是“只有模块允许且 local 有活动才开”；`local_en=1` 也能独立开钟。扫描 `SE`
由工艺 ICG 的测试使能端处理。未定义工艺宏时，上述使能均被直通分支旁路。

---

## 7. other_io_sync：同步器与边界寄存

### 7.1 是什么

这个模块处理通道之外的中断、调试请求、计时器、核 ID、复位向量基址、APB 基址、
低功耗/计数控制和 L2 CSR 边界信号。只有中断与调试请求在本文件中明确使用两级触发器；
其它信号不能因为模块名带 `sync` 就全部称为 CDC 同步。

### 7.2 中断 2 级同步（`other_io_sync.v:323-363`）

```verilog
always @(posedge forever_coreclk ...) begin
  cp0_me_int_ff1 <= pad_biu_me_int;    // 第 1 级
  cp0_me_int_ff2 <= cp0_me_int_ff1;    // 第 2 级
  ... (mt/ms/se/st/ss 同样 2 级)
end
assign biu_cp0_me_int = cp0_me_int_ff2;          // 取第 2 级输出
assign biu_xx_int_wakeup = ff2 们的或;            // 任一中断都能唤醒核
```

双触发器链是单比特异步电平的常见 CDC 结构：第一级承担亚稳态风险，第二级降低
亚稳态传播概率。它不是数学上“保证稳定”，剩余 MTBF 取决于工艺、时钟和时序裕量；
它也不适合未经脉宽约束的窄脉冲或多比特总线。这里使用 `forever_coreclk`，使普通
core clock 被门控时同步链仍可更新并产生 wakeup。

### 7.3 调试请求同步（`other_io_sync.v:368-382`）

```verilog
had_sdb_req_b_ff1 <= pad_biu_dbgrq_b;   // 同样 2 级
had_sdb_req_b_ff2 <= had_sdb_req_b_ff1;
assign biu_had_sdb_req_b = had_sdb_req_b_ff2;
assign biu_xx_dbg_wakeup = !had_sdb_req_b_ff2;   // 调试也能唤醒核
```

注意复位值是 `1'b1`（`:371-372`），因为 `dbgrq_b` 低有效，复位时应为"无请求"。

### 7.4 L2 CSR 边界寄存与脉冲化（`other_io_sync.v:236-314`）

这里的两个门控时钟都由 `coreclk` 派生，当前模块没有独立 L2 时钟输入，因此仅凭
这段 RTL 不能称为异步跨域。它完成的是请求电平转脉冲和返回寄存：

```verilog
assign l2reg_oclk_en = biu_csr_sel | biu_csr_sel_ff;        // 有请求才开输出时钟
assign csr_sel_pulse = biu_csr_sel & !biu_csr_sel_ff;       // sel 上升沿 → 单拍脉冲
// 用脉冲触发 biu_pad_csr_sel / biu_pad_csr_wdata 锁存
assign l2reg_iclk_en = pad_biu_csr_cmplt | biu_csr_cmplt;   // 有响应才开输入时钟
// biu_csr_cmplt / biu_csr_rdata 锁存 L2 返回
```

`csr_sel_pulse` 只在 `biu_csr_sel` 从 0 变 1 时产生。因此源若要连续发两笔请求，
必须让 sel 中间回到 0；保持 sel 不会重复发。返回侧在 `pad_biu_csr_cmplt` 为 1 时采样
128 位 rdata。该逻辑没有请求队列、busy 或 owner 锁存，“不丢不重”依赖源/目的端
遵守单笔请求协议。

### 7.5 计时器与配置直通（`other_io_sync.v:198-214, 388-391`）

实现方式必须逐项区分：

- hart ID 直接组合连接，没有寄存；
- RVBA、APB base 和 `pad_xx_time` 在 `coreclk` 上单级采样，且这些 always 块没有复位；
- `lpmd/jdb_pm/cnt_en/l2of_int` 在 `forever_coreclk` 上单级寄存；
- `biu_mmu_smp_disable` 与 `biu_xx_pmp_sel` 在当前配置恒为 0。

这些多比特信号若来自异步域，单级逐位采样不能保证总线相干。RTL 隐含的前提应是
同域或满足系统级稳定窗口；文档不能用“慢变”自行替代该接口约束。

---

## 本章小结

BIU 仲裁与低功耗逻辑把多源请求选择、事务身份标记、局部时钟活动和外部控制同步连接在一起。请求仲裁中，LSU `dp_req` 会屏蔽 IFU，CSR MUX 由 CP0 选择，写地址 MUX 在 victim valid 时选择 victim；这些是 RTL 可直接证明的固定关系。IFU 请求还在最上游被拼接为 `5'b1000x` AXI ID，使返回路径能够按身份分类。固定优先级可能影响等待时间，但“某请求更迫切”或“优先级一定提升总体性能”属于架构解释和待测假设，不能由选择表达式本身证明。

低功耗模块实例化多个门控单元并汇总本地 `no_op`，但实例数量不等于行为级仿真一定能看到同等数量的独立停钟。通用 `gated_clk_cell` 分支可能直接透传输入时钟，工艺分支中某些通道又使用恒定或较宽的 local enable；因此逻辑门控意图、RTL 波形和物理功耗效果必须分层判断。AC 活动、中断和调试使用 `forever_coreclk`，保证关键唤醒条件不依赖普通 core clock 已经开启，但这也不代表整个处理链或电源域永不关闭。跨域方面，只有中断和调试明确使用两级同步，多位配置与计时信号则采用直连或单级采样，其稳定性依赖 SoC 集成契约。分析波形时应同时检查源请求、仲裁结果、ID、门控使能和目标握手，才能区分“没有事务”“事务被更高优先级阻塞”和“时钟域尚未允许观察”。
