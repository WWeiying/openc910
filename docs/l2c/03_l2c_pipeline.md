# C910 L2C 比较流水与 sub-bank/顶层 模块详细教学文档

> RTL 文件：`ct_l2c_cmp.v`（约 898 行，cmp 第②级）、`ct_l2c_sub_bank.v`（约 877 行，单 sub-bank 容器）、`ct_l2c_top.v`（约 713 行，综合顶层 + flush FSM）、`ct_l2cache_top.v`（约 289 行，SRAM 阵列容器）
> 配置：`cpu/rtl/cpu_cfig.h`（`L2C_TAG_INDEX_WIDTH=9`、`L2C_TAG_DATA_WIDTH=24`、`L2C_DATA_INDEX_WIDTH=13`，行 396~398）
> 本篇讲解普通访问主路径的 cmp 控制级，并自底向上说明 **sub-bank（一个 512 local-set 缓存分片）→ top（2 sub-bank + flush）→ cache_top（SRAM 阵列）**。普通访问主路径是 tag/cmp/data/wb；ICC 是排空后互斥运行的维护/DCA 引擎，不计作普通请求的顺序第五级。

## 目录
- [1. 模块概述](#1-模块概述)
- [2. 端口说明](#2-端口说明)
- [3. 参数与关键寄存器](#3-参数与关键寄存器)
- [4. cmp 级：操作类型解码与流水寄存器](#4-cmp-级操作类型解码与流水寄存器)
- [5. 命中/选路逻辑（16 路并行比较）](#5-命中选路逻辑16-路并行比较)
- [6. 状态迁移计算与 tag/dirty 回写](#6-状态迁移计算与-tagdirty-回写)
- [7. data RAM 请求与 way→data-index 选路](#7-data-ram-请求与-waydata-index-选路)
- [8. 反压与 HPCP 访问事件](#8-反压与-hpcp-访问事件)
- [9. sub-bank：主路径、ICC 与 SRAM 的装配](#9-sub-bank普通主路径icc-与-sram-的装配)
- [10. top：2 sub-bank 并行 + flush FSM + 可编程访问延迟](#10-top2-sub-bank-并行--flush-fsm--可编程访问延迟)
- [11. cache_top：SRAM 阵列容器](#11-cache_topsram-阵列容器)
- [12. 一次访问的完整流水时序](#12-一次访问的完整流水时序)
- [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 职责

普通 L2 访问沿 **tag → cmp → data → wb** 主路径推进；不需要数据的事务可由 cmp 直接创建纯响应进入 wb 的 rfifo。ICC 是同一 sub-bank 内独立的整体维护/DCA 引擎，等待主路径排空后接管 SRAM。本文聚焦 cmp 控制级以及把主路径、ICC 和阵列装配起来的三个层次容器：

| 层次 | 文件 | 干什么 |
|------|------|--------|
| cmp 控制级 | `ct_l2c_cmp.v` | 消费 tag 级已形成的 16 路命中向量，归约 hit/miss，选择命中/victim/refill way，计算状态更新，发 data 请求，生成 victim CleanInvalid 请求和响应 |
| sub-bank | `ct_l2c_sub_bank.v` | 一个 **512 local-set / 16 路** 的缓存分片：实例化 tag/cmp/data/wb 主路径、独立 ICC 引擎和一份 SRAM 阵列 |
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

cmp 级是 L2 行状态更新的主要控制点：它归约 tag 级命中结果、计算 `valid/shared/dirty/pend/cp` 的 set/clr，并把命中路的 `cp` 返回 CIU。侦听过滤的最后一步不在本模块完成，逐 PIU snoop enable 位于 CIU。

---

## 2. 端口说明

`ct_l2c_cmp`（`ct_l2c_cmp.v:17-134`）端口按数据流分组：

| 组 | 端口 | 方向 | 含义 |
|----|------|------|------|
| 上游 tag 流水 | `ttecc_flop_vld`、`ttecc_stage_addr[32:0]`、`ttecc_stage_type[12:0]`、`ttecc_stage_sid[4:0]`、`ttecc_stage_src[1:0]`、`ttecc_stage_setcp/clrcp[3:0]`、`ttecc_stage_mid/hpcp_bus[2:0]`、`ttecc_stage_fatal_err`、`ttecc_stage_write_raw` | in | tag 级（经 ECC 占位 ttecc）下传的请求信息（`:201-211`） |
| 16 路 RAM 读回 | `l2c_way0..15_tag_dout[23:0]`、`l2c_way0..15_cp_dout[3:0]`、`l2c_way0..15_dirty_dout[7:0]` | in | 16 路 tag / core-presence / status(dirty) 数据 |
| 命中向量 | `cmp_way_v_hit[15:0]`、`cmp_way_vd_hit`、`cmp_way_vs_hit`、`cmp_way_vu_hit` | in | 由 tag 级算好的“valid+tag 匹配 / +dirty / +shared / +unique”16 路 one-hot（`:139-143`） |
| 选路 | `cmp_refill_ptr[15:0]`、`l2c_way_fifo[15:0]`、`l2c_way_vld[15:0]` | in | 已占位 refill/release way、allocate victim one-hot、各路 valid；前两个指针用途不同 |
| 回写 tag | `cmp_tag_cen/gwen`、`cmp_tag_index[8:0]`、`cmp_tag_wen[15:0]` | out | tag SRAM 写控制（`:241-244`） |
| 回写 dirty | `cmp_dirty_cen/gwen`、`cmp_dirty_way[15:0]`、`cmp_dirty_wen[8:0]`、`cmp_dirty_din[143:0]` | out | status/FIFO SRAM 写（`:216-220`） |
| data 请求 | `cmp_data_req/req_gate/wen`、`cmp_data_index[12:0]` | out | 发给 data 级的读/写（`:212-215`） |
| 给 wb 的响应 | `cmp_rfifo_create`、`cmp_rfifo_resp[4:0]`、`cmp_rfifo_cp[3:0]`、`cmp_rfifo_sid[4:0]`、`cmp_stage_resp[4:0]` | out | 进 wb 的 rfifo 或直通（`:228-235`） |
| victim 清理 | `l2c_ciu_snpl2_vld_x`、`l2c_ciu_snpl2_addr_x[32:0]`、`l2c_ciu_snpl2_ini_sid_x[4:0]`、`ciu_l2c_snpl2_ready_x` | out/in | allocate 替换有效 victim 时，请 CIU/SNB接受一笔 CleanInvalid 事务 |
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
| `L2C_ADDRW` | 33 | `:465` | 单个 sub-bank 内部地址 `PA[39:7]`；bank 位 `PA[6]` 由 CIU 路由 |

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
| `snpl2_granted` | 1 | victim CleanInvalid 请求已被 CIU 接受；不表示全部下游 snoop 已完成 | `:268`、写于 `:795-803` |

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
| 10 | `cmp_stage_cln` | 单行 clean 请求；命中脏行时读取数据、清 dirty，不清 valid，由 CIU 完成后续数据处理 |
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

tag 比较逻辑实际位于 `ct_l2c_tag` 的 SRAM/ECC 读出边界，cmp 只消费并归约结果。这样划分改变了各级组合路径分布；是否改善目标频率需要综合后的 path report 证明，不能仅由模块名得出结论。

### 5.2 命中路属性的 one-hot 选择（`:584-600`）

命中后要取出命中路的 cp 位，用 `cmp_way_v_hit` 做 16-to-1 one-hot mux：

```verilog
assign cmp_stage_cp[3:0] =
   {4{cmp_way_v_hit[0]}}  & l2c_way0_cp_dout[3:0] | ... |
   {4{cmp_way_v_hit[15]}} & l2c_way15_cp_dout[3:0];   // :584-600
```

### 5.3 替换路 tag 提取（`:564-582`）

allocate 需要选择 victim 时，用 `l2c_way_fifo` 做 one-hot 选择并取出旧 tag `rplc_tag[23:0]`。`cmp_rplc_way_vld = |(l2c_way_fifo & l2c_way_vld)` 只判断被选 victim 在 L2 中是否 valid：无效 victim 可直接占位；有效 victim 要先通过 `snpl2` 请求 CIU/SNB执行 CleanInvalid。这里没有使用 victim 的 `cp` 直接产生逐核 snoop。

### 5.4 命中向量必须满足 one-hot，不是由本级自动保证

正常缓存不允许同一 set 中有两路同时保存相同的有效 tag，因此
`cmp_way_v_hit` 应为 one-hot 或全 0。当前 RTL 只做 OR 归约和 one-hot mux，
没有 multi-hit 检测、优先修复或 fatal error 上报：

- `l2c_cache_hit = |cmp_way_v_hit` 会把多命中仍视为普通命中；
- `cmp_stage_cp` 由所有命中路的 `cp` 按位 OR 得到；
- `cmp_dirty_way=cmp_way_v_hit` 会使某些状态更新同时作用于多个命中路；
- `cmp_data_way` 的 `casez` 只列出 16 个严格 one-hot 模式，多 hot 时走
  `default`，把 data way 编成 0。

因此“同一 set、同一 tag 至多一个 valid way”是必须由复位/维护、allocate-refill
协议和系统验证共同保证的结构不变量。建议在验证环境中断言：

```systemverilog
assert ($onehot0(cmp_way_v_hit));
```

这条断言不是新增功能，而是把当前 RTL 隐含依赖的正确性条件显式化。

---

## 6. 状态迁移计算与 tag/dirty 回写

cmp 级计算 L2 每路压缩状态字段的 set/clr。该 8 位字段为 `{cp[3:0],valid,shared,dirty,pend}`，属于 MESI 风格的状态元数据，但不是一个完整 MOESI 枚举状态机。

### 6.1 set/clr 计算（`:614-637`）

| 位 | set 条件 | clr 条件 | file:line |
|----|----------|----------|-----------|
| valid | `cmp_stage_refill`（写 miss 占新行） | `(inv\|icln)&hit` | `:616-617` |
| dirty | `write_ud\|write_sd` | `write_uc\|write_sc\|valid_clr\|(cln\|icln)&hit_dirty` | `:619-623` |
| shared | `write_sd\|write_sc\|(shared&hit_unique)` | `write_uc\|write_ud\|valid_clr\|(unique&hit_shared)` | `:625-629` |
| pend | `alct&(!rplc_vld\|snpl2_grant)` | `release\|refill` | `:631-632` |
| cp | `setcp` 任一位 | `clrcp & 当前 cp` 任一位 | `:636-637` |

其中 `cmp_stage_refill = cmp_stage_write & l2c_cache_miss`：写事务未在有效 tag 中命中时，按 refill 路径安装新 tag/status/data。

`pend_set = alct & (!cmp_rplc_way_vld | snpl2_grant)` 的精确含义是：

- victim 无效时，不需要清理即可置 pend；
- victim 有效时，必须等 `snpl2` 被 CIU 接收，或先前已记录为 granted，才置 pend。

它不是“没有空闲路时置 pend”，而是“victim 已经不需要清理，或者清理请求已被接收后，正式建立占位”。

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
- refill/release 写 `cmp_refill_ptr`（从 `!valid & pend` 中最低位优先找到的既有占位路）；
- alct 写 `l2c_way_fifo`（FIFO 选中的待替换路）。

最终 dirty SRAM 写数据为 `{fifo_din[15:0], {16{status_din[7:0]}}}`。同一份 8 位 `status_din` 被复制到 16 个 way 切片，但低有效 bit write-enable 只开放 `cmp_dirty_way` 选中的 way，所以并非把 16 路状态全部改成相同值。高 16 位只在 `fifo_wen` 有效时写入，`{old[14:0],old[15]}` 把正常 one-hot 选择向高位轮转一格。

### 6.3 tag/dirty RAM 请求与片选（`:641-711`）

```verilog
tag_updt     = cmp_stage_refill;                       // 只有占新行才写 tag :641
dirty_updt   = write | valid_clr | ... | cp_set | cp_clr;  // 多种情况要更新 status :642-648
cmp_req_vld  = cmp_stage_vld & (tag_updt | dirty_req_vld); // 本级有 RAM 写需求 :658
cmp_tag_cen  = cmp_stage_vld & tag_updt   & !cmp_stall_by_data;  // tag 片选 :661
cmp_dirty_cen= cmp_stage_vld & dirty_updt & !cmp_stall_by_data;  // dirty 片选 :662
cmp_tag_wen[15:0] = cmp_refill_ptr & {16{tag_wen}};    // 写此前 allocate 建立的 refill way :705
```

> 注意 tag 与 dirty(status) 分开：命中读/cp 改动只需写 status（dirty 阵列），不动 tag；只有 refill 占新行才写 tag。这减少了 tag SRAM 的写翻转。

### 6.4 allocate → refill/release 是强协议顺序

`cmp_refill_ptr` 只从当前 set 的 `!valid && pend` 集合中选最低编号 way。
L2C 没有为 pending way 保存“未来新 tag、事务 SID 或返回顺序”之类的关联信息，
也没有在 refill/release 到来时检查候选是否存在。因此正常事务必须满足：

```text
allocate 成功建立 pend
        ↓
CIU/SNB 完成下级访问或决定放弃
        ↓
同一 set 的 refill 或 release 找到对应 pend way
```

若写 miss/refill 到来时 `cmp_refill_ptr==0`，RTL 不会阻塞或报错：
`cmp_tag_wen` 和 `cmp_dirty_way` 都没有选中任何 way，但 data-index 的 one-hot
解码走默认值 way0，整行数据仍可能写入 way0，随后还可创建写完成响应。结果可能是
“数据阵列被改写，但 tag/status 没有安装”。若 release 没有候选，则没有 way
被清 pend，却仍可产生 release 完成响应。

同一 set 若同时存在多个 pending way，本模块也只按最低 way 编号消费，不能依据
SID 或新 tag 区分它们。因此上游必须保证同 set 的 allocate 与 refill/release
顺序可由该最低位规则唯一对应，或者更严格地限制同 set 未完成占位数。验证时至少应
检查：

```systemverilog
assert (!(cmp_stage_vld && (cmp_stage_refill || cmp_stage_release)) ||
        $onehot(cmp_refill_ptr));
```

这里的重点不是断言语法，而是验证目标：refill/release 被接受时必须恰有一个候选；
不能把“找不到候选”当作硬件会自行恢复的普通 miss。

### 6.5 victim CleanInvalid 请求（`snpl2`，`:789-805`）

当 allocate 选中的 victim 当前 valid 时，L2C 要先请求 CIU/SNB 对该旧行执行 CleanInvalid：

```verilog
l2c_ciu_snpl2_vld_x  = cmp_stage_vld & cmp_stage_alct & cmp_rplc_way_vld & !snpl2_granted;  // :790
l2c_ciu_snpl2_addr_x = {rplc_tag[23:0], cmp_stage_addr[8:0]};   // PA[39:16] + PA[15:7]
```

当前 sub-bank 的 bank 位 `PA[6]` 不在这 33 位地址里；CIU 的 `ct_ciu_l2cif` 根据请求来自 bank0 还是 bank1，把 0 或 1 拼回完整 line 地址，并把事务类型编码为 `CleanInvalid`。

`snpl2_granted` 在 CIU ready 的时钟边沿记住请求已被接受，避免 cmp 因反压保持时重复发送。`snpl2_grant = ready | granted` 允许首次握手当拍或后续保持拍建立 pend。该路径与通用 cp-filtered snoop 要区分：L2C 的 `snpl2` 不携带逐核 mask；CIU/SNB 收到事务后才结合目录响应和一致性状态安排实际 PIU snoop。

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

## 8. 反压与 HPCP 访问事件

### 8.1 cmp_stage_stall / cmp_stall_by_data

cmp 级两个反压源（`:499,776-781`）：

```verilog
cmp_stage_stall  = cmp_stage_vld & (cmp_stall_by_data | cmp_req_vld & !tag_yy_ram_idle);  // :499
cmp_stall_by_data= cmp_stage_vld & !cmp_data_piped_down & (stall_by_read | stall_by_write); // :776
stall_by_read    = data_rd & !data_yy_ram_idle;        // data 忙，读等不到 :779
stall_by_write   = cmp_stage_write & (!cmp_data_vld | !data_yy_ram_idle);  // 写数据没到 / data 忙 :780
```

含义：cmp 级在“要写 tag/dirty 但 tag RAM 没空”或“要访 data 但 data RAM 没空/写数据未到”时**自锁**（`cmp_stage_vld` 保持），从而反压 tag 级不再下传。这是把可编程 RAM 延迟吸收进流水的关键握手。

### 8.2 HPCP 计数的精确定义（`:878-888`）

cmp 输出四类增量事件：

```verilog
rd_first       = cmp_stage_hpcp_bus[0];
wt_first       = cmp_stage_hpcp_bus[1];
read_acc_vld   = cmp_stage_vld && rd_first;
write_acc_vld  = cmp_stage_vld && wt_first;
read_miss_vld  = read_acc_vld  && !l2c_cache_hit;
write_miss_inc = write_acc_vld && !l2c_cache_hit;

acc_inc[1:0]  = {read_acc_vld,  write_acc_vld} & {2{!cmp_stage_stall}};
miss_inc[1:0] = {read_miss_vld, write_miss_inc} & {2{!cmp_stage_stall}};
```

位序是 `[1]=read`、`[0]=write`。`mid[2:0]` 与增量同时返回 CIU；
`ct_ciu_l2cif` 只在 `mid[2]==0` 时把事件路由到四个 PIU 之一，并按
`mid[1:0]` 选择核。

这不是简单地对每个 `cmp_stage_read/write` 计数。`rd_first/wt_first` 来自 CIU
事务项携带的 `hpcp_bus`；在 `ct_ciu_snb_sab_entry` 中，它们只在事务第一次进入
L2C 主阶段时置位。这样，一个事务后续的 allocate、refill、release 等内部 L2C
协议动作不会被重复算成新的处理器访问。事件又与 `!cmp_stage_stall` 相与，所以
请求在 cmp 保持多个周期时只在最终可推进的那一拍发出一次增量。

因此这些计数器回答的是“上游标记的首次 L2 读/写访问及其中的 tag miss 数”，而
不是：

- 所有 L2C 内部操作总数；
- 每个停顿周期的访问数；
- 预取是否被采用、miss 延迟或 miss 并发数；
- 单独的 read-hit/write-hit 数。命中数应由 `access - miss` 推导。

分析 miss rate 时还要保持分母一致：分别使用
`read_miss/read_access` 和 `write_miss/write_access`，并按相同 MID 汇总两个
sub-bank。将内部 refill 次数或纯响应数混入分母会得到错误的 L2 miss rate。

---

## 9. sub-bank：普通主路径、ICC 与 SRAM 的装配

`ct_l2c_sub_bank.v` 是一个 **512 local-set / 16 路缓存分片**。它以结构连线为主，但“几乎没有逻辑”也不够准确：该层还承载模块间共享信号、data/tag SRAM 端口接线、空闲状态汇总和若干输出组合。

| 子模块 | 实例 | 起始行（`ct_l2c_sub_bank.v`） |
|--------|------|------------------------------|
| `ct_l2c_tag`（主路径） | `x_ct_l2c_tag` | `:423` |
| `ct_l2c_cmp`（主路径） | `x_ct_l2c_cmp` | `:565` |
| `ct_l2c_data`（主路径） | `x_ct_l2c_data` | `:685` |
| `ct_l2c_wb`（主路径） | `x_ct_l2c_wb` | `:732` |
| `ct_l2c_icc`（维护/DCA） | `x_ct_l2c_icc` | `:771` |
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

### 9.2 RAM 端口的来源选择

tag/dirty/data 三类 SRAM 的端口都被多源共享。sub-bank 把三方的请求都连到对应的级模块里，由级模块内部仲裁：

- **tag/dirty 端口**：由 `ct_l2c_tag` 仲裁，接收 cmp 的 `cmp_tag_*/cmp_dirty_*`（连于 `:435-449`）、icc 的 `icc_tag_*/icc_dirty_*`（`:461-469`）、wb 的 `wb_tag_*/wb_dirty_*`（`:553-561`），输出统一的 `l2c_tag_*/l2c_dirty_*` 给 SRAM。
- **data 端口**：由 `ct_l2c_data` 仲裁，接收 cmp 的 `cmp_data_*`（`:688-692`）、icc 的 `icc_data_*`（`:712-715`），输出 `l2c_data_index0~3/cen/wen/din`。

tag/status 组合 mux 的选择顺序是 ICC/WB 合并源在 cmp 之前；data 地址 mux 在 ICC 请求有效时选择 ICC。不过当前 wb ECC 请求被硬连为 0，ICC 也只在主流水排空后开始，所以不应把它描述为三个活跃发起方每拍竞争的动态仲裁。正常工作模型是“普通流水运行”与“ICC 排空后接管”互斥。

---

## 10. top：2 sub-bank 并行 + flush FSM + 可编程访问延迟

`ct_l2c_top.v`（约 713 行）是 L2C 综合边界，三件事：

### 10.1 实例化（`:525,599,672`）

```
x_ct_l2c_sub_bank_0   @ ct_l2c_top.v:525   ← bank_0（512 组）
x_ct_l2c_sub_bank_1   @ ct_l2c_top.v:599   ← bank_1（512 组）
x_ct_l2c_prefetch     @ ct_l2c_top.v:672   ← 两 bank 共享的预取引擎
```

对外端口几乎全部 **bank_0/bank_1 成对**。bank 选择确实不在 `ct_l2c_top` 内，但上游也不是使用未说明的“散列”：CIU/PIU 直接按物理地址 `PA[6]` 路由，0 到 bank0，1 到 bank1；送入 sub-bank 的 33 位地址为 `PA[39:7]`。

### 10.2 flush 状态机（`:454-513`）

对接 SoC 的 `sysio_l2c_flush_req`，要等待两个 sub-bank 都完成“脏行下推后失效”。请求只有在 IDLE 且 `ciu_xx_no_op=1` 时才被接受。5 态（`:454-458`），状态寄存器 `flush_cur_state[2:0]`：

| 状态 | 编码 | 含义 |
|------|------|------|
| `IDLE` | 000 | 等 flush 请求 |
| `REQ` | 001 | 向两个 bank 持续提出 flush，并观察两路 done |
| `WAIT_1` | 010 | bank_0 已完成，等 bank_1 |
| `WAIT_0` | 011 | bank_1 已完成，等 bank_0 |
| `DONE` | 100 | 两 bank 均完成，回报 SoC |

`l2c_flush_req_bank_0/1` 只在 REQ 状态为 1。某 bank 的 ICC 接收后会锁存 `l2c_flush_f`，所以顶层进入 WAIT 后无需继续对已启动的 bank 保持 req。DONE 状态保持到外部撤销 `sysio_l2c_flush_req`；`flush_done` 因而是电平式完成阶段，不是单拍脉冲。

### 10.3 可编程访问延迟查表（`:398-447`）

CIU 给的是物理 latency/setup，top 把它换算成流水拍数 acc_cycle：

```verilog
tag_acc_cycle[3:0]  = {3'b0,ciu_l2c_tag_setup}  + {1'b0,ciu_l2c_tag_latency[2:0]};   // :398
data_acc_cycle[3:0] = {3'b0,ciu_l2c_data_setup} + {1'b0,ciu_l2c_data_latency[2:0]};  // :399
```

再各经一个 case 查表钳到合法范围：
- tag：`ciu_l2c_tag_acc_cycle[2:0]` 最大编码为 4；
- data：`ciu_l2c_data_acc_cycle[3:0]` 最大编码为 8。

计数器载入该编码后，在 BUSY 状态逐拍减到 0。不要把“载入值 4/8”未经时序定义就直接写成固定端到端延迟“4/8 拍”，因为接收边沿、setup 控制寄存器、计数归零观察和后级锁存还会影响可见完成拍。

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
   命中读不创建纯响应 rfifo；它继续进入 data/wb，随 512 位数据完成
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

## 本章小结

L2 子 bank 的访问沿 tag、cmp、data、wb 逐级推进。tag 级在 SRAM 出口形成 16 路比较并锁存，cmp 级归约命中、检查状态、选择 victim、更新压缩状态字段，并按事务类型发出 data 请求或直接形成响应。tag 与 status 阵列分离后，命中访问的 cp/共享/脏状态变化可以只读改写 status，只有 refill 才写入新 tag。这里可以确认比较与归约被放在不同流水边界，但哪一级构成最终关键路径仍须由综合时序报告判断。

替换有效行时，cmp 先用旧 tag 和 local set 构造 `snpl2`，CIU 补回 bank 位并发起 CleanInvalid；只有 `snpl2_granted` 后才建立 pending 占位，再等待 refill 或 release 结束。逐 PIU snoop 目标仍由 CIU 结合 cp 等目录信息选择。顶层实例化两个各含 512 个 local set 的 sub-bank，以 `PA[6]` 形成 1024 个全局 set；不同 bank 的请求具有并行推进的结构条件，但吞吐还受 CIU/SNB、地址分布和返回资源限制。flush 可同时启动两个 bank，再由 WAIT_1/WAIT_0 分别等待较慢一侧，实现并行执行、同步收尾。SRAM 物理 latency/setup 到流水 `acc_cycle` 的换算集中在顶层，观察时必须使用当前配置。tag 级见 01，data 级见 02，wb、ICC 与 prefetch 见 04。
