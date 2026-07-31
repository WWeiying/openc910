# C910 间接跳转预测详解（`ct_ifu_ind_btb`）

> RTL 依据：`ct_ifu_ind_btb.v`、`ct_ifu_ind_btb_array.v`、
> `ct_ifu_ibctrl.v`、`ct_rtu_retire.v`。本文只描述当前生成 RTL 中实际存在的逻辑。

## 1. 它解决什么问题

直接跳转的目标由指令立即数决定，普通 BTB 可以用分支 PC 记住目标；`jalr`、
函数指针、虚函数和 switch 跳转表的目标来自寄存器，同一个跳转 PC 还可能在
不同调用路径上跳向不同地址。C910 因此使用独立的 Indirect BTB：

```text
最近 4 个间接跳转的路径特征 + 8-bit GHR
                    |
                    v
              8-bit 混合索引
                    |
                    v
             256 x 23-bit SRAM
          {valid, privilege, target[19:0]}
```

它本质上是一个带路径上下文的目标预测器，不是普通的“PC tag + target”表。

## 2. 真实容量与表项

`ct_ifu_ind_btb_array.v:83~92` 只实例化一个 `ct_spsram_256x23`：

| 字段 | 位数 | 含义 |
|---|---:|---|
| `valid` | 1 | 表项是否可用 |
| `priv_mode` | 2 | 创建/更新时的特权模式 |
| `target[19:0]` | 20 | 退休确认的下一 PC 的内部低 20 位；由于 IFU 内部 PC 省略恒为 0 的架构地址 bit 0，它对应架构字节地址的 `[20:1]` |

表中没有分支 PC tag，也只保存目标低 20 位。因此，不同上下文映射到同一索引时
会发生容量/别名冲突。`ct_ifu_ibctrl.v` 中的实际目标重建式为：

```verilog
ind_chgflw_pc = ind_btb_rd_vld
              ? {ib_vpc[38:20], ind_btb_dout[19:0]}
              : default_pc;
```

也就是说，表项提供内部 PC 低 20 位，高 `[38:20]` 直接沿用当前 IB 虚拟 PC。
内部低 20 位对应架构字节地址 `[20:1]`，因此高位拼接边界是 2 MiB。这里不是
把一个完整地址从表中读出来，也没有额外高位 tag 检查；若真实目标跨越当前
2 MiB 区域，或不同上下文在无 tag 表中发生别名，就可能预测到错误地址。预测
错误只能损失性能，不能改变架构结果，因为执行侧仍会计算真实 JALR 目标，ROB/RTU
按误预测标志恢复架构路径。

## 3. 索引为什么不是 PC

### 3.1 路径历史

模块维护两套 4×8-bit 路径寄存器：

- `path_reg_0..3`：投机路径。只有 `ibctrl_ind_btb_check_vld` 成立，即 IB 已形成
  间接改流且没有被自身 stall 或 PCFIFO stall 阻断时，才压入
  `ibctrl_ind_btb_path = ind_chgflw_pc[10:3]`。压入的是**预测目标 PC 的一段低位**，
  不是该 `jalr` 指令本身的 PC。
- `rtu_path_reg_0..3`：退休路径，只在 RTU 正常退休间接跳转时压入
  `rtu_ifu_retire*_chk_idx`。

`reg_0` 是最新项，新增一项时旧项依次向 `reg_1..3` 移动。RTU 一拍最多退休
3 个相关跳转，所以 `ct_ifu_ind_btb.v:400~455` 显式枚举了 8 种
`{retire0, retire1, retire2}` 组合，保证同拍多个事件仍按程序序进入历史。

### 3.2 与 GHR 混合

读索引的等价伪代码是：

```text
index[7:6] = path3_pre[7:6] XOR vGHR_reg[7:6]
index[5:4] = path2_pre[5:4] XOR vGHR_reg[5:4]
index[3:2] = path1_pre[3:2] XOR vGHR_reg[3:2]
index[1:0] = path0_pre[1:0] XOR vGHR_reg[1:0]
```

这里特意使用 `path_reg_*_pre`，因为触发读的事件可能正是“IB 接受新的间接改流”、
“IP 看到条件分支而更新 vGHR”或“RTU 恢复历史”；查询必须对应该事件作用后的候选
历史，而不能机械地使用寄存器更新前的旧值。RTL 注释同时说明，为缩短时序，GHR
一侧使用 `vghr_reg` 而不是另一个组合预计算值。写索引则使用退休路径
`rtu_path_reg_*` 与精确 `rtu_ghr`。这样同一 `jalr` 在不同控制流上下文下可能
映射到不同表项，能够学习“路径上下文与目标相关”的模式。

体系结构上的关键点是：**预测索引和训练索引必须代表同一段历史语义**。投机执行
期间用 vGHR/投机 path 提高吞吐；退休或 flush 时必须恢复到 RTU 的已提交历史，
否则后续查询会长期使用错误上下文。

## 4. 查询时序与停顿

`ipdp_ind_btb_jmp_detect` 表示 IP 数据通路检测到需要间接目标预测的指令，但
`ind_btb_rd` 并不等于这个检测信号本身。读使能还要求预测器已启用、当前不是 RTU
写表或逐项失效、PCFIFO 没有阻塞，并且出现以下至少一种“需要按新历史重读”的
原因：RTU 历史恢复、恢复后一拍的补充读取、IB 投机 path 更新，或 IP 侧 vGHR
更新。同步 SRAM 查询不能在同拍返回供 IB 使用的稳定结果：

1. 某个历史更新条件使组合信号 `ind_btb_rd` 成立，单端口 SRAM 接收读地址。
2. 主时钟上升沿把该请求记入 `ind_btb_rd_flop`。
3. `ind_btb_rd_flop` 作为 `dout_update_clk` 的本地开钟条件；相应有效边沿把
   `ind_btb_dout` 锁存到 `ind_btb_dout_reg`，并在**同一锁存边沿**采样
   `cp0_yy_priv_mode` 到 `priv_mode_reg`。
4. IB 遇到有效间接跳转且 `ind_btb_rd_state==0` 时，
   `ind_btb_rd_stall` 拉高；该条件在有效状态时钟边沿把状态置 1。
5. 随后只有表项 `valid==1` 且表内 privilege 等于这个已采样的
   `priv_mode_reg`，`ind_btb_rd_vld` 才成立。IB 才会用表中低位重建目标；否则
   走 `default_pc`，同时给 PCFIFO 记录 indirect-BTB miss。

`ind_btb_rd_stall` 的 RTL 意图是等待一拍，但这里的“一拍”是从 IB 第一次看到该
间接跳转、状态仍为 0 的周期算起；若同时存在 cancel、地址 cancel、PCFIFO/full
stall 等事件，整个间接改流完成时间还会继续延长。它解释了为何间接跳转即使预测
命中，也不具备 L0 BTB 那样在 IF 级较早提供寄存器表目标的路径。
调性能时应分别量化“表未命中”和“同步查询等待”，不能把所有停顿都称为
预测错误。

一个容易忽略的边界是：IBCTRL 的
`ind_btb_rd_stall = !ind_btb_rd_state && ib_data_vld && !ib_expt_vld &&
(|hn_ind_br)` 本身没有与 `cp0_ifu_ind_btb_en` 相与。因此检测到间接跳转时，
即使 Indirect-BTB 查询/训练被 CP0 禁止，IB 的状态握手仍会经历这一等待路径。
同时 `ind_btb_rd_vld` 只检查锁存表项的 valid 和 privilege，也没有再次检查
enable。通常模式切换应由上游配置/flush 协议保证旧结果不被误用；在验证动态
开关功能时，必须把 CP0 enable、最后一次 `dout_reg`、IB state 和 flush 一起
观察，不能只看 SRAM 有没有发起新读。

## 5. 更新与恢复

### 5.1 只在已确认错误时写目标

```verilog
assign rtu_ind_btb_update_vld = rtu_ifu_retire0_jmp_mispred;
assign ind_btb_data_in = {1'b1, cp0_yy_priv_mode,
                          rtu_ifu_retire0_next_pc[19:0]};
```

当前 RTL 不是每次间接跳转退休都重写表项。RTU 中
`rtu_ifu_retire0_jmp_mispred` 的上游条件是 retire0 正常退休、ROB 标记
`jmp_mispred`，且该指令不是预测返回 `pret`；只有这个事件才产生 Indirect BTB
目标更新。写数据使用当拍 `cp0_yy_priv_mode` 和 retire0 的
`next_pc[19:0]`。写优先级高于读；同拍更新时 `ind_btb_rd` 被抑制，以确定单端口
SRAM 的访问语义。

### 5.2 两套历史如何重新一致

`path_reg_rtu_updt = rtu_ifu_retire0_mispred || rtu_ifu_flush`。发生误预测退休或
全局 flush 时，投机 `path_reg_*` 从退休侧计算出的 `rtu_path_reg_*_pre`
恢复。若同拍又更新 Indirect BTB，`after_path_reg_rtu_updt` 再保留一拍，
保证后续检测到间接跳转时能以恢复后的路径重新查询。

这里的逻辑难点不是“清空几个寄存器”，而是协调三个时间域语义：

- 已退休、必然正确的历史；
- 已取到但尚未退休的投机历史；
- 误预测发生当拍正在读/写的 SRAM 操作。

任何恢复少一拍或历史压入顺序错误，都可能造成预测精度持续下降，而且不会表现为
架构错误，因此特别容易被普通指令正确性测试漏掉。

## 6. 失效流程

`ifctrl_ind_btb_inv` 启动失效。它不是一个含义模糊的“前端正在失效”电平，而是
`ct_ifu_ifctrl` 对 `cp0_ifu_ind_btb_inv` 做上升沿检测后产生的启动脉冲：

1. `ind_btb_inv_cnt` 装入 `8'hff`。
2. 每拍对当前地址写 23-bit 全零。
3. 计数从 255 递减到 0。
4. `ind_btb_inv_on_reg` 清零，`ind_btb_ifctrl_inv_done` 重新拉高。

这是 256 行逐行清零，不是一个周期清空。计数器装载 255 后，失效有效期间依次
写地址 255、254，直至 0；`ind_btb_inv_on_reg` 在地址 0 对应的失效周期之后清零。
失效期间普通预测读写被屏蔽，投机和退休路径历史也被清零。
`ind_btb_ifctrl_inv_done` 实际是 `!ind_btb_inv_on_reg` 的完成/空闲电平，不是只维持
一拍的 done 脉冲；IFCTRL 再对它的上升沿形成送 CP0 的完成脉冲。

本文只能从当前连接确认该流程由 CP0 专用的 `cp0_ifu_ind_btb_inv` 请求启动，不能
仅凭模块名把任意复位、`fence.i` 或 I-Cache invalidate 都等同于这个请求。波形
分析应直接观察 CP0 请求和 `ind_btb_inv_on_reg`，而不是根据软件指令名称猜测。

## 7. 正确性不变量

1. 只有 `ind_btb_rd` 被时钟边沿记录、随后 `ind_btb_rd_flop` 使输出寄存器完成
   锁存后，`ind_btb_dout_reg` 才代表这次查询；不能把 SRAM 组合输出变化直接当结果。
2. 写目标来自退休确认的 `next_pc`，不能来自仍可能被冲刷的投机结果。
3. flush 后投机 path 必须回到退休 path。
4. 同拍退休多条间接跳转时，历史压入顺序必须与程序序一致。
5. 当前 RTL 在 `ind_btb_rd_flop` 对应的结果锁存边沿同时采样 privilege，而不是
   在最初形成 `ind_btb_rd` 的组合周期单独保存“请求时 privilege”。因此波形核查
   应比较结果锁存边沿的 `cp0_yy_priv_mode`、`priv_mode_reg` 和表项 privilege；
   若要证明跨周期特权切换安全，还需结合 flush/特权切换协议，不能只看此模块。
6. 表项无 tag，命中只能视为预测；后端必须独立确认真实目标。
7. `cp0_ifu_ind_btb_en` 控制 SRAM 读写和路径历史更新，但不直接清零
   `ind_btb_dout_reg`，也不直接屏蔽 IBCTRL 的一拍状态机；动态开关的正确性依赖
   更高层控制协议。

### 7.1 门控时钟的观察边界

Indirect-BTB SRAM、输出锁存、路径历史和失效计数分别使用多个
`gated_clk_cell`。例如 SRAM 的 local-enable 只覆盖 invalidation、
RTU update 或 IPDP jump-detect，而一次有效访问还必须联合
`ind_btb_cen_b/ind_btb_wen_b/index` 判断。技术 ICG 分支中
`cp0_ifu_icg_en` 可覆盖 local-enable，且所有这些实例仍受
`cp0_yy_clk_en`；未定义 `C910_USE_TSMC28_ICG` 时开源 wrapper 直接传递主时钟。
因此 Verdi 中看到某个局部时钟持续翻转，不等于 SRAM 每拍都读写；反过来，
`local_en=0` 也不能单独证明物理实现已经关钟。

## 8. Verdi 观察方法

建议按一次间接跳转从发现到恢复的顺序加入：

```text
ipdp_ind_btb_jmp_detect
ibctrl_ind_btb_check_vld
ibctrl_ind_btb_path[7:0]
ind_btb_rd
ind_btb_rd_index[7:0]
ind_btb_rd_flop
ind_btb_dout[22:0]
ind_btb_dout_reg[22:0]
ibctrl_debug_ind_btb_stall

path_reg_0..3
rtu_path_reg_0..3
bht_ind_btb_vghr[7:0]
bht_ind_btb_rtu_ghr[7:0]

rtu_ifu_retire0_jmp_mispred
rtu_ifu_retire0_next_pc[38:0]
rtu_ind_btb_update_vld
ind_btb_wen_b
path_reg_rtu_updt
```

诊断顺序：

1. 先确认 `jmp_detect` 后是否真的发出 `ind_btb_rd`。
2. 若未发出，检查 FIFO stall、失效状态和 CP0 enable。
3. 若发出但目标错误，比较读/写索引及两套历史。
4. 若索引相同却输出错误，检查表项别名、写优先级和 SRAM 锁存拍。
5. 若恢复后连续错误，重点检查 `path_reg_rtu_updt` 和 GHR 是否同拍恢复。

## 9. 性能含义

Indirect BTB 适合研究函数指针、解释器 dispatch、虚函数和大型 switch。性能分析
至少要拆成：

- 间接跳转动态频率；
- 查询导致的等待周期；
- valid/privilege/目标预测命中率；
- 误预测后的前端空窗周期；
- 256 项无 tag 表的冲突与上下文别名。

只看总分支预测准确率会掩盖这个小而高代价的分支子类。
