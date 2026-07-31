# C910 MMU regs + sysmap（寄存器与硬连线 PMA）模块详细教学文档

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/mmu/rtl/ct_mmu_regs.v`（724 行）、
> `ct_mmu_sysmap.v`（210 行）、`ct_mmu_sysmap_hit.v`（47 行）、
> `sysmap.h`（51 行宏定义）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [satp 寄存器](#4-satp-寄存器)
5. [TLB 维护寄存器 MIR/MEL/MEH/MCIR](#5-tlb-维护寄存器-mirmelmehmcir)
6. [XMAE 14 位属性（SO/CA/BUF/SEC/SH）](#6-xmae-14-位属性socabufsecsh)
7. [sysmap：8 区硬连线 PMA](#7-sysmap8-区硬连线-pma)
8. [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 职责

- **regs（`ct_mmu_regs.v`）**：存放 MMU 的所有软件可见寄存器 —— 标准的 **satp**（控制翻译开关、ASID、根页表 PPN），以及 T-Head 扩展的 **MIR/MEL/MEH/MCIR** 四个 TLB 维护寄存器。它解码 CP0 写、生成各维护操作的触发信号给 tlboper，并把 satp 内容分发给 PTW/JTLB。
- **sysmap（`ct_mmu_sysmap.v` + `_hit.v` + `sysmap.h`）**：一张编译期
  固化的 8 区物理内存属性（PMA）表。MMU-off 路径直接用它；`maee=0`时 PTW
  用它形成 TLB PMA 并检查大页是否跨属性区；PFU 也在相应路径查询它。
  sysmap 给出属性，不替代 PMP 的物理访问许可。

### 1.2 位置

regs 接 CP0（`cp0_mmu_*`）、接 tlboper（双向）、接 PTW/JTLB（输出 satp.ppn/asid）。sysmap 是纯组合查表，输入物理页号、输出 5 位属性 flag 和 8 位命中向量，被 PTW 和 duTLB_read 等调用。

---

## 2. 端口说明

### 2.1 regs ↔ CP0

| 信号 | 方向 | 含义 |
|------|------|------|
| `cp0_mmu_reg_num[1:0]` / `cp0_mmu_wreg` / `cp0_mmu_wdata` | in | 写哪个 MMU 寄存器 / 写数据 |
| `cp0_mmu_satp_sel` | in | 写 satp |
| `cp0_mmu_cskyee` | in | T-Head 扩展使能（维护寄存器解码门控） |
| `mmu_cp0_data` / `mmu_cp0_satp_data` | out | 读回数据 |
| `mmu_xx_mmu_en` / `mmu_lsu_mmu_en` | out | MMU 是否使能 |

### 2.2 regs ↔ tlboper / JTLB / PTW

| 信号 | 方向 | 含义 |
|------|------|------|
| `regs_tlboper_invall/invasid/tlbp/tlbr/tlbwi/tlbwr` | out | 触发各维护操作 |
| `regs_tlboper_cur_vpn/pgs/asid/inv_asid/mir` | out | 维护操作用的参数 |
| `regs_ptw_satp_ppn` / `regs_ptw_cur_asid` | out | 给 PTW |
| `regs_jtlb_cur_asid` | out | 直接给 JTLB 作当前地址空间 ASID 比较 |
| `regs_jtlb_cur_ppn/flg/g` | out | 给 tlboper 组装 TLBWI/TLBWR 写入内容，再经 arb 写 JTLB |
| `regs_utlb_clr` | out | satp 写 → 清 uTLB |
| `jtlb_tlbr_*` / `jtlb_regs_hit*` | in | TLBR/TLBP 结果回写 |

### 2.3 sysmap

| 信号 | 方向 | 含义 |
|------|------|------|
| `mmu_sysmap_pa_y[27:0]` | in | 物理页号 |
| `sysmap_mmu_flg_y[4:0]` | out | 5 位 PMA 属性 |
| `sysmap_mmu_hit_y[7:0]` | out | 命中哪个区（one-hot） |

---

## 3. 参数与关键寄存器

regs 宽度参数（`ct_mmu_regs.v:229-233`）：`VPN_WIDTH=27`、`PPN_WIDTH=28`、`FLG_WIDTH=14`、`PGS_WIDTH=3`、`ASID_WIDTH=16`。

四个维护寄存器编号（`:272-275`）：`MIR_NUM=0`、`MEL_NUM=1`、`MEH_NUM=2`、`MCIR_NUM=3`。

sysmap 参数（`ct_mmu_sysmap.v:69-70`）：`ADDR_WIDTH = PA_WIDTH-12`、`FLG_WIDTH=5`。

---

## 4. satp 寄存器

布局（`ct_mmu_regs.v:624-653`）：

```
|63  60|59        44|43        28|27                 0|
| Mode |    ASID    |  Reserved  |        PPN         |
```

- **Mode**（`:630-636`）：写 `cp0_mmu_wdata[63]` 到 `satp_mode[3]`，仅当 `wdata[62:60]==0`（即 mode 只能是 0 或 8）。**`mode==4'b1000` 表示开启 Sv39**（`:700` `regs_mmu_en = satp_mode==4'b1000`）。
- **ASID**（16 位，`:642-648`）、**PPN**（28 位）。

这里有一个容易被“只支持 mode 0/8”掩盖的部分写语义：每次
`satp_write_en`都会更新 ASID 和 PPN；只有 mode 字段在
`wdata[62:60]==0`时更新。若软件写入其他 mode 编码，当前 mode 保持旧值，
ASID/PPN 仍取新数据。同时 `regs_utlb_clr = satp_write_en`，所以无论 mode
是否被接受，这次 satp 写都会在时钟沿清 uTLB。

MMU 使能区分两类（`:704-707`）：

```verilog
mmu_lsu_mmu_en = (satp_mode==8) && (priv_mode != M);   // 数据侧（考虑 MPRV）
mmu_xx_mmu_en  = (satp_mode==8) && (cur_priv  != M);   // 取指侧
```

取指侧 `mmu_xx_mmu_en`按当前 `cp0_yy_priv_mode`判断；数据侧先由
`cp0_mmu_mprv ? cp0_mmu_mpp : cp0_yy_priv_mode`形成有效特权级。因此
M-mode 在 MPRV 生效且 MPP 非 M 时，数据访问可以启用地址翻译，而取指不会
因 MPRV 改变。不能简单概括成“M 态一律不翻译”。

**关键联动**：satp 写请求是组合清除源；iuTLB/duTLB 各表项在门控时钟
上升沿把 valid 清零。JTLB 不由该信号遍历清除，后续靠 ASID/G 匹配隔离。

---

## 5. TLB 维护寄存器 MIR/MEL/MEH/MCIR

这是 T-Head 对 RISC-V 的扩展，提供软件直接 probe/read/write/invalidate JTLB 的能力（`cp0_mmu_cskyee` 门控）。

### 5.1 MEH（Entry High，`:452-487`）

```
|63    46|45    19|18  16|15    0|
|Reserved|  VPN   | PGS  | ASID  |
```

存待操作项的 VPN/页大小/ASID。异常发生时（`rtu_mmu_expt_vld`）记录 bad VPN（`:472-477`），供软件读取出错地址。

### 5.2 MEL（Entry Low，`:343-446`）

存待操作项的 PPN + 全部属性位：

```
|63 |62 |61 |60 |59 |…|37  32|31  10|9 8| 7 6 5 4 3 2 1 0 |
| So| C | B | Sh|Sec|…| PPN  | PPN  |RSW|D A G U X W R V  |
```

即高 5 位是扩展 PMA（So/C/B/Sh/Sec），低位是标准 PTE 权限/状态位。TLBR 把 JTLB 读出项写进 MEL（`:423-440`），TLBWI/WR 把 MEL 写进 JTLB。

### 5.3 MIR（Index，`:290-340`）

存 probe/写操作的 index，以及 TLBP 结果：`P`（match flag，`:319`）、`tlbp_tfatal`（多命中，`:320`）、`Index`（命中位置，`:334-337`）。

### 5.4 MCIR（Control & Invalidate，`:490-619`）

```
|31  |30  |29   |28   |27       |26    |25  16| 15 0 |
|tlbp|tlbr|tlbwi|tlbwr|inv asid |invall|resv. | ASID |
```

写 MCIR 的对应位即触发相应维护操作（`:504-520` 解码），各操作有独立的 set/clear 触发寄存器（`:522-590`），完成时由 `tlboper_regs_cmplt` 清零。`mcir_no_op`（`:609-619`）处理写全 0 的空操作。这些触发位输出给 tlboper（`:687-692`）。

---

## 6. XMAE 14 位属性（SO/CA/BUF/SEC/SH）

整个 MMU 的 TLB data flag 是 **14 位**，由 5 位扩展 PMA +
`RSW[1:0],D,A,U,X,W,R,V`九位组成。PTE 的 G 位不在这 14 位中，而在 JTLB
tag 单独保存；MEL 作为软件可见格式仍包含 G。

### 6.1 14 位 flag 的构成

从 PTW 组装可见（`ct_mmu_ptw.v:718`）：

```verilog
ptw_ref_flg[13:0] = {ptw_ref_pma[4:0], lsu_data_flop[9:6], lsu_data_flop[4:0]};
//                    └─ 5 位扩展 PMA ┘ └─ RSW,D,A ┘ └─ U,X,W,R,V ┘
```

| bit | 含义 | bit | 含义 |
|-----|------|-----|------|
| 13 | **SO** Strong-order（强序） | 6 | D Dirty |
| 12 | **CA** Cacheable（可缓存） | 5 | A Accessed |
| 11 | **BUF** Bufferable（可缓冲） | 4 | U User |
| 10 | **SH** Shareable（可共享） | 3 | X Execute |
| 9  | **SEC** Security（安全） | 2 | W Write |
| 8-7 | RSW（软件保留） | 1 | R Read |
|     |      | 0 | V Valid |

高 5 位（SO/CA/BUF/SH/SEC）即 **XMAE（扩展内存属性）**，对应 MEL 的 `So/C/B/Sh/Sec`（`ct_mmu_regs.v:443-446` 组装 MEL）。

### 6.2 属性来源（XMAE 使能 maee）

- **`cp0_mmu_maee==1`**：PTW 用叶 PTE 高位 `[63:59]`作为 XMAE。
- **`maee==0`**：PTW 用 sysmap 属性，并对大页覆盖区做边界一致性检查。

这不是运行时检测“PTE 属性是否缺失”后的 fallback，而是由 `maee`明确二选一。

### 6.3 属性如何用

duTLB_read 把 14 位 flag 解给 LSU（`ct_mmu_dutlb_read.v:456-461`）：

```verilog
mmu_lsu_so_x  = flg[13];                  // 强序
mmu_lsu_ca_x  = flg[12] && !flg[13];      // SO 时强制不可缓存
mmu_lsu_buf_x = flg[11] || !flg[13];      // 非 SO 必可缓冲
mmu_lsu_sh_x  = flg[10] && !smp_disable;  // 共享
mmu_lsu_sec_x = flg[9];                   // 安全
```

注意 SO 与 CA 的互斥逻辑：强序内存（设备）必然不可缓存。

---

## 7. sysmap：8 区硬连线 PMA

### 7.1 思想：MMU 关时也得有内存属性

sysmap 是**编译期固化的物理页号→属性组合逻辑**。主要使用点不同：

- iuTLB/duTLB 在翻译关闭时，以当前物理页号查询 PMA；
- PTW 在 `maee=0`时给最终 TLB 项选择 PMA，并用 region hit 比较大页首尾；
- PFU 在 MMU-off 或不采用页表 XMAE 的路径查询 PMA。

sysmap 不检查 R/W/X 权限，也不决定 page fault；PMP 和页表权限分别承担
物理保护与虚拟页许可。

### 7.2 边界与属性定义（sysmap.h）

`sysmap.h`定义 8 个递增上界和对应属性，单位是 4KB 物理页号。当前源码的
`FPGA`与`else`分支数值相同，但它们仍是编译配置接口，移植版本可能修改。
当前值为：

```
ADDR0=0x01000 FLG0=01111   ADDR1=0x02000 FLG1=10000
ADDR2=0xd0000 FLG2=10000   ADDR3=0xeffff FLG3=01101
ADDR4=0xfffff FLG4=01111   ADDR5=0x4000000 FLG5=01111
ADDR6=0x5000000 FLG6=10000 ADDR7=0xfffffff FLG7=01111
```

5 位属性对应 `{SO, CA, BUF, SH, SEC}`。例如 `01111`表示非 SO、cacheable、
bufferable、shareable、secure；`10000`表示 SO 且其余四位为 0。这里的
`SEC`是实现定义的安全属性位，不能仅凭名字推导完整安全域协议。

### 7.3 命中逻辑

sysmap 是 8 个"区间比较器"的级联（`ct_mmu_sysmap.v`）：

- 每段先计算 `addr < upper_bound`；
- `addr_ge_bottom_x`由“前一上界比较已经不成立”传递，首段下界条件固定为
  真，所以区间是 `[previous_bound, current_bound)`；
- 8 个命中拼成 one-hot `sysmap_hit[7:0]`（`:164-167`），用 casez 选出对应区的 5 位属性（`:170-183`）。默认属性 `5'b10011`（`:182`）。

最后一个上界也是严格 `<`。当前最大宏为 `28'hfffffff`，地址恰好等于该值
不会命中任何区，而走 default `5'b10011`；所以不能把第 7 区口语化成“覆盖
到并包含最大值”。`sysmap_mmu_hit_y`在这种 default 情况下仍为全 0。

PTW 大页跨区检查比较的是首尾地址的 8-bit region hit 向量；不同即收窄回填
粒度。它比较区域身份，不直接逐字节比较属性值，所以即使两个不同 region
恰好配置相同 flag，也仍会被视为跨区。

---

## 本章小结

MMU 寄存器把架构 satp/mstatus 语义、T-Head TLB 操作扩展和物理内存属性选择连接起来。任意被 CP0 译码为 satp 写的操作都会触发 uTLB 清空；ASID 和 PPN 字段仍可更新，而不被支持的 mode 值可能不改变当前 mode，因此“写入发生”“mode 被接受”和“翻译已重新建立”不是同一事件。MIR、MEL、MEH、MCIR 在 csky 扩展门控下允许软件直接 probe、read、write 或 invalidate JTLB，它们仍要经过 tlboper 状态机和 JTLB 端口仲裁，不能按普通单周期寄存器副作用理解。MPRV 只在规定的机器态数据访问条件下改变有效特权，不能泛化到取指或所有地址翻译。

JTLB data 的 14 位 flag 保存 5 位 PMA 以及 RSW、D、A、U、X、W、R、V，global 位单独位于 tag。物理属性来源由 MAEE 显式选择：`maee=1` 使用 PTE 的 XMAE 扩展字段，`maee=0` 使用硬连线 sysmap，不存在“扩展字段为空时自动回退”的检测。sysmap 用八个编译期固定的半开物理地址区间生成属性，也为 PTW 判断大页是否跨越 PMA 区域提供边界。观察翻译结果时，应同时核对 satp/有效特权、PTE 权限、MAEE 模式、sysmap 命中和最终 PMP/PMA 输出，避免把页表权限与物理区域属性混为一层保护。
