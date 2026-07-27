# C910 L2C Tag / Status 模块详细教学文档

> RTL 文件：`ct_l2c_tag.v`（约 1539 行）、`ct_l2cache_tag_array_16way.v`（约 195 行）、`ct_l2cache_dirty_array_16way.v`（约 90 行）、`ct_l2c_tag_ecc.v`（约 444 行）
> 配置：`cpu/rtl/cpu_cfig.h`（16WAY/1M 段，行 376-398）

## 目录
- [1. 模块概述](#1-模块概述)
- [2. 端口说明](#2-端口说明)
- [3. 参数与关键寄存器](#3-参数与关键寄存器)
- [4. Tag 阵列组织（ct_l2cache_tag_array_16way）](#4-tag-阵列组织ct_l2cache_tag_array_16way)
- [5. Status / Dirty 阵列与 8 位状态编码](#5-status--dirty-阵列与-8-位状态编码)
- [6. Tag RAM 访问 FSM 与可编程周期](#6-tag-ram-访问-fsm-与可编程周期)
- [7. Tag 比较与命中向量生成](#7-tag-比较与命中向量生成)
- [8. FIFO 替换（l2c_way_fifo / refill 指针）](#8-fifo-替换l2c_way_fifo--refill-指针)
- [9. Tag SECDED ECC（ct_l2c_tag_ecc）](#9-tag-secded-eccct_l2c_tag_ecc)
- [10. 多源仲裁与写通路](#10-多源仲裁与写通路)
- [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

`ct_l2c_tag` 是 L2C 流水的 **第 ① 级（tag 级）**。它负责：

1. **驱动 tag / dirty(status) RAM**：生成地址、片选、写使能，把 16 路 tag 和 16 路 status 一次读出。
2. **解码状态**：把 dirty/status RAM 读回的扁平比特解出每路的 `{cp[3:0],valid,shared,dirty,pend}`（`ct_l2c_tag.v:1078-1161`）。
3. **预比较 tag**：在 tag 级就做一遍 16 路地址比较（`tag_stage_addr_hit`，:1044），并与 valid/shared/dirty 与运算，得到送往 cmp 级的命中向量。
4. **算 FIFO 替换指针**：决定 miss 时填哪一路（:1171、:1331）。
5. **RAM 访问 FSM**：用 `tag_acc_cnt` 把可编程访问周期吸收进流水（:891、:948）。
6. **多源仲裁**：cmp / icc / wb / ciu 四类请求对 tag/dirty RAM 端口的仲裁（:594-643）。
7. **挂载 ECC 子模块** `ct_l2c_tag_ecc`（:1477）。

### 1.2 位置

```
CIU 请求 ─► [① ct_l2c_tag] ─► cmp_way_v_hit / cmp_refill_ptr / l2c_way_fifo
                │  ▲                 │  l2c_way{N}_tag_dout / cp_dout / dirty_dout
   l2c_tag_*    │  │ l2c_tag_dout    ▼
   l2c_dirty_*  ▼  │                ct_l2c_cmp (② 级)
        ct_l2cache_top (tag/dirty/data SRAM 阵列)
```

---

## 2. 端口说明

`ct_l2c_tag` 端口很多（16 路各有 tag/cp/dirty dout）。按功能分组：

| 组 | 代表端口 | 方向 | 含义 |
|----|----------|------|------|
| CIU 请求 | `ciu_l2c_addr_vld_x`/`ciu_l2c_addr_x[32:0]`/`ciu_l2c_type_x[12:0]`/`ciu_l2c_sid_x`/`ciu_l2c_src_x` | in | 新请求地址/类型/来源 |
| CIU cp | `ciu_l2c_set_cp_x[3:0]`/`ciu_l2c_clr_cp_x[3:0]`/`ciu_l2c_mid_x`/`ciu_l2c_hpcp_bus_x` | in | core-presence 置/清、master id、性能计数总线 |
| 周期配置 | `ciu_l2c_tag_acc_cycle[2:0]`/`ciu_l2c_tag_setup` | in | tag RAM 访问周期/建立 |
| cmp 回写 | `cmp_tag_cen/gwen/wen/index`、`cmp_dirty_*`、`cmp_req_vld`、`cmp_stage_addr/stall` | in | cmp 级对 tag/dirty 的更新请求 |
| icc 回写 | `icc_tag_cen/gwen/index/req`、`icc_dirty_*`、`icc_dca_way_sel`、`icc_idle` | in | icc(维护/DCA) 对 tag/dirty 的访问 |
| wb 回写 | `wb_tag_cen/gwen/index/req`、`wb_dirty_*`、`wb_ecc_rfifo_empty` | in | wb(ECC 写回) 通路 |
| 给阵列 | `l2c_tag_din/wen/gwen/index/ram_cen`、`l2c_dirty_*` | out | 驱动 tag/dirty SRAM |
| 阵列读回 | `l2c_tag_dout[383:0]`/`l2c_dirty_dout[143:0]` | in | SRAM 读回（16×24=384 tag；16×8+16=144 status+fifo） |
| 给 cmp | `cmp_way_v_hit/vd_hit/vs_hit/vu_hit[15:0]`、`cmp_refill_ptr[15:0]`、`l2c_way_fifo/vld/dirty[15:0]`、`l2c_way{N}_tag_dout/cp_dout/dirty_dout` | out | 命中向量 + 选路所需的 tag/状态 |
| 给 ttecc 级 | `ttecc_stage_addr/type/sid/...`、`ttecc_flop_vld` | out | 流水信息下传到 ecc/cmp |
| idle/grant | `tag_xx_idle`/`tag_yy_ram_idle`/`tag_icc_grant`/`tag_acc_cnt_zero` | out | 给 icc 仲裁的空闲指示 |
| DCA | `icc_dca_tag_f[23:0]`/`icc_dca_dirty_f[7:0]` | out | DCA 读出的 tag/dirty |

---

## 3. 参数与关键寄存器

参数（`ct_l2c_tag.v:569-571`、`:860`、`:1304`）：

| 参数 | 值（1M/16way） | file:line | 含义 |
|------|----------------|-----------|------|
| `TAG_INDEX_LENTH` | `L2C_TAG_INDEX_WIDTH` = 9 | `ct_l2c_tag.v:569` | tag 索引位宽 → 512 组/bank |
| `TAG_TAG_LENTH` | `L2C_TAG_DATA_WIDTH` = 24 | `ct_l2c_tag.v:570` | 每路 tag 标签位宽 |
| `L2C_ADDRW` | 33 | `ct_l2c_tag.v:571` | L2 内部地址位宽 |
| `TAG_IDLE/TAG_BUSY` | 2'b01 / 2'b10 | `ct_l2c_tag.v:860-861` | tag RAM FSM 两态（one-hot） |
| `CP_WIDTH` | 4 | `ct_l2c_tag.v:1304` | core-presence 位宽 |

关键寄存器（`ct_l2c_tag.v:299-355`）：

| 寄存器 | 位宽 | 含义 |
|--------|------|------|
| `tag_ram_state` | 2 | RAM 访问 FSM 当前态 |
| `tag_acc_cnt` | 3 | 访问周期倒数计数器 |
| `tag_refill_ptr` | 16 | 由 status_inv_pend 算出的 refill 路 one-hot |
| `cmp_refill_ptr` | 16 | 锁存给 cmp 的 refill 指针 |
| `cmp_way_v_hit/vd/vs/vu` | 16×4 | 命中向量（valid / valid&dirty / valid&shared / valid&unique） |
| `l2c_way_fifo` | 16 | 该组的 FIFO 替换状态位 |
| `l2c_dirty_dout_flop` | 80 | 锁存 {fifo,valid,shared,dirty,pend}×16 |
| `l2c_tag_cp_dout_flop` | 64 | 锁存 16 路 cp[3:0] |
| `l2c_way{N}_tag_dout` | 16×24 | 锁存的各路 tag |
| `way_fifo_pend_inv` | 16 | pend 优先级编码出的替换路 |

---

## 4. Tag 阵列组织（ct_l2cache_tag_array_16way）

`ct_l2cache_tag_array_16way`（`ct_l2cache_tag_array_16way.v`）把 16 路 tag 拆成 **4 颗 4 路 SRAM**：

- 端口：`tag_din/wen/dout` 宽度 = `16 * L2C_TAG_DATA_WIDTH = 16*24 = 384`（:34、:44-46）。
- 索引 `tag_idx` 宽 `L2C_TAG_INDEX_WIDTH`（:38）。
- 4 个实例，每个承载 4 路 tag（`TAG_DATA_WIDTH_4WAY = 4*24 = 96` 位）：
  - 实例 0：`tag_din[95:0]`（:89-91）
  - 实例 1：`tag_din[191:96]`（:122-124）
  - 实例 2：`tag_din[287:192]`（:155-157）
  - 实例 3：`tag_din[383:288]`（:188-190）
- **SRAM 型号随容量切换**（`ifdef` 链，:61-81）。1MB 配置选 `ct_spsram_512x96`（:71）：512 深 = 512 组/bank，96 位 = 4 路 × 24 位。

> 为什么拆 4 颗：单颗 16×24=384 位宽 SRAM 不利布局，4 颗 4 路是面积/时序折中。读出时 4 颗拼成 384 位 `l2c_tag_dout` 一次给 ecc/比较逻辑。

---

## 5. Status / Dirty 阵列与 8 位状态编码

### 5.1 阵列（ct_l2cache_dirty_array_16way）

`ct_l2cache_dirty_array_16way`（`ct_l2cache_dirty_array_16way.v`）是**一颗** 144 位宽 SRAM：

- 端口 `dirty_din/wen/dout` 固定 144 位（:37、:40-41）。
- 1MB 配置选 `ct_spsram_512x144`（:61-62）：512 深、144 位。
- 144 = **16 路 × 8 位 status（=128）+ 16 位 FIFO 替换位**。
  - `l2c_dirty_dout[127:0]` = 16 路 status（每路 8 位）。
  - `l2c_dirty_dout[143:128]` = 16 位 fifo（在 ecc 模块 :361 取出 `fifo_dout = l2c_dirty_dout[143:128]`）。

### 5.2 每路 8 位 status 编码（核心！）

每路 status = `{cp[3:0], valid, shared, dirty, pend}`。在 `ct_l2c_tag.v` 把 144 位读回拆成各路、再按位解出（`way{N}_dirty_dout_after_correct` 是 8 位 status）：

| 位 | 信号（按路聚合） | 取自 | file:line |
|----|------------------|------|-----------|
| `[7:4]` cp | `status_cp[63:0]` = 16 路各 `[7:4]` | `way{N}_dirty_dout_after_correct[7:4]` | `ct_l2c_tag.v:1078` |
| `[3]` valid | `status_vld[15:0]` = 16 路各 `[3]` | `..._after_correct[3]` | `ct_l2c_tag.v:1095` |
| `[2]` shared | `status_shared[15:0]` = 各 `[2]` | `..._after_correct[2]` | `ct_l2c_tag.v:1112` |
| `[1]` dirty | `status_dirty[15:0]` = 各 `[1]` | `..._after_correct[1]` | `ct_l2c_tag.v:1129` |
| `[0]` pend | `status_pend[15:0]` = 各 `[0]` | `..._after_correct[0]` | `ct_l2c_tag.v:1146` |

派生组合（`ct_l2c_tag.v:1165-1169`）：

```verilog
status_vld_shared = status_vld & status_shared;        // 有效且共享
status_vld_unique = status_vld & ~status_shared;       // 有效且独占
status_vld_dirty  = status_vld & status_dirty;         // 有效且脏
status_inv_pend   = ~status_vld & status_pend;         // 无效但 pend（=已占位待回填）
```

这些组合直接喂给 tag 级比较（第 7 节）和 refill 指针（第 8 节）。

### 5.3 cp / dirty 的输出回程

锁存后通过 `l2c_way{N}_dirty_dout[3:0]`（valid/shared/dirty/pend 重排，:1360-1375）与 `l2c_way{N}_dirty_dout[7:4]`（cp，:1377-1392）、`l2c_way{N}_cp_dout`（:1404-1419）送给 cmp 级选路。

---

## 6. Tag RAM 访问 FSM 与可编程周期

### 6.1 两态 FSM（`ct_l2c_tag.v:891-928`）

```
        tag_req_vld
 ┌──────────────────────┐
 │                      ▼
TAG_IDLE ───────────► TAG_BUSY
 ▲   (有请求)            │
 │                      │ tag_acc_cnt_zero & !next_stage_stall & !新请求
 └──────────────────────┘
```

- `tag_req_vld = icc_tag_req | cmp_tag_req | ciu_req_vld | wb_tag_req`（:888）——四源任一发起即进 BUSY。
- BUSY 中靠 `tag_acc_cnt` 倒数（:948-956）：`init` 时载入 `ciu_l2c_tag_acc_cycle[2:0]`（:953），随后每拍减 1，到 0（`tag_acc_cnt_zero`，:958）表示 RAM 数据就绪。
- `tag_stage_stall`（:934）= BUSY 且（计数未到 0 或后级反压），用于挡住前级。
- `tag_ram_idle`（:931）= IDLE 或（BUSY 且计数到 0），是 icc 抢占 RAM 的握手条件（`tag_icc_grant = tag_ram_idle`，:939）。

### 6.2 为什么需要可编程周期

不同工艺/频率下，大容量 SRAM 的读延迟不同。把访问周期做成 CIU 可配的 `tag_acc_cycle`，让同一份 RTL 适配不同 SRAM——代价是引入计数器和 BUSY 态，流水深度随配置变化。

---

## 7. Tag 比较与命中向量生成

tag 级在数据就绪后做 **16 路并行比较**（`ct_l2c_tag.v:1044-1059`）：

```verilog
tag_stage_addr_hit[i] =
   (ttecc_stage_addr[ADDR高位] == way{i}_tag_dout_after_correct[TAG_TAG_LENTH-1:0]);
```

比较位段取 `ttecc_stage_addr[L2C_ADDRW-1 : L2C_ADDRW-TAG_TAG_LENTH]`，即地址高 24 位（标签部分）。

命中向量与状态做与（:1061-1069）：

| 向量 | = | 含义 |
|------|---|------|
| `tag_stage_v_hit` | `addr_hit & status_vld` | 真命中（标签匹配且 valid） |
| `tag_stage_vs_hit` | `addr_hit & status_vld_shared` | 命中且共享 |
| `tag_stage_vu_hit` | `addr_hit & status_vld_unique` | 命中且独占 |
| `tag_stage_vd_hit` | `addr_hit & status_vld_dirty` | 命中且脏 |

这些在 `cmp_info` 时钟域被锁存成 `cmp_way_v_hit/vs/vu/vd`（:1444-1474），连同 `cmp_refill_ptr` 一起送给 cmp 级——也就是说 **真正的“比较”发生在 tag 级，cmp 级只是消费命中结果**（这点常被误解）。

---

## 8. FIFO 替换（l2c_way_fifo / refill 指针）

L2C 用一个 **近似 FIFO** 替换策略，避免真 LRU 的存储与更新开销。

### 8.1 refill 指针：优先填“占位待回填”的路

`status_inv_pend = ~valid & pend`（:1169）标识“已被 alloc 占位、但数据尚未回填”的路。`tag_refill_ptr` 用优先级编码挑出最低位的这类路（:1174-1195）：

```verilog
casez(status_inv_pend[15:0])
  16'b...............1: tag_refill_ptr[0]=1;   // 最低位优先
  ...
endcase
```

即 miss 回填时**优先复用已占位的空路**。该指针锁存为 `cmp_refill_ptr` 给 cmp 级（:1466、:1472）。

### 8.2 FIFO 状态位与 pend 推进

每组有 16 位 `status_fifo`（来自 dirty RAM 的 `[143:128]`，:1163），表示 FIFO 顺序。`l2c_way_fifo` 的更新（:1319-1331）：

```verilog
way_fifo = fifo_way_pend_vld ? way_fifo_pend_inv : status_fifo;
fifo_way_pend_vld = |(status_fifo & status_pend);   // FIFO 头正处于 pend
```

当 FIFO 选中的路恰处于 pend（不能被替换）时，用 `way_fifo_pend_inv`（按 `status_pend` 做前缀优先级编码，:1335-1356）跳过 pend 路，选下一个可替换路。这就是“FIFO + 跳过 pending”的替换近似。

> 取舍：FIFO 位只需 16 位/组并随 alloc 推进，远比 LRU 的两两比较矩阵省；命中率略低于 LRU，但 L2 容量大、相联高，差异有限。

---

## 9. Tag SECDED ECC（ct_l2c_tag_ecc）

`ct_l2c_tag_ecc`（`ct_l2c_tag_ecc.v`）是 tag/dirty 读出后的 **ECC 纠错级**，把原始 `l2c_tag_dout`/`l2c_dirty_dout` 拆成各路并产生 `*_after_correct` 信号供 tag 级使用。

### 9.1 架构意图（SECDED）

- 参数 `DIRTY_WIDTH=8`、`TAG_TAG_LENTH=24`（:202-206）。
- 注释中保留了完整的 ECC 编解码实例骨架：`ct_l2c_ecc_encode_7bit`（tag 7 位校验）、`ct_l2c_ecc_encode_5bit`（dirty 5 位校验）（:222-227），以及 16 路 `ct_l2c_tag_ecc_decode` 解码实例（:236-281）。7 位校验保护 ~24 位数据，正是 **SECDED（单纠错双检错）** 的汉明 + 整体奇偶位规模。
- 输出 `l2c_tag_dirty_fatal_err[15:0]` 是双比特错（不可纠）上报。

### 9.2 开源版的实现现状（重要）

在本开源 RTL 中，纠错运算**被旁路**，`*_after_correct` 直接等于原始读出：

```verilog
way0_tag_dout_after_correct   = way0_tag_dout;        // 直通，无纠错  (ct_l2c_tag_ecc.v:328)
way0_dirty_dout_after_correct = way0_dirty_dout;      // 直通          (ct_l2c_tag_ecc.v:344)
fifo_dout_after_correct       = fifo_dout;            // 直通          (ct_l2c_tag_ecc.v:362)
l2c_tag_dirty_fatal_err[7:0]  = 8'b0;                 // fatal 恒 0    (ct_l2c_tag_ecc.v:284)
l2c_tag_dirty_fatal_err[15:8] = 8'b0;                 //               (ct_l2c_tag_ecc.v:286)
```

`&Instance(...)` 注释表明 encode/decode 单元在交付物里未展开。**结论：ECC 的端口、流水级、syndrome 时序框架都在，但纠错核心未随开源版提供，功能上等价于“无 ECC”。** 学习时应理解“这是预留的 SECDED 通路”，不要把直通误读为算法。

### 9.3 DCA tag/dirty 旁路

ecc 模块还按 `icc_dca_way_sel` one-hot 选出 DCA 要读的那一路 tag/dirty（:367-399），锁存为 `icc_dca_tag_f`/`icc_dca_dirty_f`（:423-429），供 icc 的 DCA 调试读出。

---

## 10. 多源仲裁与写通路

tag/dirty RAM 端口被 4 类发起方共享，仲裁逻辑（`ct_l2c_tag.v:594-643`）：

- **片选**：`l2c_tag_cen = (icc_tag_cen | cmp_tag_cen | ciu_req_vld | wb_tag_cen) & !tag_stage_stall`（:594）。
- **索引选择**（优先级 icc/wb > cmp > ciu，:609-612）：
  ```verilog
  l2c_tag_index_pre = icc_wb_req ? icc_wb_tag_index
                    : cmp_req_vld ? cmp_tag_index
                    : ciu_l2c_addr_x[index];
  ```
- **写使能**：`cmp_icc_wb_tag_way` 选出要写的路 one-hot，扩展成每路 24 位的 `l2c_tag_wen_pre`（低有效，:623-639）。
- **写数据**：icc/wb 写 0（失效），cmp 写当前请求地址的标签（:641-643）。
- 地址命中旁路：`cmp_addr_hit`/`data_addr_hit`（:585-586）用低 7 位比较，处理同组连发的转发。

> 仲裁把维护(icc)/ECC 写回(wb) 放在最高优先级，保证一致性事务不被普通访问饿死；普通 ciu 请求优先级最低，靠流水反压保证不丢。

---

## 设计取舍小结

1. **状态集中、tag 分散**：16 路 status 集中放一颗 144 位 RAM，便于一次读出全 16 路做并行命中与替换决策；tag 则拆 4 颗 4 路 SRAM 平衡面积/时序。
2. **比较前移到 tag 级**：在 tag 级就完成 16 路比较并锁存命中向量，cmp 级只消费结果，缩短了 cmp 级关键路径——代价是 tag 级逻辑较重。
3. **8 位 status 把一致性目录嵌入缓存**：cp[3:0] 让 L2 成为侦听过滤器；valid/shared/dirty 实现 MESI 风格；pend 实现事务序列化。8 位/路的代价换来无需独立目录。
4. **FIFO+跳过 pend 的替换**：用 16 位/组的 FIFO 位近似 FIFO，遇 pend 路优先级编码跳过，简单省面积。
5. **可编程访问周期**：以计数器 FSM 吸收 SRAM 延迟，换取跨工艺/频率的可移植性。
6. **ECC 框架化但未实现**：保护通路结构齐全，纠错核未开源——务必区分架构意图与交付现状。

---

*文档覆盖 ct_l2c_tag.v / ct_l2cache_tag_array_16way.v / ct_l2cache_dirty_array_16way.v / ct_l2c_tag_ecc.v 的全部关键逻辑（FSM、状态解码、比较、FIFO 替换、ECC 框架、仲裁），合计约 2268 行。*
