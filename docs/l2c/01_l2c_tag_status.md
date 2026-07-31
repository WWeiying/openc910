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
- [9. Tag/Status ECC 预留通路（ct_l2c_tag_ecc）](#9-tagstatus-ecc-预留通路ct_l2c_tag_ecc)
- [10. 多源仲裁与写通路](#10-多源仲裁与写通路)
- [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 职责

`ct_l2c_tag` 是 L2C 流水的 **第 ① 级（tag 级）**。它负责：

1. **驱动 tag / dirty(status) RAM**：生成地址、片选、写使能，把 16 路 tag 和 16 路 status 一次读出。
2. **解码状态**：把 dirty/status RAM 读回的扁平比特解出每路的 `{cp[3:0],valid,shared,dirty,pend}`（`ct_l2c_tag.v:1078-1161`）。
3. **比较 tag**：tag/status 读回经过当前为直通的 ECC 边界后，在本模块中完成 16 路 tag 比较，并与 valid/shared/dirty 组合，得到送往 cmp 级的命中向量。
4. **产生两类不同的 way 指针**：`l2c_way_fifo` 给 allocate 选择 victim；`cmp_refill_ptr` 从 `!valid && pend` 中找此前已占位、等待 refill/release 的 way。二者不能混称为“miss 填充指针”。
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
| CIU 请求 | `ciu_l2c_addr_vld_x`/`ciu_l2c_addr_x[32:0]`/`ciu_l2c_type_x[12:0]`/`ciu_l2c_sid_x`/`ciu_l2c_src_x` | in | 新请求意图、内部地址 `PA[39:7]`、类型和来源；是否被接收还要看 `l2c_ciu_addr_ready_x` |
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
| `L2C_ADDRW` | 33 | `ct_l2c_tag.v:571` | 单个 sub-bank 接收的内部地址 `PA[39:7]`；`PA[6]` 已在 CIU 用于选 bank，`PA[5:0]` 为行内偏移 |
| `TAG_IDLE/TAG_BUSY` | 2'b01 / 2'b10 | `ct_l2c_tag.v:860-861` | tag RAM FSM 两态（one-hot） |
| `CP_WIDTH` | 4 | `ct_l2c_tag.v:1304` | core-presence 位宽 |

关键寄存器（`ct_l2c_tag.v:299-355`）：

| 寄存器 | 位宽 | 含义 |
|--------|------|------|
| `tag_ram_state` | 2 | RAM 访问 FSM 当前态 |
| `tag_acc_cnt` | 3 | 访问周期倒数计数器 |
| `tag_refill_ptr` | 16 | 从 `~valid & pend` 中最低位优先选出的 refill/release 路 one-hot；若不存在候选则全 0 |
| `cmp_refill_ptr` | 16 | 锁存给 cmp 的 refill 指针 |
| `cmp_way_v_hit/vd/vs/vu` | 16×4 | 命中向量（valid / valid&dirty / valid&shared / valid&unique） |
| `l2c_way_fifo` | 16 | 该组的 FIFO 替换状态位 |
| `l2c_dirty_dout_flop` | 80 | 锁存 {fifo,valid,shared,dirty,pend}×16 |
| `l2c_tag_cp_dout_flop` | 64 | 锁存 16 路 cp[3:0] |
| `l2c_way{N}_tag_dout` | 16×24 | 锁存的各路 tag |
| `way_fifo_pend_inv` | 16 | 当当前 FIFO one-hot 所指 way 为 pending 时，从 `status_pend` 中最低位优先找一个非 pending way |

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

四颗 SRAM 的确把 384 位总宽拆成四组 96 位并行端口。这样通常有利于宏单元选择、布线和时序，但 RTL 本身没有记录物理实现团队选择该划分的唯一原因；“面积/时序折中”应视为合理的实现解释，而不是可由功能 RTL 单独证明的设计动机。

---

## 5. Status / Dirty 阵列与 8 位状态编码

### 5.1 阵列（ct_l2cache_dirty_array_16way）

`ct_l2cache_dirty_array_16way`（`ct_l2cache_dirty_array_16way.v`）是**一颗** 144 位宽 SRAM：

- 端口 `dirty_din/wen/dout` 固定 144 位（:37、:40-41）。
- 1MB 配置选 `ct_spsram_512x144`（:61-62）：512 深、144 位。
- 144 = **16 路 × 8 位 status（=128）+ 16 位 FIFO 替换位**。
  - `l2c_dirty_dout[127:0]` = 16 路 status（每路 8 位）。
  - `l2c_dirty_dout[143:128]` = 16 位 fifo（在 ecc 模块 :361 取出 `fifo_dout = l2c_dirty_dout[143:128]`）。

当前 16-way wrapper 没有 `L2_CACHE_128K` 的 SRAM 实例分支，最小分支是 `L2_CACHE_256K`。因此不能从 `cpu_cfig.h` 中存在 128 KiB/16-way 位宽宏，进一步推断该组合在此交付 RTL 中已经完整可综合。

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

这些组合直接喂给 tag 比较和两类选路逻辑。`shared=0` 在 RTL 中被称为 unique，但这一个比特并不是完整 MOESI 枚举；`cp`、dirty 以及 CIU 中的事务状态仍需共同参与系统级一致性判断。

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
- `tag_ram_idle`（:931）= IDLE 或（BUSY 且计数到 0），表示当前访问计数不再占用 tag/status RAM。`tag_icc_grant` 组合地等于该信号；ICC 只会在整条主流水已排空后启动，因此这里是维护引擎接管端口时的本地 grant，不是任意时刻抢占在途普通请求。

### 6.2 为什么需要可编程周期

不同工艺/频率下，大容量 SRAM 的读延迟不同。把访问周期做成 CIU 可配的 `tag_acc_cycle`，让控制逻辑可等待不同的 SRAM 周期数。这里应区分“计数寄存器有 3 位”和“顶层允许的配置范围”：3 位寄存器理论上可表示 0~7，但 `ct_l2c_top` 的换算逻辑把当前 tag access cycle 钳到最大 4。

---

## 7. Tag 比较与命中向量生成

tag 级在数据就绪后做 **16 路并行比较**（`ct_l2c_tag.v:1044-1059`）：

```verilog
tag_stage_addr_hit[i] =
   (ttecc_stage_addr[ADDR高位] == way{i}_tag_dout_after_correct[TAG_TAG_LENTH-1:0]);
```

比较位段取 `ttecc_stage_addr[32:9]`。因为 `ttecc_stage_addr=PA[39:7]`，所以这 24 位精确对应物理地址 `PA[39:16]`；低 9 位 `addr[8:0]` 对应 local-set `PA[15:7]`。

命中向量与状态做与（:1061-1069）：

| 向量 | = | 含义 |
|------|---|------|
| `tag_stage_v_hit` | `addr_hit & status_vld` | 真命中（标签匹配且 valid） |
| `tag_stage_vs_hit` | `addr_hit & status_vld_shared` | 命中且共享 |
| `tag_stage_vu_hit` | `addr_hit & status_vld_unique` | 命中且独占 |
| `tag_stage_vd_hit` | `addr_hit & status_vld_dirty` | 命中且脏 |

这些在 `cmp_info` 时钟域被锁存成 `cmp_way_v_hit/vs/vu/vd`（:1444-1474），连同 `cmp_refill_ptr` 一起送给 cmp 级——也就是说 **真正的“比较”发生在 tag 级，cmp 级只是消费命中结果**（这点常被误解）。

### 7.1 多命中不是本模块会纠正的状态

16 路比较是彼此独立的，RTL 没有在 tag 级对
`tag_stage_v_hit[15:0]` 做 `$onehot0` 检查，也没有“多命中时只取最低路”的
优先编码器。正常情况下，缓存唯一性不变量应保证结果为 one-hot 或全 0。

如果同一 set 因协议错误、初始化错误或软错误形成两个相同 valid tag，两个命中位
会原样锁存给 cmp。cmp 随后把属性做 OR，并把命中向量直接用于 status way-enable；
data way 的严格 one-hot 解码则会在多 hot 时回落到默认 way0。这说明 multi-hit
不能被当作可容忍的“任选一路”情形，验证环境应把它作为错误立即捕获。当前
`fatal_err` 恒 0 的 ECC 旁路也不会替该不变量提供保护。

---

## 8. FIFO 替换（l2c_way_fifo / refill 指针）

L2C 用一个 **近似 FIFO** 替换策略，避免真 LRU 的存储与更新开销。

### 8.1 refill 指针：只寻找“此前已占位待回填”的路

`status_inv_pend = ~valid & pend`（:1169）标识“已被 alloc 占位、但数据尚未回填”的路。`tag_refill_ptr` 用优先级编码挑出最低位的这类路（:1174-1195）：

```verilog
casez(status_inv_pend[15:0])
  16'b...............1: tag_refill_ptr[0]=1;   // 最低位优先
  ...
endcase
```

它不是在“空闲 way”和“pending way”之间做优先选择，而是**只**在 `!valid && pend` 集合中选择最低编号 way；集合为空时输出全 0。协议因此要求正常 refill/release 之前已经有 allocate 建立 pending 占位。该组合结果在 tag 结果被接收时锁存为 `cmp_refill_ptr` 给 cmp 级。

这个指针不携带 SID 或待安装的新 tag。若一个 set 同时存在多个 `!valid && pend`
way，refill/release 只会消费最低编号者；若一个也没有，指针就是 0，而 cmp
不会为此自动报错。故 CIU/SNB 必须保证同 set 的完成顺序与该选择规则一致。
最直接的验证条件是：每当有效 refill/release 到达 cmp 时，
`cmp_refill_ptr` 必须恰好 one-hot。

### 8.2 FIFO 状态位与 pend 推进

每组有 16 位 `status_fifo`（来自 dirty RAM 的 `[143:128]`，:1163），正常运行中作为 one-hot 的轮转 victim 选择字段。维护初始化写入的 `{16'b1,128'b0}` 中，`16'b1` 是 16 位数值 1，即只有 bit0 为 1，并不是 16 个 1。allocate 成功建立 pend 时，cmp 用 `{l2c_way_fifo[14:0],l2c_way_fifo[15]}` 把 one-hot 向高位轮转一格。

`l2c_way_fifo` 的当前选择逻辑（:1319-1331）：

```verilog
way_fifo = fifo_way_pend_vld ? way_fifo_pend_inv : status_fifo;
fifo_way_pend_vld = |(status_fifo & status_pend);   // FIFO 头正处于 pend
```

当 FIFO one-hot 选中的 way 恰处于 pend 时，用 `way_fifo_pend_inv` 按 way0 到 way15 的顺序寻找**第一个非 pending way**。这不是“沿当前 FIFO 指针继续环形搜索”的严格 FIFO 算法，而是“正常时轮转；命中 pending 冲突时改用最低编号非 pending way”的近似策略。若 16 路全 pending，`casez` 的 default 产生 `x`；正常协议必须避免该状态被用于新的 allocate。

与真 LRU 相比，这种每组 16 位选择字段只需 one-hot 轮转和优先编码，控制更简单。它可能降低某些访问模式下的命中率，但“差异有限”需要 workload 实测，不能由 RTL 结构直接下结论。

---

## 9. Tag/Status ECC 预留通路（ct_l2c_tag_ecc）

`ct_l2c_tag_ecc`（`ct_l2c_tag_ecc.v`）是 tag/dirty 读出后的 **ECC 纠错级**，把原始 `l2c_tag_dout`/`l2c_dirty_dout` 拆成各路并产生 `*_after_correct` 信号供 tag 级使用。

### 9.1 注释骨架所表达的保护意图

- 参数 `DIRTY_WIDTH=8`、`TAG_TAG_LENTH=24`（:202-206）。
- 注释中保留 `ct_l2c_ecc_encode_7bit`、`ct_l2c_ecc_encode_5bit` 和 16 路 `ct_l2c_tag_ecc_decode` 的实例骨架。
- 从模块命名、校验位规模、`after_correct` 与 `fatal_err` 接口可以推断设计意图包含单比特纠正和不可纠错误上报；但编码器/解码器实例当前被注释，不能把注释骨架当作当前 build 已启用的 SECDED 功能。

### 9.2 开源版的实现现状（重要）

在本开源 RTL 中，纠错运算**被旁路**，`*_after_correct` 直接等于原始读出：

```verilog
way0_tag_dout_after_correct   = way0_tag_dout;        // 直通，无纠错  (ct_l2c_tag_ecc.v:328)
way0_dirty_dout_after_correct = way0_dirty_dout;      // 直通          (ct_l2c_tag_ecc.v:344)
fifo_dout_after_correct       = fifo_dout;            // 直通          (ct_l2c_tag_ecc.v:362)
l2c_tag_dirty_fatal_err[7:0]  = 8'b0;                 // fatal 恒 0    (ct_l2c_tag_ecc.v:284)
l2c_tag_dirty_fatal_err[15:8] = 8'b0;                 //               (ct_l2c_tag_ecc.v:286)
```

`&Instance(...)` 行是 vperl 生成源留下的注释，不会在当前 Verilog 中实例化硬件。**结论：当前 build 的 tag/status 数据没有经过实际纠错，fatal error 也不会由该模块上报。** “ECC 预留通路”描述的是接口和原始生成意图，不应写成当前已具备可靠性保护。

### 9.3 DCA tag/dirty 旁路

ecc 模块还按 `icc_dca_way_sel` one-hot 选出 DCA 要读的那一路 tag/dirty（:367-399），锁存为 `icc_dca_tag_f`/`icc_dca_dirty_f`（:423-429），供 icc 的 DCA 调试读出。

---

## 10. 多源仲裁与写通路

tag/dirty RAM 端口被 4 类发起方共享，仲裁逻辑（`ct_l2c_tag.v:594-643`）：

- **片选**：`l2c_tag_cen = (icc_tag_cen | cmp_tag_cen | ciu_req_vld | wb_tag_cen) & !tag_stage_stall`（:594）。
- **索引选择**（组合选择顺序为 icc/wb 合并源 > cmp > ciu，:609-612）：
  ```verilog
  l2c_tag_index_pre = icc_wb_req ? icc_wb_tag_index
                    : cmp_req_vld ? cmp_tag_index
                    : ciu_l2c_addr_x[index];
  ```
- **写使能**：`cmp_icc_wb_tag_way` 选出要写的路 one-hot，扩展成每路 24 位的 `l2c_tag_wen_pre`（低有效，:623-639）。
- **写数据**：icc/wb 写 0（失效），cmp 写当前请求地址的标签（:641-643）。
- 入口冲突屏障：`tag_addr_hit`/`cmp_addr_hit`/`data_addr_hit` 用内部地址低 7 位 `addr_x[6:0]=PA[13:7]` 比较，命中时暂不接收新请求。它没有比较完整 tag，也少于 9 位 local-set index，因此是保守的局部 SRAM hazard 检查，不是数据转发，也不是精确的同地址/同 set 判定。

当前开源版的 wb ECC 写回请求被硬连为 0；ICC 又只在主流水排空后进入。因此“组合选择顺序”不等于多个长期并发请求之间存在一个具备公平性的动态仲裁器。普通 CIU 请求是否被接收由 `addr_vld/addr_ready` 握手保证，不能仅凭 mux 顺序宣称“绝不会饥饿”。

---

## 本章小结

L2 tag/status 路径把 16 路 tag 分散在四颗 4 路 SRAM 中，而把 16 路状态集中在一颗 144 位 RAM 中。一次 set 读取因此可并行得到全部路的 `valid/shared/dirty/pend/cp[3:0]`，tag 比较结果则在 SRAM 读出与 ECC 旁路边界后形成并锁存，再交给 cmp 级归约。`cp` 位为 CIU 的侦听过滤提供目录线索，但逐 PIU 的 snoop 目标选择仍由 CIU 完成；`pend` 把 victim 选择、占位、refill 和 release 串成生命周期，不能仅按“该路无效”解释。

替换通常由每组 one-hot 轮转状态选择；若当前候选路处于 pending，逻辑改选最低编号的非 pending 路。它既不是真 LRU，也不是从当前指针继续环形搜索的严格 FIFO。tag/status 访问由计数器 FSM 吸收可配置 SRAM 周期，比较发生在哪个逻辑边界可以由 RTL 确认，但最终频率收益仍需综合时序报告。ECC 的端口、状态和数据通路在结构上存在，开源版本的纠错核却没有落地，因此波形中的 ECC 旁路不能当成已实现的错误检测或纠正能力。分析一次命中或替换时，应连续观察 set 读取、16 路比较、状态资格、victim 选择、pending 建立和后续 refill/release。
