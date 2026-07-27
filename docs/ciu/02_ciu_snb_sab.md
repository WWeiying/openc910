# C910 CIU SNB/SAB 模块详细教学文档

> RTL 文件：`ct_ciu_snb.v`（约 993 行）、`ct_ciu_snb_sab.v`（约 5020 行）、`ct_ciu_snb_sab_entry.v`（约 2571 行）、`ct_ciu_snb_arb.v`（约 2379 行）、`ct_ciu_snb_dp_sel.v`（约 136 行）、`ct_ciu_snb_dp_sel_16.v`（约 121 行）、`ct_ciu_snb_dp_sel_8.v`（约 81 行）
>
> 上层：`ct_ciu_top.v` 实例化 **2 个** SNB（`x_ct_ciu_snb_0` / `x_ct_ciu_snb_1`，`ct_ciu_top.v:2745,2934`）
>
> 这是 CIU 一致性机制的核心，建议精读。

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口与层次](#2-端口与层次)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [SAB：24 项侦听缓冲（16 读 + 8 写）](#4-sab24-项侦听缓冲16-读--8-写)
5. [SAB 项的内容：地址 + cp 位图](#5-sab-项的内容地址--cp-位图)
6. [侦听过滤器：cp → cp_after_mask](#6-侦听过滤器cp--cp_after_mask)
7. [主 FSM：14 态一致性引擎](#7-主-fsm14-态一致性引擎)
8. [侦听派发与每核子 FSM](#8-侦听派发与每核子-fsm)
9. [侦听类型编码（acsnoop）](#9-侦听类型编码acsnoop)
10. [cp 位图的维护：set_cp / clr_cp](#10-cp-位图的维护set_cp--clr_cp)
11. [年龄向量仲裁：dp_sel 家族](#11-年龄向量仲裁dp_sel-家族)
12. [地址依赖与 DEPD](#12-地址依赖与-depd)
13. [完整侦听时序](#13-完整侦听时序)
14. [设计取舍小结](#14-设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

SNB（**Snoop Buffer / 侦听广播单元**）是 CIU 一致性的执行机构。它接收来自各 PIU 的相干读（AR）/写（AW）请求，为每个请求分配一个 **SAB（Snoop Address Buffer）**项，由这个 SAB 项里的状态机驱动整条一致性事务走完全程：

1. 向 **L2 Cache** 查 tag，拿到该 line 的 **cp 位图**（谁缓存了它）和 L2 状态；
2. 经 **snoop filter** 过滤出真正需要侦听的核；
3. 经 PIU 的 AC 通道向那些核发**侦听**，回收它们的 CR 响应、CD 脏数据；
4. 按 MOESI 规则更新 L2C 状态、cp 位图，必要时读/写内存（经 EBIU）；
5. 把数据/应答返回请求者，释放 SAB 项。

SNB **不存数据**（数据在 L1/L2/内存里），它存的是**地址 + 一致性状态机 + cp 位图**——本质是一个**分布式 cache 目录控制器**。

### 1.2 位置与双 bank

```
PIU0-3 (AR/AW) ──按 addr[6] 分流──► SNB0 (偶 line) / SNB1 (奇 line)
                                       │
              ┌────────────────────────┴───────────────────────┐
              │  ct_ciu_snb (单 bank)                            │
              │  ┌──────────┐  ┌─────────────────────────────┐  │
              │  │ snb_arb  │  │ snb_sab (24 项 SAB)          │  │
              │  │ 通道仲裁  │  │ ┌──────────────────────────┐│  │
              │  └──────────┘  │ │ sab_entry ×24             ││  │
              │                │ │ (主FSM + cp位图 + 子FSM)   ││  │
              │                │ └──────────────────────────┘│  │
              │                │  dp_sel 家族 (年龄向量仲裁)   │  │
              │                └─────────────────────────────┘  │
              └─────────┬──────────────┬──────────────┬─────────┘
                        ▼ l2cif        ▼ AC→PIU       ▼ ebiuif→内存
                   L2 Cache       侦听各核          外部总线
```

C910 实例化 2 个 SNB（`ct_ciu_top.v:2745,2934`），分别处理地址 bit[6]=0/1 的 cache line，使奇偶行的一致性事务**真正并行**。下文以单个 SNB 为例讲解。

---

## 2. 端口与层次

`ct_ciu_snb` 内部实例化两个子模块（`ct_ciu_snb.v:633-947`）：

```verilog
ct_ciu_snb_arb  x_ct_ciu_snb_arb (...);   // 通道仲裁（行 634）
ct_ciu_snb_sab  x_ct_ciu_snb_sab (...);   // 24 项侦听缓冲（行 892）
```

`ct_ciu_snb_sab` 内部又实例化：
- **24 个** `ct_ciu_snb_sab_entry`（`ct_ciu_snb_sab.v` 中 `grep` 得 24 个实例）——每项一个独立状态机；
- 多个 `ct_ciu_snb_dp_sel*` 选择器（见 §11）。

### 2.1 主要端口分组（`ct_ciu_snb.v` 端口表）

| 组 | 代表信号 | 方向 | 含义 | file:line |
|----|----------|------|------|-----------|
| PIU 读/写请求 | `piu0_snb_ar_req`/`ar_bus[70:0]`、`piu0_snb_aw_req` | in | 各核来的相干读/写 | `ct_ciu_snb.v:228-237` |
| PIU 侦听响应 | `piu0_snb_cr_req`/`cr_bus[9:0]` | in | 各核回来的 CR | `ct_ciu_snb.v:233-234` |
| 给 PIU 的侦听 | `snb0_piu_acbus`/`acvalid`（在顶层连 PIU） | out | 下发侦听（经 sab_entry 的 x_piux_ac_bus） | — |
| L2C 接口 | `snb0_l2c_addr_req`、`l2c_snb_cmplt`、`l2c_snb_cp[3:0]`、`l2c_snb_data[511:0]`、`l2c_snb_resp[4:0]` | in/out | 查 tag、读数据、拿 cp 与状态 | `ct_ciu_snb.v:213-225` |
| EBIU 接口 | `ebiuif_snb_acvalid`、`ebiuif_snbx_acbus[70:0]`、`ebiuif_snb_ar_grant` | in | 外部侦听(snpext)、读授权 | `ct_ciu_snb.v:203-219` |
| L2C 预取/侦听 L2 | `l2c_snb_prf_req`/`prf_bus`、`l2c_snb_snpl2_req`/`snpl2_bus` | in | L2 预取、侦听 L2 | `ct_ciu_snb.v:220-225` |

---

## 3. 参数与关键寄存器

### 3.1 SAB 深度（`cpu_cfig.h:468-470`）

```verilog
`define SAB_DEPTH  24    // 总 24 项
`define SAB_RDEPTH 16    // 16 项给读（AR）
`define SAB_WDEPTH 8     // 8  项给写（AW）
```

在 `ct_ciu_snb_sab.v:800-803` 引用：

```verilog
parameter DEPTH  = `SAB_DEPTH;   // 24
parameter RDEPTH = `SAB_RDEPTH;  // 16
parameter WDEPTH = `SAB_WDEPTH;  // 8
parameter PTR_EXTENT = {{(DEPTH-1){1'b0}},1'b1};
```

### 3.2 主 FSM 状态编码（`ct_ciu_snb_sab_entry.v:677-690`）

```verilog
parameter IDLE = 4'b0000;   // 空闲
parameter DEPD = 4'b0001;   // 等待地址依赖解除
parameter L2C  = 4'b0010;   // 查 L2C tag（拿 cp 和状态）
parameter SNOP = 4'b0011;   // 侦听各核
parameter L2CR = 4'b0100;   // 读 L2C 数据
parameter L2CW = 4'b0101;   // 写 L2C / 改状态
parameter L2CA = 4'b0110;   // L2C 分配（allocate）
parameter MEMR = 4'b0111;   // 读内存
parameter L2CT = 4'b1000;   // 读 L2C tag（二次）
parameter MEMW = 4'b1001;   // 写内存
parameter BAR  = 4'b1010;   // barrier
parameter POP  = 4'b1011;   // 完成、释放
parameter CR   = 4'b1100;   // 回 CR 响应（snpext）
parameter ECC_ERR = 4'b1101; // ECC 错误处理
```

### 3.3 SAB 项关键寄存器（`ct_ciu_snb_sab_entry.v`）

| 寄存器 | 位宽 | 含义 | file:line |
|--------|------|------|-----------|
| `main_cur_state` | [3:0] | 主 FSM 当前态 | 243 |
| `cp` | [3:0] | **核存在位图**（从 L2C tag 取） | 1940 |
| `l2_resp` | [4:0] | L2C 响应（HIT/ERR/PD/IS…） | 1939 |
| `crresp` | [4:0] | 累积的核 CR 响应 | 1881 |
| `smpen` | [3:0] | SMP 使能（从 regs） | 1957 |
| `snp0_cur_state`…`snp3_cur_state` | [1:0]×4 | 每核侦听子 FSM | 260-267 |
| `memr_cur_state` / `memw_cur_state` | [1:0] | 读/写内存子 FSM | 247,251 |
| `l2c_cur_state` | [1:0] | L2C 访问子 FSM | 241 |

---

## 4. SAB：24 项侦听缓冲（16 读 + 8 写）

24 项不是平均分配的，而是**读 16 + 写 8**的固定划分：

- **读项（entry 0~15）**：处理 AR（相干读）请求，由 `sab_cen0` 创建（`ct_ciu_snb_sab.v:3464-3465`）：
  ```verilog
  assign sab_cen0[RDEPTH-1:0] = {RDEPTH{sab_ar_create_en}} & sab_ar_create_sel[RDEPTH-1:0];
  ```
- **写项（entry 16~23）**：处理 AW（相干写）请求，由 `sab_cen1` 创建（`ct_ciu_snb_sab.v:3471-3472`）：
  ```verilog
  assign sab_cen1[WDEPTH-1:0] = {WDEPTH{sab_aw_create_en}} & sab_aw_create_sel[WDEPTH-1:0];
  ```

**为什么读写分开？** 读和写的资源压力、完成路径不同（读要返数据、写要写回应答），分区可避免写阻塞读、保证两类事务各有保底名额，简化依赖跟踪（读对写的依赖只需检查写区那 8 项，见 §12）。

---

## 5. SAB 项的内容：地址 + cp 位图

每个 SAB 项记录一条 in-flight 一致性事务的全部状态。最关键的两样：

1. **地址**：请求的物理地址（`req_addr[ADDRW-1:0]`），用于 L2C 查 tag、侦听各核、地址依赖比较。
2. **cp 位图**：`cp[3:0]`，从 L2C tag 读回（`ct_ciu_snb_sab_entry.v:1947-1951`）：
   ```verilog
   else if (l2c_resp_wen) begin
     l2_resp[4:0] <= l2c_resp[4:0];   // L2C 状态：HIT/ERR/PD(脏)/IS(共享)
     cp[3:0]      <= l2c_cp[3:0];     // ◄ 谁缓存了这一行
   end
   ```

L2C 响应字段编码（`ct_ciu_snb_sab_entry.v:1925-1969`）：

```verilog
parameter HIT = 4;  // l2_hit = l2_resp[4]
parameter ERR = 1;  // l2_err = l2_resp[1]
parameter PD  = 2;  // l2_pd  = l2_resp[2]（脏）
parameter IS  = 3;  // l2_sh  = l2_resp[3]（共享）
```

核 CR 响应同样累积成位图（`ct_ciu_snb_sab_entry.v:1884-1893`）：

```verilog
else if (|piu_crvld[3:0])
  crresp[4:0] <= crresp[4:0] | piu_crresp[4:0];   // 多核响应按位或累积
...
assign l1_dt = crresp[DT];  // 有数据传输
assign l1_err= crresp[ERR];
assign l1_pd = crresp[PD];  // 核持有脏数据
assign l1_sh = crresp[IS];  // 核持有共享副本
```

---

## 6. 侦听过滤器：cp → cp_after_mask

这是 snoop filter 的算法核心，三步组合逻辑（`ct_ciu_snb_sab_entry.v:1962-1964`）：

```verilog
// ① 过滤器开关：CSR 关闭过滤且 L2 命中 → 强制广播全 1
assign cp_after_sf[3:0]   = (ciu_chr2_sf_dis & l2_hit) ? 4'b1111 : cp[3:0];
// ② 去掉请求者自己（inst 取指请求不 mask）
assign cp_mask[3:0]       = inst ? 4'b0 : piu_sel[3:0];
// ③ 最终位图 = 持有者 & 去自己 & 只留 SMP 使能的核
assign cp_after_mask[3:0] = cp_after_sf[3:0] & (~cp_mask[3:0]) & smpen[3:0];
```

| 信号 | 来源 | 作用 |
|------|------|------|
| `cp[3:0]` | L2C tag | 哪些核缓存了这一行 |
| `ciu_chr2_sf_dis` | `ct_ciu_regs.v:453` | =1 关闭过滤，强制广播（debug/兼容） |
| `piu_sel[3:0]` | 发起请求的核 one-hot | 抠掉自己——不侦听自己 |
| `smpen[3:0]` | `ct_ciu_regs.v:656` | 未进 SMP 域的核不参与一致性 |
| `cp_after_mask` | 上面三者 AND | **最终要侦听哪些核的位图** |

**收益举例**：核 0 读一行，`cp=4'b0110`（核 1、核 2 缓存），`piu_sel=4'b0001`（核 0 发起），`smpen=4'b0011`（只核 0/1 在 SMP 域）：
```
cp_after_sf  = 0110 (过滤开)
cp_mask      = 0001 (核0自己)
cp_after_mask= 0110 & ~0001 & 0011 = 0010   ← 只侦听核 1
```
核 2 虽然 cp 显示缓存了，但 smpen[2]=0（不在 SMP 域）→ 不侦听。核 0 自己被抠掉。最终只发 1 个侦听，而非广播 4 个。

---

## 7. 主 FSM：14 态一致性引擎

每个 SAB 项的 `main_cur_state`（`ct_ciu_snb_sab_entry.v:748-867`）是整个一致性协议的灵魂。下面给出关键转移（节选自 RTL `case` 语句）。

### 7.1 IDLE → L2C / DEPD / BAR（行 749-760）

```verilog
IDLE: begin
  if (req_vld && !bar_raw) begin
    if (depd_vld_raw | wt_raw)  main_next_state = DEPD;  // 有地址依赖，先等
    else                        main_next_state = L2C;   // 直接查 L2C
  end
  else if (req_vld && bar_raw)  main_next_state = BAR;    // barrier 事务
  else                          main_next_state = IDLE;
end
```

### 7.2 L2C → SNOP / L2CW / MEMR …（行 769-800）

查完 L2C tag，拿到 cp 和状态后，最关键的分支：

```verilog
L2C: begin
  if (l2c_cmplt & !l2_err) begin
    if (cp_vld)                          main_next_state = SNOP;  // ◄ 有核要侦听 → 去侦听
    else if (evict | csl1)               main_next_state = POP;   // 逐出/清 L1，无需侦听 → 完成
    else if (!depd_vld & (cml2 | snpl2)) main_next_state = L2CW;  // 改 L2C 状态
    ...
    else if (l2_hit) begin
      if (uni_op & l2_sh & !snpext)      main_next_state = MEMR;  // 独占但 L2 共享 → 读内存
      else if (ws)                       main_next_state = L2CR;  // 写需先读 L2C 数据
      else                               main_next_state = L2CW;  // 普通 → 写 L2C
    end
    else if (snpext)                     main_next_state = CR;    // 外部侦听 → 回 CR
    else if (rd_alct)                    main_next_state = L2CA;  // 读未命中 → L2C 分配
    else if (wns)                        main_next_state = MEMW;  // 非缓存写 → 写内存
    else main_next_state = (ace_cfig|ro|rns) ? MEMR : (cu ? L2CW : L2CR);
  end
  else if (l2c_cmplt & l2_err)           main_next_state = ECC_ERR;
end
```

`cp_vld` 就是 §6 算出的位图非空（`ct_ciu_snb_sab_entry.v:918`），它是“走不走 SNOP”的开关。

### 7.3 SNOP → L2CR / L2CW / MEMR / POP（行 801-816）

```verilog
SNOP: begin
  if (snp_cmplt & !depd_vld & !l1_err_t) begin       // 全部侦听完成、无错
    if (reply | ws & !l2_sh)             main_next_state = L2CR;  // 需读 L2C
    else if (csl1 & !l1_pd)              main_next_state = POP;   // 清 L1 且不脏 → 完成
    else if (uni_op & l2_sh & !snpext)   main_next_state = MEMR;  // 独占 → 读内存
    else                                 main_next_state = L2CW;  // 改 L2C 状态
  end
  else if (snp_cmplt & !depd_vld & l1_err_t) main_next_state = ECC_ERR;
  else main_next_state = SNOP;   // 还没侦听完，留在 SNOP
end
```

`snp_cmplt` 是“四核侦听全部完成”（§8）。被侦听核回的脏数据（l1_pd）此时已收回。

### 7.4 其余状态

- **L2CR**（读 L2C 数据，行 817-824）→ L2CW 或 MEMW。
- **L2CW**（写 L2C / 改状态，行 855-867）：按结果决定是否还要写回内存（MEMW）或直接 POP。
- **L2CA**（分配，行 825-832）→ MEMR。
- **MEMR**（读内存，行 833-846）：等内存返回 + snpl2 完成后回 L2CR/L2CW/L2CT/POP。
- **L2CT**（二次读 tag，行 847-854）→ L2CA/L2CW。
- **POP**：把数据/应答交还请求者，项释放。
- **CR**：外部侦听（snpext）的响应路径。
- **ECC_ERR**：错误兜底。

整个 FSM 完整覆盖了 MOESI 的所有读/写/独占/共享/清/作废/逐出场景。L2C 命令类型（13 种 `req_type`，`ct_ciu_snb_sab_entry.v:1759-1808`）就是这些状态向 L2C 发的具体操作。

---

## 8. 侦听派发与每核子 FSM

进入 SNOP 后，过滤位图 `cp_after_mask` 驱动 4 个**独立的每核侦听子 FSM**（`ct_ciu_snb_sab_entry.v:1389-1403`）：

```verilog
assign cp_vld       = |cp_after_mask[3:0] & !(rns | wns | evict | l2_prf);  // §6 排除非侦听类
assign snp_req_vld  = (main_cur_state == L2C) & l2c_cmplt & !l2_err & cp_vld;
assign snp_req_en[3:0] = {4{snp_req_vld}} & cp_after_mask[3:0];   // 每位=要不要侦听该核
assign snp0_req_vld = snp_req_en[0];   // 核0 子 FSM
assign snp1_req_vld = snp_req_en[1];   // 核1
assign snp2_req_vld = snp_req_en[2];   // 核2
assign snp3_req_vld = snp_req_en[3];   // 核3
assign snp_cmplt = snp0_cmplt & snp1_cmplt & snp2_cmplt & snp3_cmplt;  // ◄ 全部完成
```

每个子 FSM（2 位状态，如 `snp0_cur_state`）的请求态产生 AC 请求送 PIU（`ct_ciu_snb_sab_entry.v:1180`）：

```verilog
assign sab_piu0_ac_req_x = (snp0_cur_state == SNP0_REQ);
```

**关键点**：`cp_after_mask` 里为 0 的核，其 `snp_req_en` 位为 0，对应子 FSM 不进 REQ 态、`snpX_cmplt` 立即为 1。所以 `snp_cmplt` 只等真正被侦听的那几个核——**这就是过滤的物理体现：不被侦听的核不拖慢完成**。

下发给 PIU 的 AC 总线在 §5 的 `x_piux_ac_bus` 组装（`ct_ciu_snb_sab_entry.v:1411-1416`）：

```verilog
assign x_piux_ac_bus[AC_WIDTH-1:0] = {req_addr[ADDRW-1:0], 4'b0001, snb1,
                                      x_sid[4:0], inst, acsnoop[3:0]};
```

---

## 9. 侦听类型编码（acsnoop）

下发给核的侦听类型 `acsnoop[3:0]` 由请求性质决定（`ct_ciu_snb_sab_entry.v:1406-1409`）：

```verilog
assign acsnoop[3:0] = ... ? 4'b1001        // CI  : Clean Invalid（让对方清脏并作废）
                    : ((mu | wlu) ? 4'b1101 // MI  : Make Invalid（让对方直接作废）
                                  : (rs ? 4'b1000   // CS : Clean Shared（让对方降级到 Shared）
                                        : sab_cont[SNOOP_3:SNOOP_0]));
```

| 编码 | 名称 | 语义 | 触发场景 |
|------|------|------|----------|
| `1000` | CS (Clean Shared) | 对方保留但降级为 Shared，提供脏数据则写回 | 读共享（请求者要读，对方可继续共享） |
| `1001` | CI (Clean Invalid) | 对方提供脏数据并作废自己 | 需要拿走脏数据并独占 |
| `1101` | MI (Make Invalid) | 对方直接作废（不要数据） | 独占写、make-unique |

侦听类型的选择正对应 MOESI 的状态迁移：读共享让对方 M→O 或 S 保留（配合 CTC）；独占写让对方全部 →I。

---

## 10. cp 位图的维护：set_cp / clr_cp

侦听过滤要正确，cp 位图必须随每次事务更新。SAB 项在不同状态产生 set/clr 命令给 L2C（`ct_ciu_snb_sab_entry.v:1812-1820`）：

```verilog
// 清位（L2C 态，遇独占/清/作废/逐出）
assign clr_cp_vld  = (main_cur_state == L2C) & (ru | cu | ws | wb | ci | mi | evict);
assign clr_cp[3:0] = (wb | evict) ? piu_sel[3:0]    // 逐出/写回：清自己那位
                                  : ~piu_sel[3:0];   // 独占类：清别人那些位
assign clr_cp_sel[3:0] = {4{clr_cp_vld}} & clr_cp[3:0];

// 置位（L2CW 态，读分配成功）
assign set_cp_vld  = (main_cur_state == L2CW) & rd_alct & !l2_prf;
assign set_cp[3:0] = piu_sel[3:0];   // 把请求者那位置 1（它现在也缓存了）
assign set_cp_sel[3:0] = {4{set_cp_vld}} & set_cp[3:0];
```

- **读分配成功** → `set_cp` 把请求者标进位图（“以后侦听这一行要带上它”）。
- **逐出/写回**（`wb|evict`）→ `clr_cp = piu_sel`，清掉自己那位（呼应 `00_ciu_overview.md` 第 9 节：干净行 Evict 也要清位，否则过滤退化）。
- **独占/作废类**（ru/cu/ci/mi…）→ `clr_cp = ~piu_sel`，清掉**其它**核那些位（它们都被作废了，只剩请求者）。

---

## 11. 年龄向量仲裁：dp_sel 家族

SAB 有 24 项，每个下游消费者（L2C、各 PIU 的 AC、EBIU 读/写、读应答、写应答）每拍只能服务一项。用哪一项？答案是**最老优先（oldest-first）**，靠 `dp_sel` 家族的**年龄向量（age vector）**实现。

### 11.1 算法（`ct_ciu_snb_dp_sel.v:107-130`）

```verilog
parameter DEPTH = `SAB_DEPTH;  // 24
assign sel[0]  = req_vld[0]  && !(|(req_vld[23:0] & entry0_age_vect[23:0]));
assign sel[1]  = req_vld[1]  && !(|(req_vld[23:0] & entry1_age_vect[23:0]));
...
assign sel[23] = req_vld[23] && !(|(req_vld[23:0] & entry23_age_vect[23:0]));
```

**怎么理解**：`entryN_age_vect[k]=1` 表示“项 k 比项 N 老”。`sel[N]=1` 当且仅当项 N 有请求（`req_vld[N]`）且**没有任何比它老的项也在请求**（`req_vld & age_vect` 全 0）。这样每拍恰好选出当前请求集合里最老的那一项——天然公平、防饿死、保证一致性事务的服务顺序。

### 11.2 三种宽度变体

| 模块 | DEPTH | 用途 | file:line |
|------|-------|------|-----------|
| `ct_ciu_snb_dp_sel` | 24 | 全 24 项参与的消费者（PIU AC、L2C、EBIU 读/写） | `ct_ciu_snb_dp_sel.v:105` |
| `ct_ciu_snb_dp_sel_16` | 16 | 只在 16 个读项里选（读应答 rresp） | `ct_ciu_snb_dp_sel_16.v:98` |
| `ct_ciu_snb_dp_sel_8` | 8 | 只在 8 个写项里选（写应答 bresp），用 age_vect[23:16] | `ct_ciu_snb_dp_sel_8.v:66-75` |

实例化分布（`ct_ciu_snb_sab.v`）：piu0-3 AC 各一个（行 3788/3892/3997/4102）、l2c（行 4210）、ebiu_wt（行 4434）、ebiu_rd（行 4655）用 24 宽；rresp 用 16 宽（行 4803），bresp 用 8 宽（行 4908）。读应答只可能来自读项、写应答只可能来自写项，故用窄选择器省逻辑。

---

## 12. 地址依赖与 DEPD

同一条 cache line 上的多个 in-flight 事务必须串行化（否则一致性会乱）。SAB 在创建新项时检查**地址依赖**：

- 读项对写项的依赖（`ct_ciu_snb_sab.v:3517-3519`）：
  ```verilog
  assign sab_ar_depd_aw[DEPTH-1:RDEPTH] =
       {WDEPTH{(ar_crt_entry_index[6:0] == aw_crt_entry_index[6:0]) & !aw_bar}} & sab_cen1[WDEPTH-1:0];
  assign sab_ar_depd_aw[RDEPTH-1:0] = {RDEPTH{1'b0}};   // 读项不依赖读项
  ```
  新读项若与某个写项地址相同（index[6:0] 匹配），就对它建立依赖。

有依赖的项进入 **DEPD** 状态等待（主 FSM IDLE→DEPD，`ct_ciu_snb_sab_entry.v:751-752`），被依赖项 pop 后清依赖、再进 L2C（`ct_ciu_snb_sab_entry.v:761-768`）：

```verilog
DEPD: begin
  if (!depd_vld & (!wt_val | evict | l1_wdata_vld)) main_next_state = L2C;
  else if (!depd_vld & l1_wdata_err)                main_next_state = ECC_ERR;
  else                                              main_next_state = DEPD;
end
```

`depd_val[DEPTH-1:0]` 是 24 位依赖向量（`ct_ciu_snb_sab_entry.v:1849-1861`），记录本项在等哪些项；全清后 `depd_vld=0`，放行。

---

## 13. 完整侦听时序

以“**核 0 ReadUnique（独占读，准备写）一条被核 1 以 Modified 持有的 line**”为例，串起单个 SAB 项主 FSM 的全程：

```
t0  AR(ReadUnique, addr) 经 PIU0 → 按 addr[6] 选 SNB0
       snb_arb 仲裁 → SAB 分配读项 entry5
t1  entry5 主FSM: IDLE → L2C   (无地址依赖，ct_ciu_snb_sab_entry.v:754)
t2  L2C: 向 L2C 发 acc_tag，回 cp=0010(核1持有)、l2_hit、l2_sh
       cp_after_mask = 0010 & ~0001 & smpen = 0010   (§6)
       cp_vld=1 → L2C → SNOP    (行 771-772)
t3  SNOP: snp_req_en=0010 → 只触发 snp1 子 FSM
       sab_piu1_ac_req → PIU1 → AC(acsnoop=CI 1001, 因独占需作废) → 核1
       (acsnoop 选 CI/MI，ct_ciu_snb_sab_entry.v:1406-1407)
t4  核1 命中且脏(M)：CR 回 {DT,PD} → crresp|=…(行1884)
       CD 回送脏数据 → 经 PIU pkb 打包 → 写 L2C
       核1 作废自己副本(I)
t5  snp_cmplt=1 (snp1 done, snp0/2/3 本就 done) → SNOP 退出
       独占 → main_next_state = L2CW (改 L2C 状态)  (行 807-810)
t6  L2CW: 写 L2C，req_uni(set unique)；set_cp 把核0 那位置1、clr_cp 清核1 位
       → POP   (行 855-864)
t7  POP: 数据/授权经 PIU0 R 通道返回核0；entry5 释放
```

期间若核 0 紧接着又对同一行发请求，新项会在 t1 因地址依赖进 DEPD，等 entry5 在 t7 pop 后才放行（§12）——保证同地址事务严格串行。

两个 SNB bank（addr[6]=0/1）对不同 cache line 的上述流程**并行**进行，互不干扰。

---

## 14. 设计取舍小结

| 决策 | 内容 | 为什么 | 出处 |
|------|------|--------|------|
| 双 SNB bank | 按 addr[6] 分偶/奇 line | 奇偶行一致性事务并行，翻倍吞吐 | `ct_ciu_top.v:2745,2934` |
| SAB 24 项=16 读+8 写 | 读写分区固定名额 | 防写阻塞读，简化依赖跟踪 | `cpu_cfig.h:468-470` |
| cp 位图存 L2C tag | 一致性目录寄生在 L2 tag | 复用 L2 tag SRAM，省独立目录 | `ct_ciu_snb_sab_entry.v:1950` |
| 三步过滤 | cp→sf→mask→smpen | 精确侦听，省功耗/带宽/延迟 | `ct_ciu_snb_sab_entry.v:1962-1964` |
| 每核独立子 FSM | snp0~snp3 并行侦听 | 不被侦听核立即 done，不拖慢完成 | `ct_ciu_snb_sab_entry.v:1389-1403` |
| 14 态主 FSM | 覆盖 MOESI 全部场景 | 一个状态机管完整事务生命周期 | `ct_ciu_snb_sab_entry.v:677-867` |
| 年龄向量仲裁 | oldest-first 选择器 | 公平、防饿死、保证服务顺序 | `ct_ciu_snb_dp_sel.v:107-130` |
| 窄选择器变体 | rresp 16 宽 / bresp 8 宽 | 读应答只来自读项，省仲裁逻辑 | `ct_ciu_snb_dp_sel_16/8.v` |
| DEPD 依赖串行 | 同地址事务排队 | 保证一致性正确，防乱序 | `ct_ciu_snb_sab.v:3517` |
| sf_dis 后门 | CSR 关过滤强制广播 | debug/兼容回退 | `ct_ciu_regs.v:453` |

---

*文档覆盖 `ct_ciu_snb.v`、`ct_ciu_snb_sab.v`、`ct_ciu_snb_sab_entry.v`、`ct_ciu_snb_arb.v`、`ct_ciu_snb_dp_sel*.v` 的全部核心逻辑（合计约 11000 行）。*
