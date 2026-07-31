# C910 VFPU VFDSU（SRT 基-16 除法/开方）详细教学文档

> 主要 RTL：
> - `C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_top.v`
> - `C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_ctrl.v`
> - `C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_prepare.v`
> - `C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_srt.v`
> - `C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_srt_radix16_with_sqrt.v`
> - `C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_srt_radix16_bound_table.v`
> - `C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_round.v`
> - `C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/ct_vfdsu_pack.v`

## 1. 当前实例边界

当前 `ct_vfdsu_top` 的有效 Verilog 实例只有：

1. 一个 `ct_vfdsu_ctrl`；
2. 一个 `ct_vfdsu_double`；
3. 一个 `ct_vfdsu_scalar_dp`。

`ct_vfdsu_double` 这个模块名容易误导。它不只处理 f64：输入中还有
`ex1_single`，未选择 double/single 时走 half 相关控制，因此它是当前共用的
64 位标量多精度运算核。

文件 `ct_vfdsu_top.v:137`-`224` 的 set0/set1、single 和多个 half
`&Instance`/`&Connect` 均位于注释中。当前端口也只有 64 位源和 64 位结果，
不存在有效的 `[127:64]` 输入。因此这些行只能称为向量化生成模板，不能写成
当前“两个 set 并行”“VLEN128”或多 lane 除法器。

VFDSU 在 `ct_vfpu_top` 只实例化一份并挂在 pipe6。单实例、单个 SRT 状态机和
busy 反馈是 RTL 事实；“除法低频所以不复制”是常见设计解释，但需要工作负载
统计和综合面积才能作为该实现的定量结论。

## 2. 为什么它是变延迟、非每拍接收

加法和 FMA 可以把不同指令放在不同流水级中重叠执行。当前 VFDSU 的 SRT 引擎
则在多个周期中反复更新同一组部分余数、商/根和边界选择状态：

```text
准备操作数
  -> 装入初始余数/除数/计数器
  -> 多周期更新部分余数和商/根
  -> round
  -> pack
  -> 返回 VFPU 固定流水并写回
```

当写回状态机位于 RF、EX1、EX2 或 WB_REQ 时，`div_cur_state[2]=1`，
`vfdsu_dp_fdiv_busy` 为 1。IDU 据此避免把另一条除法/开方送入同一迭代器。
因此“不可每拍接收新除法”来自共享迭代状态，而不是仅仅因为延迟长。

总延迟可因下列条件变化：

- f64/f32/f16 使用不同计数初值；
- 特殊值、范围条件使 `skip_srt` 提前结束；
- 余数变为 0 时 `rem_zero` 提前结束；
- flush 使状态机回到 IDLE；
- 共享写回时隙和参考点会影响所观测的端到端周期数。

## 3. 接口语义

| 信号 | 精确含义 |
|---|---|
| `dp_vfdsu_idu_fdiv_issue` | 写回状态机在 IDLE/WB 判断是否接收一条新除法类请求 |
| `dp_vfdsu_ex1_pipex_sel` | 请求到达 VFDSU EX1，启动 SRT 状态机和数据准备 |
| `dp_vfdsu_fdiv_gateclk_issue` | 写回状态机门控时钟的启动请求，不等价于功能接收 |
| `vfdsu_dp_fdiv_busy` | `div_cur_state[2]`；覆盖 RF/EX1/EX2/WB_REQ，不覆盖 WB |
| `vfdsu_dp_inst_wb_req` | `vfdsu_ex3_vld`；结果接近返回时申请共享写回时隙 |
| `pipex_dp_vfdsu_inst_vld` | 写回状态机当前为 WB，返回结果被重新注入 VFPU |
| `pipex_dp_vfdsu_freg_data` | 64 位浮点结果数据 |
| `pipex_dp_vfdsu_ereg_data` | 5 位浮点异常结果 |

`busy`、`wb_req` 和 `inst_vld` 分别描述资源占用、写回预约和结果返回，不能互换。
尤其是状态进入 WB 后 `busy` 已经为 0，而 `pipex_dp_vfdsu_inst_vld` 正在有效。

此外，VFPU CBUS 直接由 `idu_vfpu_rf_pipe6_sel` 驱动并没有排除 VFDSU。因此一条
VFDSU 请求也会产生早期 ROB 完成事件；最终结果仍由上述返回路径写 FREG/EREG。
完成记账和数据就绪是两套事件。

## 4. 两个状态机

### 4.1 SRT 状态机

SRT 状态机只有 IDLE/BUSY 两态：

```verilog
SRT_IDLE: if (ex1_pipedown)   next = SRT_BUSY;
SRT_BUSY: if (srt_last_round) next = SRT_IDLE;
```

`srt_sm_on` 直接等于当前状态位。`srt_last_round` 是组合终止条件：

```verilog
srt_last_round =
    (skip_srt || srt_ctrl_rem_zero || srt_cnt_zero) && srt_sm_on;
```

所以 `srt_last_round` 是 BUSY 期间的终止判定，不是一个独立保存的“完成状态”。
在命中条件的时钟沿，SRT 状态回到 IDLE，并同时推动 EX2 结果进入 EX3。

SRT 状态时钟的本地请求为：

```verilog
srt_sm_clk_en = srt_cur_state || ex1_pipedown || rtu_yy_xx_flush;
```

这保证启动、运行和 flush 清零时有时钟。`local_en=0` 只表示本地不请求开钟；
扫描、全局和模块使能仍会影响门控单元最终输出。

### 4.2 写回状态机

写回状态机有六态：

```text
IDLE -> RF -> EX1 -> EX2 -> WB_REQ -> WB -> IDLE
```

状态转移的细节为：

```verilog
IDLE   : issue                 ? RF     : IDLE
RF     :                         EX1
EX1    : ex1_pipex_sel         ? EX2    : IDLE
EX2    : srt_last_round        ? WB_REQ : EX2
WB_REQ : ex4_pipedown          ? WB     : WB_REQ
WB     : same-cycle new issue  ? RF     : IDLE
```

EX1 如果没有看到预期的 `dp_vfdsu_ex1_pipex_sel` 会返回 IDLE，而不是无限等待。
WB 状态允许在当前结果返回的同时接受下一条 issue，并在下一拍转入 RF。这是一种
缩短相邻操作交接空隙的设计，但仍不代表两个 SRT 迭代可以重叠。

`ex2_pipedown = srt_last_round && div_st_ex2` 把两个状态机对齐：只有 SRT 判定终止
且写回机确实在 EX2 时，结果才进入 round/pack 后处理。

## 5. `srt_cnt_ini=13/6/3` 到底表示什么

有效赋值为：

```verilog
srt_cnt_ini = ex1_double ? 13
            : ex1_single ?  6
                         :  3;
```

启动沿把 `srt_cnt` 装为 N；只要 SRT 处于 BUSY 且未结束，每个有效沿执行
`srt_cnt <= srt_cnt - 1`。`srt_cnt_zero` 检查的是**当前寄存器值**是否为 0。

因此正常计数控制路径经历：

```text
N, N-1, ..., 2, 1, 0
```

共 N+1 个有效计数状态：

| 精度选择 | 装载值 N | 不提前结束时经历的计数状态数 |
|---|---:|---:|
| double | 13 | 14 |
| single | 6 | 7 |
| half | 3 | 4 |

13/6/3 是计数器装载值，不是脱离计数语义后可以直接引用的“迭代轮数”。如果把
启动准备或结束沿也定义为算法子步，论文中的轮数还会采用不同口径；波形分析应
直接统计 `srt_sm_on && !srt_last_round` 的运行周期和终止周期，而不是只读取
装载常量。

源文件紧邻赋值的注释仍写“double 28、计算 29 round；single 14、计算 15
round”。这些数字与有效赋值不一致，属于过期注释。仅凭这两行不能确定旧版本
使用了哪一种 SRT 基数或微步骤组织，因此不应进一步断言它一定来自某个具体旧
算法。

## 6. 提前结束条件

### 6.1 `skip_srt`

`ct_vfdsu_srt.v` 的有效逻辑为：

```verilog
srt_ctrl_skip_srt =
    ex2_of || ex2_id_nor_srt_skip || vfdsu_ex2_srt_skip;
```

- `ex2_of`：正常操作数组合下的指数溢出判定；
- `ex2_id_nor_srt_skip`：指数极小到无需正常 SRT 精度路径的条件；
- `vfdsu_ex2_srt_skip`：prepare 阶段传播的特殊值/无需迭代条件。

因此 `skip_srt` 不应只概括为“被除数特殊”，它还包含范围和 prepare 阶段判定。
命中后仍要经过后续 round/pack/返回控制，并不是整个指令同拍完成。

### 6.2 `rem_zero`

`srt_ctrl_rem_zero = ~|srt_remainder[60:0]`。当当前部分余数全零时，继续产生后续
商/根位没有必要，状态机可在该周期终止。它检测的是内部 61 位 SRT 余数，不是
最终打包结果是否为浮点 `+0/-0`。

## 7. SRT 基-16 数据路径

基-16 SRT 的核心思想是：每个迭代周期选择一个冗余商/根 digit，再更新部分余数
和累计商/根。当前实现中可直接看到：

- `initial_divisor_in[55:0]` 和 `initial_remainder_in[60:0]`；
- 7 位 `bound_sel`；
- 9 个 12 位 `digit_bound_1...9`；
- 9 次 `part_rem < digit_bound_n` 比较；
- 包括 `+8/-8` 在内的余数候选路径；
- 商/根累计值与校正值。

9 个边界比较把部分余数映射到冗余 digit 区间。基-16 表示一次推进多位，但
“每周期固定产生四个最终正确二进制位”是算法层概括；冗余 digit 还需累计和
校正，不能把中间选择码直接当最终商的四位切片。

`ct_vfdsu_srt_radix16_bound_table.v` 很长，说明边界常量和开方特殊边界逻辑较多。
源码行数不能等价为门面积；该模块在综合后可能被优化成逻辑网络或 ROM 风格结构。
是否为 VFDSU 最大面积块、是否处于主关键路径，都要看综合层次面积与时序报告。

## 8. `srt_first_round` 与 `srt_secd_round`

这两个名字描述开方启动附近的**微步骤/阶段脉冲**，不是两遍完整 SRT：

- `ex2_srt_first_round` 在 `ex1_pipedown` 后置 1，一个周期后自动回 0；
- `srt_secd_round_pre` 在 BUSY 且计数器仍等于初值 N 时为 1；
- `ex2_srt_secd_round` 在下一有效沿锁存该条件，因此也是短脉冲；
- 计数器没有在 `srt_secd_round` 时重新装载；
- SRT 状态也没有回到 IDLE 后再次进入 BUSY。

在 `ct_vfdsu_srt_radix16_with_sqrt.v` 中，这两个脉冲与 `srt_sel_sqrt` 相与后送入
边界表：

```verilog
sqrt_first_round = srt_sel_sqrt && srt_first_round;
sqrt_secd_round  = srt_sel_sqrt && srt_secd_round;
```

边界表在 first 脉冲使用一组固定初始边界，在 second 脉冲根据余数符号使用
另一组开方校正边界，其他周期使用普通 `ori_digit_bound_*`。所以
`srt_secd_round` 更准确的中文是“开方初始阶段的第二微步骤标记”。

当前控制中 FDIV 和 FSQRT 同精度使用相同 `srt_cnt_ini`，也没有因
`srt_secd_round` 重新装载计数器。故不能由该信号得出“FSQRT 完整迭代两遍”
或“FSQRT 必然比同精度 FDIV 多一整组迭代周期”。两者实际数据相关延迟还会受
skip/rem_zero 条件影响，应通过波形或计数器测量。

## 9. Round、pack 与返回

SRT 终止后：

1. `ex2_pipedown` 使 `vfdsu_ex3_vld` 在时钟沿置 1；
2. EX3 承担商/根整理、舍入相关计算，并令
   `vfdsu_dp_inst_wb_req = vfdsu_ex3_vld`；
3. 下一阶段 `vfdsu_ex4_vld` 驱动 pack 结果有效；
4. 写回机在 `ex4_pipedown` 时从 WB_REQ 进入 WB；
5. WB 周期 `pipex_dp_vfdsu_inst_vld=1`，64 位结果、5 位异常和目的编码返回
   VFPU pipe6；
6. VFPU 把返回当作变延迟结果注入固定流水，之后由 RBus 写 FREG/EREG。

“WB_REQ”表示申请/预约共享返回资源，不表示数据已经写进物理寄存器。
“WB”表示 VFDSU 对上层的返回有效，也不等于 ROB 已经退休。

## 10. 延迟如何计算

在没有 skip/rem_zero/flush 的情况下，可按事件而不是按模糊的“拍数”计数：

```text
IDU issue
  -> 写回机 RF
  -> 写回机 EX1，看到 pipex_sel 后启动 SRT
  -> SRT 经历 N...0
  -> EX3 round / wb_req
  -> EX4 pack
  -> WB 返回
  -> VFPU/RBus 写回
```

从 IDU issue 到 VFDSU WB 返回，double/single/half 的差异主要来自 N。按照当前
状态转移，可以推导出常见的约 18/11/8 周期数量级，但这个数字依赖：

- 起点取 issue 组合有效、采样沿还是 RF 状态；
- 终点取 VFDSU WB、RBus 写有效还是消费者可前递；
- 是否把起止周期都计入；
- 是否命中提前结束。

因此 18/11/8 应标为“基于状态机、以特定起止事件推导的无提前退出参考值”，
不能写成 RTL 常量或所有输入都固定不变的官方延迟。

## 11. 波形观察建议

一条操作至少同时观察：

```text
dp_vfdsu_idu_fdiv_issue
dp_vfdsu_ex1_pipex_sel
div_cur_state
srt_cur_state / srt_sm_on
srt_cnt / srt_cnt_zero
skip_srt / srt_ctrl_rem_zero / srt_last_round
ex2_srt_first_round / srt_secd_round
vfdsu_ex3_vld / vfdsu_ex4_vld
vfdsu_dp_inst_wb_req
pipex_dp_vfdsu_inst_vld
pipex_dp_vfdsu_freg_data / ereg_data
rtu_yy_xx_flush
```

判断提前退出时，不只看总周期变短，还要同时确认是 `skip_srt`、`rem_zero` 还是
flush 触发。判断写回时，要把 VFDSU 的 WB 返回与之后 RBus 的 FREG/EREG 写有效
配对，避免把返回入口当成最终物理写回。

## 12. 体系结构意义

VFDSU 展示了乱序处理器接入长延迟单实例单元的典型方法：

- issue 与 EX1 选择对齐，避免门控请求被误当成功能接收；
- busy 管资源占用，wb_req 管共享返回端口，二者分工；
- 数据相关提前退出降低平均延迟，但最坏延迟仍由精度和计数路径决定；
- 变延迟结果通过返回注入复用固定 RBus，而不是另建完整写回系统；
- ROB 完成、数据写回、异常状态和顺序退休保持解耦。

优化这类单元时，既要看单条除法延迟，也要看除法出现频率、后继依赖距离、busy
导致的结构冲突和返回端口冲突。只减少 SRT 一两个周期，如果负载中几乎没有
除法，整机 IPC 可能几乎不变；反之，依赖链密集的除法工作负载会直接受益。
