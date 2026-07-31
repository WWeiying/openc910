# `ct_clint_func` RTL 逐段教学

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/clint/rtl/ct_clint_func.v`
>
> 本文按 RTL 的组合条件、时序接受点和输出传播关系解释功能。涉及 RISC-V 软件习惯的段落会明确标为体系结构解释，不把背景知识写成当前 RTL 已证明的功能。

## 1. 模块职责

`ct_clint_func` 是 CLINT 的功能主体，包含：

1. APB 从设备应答；
2. 地址合法性与访问权限检查；
3. 两个 hart 的软件中断寄存器；
4. 两个 hart 的机器态、监管态定时器比较寄存器；
5. 系统时间的本地采样寄存器；
6. 八根中断电平输出；
7. APB 逻辑和时间采样逻辑的两组门控时钟。

它不包含：

- 自增式 `mtime` 计数器；
- PLIC 外部中断仲裁；
- 中断入口地址计算；
- CP0 中断优先级选择；
- IPI 消息缓冲区；
- 64 位比较值的原子写提交机构。

## 2. 端口按功能分组

### 2.1 时钟、复位和门控控制

| 端口 | 含义 | 直接使用位置 |
|---|---|---|
| `forever_apbclk` | APB 侧基础时钟 | `x_clint_gateclk` 输入 |
| `forever_cpuclk` | CPU 侧基础时钟 | `x_mtime_gated_clk` 输入 |
| `cpurst_b` | 异步低有效复位 | 模块内全部显式复位时序块 |
| `apb_clk_en` | 时间与中断采样相关使能 | `mtime_clk`、上游 `sysio_kid` 的局部使能 |
| `ciu_clint_icg_en` | CLINT 模块级 ICG 使能 | 两个 `gated_clk_cell` |
| `pad_yy_icg_scan_en` | scan 模式时钟控制 | 两个 `gated_clk_cell` |

`apb_clk_en` 名称中带 APB，但在本模块里它驱动的是基于 `forever_cpuclk` 的 `mtime_clk` 局部使能。阅读时应看实际连接，而不是仅按信号名字推断时钟域。

### 2.2 APB 请求和应答

| 端口 | 方向 | 位宽 | RTL 中的用途 |
|---|---|---:|---|
| `psel_clint` | 输入 | 1 | 表示上级已选中 CLINT |
| `penable` | 输入 | 1 | 区分 SETUP 与 ACCESS 阶段 |
| `pwrite` | 输入 | 1 | 1 为写，0 为读 |
| `paddr` | 输入 | 32 | 本模块只译码低 16 位 |
| `pwdata` | 输入 | 32 | 写数据 |
| `pprot` | 输入 | 2 | 本实现自定义解释为 U/S/M 访问属性 |
| `pready_clint` | 输出寄存器 | 1 | SETUP 后在 ACCESS 阶段给出的 ready |
| `perr_clint` | 输出寄存器 | 1 | 与应答配对的地址/权限错误指示 |
| `prdata_clint` | 输出 | 32 | 组合读数据 |

这里的 `perr_clint` 是工程内部接口名。它承担 APB 错误应答方向的作用，但是否在更上层直接对应某一版 APB 的 `PSLVERR`，应继续沿上级连接确认，不需要在本模块文档中强行改名。

### 2.3 时间和中断

| 端口 | 方向 | 含义 |
|---|---|---|
| `sysio_clint_mtime[63:0]` | 输入 | sysio 已采样的系统时间 |
| `clint_core0_ms_int` | 输出 | hart0 机器软件中断电平 |
| `clint_core0_mt_int` | 输出 | hart0 机器定时器中断电平 |
| `clint_core0_ss_int` | 输出 | hart0 监管软件中断电平 |
| `clint_core0_st_int` | 输出 | hart0 监管定时器中断电平 |
| `clint_core1_*` | 输出 | hart1 对应的四类中断电平 |

## 3. 地址参数不等于已实现寄存器

RTL 为 hart0 至 hart3 都定义了符号地址：

```text
MSIP0..3
MTIMECMP0..3 / MTIMECMPH0..3
SSIP0..3
STIMECMP0..3 / STIMECMPH0..3
```

但是后续只有 hart0、hart1 出现在：

- `acc_err` 合法地址 case；
- 独立寄存器声明；
- 专用写使能；
- 读数据 MUX；
- 中断输出。

因此当前有效寄存器总数是 12 个 32 位地址槽：

```text
每 hart:
  1 x MSIP
  2 x MTIMECMP 高低半部
  1 x SSIP
  2 x STIMECMP 高低半部

2 hart x 6 = 12 个地址槽
```

`MSIP2` 等 parameter 是未实现预留。访问它们会报告地址错误。

## 4. APB 时序：ready、error 和真正的写入沿

### 4.1 `pready_clint`

```verilog
always @(posedge clint_clk or negedge cpurst_b)
  if (!cpurst_b)
    pready_clint <= 1'b0;
  else if (psel_clint && !penable)
    pready_clint <= 1'b1;
  else
    pready_clint <= 1'b0;
```

时序解释：

| 阶段 | 输入 | 时钟沿后的 `pready_clint` |
|---|---|---|
| 空闲 | `psel=0` | 0 |
| SETUP | `psel=1, penable=0` | 1 |
| ACCESS | `psel=1, penable=1` | 0 |

在 APB 的同步观察方式中，SETUP 末端寄存出的 1 会在随后的 ACCESS 阶段可见，因此主设备可在该 ACCESS 阶段完成传输。代码不是组合 `pready=1`，也不是在 SETUP 开始的瞬间就完成传输。

### 4.2 `perr_clint`

```verilog
else if (psel_clint && !penable && (acc_err || priv_err))
  perr_clint <= 1'b1;
```

错误同样在 SETUP 末端被寄存，并在后续 ACCESS 阶段与应答一起可见。`acc_err` 和 `priv_err` 是基于当前地址/属性的组合判断，因此 APB 协议要求 SETUP 阶段控制信号稳定非常重要。

### 4.3 目标寄存器何时更新

总写请求条件是：

```verilog
clint_wen = psel_clint && pwrite && penable;
```

再经过特权和地址条件形成专用写使能。例如：

```verilog
mreg_wen     = mach_mode && clint_wen;
mtimecmp0_wen = mreg_wen && paddr[15:0] == MTIMECMP0;
```

因此寄存器更新发生在 ACCESS 阶段末端的 `clint_clk` 上升沿，而不是 SETUP 阶段产生 ready 的那个沿。精确因果链是：

```text
SETUP 地址/属性出现
  -> SETUP 沿寄存 ready/error
  -> ACCESS 阶段形成 clint_wen
  -> 地址和特权形成专用 wen
  -> ACCESS 沿写入目标寄存器
  -> 新状态改变中断组合输出
```

## 5. 地址合法性检查

`acc_err` 使用白名单组合 case。只有 12 个实际寄存器偏移返回 0，其他低 16 位地址都返回 1。

这意味着：

- 已声明但未实现的 hart2/3 地址非法；
- 寄存器之间的空洞地址非法；
- 对齐但未列入白名单的地址同样非法；
- `paddr[31:16]` 不参与本地合法性判断，因为进入本模块前已经由 `psel_clint` 完成上层区域选择。

非法地址时，读 MUX 的默认值是 32 位 `x`。这适合在 RTL 仿真中暴露错误使用；软件不能依赖错误访问的数据值，应该以错误应答为准。

## 6. `pprot` 特权解释和边界

### 6.1 三个有效编码

```verilog
user_mode = pprot == 2'b00;
supv_mode = pprot == 2'b01;
mach_mode = pprot == 2'b11;
```

写入许可：

```verilog
mreg_wen = mach_mode && clint_wen;
sreg_wen = (mach_mode || supv_mode) && clint_wen;
```

错误判断：

```text
M 区 0x0/0x4: 不是 machine -> priv_err
S 区 0xc/0xd: 是 user       -> priv_err
```

对于正常 U/S/M 编码，结果为：

| 请求模式 | M 区读 | M 区写 | S 区读 | S 区写 |
|---|---|---|---|---|
| U `00` | 权限错误 | 权限错误且不更新 | 权限错误 | 权限错误且不更新 |
| S `01` | 权限错误 | 权限错误且不更新 | 允许 | 允许更新 |
| M `11` | 允许 | 允许更新 | 允许 | 允许更新 |

`priv_err` 不区分读写，因此越权读也会报错。写入端还通过 `mreg_wen/sreg_wen` 阻止寄存器状态改变。

### 6.2 保留编码 `10`

`10` 不是三个模式中的任何一个：

- M 区：`!mach_mode` 成立，会报权限错；
- S 区：`user_mode` 不成立，不报权限错；
- S 区写：`mach_mode || supv_mode` 不成立，不会更新。

因此，在保留编码下可能出现“读 S 区未报权限错、写 S 区未报错但也未生效”的非对称行为。这不是常规软件访问模式，但它是 RTL 的真实边界，验证环境应约束或覆盖它。

## 7. 专用写使能

每个寄存器的写使能由“总线写已进入 ACCESS + 特权许可 + 地址命中”构成：

```text
msip0_wen      = mreg_wen && addr == MSIP0
mtimecmp0_wen  = mreg_wen && addr == MTIMECMP0
mtimecmph0_wen = mreg_wen && addr == MTIMECMPH0

ssip0_wen      = sreg_wen && addr == SSIP0
stimecmp0_wen  = sreg_wen && addr == STIMECMP0
stimecmph0_wen = sreg_wen && addr == STIMECMPH0
```

hart1 完全对称。这里没有字节写使能，因此本模块接收的是完整 32 位写数据；软件中断寄存器只主动选取 bit 0。

## 8. 软件中断寄存器

### 8.1 写入和读回

`msip0_reg` 的结构代表四个软件中断寄存器的共同形式：

```verilog
if (!cpurst_b)
  msip0_reg <= 1'b0;
else if (msip0_wen)
  msip0_reg <= pwdata[0];

msip0_value = {31'b0, msip0_reg};
```

行为要点：

- 复位值为 0；
- 只有专用写使能成立的 ACCESS 沿才更新；
- 只保存 `pwdata[0]`；
- 未写时保持原值；
- 读回的 `[31:1]` 固定为 0；
- 直接驱动输出，因此是保持型电平。

### 8.2 从“写 1”到“实际进入中断”的距离

```text
写 1 被目标寄存器接受
  -> msip/ssip 寄存器变 1
  -> CLINT 输出组合变 1
  -> sysio_kid 在后续有效采样沿寄存
  -> CP0 对应 pending 输入变化
  -> CP0 检查使能和特权条件
  -> RTU 在可接受边界进行控制流重定向
```

所以“写 1 立即中断另一个核”只适合作为软件层简写，不适合作为周期精确说明。

## 9. 64 位定时器比较寄存器

每个 64 位阈值由两个独立的 32 位寄存器组成：

```text
machine compare    = {mtimecmph*_reg, mtimecmp*_reg}
supervisor compare = {stimecmph*_reg, stimecmp*_reg}
```

### 9.1 复位值

每个半部复位为 `32'hffffffff`，组合阈值为 64 位最大无符号数。

正确表述是：

> 该复位值把首次正常触发推迟到系统时间达到最大值，因而通常可以避免复位后立即产生定时器中断。

错误表述是：

> `mtime` 永远追不上最大值。

二进制 64 位计数器可以等于最大值；此时比较条件成立。

### 9.2 非原子更新

两个半部有独立地址和独立写使能，没有 shadow/commit 位。假设旧值为：

```text
old = {old_hi, old_lo}
```

先写高半部后，比较器立即看到：

```text
intermediate = {new_hi, old_lo}
```

再写低半部后才看到：

```text
final = {new_hi, new_lo}
```

这类中间值可能改变中断电平。RTL 没有替软件隐藏该过程。软件必须根据时间单调性和目标值选择安全写序。

### 9.3 读取的边界

读高低半部也是两次独立 APB 事务。这里读取的是软件配置的比较值，它不会像自由运行计数器那样每拍变化；但若另一个 hart、调试器或固件并发改写，两个读结果仍可能来自不同版本。当前 CLINT 没有快照锁存。

## 10. 读数据通路

`data_out` 是一个纯组合 case：

```text
paddr[15:0]
  -> 选择 12 个寄存器值之一
  -> prdata_clint
```

软件中断值高位补零，比较寄存器返回完整 32 位半部。非法地址返回 `x`，同时 `acc_err` 在 SETUP 时被捕获为错误应答。

`prdata_clint` 本身没有“读数据有效”寄存器。其协议有效性来自 APB 的 `psel/penable/pready` 阶段关系，不能单看 `prdata_clint` 上出现某个数就认定一次读已经完成。

## 11. 系统时间采样

### 11.1 CLINT 内部采样

```verilog
always @(posedge mtime_clk or negedge cpurst_b)
  if (!cpurst_b)
    clint_mtime_reg <= 64'b0;
  else if (apb_clk_en)
    clint_mtime_reg <= sysio_clint_mtime;
```

`mtime_clk` 本身已经以 `apb_clk_en` 作为 `gated_clk_cell.local_en`，时序块内又检查一次 `apb_clk_en`。在真实门控单元配置下，内部判断通常与门控条件一致；在仓库的 pass-through 仿真配置下，内部判断仍确保寄存器只在使能为 1 时更新。

### 11.2 上游并非直接连引脚

上游 `ct_sysio_top` 还有：

```verilog
if (axim_clk_en)
  ccvr <= pad_cpu_sys_cnt;

assign sysio_clint_mtime = ccvr;
```

因此：

```text
外部计数值
  -> sysio 在 axim_clk_en 有效时采样
  -> CLINT 在 apb_clk_en 有效时再采样
  -> 比较器使用 CLINT 本地样本
```

文档不能把它简化成“mtime 每个 CPU 周期直接进入比较器”。若两个使能不是每周期有效，中断检测会相应延后。

### 11.3 CDC 能证明到什么程度

`sysio_clk` 和 `mtime_clk` 都由 `forever_cpuclk` 相关门控路径产生，这是 RTL 可见事实。但 `pad_cpu_sys_cnt` 的真正源时钟、相位约束和 SoC 集成假设不在本模块中。

所以可以说：

- sysio 和 CLINT 对时间值进行了两级寄存采样；
- 采样寄存器位于 CPU 基础时钟派生路径。

不能只据此说：

- 64 位异步总线已经通过标准同步器无撕裂跨域；
- 任意外部时钟关系下都不存在亚稳态；
- 采样值一定对应同一个外部计数瞬间。

这些结论需要顶层时钟约束、系统计数器接口协议或 CDC 报告支持。

## 12. 定时器比较逻辑

四个比较器完全对称：

```verilog
clint_core0_mt_int = !({mtimecmph0_reg, mtimecmp0_reg}
                     > clint_mtime_reg);
clint_core0_st_int = !({stimecmph0_reg, stimecmp0_reg}
                     > clint_mtime_reg);
```

等价伪代码：

```text
mt_int[hart] = unsigned(sampled_mtime) >= unsigned(mtimecmp[hart])
st_int[hart] = unsigned(sampled_mtime) >= unsigned(stimecmp[hart])
```

关键细节：

- 拼接后的两个操作数都是 64 位；
- Verilog 中这些寄存器未声明 `signed`，因此执行无符号比较；
- 输出为组合逻辑，不再经过 CLINT 内部输出寄存器；
- 输出保持时间由比较关系决定，而不是固定一个周期；
- 改写阈值和更新本地时间样本都可能改变输出；
- `!(cmp > time)` 与 `time >= cmp` 逻辑等价，但面积和时序必须由目标工艺综合结果判断。

## 13. 输出进入 CP0 后的准确含义

### 13.1 机器态两路

在 `ct_cp0_regs.v` 中：

```verilog
mtip = biu_cp0_mt_int;
msip = biu_cp0_ms_int;
```

这表示机器定时器和软件中断输入直接形成对应 pending 值。随后仍需与 `mtie/msie`、全局中断条件和当前特权态组合，才形成可选择中断。

### 13.2 监管态两路

```verilog
stip = (biu_cp0_st_int && clintee) || stip_reg;
ssip = (biu_cp0_ss_int && clintee) || ssip_reg;
```

所以 CLINT 监管态输出还受 `clintee` 控制，并与 CP0 内部软件保存位做 OR。波形分析时只看 `clint_core0_st_int` 无法解释最终 `mip.STIP`，至少还要看：

- `ct_sysio_kid.clint_core_st_int_cpu`；
- `biu_cp0_st_int`；
- `clintee`；
- `stip_reg`；
- `stip`；
- `stie` 和委托/全局使能逻辑。

### 13.3 监管态扩展不直接证明 Sstc

本模块实现内存映射 `stimecmp/stimecmph`。标准 Sstc 以 CSR 形式定义监管态比较接口。二者目标相近、接口形式不同；要判断扩展合规，需要继续核查 CP0 CSR 和整机软件可见行为。

## 14. 中断线的下游寄存采样

`ct_sysio_kid` 在 `kid_int_clk` 上把 PLIC 和 CLINT 中断各采样一拍。其局部使能同样为 `apb_clk_en`。

这一结构带来：

- CLINT 组合输出与核心看到的中断输入之间至少有一个可见寄存阶段；
- 采样只在相应使能有效的时钟沿发生；
- 复位把该级中断寄存器清零。

但它只有单级寄存器。除非系统时钟关系和约束另有保证，否则不能把它描述成通用意义上的双触发器异步同步器。

## 15. 时钟门控的实现边界

### 15.1 `clint_clk`

```text
clk_in    = forever_apbclk
local_en  = psel_clint || perr_clint || pready_clint
module_en = ciu_clint_icg_en
scan_en   = pad_yy_icg_scan_en
```

该使能表达式使一次事务从选择出现到应答结束期间保持 APB 逻辑可运行。

### 15.2 `mtime_clk`

```text
clk_in    = forever_cpuclk
local_en  = apb_clk_en
module_en = ciu_clint_icg_en
scan_en   = pad_yy_icg_scan_en
```

它只驱动 `clint_mtime_reg`。

### 15.3 RTL 意图和当前编译模型

通用 `gated_clk_cell.v` 的行为取决于宏：

```text
C910_USE_TSMC28_ICG 已定义 -> 例化特定 ICG 单元
未定义                  -> clk_out = clk_in
```

因此：

- 从结构上可以讨论局部/模块/scan 使能的门控意图；
- 在默认 pass-through 仿真中，输出时钟波形可能不会停；
- 即使时钟不物理停，时序块内部的 `if (apb_clk_en)` 仍限制 `clint_mtime_reg` 更新；
- 功耗收益不能由源 RTL 结构单独量化。

## 16. 复位行为逐项核对

| 状态 | 复位值 | 直接效果 |
|---|---:|---|
| `pready_clint` | 0 | 复位期间不应答 |
| `perr_clint` | 0 | 复位期间不报事务错误 |
| `msip0/1_reg` | 0 | 机器软件中断输出低 |
| `ssip0/1_reg` | 0 | 监管软件中断输出低 |
| 比较值高低半部 | 全 1 | 组合阈值为 64 位最大值 |
| `clint_mtime_reg` | 0 | CLINT 本地时间样本从零开始 |

上游 `ct_sysio_top.ccvr` 没有显式复位分支，不应被包括在“CLINT 全部时间路径都复位为零”的结论中。

## 17. 建议的功能验证点

### 17.1 APB

- 合法读、合法写分别验证 SETUP 和 ACCESS 时序；
- 每个空洞地址验证 `acc_err/perr_clint`；
- hart2/3 预留地址验证非法；
- U/S/M 三个有效 `pprot` 编码覆盖 M/S 两个地址区；
- 专门覆盖保留编码 `10` 的非对称行为；
- 错误写验证寄存器不更新；
- 非法读验证软件不依赖 `prdata` 的 `x` 值。

### 17.2 软件中断

- 写 1 后持续为高；
- 无写事务时保持；
- 写 0 后清除；
- 高 31 位写入不影响结果；
- hart0 和 hart1 地址互不串扰；
- sysio_kid 采样延迟与 `apb_clk_en` 的关系。

### 17.3 定时器

- `time < cmp`、`time == cmp`、`time > cmp` 三个边界；
- 最大值比较；
- 时间样本不更新时中断关系保持；
- 高低半部分别写入时的中间比较值；
- 写未来阈值后已有高电平清除；
- `clintee=0/1` 对 STIP/SSIP 而非 CLINT 原始输出的影响。

## 18. 用一句伪代码概括模块

```text
on APB SETUP edge:
    ready_next = selected
    error_next = selected && (illegal_address || illegal_privilege)

on APB ACCESS edge:
    if selected && write && privilege_allowed && address_matches:
        selected_register = write_data

on enabled CPU-derived mtime sample edge:
    sampled_mtime = sysio_mtime

continuous:
    ms_int = msip
    ss_int = ssip
    mt_int = sampled_mtime >= mtimecmp
    st_int = sampled_mtime >= stimecmp
```

这段伪代码保留了本模块最关键的时序边界：应答生成、寄存器写入、时间采样和中断组合输出是四类不同事件。
