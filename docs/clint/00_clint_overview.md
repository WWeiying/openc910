# C910 CLINT 总体架构与行为

> 主要 RTL：
>
> - `C910_RTL_FACTORY/gen_rtl/clint/rtl/ct_clint_top.v`
> - `C910_RTL_FACTORY/gen_rtl/clint/rtl/ct_clint_func.v`
> - `C910_RTL_FACTORY/gen_rtl/cpu/rtl/ct_sysio_top.v`
> - `C910_RTL_FACTORY/gen_rtl/cpu/rtl/ct_sysio_kid.v`
>
> 本文首先说明 RTL 中能够直接确认的实现事实，再补充体系结构含义。文中把“请求出现”“总线事务被接受”“寄存器在时钟沿更新”“中断成为 pending”“处理器实际进入中断”视为不同事件，不把它们合并成一句“访问后触发中断”。

## 1. CLINT 在这套 RTL 中负责什么

OpenC910 的 CLINT 是一个 APB 从设备。它服务当前实现中的两个 hart，并完成三类工作：

1. 保存每个 hart 的机器态和监管态软件中断寄存器；
2. 保存每个 hart 的机器态和监管态定时器比较值；
3. 对系统提供的时间值进行采样和比较，输出软件中断、定时器中断电平。

每个已实现 hart 有四根 CLINT 输出：

| 输出 | 直接来源 | 体系结构方向 |
|---|---|---|
| `clint_core*_ms_int` | `msip*_reg` | 机器软件中断 pending 输入 |
| `clint_core*_mt_int` | `clint_mtime_reg >= mtimecmp*` | 机器定时器中断 pending 输入 |
| `clint_core*_ss_int` | `ssip*_reg` | 监管软件中断 pending 输入 |
| `clint_core*_st_int` | `clint_mtime_reg >= stimecmp*` | 监管定时器中断 pending 输入 |

这里的“输出有效”只表示一根**电平型中断请求线**为高。它还不等于处理器已经接受中断，更不等于流水线已经跳到中断入口。CP0 后续还要检查 pending 位、局部使能位、全局中断使能、当前特权级和委托关系。

### 1.1 CLINT 不负责的工作

CLINT 不自行递增 `mtime`。系统时间来自：

```text
pad_cpu_sys_cnt[63:0]
  -> ct_sysio_top.ccvr
  -> sysio_clint_mtime[63:0]
  -> ct_clint_func.clint_mtime_reg
  -> 四个 64 位比较器
```

因此，CLINT 的角色是“采样时间、保存阈值、产生电平”，不是“实现系统计数器”。

CLINT 也不保存核间消息正文。所谓 IPI，是软件向另一个 hart 的 `msip` 或 `ssip` 寄存器写 1，使目标 hart 的软件中断线保持为高；消息内容、发送队列和确认协议都需要软件另行实现。

## 2. 模块层次和系统位置

```text
CPU load/store
  -> CIU APB 接口
  -> psel_clint/paddr/pprot/pwrite/pwdata/penable
  -> ct_clint_top
       -> ct_clint_func
          - APB 应答
          - 软件中断寄存器
          - 定时器比较寄存器
          - 时间采样与比较
  -> clint_core{0,1}_{ms,mt,ss,st}_int
  -> ct_sysio_kid 中的一拍寄存采样
  -> sysio_piu{0,1}_*_int
  -> CIU/PIU 连接
  -> core BIU
  -> CP0 pending、使能、委托和优先级判断
  -> RTU 发起中断重定向
```

`ct_clint_top` 只按名称一一连接端口并例化 `ct_clint_func`。当前 RTL 没有在这一层实现额外寄存器、同步器、译码器或仲裁器。可以把它称为结构包装层，但不能仅凭这种写法断言它专门用于 scan 或物理实现胶水。

## 3. 实际配置和参数预留

`ct_clint_func.v` 定义了 hart0 到 hart3 的地址参数，但地址合法性白名单、寄存器实体和中断输出只覆盖 hart0、hart1。

这三件事必须分开理解：

| 层次 | RTL 状态 |
|---|---|
| 地址名字 | hart0 至 hart3 都定义了 parameter |
| 实际寄存器 | 只有 hart0、hart1 |
| 合法地址译码 | 只有 hart0、hart1 |

所以 `MSIP2`、`MTIMECMP2` 等 parameter 的存在只是代码中的地址预留，不表示当前综合实例支持四个 hart。访问这些地址会进入 `acc_err` 的 `default` 分支，而不是访问一个隐藏或未连接的寄存器。

## 4. 寄存器映射

CLINT 在已经由上级 `psel_clint` 选中的前提下，仅使用 `paddr[15:0]` 进行本地地址译码。

| 偏移 | 寄存器 | 有效位 | RTL 允许的写入特权 | 复位值 | 作用 |
|---|---|---:|---|---:|---|
| `0x0000` | `MSIP0` | bit 0 | M | `0` | hart0 机器软件中断电平 |
| `0x0004` | `MSIP1` | bit 0 | M | `0` | hart1 机器软件中断电平 |
| `0x4000` | `MTIMECMP0` | `[31:0]` | M | `0xffffffff` | hart0 机器定时阈值低半部 |
| `0x4004` | `MTIMECMPH0` | `[31:0]` | M | `0xffffffff` | hart0 机器定时阈值高半部 |
| `0x4008` | `MTIMECMP1` | `[31:0]` | M | `0xffffffff` | hart1 机器定时阈值低半部 |
| `0x400c` | `MTIMECMPH1` | `[31:0]` | M | `0xffffffff` | hart1 机器定时阈值高半部 |
| `0xc000` | `SSIP0` | bit 0 | M 或 S | `0` | hart0 监管软件中断电平 |
| `0xc004` | `SSIP1` | bit 0 | M 或 S | `0` | hart1 监管软件中断电平 |
| `0xd000` | `STIMECMP0` | `[31:0]` | M 或 S | `0xffffffff` | hart0 监管定时阈值低半部 |
| `0xd004` | `STIMECMPH0` | `[31:0]` | M 或 S | `0xffffffff` | hart0 监管定时阈值高半部 |
| `0xd008` | `STIMECMP1` | `[31:0]` | M 或 S | `0xffffffff` | hart1 监管定时阈值低半部 |
| `0xd00c` | `STIMECMPH1` | `[31:0]` | M 或 S | `0xffffffff` | hart1 监管定时阈值高半部 |

### 4.1 “写入特权”不是完整的软件可见权限模型

上表直接描述 `mreg_wen` 和 `sreg_wen`。对于 RTL 认可的三个 `pprot` 编码：

```text
00 -> user_mode
01 -> supv_mode
11 -> mach_mode
```

- M 区 `0x0xxx/0x4xxx` 只允许 `11`；
- S 区 `0xcxxx/0xdxxx` 允许 `01` 或 `11`；
- `00` 访问 S 区会产生权限错误。

`pprot=2'b10` 没有被识别为 U/S/M 中任何一种模式。这个保留编码存在一个细节：访问 S 区时 `priv_err` 不会因为它不是 `user_mode` 而置位，但 `sreg_wen` 也不会成立，因此写应答可能没有报权限错，寄存器却不更新。正常系统不应产生该编码；文档也不能把当前布尔逻辑泛化成“任何非 M/S 编码都可靠报错”。

## 5. 一次 APB 写如何真正生效

把 APB 写寄存器精确拆开如下：

1. **SETUP 阶段**：主设备使 `psel_clint=1`、`penable=0`，并给出稳定地址、写属性、数据和 `pprot`。
2. **组合检查**：`acc_err` 根据地址白名单判断地址是否合法，`priv_err` 根据地址区和 `pprot` 判断权限。
3. **SETUP 末端时钟沿**：`pready_clint` 被置 1；若检查失败，`perr_clint` 也被置 1。
4. **ACCESS 阶段**：主设备保持选择和控制，并使 `penable=1`。此时 `clint_wen = psel_clint && pwrite && penable`。
5. **ACCESS 末端时钟沿**：若寄存器专用写使能成立，目标寄存器采样 `pwdata`。
6. **时钟沿之后**：软件中断输出或定时器比较结果根据新寄存器值组合更新。

因此，SETUP 阶段看到地址并不等于寄存器已经更新；`pready_clint` 被置位也不等于写数据在同一个 SETUP 时钟沿进入目标寄存器。真正的状态更新条件还包括 ACCESS 阶段和专用写使能。

按标准两阶段 APB 时序使用时，这个实现会在紧随 SETUP 的 ACCESS 阶段给出 ready，因而不额外插入等待周期。这里的“无额外等待”不应误写为“单拍完成”，因为协议本身仍有 SETUP 和 ACCESS 两个阶段。

## 6. 软件中断：寄存器保持的电平

以 hart0 的机器软件中断为例：

```verilog
if (!cpurst_b)
  msip0_reg <= 1'b0;
else if (msip0_wen)
  msip0_reg <= pwdata[0];

assign clint_core0_ms_int = msip0_reg;
```

它具有以下精确语义：

- 只有 `pwdata[0]` 被保存；高 31 位被忽略；
- 读回时高 31 位补零；
- 写 1 后输出持续为高，而不是只产生一个周期的脉冲；
- 写 0 后输出持续为低；
- 中断处理器读取该寄存器本身不会自动清零；
- core0 向 `MSIP1` 写 1 可以向 hart1 发出机器软件中断，但“这是一个 IPI”是软件使用方式，不是硬件内部存在消息传送器。

`ssip` 的寄存器行为相同，但它对应监管软件中断路径，并允许有效的 S/M `pprot` 写入。

## 7. 定时器中断：采样值、阈值和电平

定时器条件在 RTL 中写为：

```verilog
assign clint_core0_mt_int =
       !({mtimecmph0_reg, mtimecmp0_reg} > clint_mtime_reg);
```

对于无符号 64 位操作数，它在逻辑上等价于：

```text
clint_mtime_reg >= {mtimecmph0_reg, mtimecmp0_reg}
```

原写法只是布尔等价表达。没有综合报告时，不能断言它必然比直接写 `>=` 少一个比较器或面积更小；综合器通常会把等价关系归一化。

### 7.1 这是电平条件，不是“到点发一个脉冲”

当采样时间大于等于比较值时，输出保持为高。软件通常要把比较值改到未来，才能使输出重新为低。CLINT 内没有“中断已经服务过”的自动清除状态。

比较寄存器复位为 `64'hffff_ffff_ffff_ffff`。这使复位后的绝大多数正常时间值都小于阈值，避免立即拉高定时器中断。不过，“最大值”不等于数学意义上的永不触发：当采样时间恰好到达最大值时，`mtime >= cmp` 仍然成立。

### 7.2 比较的是采样时间，不一定是引脚上的当前值

存在两级时间寄存：

1. `ct_sysio_top.ccvr` 在 `sysio_clk` 有效沿、且 `axim_clk_en=1` 时采样 `pad_cpu_sys_cnt`；
2. `ct_clint_func.clint_mtime_reg` 在 `mtime_clk` 有效沿、且 `apb_clk_en=1` 时采样 `sysio_clint_mtime`。

所以比较器看到的是 `clint_mtime_reg`，而不是直接看到当前 `pad_cpu_sys_cnt`。中断相对于外部计数值的可见延迟取决于两次采样使能和相关时钟。仅从这些模块不能证明外部 `pad_cpu_sys_cnt` 与 `forever_cpuclk` 的相位关系，也不能把这条路径称为已经完成严格异步 CDC 证明。

### 7.3 32 位 APB 写 64 位阈值的中间状态

低 32 位和高 32 位是两个独立寄存器。硬件没有影子寄存器，也没有“两个半部写完再一起提交”的原子更新机制。第一次写完成后，比较器立即使用“新的一半 + 旧的一半”。

这会带来两个重要后果：

- 更新过程中可能暂时形成一个已经过期的阈值，从而短暂拉高中断；
- 更新过程中也可能暂时形成一个很远的阈值，从而暂时拉低原有中断。

对于单调递增时间和未来目标值，一种常见的软件编程思路是：

```text
先把低半部写成 0xffffffff
再写目标高半部
最后写目标低半部
```

这样做是软件规避中间值误触发的方法，不是 CLINT RTL 自身提供的原子保证。若系统软件已有平台专用访问函数，应以该软件约定为准。

## 8. 监管态比较寄存器与 Sstc 的关系

这份 RTL 确实提供了：

- S/M 可写的内存映射 `stimecmp/stimecmph`；
- S/M 可写的内存映射 `ssip`；
- 对应的 `clint_core*_st_int` 和 `clint_core*_ss_int`。

它们减少了监管态软件完全依赖机器态代设定时阈值的需要，设计目标与“让 S 态直接管理定时器”相近。

但不能据此直接写成“OpenC910 实现了标准 Sstc 扩展”。标准 Sstc 的软件接口是监管态 CSR `stimecmp`，RV32 还使用 `stimecmph`；这里展示的是 CLINT 中的内存映射寄存器。是否符合某一版扩展规范还需要核查 CSR、异常和软件可见行为等完整实现，单凭 `ct_clint_func.v` 不能得出合规结论。

因此，准确称呼是：

> C910 CLINT 实现了内存映射的监管态软件中断和定时器比较扩展，其目标与 S 态直接管理定时器相近；本文不把它等同于标准 Sstc 合规实现。

## 9. 中断到 CP0 的实际传播

### 9.1 `ct_sysio_kid` 是一拍寄存采样

每个 hart 的 CLINT 四根输出在 `ct_sysio_kid` 中由 `kid_int_clk` 采样一次：

```verilog
clint_core_ms_int_cpu <= clint_core_ms_int;
clint_core_ss_int_cpu <= clint_core_ss_int;
clint_core_mt_int_cpu <= clint_core_mt_int;
clint_core_st_int_cpu <= clint_core_st_int;
```

`kid_int_clk` 来自 `forever_cpuclk` 的门控路径，局部使能是 `apb_clk_en`。这一拍能提供寄存隔离和时序对齐，但单个寄存器级不能自动等价为标准双触发器异步同步器，也不能仅凭模块名证明亚稳态风险已经完整处理。

### 9.2 CIU/PIU 的相关连接是直接传递

`ct_piu_other_io_sync.v` 对这些中断使用直接 `assign`，例如：

```verilog
assign ciu_ibiu_mt_int = sysio_piu_mt_int;
```

因此，不应在文档中凭空增加“CIU 又同步若干拍”的描述。真正可见的寄存采样级是前述 `ct_sysio_kid`，其后的相关路径主要是层次连接。

### 9.3 CLINT 输出与 `mip` 位不是完全相同的布尔关系

CP0 中的关键关系是：

```text
MEIP = BIU 机器外部中断
MTIP = BIU 机器定时器中断
MSIP = BIU 机器软件中断

SEIP = BIU 监管外部中断 OR CP0 软件保存位
STIP = (BIU 监管定时器中断 AND clintee) OR CP0 软件保存位
SSIP = (BIU 监管软件中断 AND clintee) OR CP0 软件保存位
```

所以：

- CLINT 的 `mt_int`、`ms_int` 直接参与 MTIP、MSIP；
- CLINT 的 `st_int`、`ss_int` 还受 C910 扩展控制位 `clintee` 门控；
- STIP、SSIP 还可能由 CP0 内部可写 pending 位拉高；
- CLINT 不产生 SEIP/MEIP，它们来自 PLIC 等外部中断路径。

### 9.4 pending 不等于已经取中断

CP0 还会继续形成：

```text
pending
  AND mie/sie 中对应局部使能
  AND 当前特权级下适用的全局使能
  AND 委托/非委托条件
  -> 中断候选
  -> 优先级选择
  -> RTU 重定向
```

因此，波形中看到 `clint_core0_mt_int=1` 而 PC 尚未跳到中断入口，不一定是故障。必须同时检查 `mip.MTIP`、`mie.MTIE`、当前特权态、全局 `MIE`、委托和更高优先级异常/中断。

## 10. CLINT 与 PLIC 的边界

| 维度 | CLINT | PLIC |
|---|---|---|
| 典型来源 | 时间阈值、软件写 pending | 外部设备中断源 |
| 输出性质 | 每 hart 固定的 mt/ms/st/ss 电平 | 经过优先级和阈值选择的外部中断电平 |
| CP0 方向 | MTIP、MSIP、STIP、SSIP | MEIP、SEIP |
| 消除 pending 的常见方式 | 清软件位或把比较值移到未来 | 按 PLIC claim/complete 等平台协议处理 |

两者都可能通过 APB 配置，但功能不是上下级关系。CLINT 不负责 PLIC 仲裁，PLIC 也不负责 `mtimecmp`。

## 11. 时钟、门控和复位边界

### 11.1 两条时钟路径

| 时钟 | 输入 | RTL 局部使能 | 直接驱动 |
|---|---|---|---|
| `clint_clk` | `forever_apbclk` | `psel_clint \|\| perr_clint \|\| pready_clint` | APB 应答寄存器、软件中断和比较寄存器 |
| `mtime_clk` | `forever_cpuclk` | `apb_clk_en` | `clint_mtime_reg` |

两个 `gated_clk_cell` 都还接收 `ciu_clint_icg_en` 和 scan 使能。这里描述的是 RTL 的门控意图。仓库中的通用 `gated_clk_cell.v` 只有定义 `C910_USE_TSMC28_ICG` 时才例化特定 ICG；否则 `clk_out` 直接连接 `clk_in`。因此，仿真波形中时钟是否真正停摆以及综合后是否节省动态功耗，取决于编译配置和目标实现，不能只看实例名字下结论。

### 11.2 复位不是整条时间源链路都清零

CLINT 自身的寄存器使用异步低有效 `cpurst_b`：

- `msip/ssip` 清零；
- `mtimecmp/stimecmp` 两个半部置全 1；
- `pready/perr` 清零；
- `clint_mtime_reg` 清零。

但是上游 `ct_sysio_top.ccvr` 的时序块没有显式复位分支。它在 `sysio_clk` 上且 `axim_clk_en=1` 时才采样 `pad_cpu_sys_cnt`。所以只能说“CLINT 内部采样寄存器复位为零”，不能扩大成“从外部计数器到 CLINT 的所有时间寄存器均复位为零”。

## 12. 阅读 RTL 时最容易混淆的概念

| 容易混淆的说法 | 更准确的理解 |
|---|---|
| “写 APB 地址就触发中断” | ACCESS 阶段的目标寄存器写使能在时钟沿被接受后，寄存器才更新；随后组合输出变化 |
| “mtime 到点产生一个中断脉冲” | 比较结果是保持型电平，只要采样时间仍不小于阈值就保持为高 |
| “比较值全 1，所以永远不会中断” | 在到达最大 64 位值前通常不触发；等于最大值时仍会触发 |
| “`!(a>b)` 比 `<=` 更省面积” | 逻辑等价；实际映射和面积必须看综合结果 |
| “sysio_kid 完成双触发器同步” | RTL 只明确显示一拍寄存采样 |
| “CLINT 输出就是最终中断” | 它只是 pending 来源之一，CP0 仍要做使能、委托和优先级判断 |
| “S 态寄存器就是标准 Sstc” | 这是内存映射实现，不能仅凭目标相近宣称标准扩展合规 |
| “定义了 hart2/3 地址，所以支持四核” | 当前白名单、寄存器和输出只实现 hart0/1 |

## 13. 观察波形时的推荐因果链

调试一次软件中断写入时，按以下顺序看：

```text
psel_clint, penable, pwrite, paddr, pprot, pwdata
  -> acc_err, priv_err
  -> pready_clint, perr_clint
  -> mreg_wen/sreg_wen
  -> msip*_wen/ssip*_wen
  -> msip*_reg/ssip*_reg
  -> clint_core*_*s_int
  -> ct_sysio_kid 中的 *_int_cpu
  -> sysio_piu*_*s_int
  -> ciu_ibiu_*s_int / biu_cp0_*s_int
  -> mip 对应位
  -> 局部与全局使能、委托、int_sel
  -> RTU 中断重定向
```

调试一次定时器中断时，按以下顺序看：

```text
pad_cpu_sys_cnt
  -> ccvr/sysio_clint_mtime
  -> clint_mtime_reg
  -> mtimecmp*/stimecmp* 两个半部
  -> 比较结果 mt_int/st_int
  -> sysio_kid 采样
  -> CP0 pending 和最终仲裁
```

这种顺序可以区分四类问题：总线写没有被接受、比较寄存器编程中间值错误、时间采样没有更新、pending 已到 CP0 但被中断控制条件屏蔽。
