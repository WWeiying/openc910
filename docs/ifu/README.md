# C910 IFU 学习文档索引

## 目录结构

| 文件 | 内容 | 适合阶段 |
|------|------|----------|
| [00_ifu_overview.md](00_ifu_overview.md) | IFU 总体架构、三级流水、全模块串讲、完整数据流 | 先读，建立全局观 |
| [01_pcgen.md](01_pcgen.md) | PC 生成单元：10 优先级 MUX、inc_pc、Way Predict、Cancel 层次 | 第一个精读 |
| [02_l0_btb.md](02_l0_btb.md) | L0 BTB：16 项寄存器式热点目标表，全项并行比较、命中向量打一拍 | 配合 pcgen |
| [03_btb.md](03_btb.md) | BTB：512 行×4 个固定位置槽，Refill Buffer、读后保持与 INV 机制 | 分支预测核心 |
| [04_bht.md](04_bht.md) | BHT：Bi-Mode 预测器，双 GHR，Write Buffer，折叠索引 | 方向预测核心 |
| [05_ras.md](05_ras.md) | RAS：12 项投机栈+6 项退休恢复副本，5 位环形指针 | 函数返回预测 |
| [06_icache_if.md](06_icache_if.md) | I-Cache 接口：5 个 SRAM，Bank 精确激活，FIFO 替换，Predecode Array | Cache 访问控制 |
| [07_precode.md](07_precode.md) | 预解码：128→32bit，分支检测，BRY 边界位，RVC 处理 | 配合 icache_if |
| [08_ifctrl.md](08_ifctrl.md) | IF 级控制：stall 汇聚，INV 状态机，L0 BTB 协调 | IF 级流水线管理 |
| [09_ifdp.md](09_ifdp.md) | IF 级数据通路：tag 比较，BRY 缓存，BTB 4 路解码 | IF 级数据处理 |
| [10_ipctrl.md](10_ipctrl.md) | IP 级控制：分支碰撞检测，Miss 处理，chgflw 生成 | IP 级流水线管理 |
| [11_ipdp.md](11_ipdp.md) | IP 级数据通路：H0~H8 指令解析，目标 PC 选择，BHT 融合 | IP 级数据处理 |
| [12_ibctrl.md](12_ibctrl.md) | IB 级控制：IBUF/LBUF 仲裁，RAS push/pop，Indirect BTB | IB 级流水线管理 |
| [13_ibuf.md](13_ibuf.md) | 指令缓冲队列：32 项（每项 1 个 16 位 half-word），Bypass 路径，特殊指令标记 | 取指-译码解耦 |
| [14_lbuf.md](14_lbuf.md) | 循环缓冲：全零 IDLE 加六个独热工作状态、16 项半字 Entry、BHT 集成 | 循环性能优化 |
| [15_addrgen.md](15_addrgen.md) | 分支地址生成：PC-relative 目标复算与纠错、BTB refill 请求、L0 BTB 误预测项失效 | 分支确认后处理 |
| [16_l1_refill.md](16_l1_refill.md) | L1 Cache 填充：11 个编码状态、4×128-bit WRAP、关键块旁路、INV 冲突与单 demand-refill 上下文 | Cache Miss 处理 |
| [17_ind_btb.md](17_ind_btb.md) | 间接跳转预测：路径历史/GHR 混合索引、256 项目标表、退休恢复 | 间接控制流 |
| [18_sfp.md](18_sfp.md) | 推测失败预测：12 项全相联表、load/store no-spec 与 VL 预测反馈 | 存储相关投机 |
| [19_ipb.md](19_ipb.md) | 指令预取缓冲：下一行预取、4×128-bit PBUF、refill/BIU 仲裁 | 前端存储层次 |
| [20_aux_control.md](20_aux_control.md) | PCFIFO 接口、复位/异常向量控制和 IFU 调试快照 | 跨模块控制 |

## 推荐学习路径

```
第一轮（建立全局观）
  └── 00_ifu_overview.md

第二轮（前端预测体系）
  └── 01_pcgen → 02_l0_btb → 03_btb → 04_bht → 05_ras

第三轮（Cache 访问）
  └── 06_icache_if → 07_precode → 16_l1_refill

第四轮（流水级控制与数据通路）
  └── 08_ifctrl → 09_ifdp → 10_ipctrl → 11_ipdp → 12_ibctrl

第五轮（缓冲与优化）
  └── 13_ibuf → 14_lbuf → 15_addrgen

第六轮（容易遗漏的跨模块机制）
  └── 17_ind_btb → 18_sfp → 19_ipb → 20_aux_control
```
