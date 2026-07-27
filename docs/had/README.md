# C910 HAD（玄铁硬件调试单元）学习文档索引

> HAD = Hardware Assisted Debug，玄铁/C-SKY **自有调试协议（HAD v2.3）**，并非 RISC-V Debug Spec。
> RTL 源目录：`C910_RTL_FACTORY/gen_rtl/had/rtl/`（共 22 个 `.v` 文件）。

## 目录结构

| 文件 | 内容 | 覆盖 RTL | 适合阶段 |
|------|------|----------|----------|
| [00_had_overview.md](00_had_overview.md) | 总览：停核→注入→窥探→恢复四步法、与 RISC-V Debug 区别、HACR 寻址、多核 halt-all、整体数据流 | 全子系统 | 先读，建立全局观 |
| [01_had_jtag.md](01_had_jtag.md) | JTAG 接入层：TAP 状态机、IO 引脚、串行移位、16 位 HACR 译码、core 选择、跨时钟域同步 | sm / io / serial / ir / private_ir / sync_3flop | 第一个精读，搞清"调试器怎么寻址" |
| [02_had_breakpoint.md](02_had_breakpoint.md) | 断点：2 个硬件断点（BABA/BAMA 基址掩码 + RC 取反 + BC 条件 + 8 位过 N 次计数）+ 不可撤销断点 | ct_had_bkpt / ct_had_nirv_bkpt | 理解断点机制 |
| [03_had_ctrl_ddc.md](03_had_ctrl_ddc.md) | 调试控制与 DDC：四类停核请求、SQC 链、go 注入、WBBR 回写、退出/pcload、HSR 更新；DDC 9 态 FSM 硬件合成 mv/sd 搬内存 | ct_had_ctrl / ct_had_ddc_ctrl / ct_had_ddc_dp | 核心，搞清"停核/注入/窥探/恢复怎么实现" |
| [04_had_trace.md](04_had_trace.md) | Trace 与跨核：16 项 PC-FIFO、OTC 采样计数、ETM 多核交叉触发 halt-all、PIPEFIFO、debug-info 快照 | pcfifo / trace / etm / etm_if / event / dbg_info | 理解轨迹追踪与多核协同 |
| [05_had_regs.md](05_had_regs.md) | 寄存器堆与顶层：HCR/HSR/CPUSCR、版本 ID、断点基址/MBIR、RSR/DMS、common_top/private_top 结构、多核掩码 | regs / common_regs / common_top / private_top | 收尾，把所有寄存器字段对齐 |

## 推荐学习路径

```
第一轮（建立全局观）
  └── 00_had_overview.md      —— 四步法 + HACR 寻址 + 与 RISC-V 的区别

第二轮（接入与控制主线）
  └── 01_had_jtag  →  03_had_ctrl_ddc      —— 调试器怎么寻址 → 停核/注入/窥探/恢复/搬内存

第三轮（断点与追踪）
  └── 02_had_breakpoint  →  04_had_trace   —— 硬件断点 → PC-FIFO/OTC/多核 halt-all

第四轮（对齐所有寄存器）
  └── 05_had_regs                          —— HCR/HSR/CPUSCR/ID/RSR/DMS 字段全表
```

## 一句话抓住 HAD

> 调试 = **停核**（halt）→ **注入指令**（让 CPU 替我干活）→ **借指令把内部状态搬到 WBBR/CPUSCR 再移出**（窥探/修改）→ **恢复现场并继续**（resume）。
>
> HAD 的所有寄存器（IR/WBBR/PC/CSR/HCR/HSR）与状态机（TAP/DDC FSM/ctrl FSM）都为这四步服务。
