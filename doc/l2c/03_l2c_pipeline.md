# C910 L2C 比较流水与 sub-bank/顶层 模块详细教学文档

> RTL 文件：`ct_l2c_cmp.v`（约 898 行，cmp 第②级）、`ct_l2c_sub_bank.v`（约 877 行，单 sub-bank 容器）、`ct_l2c_top.v`（约 713 行，综合顶层 + flush FSM）、`ct_l2cache_top.v`（约 289 行，SRAM 阵列容器）
> 配置：`cpu/rtl/cpu_cfig.h`（`L2C_TAG_INDEX_WIDTH=9`、`L2C_TAG_DATA_WIDTH=24`、`L2C_DATA_INDEX_WIDTH=13`，行 396~398）
> 本篇把“5 级比较流水”的**第②级 cmp**讲透，再自底向上讲 **sub-bank（一个 512 组并行单元）→ top（2 sub-bank 并行 + flush）→ cache_top（SRAM 阵列）** 的层次结构。tag 级见 `01`，data 级见 `02`，wb/icc/prefetch 见 `04`。

## 目录
- [1. 模块概述](#1-模块概述)
- [2. 端口说明](#2-端口说明)
- [3. 参数与关键寄存器](#3-参数与关键寄存器)
- [4. cmp 级：操作类型解码与流水寄存器](#4-cmp-级操作类型解码与流水寄存器)
- [5. 命中/选路逻辑（16 路并行比较）](#5-命中选路逻辑16-路并行比较)
- [6. 状态迁移计算与 tag/dirty 回写](#6-状态迁移计算与-tagdirty-回写)
- [7. data RAM 请求与 way→data-index 选路](#7-data-ram-请求与-waydata-index-选路)
- [8. 反压：cmp_stage_stall / cmp_stall_by_data](#8-反压cmp_stage_stall--cmp_stall_by_data)
- [9. sub-bank：5 级流水 + SRAM 的装配](#9-sub-bank5-级流水--sram-的装配)
- [10. top：2 sub-bank 并行 + flush FSM + 可编程访问延迟](#10-top2-sub-bank-并行--flush-fsm--可编程访问延迟)
- [11. cache_top：SRAM 阵列容器](#11-cache_topsram-阵列容器)
- [12. 一次访问的完整流水时序](#12-一次访问的完整流水时序)
- [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

L2C 的访问被切成 **5 个流水级**：`tag → cmp → data → wb → icc`。本篇聚焦其中的 **cmp（比较）级**及把所有级装配起来的三个层次容器：

| 层次 | 文件 | 干什么 |
|------|------|--------|
| ② cmp 级 | `ct_l2c_cmp.v` | 16 路并行 tag 比较、命中/选路、MESI 状态迁移计算、回写 tag/dirty、发 data 请求、触发 snoop/prefetch、生成响应 |
| sub-bank | `ct_l2c_sub_bank.v` | 一个 **512 组 / 16 路** 的完整缓存单元：实例化 tag/cmp/data/wb/icc 五级 + 一份 SRAM 阵列 |
| top | `ct_l2c_top.v` | L2C 综合边界：**2 个 sub-bank 并行** + 1 个共享 prefetch + 1 个对接 SoC 的 flush 状态机 + 可编程访问延迟查表 |
| cache_top | `ct_l2cache_top.v` | 把 tag/dirty/data 三类 SRAM 阵列接在一起的纯结构容器 |

### 1.2 cmp 级在流水中的位置

```
ct_l2c_tag (①)                         ct_l2c_data (③)
   │ ttecc_stage_* (addr/type/sid/cp…)    ▲ cmp_data_req/din/index/wen
   │ + 16 路 l2c_wayN_tag/cp/dirty_dout   │
   ▼                                      │
┌──────────────── ② ct_l2c_cmp ──────────┴──┐
│ 16 路比较 → cmp_way_v_hit → l2c_cache_hit  │
│ 状态迁移 → cmp_tag_*/cmp_dirty_* 回写      │──► ct_l2cache_top (tag/dirty SRAM)
│ cmp_rfifo_* (响应) ──────────────────────► ct_l2c_wb (④)
│ cmp_pref_* ──────────────────────────────► ct_l2c_prefetch
│ l2c_ciu_snpl2_* ─────────────────────────► CIU (侦听)
└────────────────────────────────────────────┘
```

cmp 级是 L2C 一致性逻辑的**心脏**：命中判定、MESI 状态机、侦听过滤器的置/清 cp 都在这里完成。

---

## 2. 端口说明

`ct_l2c_cmp`（`ct_l2c_cmp.v:17-134`）端口按数据流分组：

| 组 | 端口 | 方向 | 含义 |
|----|------|------|------|
| 上游 tag 流水 | `ttecc_flop_vld`、`ttecc_stage_addr[32:0]`、`ttecc_stage_type[12:0]`、`ttecc_stage_sid[4:0]`、`ttecc_stage_src[1:0]`、`ttecc_stage_setcp/clrcp[3:0]`、`ttecc_stage_mid/hpcp_bus[2:0]`、`ttecc_stage_fatal_err`、`ttecc_stage_write_raw` | in | tag 级（经 ECC 占位 ttecc）下传的请求信息（`:201-211`） |
| 16 路 RAM 读回 | `l2c_way0..15_tag_dout[23:0]`、`l2c_way0..15_cp_dout[3:0]`、`l2c_way0..15_dirty_dout[7:0]` | in | 16 路 tag / core-presence / status(dirty) 数据 |
| 命中向量 | `cmp_way_v_hit[15:0]`、`cmp_way_vd_hit`、`cmp_way_vs_hit`、`cmp_way_vu_hit` | in | 由 tag 级算好的“valid+tag 匹配 / +dirty / +shared / +unique”16 路 one-hot（`:139-143`） |
| 替换/FIFO | `cmp_refill_ptr[15:0]`、`l2c_way_fifo[15:0]`、`l2c_way_vld[15:0]` | in | FIFO 替换指针、各路 FIFO 位、各路 valid（`:197-198`） |
| 回写 tag | `cmp_tag_cen/gwen`、`cmp_tag_index[8:0]`、`cmp_tag_wen[15:0]` | out | tag SRAM 写控制（`:241-244`） |
| 回写 dirty | `cmp_dirty_cen/gwen`、`cmp_dirty_way[15:0]`、`cmp_dirty_wen[8:0]`、`cmp_dirty_din[143:0]` | out | status/FIFO SRAM 写（`:216-220`） |
| data 请求 | `cmp_data_req/req_gate/wen`、`cmp_data_index[12:0]` | out | 发给 data 级的读/写（`:212-215`） |
| 给 wb 的响应 | `cmp_rfifo_create`、`cmp_rfifo_resp[4:0]`、`cmp_rfifo_cp[3:0]`、`cmp_rfifo_sid[4:0]`、`cmp_stage_resp[4:0]` | out | 进 wb 的 rfifo 或直通（`:228-235`） |
| 侦听 | `l2c_ciu_snpl2_vld_x`、`l2c_ciu_snpl2_addr_x[32:0]`、`l2c_ciu_snpl2_ini_sid_x[4:0]`、`ciu_l2c_snpl2_ready_x` | out/in | L2 向核发 snoop（`:250-252,137`） |
| prefetch | `cmp_pref_vld/read/ifu_req/tlb_req/cache_miss_x`、`cmp_pref_addr_x[32:0]` | out | 喂预取引擎（`:221-226`） |
| 反压 | `cmp_stage_stall`、`cmp_stall_by_data` | out | 反压上游 / 被 data 级卡住（`:237,240`） |
| HPCP 性能计数 | `l2c_ciu_hpcp_acc_inc_x[1:0]`、`l2c_ciu_hpcp_miss_inc_x[1:0]`、`l2c_ciu_hpcp_mid_x[2:0]` | out | 访问/缺失计数（`:247-249`） |

---

## 3. 参数与关键寄存器

| 参数 | 值（16WAY/1M） | file:line | 含义 |
|------|----------------|-----------|------|
| `TAG_INDEX_LENTH` | `L2C_TAG_INDEX_WIDTH`=9 | `ct_l2c_cmp.v:462` | tag 索引宽 → 512 组/sub-bank |
| `TAG_TAG_LENTH` | `L2C_TAG_DATA_WIDTH`=24 | `:463` | tag 标签宽 |
| `DATA_INDEX_LENTH` | `L2C_DATA_INDEX_WIDTH`=13 | `:464` | data 索引宽 → 8192 行/bank |
| `L2C_ADDRW` | 33 | `:465` | 地址宽 |

cmp 级流水寄存器（在 `cmp_dp_clk` 门控时钟下，`:512-540`）：

| 寄存器 | 位宽 | 含义 | file:line |
|--------|------|------|-----------|
| `cmp_stage_vld` | 1 | cmp 级有效 | `:266`、写于 `:501-509` |
| `cmp_stage_addr` | 33 | 请求地址 | `:257` |
| `cmp_stage_type` | 13 | 操作类型（下面解码） | `:265` |
| `cmp_stage_sid/src` | 5/2 | source-id / 来源 | `:263-264` |
| `cmp_stage_setcp/clrcp` | 各 4 | 要置/清的 cp 位 | `:262,258` |
| `cmp_data_piped_down` | 1 | data 请求已被 data 级接走的标志 | `:255`、写于 `:722-732` |
| `cmp_data_way` | 4 | 命中/替换路的 4 位编号 | `:256` |
| `snpl2_granted` | 1 | snoop 已被 CIU 接受 | `:268`、写于 `:795-803` |

---

## 4. cmp 级：操作类型解码与流水寄存器

### 4.1 流水寄存器锁存（`:501-540`）

cmp 级在 `!cmp_stage_stall` 时从 tag 级吸入新请求：`cmp_stage_vld <= ttecc_flop_vld`（`:506`）；其余信息（addr/sid/type/src/cp…）在 `ttecc_flop_vld & !cmp_stage_stall` 时锁存（`:527-539`）。`cmp_dp_clk` 是数据通路门控时钟，仅在 `ttecc_flop_vld` 时翻转（`:474`），省功耗。

### 4.2 type[12:0] 全解码（`:542-554`）

这是理解 L2 全部行为的字典——一个 13 位 one-hot/多 hot 操作码：

| 位 | 信号（`:542-554`） | 含义 |
|----|------|------|
| 12 | `cmp_stage_read` | 读 |
| 11 | `cmp_stage_alct` | allocate（占位/预分配一路） |
| 10 | `cmp_stage_cln` | clean（写回脏行但保留 valid） |
| 9 | `cmp_stage_icln` | invalidate-clean（写回并失效） |
| 8 | `cmp_stage_write_sd` | write shared-dirty |
| 7 | `cmp_stage_write_uc` | write unique-clean |
| 6 | `cmp_stage_write_ud` | write unique-dirty |
| 5 | `cmp_stage_write_sc` | write shared-clean |
| 4 | `cmp_stage_atag` | access tag（仅访 tag，改 cp） |
| 3 | `cmp_stage_inv` | invalidate |
| 2 | `cmp_stage_release` | release（释放 pending 占位） |
| 1 | `cmp_stage_unique` | 升级独占 |
| 0 | `cmp_stage_shared` | 降级共享 |

`cmp_stage_write = write_sd | write_sc | write_uc | write_ud`（`:612-613`）：4 种写归一。
`cmp_stage_nop = ~(|type[12:0])`（`:639`）：全 0 表示空操作（只携带 cp 操作）。

---

## 5. 命中/选路逻辑（16 路并行比较）

### 5.1 命中判定（`:560-563`）

tag 级已把 16 路的 “valid 且 tag 匹配” 算成 `cmp_way_v_hit[15:0]`。cmp 级只需 OR 归约：

```verilog
assign l2c_cache_hit      = |cmp_way_v_hit[15:0];     // 任一路命中  (:560)
assign cmp_hit_way_dirty  = |cmp_way_vd_hit[15:0];    // 命中路是脏的 (:561)
assign cmp_hit_way_shared = |cmp_way_vs_hit[15:0];    // 命中路是共享 (:562)
assign cmp_hit_way_unique = |cmp_way_vu_hit[15:0];    // 命中路是独占 (:563)
assign l2c_cache_miss     = !l2c_cache_hit;            // (:602)
```

> 为什么把比较拆到 tag 级算？因为 16 路 × 24 位 tag 比较是关键路径，放在 tag 级（数据刚出 SRAM）做，cmp 级只做 OR 归约和后续逻辑，平衡了流水各级时延。

### 5.2 命中路属性的 one-hot 选择（`:584-600`）

命中后要取出命中路的 cp 位，用 `cmp_way_v_hit` 做 16-to-1 one-hot mux：

```verilog
assign cmp_stage_cp[3:0] =
   {4{cmp_way_v_hit[0]}}  & l2c_way0_cp_dout[3:0] | ... |
   {4{cmp_way_v_hit[15]}} & l2c_way15_cp_dout[3:0];   // :584-600
```

### 5.3 替换路 tag 提取（`:564-582`）

miss 要替换一路时，用 `l2c_way_fifo`（FIFO 替换指针，来自 tag 级）做 one-hot 选出被替换路的旧 tag `rplc_tag[23:0]`（`:566-582`），它将拼成 snoop 地址（见 §6.4）。`cmp_rplc_way_vld = |(l2c_way_fifo & l2c_way_vld)`（`:564`）= 被选替换路当前是否 valid（valid 才需 snoop/回写）。

---

## 6. 状态迁移计算与 tag/dirty 回写

cmp 级是 MESI 状态机所在地。每路 status 8 位 `{cp[3:0],valid,shared,dirty,pend}`，cmp 级算出每位的 set/clr。

### 6.1 set/clr 计算（`:614-637`）

| 位 | set 条件 | clr 条件 | file:line |
|----|----------|----------|-----------|
| valid | `cmp_stage_refill`（写 miss 占新行） | `(inv\|icln)&hit` | `:616-617` |
| dirty | `write_ud\|write_sd` | `write_uc\|write_sc\|valid_clr\|(cln\|icln)&hit_dirty` | `:619-623` |
| shared | `write_sd\|write_sc\|(shared&hit_unique)` | `write_uc\|write_ud\|valid_clr\|(unique&hit_shared)` | `:625-629` |
| pend | `alct&(!rplc_vld\|snpl2_grant)` | `release\|refill` | `:631-632` |
| cp | `setcp` 任一位 | `clrcp & 当前 cp` 任一位 | `:636-637` |

其中 `cmp_stage_refill = cmp_stage_write & l2c_cache_miss`（`:614`）：写未命中 → 占一新行。
`pend_set` 只在 alct 且“没空闲可替换路、或 snoop 已被接受”时置（`:631`），配合 §6.4 的 snoop 序列化。

### 6.2 status 写数据合成（`:673-708`）

```verilog
status_wen[7:0]     = {cp_wen[3:0], valid_wen, shared_wen, dirty_wen, pend_wen};      // :673
status_set_din[7:0] = {setcp, valid_set, shared_set, dirty_set, pend_set};            // :675
status_clr_din[7:0] = {clrcp, valid_clr, shared_clr, dirty_clr, pend_clr};            // :676
status_din[7:0]     = refill ? status_set_din                                          // 新行直接写 set
                             : (l2c_status_din | status_set_din) & ~status_clr_din;    // 旧行读改写 :677-679
```

`l2c_status_din` 用 `cmp_status_ptr` 从 16 路 dirty_dout 中 one-hot 选出**当前路**的旧 status（`:682-698`），实现“读-改-写”。

写哪一路由指针决定（`:701-703`）：
- 命中类操作写 `cmp_way_v_hit`（命中路）；
- refill/release 写 `cmp_refill_ptr`（新分配路）；
- alct 写 `l2c_way_fifo`（FIFO 选中的待替换路）。

最终 dirty SRAM 写：`cmp_dirty_din[143:0] = {fifo_din[15:0], {16{status_din[7:0]}}}`（`:708`）——低 128 位是 16 路 × 8 位 status（按 `cmp_dirty_way` one-hot 选写哪一路），高 16 位是更新后的 FIFO 替换位（`:700`，左旋一位实现 FIFO 推进）。

### 6.3 tag/dirty RAM 请求与片选（`:641-711`）

```verilog
tag_updt     = cmp_stage_refill;                       // 只有占新行才写 tag :641
dirty_updt   = write | valid_clr | ... | cp_set | cp_clr;  // 多种情况要更新 status :642-648
cmp_req_vld  = cmp_stage_vld & (tag_updt | dirty_req_vld); // 本级有 RAM 写需求 :658
cmp_tag_cen  = cmp_stage_vld & tag_updt   & !cmp_stall_by_data;  // tag 片选 :661
cmp_dirty_cen= cmp_stage_vld & dirty_updt & !cmp_stall_by_data;  // dirty 片选 :662
cmp_tag_wen[15:0] = cmp_refill_ptr & {16{tag_wen}};    // 只写替换路那一路 :705
```

> 注意 tag 与 dirty(status) 分开：命中读/cp 改动只需写 status（dirty 阵列），不动 tag；只有 refill 占新行才写 tag。这减少了 tag SRAM 的写翻转。

### 6.4 侦听（snoop）输出（`:789-805`）

当 alct 要替换一路、而被替换路当前 valid（`cmp_rplc_way_vld`）时，必须先 snoop 把该行从核里赶出：

```verilog
l2c_ciu_snpl2_vld_x  = cmp_stage_vld & cmp_stage_alct & cmp_rplc_way_vld & !snpl2_granted;  // :790
l2c_ciu_snpl2_addr_x = {rplc_tag[23:0], cmp_stage_addr[8:0]};   // 替换行的旧地址 :792
```

`snpl2_granted` 记录 CIU 是否已接受这次 snoop（`:795-803`），避免重发；`snpl2_grant = ready | granted`（`:805`）一旦被接受就允许 pend_set 推进。这就是**侦听过滤器**与替换的协同：替换有效行前先发精确 snoop。

---

## 7. data RAM 请求与 way→data-index 选路

### 7.1 何时访 data（`:717-720`）

```verilog
data_rd = read & hit | (cln|icln) & hit_dirty;   // 读命中 / 需回写脏行 :717
data_wr = write & cmp_data_vld;                   // 写且写数据已到 :718
cmp_data_req = cmp_stage_vld & (data_wr|data_rd) & !cmp_data_piped_down;  // :720
```

`cmp_data_piped_down`（`:722-732`）：data 请求一旦被 data 级接走（`cmp_data_req && data_yy_ram_idle`）就置 1，防止同一请求重复发 data。

### 7.2 way 编号 → 13 位 data-index（`:747-770`）

data SRAM 一个 bank 深 8192 = 16 路 × 512 组。所以 data-index = `{way[3:0], 组内偏移[8:0]}`。把 one-hot 的 `cmp_req_way_ptr[15:0]` 经 casez 转成 4 位 way 号（`:747-769`），再拼地址低位：

```verilog
cmp_data_index[12:0] = {cmp_data_way[3:0], cmp_stage_addr[8:0]};   // :770
```

> 这就是 `02` 篇里 data 索引 13 位的来历：高 4 位选路、低 9 位选组（注 `DATA_INDEX_LENTH-5=8`，即 addr[8:0]）。

---

## 8. 反压：cmp_stage_stall / cmp_stall_by_data

cmp 级两个反压源（`:499,776-781`）：

```verilog
cmp_stage_stall  = cmp_stage_vld & (cmp_stall_by_data | cmp_req_vld & !tag_yy_ram_idle);  // :499
cmp_stall_by_data= cmp_stage_vld & !cmp_data_piped_down & (stall_by_read | stall_by_write); // :776
stall_by_read    = data_rd & !data_yy_ram_idle;        // data 忙，读等不到 :779
stall_by_write   = cmp_stage_write & (!cmp_data_vld | !data_yy_ram_idle);  // 写数据没到 / data 忙 :780
```

含义：cmp 级在“要写 tag/dirty 但 tag RAM 没空”或“要访 data 但 data RAM 没空/写数据未到”时**自锁**（`cmp_stage_vld` 保持），从而反压 tag 级不再下传。这是把可编程 RAM 延迟吸收进流水的关键握手。

---

## 9. sub-bank：5 级流水 + SRAM 的装配

`ct_l2c_sub_bank.v`（约 877 行）是**一个完整的 512 组 / 16 路缓存单元**。它本身几乎没有逻辑，纯粹把 6 个子模块连起来：

| 子模块 | 实例 | 起始行（`ct_l2c_sub_bank.v`） |
|--------|------|------------------------------|
| `ct_l2c_tag`（①） | `x_ct_l2c_tag` | `:423` |
| `ct_l2c_cmp`（②） | `x_ct_l2c_cmp` | `:565` |
| `ct_l2c_data`（③） | `x_ct_l2c_data` | `:685` |
| `ct_l2c_wb`（④） | `x_ct_l2c_wb` | `:732` |
| `ct_l2c_icc`（⑤） | `x_ct_l2c_icc` | `:771` |
| `ct_l2cache_top`（SRAM） | `x_ct_l2cache_top` | `:848` |

### 9.1 级间连线（数据流的“骨架”）

| 连接 | 代表信号（`ct_l2c_sub_bank.v`） |
|------|--------------------------------|
| tag→cmp | `ttecc_flop_vld`、`ttecc_stage_addr/type/sid/src/setcp/clrcp/...`（`:365-375`） |
| cmp→data | `cmp_data_index/din/req/req_gate/wen/vld`（`:178-183`） |
| cmp→data（随路信息） | `cmp_stage_addr/cp/resp/sid/src/write/vld`（`:201-208`） |
| data→wb | `data_stage_cp/resp/sid/vld/index`（`:224-228`）、`l2c_data_dout_flop`（`:279`） |
| cmp→wb | `cmp_rfifo_cp/resp/sid/create`（`:197-200`） |
| SRAM→cmp | 16 路 `l2c_way0..15_tag_dout/cp_dout/dirty_dout`（`:307-354`） |

### 9.2 RAM 端口的三方仲裁（cmp / icc / wb）

tag/dirty/data 三类 SRAM 的端口都被多源共享。sub-bank 把三方的请求都连到对应的级模块里，由级模块内部仲裁：

- **tag/dirty 端口**：由 `ct_l2c_tag` 仲裁，接收 cmp 的 `cmp_tag_*/cmp_dirty_*`（连于 `:435-449`）、icc 的 `icc_tag_*/icc_dirty_*`（`:461-469`）、wb 的 `wb_tag_*/wb_dirty_*`（`:553-561`），输出统一的 `l2c_tag_*/l2c_dirty_*` 给 SRAM。
- **data 端口**：由 `ct_l2c_data` 仲裁，接收 cmp 的 `cmp_data_*`（`:688-692`）、icc 的 `icc_data_*`（`:712-715`），输出 `l2c_data_index0~3/cen/wen/din`。

> 优先级：icc（维护/DCA）> cmp（正常访问）> wb。一致性维护事务必须能抢到 RAM 端口，否则 flush 永远完不成（见 `04` 篇 icc）。

---

## 10. top：2 sub-bank 并行 + flush FSM + 可编程访问延迟

`ct_l2c_top.v`（约 713 行）是 L2C 综合边界，三件事：

### 10.1 实例化（`:525,599,672`）

```
x_ct_l2c_sub_bank_0   @ ct_l2c_top.v:525   ← bank_0（512 组）
x_ct_l2c_sub_bank_1   @ ct_l2c_top.v:599   ← bank_1（512 组）
x_ct_l2c_prefetch     @ ct_l2c_top.v:672   ← 两 bank 共享的预取引擎
```

对外端口几乎全部 **bank_0/bank_1 成对**（`ciu_l2c_addr_bank_0`/`_1` 等），这就是“2 sub-bank 并行 × 512 组 = 1024 组”在接口上的体现。地址到 bank 的散列**不在本模块**——top 给两个 bank 各自独立的 `addr_vld_bank_x`，由上游 CIU 决定一次请求落哪个 bank。

### 10.2 flush 状态机（`:454-513`）

对接 SoC 的 `sysio_l2c_flush_req`，要把**两个 bank**都 flush 干净。5 态（`:454-458`），状态寄存器 `flush_cur_state[2:0]`（`:254`）：

| 状态 | 编码 | 含义 |
|------|------|------|
| `IDLE` | 000 | 等 flush 请求 |
| `REQ` | 001 | 向两个 bank 同时发 flush |
| `WAIT_1` | 010 | bank_0 已完成，等 bank_1 |
| `WAIT_0` | 011 | bank_1 已完成，等 bank_0 |
| `DONE` | 100 | 两 bank 均完成，回报 SoC |

时序逻辑在 `:460-466`，组合次态在 `:468-513`。两个 bank 完成时间不同，所以分出 WAIT_1/WAIT_0 两个“等另一个”的中间态——这是“两 bank 并行但要同步收尾”的直接后果。

### 10.3 可编程访问延迟查表（`:398-447`）

CIU 给的是物理 latency/setup，top 把它换算成流水拍数 acc_cycle：

```verilog
tag_acc_cycle[3:0]  = {3'b0,ciu_l2c_tag_setup}  + {1'b0,ciu_l2c_tag_latency[2:0]};   // :398
data_acc_cycle[3:0] = {3'b0,ciu_l2c_data_setup} + {1'b0,ciu_l2c_data_latency[2:0]};  // :399
```

再各经一个 case 查表钳到合法范围：
- tag：`ciu_l2c_tag_acc_cycle[2:0]`，最大 `3'b100`（`:402-419`，3 位 → 最多 4 拍 + setup）。
- data：`ciu_l2c_data_acc_cycle[3:0]`，最大 `4'b1000`（`:422-447`，4 位 → 最多 8 拍）。

> 印证 `02` 篇“tag 计数 3 位、data 计数 4 位”的来历：data SRAM 更大更慢，给它更宽的访问拍数。这套查表让同一 RTL 适配不同频率/SRAM——把物理延迟解耦成可配置的流水拍数。

---

## 11. cache_top：SRAM 阵列容器

`ct_l2cache_top.v`（约 289 行）是纯结构容器，把三类 SRAM 阵列接好（与 `01`/`02` 篇呼应）：

| 阵列实例 | 模块 | file:line |
|----------|------|-----------|
| tag（16 路） | `ct_l2cache_tag_array_16way` | `:109` |
| dirty/status（16 路 + FIFO） | `ct_l2cache_dirty_array_16way` | `:130` |
| data bank0 | `ct_l2cache_data_array` `[127:0]` | `:157` |
| data bank1 | `ct_l2cache_data_array` `[255:128]` | `:179` |
| data bank2 | `ct_l2cache_data_array` `[383:256]` | `:200` |
| data bank3 | `ct_l2cache_data_array` `[511:384]` | `:221` |

要点：
- 4 个 data bank 各 128 位、各自独立 `l2c_data_index0~3`、独立片选 `l2c_data_ram_cen[i]`，拼成 512 位整行（`:157-230`）。
- 每 bank 的 128 位写使能由 1 位复制 128 份：`l2c_data_wen0[127:0]={128{l2c_data_wen[0]}}`（`:151-154`）。
- tag/dirty 共用 `l2c_tag_clk`、共用 `l2c_tag_index`（`:111-136`）——它们总是同组访问，一起读写。
- ECC 阵列（tag_ecc/dirty_ecc/data_ecc）只留注释占位（`:241-269`），开源版**未实例化**——与 `00`/`01`/`02` 的“ECC 仅框架”一致。

---

## 12. 一次访问的完整流水时序

以**核读命中**为例，串起 cmp 级（行号为 `ct_l2c_cmp.v`）：

```
① tag 级：读 16 路 tag/cp/dirty，算出 cmp_way_v_hit，ttecc_flop_vld 拉高下传
   │
② cmp 级（本篇）：
   cmp_stage_vld 锁存 (:506)，type 解出 read (:542)
   l2c_cache_hit = |cmp_way_v_hit (:560) → 命中
   data_rd = read & hit (:717) → cmp_data_req (:720)
   way one-hot → 4 位 → cmp_data_index = {way, addr[8:0]} (:770)
   命中读不改 tag，只可能改 status(cp)；cmp_rfifo_create 生成响应 (:835)
   cmp_pref_* 喂预取（若 ifu/tlb miss）(:811-816)
   │  若 data 忙 → cmp_stall_by_data 自锁 (:776)
③ data 级：data_acc_cnt 吸收延迟，选中 way 的 4 bank 读 512 位 → l2c_data_dout_flop
   │
④ wb 级：组装 l2c_ciu_data_x(512b)/resp/cp/sid → l2c_ciu_cmplt_x（见 04 篇）
   │
   ▼ 返回 CIU → 路由回发起核
```

写/维护/预取的分支见 §6/§7 与 `04` 篇。

---

## 设计取舍小结

1. **比较拆分到 tag 级、归约放 cmp 级**：16 路 × 24 位 tag 比较是关键路径，放 SRAM 出口（tag 级）做；cmp 级只做 OR 归约 + 状态机，平衡流水各级时延。
2. **tag 与 status(dirty) 阵列分离**：命中读/cp 改动只写 status、不动 tag，只有 refill 才写 tag——减少 tag SRAM 写翻转，也让“读-改-写 status”在一个阵列里闭环（`status_din` 读改写，`:677`）。
3. **侦听过滤 + 替换序列化**：替换 valid 行前用 `rplc_tag` 拼精确 snoop 地址只 snoop 持有核，`snpl2_granted` + `pend` 位把“snoop—占位—refill”序列化，避免一致性窗口。
4. **sub-bank 是干净的复用单元**：把 5 级 + SRAM 封成一个 512 组单元，top 例化两份即得 1024 组——加倍吞吐、对称布局，代价是接口全部成对、综合规模翻倍。
5. **flush 的 WAIT_1/WAIT_0 双等态**：两 bank 并行 flush 但完成时间不同，用两个中间态分别等“另一个”，体现“并行执行、同步收尾”。
6. **可编程访问延迟查表集中在 top**：物理 latency/setup → 流水拍数 acc_cycle 的换算放顶层一处（`:398-447`），让 sub-bank 内部逻辑与具体 SRAM 时序解耦。

---

*本文覆盖 ct_l2c_cmp.v 全部关键逻辑（类型解码、命中/选路、MESI 状态迁移、tag/dirty 回写、data 请求、snoop、反压），以及 ct_l2c_sub_bank.v / ct_l2c_top.v / ct_l2cache_top.v 的层次装配、flush FSM 与可编程访问延迟，合计约 2797 行。tag 级见 01，data 级见 02，wb/icc/prefetch 见 04。*
