# C910 L2C 预取 / 核间一致性 / 写回 模块详细教学文档

> RTL 文件：`ct_l2c_prefetch.v`（约 262 行，硬件预取引擎）、`ct_l2c_icc.v`（约 882 行，核间一致性 / 维护 / DCA / flush 引擎）、`ct_l2c_wb.v`（约 320 行，写回 / 响应组装 + rfifo）
> 配置：`cpu/rtl/cpu_cfig.h`（`L2C_TAG_INDEX_WIDTH=9`、`L2C_DATA_INDEX_WIDTH=13`）
> 本篇讲 L2C 的三个“旁路 / 收尾”模块：流水第④级 **wb**（组装返回 CIU 的数据/响应）、第⑤级 **icc**（与主流水仲裁共享 RAM 端口的维护引擎）、以及顶层共享的 **prefetch**（指令/TLB 预取）。前三级 tag/cmp/data 见 `01`/`02`/`03`。

## 目录
- [1. 模块概述](#1-模块概述)
- [2. 端口说明](#2-端口说明)
- [3. 参数与关键寄存器](#3-参数与关键寄存器)
- [4. prefetch：指令 + TLB 下一行预取](#4-prefetch指令--tlb-下一行预取)
- [5. icc：13 态维护 FSM 总览](#5-icc13-态维护-fsm-总览)
- [6. icc：flush/clean/invalidate 的 index/way 遍历](#6-iccflushcleaninvalidate-的-indexway-遍历)
- [7. icc：DCA 直接缓存访问](#7-iccdca-直接缓存访问)
- [8. icc：脏行回写（RDL）与 RAM 端口仲裁](#8-icc脏行回写rdl与-ram-端口仲裁)
- [9. wb：响应组装与 14 位 rfifo](#9-wb响应组装与-14-位-rfifo)
- [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

| 模块 | 流水位置 | 职责 |
|------|----------|------|
| `ct_l2c_prefetch` | 顶层共享（非流水级） | 监听两 bank 的 cmp 级 miss 信号，对**下一行**发硬件预取；区分指令预取（深度可配 1~3）与 TLB 页表预取 |
| `ct_l2c_icc` | 流水第⑤级（旁路引擎） | 核间一致性维护：clean/invalidate **全缓存遍历**、DCA 直接读写 tag/data/ECC、SoC flush；与 cmp 主流水**仲裁共享** tag/dirty/data RAM 端口 |
| `ct_l2c_wb` | 流水第④级 | 把 data 级读出的 512 位整行 + 随路 sid/resp/cp 组装成返回 CIU 的完成响应；用 **3 深 rfifo** 缓存“无数据的纯响应”（如维护完成） |

### 1.2 三者在流水中的位置

```
                              ┌─ ct_l2c_prefetch ◄── cmp_pref_*（两 bank 的 miss 信号）
                              │      └─► l2c_ciu_prf_*（下一行预取请求）
ct_l2c_cmp(②) ─cmp_data_*─► ct_l2c_data(③) ─data_stage_*/dout_flop─► ct_l2c_wb(④) ─► l2c_ciu_cmplt/data/resp
       │ cmp_rfifo_* ─────────────────────────────────────────────────► (wb rfifo)
       │
ciu_l2c_ctcq/dca/rst/flush_req ─► ct_l2c_icc(⑤) ─icc_tag_*/icc_data_*─► 抢占 tag/data RAM 端口
                                        └─► l2c_ciu_ctcq/dca/rdl_*（维护完成 / DCA 数据 / 脏行回写）
```

---

## 2. 端口说明

### 2.1 prefetch（`ct_l2c_prefetch.v:17-66`）

| 组 | 端口 | 方向 | 含义 |
|----|------|------|------|
| 配置 | `ciu_l2c_iprf[1:0]`、`ciu_l2c_tprf`、`ciu_l2c_prf_ready` | in | 指令预取深度(0~3)、TLB 预取使能、下游接受预取 |
| bank0 触发 | `cmp_pref_vld/read/ifu_req/tlb_req/cache_miss_bank_0`、`cmp_pref_addr_bank_0[32:0]` | in | bank_0 cmp 级喂来的预取触发信息 |
| bank1 触发 | `..._bank_1` | in | bank_1 同上 |
| 预取输出 | `l2c_ciu_prf_addr[33:0]`、`l2c_ciu_prf_prot[2:0]`、`l2c_ciu_prf_vld` | out | 给 CIU 的预取地址/属性/有效 |
| 状态 | `prf_idle` | out | 预取引擎空闲 |

### 2.2 icc（`ct_l2c_icc.v:17` 起）

| 组 | 代表端口 | 方向 | 含义 |
|----|----------|------|------|
| 维护请求 | `ciu_l2c_ctcq_req_x`、`ciu_l2c_icc_type_x[1:0]`、`ciu_l2c_rst_req`、`l2c_flush_req_x` | in | CMO 维护队列、复位失效、SoC flush（`:85-98`） |
| DCA 请求 | `ciu_l2c_dca_req_x`、`ciu_l2c_dca_addr_x[32:0]`、`ciu_l2c_icc_mid_x[2:0]` | in | 直接缓存访问（`:86-88`） |
| 仲裁授权 | `tag_icc_grant`、`data_icc_grant` | in | tag/data RAM 端口授权（`:122,93`） |
| 写 tag/dirty | `icc_tag_cen/gwen/req`、`icc_tag_index[8:0]`、`icc_dirty_cen/gwen/wen[8:0]` | out | 维护时改 status/失效（`:129-137`） |
| 读/写 data | `icc_data_req/cen[4:0]/index[12:0]/flop` | out | 读脏行回写 / DCA 读数据（`:124-127`） |
| 完成响应 | `l2c_ciu_ctcq_cmplt/ready_x`、`l2c_ciu_dca_cmplt/ready_x`、`l2c_ciu_dca_data_x[127:0]`、`l2c_flush_done_x` | out | 维护/DCA/flush 完成回报（`:138-148`） |
| 脏行回写 | `l2c_ciu_rdl_addr_x[32:0]`、`l2c_ciu_rdl_dvld/rvld_x`、`l2c_ciu_rdl_mid/prot_x[2:0]` | out | 把脏行写回下游（`:143-147`） |

### 2.3 wb（`ct_l2c_wb.v:17-90`）

| 组 | 端口 | 方向 | 含义 |
|----|------|------|------|
| 来自 data 级 | `data_stage_cp/resp/sid[*]`、`data_stage_vld`、`data_yy_flop_vld`、`l2c_data_dout_flop[511:0]` | in | 随路属性 + 512 位整行（`:62-69`） |
| 来自 cmp 级 | `cmp_rfifo_create`、`cmp_rfifo_resp[4:0]`、`cmp_rfifo_cp[3:0]`、`cmp_rfifo_sid[4:0]` | in | 进 rfifo 的纯响应（`:56-59`） |
| 给 CIU | `l2c_ciu_cmplt_x`、`l2c_ciu_data_x[511:0]`、`l2c_ciu_resp_x[4:0]`、`l2c_ciu_cp_x[3:0]`、`l2c_ciu_sid_x[4:0]` | out | 完成 + 读数据 + 响应（`:73-77`） |
| 流水空闲 | `l2c_pipeline_rdy`、`rfifo_empty`、`wb_stage_vld` | out | 整条流水空（供 icc 判断可介入）（`:78-86`） |

---

## 3. 参数与关键寄存器

### prefetch（`ct_l2c_prefetch.v`）

| 名称 | 值 | file:line | 含义 |
|------|-----|-----------|------|
| `IDLE`/`PREF` | 1'b0/1'b1 | `:121-122` | 预取 2 态 FSM |
| `pref_state` | 1 | `:71` | FSM 态 |
| `pref_addr` | 34 | `:69` | 当前预取地址（含 bit0） |
| `pref_cnt` | 2 | `:70` | 剩余预取行数（指令预取最多 3） |
| `pref_tlb` | 1 | `:73` | 本次是 TLB 预取 |

### icc（`ct_l2c_icc.v`）

| 名称 | 值/位宽 | file:line | 含义 |
|------|---------|-----------|------|
| `icc_all_state` | 4 | `:159` | 维护 FSM 态（13 态见 §5） |
| `icc_index` | 9（`TAG_INDEX_LENTH`） | `:161` | 遍历所有组的索引计数器 |
| `icc_data_way` | 4 | `:160` | 当前处理路的 4 位编号 |
| `dirty_way_ptr` | 16 | `:157` | 当前脏路 one-hot 指针 |
| `icc_status_vld/dirty` | 各 16 | `:163-164` | 当前组 16 路的 valid/dirty 快照 |
| `dca_index_f/way_f/type_f/offset_f` | 14/4/4/2 | `:152-156` | DCA 请求锁存 |

### wb（`ct_l2c_wb.v`）

| 名称 | 值/位宽 | file:line | 含义 |
|------|---------|-----------|------|
| `wb_stage_vld` | 1 | `:96` | wb 级有效（有数据要返回） |
| `wb_stage_sid/resp/cp` | 5/5/4 | `:93-95` | 随数据返回的属性 |
| `wb_stage_data` | 512 | `:144`（= `l2c_data_dout_flop`，`:217`） | 返回 CIU 的整行 |
| rfifo 宽/深 | WIDTH=14 / DEPTH=3 | `:242` | 响应 FIFO |

---

## 4. prefetch：指令 + TLB 下一行预取

`ct_l2c_prefetch` 是两 bank 共享的预取引擎，思路是 **“某 bank 读 miss → 对下一行（addr+1 cache line）发预取”**。

### 4.1 两种预取使能（`:156-169`）

```verilog
ciu_ipref_en = (ciu_l2c_iprf[1:0] != 2'b00);   // 指令预取深度非 0 :156
ciu_tpref_en = (ciu_l2c_tprf != 1'b0);          // TLB 预取使能     :157

pref_en_0 = cmp_pref_vld_bank_0 & cmp_pref_read_bank_0 &
            (cmp_pref_ifu_req_bank_0 & ciu_ipref_en |     // 指令取指 miss
             cmp_pref_tlb_req_bank_0 & ciu_tpref_en) &    // TLB 取页表 miss
            cmp_pref_cache_miss_bank_0;                    // 且确实 miss  :159-163
```

bank_1 同理（`:165-169`）。两个条件来自 cmp 级（`03` 篇 §6：`cmp_pref_ifu_req=src[0]`、`cmp_pref_tlb_req=src[1]`、`cmp_pref_read`、`cmp_pref_cache_miss`）。

`pref_en = (pref_en_0 || pref_en_1) && !cmp_pref_addr_cross_page`（`:171`）——**跨页不预取**（避免预取到没映射的页）。

### 4.2 两态 FSM（`:148-199`）

```
IDLE ──pref_en──► PREF
  ▲                 │ 每拍 ciu_accepted 发一行、pref_cnt--
  └─ ciu_accepted & (pref_last | cross_page) ─┘
```

- `pref_addr_update = pref_en && (state==IDLE)`（`:201`）：进 PREF 时载入预取地址与计数。
- 地址选择（`:210-217`）：哪个 bank miss 就取哪个 bank 的地址 `+0`/`+1` 拼成 34 位（bit0 标 bank），`cmp_pref_addr = addr + 1`（`:222`）即下一行。
- 计数 `pref_cnt`（`:225-251`）：TLB 预取固定 1 行（`pref_cnt=0`）；指令预取取 `iprf_cnt = ciu_l2c_iprf - 1`（`:225,239`），即深度 1~3 行连发。
- `cross_page`（`:255` / `:220`）用 addr bit[6] 异或判断是否跨过 64B×64=4KB 页边界，跨页则停。
- 输出 `l2c_ciu_prf_prot = {!pref_tlb, 2'b11}`（`:126`）：bit2 区分指令/TLB。

> 设计要点：预取是**纯下一行（next-line）**策略，简单有效；指令流顺序性强，深度可配 1~3 行；TLB 页表只预取 1 行；跨页一律停。

---

## 5. icc：13 态维护 FSM 总览

`ct_l2c_icc` 是与主流水**并行的维护引擎**。它处理三类请求（`:405-407`）：

```verilog
inv_all     = ctcq_req & icc_type[0] | rst_req | flush_req;  // 失效全缓存 :405
cln_all     = ctcq_req & icc_type[1] | flush_req;             // 清(写回)全缓存 :406
cln_inv_all = inv_all | cln_all;                              // :407
```

外加 DCA（`:410-413`）。状态机 `icc_all_state[4:0]` 共声明 **13 个状态参数**（`ct_l2c_icc.v:479-491`）：

| 状态 | 编码 | file:line | 含义 |
|------|------|-----------|------|
| `ICC_STATE_IDLE` | 0000 | `:479` | 空闲，等维护/DCA 请求 |
| `ICC_INV` | 0010 | `:480` | 纯失效（inv 全遍历，不回写） |
| `TAG_RD` | 0011 | `:481` | 读当前组 tag/status |
| `TAG_FLOP` | 0100 | `:482` | tag 读回锁存一拍 |
| `STATUS_UPDT` | 0101 | `:483` | 更新 status（清 valid/dirty） |
| `DIRTY_CHECK` | 0110 | `:484` | 检查本组还有无脏路要回写 |
| `WAIT_RDL` | 0111 | `:485` | 等下游接受脏行回写 |
| `DATA_RD` | 1000 | `:486` | 读 data（脏行回写 / DCA 读） |
| `DATA_FLOP` | 1010 | `:487` | data 读回锁存一拍 |
| `DCA_RDY` | 1011 | `:488` | DCA 数据就绪 |
| `DCA_CMPLT` | 1100 | `:489` | DCA 完成 |
| `DATA_CRRCT` | 1101 | `:490` | （ECC 数据纠错态，**开源版未使用**） |
| `TAG_CRRCT` | 1110 | `:491` | （ECC tag 纠错态，**开源版未使用**） |

> “13 态”是按声明数算的；其中 `DATA_CRRCT`/`TAG_CRRCT` 是 ECC 纠错预留态，开源版次态逻辑里没用到（与全篇 ECC 框架预留一致），**实际跑的是 11 态**。

### 进入维护的门槛（`:519-530`）

```verilog
ICC_STATE_IDLE:
  if(ciu_icc_req & l2c_pipeline_rdy)     // 必须等主流水排空
    icc_all_next_state = (cln_all || dca_acc_tag || dca_acc_tag_ecc) ? TAG_RD
                       : (inv_all ? ICC_INV : DATA_RD);
```

`l2c_pipeline_rdy`（来自 wb，`ct_l2c_wb.v:164`：tag/cmp/data/wb 全空 + rfifo 空）保证 icc 不会和正在飞的访问冲突——**维护与正常访问互斥，不是真并行**，而是“流水排空后接管”。

---

## 6. icc：flush/clean/invalidate 的 index/way 遍历

clean/invalidate 要**遍历整个 sub-bank**：512 组 × 16 路。icc 用一个 index 计数器逐组扫，每组内再逐路处理脏行。

### 6.1 index 遍历（`:645-662`）

```verilog
icc_index_start  = (state==IDLE) && l2c_pipeline_rdy && cln_inv_all;  // 从组 0 开始 :645
icc_index_update = (state==DIRTY_CHECK) && have_no_dirty              // 本组扫完
                || (state==ICC_INV) && tag_icc_grant;                  // 失效推进 :647
// :653-661 计数器：start→0；update→+1；
icc_all_last = (icc_index == {9{1'b1}});    // 扫到最后一组 511 :662
```

`icc_all_last && tag_icc_grant`（INV）或 `have_no_dirty && icc_all_last`（CLEAN）时回 IDLE 并置 `ctc_done`（`:611-612`），表示整缓存遍历完成。

### 6.2 组内脏路遍历

- 读出本组 16 路 status 后，算 `l2c_way_dirty_vld = icc_status_vld & icc_status_dirty & ~fatal_err`（脏且有效的路）。
- 用优先编码 `casez` 从中选一个脏路 `dirty_way_ptr[15:0]`（one-hot），转成 4 位 `icc_data_way`。
- 该脏路经 DATA_RD/DATA_FLOP/WAIT_RDL 回写下游（§8），回写后在 STATUS_UPDT 清掉它的 valid/dirty：`icc_status_vld <= icc_status_vld & ~dirty_way_ptr`。
- 循环回 DIRTY_CHECK，直到 `have_no_dirty`，再 `icc_index_update` 跳下一组。

> clean 与 invalidate 的差别：clean 走完整“读 status→逐脏路回写→清 dirty”链；inv 只走 `ICC_INV` 把每组 status 清掉、不回写数据（更快）。flush（SoC）= clean + inv 的组合（`:406` 里 flush 同时进 cln_all/inv_all）。

---

## 7. icc：DCA 直接缓存访问

DCA（Direct Cache Access）是调试/诊断通路：CIU 给一个 way+index，直接读/写 tag 或 data 或它们的 ECC。类型由 `icc_type[1:0]` 译码（`:410-413`）：

| `icc_type[1:0]` | 信号 | 访问对象 |
|-----------------|------|----------|
| 00 | `dca_acc_tag` | tag |
| 01 | `dca_acc_data` | data |
| 11 | `dca_acc_data_ecc` | data ECC |
| 10 | `dca_acc_tag_ecc` | tag ECC |

流程：IDLE →（tag 类）TAG_RD→TAG_FLOP→DCA_RDY→DCA_CMPLT；（data 类）DATA_RD→DATA_FLOP→DCA_RDY→DCA_CMPLT（`:519-596`）。

DCA 读出组装（`icc` 内部）：
- tag 类返回 `{tag[23:0], index, dirty}` 拼成 128 位；
- data 类用 `dca_offset_f[1:0]` 从 512 位整行里选 128 位；
- ECC 值在开源版恒 0（ECC 框架未落地）。

最终 `l2c_ciu_dca_data_x[127:0]` 在 DCA_CMPLT 时输出（`l2c_ciu_dca_cmplt_x = icc_dca_cmplt`）。

> DCA 只读/写 128 位（一个 data bank 的宽度），靠 `dca_offset` 选 4 个 bank 之一——用于软件直接窥探/注入某一路某 bank 的内容，是 RAS/调试特性。

---

## 8. icc：脏行回写（RDL）与 RAM 端口仲裁

### 8.1 脏行回写（RDL = Read-and-write-Down to Lower level）

clean/flush 遇到脏路要写回下游内存：
- 用 `dirty_way_ptr` one-hot 选出脏路的 tag → 拼地址 `icc_rdl_addr = {icc_rdl_tag[23:0], icc_index[8:0]}`。
- DATA_RD/DATA_FLOP 读出该路 512 位数据。
- WAIT_RDL 态等下游接受：`ciu_l2c_rdl_ready_x` 到 → 回 DIRTY_CHECK 继续下一脏路（`:582-588`）。
- 输出 `l2c_ciu_rdl_rvld/dvld_x` + `l2c_ciu_rdl_addr_x` + `l2c_ciu_rdl_mid_x` + `l2c_ciu_rdl_prot_x=3'b011` 把脏行推给 CIU/下游。

### 8.2 RAM 端口仲裁（icc 抢占 cmp）

icc 与主流水共享 tag/dirty/data 端口，靠 grant 握手（在 `ct_l2c_sub_bank` 内仲裁，见 `03` 篇 §9.2）：

```verilog
icc_tag_req  = icc_dirty_cen || icc_tag_cen;       // 请求 tag/dirty 端口
icc_tag_cen  = (state==TAG_RD) || icc_tag_gwen;     // 读 status 或写
icc_data_req = (state==DATA_RD);                    // 请求 data 端口
icc_data_cen[4:0] = {5{icc_data_req}} & data_ram_sel[4:0];
```

`tag_icc_grant`/`data_icc_grant`（输入）由 tag/data 级仲裁给出，且因为 icc 只在 `l2c_pipeline_rdy`（主流水排空）后启动，所以本质上是**独占**而非抢占——避免一致性维护与正常访问交织出错。

### 8.3 维护完成回报（`:416-417`）

```verilog
l2c_ciu_ctcq_cmplt_x = ctc_done & !rst_req_f & !l2c_flush_f;  // CMO 维护完成
l2c_flush_done_x     = ctc_done & l2c_flush_f;                 // SoC flush 完成
```

`ctc_done` 在整缓存遍历结束时拉高（§6.1），分别回报给 CMO 队列或 SoC flush FSM（`03` 篇 §10.2 的 top flush FSM 就在等这个 `l2c_flush_done_bank_x`）。

---

## 9. wb：响应组装与 14 位 rfifo

`ct_l2c_wb`（流水第④级）把读出数据和响应组装好交给 CIU。

### 9.1 wb 流水寄存器（`:190-219`）

`data_yy_flop_vld` 到来时（data 级数据就绪），wb 锁存随路属性 + 整行：

```verilog
wb_stage_vld <= 1'b1;                      // 有数据要返回 :194-195
wb_stage_sid/resp/cp <= data_stage_*;      // 随路属性     :208-213
wb_stage_data[511:0] = l2c_data_dout_flop[511:0];  // 整行直通 :217
```

### 9.2 rfifo：14 位宽 × 3 深的响应队列（`:233-260`）

有些操作**只有响应、没有数据**（写完成、维护完成、cp 操作等）。cmp 级把这些响应 `cmp_rfifo_create` 推进一个 FIFO，与“带数据的 wb_stage”分开排队：

```verilog
ct_fifo #(.WIDTH(14), .DEPTH(3), .PTR_W(2)) x_ct_l2c_resp_rfifo(...);   // :242
rfifo_create_bus[13:0] = {cmp_rfifo_resp[4:0], cmp_rfifo_cp[3:0], cmp_rfifo_sid[4:0]};  // 5+4+5=14 位 :238-240
```

> **关于“14 项”的澄清**：rfifo 的**深度只有 3 项**（`DEPTH(3)`，`:242`），不是 14 项；`14` 是每项的**位宽**（`rfifo_create_bus[13:0]`，由 resp[5]+cp[4]+sid[5] 拼成，`:238-240`）。设计选 3 深够用，因为同时在途的纯响应不会多。

弹出条件 `rfifo_pop_en = !wb_stage_vld && rfifo_pop_entry_vld`（`:236`）——**带数据的 wb_stage 优先**，没数据返回的拍才弹 rfifo。

### 9.3 输出到 CIU（`:266-270`）

```verilog
l2c_ciu_cmplt_x = wb_stage_vld | rfifo_pop_en;                      // 二选一来源 :266
l2c_ciu_resp_x  = wb_stage_vld ? wb_stage_resp_after_ecc : rfifo_pop_entry_resp;  // :267
l2c_ciu_cp_x    = wb_stage_vld ? wb_stage_cp  : rfifo_pop_entry_cp;   // :268
l2c_ciu_sid_x   = wb_stage_vld ? wb_stage_sid : rfifo_pop_entry_sid;  // :269
l2c_ciu_data_x  = wb_stage_data[511:0];                              // 数据只来自 wb :270
```

### 9.4 ECC / wb 写回框架（开源版旁路，`:218,304-312`）

```verilog
wb_stage_fatal_err = 1'b0;          // ECC 致命错恒 0（无纠错）:218
wb_tag_req = wb_tag_cen = wb_dirty_cen = 1'b0;   // wb 不写 tag/dirty :304-308
wb_ecc_rfifo_empty = 1'b1;          // ECC rfifo 恒空           :309
```

注释里大量 `ct_l2c_ecc_rfifo_entry0~5` 实例（`:286-301`）是 ECC 纠错后重写阵列的 6 项 ECC rfifo——**开源版全部注释掉**，所以 wb 对 tag/dirty 的写端口恒不激活。这与 `00`/`01`/`02` 的“ECC 仅框架”一致：架构上 wb 级本应承担“纠错后写回 + ECC 响应”，开源版只保留数据组装与响应 rfifo。

`l2c_pipeline_rdy`（`:164`）= tag/cmp/data/wb 全空 + 两个 rfifo 空 —— 这正是 icc 启动维护的前提（§5）。

---

## 设计取舍小结

1. **next-line 预取，深度可配**：预取策略最简单的“下一行”，对顺序性强的指令流/页表行之有效；指令预取深度 `iprf` 可配 1~3 行、TLB 固定 1 行；跨页一律停（`pref_en & !cross_page`），避免预取未映射页。共享一个引擎服务两 bank，省面积。
2. **维护引擎“排空后独占”而非真并行**：icc 必须等 `l2c_pipeline_rdy`（主流水全空）才启动，且独占 RAM 端口。这把一致性维护与正常访问彻底互斥，换来正确性与逻辑简单，代价是维护期间访问停顿——但 flush/CMO 本就是稀有事件。
3. **遍历式 clean/inv**：512 组 × 16 路用 index 计数器 + 组内脏路优先编码逐个处理；clean 完整回写、inv 只清状态、flush=两者组合。结构简单、面积小，代价是整缓存遍历耗时较长。
4. **DCA 复用 icc 通路**：调试/诊断的直接读写不另设通路，挂在 icc FSM 上（多几个 DCA 态），靠 offset 选 128 位 bank。复用省面积，但让 icc FSM 态数变多。
5. **wb 双来源 + 3 深 rfifo**：带数据响应走 `wb_stage`、纯响应走 3 深 rfifo，二者在输出端二选一（数据优先）。把“慢数据”和“快响应”解耦，避免纯响应被数据访问阻塞；3 深够用是因为在途纯响应有限。
6. **ECC 框架贯穿但未落地**：icc 的 `DATA_CRRCT`/`TAG_CRRCT` 态、wb 的 6 项 ECC rfifo、`fatal_err`/`after_ecc` 信号都在结构上存在，但开源版恒旁路（err=0、rfifo 空、纠错态不进）。学习时要分清“架构意图”与“开源现状”。

---

*本文覆盖 ct_l2c_prefetch.v 全部逻辑（双 bank 触发、2 态 FSM、深度计数、跨页停）、ct_l2c_icc.v 关键逻辑（13 态维护 FSM、index/way 遍历、DCA、RDL 脏行回写、RAM 端口仲裁、维护完成回报）、ct_l2c_wb.v 全部逻辑（wb 流水寄存器、14 位×3 深 rfifo、双来源输出、ECC 框架旁路），合计约 1464 行。tag/cmp/data 级见 01/02/03。*
