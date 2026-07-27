# C910 CLINT 总体架构教学文档

> RTL 文件：C910_RTL_FACTORY/gen_rtl/clint/rtl/ct_clint_top.v（约 136 行）、ct_clint_func.v（约 520 行）

## 目录

- [1. CLINT 是什么](#1-clint-是什么)
- [2. 在系统中的位置](#2-在系统中的位置)
- [3. 模块层次与文件清单](#3-模块层次与文件清单)
- [4. 寄存器映射全景](#4-寄存器映射全景)
- [5. 三类中断的数据流](#5-三类中断的数据流)
  - [5.1 mtime / mtimecmp → mtip（机器定时器中断）](#51-mtime--mtimecmp--mtip机器定时器中断)
  - [5.2 stimecmp → stip（S 态定时器中断，Sstc 思想）](#52-stimecmp--stips-态定时器中断sstc-思想)
  - [5.3 msip / ssip → 软件中断（IPI）](#53-msip--ssip--软件中断ipi)
- [6. 与核 cp0 中断接口的连接链路](#6-与核-cp0-中断接口的连接链路)
- [7. CLINT 与 PLIC 的分工](#7-clint-与-plic-的分工)
- [8. 时钟与复位](#8-时钟与复位)
- [9. 关键设计决策汇总](#9-关键设计决策汇总)

---

## 1. CLINT 是什么

CLINT（Core Local Interruptor，核局部中断器）是 RISC-V 平台里负责产生**两类"核本地"中断**的标准外设：

1. **定时器中断（Timer Interrupt）**：当全局时间计数器 `mtime` 追上某个核设定的比较值 `mtimecmp` 时，给该核拉起定时器中断（对应 CSR `mip.MTIP`）。
2. **软件中断 / 核间中断（Software Interrupt / IPI）**：一个核可以通过往另一个核的 `msip` 寄存器写 1，主动给目标核投递一个软件中断（对应 CSR `mip.MSIP`），这是多核之间互相"敲门"（Inter-Processor Interrupt）的标准手段。

OpenC910 的这套 CLINT 在标准 RISC-V CLINT 之上做了**两点扩展**：

- 不仅有机器态（M-mode）的 `msip`/`mtimecmp`，还提供了**监管态（S-mode）的 `ssip`/`stimecmp`**，使得 OS 可以直接在 S 态管理软件中断与定时器中断，省掉 M 态 SBI 转发——这就是 RISC-V "Sstc"（Supervisor-mode Timer Compare）扩展的思想（`ct_clint_func.v:329-357`、`389-417`）。
- 服务 **2 个 hart**（core0 / core1），每个 hart 独立拥有自己的一整套寄存器（`ct_clint_func.v:148-174`）。

### 它不做什么

CLINT **不产生** mtime 本身。`mtime` 是平台级的全局时基，由 SoC 顶层的系统计数器 `pad_cpu_sys_cnt` 提供，经 sysio 采样后以 `sysio_clint_mtime[63:0]` 总线送进 CLINT（见 [第 8 节](#8-时钟与复位)）。CLINT 只是**采样 mtime、保存各核的比较值、做大小比较、产生中断电平**。

---

## 2. 在系统中的位置

CLINT 挂在 SoC 内部的 **APB 总线**上，由 CPU 通过普通 load/store 访问其寄存器空间。它的输出是 8 根中断线（2 个 hart × 4 类中断），最终送到各核的 cp0。

```
                pad_cpu_sys_cnt[63:0]  (SoC 全局时间计数)
                          │
                          ▼  (ct_sysio_top.v: ccvr 寄存器采样)
                  sysio_clint_mtime[63:0]
                          │
   APB 总线 ──────────────┼──────────────────────────────┐
 (paddr/pwdata/...)       ▼                               │
                  ┌───────────────────┐                  │
                  │   ct_clint_top     │  (顶层壳)         │
                  │  └ ct_clint_func   │  (全部逻辑)       │
                  └───────────────────┘                  │
                          │                               │
        ┌─────────────────┴─────────────────┐            │
   core0: ms/mt/ss/st_int          core1: ms/mt/ss/st_int │
        │                                   │            │
        ▼                                   ▼            │
   ct_sysio_kid (core0)              ct_sysio_kid (core1) │  ← 重新同步到 cpuclk
        │                                   │            │
   sysio_piu_*_int                  sysio_piu_*_int       │
        │                                   │            │
        ▼                                   ▼            │
   PIU/CIU → cp0_regs (mip CSR)     PIU/CIU → cp0_regs   │
```

关键事实（已在 RTL 中核实）：

| 事实 | 出处 |
|------|------|
| `ct_clint_top` 仅例化 `ct_clint_func`，自身无逻辑 | `ct_clint_top.v:103-128` |
| mtime 来源 = SoC 系统计数器 `pad_cpu_sys_cnt` → sysio 的 `ccvr` 寄存器 | `ct_sysio_top.v:254`、`259` |
| CLINT 在 openC910 顶层被例化一次，服务两核 | `openC910.v:1577-1578` |
| 中断经 sysio_kid 重新同步后送 PIU | `ct_sysio_kid.v:190-202` |

---

## 3. 模块层次与文件清单

CLINT 的 RTL 极其精简，只有两个文件：

| 文件 | 行数 | 角色 | 详解文档 |
|------|------|------|----------|
| `ct_clint_top.v` | ~136 | **顶层壳**：声明端口，原样例化 `ct_clint_func`，无任何功能逻辑 | 见本文 [第 6 节](#6-与核-cp0-中断接口的连接链路) |
| `ct_clint_func.v` | ~520 | **功能体**：APB 接口、全部寄存器、比较逻辑、中断生成 | [01_clint_func.md](01_clint_func.md) |

`ct_clint_top` 的端口列表与 `ct_clint_func` **完全一一对应**（对比 `ct_clint_top.v:17-68` 与 `ct_clint_func.v:17-68`），它就是一层包装。这种"top 只做例化"的写法在 C910 里是统一风格，便于在 top 层插入 scan/物理设计相关的胶水逻辑而不污染功能代码。

---

## 4. 寄存器映射全景

CLINT 用 `paddr[15:0]` 作为寄存器偏移，地址 map 由一组 parameter 定义（`ct_clint_func.v:148-174`）。下表只列出本设计**实际实现**的寄存器（2 个 hart）；parameter 中还声明了 hart2/hart3 的地址（`MSIP2/3`、`MTIMECMP2/3` 等），但因为只服务 2 个 hart，它们在译码表里走 `default`，访问会报 access error（见 [01 文档](01_clint_func.md) 第 4 节）。

| 偏移 (paddr[15:0]) | parameter | 寄存器 | 位宽 | 特权 | 复位值 | 作用 |
|---|---|---|---|---|---|---|
| `0x0000` | MSIP0 | msip0 | 1 bit（bit0） | M | 0 | core0 机器软件中断 pending |
| `0x0004` | MSIP1 | msip1 | 1 bit | M | 0 | core1 机器软件中断 pending |
| `0x4000` | MTIMECMP0 | mtimecmp0 低 32 | 32 | M | 0xFFFFFFFF | core0 机器定时器比较值[31:0] |
| `0x4004` | MTIMECMPH0 | mtimecmp0 高 32 | 32 | M | 0xFFFFFFFF | core0 机器定时器比较值[63:32] |
| `0x4008` | MTIMECMP1 | mtimecmp1 低 32 | 32 | M | 0xFFFFFFFF | core1 机器定时器比较值[31:0] |
| `0x400C` | MTIMECMPH1 | mtimecmp1 高 32 | 32 | M | 0xFFFFFFFF | core1 机器定时器比较值[63:32] |
| `0xC000` | SSIP0 | ssip0 | 1 bit | S/M | 0 | core0 监管软件中断 pending |
| `0xC004` | SSIP1 | ssip1 | 1 bit | S/M | 0 | core1 监管软件中断 pending |
| `0xD000` | STIMECMP0 | stimecmp0 低 32 | 32 | S/M | 0xFFFFFFFF | core0 监管定时器比较值[31:0] |
| `0xD004` | STIMECMPH0 | stimecmp0 高 32 | 32 | S/M | 0xFFFFFFFF | core0 监管定时器比较值[63:32] |
| `0xD008` | STIMECMP1 | stimecmp1 低 32 | 32 | S/M | 0xFFFFFFFF | core1 监管定时器比较值[31:0] |
| `0xD00C` | STIMECMPH1 | stimecmp1 高 32 | 32 | S/M | 0xFFFFFFFF | core1 监管定时器比较值[63:32] |

几个设计要点：

- **64 位比较值拆成两个 32 位寄存器**（`*MP` 低字 + `*MPH` 高字），因为 APB 数据通路是 32 位（`pwdata[31:0]`，`ct_clint_func.v:55`）。读写一次 64 位的 mtimecmp 需要两次 APB 访问。
- **mtimecmp / stimecmp 复位值是全 1（0xFFFFFFFF…）**（`ct_clint_func.v:313`、`323` 等）。这是关键设计：复位后比较值最大，`mtime` 永远追不上，于是定时器中断默认**不触发**，避免上电瞬间误中断。
- **msip / ssip 只有 bit0 有意义**：写时只取 `pwdata[0]`（`ct_clint_func.v:305`），读时高 31 位补 0（`{31'b0, msip0_reg}`，`ct_clint_func.v:307`）。
- 地址按 4KB 区块组织：`0x0xxx`=MSIP、`0x4xxx`=MTIMECMP、`0xCxxx`=SSIP、`0xDxxx`=STIMECMP。`paddr[15:12]` 的高 4 位正好用来做特权检查（见 [01 文档](01_clint_func.md)）。

---

## 5. 三类中断的数据流

### 5.1 mtime / mtimecmp → mtip（机器定时器中断）

**数据流：**

1. SoC 全局计数 `pad_cpu_sys_cnt[63:0]` → sysio 的 `ccvr` 寄存器 → `sysio_clint_mtime[63:0]` 进入 CLINT（`ct_sysio_top.v:254/259`）。
2. CLINT 在 `mtime_clk` 上把它采样进内部 `clint_mtime_reg[63:0]`（`ct_clint_func.v:485-493`）。
3. 软件预先往 `mtimecmp0` 写好一个目标时刻（高低两字）。
4. 比较逻辑产生中断：

```verilog
// ct_clint_func.v:498-499
assign clint_core0_mt_int = !({mtimecmph0_reg[31:0], mtimecmp0_reg[31:0]}
                          > clint_mtime_reg[63:0]);
```

**为什么写成 `!(mtimecmp > mtime)`？** RISC-V 规范要求"当 `mtime >= mtimecmp` 时产生中断"。这里用德摩根等价改写：`mtime >= mtimecmp` ⇔ `!(mtimecmp > mtime)`。综合上更喜欢只比一次 `>`，再取反，比直接写 `>=` 省一个比较器。两个 32 位寄存器用位拼接 `{高, 低}` 拼成 64 位整体做无符号比较，避免分别比较高低字的繁琐进位处理。

5. `clint_core0_mt_int` 输出 → sysio_kid 重新同步 → `mip.MTIP`（见 [第 6 节](#6-与核-cp0-中断接口的连接链路)）。

### 5.2 stimecmp → stip（S 态定时器中断，Sstc 思想）

S 态定时器与 M 态**结构完全镜像**，只是寄存器换成 `stimecmp`/`stimecmph`，输出换成 `clint_core0_st_int`：

```verilog
// ct_clint_func.v:500-501
assign clint_core0_st_int = !({stimecmph0_reg[31:0], stimecmp0_reg[31:0]}
                          > clint_mtime_reg[63:0]);
```

**为什么要有这套 S 态比较器？** 标准 RISC-V 里 S 态定时器中断（`mip.STIP`）只能由 M 态软件（SBI）写 `mip` 来注入，每次 OS 想设个定时器都要陷入 M 态，开销大。Sstc 扩展让 S 态可以直接写一个 `stimecmp`，硬件自动比较产生 `stip`，绕过 M 态。OpenC910 在 CLINT 里实现了**内存映射版**的 stimecmp（`0xD000` 区），并对其放宽特权——S 态即可写（`sreg_wen = (mach_mode || supv_mode) && clint_wen`，`ct_clint_func.v:217`）。

### 5.3 msip / ssip → 软件中断（IPI）

软件中断最简单——它就是一个**可读写的 1 比特寄存器**，写进去什么就直接输出什么：

```verilog
// ct_clint_func.v:300-307 (msip0)
always @ (posedge clint_clk or negedge cpurst_b)
  if(!cpurst_b)       msip0_reg <= 1'b0;
  else if(msip0_wen)  msip0_reg <= pwdata[0];
// ...
assign clint_core0_ms_int = msip0_reg;   // ct_clint_func.v:495
```

**IPI 的玩法：** core0 想中断 core1，就往地址 `0x0004`（MSIP1）写 1，`msip1_reg` 置位 → `clint_core1_ms_int` 拉高 → core1 的 `mip.MSIP` 置位、进中断。core1 的中断处理函数读完消息后，往同一地址写 0 清除。`ssip`（`0xC000` 区）是其 S 态版本，输出 `clint_core0_ss_int`（`ct_clint_func.v:496`），供 OS 在 S 态发起核间软中断。

---

## 6. 与核 cp0 中断接口的连接链路

CLINT 的 8 根输出经过 3 跳到达每个核的 cp0：

**第 1 跳——CLINT 顶层输出（`ct_clint_top.v:58-65`）：**

| 输出 | 含义 | 对应 CSR 位 |
|------|------|------------|
| `clint_core0_ms_int` / `clint_core1_ms_int` | 机器软件中断 | `mip.MSIP` |
| `clint_core0_mt_int` / `clint_core1_mt_int` | 机器定时器中断 | `mip.MTIP` |
| `clint_core0_ss_int` / `clint_core1_ss_int` | 监管软件中断 | `mip.SSIP` |
| `clint_core0_st_int` / `clint_core1_st_int` | 监管定时器中断 | `mip.STIP` |

**第 2 跳——sysio_kid 跨时钟域同步：** sysio_top 把 core0 的四根线接到该核的 sysio_kid（`ct_sysio_top.v:308-311`）。sysio_kid 在 cpuclk 域用寄存器**重新采样一拍**，再以 `sysio_piu_*_int` 输出：

```verilog
// ct_sysio_kid.v:190-202
clint_core_ms_int_cpu <= clint_core_ms_int;   // 同步打拍
...
assign sysio_piu_ms_int = clint_core_ms_int_cpu;
assign sysio_piu_mt_int = clint_core_mt_int_cpu;
assign sysio_piu_ss_int = clint_core_ss_int_cpu;
assign sysio_piu_st_int = clint_core_st_int_cpu;
```

**为什么要打拍？** CLINT 跑在 APB 时钟域（`forever_apbclk`），而核跑在 cpuclk 域（`forever_cpuclk`），两者异步。中断电平进核前必须重新同步以防亚稳态。注意 `mtime` 的采样恰好相反——它用 `mtime_clk`（源自 `forever_cpuclk`，`ct_clint_func.v:467-468`）采样，这样比较逻辑与核同节拍。

**第 3 跳——PIU/CIU → cp0：** `sysio_piu_*_int` 经 PIU（Processor Interface Unit）/CIU 进入核内，最终在 `ct_cp0_regs.v` 里写进 `mip` CSR。cp0 的中断仲裁逻辑结合 `mie`/`mstatus.MIE` 等使能位决定是否真正打断流水线。

---

## 7. CLINT 与 PLIC 的分工

OpenC910 同时有 CLINT 和 PLIC（Platform-Level Interrupt Controller），两者职责正交：

| 维度 | CLINT | PLIC |
|------|-------|------|
| 中断来源 | 核本地：定时器 + 核间软件中断 | 外部设备：UART/网卡/GPIO… 等大量外设 |
| 中断数量 | 固定每核 4 类（mt/ms/st/ss） | 多达 ~144/160 个外部中断源（`openC910.v:160` `pad_plic_int_vld[143:0]`、`plic_int_vld[159:0]`） |
| 是否需仲裁/优先级 | 否，每根线直连一个 CSR 位 | 是，PLIC 内部有优先级/阈值/仲裁（`plic_*_arb`、`plic_ctrl` 等模块，`openC910.v:18-39`） |
| 送进核的 CSR 位 | `mip.{MTIP,MSIP,STIP,SSIP}` | `mip.{MEIP,SEIP}`（外部中断） |
| PLIC 输出信号 | — | `plic_core0_me_int`/`plic_core0_se_int`（`openC910.v:640-643`） |

一句话：**CLINT 管"时间"和"核之间互相打招呼"，PLIC 管"外面的设备来敲门"。** 两者输出在 cp0 的 `mip` 里占不同的位，互不干扰。它们都挂 APB（CLINT 用 `psel_clint`，PLIC 用 `psel_plic`），都受各自的 ICG 使能控制（`ciu_clint_icg_en` vs `ciu_plic_icg_en`，`openC910.v:255/301`）。

---

## 8. 时钟与复位

CLINT 内部有**两个门控时钟**，对应它的两类节拍需求：

| 门控时钟 | 例化 | 时钟源 | 局部使能 | 用途 |
|----------|------|--------|----------|------|
| `clint_clk` | `x_clint_gateclk`，`ct_clint_func.v:180-188` | `forever_apbclk` | `clint_clk_en` = `psel_clint \|\| perr_clint \|\| pready_clint`（`:178`） | 驱动 APB 访问相关逻辑、所有寄存器写、pready/perr |
| `mtime_clk` | `x_mtime_gated_clk`，`ct_clint_func.v:467-475` | `forever_cpuclk` | `apb_clk_en`（`:472`） | 仅采样 `sysio_clint_mtime` 进 `clint_mtime_reg` |

**设计意图：** 寄存器读写逻辑跟随 APB 总线节拍（`forever_apbclk`），只在被选中或有 ready/err 时才开时钟，省功耗；而 mtime 的采样跟随 cpu 节拍（`forever_cpuclk`），且只在 `apb_clk_en` 有效的节拍更新（`ct_clint_func.v:489`），把两个时钟域的速率对齐。两个门控时钟都受统一的模块级使能 `ciu_clint_icg_en`（来自 CIU 的时钟管理）控制（`:186`、`:473`）。

**复位** 统一用异步低有效 `cpurst_b`，所有寄存器在复位时回到安全值（比较值全 1、pending 全 0、mtime 全 0）。

---

## 9. 关键设计决策汇总

| 决策 | 体现 | 为什么 |
|------|------|--------|
| top 只做例化，逻辑全在 func | `ct_clint_top.v:103-128` | 分离物理/scan 胶水与功能逻辑，C910 统一风格 |
| 比较值复位为全 1 | `ct_clint_func.v:313/323/343/...` | 上电后 `mtime` 追不上，默认不触发定时器中断，防误中断 |
| 用 `!(cmp > mtime)` 而非 `mtime >= cmp` | `ct_clint_func.v:498-501` | 只综合一个比较器再取反，省面积 |
| 64 位比较值拆成两个 32 位寄存器 | `ct_clint_func.v:76-79` | APB 数据通路只有 32 位 |
| 实现 S 态 stimecmp/ssip（Sstc 思想） | `ct_clint_func.v:329-417` | S 态 OS 直接管定时器/软中断，省 M 态 SBI 陷入 |
| 比 M/S 寄存器各设独立特权门 | `mreg_wen` / `sreg_wen`，`:216-217`；`priv_err`，`:273-274` | M 区只许 M 写，S 区允许 M/S 写，禁止 U 态访问 |
| 非法地址 → `acc_err`，越权 → `priv_err`，合并报 perr | `ct_clint_func.v:247-274`、`235-236` | 把总线错误反馈给 APB master，符合 RISC-V 访问异常语义 |
| mtime 采样用 cpuclk、中断进核再同步 | `mtime_clk` / sysio_kid 打拍 | 处理 APB↔cpu 跨时钟域，防亚稳态 |
| 仅服务 2 hart，但地址 map 预留 4 hart | `ct_clint_func.v:148-174` | 参数化预留扩展空间，未实现的走 default 报错 |

学习建议：先读本文建立全局观，再精读 [01_clint_func.md](01_clint_func.md) 把每个 `always`/`assign` 对应到上面的数据流。

*本文档为总览，引用行号均已在 ct_clint_top.v / ct_clint_func.v 中核实。*
