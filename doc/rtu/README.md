# C910 RTU 学习文档索引

RTU（Retire Unit，退休单元）是 C910 乱序执行的**秩序守护者**：指令可以乱序
执行，但必须**按程序序退休**。RTU 维护 ROB（重排序缓冲）、PST（物理寄存器
状态表）、异常缓冲与 flush 状态机，保证精确异常和正确的寄存器回收。

> RTU 共 22 个 RTL 文件，约 3.6 万行，位于 `C910_RTL_FACTORY/gen_rtl/rtu/rtl/`。
> 最大文件 ct_rtu_pst_preg.v（8637 行）。每拍最多退休 3 条 ROB 表项，
> 每项最多折叠 3 条指令——理论退休带宽高达 9 IPC（实际受 3 表项限制）。

## 目录结构

| 文件 | 内容 | 对应 RTL |
|------|------|----------|
| [00_rtu_overview.md](00_rtu_overview.md) | 总体架构、ROB+PST+Retire 三大件、IID 体系 | ct_rtu_top.v |
| **ROB（重排序缓冲）** | | |
| [01_rob.md](01_rob.md) | 64 项 ROB：指令折叠、创建/完成/弹出、推定完成计数 | ct_rtu_rob.v / rob_entry.v |
| [02_rob_rt.md](02_rob_rt.md) | 退休读端口、**退休 PC 增量重建**（C910 特色） | ct_rtu_rob_rt.v |
| [03_rob_expt.md](03_rob_expt.md) | 单项异常缓冲：最老异常的擂台赛选择 | ct_rtu_rob_expt.v |
| **退休控制** | | |
| [04_retire.md](04_retire.md) | 退休判定、异常/中断仲裁、**flush 状态机**（全核恢复的总指挥） | ct_rtu_retire.v |
| **PST（物理寄存器状态表）** | | |
| [05_pst_preg.md](05_pst_preg.md) | 96 项整数 preg 生命周期状态机、释放与重命名表恢复 | ct_rtu_pst_preg.v + entry |
| [06_pst_vreg_ereg.md](06_pst_vreg_ereg.md) | 向量/浮点 vreg（64 项 ×2）与 ereg 状态表 | ct_rtu_pst_vreg.v / pst_ereg.v + entry |
| **公共组件** | | |
| [07_encode_compare.md](07_encode_compare.md) | IID 环形年龄比较、独热↔二进制互转 | compare_iid / encode_* / expand_* |

## 推荐学习路径

```
第一轮（建立全局观）
  └── 00_rtu_overview.md          ← 必读：ROB/PST/Retire 怎么分工，IID 是什么

第二轮（ROB 主线 —— 按序退休如何实现）
  └── 07_encode_compare.md（先懂 IID 比较，10 分钟）
      → 01_rob.md → 02_rob_rt.md

第三轮（异常与恢复 —— 精确异常如何保证）
  └── 03_rob_expt.md → 04_retire.md   ← flush 状态机是全书最重要的一节

第四轮（寄存器回收 —— 乱序的另一半收尾）
  └── 05_pst_preg.md → 06_pst_vreg_ereg.md
```

## 与已有文档的衔接

- **上游创建**：IDU IS 级创建 ROB/PST 表项见 `doc/idu/11_is_ctrl.md`；
- **完成来源**：IU 的 CBUS 见 `doc/iu/07_cbus.md`（pipe0/1/2），LSU pipe3/4 与
  VFPU pipe6/7 直连；
- **分支闭环**：误预测的退休期 flush 与 `doc/iu/02_bju.md` 第 2.6 节的
  stall 状态机互为表里；退休 PC 依赖 PCFIFO 弹出（`doc/iu/03_bju_pcfifo.md`）；
- **perf 统计**：tb.v 采样的 `rtu_yy_xx_retire0/1/2` 和 HPCP 的退休事件都源于
  本模块（见 04_retire.md 性能监控一节）。
