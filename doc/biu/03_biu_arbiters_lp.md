# C910 BIU 仲裁器、低功耗与跨域同步 模块详细教学文档

> 本文档解析 BIU 的四个"配套"模块：
> `ct_biu_req_arbiter.v`（567 行，读写请求仲裁）、
> `ct_biu_csr_req_arbiter.v`（101 行，CSR 仲裁）、
> `ct_biu_lowpower.v`（360 行，门控时钟 + no_op）、
> `ct_biu_other_io_sync.v`（445 行，中断/调试/计时器跨时钟域同步）。
> 它们不直接搬运 ACE 数据，但决定"谁能上总线、什么时候省电、跨域信号怎么不出错"。

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [req_arbiter：读写请求仲裁](#4-req_arbiter读写请求仲裁)
5. [csr_req_arbiter：CSR 仲裁（CP0 > HPCP）](#5-csr_req_arbitercsr-仲裁cp0--hpcp)
6. [lowpower：每通道门控 + no_op](#6-lowpower每通道门控--no_op)
7. [other_io_sync：跨时钟域同步](#7-other_io_sync跨时钟域同步)
8. [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

| 模块 | 一句话职责 |
|------|-----------|
| `req_arbiter` | 把 IFU/LSU 的读、LSU 的 store/victim 写整理成统一的 ar/aw 总线信号，并决定读优先级 |
| `csr_req_arbiter` | 在 CP0 与 HPCP 两个 CSR 访问源之间选一个，发给 L2 CSR |
| `lowpower` | 为每个通道生成独立门控时钟，并综合出"全空闲" no_op 信号 |
| `other_io_sync` | 把中断/调试/计时器等单比特或慢速信号跨时钟域同步进核，并寄存 L2 CSR 读写 |

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
| 读授权 | `biu_ifu_rd_grnt` / `biu_lsu_ar_ready` | out | 通知源被授权（`:239-240`） |
| LSU store 写输入 | `lsu_biu_aw_st_*` / `lsu_biu_w_st_*` | in | store 写地址/数据（`:181-195,211-215`） |
| LSU victim 写输入 | `lsu_biu_aw_vict_*` / `lsu_biu_w_vict_*` | in | victim 写地址/数据（`:196-219`） |
| 写输出 | `st_aw*/st_w*` / `vict_aw*/vict_w*` | out | 送 write_channel 两路（`:245-284`） |
| 写授权 | `biu_lsu_aw_vb_grnt/aw_wmb_grnt/w_vb_grnt/w_wmb_grnt` | out | victim/store 各自授权（`:241-244`） |

### 2.2 csr_req_arbiter

| 信号 | 方向 | 含义 |
|------|------|------|
| `cp0_biu_sel/op/wdata` | in | CP0 的 CSR 访问（`csr_req_arbiter.v:36-38`） |
| `hpcp_biu_sel/op/wdata` | in | HPCP 的 CSR 访问（`:39-41`） |
| `biu_csr_sel/op/wdata` | out | 仲裁后统一送出（`:44-46`） |
| `biu_csr_cmplt/rdata` | in | L2 CSR 完成/读数据（`:34-35`） |
| `biu_cp0_cmplt/rdata` / `biu_hpcp_cmplt/rdata` | out | 回送两个源（`:42-43,47-48`） |

### 2.3 lowpower

| 信号 | 方向 | 含义 |
|------|------|------|
| `coreclk/forever_coreclk/cp0_biu_icg_en/pad_yy_icg_scan_en` | in | 时钟源与门控控制（`lowpower.v:51-53,66`） |
| `*_clk_en`（read_ar/read_r/st_aw/st_w/vict_aw/vict_w/round_w/snoop_ac/cr/cd/bus_arb_w_fifo/write_b） | in | 各通道使能（`:50-67`） |
| `*cpuclk`（arcpuclk/rcpuclk/st_awcpuclk/.../accpuclk/crcpuclk/cdcpuclk/bcpuclk） | out | 各通道门控后时钟（`:68-80`） |
| `read_busy/write_busy` | in | 通道忙标志（`:56,67`） |
| `biu_yy_xx_no_op` | out | 全空闲标志（`:71`） |

### 2.4 other_io_sync

| 组 | 信号 | 方向 | 含义 |
|----|------|------|------|
| 中断输入 | `pad_biu_me/ms/mt/se/ss/st_int` | in | 6 种中断（`other_io_sync.v:83-88`） |
| 中断输出 | `biu_cp0_me/ms/mt/se/ss/st_int`、`biu_xx_int_wakeup` | out | 同步后给 CP0（`:96-102,116`） |
| 调试 | `pad_biu_dbgrq_b` → `biu_had_sdb_req_b`/`biu_xx_dbg_wakeup` | in/out | 调试请求同步（`:81,106,115`） |
| 核 ID/RVBA/APB base | `pad_core_hartid/pad_core_rvba/pad_xx_apb_base` | in | 配置信息（`:89-91`） |
| 计时器 | `pad_xx_time` → `biu_hpcp_time` | in/out | 64 位系统计时（`:92,108`） |
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
| other_io_sync | 3 个 `gated_clk_cell`（l2reg_out/in，注释中还有 apbif） | `:238-265` |

---

## 4. req_arbiter：读写请求仲裁

### 4.1 读仲裁：LSU > IFU（核心，`req_arbiter.v:433-436`）

```verilog
assign ifu_ar_req   = ifu_biu_rd_req && !lsu_biu_ar_dp_req;  // IFU 只有在 LSU 不请求时才赢
assign lsu_ar_req   = lsu_biu_ar_req &&  lsu_biu_ar_dp_req;  // LSU 请求(带 dp_req)
assign arvalid      = ifu_ar_req || lsu_ar_req;
assign arvalid_gate = ifu_ar_req || lsu_biu_ar_dp_req;
```

`!lsu_biu_ar_dp_req` 这一项就是优先级的全部秘密：**只要 LSU 在请求读，IFU 就被压住。**

**为什么 LSU > IFU？** 数据缺失通常直接挂着一条正在执行的 load/store 指令，
它堵在流水线关键路径上；取指缺失虽然也重要，但 IFU 前端有预测和缓冲（IBUF/LBUF）缓冲气泡，
更"扛得住等"。所以把总线读带宽优先让给 LSU。

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

授权信号（`:497-498`）：

```verilog
assign biu_ifu_rd_grnt  = ifu_ar_req && arready;  // IFU 赢了且缓冲能收
assign biu_lsu_ar_ready = arready;
```

### 4.3 写仲裁：store 与 victim 分两路直通（`req_arbiter.v:501-553`）

写**只有 LSU 一个源**，但分 store(WMB) 和 victim(VB) 两路。req_arbiter 在这里**不做优先级合并**，
而是把两路原样透传给 write_channel 的两个缓冲（victim>store 的优先级在 write_channel 里裁，
见 [01](01_biu_read_write.md) 第 7.2 节）：

```verilog
assign vict_awvalid = lsu_biu_aw_vict_req;   assign vict_awid = lsu_biu_aw_vict_id; ...
assign st_awvalid   = lsu_biu_aw_st_req;     assign st_awid   = lsu_biu_aw_st_id;   ...
assign biu_lsu_aw_vb_grnt  = vict_awready;   // victim 缓冲空 → 授权
assign biu_lsu_aw_wmb_grnt = st_awready;     // store 缓冲空 → 授权
```

W 数据通道同理两路直通（`:540-553`）。**职责切分**：req_arbiter 管读的优先级和字段拼装，
write_channel 管写的保序和 victim 优先——各司其职。

---

## 5. csr_req_arbiter：CSR 仲裁（CP0 > HPCP）

### 5.1 是什么

C910 把 L2 Cache 的控制/状态寄存器（CSR）暴露给两个核内源：

- **CP0**（系统控制协处理器）：架构级配置（cache 使能、刷新等）。
- **HPCP**（Hardware Performance Counter，硬件性能计数器）：读 L2 的性能事件计数。

两者可能同时想访问 L2 CSR，必须二选一。

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

**为什么 CP0 优先？** CP0 是架构可见的控制路径，可能正在做 cache 维护这类必须及时生效的操作；
HPCP 只是读计数器，延后一两拍无伤大雅。这与"读 LSU>IFU、写 victim>store"一脉相承——
**优先级永远偏向"更基础/更迫切"的那一方。**

### 5.3 响应回送（`csr_req_arbiter.v:93-96`）

```verilog
assign biu_cp0_cmplt  = biu_csr_cmplt && cp0_biu_sel;  // 只有 CP0 发起时才回 CP0 完成
assign biu_cp0_rdata  = biu_csr_rdata;
assign biu_hpcp_cmplt = biu_csr_cmplt;                 // HPCP 完成(注意未 &hpcp_sel)
assign biu_hpcp_rdata = biu_csr_rdata;
```

读数据是共享线，cmplt 才是真正的"认领"信号——`biu_cp0_cmplt` 带 `cp0_biu_sel` 限定，
保证完成回到正确的发起者。仲裁后的请求经 `other_io_sync` 寄存再发往 pad（见下节）。

---

## 6. lowpower：每通道门控 + no_op

### 6.1 是什么

lowpower 为 BIU 每个通道单独例化一个 `gated_clk_cell`（门控时钟单元），
让**空闲通道单独熄火**，而不是整个 BIU 一起开关——粒度细，省电更彻底。

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

**注意 `accpuclk` 用 `forever_coreclk` 而非 `coreclk`**（`:297`）：侦听请求随时可能从核外到来，
即使核已门控休眠，AC 通道也必须能醒来接收（详见 [02_biu_snoop.md](02_biu_snoop.md) 第 4.3/7 节）。
其余通道都是核主动发起的，核休眠时本就不会有请求，可用普通 `coreclk`。

### 6.3 no_op：全空闲信号（`lowpower.v:353`）

```verilog
assign biu_yy_xx_no_op = !read_busy && !write_busy;
```

- `read_busy`（`read_channel.v:732-735`）= 读地址缓冲有效 || 读数据缓冲有效 || rack_valid || rack_pending。
- `write_busy`（`write_channel.v:1059-1063`）= 写地址 || 写数据 || 写响应 || back_valid || back_pending。

只有读写**都彻底没有在途事务**时，`no_op` 才为 1，告诉核级电源管理"BIU 这边干净了，可以进更深的低功耗"。
注意 no_op **不看 snoop**——因为侦听由 `biu_xx_snoop_vld` 单独管（snoop 期间另有刹车），二者分工。

### 6.4 gated_clk_cell 的四个使能

每个门控单元有 `global_en`（恒 1）、`module_en`（`cp0_biu_icg_en` 模块总开关）、
`local_en`（本通道使能）、`external_en`（恒 0）+ `pad_yy_icg_scan_en`（扫描旁路）。
逻辑上 `clk_out` 仅当模块允许门控且本通道有活时才翻转——这是 C910 全核统一的门控范式。

---

## 7. other_io_sync：跨时钟域同步

### 7.1 是什么

这个模块处理"通道之外"的杂项 IO：中断、调试请求、计时器、核 ID、L2 CSR 寄存。
其中**中断和调试是从片外（可能异步）来的单比特信号**，直接进核会引发亚稳态，必须同步。

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

**为什么 2 级 FF？** 这是标准 CDC（Clock Domain Crossing）打拍同步：
第 1 级 FF 可能因为输入在采样窗口翻转而进入亚稳态，但给它一整个周期沉降，
到第 2 级时已稳定。两级足以把亚稳态概率压到可忽略。用 `forever_coreclk` 是因为
**中断必须能在核休眠时把核叫醒**（`biu_xx_int_wakeup`），所以同步链不能被门控。

### 7.3 调试请求同步（`other_io_sync.v:368-382`）

```verilog
had_sdb_req_b_ff1 <= pad_biu_dbgrq_b;   // 同样 2 级
had_sdb_req_b_ff2 <= had_sdb_req_b_ff1;
assign biu_had_sdb_req_b = had_sdb_req_b_ff2;
assign biu_xx_dbg_wakeup = !had_sdb_req_b_ff2;   // 调试也能唤醒核
```

注意复位值是 `1'b1`（`:371-372`），因为 `dbgrq_b` 低有效，复位时应为"无请求"。

### 7.4 L2 CSR 寄存与脉冲化（`other_io_sync.v:236-314`）

CSR 请求/响应跨到 L2 域，这里用门控时钟 + 边沿脉冲处理：

```verilog
assign l2reg_oclk_en = biu_csr_sel | biu_csr_sel_ff;        // 有请求才开输出时钟
assign csr_sel_pulse = biu_csr_sel & !biu_csr_sel_ff;       // sel 上升沿 → 单拍脉冲
// 用脉冲触发 biu_pad_csr_sel / biu_pad_csr_wdata 锁存
assign l2reg_iclk_en = pad_biu_csr_cmplt | biu_csr_cmplt;   // 有响应才开输入时钟
// biu_csr_cmplt / biu_csr_rdata 锁存 L2 返回
```

把电平 `sel` 转成单拍 `pulse`（`:282`），避免向 L2 重复发请求；输入侧把 L2 的 cmplt/rdata 寄存一拍
再回 csr_req_arbiter。这样 CSR 访问就被干净地"打包"成请求脉冲 + 响应寄存，跨域不丢不重。

### 7.5 计时器与配置直通（`other_io_sync.v:198-214, 388-391`）

核 ID（`:198-199`）、RVBA 复位向量基址（`:204-207`）、APB base（`:211-214`）、
计时器（`:388-391`）这些都是慢变或上电即定的配置，单级寄存（甚至直接接线）即可，无需 2 级同步。

---

## 设计取舍小结

1. **优先级三连贯彻同一哲学**：读 LSU>IFU（`req_arbiter.v:433`）、CSR CP0>HPCP（`csr_req_arbiter.v:78`）、
   写 victim>store（write_channel）——永远偏向"更迫切/更基础"的请求。

2. **仲裁器在前盖 AXI ID 名牌**：req_arbiter 给 IFU 请求拼 `5'b1000x`（`:465`），
   是乱序分发能成立的前提，把 overview 通用思想①落到最上游。

3. **门控粒度细到每通道**：12 个独立 `gated_clk_cell`，空闲通道单独熄火；
   `no_op = !read_busy && !write_busy` 综合出全空闲，给核级电源管理。

4. **AC/中断/调试用 forever_coreclk**：凡是"核外随时可能来、必须能叫醒休眠核"的信号
   （侦听、中断、调试），其时钟都不可门控——这是低功耗与响应能力之间的硬约束。

5. **跨域一律 2 级 FF**：中断/调试用标准双触发器同步防亚稳态；CSR 用脉冲化 + 寄存打包。
   BIU 把所有 CDC 风险集中到 other_io_sync 一处处理，其余模块可假设输入已同步。

---

*文档覆盖 ct_biu_req_arbiter.v 全部 567 行、ct_biu_csr_req_arbiter.v 全部 101 行、ct_biu_lowpower.v 全部 360 行、ct_biu_other_io_sync.v 全部 445 行逻辑。*
