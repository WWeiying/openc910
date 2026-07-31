# C910 HAD 硬件调试子系统学习文档索引

> 公开 RTL没有给出 HAD 缩写的正式展开。当前实现使用项目私有 HACR/调试寄存器/注入通路，不是 RISC-V Debug Module/DMI 寄存器实现；`id_reg[11:8]=1011` 的邻近注释标为 version 2.3。
> RTL 源目录：`C910_RTL_FACTORY/gen_rtl/had/rtl/`（共 22 个 `.v` 文件）。

## 目录结构

| 文件 | 内容 | 覆盖 RTL | 适合阶段 |
|------|------|----------|----------|
| [00_had_overview.md](00_had_overview.md) | 总览：停核→注入→窥探→恢复四步法、与 RISC-V Debug 区别、HACR 寻址、多核 halt-all、整体数据流 | 全子系统 | 先读，建立全局观 |
| [01_had_jtag.md](01_had_jtag.md) | JTAG 接入层：TAP 状态机、IO 引脚、串行移位、16 位 HACR 译码、core 选择、跨时钟域同步 | sm / io / serial / ir / private_ir / sync_3flop | 第一个精读，搞清"调试器怎么寻址" |
| [02_had_breakpoint.md](02_had_breakpoint.md) | 断点：IFU/LSU 地址比较、A/B 两套 BC/MBC 过滤、mask/RC 精确语义、split pending、non-IRV 退休元数据路径 | ct_had_bkpt / ct_had_nirv_bkpt，并追到 IFU/LSU/RTU | 理解命中、请求、RTU 接受的分层 |
| [03_had_ctrl_ddc.md](03_had_ctrl_ddc.md) | 调试控制：多源请求、SQC、go/ex、WBBR 双向数据、退出；DDC 9 态 FSM 生成 addi/addi/sd 连续写内存 | ct_had_ctrl / ct_had_ddc_ctrl / ct_had_ddc_dp | 核心，区分请求、执行、退休与完成 |
| [04_had_trace.md](04_had_trace.md) | 运行记录与跨核：PCFIFO、OTC 倒计数、当前双核 event/ETM、PIPEFIFO、单份快照分片读窗 | pcfifo / trace / etm / etm_if / event / dbg_info | 理解记录、触发、快照三种不同机制 |
| [05_had_regs.md](05_had_regs.md) | 寄存器堆与顶层：HCR/HSR/CPUSCR、版本 ID、断点基址/MBIR、RSR/DMS、common_top/private_top 结构、多核掩码 | regs / common_regs / common_top / private_top | 收尾，把所有寄存器字段对齐 |

## 推荐学习路径

```
第一轮（建立全局观）
  └── 00_had_overview.md      —— 四步法 + HACR 寻址 + 与 RISC-V 的区别

第二轮（接入与控制主线）
  └── 01_had_jtag  →  03_had_ctrl_ddc      —— 串行事务怎么跨域 → 请求/注入/连续 store/退出

第三轮（断点与追踪）
  └── 02_had_breakpoint  →  04_had_trace   —— 地址命中与停核链 → PCFIFO/OTC/双核 event

第四轮（对齐所有寄存器）
  └── 05_had_regs                          —— HCR/HSR/CPUSCR/ID/RSR/DMS 字段全表
```

## 一句话抓住 HAD

> 教学主线：**提出停核请求并等待 RTU 确认** → **注入受控指令** → **通过 WBBR/PC/IR/CSR 交换可达状态** → **请求退出并观察 IFU/RTU 恢复**。
>
> 这是一条理解主线，不代表 HAD 内存在一个统一四状态 FSM，也不表示所有架构/微结构状态天然可见。
