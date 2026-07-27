# C910 CLINT func 模块详细教学文档

> RTL 文件：C910_RTL_FACTORY/gen_rtl/clint/rtl/ct_clint_func.v（约 520 行）

## 目录

- [1. 模块概述](#1-模块概述)
  - [1.1 职责](#11-职责)
  - [1.2 在系统中的位置](#12-在系统中的位置)
- [2. 端口说明](#2-端口说明)
- [3. 参数与关键寄存器](#3-参数与关键寄存器)
- [4. 地址译码与访问错误（acc_err / priv_err）](#4-地址译码与访问错误acc_err--priv_err)
- [5. APB 总线接口（pready / perr / prdata）](#5-apb-总线接口pready--perr--prdata)
- [6. 特权访问控制（mreg_wen / sreg_wen）](#6-特权访问控制mreg_wen--sreg_wen)
- [7. 写使能生成（per-register wen）](#7-写使能生成per-register-wen)
- [8. 寄存器主体（msip / mtimecmp / ssip / stimecmp）](#8-寄存器主体msip--mtimecmp--ssip--stimecmp)
- [9. 读数据通路（data_out MUX）](#9-读数据通路data_out-mux)
- [10. mtime 采样与中断生成（CP0 接口）](#10-mtime-采样与中断生成cp0-接口)
- [11. 时钟门控](#11-时钟门控)
- [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

`ct_clint_func` 是 CLINT 的**唯一功能模块**（顶层 `ct_clint_top` 只是把它原样例化）。它把一条 APB 从设备接口、一组中断/比较寄存器、以及全部中断生成逻辑封装在一起，干三件事（代码注释也这么分段，`ct_clint_func.v:198-203`）：

1. **APB interface** —— 当一个 32 位 APB 从设备，响应 CPU 对 CLINT 寄存器空间的读写，产生 `pready`/`perr`/`prdata`。
2. **Software and Time Register** —— 保存 2 个 hart 各自的 `msip`/`ssip`（软件中断 pending）与 `mtimecmp`/`stimecmp`（64 位定时器比较值）。
3. **CP0 interface** —— 采样全局 `mtime`，做比较，向 2 个核各输出 4 根中断线（mt/ms/st/ss）。

### 1.2 在系统中的位置

它被 `ct_clint_top` 例化（`ct_clint_top.v:103-128`），后者再被 openC910 顶层例化（`openC910.v:1577`）。输入侧接 SoC 内部 APB 总线和 `sysio_clint_mtime`，输出侧的 8 根中断线经 sysio_kid 同步后送进两个核的 cp0（完整链路见 [00_clint_overview.md](00_clint_overview.md) 第 6 节）。

---

## 2. 端口说明

### 时钟与复位（`ct_clint_func.v:45-50`）

| 端口 | 方向 | 位宽 | 说明 |
|------|------|------|------|
| `forever_apbclk` | in | 1 | APB 自由运行时钟，门控后生成 `clint_clk` |
| `forever_cpuclk` | in | 1 | CPU 自由运行时钟，门控后生成 `mtime_clk` |
| `apb_clk_en` | in | 1 | mtime 采样的局部使能（也是 mtime 门控时钟的 local_en） |
| `ciu_clint_icg_en` | in | 1 | CIU 下发的模块级时钟门控使能 |
| `pad_yy_icg_scan_en` | in | 1 | DFT scan 时旁路时钟门控 |
| `cpurst_b` | in | 1 | 异步低有效复位 |

### APB 从设备接口（`ct_clint_func.v:51-68`）

| 端口 | 方向 | 位宽 | 说明 |
|------|------|------|------|
| `psel_clint` | in | 1 | APB 片选 |
| `penable` | in | 1 | APB enable（访问的第二拍） |
| `pwrite` | in | 1 | 1=写，0=读 |
| `paddr` | in | 32 | 地址（实际只用 `paddr[15:0]` 译码） |
| `pwdata` | in | 32 | 写数据 |
| `pprot` | in | 2 | 保护属性 = 发起访问的特权级 |
| `prdata_clint` | out | 32 | 读数据 |
| `pready_clint` | out | 1 | 传输完成 |
| `perr_clint` | out | 1 | 传输出错（非法地址或越权） |

### mtime 输入与中断输出（`ct_clint_func.v:57-65`）

| 端口 | 方向 | 位宽 | 说明 |
|------|------|------|------|
| `sysio_clint_mtime` | in | 64 | SoC 全局时间计数（来自 sysio 的 ccvr） |
| `clint_core0_mt_int` / `clint_core1_mt_int` | out | 1 | 机器定时器中断（→ `mip.MTIP`） |
| `clint_core0_ms_int` / `clint_core1_ms_int` | out | 1 | 机器软件中断（→ `mip.MSIP`） |
| `clint_core0_st_int` / `clint_core1_st_int` | out | 1 | 监管定时器中断（→ `mip.STIP`） |
| `clint_core0_ss_int` / `clint_core1_ss_int` | out | 1 | 监管软件中断（→ `mip.SSIP`） |

---

## 3. 参数与关键寄存器

### 地址 parameter（`ct_clint_func.v:148-174`）

地址按特权与功能分成 4 个区，每区每 hart 一个偏移：

```
MSIP   区：0x0000 起，每 hart +4   →  MSIP0=0x0000, MSIP1=0x0004 ...
MTIMECMP 区：0x4000 起，每 hart +8  →  MTIMECMP0=0x4000/H=0x4004, MTIMECMP1=0x4008/H=0x400C ...
SSIP   区：0xC000 起，每 hart +4   →  SSIP0=0xC000, SSIP1=0xC004 ...
STIMECMP 区：0xD000 起，每 hart +8  →  STIMECMP0=0xD000/H=0xD004, STIMECMP1=0xD008/H=0xD00C ...
```

注意 parameter 一直定义到 `*2`/`*3`（hart2、hart3，`:150-151`、`:157-160`、`:164-165`、`:171-174`），**但本设计只实现 hart0/hart1**。hart2/3 的地址在译码表里没有 case 分支，会落到 `default`（见第 4 节），即对它们的访问被判为非法。这是"参数化预留、按需实现"的常见做法。

### 关键寄存器（`ct_clint_func.v:70-87`）

| 寄存器 | 位宽 | 复位值 | 行号 | 说明 |
|--------|------|--------|------|------|
| `clint_mtime_reg` | 64 | 0 | `:72`,`:488` | mtime 的本地采样副本 |
| `msip0_reg` / `msip1_reg` | 1 | 0 | `:74-75`,`:303/363` | M 软件中断 pending |
| `ssip0_reg` / `ssip1_reg` | 1 | 0 | `:82-83`,`:333/393` | S 软件中断 pending |
| `mtimecmp0_reg` / `mtimecmp1_reg` | 32 | 0xFFFFFFFF | `:76-77`,`:313/373` | M 比较值低 32 |
| `mtimecmph0_reg` / `mtimecmph1_reg` | 32 | 0xFFFFFFFF | `:78-79`,`:323/383` | M 比较值高 32 |
| `stimecmp0_reg` / `stimecmp1_reg` | 32 | 0xFFFFFFFF | `:84-85`,`:343/403` | S 比较值低 32 |
| `stimecmph0_reg` / `stimecmph1_reg` | 32 | 0xFFFFFFFF | `:86-87`,`:353/413` | S 比较值高 32 |
| `data_out` | 32 | （组合） | `:73`,`:436` | 读数据 MUX 结果 |
| `acc_err` | 1 | （组合） | `:71`,`:247` | 地址非法标志 |
| `pready_clint` / `perr_clint` | 1 | 0 | `:80-81` | APB 应答 |

**为什么比较值复位成全 1？** `mtimecmp`/`stimecmp` 复位为 `0xFFFFFFFF`（高低字都是，拼起来是 64 位全 1，即最大值）。这样上电后 `mtime`（从 0 开始）永远小于比较值，`mtime >= cmp` 不成立，定时器中断默认关闭。软件想用定时器时，先写一个合理的将来时刻进去再说。

---

## 4. 地址译码与访问错误（acc_err / priv_err）

CLINT 把"访问是否合法"拆成**两个正交的检查**：地址是否存在（`acc_err`）、特权是否够（`priv_err`）。

### acc_err —— 地址合法性（`ct_clint_func.v:247-271`）

一个组合 case，对 `paddr[15:0]` 译码。**只有真正实现的 12 个地址**（MSIP0/1、MTIMECMP0/1 及其 H、SSIP0/1、STIMECMP0/1 及其 H）置 `acc_err=0`，其余一切（包括预留的 hart2/3 地址）走 `default: acc_err=1'b1`（`:268`）：

```verilog
always @( paddr[15:0])
case(paddr[15:0])
  MSIP0:      acc_err = 1'b0;
  MTIMECMP0:  acc_err = 1'b0;
  ...
  default:    acc_err = 1'b1;       // 非法地址
endcase
```

**为什么用白名单而不是范围判断？** CLINT 寄存器在地址空间里是稀疏的（中间有大量空洞，比如 0x4000 区只用了头 16 字节），白名单 case 最精确，能把所有未实现地址都拦下报错。

### priv_err —— 特权合法性（`ct_clint_func.v:273-274`）

```verilog
assign priv_err = (paddr[15:12] == 4'h0 || paddr[15:12] == 4'h4) && !mach_mode
               || (paddr[15:12] == 4'hC || paddr[15:12] == 4'hD) &&  user_mode;
```

它用地址高 4 位 `paddr[15:12]` 判断访问落在哪个区，再核对发起者特权：

- **M 区（`0x0xxx` MSIP、`0x4xxx` MTIMECMP）**：只允许机器态。非 M 态访问 → `priv_err`。
- **S 区（`0xCxxx` SSIP、`0xDxxx` STIMECMP）**：禁止用户态。U 态访问 → `priv_err`（M、S 都可访问）。

这正好对应 RISC-V 的特权语义：M 态资源只能 M 访问；S 态资源 OS（S）和固件（M）都能碰，但 U 态应用程序不行。`acc_err` 和 `priv_err` 最后一起喂给 perr 生成逻辑（第 5 节）。

---

## 5. APB 总线接口（pready / perr / prdata）

CLINT 是个**两拍应答的 APB 从设备**。APB 协议里一次访问分 SETUP（`psel=1,penable=0`）和 ACCESS（`psel=1,penable=1`）两拍。

### clint_wen —— 写命中（`ct_clint_func.v:210`）

```verilog
assign clint_wen = psel_clint && pwrite && penable;
```

只有片选 + 写 + enable 三者同时成立才算一次有效写（在 ACCESS 拍）。

### pready 生成（`ct_clint_func.v:220-228`）

```verilog
if(!cpurst_b)              pready_clint <= 1'b0;
else if(psel_clint && !penable)  pready_clint <= 1'b1;   // SETUP 拍置位
else                       pready_clint <= 1'b0;
```

在 SETUP 拍（`psel && !penable`）就把 `pready` 拉高一拍，这样到 ACCESS 拍时 master 看到 ready，传输完成。CLINT 寄存器访问无 wait state，固定一拍 ready。

### perr 生成（`ct_clint_func.v:231-239`）

```verilog
else if(psel_clint && !penable && (acc_err || priv_err))
    perr_clint <= 1'b1;
```

同样在 SETUP 拍判定：若地址非法（`acc_err`）或越权（`priv_err`），把 `perr` 拉高，告诉 master 这次访问出错。两个错误源在这里**合并**成一根 perr 线。

### prdata（`ct_clint_func.v:242`）

```verilog
assign prdata_clint[31:0] = data_out[31:0];
```

读数据直接取读 MUX 的结果 `data_out`（第 9 节）。

**注意 clint_clk_en 也依赖 perr/pready：** 门控时钟使能 `clint_clk_en = psel_clint || perr_clint || pready_clint`（`:178`）。把 perr/pready 也算进去，是为了保证应答拍即使 psel 已撤掉，时钟仍然有效、寄存器能把应答输出更新到正确值。

---

## 6. 特权访问控制（mreg_wen / sreg_wen）

特权级直接从 APB 的 `pprot[1:0]` 解码（`ct_clint_func.v:212-214`）：

```verilog
assign user_mode = pprot[1:0] == 2'b00;
assign supv_mode = pprot[1:0] == 2'b01;
assign mach_mode = pprot[1:0] == 2'b11;
```

在此基础上生成两条"按区放行"的总写使能（`ct_clint_func.v:216-217`）：

```verilog
assign mreg_wen  = mach_mode && clint_wen;                 // M 区只许 M 写
assign sreg_wen  = (mach_mode || supv_mode) && clint_wen;  // S 区许 M/S 写
```

- `mreg_wen`：M 态资源（msip/mtimecmp）的写门，只有机器态才放行。
- `sreg_wen`：S 态资源（ssip/stimecmp）的写门，机器态或监管态都放行。

**与 priv_err 的关系（重要）：** 这两条 wen 是"积极防御"——越权写时 wen 不会有效，寄存器内容不被破坏；而 `priv_err` 是"消极报错"——同一次越权访问还会通过 perr 反馈给 master。两者配合：**既不让坏写入生效，又把错误报出去**。这是体现 Sstc 思想的关键所在——S 态被允许直接写 stimecmp/ssip（`sreg_wen` 放行 S 态），从而无需陷入 M 态即可设置 S 定时器/软中断。

---

## 7. 写使能生成（per-register wen）

每个寄存器有自己的写命中信号，由"区写使能 && 地址精确匹配"得到（`ct_clint_func.v:281-295`）：

```verilog
// hart0 的 M 区（受 mreg_wen 控制）
assign msip0_wen      = mreg_wen && paddr[15:0] == MSIP0;
assign mtimecmp0_wen  = mreg_wen && paddr[15:0] == MTIMECMP0;
assign mtimecmph0_wen = mreg_wen && paddr[15:0] == MTIMECMPH0;
// hart0 的 S 区（受 sreg_wen 控制）
assign ssip0_wen      = sreg_wen && paddr[15:0] == SSIP0;
assign stimecmp0_wen  = sreg_wen && paddr[15:0] == STIMECMP0;
assign stimecmph0_wen = sreg_wen && paddr[15:0] == STIMECMPH0;
// hart1 同理（:289-295）
```

可以看到 M 区寄存器统一用 `mreg_wen`、S 区寄存器统一用 `sreg_wen`——特权检查在这里**自然落地**到每个寄存器。地址用全 16 位精确比较，确保只命中目标寄存器。

---

## 8. 寄存器主体（msip / mtimecmp / ssip / stimecmp）

每个寄存器都是一个标准的"复位 + 写使能更新"的时序块，跑在 `clint_clk` 上。下面各举一例（hart1 与 hart0 结构相同，只是序号不同）。

### 软件中断寄存器（1 bit）——`ct_clint_func.v:300-307`

```verilog
always @ (posedge clint_clk or negedge cpurst_b)
  if(!cpurst_b)       msip0_reg <= 1'b0;
  else if(msip0_wen)  msip0_reg <= pwdata[0];      // 只取 bit0
assign msip0_value[31:0] = {31'b0, msip0_reg};     // 读出时高位补 0
```

软件中断本质是个 1 比特锁存器：写 1 拉起中断、写 0 清中断，由软件全权控制。`ssip0_reg`（`:330-337`）结构完全一致，只是写门换成 `ssip0_wen`、输出 `ssip0_value`。

### 定时器比较寄存器（32 bit × 2）——`ct_clint_func.v:310-327`

```verilog
// 低 32 位
always @ (posedge clint_clk or negedge cpurst_b)
  if(!cpurst_b)            mtimecmp0_reg[31:0] <= 32'hffffffff;   // 复位全 1
  else if(mtimecmp0_wen)   mtimecmp0_reg[31:0] <= pwdata[31:0];
assign mtimecmp0_value[31:0] = mtimecmp0_reg[31:0];
// 高 32 位（mtimecmph0_reg，:319-327）结构相同，写门 mtimecmph0_wen
```

64 位比较值拆成低字 `mtimecmp0_reg` + 高字 `mtimecmph0_reg`，分别由两个地址写入，复位都为全 1。`stimecmp`/`stimecmph`（`:339-357`）是其 S 态镜像。

**对称性总结：** hart0 与 hart1 各有 8 个寄存器块（msip、ssip、mtimecmp/H、stimecmp/H），共 16 个，全部按上面两种模板复制（`:300-417`）。这种高度规整使代码易读、易扩展到更多 hart。

---

## 9. 读数据通路（data_out MUX）

读路径是一个组合 case，按 `paddr[15:0]` 选出对应寄存器的 `*_value` 送给 `data_out`（`ct_clint_func.v:437-457`）：

```verilog
case(paddr[15:0])
  MSIP0:      data_out[31:0] = msip0_value[31:0];
  MTIMECMP0:  data_out[31:0] = mtimecmp0_value[31:0];
  MTIMECMPH0: data_out[31:0] = mtimecmph0_value[31:0];
  SSIP0:      data_out[31:0] = ssip0_value[31:0];
  ...
  default:    data_out[31:0] = {32{1'bx}};   // 非法地址读出 X
endcase
```

要点：

- 软件中断读出是 `{31'b0, *_reg}`，符合 RISC-X msip/ssip 只有 bit0 的语义。
- 64 位比较值要读两次（先读 `MTIMECMP0` 拿低字，再读 `MTIMECMPH0` 拿高字）。
- `default` 给 `32'bx`——非法地址本来就会通过 `acc_err`/`perr` 报错，读数据是什么无所谓，给 X 让综合工具自由优化。
- 这个 MUX 与 acc_err 的 case（第 4 节）地址表一致：能读到真值的地址恰好就是 `acc_err=0` 的那些。

---

## 10. mtime 采样与中断生成（CP0 接口）

这是 CLINT 的核心输出段（`ct_clint_func.v:462-513`），对应注释"3. CP0 interface"。

### mtime 采样（`ct_clint_func.v:485-493`）

```verilog
always@(posedge mtime_clk or negedge cpurst_b)
  if(!cpurst_b)        clint_mtime_reg[63:0] <= 64'b0;
  else if(apb_clk_en)  clint_mtime_reg[63:0] <= sysio_clint_mtime[63:0];
  else                 clint_mtime_reg[63:0] <= clint_mtime_reg[63:0];   // 保持
```

把外部送来的 64 位 `sysio_clint_mtime` 采样进本地寄存器 `clint_mtime_reg`，只在 `apb_clk_en` 有效的节拍更新。**为什么用 `mtime_clk`（源自 cpuclk）而不是 apbclk？** 这样 mtime 副本与核同节拍，后续比较产生的中断电平和核的时间观一致；`apb_clk_en` 则把更新速率对齐到 APB 节奏，避免每个 cpuclk 都刷新带来的功耗与跨域问题。

### 软件中断输出（`ct_clint_func.v:495-496`、`505-506`）

```verilog
assign clint_core0_ms_int = msip0_reg;
assign clint_core0_ss_int = ssip0_reg;
assign clint_core1_ms_int = msip1_reg;   // :505
assign clint_core1_ss_int = ssip1_reg;   // :506
```

软件中断直接把 pending 寄存器接出去，无任何组合逻辑——写进 1 就立刻拉高中断。

### 定时器中断比较（`ct_clint_func.v:498-511`）

```verilog
assign clint_core0_mt_int = !({mtimecmph0_reg[31:0], mtimecmp0_reg[31:0]} > clint_mtime_reg[63:0]);
assign clint_core0_st_int = !({stimecmph0_reg[31:0], stimecmp0_reg[31:0]} > clint_mtime_reg[63:0]);
assign clint_core1_mt_int = !({mtimecmph1_reg[31:0], mtimecmp1_reg[31:0]} > clint_mtime_reg[63:0]);
assign clint_core1_st_int = !({stimecmph1_reg[31:0], stimecmp1_reg[31:0]} > clint_mtime_reg[63:0]);
```

每根定时器中断线的逻辑都是同一个套路：

1. 把高字、低字两个 32 位寄存器用位拼接 `{高, 低}` 组成 64 位比较值。
2. 与本地 `clint_mtime_reg[63:0]` 做无符号 `>` 比较。
3. 取反 `!(...)`。

`!(cmp > mtime)` 在数学上等于 `mtime >= cmp`，正是 RISC-V 规范要求的定时器中断条件。这样写只用一个 `>` 比较器（而非额外的 `>=`），是面积友好的写法。共 4 根定时器中断线（2 hart × {M, S}）。

第 503、513 行有被注释掉的 `clint_core*_time[63:0]` 导出——曾经打算把 mtime 也送进核，最终未启用（核自有时间通路 `sysio_xx_time`）。

---

## 11. 时钟门控

模块内两个 `gated_clk_cell` 实例：

| 实例 | 行号 | clk_in | local_en | clk_out | 服务对象 |
|------|------|--------|----------|---------|----------|
| `x_clint_gateclk` | `:180-188` | `forever_apbclk` | `clint_clk_en`（`:178`） | `clint_clk`：APB 逻辑 + 全部寄存器写 + pready/perr |
| `x_mtime_gated_clk` | `:467-475` | `forever_cpuclk` | `apb_clk_en` | `mtime_clk`：仅 mtime 采样 |

两者 `global_en=1`、`external_en=0`，模块级使能均为 `ciu_clint_icg_en`，DFT 时由 `pad_yy_icg_scan_en` 旁路。`clint_clk_en = psel_clint || perr_clint || pready_clint`：只在有访问或正在应答时开 APB 时钟，平时关掉省功耗。

---

## 设计取舍小结

| 取舍 | 体现（行号） | 理由 |
|------|------|------|
| 比较值复位全 1 | `:313/323/343/353/373/383/403/413` | 上电默认不触发定时器中断 |
| `!(cmp > mtime)` 实现 `mtime>=cmp` | `:498-511` | 单比较器 + 取反，省面积 |
| 64 位拆 2×32 位寄存器 + 位拼接比较 | `:76-79`、`:498` | 适配 32 位 APB 数据通路 |
| acc_err 用白名单 case | `:247-271` | 稀疏地址空间下精确拦非法访问 |
| 特权 wen 与 priv_err 双管齐下 | `:216-217`、`:273-274` | 既阻止坏写生效又上报错误 |
| S 区放行 S 态写（Sstc） | `:217`、`:285-287` | S 态 OS 直接管定时器/软中断，免 M 陷入 |
| msip/ssip 仅 bit0、读补 0 | `:305`、`:307` | 符合 RISC-V 软件中断寄存器语义 |
| mtime 用 cpuclk 域采样、`apb_clk_en` 选通 | `:467-493` | 对齐核节拍 + 控制刷新速率 |
| 两路门控时钟、按需开启 | `:178-188`、`:467-475` | APB 逻辑与 mtime 采样分域低功耗 |
| 参数预留 4 hart、仅实现 2 hart | `:148-174`、case 表 | 可扩展，未实现走 default 报错 |

*文档覆盖 ct_clint_func.v 全部 520 行逻辑。*
