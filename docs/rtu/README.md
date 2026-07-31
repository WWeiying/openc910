# C910 RTU 学习文档索引

RTU（Retire Unit，退休单元）是 C910 乱序执行的**秩序守护者**：指令可以乱序
执行，但必须**按程序序退休**。RTU 维护 ROB（重排序缓冲）、PST（物理寄存器
状态表）、异常缓冲与 flush 状态机，保证精确异常和正确的寄存器回收。

> RTU 共 22 个 RTL 文件，约 3.6 万行，位于 `C910_RTL_FACTORY/gen_rtl/rtu/rtl/`。
> 最大文件 ct_rtu_pst_preg.v（8637 行）。每拍最多弹出 3 个 ROB 表项，每项用
> `inst_num` 表示 1~3 条被折叠的架构指令。因此某一拍计入 `minstret` 的指令数
> 可以大于 3，但长期 IPC 仍受前端每拍最多输入 3 条架构指令等环节限制，不能把
> 单拍最大求和值直接称为可持续 9 IPC。HPCP 还会用 `!split` 屏蔽拆分微操作，
> 因而 `minstret` 统计的是非 split 退休项覆盖的架构指令数，不是所有退出 ROB
> 的内部微操作数。

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
| [05_pst_preg.md](05_pst_preg.md) | 96 个整数物理编号：preg0 固定映射 + 95 个有状态 entry，及释放与恢复 | ct_rtu_pst_preg.v + entry |
| [06_pst_vreg_ereg.md](06_pst_vreg_ereg.md) | 当前 64 项 FREG PST、向量 PST dummy、32 项 EREG 状态贡献表及精确累积路径 | ct_rtu_pst_vreg.v / pst_vreg_dummy.v / pst_ereg.v + entry |
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

- **上游创建**：IDU IS 级创建 ROB/PST 表项见 `docs/idu/11_is_ctrl.md`；
- **完成来源**：IU 的 CBUS 见 `docs/iu/07_cbus.md`（pipe0/1/2），LSU pipe3/4 与
  VFPU pipe6/7 直连；
- **分支闭环**：误预测的退休期 flush 与 `docs/iu/02_bju.md` 第 2.6 节的
  stall 状态机互为表里；退休 PC 依赖 PCFIFO 弹出（`docs/iu/03_bju_pcfifo.md`）；
- **perf 统计**：`rtu_yy_xx_retire0/1/2` 只表示三个 ROB 退休槽有效。准确的
  HPCP 增量要对每个有效且 `split=0` 的槽的 `rob_retire_inst*_num` 求和；
  `minstret_adder` 正是这样实现。仅把三个 valid 相加既会漏算折叠指令，也会
  把 split 微操作误当成架构指令。该增量路径没有在 HPCP 接口处另加
  `!expt_vld` 条件；普通无异常 benchmark 中可作为架构退休数，异常边界应以
  定向测试核对实际计数语义。
- **RAS 返回栈**：`ct_ifu_ras.v` 内有 12 个推测栈数据项和 6 个退休恢复副本
  `rtu_entry0~5`。后六项服务精确状态恢复，不是额外的预测栈容量，因而不能把
  RAS 深度写成 18。RTU 不自存 RAS，而是在退休时通过
  `rtu_ifu_retire0/1/2_pcall/preturn` 信号驱动恢复副本更新——**用精确退休的 call/ret
  纠正前端投机压栈/弹栈的错误**。所以 RAS 的存储归 IFU（见
  `docs/ifu/05_ras.md`），但其精确恢复依赖 RTU 的退休事件。
