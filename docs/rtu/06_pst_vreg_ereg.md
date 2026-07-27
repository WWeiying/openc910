# C910 向量/浮点/扩展寄存器状态表（ct_rtu_pst_vreg / ct_rtu_pst_ereg）

> RTL 源文件：
> - `ct_rtu_pst_vreg.v`（6288 行）+ `ct_rtu_pst_vreg_entry.v`（581 行）——
>   **例化两次**：`x_ct_rtu_pst_vreg`（向量 vreg）与 `x_ct_rtu_pst_freg`（浮点 freg）
> - `ct_rtu_pst_ereg.v`（2743 行）+ `ct_rtu_pst_ereg_entry.v`（529 行）
> - `ct_rtu_pst_vreg_dummy.v`（194 行，门控配置下的占位）
>
> 三类寄存器的 PST 与整数 preg（见 05）**同构**：同样的五态生命周期 +
> 两态写回 FSM。本文只讲差异，状态机原理请先读 05_pst_preg.md。

---

## 1. 同构的证据

vreg_entry 与 ereg_entry 的状态定义与 preg 完全一致：

```verilog
// vreg_entry.v:188-195 / ereg_entry.v:152-159（与 preg_entry.v:185-192 相同）
parameter DEALLOC=00001; WF_ALLOC=00010; ALLOC=00100; RETIRE=01000; RELEASE=10000;
parameter IDLE=0; WB=1;
```

状态转换、退休 iid 预匹配、rel_reg 释放位图、RETIRE 态恢复位图、
`retired_released_wb` 汇报——五件套一样不少。差异只在规模与写回源。

## 2. 三张表的差异

| | preg（整数） | vreg/freg（向量/浮点） | ereg（扩展） |
|---|---|---|---|
| 项数 | 96 | 各 64 | 32 |
| 服务的逻辑寄存器 | x0-x31 | v0-v31 / f0-f31 | T-Head 扩展寄存器（vsetvl 组配置等的重命名） |
| 写回源 | IU pipe0/1、LSU pipe3、VFPU mfvr | LSU pipe3（向量 load）、VFPU pipe6/7（ex5 写回） | pipe 完成即写回 |
| 释放位图宽度 | expand_96 | expand_64 | expand_32 |
| 每拍分配 | 4 | 4 | 4 |

vreg 的写回接口（ct_rtu_top.v 例化处注释 L1681-1685 可见）：
`lsu_rtu_wb_pipe3_wb_vreg_expand[63:0]`、`vfpu_rtu_ex5_pipe6/7_wb_vreg_expand[63:0]`
——向量写回最晚到 **EX5**（VFPU 管线深），所以向量指令退休后等写回落地的
窗口比整数长，flush 状态机的 WF_EMPTY 在向量代码里停留更久。

**freg 复用 vreg 模块**：浮点与向量在 C910 中是两套独立的 64 项寄存器堆
（FLEN=64 / VLEN=128 共享编址不同存储），但状态管理需求一致，于是同一
RTL 例化两份，端口接不同的写回源（`vfpu_rtu_ex5_pipe6_wb_vreg_fr_vld` vs
`_vr_vld`，见 ct_rtu_top.v L1736-1747 的 Connect 注释）。

**dummy 版本**（pst_vreg_dummy.v）：当配置裁掉向量单元时用空壳占位保持
端口，输出恒空闲——RTL 配置管理的常见手法。

## 3. ereg 是什么

ereg 服务于 T-Head 扩展中需要重命名的"额外结果"寄存器（典型：vsetvl 组
指令对 vl/vtype 的修改在退休前是推测的，需要像寄存器一样重命名回滚）。
retire.v 的 `retire_pst_wb_retire_inst*_ereg_vld`（L1178-1181 注释
"expt instruction should write back ereg value"）表明：**带异常的指令也要
正常提交 ereg**——异常指令本身的 ereg 效果属于体系结构定义的一部分。

## 4. Verdi 观察建议

层次：`...x_ct_rtu_top.x_ct_rtu_pst_vreg / x_ct_rtu_pst_freg / x_ct_rtu_pst_ereg`

跑 rvv case 时对比 `x_ct_rtu_pst_vreg` 与 `x_ct_rtu_pst_preg` 的分配节奏；
纯整数代码（coremark）里 vreg/freg 表应几乎纹丝不动——若有翻转，注意是否
fp_dirty/vec_dirty 误置（ROB 表项位，影响 mstatus.FS/VS 懒保存）。
