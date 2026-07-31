# C910 IFU 跨模块控制：PCFIFO 接口、入口向量与调试快照

> 本文说明三个容易因名称或位置被忽略的直接子模块：
> `ct_ifu_pcfifo_if.v`、`ct_ifu_vector.v`、`ct_ifu_debug.v`。

## 1. `ct_ifu_pcfifo_if`：把取指现场交给后端

### 1.1 为什么 IFU 要创建 IU 的 PCFIFO 项

分支进入 BJU 时，需要比较“当时预测的方向/目标”与真实执行结果；RTU 退休时还
需要精确重建控制流 PC。若把完整 PC、预测 GHR 和 BHT 元数据跟随每条微操作经过
所有流水级，代价很高。C910 让 IFU 在发现 `pc_oper` 时向 IU 的 PCFIFO 发送
创建描述，后续相关指令通过较短的 pid 引用相应记录。`ct_iu_bju_pcfifo.v` 的
有效向量和指针均为 `[31:0]`，所以存储深度确为 32 项；这里的“32 项”来自 IU
存储本体，不是从 IFU 侧两个 create 接口的数量推出来的。

`ct_ifu_pcfifo_if` 是这条跨单元接口的格式化和限宽层，不是 PCFIFO 存储本体。
存储本体在 `ct_iu_bju_pcfifo.v`，详见 `docs/iu/03_bju_pcfifo.md`。

### 1.2 从 8 个 half-word 位置选最多两个

IB 数据通路给出 H1~H8 八个 half-word 位置上的 `hn_pc_oper[7:0]`，其中 H1
对应 bit 7，H8 对应 bit 0。H1 的 PC 还有一个合并细节：若
`ibdp_pcfifo_if_h0_vld` 为 1，`h1_cur_pc` 选 H0 的 current PC；否则选 H1
current PC。这是上游 half-word 拼接留下的接口语义，不能只按信号名认定 H1 PC
永远来自 `h1_cur_pc` 输入。

`pcfifo_if` 用 priority case 找程序序最靠前的两个有效项，输出
`create0/create1`。这里“8 个位置”不等于一拍 8 条完整指令；RVC 使指令边界以
16-bit half-word 表示，32-bit 指令会占两个位置。

这个模块本身没有状态寄存器或本地时钟，选项、mask 和两组 create payload 都是
组合逻辑。真正是否在边沿创建 PCFIFO 项由 IU 侧存储体根据
`create*_en` 采样；`create*_gateclk_en` 是给消费者准备局部时钟的条件，不等同于
create 事务有效。例如 IB 路径下 `inst0_vld=1` 可使 gateclk-enable 拉高，但
`create0_en` 还要求 `ibctrl_pcfifo_if_create_vld=1`。

若窗口里超过两个 `pc_oper`：

1. `pcfifo_if_ibctrl_more_than_two` 拉高；
2. `over_mask` 标记前两个之后尚未处理的位置；
3. IB 级阻止一次性越过这些控制流；
4. 后续周期继续处理剩余部分。

这是一个前端元数据带宽边界：`ct_ifu_pcfifo_if` 每次最多向 IU 提交两个
`pc_oper` 描述。它不等于 IU PCFIFO 存储阵列内部只有两个物理写使能；IU 会根据
`jal/jalr/dst_vld` 等字段进一步展开自身 create 控制。对 IFU 而言可以确定的是，
同一八 half-word 窗口若含三项或更多 `pc_oper`，必须分轮处理，因而控制流密集
代码可能先受这个跨模块描述接口限制。

`more_than_two` 的实现没有输出完整 population count。`hn_pc_mask_head` 清除
程序序最前的置位及其之前部分，`hn_pc_mask_tail` 清除程序序最后的置位及其之后
部分，再对两者按位与并做归约 OR；这等价于检查首尾之间是否还有第三个置位。
“这样缩短组合路径”是根据 RTL 注释 `seperate ... to save timing` 得到的设计
意图，而不是本文给出的 STA 结论。其布尔不变量是：

```text
more_than_two == 1  <=>  hn_pc_oper 中至少有 3 个 1
```

### 1.3 创建内容

每个创建端口包含：

| 字段 | 来源/用途 |
|---|---|
| `cur_pc[39:0]` | IFU 内部 39-bit、已省略架构 bit 0 的 PC 末尾补 0，恢复 40-bit 字节地址 |
| `tar_pc[39:0]` | 返回预测时为 RAS 目标；否则为 Indirect BTB 目标减去 `jalr` immediate 后的预处理值，仅对相应控制流类型有意义 |
| `jal/jalr/dst_vld` | BJU 检查与链接类操作 |
| `bht_pred` | 当时预测方向 |
| `chk_idx[24:0]` | `{pre_result[0], sel_result[1:0], vGHR[21:0]}` |
| `jmp_mispred` | 直接接自 `ibctrl_pcfifo_if_ind_btb_miss`；只应结合相应间接跳转描述解释 |

间接跳转保存的 `target_pc` 在 IFU 侧做如下 40-bit 运算：

```text
pcfifo_ind_target_pc =
    {predicted_indirect_target_internal[38:0], 1'b0}
  - sign_extend(ind_br_offset[20:0])
```

BJU 随后可以把该预处理值与源寄存器基址配合检查，而不必在目标比较点重新形成
完全相同的 `src1 + immediate` 表达式。RTL 注释明确把这解释为后端时序考虑；
“一定从关键路径移除了一个加法器”仍属于需要综合/STA 证明的物理实现结论，不能
只由减法表达式的位置保证。

若第一个选中项是条件分支，第二项的 vGHR 使用
`{ibdp_pcfifo_if_vghr[20:0], 1'b0}`。这里移入的不是任意
`inst_bht_pre_result`，而是固定的 0，即 not-taken。原因可以从控制流可达性理解：
若第一条条件分支预测 taken，顺序窗口中它后面的第二个 `pc_oper` 不应继续沿当前
fall-through 路径被创建；能与第二项同时出现的前一条件分支语义应是预测
not-taken。这个解释仍依赖上游窗口裁剪协议，波形核查应确认“inst0 条件分支 +
inst1 有效”时 inst0 的实际预测方向确为 0。

### 1.4 LBUF 路径

`lbuf_pcfifo_if_create_select` 为 1 时，create0 的 enable、PC、target、BHT 和
vGHR 元数据改由 LBUF 接口提供，`jal/jalr/dst_vld/jmp_mispred` 则在该选择下被
固定为 0；create1 enable 被固定为 0。调波形时必须同时看这个 select，否则会
误以为 IB 数据通路的 `inst0_vld` 与 create0 内容不一致。

### 1.5 推荐波形

```text
ibdp_pcfifo_if_hn_pc_oper[7:0]
inst0_vld / inst1_vld
inst0_cur_pc / inst1_cur_pc
pcfifo_if_ibctrl_more_than_two
pcfifo_if_ibdp_over_mask[7:0]
lbuf_pcfifo_if_create_select
ifu_iu_pcfifo_create0_en
ifu_iu_pcfifo_create1_en
ifu_iu_pcfifo_create0_cur_pc[39:0]
ifu_iu_pcfifo_create0_chk_idx[24:0]
iu_ifu_pcfifo_full
```

要证明 PCFIFO 限宽造成停顿，应同时满足：窗口有至少三个 pc_oper、
`more_than_two=1`、IB 没有异常/其他 stall，并观察下一拍剩余 mask 被继续处理。

## 2. `ct_ifu_vector`：复位和异常入口 PC

### 2.1 名称澄清

这里的 “vector” 指 **exception vector/复位向量**，不是 RISC-V V 扩展的向量
执行单元。真正的向量/浮点执行逻辑在 VFPU。

当前生成 RTL 只启用三个 one-hot 状态：

```text
RESET --cp0_ifu_rst_inv_done--> IDLE
IDLE  --rtu_ifu_xx_expt_vld--> PCLOAD
PCLOAD -----------------------> IDLE
```

源文件中 `PHYADD/WAIT/CACHE/MISS/EXP` 等状态已被注释，不属于当前硬件。不能根据
保留注释把它描述成一条“异常向量 I-Cache 专用取数流水线”。

### 2.2 RESET 为什么等待 invalidate

复位后状态机停在 RESET：

- `ifu_xx_sync_reset` 保持有效；
- `vector_rst_inv_ff` 异步复位为 0；RESET 状态下第一次有效状态机时钟边沿会把
  它置为 1，所以组合式
  `ifu_cp0_rst_inv_req = RESET && !vector_rst_inv_ff` 在复位释放后的首个有效
  RESET 阶段形成一次请求电平。正常连续开钟时它表现为单周期脉冲，但“单周期”
  是相对于 `vec_sm_clk` 有效边沿而言；
- `pc_load` 在仍处于 RESET 且 `cp0_ifu_rst_inv_done==1` 的周期即可成立，随后状态
  边沿才把 FSM 转到 IDLE。不能把 PC 装载误画成“先进入 IDLE，下一拍再 pcload”。

该握手保证 PCGEN 只有在 CP0 报告 reset invalidate 完成后才接受复位入口。
`vector_ifctrl_sm_start` 在纯 RESET 等待阶段不因 `vector_sm_on` 拉高，仅在非
RESET 的状态机活动或新异常有效时启动 IFCTRL 侧相关阻断，避免 RESET 等待
invalidate 时反过来阻止 invalidate，形成控制死锁。究竟哪些预测/缓存结构包含
在 `cp0_ifu_rst_inv_done` 的完成范围内，应以 CP0/IFCTRL 的复位失效协议为准，
不能在本模块笼统扩展为“所有旧微结构状态均已清空”。

### 2.3 异常/中断入口

`rtu_ifu_xx_expt_vec[5]` 表示 interrupt，低 5 位为 cause 索引。RTL 把
`cp0_ifu_vbr[1:0]` 视作模式位，但地址计算只检查 `expt_mode[0]`；在 CP0 只产生
规范允许编码的前提下，它对应 vectored 模式。若该位为 1 且当前事件为中断：

```text
入口 = VBR base + cause * 4 byte
```

RTL 内部 PC 省略架构地址最低位，因此基址使用
`{cp0_ifu_vbr[39:2],1'b0}`，偏移在内部表示中是 `cause << 1`；换回字节地址后
就是 `cause << 2`。`reset_expt` 的精确方程只是
`rtu_ifu_xx_expt_vec[4:0] == 0`，它不检查 `expt_vld` 或 interrupt 位；该条件
成立时 `virtual_pc` 选择 `cp0_ifu_rvbr[39:1]`。将 cause 0 解释为复位是当前
RTU/CP0 接口编码约定，不是由这个比较式单独证明的 RISC-V 通用规则。

`nonvec_pc` 在 `vector_pc_update_clk` 的有效边沿锁存入口。该门控时钟在异常有效
时开启；RESET 状态下若 `reset_expt` 为 1 也开启，以提前保存 RVBR。普通异常使
FSM 从 IDLE 转入 PCLOAD，随后 PCLOAD 状态的组合 `pc_load` 把已锁存入口送到
PCGEN。若 debug mode 有效，状态寄存器在有效边沿强制回 IDLE，同时
`pc_load` 组合式被 `!rtu_ifu_xx_dbgon` 屏蔽，避免遗留 PCLOAD 与调试 PC 接管
冲突。

这里的“开启”特指 `vector_pc_update_clk_en` 这个 local-enable。技术 ICG 分支
中 `cp0_ifu_icg_en` 可以覆盖 local-enable，非技术分支则直接传递
`forever_cpuclk`；真正字段更新还取决于 always 块内
`rtu_ifu_xx_expt_vld || reset_expt`。特别是 `reset_expt` 只比较 cause 低五位，
没有与 RESET 状态相与，因此在 module-enable 强制开钟的调试模式下，不能仅看
local-enable 推断 `nonvec_pc` 是否保持，仍应同时观察 update 条件和新值。

### 2.4 正确性不变量

1. RVBR 可以在 RESET 等待期间预先锁存，但 `vector_pcgen_pcload` 只能在 reset
   invalidate 完成后拉高；“锁存候选入口”和“让 PCGEN 采用入口”是两个事件。
2. direct 模式所有异常/中断进入 VBR base。
3. vectored 模式只对 interrupt 加 cause 偏移。
4. 内部 39-bit PC 表示架构地址 `[39:1]`；与外部 40-bit byte PC 换算时必须
   补回固定的 bit 0，向量偏移也必须在同一表示域内计算。
5. debug 接管时不能残留一个延迟 PCLOAD。

推荐波形：

```text
vec_cur_state[9:0]
rtu_ifu_xx_expt_vld
rtu_ifu_xx_expt_vec[5:0]
cp0_ifu_rvbr[39:0]
cp0_ifu_vbr[39:0]
nonvec_pc[38:0]
ifu_cp0_rst_inv_req
cp0_ifu_rst_inv_done
vector_pcgen_pcload
vector_pcgen_pc[38:0]
rtu_ifu_xx_dbgon
```

## 3. `ct_ifu_debug`：事件发生时的状态快照

### 3.1 它不是性能计数器

`ct_ifu_debug` 把 IFU 多个阶段的 stall、valid、异常和状态机编码拼成
`had_debug_info[82:0]`。只有

```verilog
had_rtu_xx_jdbreq && !rtu_ifu_xx_dbgon
```

成立时，83-bit 组合值才在 `forever_cpuclk` 上升沿锁存到
`ifu_had_debug_info`。`dbg_ack_info` 只是该模块内部的采样使能名称，本文件没有
用 ready/accept 握手证明 HAD 请求已被其他模块“接受”；更准确的说法是：
`had_rtu_xx_jdbreq==1 && dbgon==0` 的采样边沿快照。该总线不会逐周期自动累计，
也不是“最近 83 个事件”。

### 3.2 位域

| 位 | 内容 |
|---|---|
| 82:69 | `pcgen_debug_pcbus[13:0]`，只是 PCGEN 提供的 14-bit 调试摘要，不是完整 40-bit PC |
| 68:59 | IB/IP/IF stall、mispred、FIFO、Indirect BTB、边界和 refill stall |
| 58:52 | IF PC valid、way predict stall、MMU/访问/IB 异常 |
| 51:36 | IBUF/LBUF/bypass/三槽 valid、各流水级 valid、改流等 |
| 35:34 | L0 BTB 状态 |
| 33:28 | LBUF 状态 |
| 27:24 | L1 refill 状态 |
| 23:20 | IPB request 状态 |
| 19:17 | IPB writeback 状态 |
| 16:13 | I-Cache invalidate 状态 |
| 12:3 | vector/reset 状态 |
| 2:0 | VFDSU busy/wait/idle |

`ifu_had_reset_on` 直接、组合地来自 `vector_debug_reset_on`。它不在
`had_debug_info[82:0]` 拼接范围内，也不受 `dbg_ack_info` 锁存；因此它表示当前
RESET 状态电平，而 `ifu_had_debug_info` 表示过去某个采样边沿的快照。两者在
同一观察周期不一定对应同一个历史时刻。

与 IFU 中大量状态寄存器不同，debug 快照没有经过
`gated_clk_cell`，而是直接在 `forever_cpuclk` 上由 `dbg_ack_info` 做同步使能。
因此 `jdbreq=0` 时看到主时钟持续翻转是预期行为，寄存器本身通过 enable 分支
保持；不能把它归因为遗漏了某个局部门控时钟。

### 3.3 如何正确使用

调试一次前端停顿时：

1. FSDB 中先看原始内部信号的逐周期变化。
2. 再在 `dbg_ack_info` 对应的主时钟采样边沿解码 `ifu_had_debug_info`，确认模块
   锁存的快照。
3. 不要用锁存后的总线推断快照前后每一拍发生了什么。

调试打包位域时，应把 `had_debug_info`（当前组合值）与
`ifu_had_debug_info`（最近一次符合采样条件时的锁存值）同时加入波形。两者在
普通周期不同是正常现象；只有在 `dbg_ack_info` 有效的采样边沿之后，才应按
非阻塞赋值时序检查锁存值是否取得该边沿前的组合快照。`pcgen_debug_pcbus` 位宽
只有 14 位，若需要定位完整指令地址，必须同时观察 PCGEN/IF/IP/IB 的完整内部 PC，
不能只依赖该摘要反推高位。

## 4. 三个模块的共同体系结构意义

这三个模块分别跨越 IFU 与 IU、RTU/CP0、HAD 的边界。跨模块逻辑最容易出现
“单个模块局部看都对，拼起来错一拍”的问题：

- PCFIFO 接口要求预测现场与后端 pid 严格对应；
- vector 要求异常入口、invalidate 和 debug PC 接管严格排序；
- debug 要求组合状态与握手采样周期严格对应。

验证这类机制不能只看最终程序是否跑完，应建立端到端事务：找到生产事件，跟踪
编码/握手/寄存，最后在消费者端确认同一事务的身份和周期。
