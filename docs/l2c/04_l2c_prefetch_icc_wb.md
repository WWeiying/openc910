# C910 L2C 预取 / 维护 / 响应模块详细教学文档

> RTL 文件：`ct_l2c_prefetch.v`（硬件预取引擎）、`ct_l2c_icc.v`（整 sub-bank 维护 / DCA / flush 引擎）、`ct_l2c_wb.v`（读响应 / 纯响应组装 + rfifo）
> 配置：`cpu/rtl/cpu_cfig.h`（`L2C_TAG_INDEX_WIDTH=9`、`L2C_DATA_INDEX_WIDTH=13`）
> 本篇讲三个职责不同的模块：普通主路径末端的 **wb**、主流水排空后接管阵列的 **icc**，以及顶层共享的 **prefetch**。ICC 不是 wb 后面的顺序流水级，也不负责通用逐核 snoop 路由。

## 目录
- [1. 模块概述](#1-模块概述)
- [2. 端口说明](#2-端口说明)
- [3. 参数与关键寄存器](#3-参数与关键寄存器)
- [4. prefetch：指令 + TLB 下一行预取](#4-prefetch指令--tlb-下一行预取)
- [5. ICC：维护和 DCA FSM 总览](#5-icc维护和-dca-fsm-总览)
- [6. ICC：flush/clean/invalidate 的 index/way 遍历](#6-iccflushcleaninvalidate-的-indexway-遍历)
- [7. ICC：DCA 直接诊断读取](#7-iccdca-直接诊断读取)
- [8. ICC：RDL 脏行下推与 RAM 端口接管](#8-iccrdl-脏行下推与-ram-端口接管)
- [9. wb：响应组装与 14 位 rfifo](#9-wb响应组装与-14-位-rfifo)
- [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 职责

| 模块 | 流水位置 | 职责 |
|------|----------|------|
| `ct_l2c_prefetch` | 顶层共享（非流水级） | 监听两 bank 的 cmp 级 miss 信号，对**下一行**发硬件预取；区分指令预取（深度可配 1~3）与 TLB 页表预取 |
| `ct_l2c_icc` | 主流水之外，排空后互斥运行 | 遍历本 sub-bank 做整体失效或“脏行下推后失效”，提供 DCA 诊断读取，并处理 SoC flush |
| `ct_l2c_wb` | 普通主路径末端 | 把 data 级读出的 512 位整行与 sid/resp/cp 组装成响应；用 **3 深 rfifo** 缓存 cmp 产生的无数据响应，例如 read miss、write/allocate/release 等完成 |

### 1.2 三者在流水中的位置

```
                              ┌─ ct_l2c_prefetch ◄── cmp_pref_*（两 bank 的 miss 信号）
                              │      └─► l2c_ciu_prf_*（下一行预取请求）
ct_l2c_cmp(②) ─cmp_data_*─► ct_l2c_data(③) ─data_stage_*/dout_flop─► ct_l2c_wb(④) ─► l2c_ciu_cmplt/data/resp
       │ cmp_rfifo_* ─────────────────────────────────────────────────► (wb rfifo)
       │
ciu_l2c_ctcq/dca/rst/flush_req ─► ct_l2c_icc ─icc_tag_*/icc_data_*─► 排空后接管 tag/data RAM
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
| 本地端口可用 | `tag_icc_grant`、`data_icc_grant` | in | tag/data 当前访问计数已释放端口；ICC 的启动还要求整条 `l2c_pipeline_rdy` |
| 写 tag/dirty | `icc_tag_cen/gwen/req`、`icc_tag_index[8:0]`、`icc_dirty_cen/gwen/wen[8:0]` | out | 维护时改 status/失效（`:129-137`） |
| 读 data | `icc_data_req/cen[4:0]/index[12:0]/flop` | out | 维护读取 512 位脏行，或 DCA 读取 128 位 data/ECC 占位；没有 ICC data 写数据端口 |
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
| `pref_addr` | 34 | `:69` | 当前预取 cache-line 编号 `PA[39:6]`；最低位就是原 `PA[6]` bank 位 |
| `pref_cnt` | 2 | `:70` | 剩余预取行数（指令预取最多 3） |
| `pref_tlb` | 1 | `:73` | 本次是 TLB 预取 |

### icc（`ct_l2c_icc.v`）

| 名称 | 值/位宽 | file:line | 含义 |
|------|---------|-----------|------|
| `icc_all_state` | 4 | `:159` | 维护 FSM；声明 13 个编码，其中 11 个可由当前次态逻辑到达 |
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

`ct_l2c_prefetch` 是两 bank 共享的预取引擎。它把 `addr_x=PA[39:7]` 与来源 bank 位重新拼成 `PA[39:6]`，再对这个**以 64 B 为单位的 line number**加 1，得到物理上的下一条 64 B cache line。

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

`pref_en = (pref_en_0 || pref_en_1) && !cmp_pref_addr_cross_page`。若两个 bank 同拍都满足触发条件，`bank1_sel` 使 bank1 获得固定优先选择；模块没有为同拍另一个 miss 排队。预取器处于 PREF 状态时，新触发也不会重新装入 `pref_addr`，因为 `pref_addr_update` 只在 IDLE 成立。

这里还有一个不能被“bank1 固定优先”掩盖的 RTL 边界。真正的
`pref_en_1`会同时检查 `read`、对应的 `iprf/tprf`使能、source 和 miss；但
实际地址多路器的 `bank1_sel`只检查 bank1 的 `cache_miss`、IFU/TLB source
和 `vld`，没有检查 `cmp_pref_read_bank_1`，也没有检查对应预取使能。因此，
当 bank0 是合法触发，而 bank1 同拍只满足这组较宽的选择条件时，整体
`pref_en`可能由 bank0 拉高，实际装入的地址和 TLB 类型却来自 bank1；
`cmp_pref_addr_cross_page`也会针对被选中的 bank1 地址计算。正常 CIU 请求
编码也许保证这些条件总是成组出现，但该约束不在本模块内部证明。验证时应
加入“两 bank 同拍、使能/读类型不同”的定向用例，不能只测两个都合法的
对称冲突。

### 4.2 两态 FSM（`:148-199`）

```
IDLE ──pref_en──► PREF
  ▲                 │ 每次有效预取被 CIU 接收后，地址+1、pref_cnt--
  └─ ciu_accepted & (pref_last | cross_page) ─┘
```

- `pref_addr_update = pref_en && (state==IDLE)`（`:201`）：进 PREF 时载入预取地址与计数。
- 地址选择（`:210-217`）：拼接 `{cmp_pref_addr_bank_x[32:0],bank_x}` 得到 `PA[39:6]`。`pref_updt_addr = cmp_pref_addr + 1` 前进一条 64 B cache line。
- 计数 `pref_cnt`（`:225-251`）：TLB 预取固定 1 行（`pref_cnt=0`）；指令预取取 `iprf_cnt = ciu_l2c_iprf - 1`（`:225,239`），即深度 1~3 行连发。
- line-number 的 bit6 对应原物理地址 `PA[12]`。当前值与 `+1` 后 bit6 异或，可检测 64 line × 64 B = 4 KiB 边界翻转，跨页则不启动或在连续预取末端停止。
- 输出 `l2c_ciu_prf_prot = {!pref_tlb, 2'b11}`（`:126`）：bit2 区分指令/TLB。

`l2c_ciu_prf_vld` 只在 PREF 状态为 1。可见事务的握手应看 `prf_vld && prf_ready`。RTL 内部把 `ciu_accepted` 直接连接到 `prf_ready`，没有再与 valid 相与；因此波形统计必须用 valid 与 ready 的交集计算真实预取发送数。空闲时 ready 即使为 1，只会改写随后会被下一次有效触发覆盖的内部地址/计数，不代表发生了外部预取事务。

---

## 5. ICC：维护和 DCA FSM 总览

`ct_l2c_icc` 与主流水在结构上并列，但运行时先等主流水排空，然后互斥接管阵列端口。它处理以下整体请求：

```verilog
inv_all     = ctcq_req & icc_type[0] | rst_req | flush_req;  // 不回写的失效意图
cln_all     = ctcq_req & icc_type[1] | flush_req;             // 先下推脏行，再失效
cln_inv_all = inv_all | cln_all;                              // :407
```

外加 DCA（`:410-413`）。状态寄存器实际是 `icc_all_state[3:0]`，RTL 共声明 **13 个 4 位状态编码**：

| 状态 | 编码 | file:line | 含义 |
|------|------|-----------|------|
| `ICC_STATE_IDLE` | 0000 | `:479` | 空闲，等维护/DCA 请求 |
| `ICC_INV` | 0010 | `:480` | 纯失效（inv 全遍历，不回写） |
| `TAG_RD` | 0011 | `:481` | 读当前组 tag/status |
| `TAG_FLOP` | 0100 | `:482` | tag 读回锁存一拍 |
| `STATUS_UPDT` | 0101 | `:483` | 保存当前组状态快照后，把 SRAM 中该组的全部 status 清零 |
| `DIRTY_CHECK` | 0110 | `:484` | 检查本组还有无脏路要回写 |
| `WAIT_RDL` | 0111 | `:485` | 等下游接受脏行回写 |
| `DATA_RD` | 1000 | `:486` | 读 data（脏行回写 / DCA 读） |
| `DATA_FLOP` | 1010 | `:487` | data 读回锁存一拍 |
| `DCA_RDY` | 1011 | `:488` | DCA 数据就绪 |
| `DCA_CMPLT` | 1100 | `:489` | DCA 完成 |
| `DATA_CRRCT` | 1101 | `:490` | （ECC 数据纠错态，**开源版未使用**） |
| `TAG_CRRCT` | 1110 | `:491` | （ECC tag 纠错态，**开源版未使用**） |

“13 态”只是声明数量。当前 `case` 没有进入 `DATA_CRRCT`/`TAG_CRRCT` 的次态分支，这两个编码也没有独立 case item；从 IDLE 和其余已实现次态出发，可达状态为 11 个。

### 进入维护的门槛（`:519-530`）

```verilog
ICC_STATE_IDLE:
  if(ciu_icc_req & l2c_pipeline_rdy)     // 必须等主流水排空
    icc_all_next_state = (cln_all || dca_acc_tag || dca_acc_tag_ecc) ? TAG_RD
                       : (inv_all ? ICC_INV : DATA_RD);
```

`l2c_pipeline_rdy` 要求 tag/cmp/data/wb 无有效事务、纯响应 rfifo 空且 ECC rfifo 空。当前 ECC rfifo 被硬连为空，但该项仍保留在表达式中。ICC 的 ready 输出还与原始请求相与，所以 `l2c_ciu_ctcq_ready_x` / `dca_ready_x` 是“请求存在且当拍可接收”的握手结果，不是独立常高的空闲信号。

---

## 6. ICC：flush/clean/invalidate 的 index/way 遍历

整体维护遍历当前 sub-bank 的 512 个 local set。纯 invalidate 每组一次写清；`cln_all` 先保存该组 16 路 valid/dirty 快照，再按快照逐个读取有效脏 way。

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
- 实际 SRAM status 已在该组进入 `STATUS_UPDT` 时整体清零。随后每个脏 way 经 DATA_RD/DATA_FLOP/WAIT_RDL 下推；`icc_status_vld/dirty <= ... & ~dirty_way_ptr` 清的是 ICC 内部快照，用于寻找下一个尚未处理的脏 way。
- 循环回 DIRTY_CHECK，直到 `have_no_dirty`，再 `icc_index_update` 跳下一组。

当前 RTL 的关键语义不是“clean 后保留 valid”：

- `inv_all`：逐组把 tag 和 status 清零，不读取或下推脏数据；
- `cln_all`：先读 tag/status 并保存快照，把 status 全部清零，再逐个下推快照中的有效脏行；正常非 fatal 情况下旧 tag 位可留在 SRAM，但 valid 已清零，所以该行逻辑上无效；
- flush：同时产生 `inv_all` 与 `cln_all`，IDLE 的优先判断使其走 `cln_all` 路径，即脏行下推后失效。

因此这里的 `cln_all` 应描述为“clean-and-invalidate 风格的整体维护”，不能沿用普通 cmp 单行 `cln` 的“清 dirty 但保留 valid”语义。

两条整体维护路径都会把 16 位 replacement 字段写成 `16'b1`，也就是 one-hot bit0，而不是 16 个 1。维护后该 set 的下一次 allocate 从 way0 开始轮转。

---

## 7. ICC：DCA 直接诊断读取

DCA（Direct Cache Access）是调试/诊断读取通路：CIU 给出 way/index/type，ICC 读取 tag/status、data 或 ECC 占位值。该模块没有 DCA 写数据输入，也没有由 DCA 类型产生 SRAM 写使能。类型由 `icc_type[1:0]` 译码（`:410-413`）：

| `icc_type[1:0]` | 信号 | 访问对象 |
|-----------------|------|----------|
| 00 | `dca_acc_tag` | tag |
| 01 | `dca_acc_data` | data |
| 11 | `dca_acc_data_ecc` | data ECC |
| 10 | `dca_acc_tag_ecc` | tag ECC |

流程：IDLE →（tag 类）TAG_RD→TAG_FLOP→DCA_RDY→DCA_CMPLT；（data 类）DATA_RD→DATA_FLOP→DCA_RDY→DCA_CMPLT（`:519-596`）。

DCA 读出组装（`icc` 内部）：
- tag 类返回 `{88'b0, tag[23:0], dca_index_f[8:5], 4'b0, status[7:0]}`；末尾 8 位是完整 status，不只是 dirty bit；
- data 类用 `dca_offset_f[1:0]` 从 512 位整行里选 128 位；
- ECC 值在开源版恒 0（ECC 框架未落地）。

最终 `l2c_ciu_dca_data_x[127:0]` 在 DCA_CMPLT 时输出（`l2c_ciu_dca_cmplt_x = icc_dca_cmplt`）。

DCA data 类型一次返回一个 128 位 slice，`dca_offset` 选择四个 slice 之一。tag 类型也统一封装为 128 位返回。当前只能“窥探”，不能通过这条 RTL 通路“注入”或修改缓存。

---

## 8. ICC：RDL 脏行下推与 RAM 端口接管

### 8.1 RDL 脏行下推

`RDL` 是 RTL 接口族名称；仓库没有给出可以据此确定的英文全称，因此不展开臆测。`cln_all`/flush 遇到有效脏 way 时：
- 用 `dirty_way_ptr` one-hot 选出脏路的 tag → 拼地址 `icc_rdl_addr = {icc_rdl_tag[23:0], icc_index[8:0]}`。
- DATA_RD/DATA_FLOP 读出该路 512 位数据。
- WAIT_RDL 态等下游接受：`ciu_l2c_rdl_ready_x` 到 → 回 DIRTY_CHECK 继续下一脏路（`:582-588`）。
- `rdl_rvld` 和 `rdl_dvld` 在 WAIT_RDL 同时有效；地址为内部 `PA[39:7]`，CIU 按 bank 来源拼回 `PA[6]` 和 6 个行内 0。
- 512 位数据没有独立的 `rdl_data` 端口，而是继续使用 sub-bank 的 `l2c_ciu_data_x[511:0]`。CIU 的 VCTM 写数据总线在 `rdl_dvld` 时取这组数据。
- `ciu_l2c_rdl_ready_x` 表示 CIU/VB 已接受该地址/数据事务；只有 ready 或 fatal error 才离开 WAIT_RDL。

这条 RDL 路径只服务 ICC 整体维护，不是普通 L2 read miss 的下级读。

### 8.2 RAM 端口接管

ICC 与主流水共享 tag/status/data 端口，靠本地 grant 等待 SRAM 当前访问计数释放：

```verilog
icc_tag_req  = icc_dirty_cen || icc_tag_cen;       // 请求 tag/dirty 端口
icc_tag_cen  = (state==TAG_RD) || icc_tag_gwen;     // 读 status 或写
icc_data_req = (state==DATA_RD);                    // 请求 data 端口
icc_data_cen[4:0] = {5{icc_data_req}} & data_ram_sel[4:0];
```

`tag_icc_grant` 和 `data_icc_grant` 分别组合地等于对应 RAM 的 idle 条件。ICC 只在 `l2c_pipeline_rdy` 后启动；启动后 `icc_idle=0` 又挡住普通地址入口。因此它不是在普通请求执行中途抢占，而是排空后接管。

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

cmp 中有些操作只需返回状态而不返回 512 位数据，例如 read miss、写完成、allocate/release、部分 clean/invalidate/属性操作和 cp 更新。它们通过 `cmp_rfifo_create` 进入纯响应 FIFO。ICC 整体维护完成走独立的 `l2c_ciu_ctcq_cmplt_x`，不进入这个 rfifo。

```verilog
ct_fifo #(.WIDTH(14), .DEPTH(3), .PTR_W(2)) x_ct_l2c_resp_rfifo(...);   // :242
rfifo_create_bus[13:0] = {cmp_rfifo_resp[4:0], cmp_rfifo_cp[3:0], cmp_rfifo_sid[4:0]};  // 5+4+5=14 位 :238-240
```

rfifo 深度是 3，每项宽度是 14 位，由 `resp[4:0] + cp[3:0] + sid[4:0]` 组成。`rfifo_full` 虽由通用 FIFO 输出，但没有接回 cmp 的 create 条件，也没有形成入口反压。因此当前实现依赖上游事务调度保证不会在 FIFO 已满时继续 create；“3 深一定够用”不是本模块自证的结论，应通过协议断言和压力仿真验证。

弹出条件 `rfifo_pop_en = !wb_stage_vld && rfifo_pop_entry_vld`，所以同拍有带数据 wb 响应时，纯响应保持在 FIFO 中。wb 输出没有来自 CIU 的 ready；设计假定 CIU 每拍都能接收 `l2c_ciu_cmplt_x` 所表示的完成。

### 9.3 输出到 CIU（`:266-270`）

```verilog
l2c_ciu_cmplt_x = wb_stage_vld | rfifo_pop_en;                      // 二选一来源 :266
l2c_ciu_resp_x  = wb_stage_vld ? wb_stage_resp_after_ecc : rfifo_pop_entry_resp;  // :267
l2c_ciu_cp_x    = wb_stage_vld ? wb_stage_cp  : rfifo_pop_entry_cp;   // :268
l2c_ciu_sid_x   = wb_stage_vld ? wb_stage_sid : rfifo_pop_entry_sid;  // :269
l2c_ciu_data_x  = wb_stage_data[511:0];                              // 数据只来自 wb :270
```

纯响应弹出时 `l2c_ciu_data_x` 仍是当前或先前的 `wb_stage_data` 组合值，不应读取。`resp[0]` 在 data path 的 `cmp_stage_resp` 中为 1，而纯响应的 `cmp_rfifo_resp[0]` 为 0，可用于区分该完成是否携带有效 512 位数据。

### 9.4 ECC / wb 写回框架（开源版旁路，`:218,304-312`）

```verilog
wb_stage_fatal_err = 1'b0;          // ECC 致命错恒 0（无纠错）:218
wb_tag_req = wb_tag_cen = wb_dirty_cen = 1'b0;   // wb 不写 tag/dirty :304-308
wb_ecc_rfifo_empty = 1'b1;          // ECC rfifo 恒空           :309
```

注释里大量 `ct_l2c_ecc_rfifo_entry0~5` 实例（`:286-301`）是 ECC 纠错后重写阵列的 6 项 ECC rfifo——**开源版全部注释掉**，所以 wb 对 tag/dirty 的写端口恒不激活。这与 `00`/`01`/`02` 的“ECC 仅框架”一致：架构上 wb 级本应承担“纠错后写回 + ECC 响应”，开源版只保留数据组装与响应 rfifo。

`l2c_pipeline_rdy`（`:164`）要求 tag/cmp/data/wb 全空、3 深纯响应 rfifo 为空，并且 ECC 写回 rfifo 为空。当前 ECC 写回 rfifo 被硬连为永远空，但表达式仍保留这一条件；这正是 ICC 启动维护的前提。

---

## 本章小结

L2 预取、维护和写回共享同一套 bank 与返回资源，但承担不同生命周期。next-line 预取引擎可按 `iprf` 为指令流继续请求 1 至 3 条 line，TLB 预取固定为 1 条，并在 4 KiB 页边界停止；两个 sub-bank 共用该控制引擎。预取是否提高性能取决于顺序局部性、及时性、污染和带宽竞争，不能由请求深度直接判断。ICC 维护必须等待 `l2c_pipeline_rdy`，启动后以 `icc_idle=0` 阻止普通请求进入相应 sub-bank。纯 invalidate 按 set 清除，clean/flush 则先保存该 set 的状态快照并使其失效，再逐路读取并下推快照中的有效脏行，所以完成时间至少随 set 数增长，还会叠加 data SRAM 和下游 ready 等待。

DCA 诊断读取复用 ICC 状态机与 tag/status/data SRAM 端口，当前只支持读取，不能概括为直接读写阵列。wb 级在带数据响应和纯响应之间选择，数据响应优先，纯响应进入 3 深 rfifo；`rfifo_full` 没有在本地形成完整反压，容量安全依赖系统级并发约束。ICC 中的 `DATA_CRRCT/TAG_CRRCT` 状态、wb 的 ECC rfifo 以及 `fatal_err/after_ecc` 信号构成 ECC 框架，但开源实现把错误固定为 0、相关队列保持空、纠错状态不可达。分析维护或返回拥塞时，应连续观察 pipeline 排空、ICC 接管、set/way 遍历、脏数据读取、下游接受、wb 选择和最终 done，而不能只用 ICC busy 的总时长推断某一单独阶段。
