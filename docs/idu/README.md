# C910 IDU 学习文档索引

IDU（Instruction Decode Unit，指令译码单元）是 C910 乱序超标量执行的**核心调度引擎**。
它接收 IFU 送来的指令流，完成译码、寄存器重命名、乱序发射、读寄存器，最终把就绪指令送往 8 条执行管线。

> IDU 是全 C910 最大的单元：56 个 RTL 文件，约 10.4 万行（IFU 的 2.5 倍）。

## 目录结构

| 文件 | 内容 | 对应 RTL |
|------|------|----------|
| [00_idu_overview.md](00_idu_overview.md) | 总体架构、四级流水、乱序原理、完整数据流 | ct_idu_top.v |
| **ID 阶段（译码）** | | |
| [01_id_ctrl.md](01_id_ctrl.md) | ID 流水控制、pipedown 指令选择、stall 生成 | ct_idu_id_ctrl.v |
| [02_id_decd.md](02_id_decd.md) | 主译码器（3 路并行）、特殊指令译码 | ct_idu_id_decd.v / id_decd_special.v |
| [03_id_dp.md](03_id_dp.md) | ID 数据通路、译码结果组织 | ct_idu_id_dp.v |
| [04_id_split.md](04_id_split.md) | 长/短指令拆分（向量、复杂指令拆为微操作） | ct_idu_id_split_long.v / id_split_short.v |
| [05_id_fence.md](05_id_fence.md) | fence/屏障指令处理 | ct_idu_id_fence.v |
| **IR 阶段（重命名）** | | |
| [06_ir_ctrl.md](06_ir_ctrl.md) | IR 流水控制、精细 stall 设计 | ct_idu_ir_ctrl.v |
| [07_ir_dp.md](07_ir_dp.md) | IR 数据通路、IR 译码 | ct_idu_ir_dp.v / ir_decd.v |
| [08_ir_rt.md](08_ir_rt.md) | 整数重命名表（RAT）、消除假依赖 | ct_idu_ir_rt.v |
| [09_ir_frt.md](09_ir_frt.md) | 浮点重命名表 | ct_idu_ir_frt.v |
| [10_ir_vrt.md](10_ir_vrt.md) | 向量重命名表 | ct_idu_ir_vrt.v |
| **IS 阶段（发射/调度）** | | |
| [11_is_ctrl.md](11_is_ctrl.md) | 发射控制、ROB/PST 创建、dispatch | ct_idu_is_ctrl.v |
| [12_is_dp.md](12_is_dp.md) | 发射数据通路、流水项 | ct_idu_is_dp.v / is_pipe_entry.v |
| [13_is_aiq.md](13_is_aiq.md) | ALU 发射队列（aiq0/1）、唤醒-选择 | ct_idu_is_aiq0/1.v + entry + lch_rdy |
| [14_is_biq.md](14_is_biq.md) | 分支发射队列 | ct_idu_is_biq.v + entry |
| [15_is_lsiq.md](15_is_lsiq.md) | Load/Store 发射队列 | ct_idu_is_lsiq.v + entry |
| [16_is_sdiq.md](16_is_sdiq.md) | Store Data 发射队列 | ct_idu_is_sdiq.v + entry |
| [17_is_viq.md](17_is_viq.md) | 向量发射队列（viq0/1） | ct_idu_is_viq0/1.v + entry |
| **RF 阶段（读寄存器）** | | |
| [18_rf_ctrl.md](18_rf_ctrl.md) | RF 控制、指令有效/就绪寄存器 | ct_idu_rf_ctrl.v |
| [19_rf_dp.md](19_rf_dp.md) | RF 数据通路、8 条管线译码 | ct_idu_rf_dp.v / rf_pipe0-7_decd.v |
| [20_rf_fwd.md](20_rf_fwd.md) | 前递网络（标量+向量旁路） | ct_idu_rf_fwd.v + preg/vreg |
| [21_rf_prf.md](21_rf_prf.md) | 物理寄存器堆（整数/浮点/向量/E） | ct_idu_rf_prf_*regfile.v |
| **依赖检查** | | |
| [22_dep.md](22_dep.md) | 依赖项单元（被各发射队列调用） | ct_idu_dep_reg/vreg_entry.v |

## 推荐学习路径

```
第一轮（建立全局观）
  └── 00_idu_overview.md          ← 必读，理解四级流水和乱序原理

第二轮（译码前端）
  └── 01_id_ctrl → 02_id_decd → 03_id_dp → 04_id_split → 05_id_fence

第三轮（重命名 —— 乱序核心之一）
  └── 06_ir_ctrl → 07_ir_dp → 08_ir_rt → 09_ir_frt → 10_ir_vrt

第四轮（发射/调度 —— 乱序核心之二）
  └── 11_is_ctrl → 12_is_dp → 22_dep → 13_is_aiq → 14_is_biq
      → 15_is_lsiq → 16_is_sdiq → 17_is_viq

第五轮（读寄存器与执行准备）
  └── 18_rf_ctrl → 19_rf_dp → 20_rf_fwd → 21_rf_prf
```

## 前置知识

阅读本系列前，建议先掌握：
- IFU 文档（`../ifu/`）—— 理解 IDU 的指令来源
- 乱序执行基本概念：寄存器重命名、Tomasulo 算法、ROB（重排序缓冲）、保留站/发射队列
- RISC-V 指令编码基础（RV64GCV）
