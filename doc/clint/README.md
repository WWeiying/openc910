# C910 CLINT 学习文档索引

CLINT（Core Local Interruptor，核局部中断器）负责产生 RISC-V 的两类"核本地"中断：**定时器中断**（mtime 追上 mtimecmp）与**软件中断 / 核间中断 IPI**（往 msip 写 1）。OpenC910 的 CLINT 还实现了 S 态 stimecmp/ssip（Sstc 思想），服务 2 个 hart，对每个核输出 mt/ms/st/ss 共 4 类中断。

## 目录结构

| 文件 | 内容 | 适合阶段 |
|------|------|----------|
| [00_clint_overview.md](00_clint_overview.md) | CLINT 总体职责、系统位置、mtime/mtimecmp/msip 数据流、与 PLIC 分工、与 cp0 中断接口链路、设计决策汇总 | 先读，建立全局观 |
| [01_clint_func.md](01_clint_func.md) | `ct_clint_func.v` 逐模块详解：APB 接口、地址译码、特权控制、寄存器主体、读 MUX、mtime 采样与中断比较、时钟门控 | 精读，落到每行 RTL |

> RTL 位置：`C910_RTL_FACTORY/gen_rtl/clint/rtl/`
> - `ct_clint_top.v`（~136 行）：顶层壳，仅例化 `ct_clint_func`，无功能逻辑。
> - `ct_clint_func.v`（~520 行）：全部功能逻辑。

## 推荐学习路径

```
第一轮（建立全局观）
  └── 00_clint_overview.md
        理解：CLINT 干什么、mtime/mtimecmp/msip 三类中断怎么流动、
              与 PLIC 如何分工、8 根中断线如何经 sysio_kid 到达 cp0

第二轮（精读功能体）
  └── 01_clint_func.md
        理解：APB 两拍应答、acc_err/priv_err 双重检查、
              mreg_wen/sreg_wen 特权门、16 个寄存器的对称结构、
              !(cmp > mtime) 比较逻辑、两路门控时钟

第三轮（顺藤摸瓜，可选）
  └── 沿 00 文档第 6 节的链路追代码：
      ct_clint_top.v → ct_sysio_top.v → ct_sysio_kid.v(同步打拍)
      → sysio_piu_*_int → PIU/CIU → ct_cp0_regs.v(mip CSR)
```

## 一页速查

| 主题 | 关键行号（ct_clint_func.v） |
|------|------|
| 地址 parameter（4 区 × 多 hart） | `:148-174` |
| acc_err 地址白名单 | `:247-271` |
| priv_err 特权检查 | `:273-274` |
| mreg_wen / sreg_wen | `:216-217` |
| mtimecmp 比较值复位全 1 | `:313`,`:323` 等 |
| msip 软件中断寄存器 | `:300-307` |
| mtime 采样 | `:485-493` |
| 定时器中断 `!(cmp > mtime)` | `:498-511` |
| 软件中断输出 | `:495-496`,`:505-506` |
| 时钟门控（clint_clk / mtime_clk） | `:180-188`,`:467-475` |
