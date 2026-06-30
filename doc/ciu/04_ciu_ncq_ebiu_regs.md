# C910 CIU NCQ/EBIU/接口与寄存器 模块详细教学文档

> RTL 文件：`ct_ciu_ncq.v`（约 1872 行）、`ct_ciu_ncq_gm.v`（约 125 行）、`ct_ebiu_top.v`（约 786 行）、`ct_ebiu_read_channel.v`（约 691 行）、`ct_ebiu_write_channel.v`（约 3070 行）、`ct_ebiu_cawt_entry.v`（约 177 行）、`ct_ebiu_ncwt_entry.v`（约 240 行）、`ct_ciu_l2cif.v`（约 1212 行）、`ct_ciu_bmbif.v`（约 303 行）、`ct_ciu_apbif.v`（约 506 行）、`ct_ciu_regs.v`（约 767 行）
>
> 上层：`ct_ciu_top.v` 实例化 `x_ct_ciu_ncq`(行 3578)、`x_ct_ebiu_top`(行 3729)、`x_ct_ciu_l2cif`(行 3278)、`x_ct_ciu_bmbif`(行 2677)、`x_ct_ciu_apbif`(行 3985)、`x_ct_ciu_regs`(行 3917)、`x_ct_ciu_ebiuif`(行 3200)

---

## 目录

1. [模块概述](#1-模块概述)
2. [NCQ：非相干队列](#2-ncq非相干队列)
3. [NCQ 全局监视器 ncq_gm](#3-ncq-全局监视器-ncq_gm)
4. [EBIU：外部 AXI 主接口](#4-ebiu外部-axi-主接口)
5. [EBIU 读通道](#5-ebiu-读通道)
6. [EBIU 写通道与 NCWT/CAWT](#6-ebiu-写通道与-ncwtcawt)
7. [L2CIF：L2 Cache 接口](#7-l2cifl2-cache-接口)
8. [EBIUIF / BMBIF](#8-ebiuif--bmbif)
9. [APBIF：APB 外设桥](#9-apbifapb-外设桥)
10. [CIU 寄存器](#10-ciu-寄存器)
11. [设计取舍小结](#11-设计取舍小结)

---

## 1. 模块概述

本文覆盖 CIU 的**非相干路径**与**对外接口/配置**部分——这些模块不参与 MOESI 侦听核心，但负责把请求送达最终目的地（内存、外设、L2C）以及配置整个 CIU。

```
非相干请求(piu0-3 uncached + piu4 设备) ──► NCQ ──► EBIU(AXI) ──► 内存
                                              └──► APBIF ──► APB 外设
相干请求(SAB/CTCQ/VB) ──► L2CIF ──► L2 Cache
                       └──► EBIUIF ──► EBIU(AXI) ──► 内存
配置/控制 ──► CIU regs(smpen/sf_dis/...)
```

---

## 2. NCQ：非相干队列

### 2.1 职责

**NCQ（Non-Coherent Queue）**汇聚所有**非相干访问**：uncached 内存、设备寄存器、IO、以及 piu4 设备口的请求。这类访问**不缓存、不侦听**，绕开整个 SAB/MOESI 机制，直接转发给 EBIU 或 APB。

### 2.2 内部 FIFO 结构（`ct_ciu_ncq.v`）

NCQ 由一组浅 FIFO 构成，读写地址/数据/应答各一条：

| FIFO | 深度 | 宽度 | 用途 | file:line |
|------|------|------|------|-----------|
| RAQ（读地址） | 2 | ARWIDTH=74 | 缓冲非相干读地址 | `ct_ciu_ncq.v:735` |
| RDQ（读数据） | 2 | RWIDTH=138 | 缓冲读返回数据 | `ct_ciu_ncq.v:891` |
| WAQ（写地址） | 2 | AWWIDTH=74 | 缓冲非相干写地址 | `ct_ciu_ncq.v:1056` |
| WOQ（写序队列） | **16** | 8 | 跟踪写顺序 | `ct_ciu_ncq.v:1236,1255` |
| WDQ（写数据） | 2 | 152 | 缓冲写数据 | `ct_ciu_ncq.v:1343` |
| WBQ（写应答） | 2 | 10 | 缓冲 B 响应（bresp+bid） | `ct_ciu_ncq.v:1515` |
| DSQ（数据源队列） | 16 | — | 跟踪每个写的数据源 | `ct_ciu_ncq.v:1388` |

地址/数据 FIFO 都很浅（深 2），因为非相干访问不像一致性事务那样要长时间挂起等侦听——它们快进快出。但**写序 WOQ 深 16**：非相干写常要求强保序（Strongly-Ordered），必须排队保证写到设备的顺序与程序序一致。

### 2.3 关键端口

| 组 | 信号 | 方向 | file:line |
|----|------|------|-----------|
| PIU 读 | `piu0_ncq_ar_bus[73:0]`/`ar_req` | in | `ct_ciu_ncq.v` 端口表 |
| PIU 写 | `piu0_ncq_aw_bus[73:0]`/`aw_req`、`wcd_bus[143:0]`/`wcd_req` | in | 同上 |
| 授权 | `ncq_piu0_ar_grant`/`aw_grant`/`wcd_grant` | out | 同上 |
| 送 EBIU | `ncq_ebiu_arvalid`/`awvalid`/`wvalid` | out | `ct_ciu_ncq.v:231-235` |
| 送 APB | `ncq_apbif_arvalid`/`awvalid`/`wvalid` | out | `ct_ciu_ncq.v:50-54` |

NCQ 按地址判断目标是内存（→EBIU）还是外设（→APBIF）。

---

## 3. NCQ 全局监视器 ncq_gm

`ct_ciu_ncq_gm.v`（125 行）实现非相干区的**独占监视器（exclusive monitor）**，支持 RISC-V 的 **LR/SC（Load-Reserved / Store-Conditional）**原子操作。

```verilog
// ct_ciu_ncq_gm.v:49-51
reg        gm_exclusive;   // 独占监视有效
reg [73:0] gm_cont;        // 监视的独占地址 + lock 信息
```

工作原理：
- **LR（load-reserved）**：`gm_set_vld_x` 置位，把目标地址记入 `gm_cont`，`gm_exclusive=1`（开始监视这个地址）。
- **SC（store-conditional）**：写时比较地址（`ct_ciu_ncq_gm.v:76-81`，比较 bit[73:34]）。若监视仍有效且地址匹配且 lock 位置位 → `gm_success_x=1`（SC 成功）；若期间地址被别人写过 → 监视失效 → SC 失败。

参数（`ct_ciu_ncq_gm.v:70-74`）：`ADDRW=40`、`LOCK=10`（lock 位位置）、`GMWIDTH=74`。这是 CIU 为不可缓存/设备区原子操作提供的硬件支持（缓存区的原子性由 MOESI 保证，无需 gm）。

---

## 4. EBIU：外部 AXI 主接口

### 4.1 职责

**EBIU（External Bus Interface Unit）**是 CIU 对片外世界的**标准 AXI 主接口**。当数据不在任何 L1、也不在 L2 时，EBIU 用 AXI 协议去访问片外内存（DDR）或外设。外部信号即顶层的 `biu_pad_ar*/aw*/w*/r*/b*`（标准 AXI 五通道）。

### 4.2 子模块（`ct_ebiu_top.v:556-765`）

```verilog
ct_ebiu_read_channel  x_ct_ebiu_read_channel  (...);   // 行 557：AR/R 读通道
ct_ebiu_snoop_channel_dummy x_ct_ebiu_snoop_channel_dummy (...); // 行 651：侦听通道(桩)
ct_ebiu_write_channel x_ct_ebiu_write_channel (...);   // 行 669：AW/W/B 写通道
ct_ebiu_lowpower      x_ct_ebiu_lowpower      (...);   // 行 765：低功耗握手
```

> snoop_channel 在本配置下是 dummy 桩（`ct_ebiu_snoop_channel_dummy.v`，83 行）——OpenC910 不接受外部主设备对自己的侦听（它是 ACE 的 master 侧而非完整 interconnect 节点）。

EBIU 汇聚的请求来源：NCQ（非相干读写）、VB（相干写回）、SNB/CTCQ 经 EBIUIF（相干读取/DVM）。

---

## 5. EBIU 读通道

`ct_ebiu_read_channel.v`（691 行）实现 AXI AR/R 主逻辑：发读地址、收读数据，并把返回数据路由回正确的 SAB 项。

- **参数**：`RWIDTH=169`（`ct_ebiu_read_channel.v:490`），`DEPTH=SAB_DEPTH=24`（`ct_ebiu_read_channel.v:511`）——读返回要能指向 24 个 SAB 项之一。
- **SAB 项选择**：输出 `ebiu_ebiuif_entry_sel[23:0]`（`ct_ebiu_read_channel.v:162`），24 位 one-hot，标识这次读返回数据该写进哪个 SAB 项（相干读 miss 到内存的回填）。

读通道把多个 outstanding 读的返回数据，按 AXI rid 配对回各自的 SAB 项 / NCQ 项。

---

## 6. EBIU 写通道与 NCWT/CAWT

`ct_ebiu_write_channel.v`（3070 行，最大的 EBIU 子模块）实现 AXI AW/W/B 主逻辑，并维护两张**写跟踪表**做地址冲突检测与保序：

### 6.1 NCWT（非相干写跟踪表，16 项）

`ct_ebiu_ncwt_entry`（240 行）共 **16 个实例**（`ct_ebiu_write_channel.v` 中 grep 得 16）。每项跟踪一个非相干写（`ct_ebiu_ncwt_entry.v:69-76`）：

```verilog
reg        ncwt_vld;        // 项有效
reg [7:0]  ncwt_addr;       // cache line 地址 [13:6]
reg [7:0]  ncwt_id;         // 写 ID
reg [1:0]  ncwt_bresp;      // 写响应状态
reg        ncwt_resp_done;  // 响应已交回源
reg        ncwt_bus_done;   // 总线写完成
reg        ncwt_gm_fail;    // 独占写失败
```

完成条件（`ct_ebiu_ncwt_entry.v:121-123`）：`ncwt_pop_en = ncwt_vld & ncwt_resp_done & ncwt_bus_done`——既要总线写完、又要响应交回源才释放。它还输出读/写对该地址的依赖（`nc_wo_rd_depd_ncwt_x`/`nc_wo_wr_dped_ncwt_x`，行 213-214），实现非相干区的同地址保序。

### 6.2 CAWT（相干地址写跟踪表，32 项）

`ct_ebiu_cawt_entry`（177 行）共 **32 个实例**（grep 得 32）。每项记一个**相干写回**的地址（`ct_ebiu_cawt_entry.v:67-69`）：

```verilog
reg [7:0] cawt_addr;  // cache line 地址 [13:6]
reg [2:0] cawt_mid;   // 写源 master ID
reg       cawt_vld;
```

它做地址冲突比较（`ct_ebiu_cawt_entry.v:149-152`）：

```verilog
ca_rd_addr_hit_cawt_x = cawt_vld && (ebiuif_ebiu_araddr[13:6] == cawt_addr[7:0]);  // 读撞写回
ca_wr_addr_hit_cawt_x = cawt_vld && (vb_ebiu_awaddr[13:6]   == cawt_addr[7:0]);    // 写撞写回
snb0_snpext_addr_hit_cawt_x = cawt_vld && (snb0_yy_snpext_index[7:0] == cawt_addr[7:0]); // 侦听撞写回
```

**为什么 CAWT 比 NCWT 大（32 vs 16）？** 相干写回涉及更多并发源（2 L2C bank + 2 SNB bank + 各核），且必须与读、侦听做严格地址冲突检测以保一致性正确性，需要更多跟踪表项。

### 6.3 请求类型与独占（`ct_ebiu_write_channel.v:518-563`）

```verilog
parameter SO_ID    = 5'b11101;  // Strongly-Ordered 强保序 ID
parameter WO_EX_ID = 5'b11110;  // Write-Order Exclusive 写序独占 ID
assign ncq_aw_wo = ncq_xx_awcache[1];    // 写序
assign ncq_aw_so = !ncq_xx_awcache[1];   // 强保序
assign ncq_aw_ex = ncq_xx_awlock;        // 独占写
```

每核还有独占写失败 FSM（`ncq_so_ex_fail_coreN_cur_state[1:0]`，`ct_ebiu_write_channel.v:229-237`），配合 ncq_gm 处理 SC 失败回报。

---

## 7. L2CIF：L2 Cache 接口

`ct_ciu_l2cif.v`（1212 行）是 CIU 与共享 **L2 Cache** 之间的接口，把 SAB/CTCQ/VB 的请求翻译成对 L2C 的访问。

### 7.1 双 bank

L2C 分两个 bank（与 SNB 双 bank 对应，按地址分流），所有信号都成对带 `_bank_0`/`_bank_1` 后缀（`ct_ciu_l2cif.v:19-26`）：

```verilog
ciu_l2c_addr_bank_0 / _bank_1        // 地址
ciu_l2c_addr_vld_bank_0 / _bank_1    // 地址有效
ciu_l2c_clr_cp_bank_0 / _bank_1      // ◄ 清 cp 位（snoop filter 维护）
ciu_l2c_ctcq_req_bank_0 / _bank_1    // CTCQ 请求
ciu_l2c_dca_req_bank_0 / _bank_1     // DCA 请求
```

### 7.2 cp 位图的载体

注意 `ciu_l2c_clr_cp_bank_*` / `ciu_l2c_set_cp_bank_*`（`ct_ciu_top.v:55-56,80-81`）——这正是 `02_ciu_snb_sab.md` §10 讲的 **set_cp/clr_cp 命令的物理出口**。SAB 算出要更新 cp 位图，经 L2CIF 把 set/clr 命令送到 L2C tag。**cp 位图寄生在 L2C 的 tag SRAM 里**，L2CIF 是 SAB 操纵它的通道。

L2C 返回的响应里带 `l2c_ciu_resp_bank_*[4:0]`（HIT/ERR/PD/IS）和 cp 位图，回送给 SAB（`02_ciu_snb_sab.md` §5）。

### 7.3 请求类型（13 种）

L2CIF 透传 SAB 的 13 种 L2C 命令（`ciu_l2c_type_bank_*[12:0]`），即 `02` 文档讲的 read/allocate/clean/clean&inv/write SD-UC-UD-SC/acc_tag/invalid/unique/shared（`ct_ciu_snb_sab_entry.v:1759-1808`）。数据宽 512 位（`l2c_ciu_data_bank_*[511:0]`），即整条 cache line。

---

## 8. EBIUIF / BMBIF

### 8.1 EBIUIF（`ct_ciu_ebiuif.v`，412 行）

EBIUIF 是 **SNB/VB/CTCQ 与 EBIU 之间的连接桥**。相干读 miss 到内存、相干写回、DVM 广播都经它转给 EBIU 的读/写通道。它也把 EBIU 读回的数据按 `entry_sel` 路由回 SAB 项（配合 §5），并参与 §6/§10 的地址依赖（`vb_ebiuif_addr_depd`、`ebiuif_vb_index`）。

### 8.2 BMBIF（`ct_ciu_bmbif.v`，303 行）

**BMBIF（Barrier/Monitor Bus Interface）**仲裁来自 CTCQ、NCQ、SNB0、SNB1 的 **barrier/monitor 请求**，并把授权分发回各 PIU master（`ct_ciu_bmbif.v:18-24`）：

```verilog
bmbif_ctcq_bar_req / bmbif_ncq_bar_req / bmbif_snb0_bar_req / bmbif_snb1_bar_req  // 屏障请求
bmbif_piu0_ctcq_grant / _ncq_grant / _snb0_grant / _snb1_grant                   // 授权回 PIU
piu0_bmbif_req_bus[8:0]  // 请求总线（9 位）
```

它确保多核内存屏障（barrier）在所有相关通道间正确排序——屏障前的访存必须先全局可见，屏障后的才能发出。

> **`ct_ciu_bmbif_kid.v`** 是 BMBIF 的**跨时钟域（CDC）封装**变体（"kid" 即 CIU 里成对出现的
> 同步外壳，与 `regs_kid` 同理）：当 PIU master 与 CIU 处于不同时钟域时，barrier 请求/授权信号
> 经它做两级触发器同步后再进 BMBIF 仲裁，防止亚稳态。逻辑与 `ct_ciu_bmbif.v` 相同，只多一层同步。

---

## 9. APBIF：APB 外设桥

`ct_ciu_apbif.v`（506 行）把 NCQ 来的非相干访问桥接到 **APB 外设**。

### 9.1 4 态 FSM（`ct_ciu_apbif.v:253-256`）

```verilog
parameter IDLE  = 2'b00;   // 空闲
parameter WADDR = 2'b01;   // 写地址阶段
parameter REQ   = 2'b10;   // APB SETUP（发起）
parameter PEND  = 2'b11;   // APB ACCESS（等 pready）
```

转移（`ct_ciu_apbif.v:274-298`）：IDLE 收到读请求直接进 REQ，收到写请求先进 WADDR 等数据，再 REQ → PEND（等外设 `pready`）→ 完成回 IDLE。这正是 APB 协议的 SETUP/ACCESS 两拍握手。

### 9.2 外设片选（`ct_ciu_apbif.v:140-144`）

```verilog
psel_clint;        // CLINT：核本地中断/定时器
psel_had;          // HAD：硬件调试
psel_l2pmp[3:0];   // L2 PMP：物理内存保护（每核一个）
psel_plic;         // PLIC：平台级中断控制器
psel_rmr;          // RMR：复位管理寄存器
```

APBIF 按地址解码出目标外设，拉对应 `psel`，转发 `paddr/pwdata/pwrite/penable`，回收 `prdata/pready`。

---

## 10. CIU 寄存器

`ct_ciu_regs.v`（767 行）是 CIU 的配置/控制寄存器堆。最关键的是 **CHR2 寄存器**（`chr2_data[10:0]`，`ct_ciu_regs.v:127`），它的位直接控制一致性行为：

| 输出信号 | 含义 | 影响 | file:line |
|----------|------|------|-----------|
| `ciu_chr2_sf_dis` | **Snoop Filter 关闭** | =1 时强制广播全部核（关过滤），见 `02` §6 | `ct_ciu_regs.v:102,453` |
| `ciu_chr2_bar_dis` | Barrier 关闭 | 关闭屏障处理 | `ct_ciu_regs.v:100,452` |
| `ciu_chr2_dvm_dis` | DVM 关闭 | 关闭 DVM 同步广播，见 `03` §8 | `ct_ciu_regs.v:101,454` |
| `ciu_xx_smpen[3:0]` | **每核 SMP 使能** | 未使能的核不参与一致性，见 `02` §6 | `ct_ciu_regs.v:114,656` |
| 各 `*_icg_en` | 时钟门控使能 | 各子模块低功耗控制 | `ct_ciu_regs.v:446-450` |
| `ciu_so_ostd_dis` | SO 写 outstanding 关闭 | 强保序写不允许 outstanding | `ct_ciu_regs.v:455` |

`ciu_chr2_sf_dis` 与 `ciu_xx_smpen` 是 snoop filter 的两个软件后门：
- **smpen**：多核启动时逐核加入 SMP 域；只有 smpen=1 的核才进 cp 位图过滤、才会被侦听。这是“哪些核参与一致性”的总开关（`02` §6 第三步）。
- **sf_dis**：debug/兼容用，关掉过滤退化为广播。

CIU 还有 CCR2（L2 时延/预取配置）、CER2（ECC 错误注入）、以及每核私有 CSR（经 `ct_ciu_regs_kid.v`，`ct_ciu_regs.v:579`）。`smpen[3:2]` 在 2 核配置里钉为 0（`ct_ciu_regs.v:634,639`），呼应 piu2/piu3 是 dummy。

---

## 11. 设计取舍小结

| 决策 | 内容 | 为什么 | 出处 |
|------|------|--------|------|
| NCQ 绕开侦听 | 非相干访问不进 SAB | 不缓存就不需一致性，快进快出 | `ct_ciu_ncq.v` |
| 地址 FIFO 浅(2) | RAQ/RDQ/WAQ/WDQ 深 2 | 非相干访问不长期挂起 | `ct_ciu_ncq.v:735…` |
| WOQ 深 16 | 写序队列独大 | 强保序写须排队保程序序 | `ct_ciu_ncq.v:1236` |
| ncq_gm 独占监视 | 为非缓存区做 LR/SC | 缓存区原子靠 MOESI，设备区需专用监视器 | `ct_ciu_ncq_gm.v` |
| EBIU = AXI 主 | 标准 AXI 对外 | 通用 SoC 集成 | `ct_ebiu_top.v` |
| snoop_channel dummy | 不接受外部侦听 | OpenC910 是 master 侧 | `ct_ebiu_snoop_channel_dummy.v` |
| NCWT 16 / CAWT 32 | 写跟踪表分相干/非相干 | 相干写并发源多、须严格冲突检测 | `ct_ebiu_write_channel.v` |
| L2C/SNB 双 bank | 按地址分两路 | 奇偶 line 并行，吞吐翻倍 | `ct_ciu_l2cif.v:19-26` |
| cp 位图寄生 L2 tag | set/clr_cp 经 L2CIF | 复用 L2 tag SRAM，省独立目录 | `ct_ciu_top.v:55-56,80-81` |
| BMBIF 集中仲裁屏障 | 4 源 barrier 统一排序 | 保证多核屏障语义 | `ct_ciu_bmbif.v` |
| APBIF 4 态 FSM | IDLE/WADDR/REQ/PEND | 实现 APB 两拍握手 | `ct_ciu_apbif.v:253-256` |
| smpen/sf_dis 后门 | 软件控制一致性范围 | 多核启动 + debug 回退 | `ct_ciu_regs.v:453,656` |

---

*文档覆盖 `ct_ciu_ncq.v`、`ct_ciu_ncq_gm.v`、`ct_ebiu_top.v`、`ct_ebiu_read_channel.v`、`ct_ebiu_write_channel.v`、`ct_ebiu_cawt_entry.v`、`ct_ebiu_ncwt_entry.v`、`ct_ciu_l2cif.v`、`ct_ciu_ebiuif.v`、`ct_ciu_bmbif.v`、`ct_ciu_apbif.v`、`ct_ciu_regs.v` 的核心逻辑（合计约 9100 行）。*
