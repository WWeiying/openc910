# C910 IU 学习文档索引

IU（Integer Unit，整数执行单元）是 C910 乱序核中**整数指令的执行后端**。
它从 IDU 的 RF 阶段接收已读好操作数的指令，完成 ALU 运算、分支执行与误预测检测、
乘法、除法、CSR/特殊指令执行，并通过结果总线（RBUS）写回 / 前递，通过完成总线（CBUS）
向 RTU 汇报指令完成与异常。

> IU 共 13 个 RTL 文件，约 1.2 万行，位于 `C910_RTL_FACTORY/gen_rtl/iu/rtl/`。
> 在 C910 的 8 条执行管线中，IU 占据 **Pipe0（ALU0+DIV+SPECIAL）、Pipe1（ALU1+MULT）、Pipe2（BJU）** 三条。

## 目录结构

| 文件 | 内容 | 对应 RTL |
|------|------|----------|
| [00_iu_overview.md](00_iu_overview.md) | 总体架构、三条管线、EX1-EX4 流水、数据流全景 | ct_iu_top.v |
| **执行单元** | | |
| [01_alu.md](01_alu.md) | 双发射 ALU：加减/逻辑/移位/比较、长短指令时序 | ct_iu_alu.v |
| [02_bju.md](02_bju.md) | 分支跳转单元：条件/间接分支执行、误预测检测、IFU 重定向闭环 | ct_iu_bju.v |
| [03_bju_pcfifo.md](03_bju_pcfifo.md) | PCFIFO：分支 PC/预测信息的载体，IFU 创建 → BJU 检查 → RTU 弹出 | ct_iu_bju_pcfifo.v + entry + read_entry |
| [04_mult.md](04_mult.md) | 乘法/乘累加单元：3 拍流水、MLA 前递链 | ct_iu_mult.v |
| [05_div.md](05_div.md) | 除法单元：SRT Radix-16 迭代除法、提前结束优化 | ct_iu_div.v + div_entry + div_srt_radix16 |
| [06_special.md](06_special.md) | 特殊指令单元：CSR 读、vsetvli、异常入口 | ct_iu_special.v |
| **总线** | | |
| [07_cbus.md](07_cbus.md) | 完成总线：三条管线的 cmplt/iid/异常向 RTU 汇总 | ct_iu_cbus.v |
| [08_rbus.md](08_rbus.md) | 结果总线：EX1 前递 + EX2 写回的仲裁与扩展编码 | ct_iu_rbus.v |

## 推荐学习路径

```
第一轮（建立全局观）
  └── 00_iu_overview.md            ← 必读，理解三条管线和 EX 各级时序

第二轮（主执行通路）
  └── 01_alu.md → 08_rbus.md       ← ALU 算完结果如何前递/写回
  └── 07_cbus.md                   ← 结果之外，"完成"信号如何报给 RTU

第三轮（分支闭环 —— 与 IFU/RTU 协同的核心）
  └── 03_bju_pcfifo.md → 02_bju.md ← 先懂数据结构（PCFIFO），再看检查逻辑

第四轮（长延迟单元）
  └── 04_mult.md → 05_div.md → 06_special.md
```

## 与已有文档的衔接

- **上游**：IDU 的发射与读寄存器见 `doc/idu/`（特别是 13_is_aiq / 14_is_biq 发射，
  19_rf_dp 读数，20_rf_fwd 前递网络——IU 的 RBUS 正是前递网络的数据源）。
- **分支闭环**：IFU 侧的预测机制见 `doc/ifu/`（03_btb / 04_bht / 05_ras）和
  `doc/branch_prediction.md`；本目录的 02_bju / 03_bju_pcfifo 讲"检查与纠错"的另一半。
- **下游**：完成/退休见 RTU 文档 `doc/rtu/`。
