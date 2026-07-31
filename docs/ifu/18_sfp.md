# C910 SFP 详解（`ct_ifu_sfp`）

> RTL 依据：`ct_ifu_sfp.v`、`ct_ifu_sfp_entry.v`、`ct_ifu_ifdp.v` 以及
> RTU 的 no-spec/VL 反馈接口。SFP 在 RTL 注释中写作 **Spec Fail
> Predictor**，本文称“推测失败预测器”，不把它误解为 store filter。

## 1. 为什么前端要预测存储相关行为

乱序核会让 load 在更老的 store 地址或数据尚未完全确定时投机执行。投机成功可
隐藏延迟；若同一 load 经常与更老 store 冲突，就会反复触发 replay/改流。

SFP 的作用是把后端已经观察到的 no-spec 结果反馈到取指侧，让某些 PC 在再次
进入流水线时携带特殊提示。模块接口和内部条目还保留 `vsetvli`/VL 预测逻辑，
因此从 RTL 结构看，它不是单一用途的“load PC 黑名单”。

需要同时说明当前生成配置的边界：`ct_idu_id_decd.v` 将 `x_vec_inst` 固定为 0，
`ct_cp0_regs.v` 将 `misa_vector` 固定为 0。也就是说，SFP 中的 VL 数据通路真实
存在于 RTL，但在当前配置的正常有效指令流中不应把它当作已启用的 RVV 功能。
本文仍解释该保留路径，目的是准确阅读 RTL 和波形，而不是宣称当前核已实现可用
RVV。

```text
RTU 退休反馈
  no_spec_hit/miss/mispred + load/store + PC
  vl_pred/hit/miss/mispred + PC
                    |
                    v
             12 项全相联 SFP
       PC 对 + 类型 + 2-bit 置信度
                    |
                    v
      IFDP: pc_hit + hit_type + 块内位置
```

## 2. 真实组织

`ct_ifu_sfp.v` 实例化 12 个 `ct_ifu_sfp_entry`。所有条目并行比较，没有 SRAM
索引；替换选择使用 12-bit 循环 one-hot `sfp_entry_fifo`。

每项状态为：

| 字段 | 位数 | 作用 |
|---|---:|---|
| `entry_hi_pc` | 8 | PC 比较高部 |
| `entry_sf_pc` | 12 | 推测失败/store/VL 一侧的 PC |
| `entry_bar_pc` | 12 | RTL 名称为 BAR 的另一侧 PC；当前写条件实际来自 load 反馈 |
| `entry_cnt` | 2 | 饱和置信度，同时承担“是否可预测”的门槛 |
| `entry_type` | 1 | 区分 VL 类条目 |
| `entry_miss_state` | 1 | 保存 VL miss 相关状态，参与后续计数更新 |

没有独立 valid 位。普通 SF/BAR 命中要求 `entry_cnt[1] == 1`，即计数为 2 或 3；
VL raw hit 只要求计数非零。复位把计数清零，因此旧 PC 位即使相等也不会形成
普通有效预测。

## 3. PC 表示与比较

`ct_ifu_pcgen.v` 直接令 `pcgen_sfp_pc[16:0] = if_pc[19:3]`。IFU 内部
`if_pc[38:0]` 保存省略架构地址 bit 0 后的 PC，因此这里对应架构字节地址
`[20:4]`，以 16-byte 地址块为比较粒度。每项把退休接口送来的内部低 20-bit
PC 拆成：

```text
entry_hi_pc[7:0] + entry_*_pc[11:3]  -> 与当前块 PC 比较
entry_*_pc[2:0]                       -> 命中指令在块内的位置
```

输出 `sfp_ifdp_hit_pc_lo[2:0]` 取自 `entry_*_pc[2:0]`，对应内部 PC 的三位、
也就是架构地址 `[3:1]`。它不是完整 PC，也不是 0 到 15 的四位 byte offset。
恢复架构字节地址时，应把当前块的 `[20:4]`、该信号的 `[3:1]` 和固定的
`bit 0 = 0` 拼接起来；直接把三位数值当字节偏移会得到少一位的错误地址。

SFP 不保存架构 PC `[39:21]`。因此相差整数个 2 MiB、但低
`PC[20:4]` 相同的代码块会比较命中同一组 entry 字段；这是容量之外的地址别名，
不能把 `sfp_*_pc_hit` 直接称为完整-PC 命中。

## 4. 两类 PC 为什么成对保存

SFP 不只记录“哪条 load 失败”，还尝试记住导致限制的另一侧 PC。RTL 中：

- `entry_sf_pc` 用于 SF/store/VL 一侧比较；
- `entry_bar_pc` 虽然名称含 `bar`，但当前
  `entry_bar_pc_updt_bit` 只由 load 的 miss 或 mispred 反馈形成，因此更准确地说
  它保存 load 对端 PC；不能仅凭名字断言这里检测了某种架构 barrier 指令；
- `sfp_sf_pc_record` 暂存退休 store 的 PC 特征，供后续 load 反馈查找已有条目。

这里还有一个具体的表达范围：entry 只保存一份共享
`entry_hi_pc=SF_PC[19:12]`。更新 load/BAR 对端时只写
`entry_bar_pc[11:0]`，不会改写 `entry_hi_pc`。所以 BAR 比较实际使用
`{SF_PC[19:12], BAR_PC[11:3]}`。只有 store/SF 与 load/BAR 的内部
PC `[19:12]` 相同，也就是架构字节地址 `[20:13]` 相同、在 SFP 可见的
modulo-2MiB 地址图像中落入同一 8 KiB 槽时，条目才能无损表示这对 PC；
高于 bit20 的地址仍可能彼此别名。若 store 与 load 的这 8 位不同，条目会形成
混合高低位，不能在该真实 load PC 上命中。

这是一种小型相关性预测结构：它尝试把“应抑制投机的消费者”与“导致冲突的
生产者/边界”联系起来。相比只给每个 load 一个 bit，它能记录一对块内位置，
但只有 12 项、截断 PC、共享高位以及全相联重复项都会限制可区分上下文。

## 5. 读路径

### 5.1 三组并行命中

1. `sfp_sf_pc_hit_raw[i]`：当前块 `[20:4]` 匹配第 `i` 项的
   `{entry_hi_pc, entry_sf_pc[11:3]}`；此时尚未检查计数器。
2. `sfp_sf_pc_hit[i]`：在 raw hit 基础上要求 `entry_cnt[i][1]==1`。
3. `sfp_bar_pc_hit[i]`：当前块匹配 `entry_bar_pc`，并要求
   `entry_cnt[i][1]==1`。
4. `sfp_vl_pc_hit_raw[i]`：SF PC raw hit、计数非零且 `entry_type[i]==1`。
5. `sfp_vl_pc_hit[i]`：SF PC raw hit、计数高位为 1 且 `entry_type[i]==1`。

汇总信号 `sfp_sf_hit` 是任一高置信 SF 命中，并排除已经被识别为 VL raw hit 的
情况。最终输出命中受 CP0 控制：

- `cp0_ifu_nsfe` 控制 no-spec/SF 预测；
- `cp0_ifu_vsetvli_pred_disable` 与 `pred_mode` 控制 VL 预测。

### 5.2 SF_RD/BAR_RD 的意义

`sfp_rd_cur_state` 在 `SF_RD` 和 `BAR_RD` 间切换，用来选择当前组合输出哪类
块内 PC。状态寄存器直接使用 `forever_cpuclk`，所以表中的“下一拍”指下一次主
时钟有效上升沿，而不是某个 entry 门控时钟。它不是流水线重放 FSM，也不表示
后端是否 stalled：

```text
SF_RD 看到 SF hit  -> 下一拍 BAR_RD
BAR_RD 仍看到 SF   -> 保持 BAR_RD
BAR_RD 看到 BAR    -> 回到 SF_RD
```

输出包含四个类型位：

| 位 | RTL 名 | 含义 |
|---:|---|---|
| 0 | `SF` | `sfp_sf_hit \|\| state==SF_RD`；包含当前读状态的默认类型编码，不等价于真实 SF hit |
| 1 | `BAR` | `!sfp_sf_hit && sfp_bar_hit && state==BAR_RD`；当前实现对应 load 对端类 |
| 2 | `VL` | 达到普通置信度的 VL 命中 |
| 3 | `VL_RAW` | 较低门槛的 VL 原始命中 |

消费者必须同时看 `sfp_ifdp_pc_hit`。尤其在复位后的 `SF_RD` 状态，即使 12 项
全未命中，`hit_type[SF]` 仍为 1；因此单独看到 `hit_type[0]` 不能断言本拍发生
预测命中。`hit_pc_lo` 也由 SF/VL 命中和当前读状态共同选择，只有在 `pc_hit`
成立时才具有一次有效预测的语义。

`sfp_rd_next_state` 使用未与 `cp0_ifu_nsfe` 相与的
`sfp_sf_hit/sfp_bar_hit`。因此关闭 no-spec prediction 会屏蔽 `pc_hit` 对
IFDP 的影响，但不会冻结这个两态选择器；已有高置信条目仍可能让状态在后台切换。
重新使能后应以当时状态和实际 `pc_hit` 联合解释，不能假设 disable 期间状态
恒为 `SF_RD`。

## 6. 退休反馈与写缓冲

RTU 一拍可提供 3 个退休槽。组合 `casez` 只选择最老的一个有效反馈：

```text
优先 retire0，其次 retire1，最后 retire2
updt_type = {hit, miss, mispred}
inst_type = {VL, store, load}
updt_pc   = 对应退休 PC 的低 20 位
```

这里的“有效反馈”并非三个槽完全对称：retire0 接受 no-spec 三类、`vl_pred` 和
`vl_miss`，并有独立的 `vl_hit/vl_miss/vl_mispred` 用于组成 update type；
retire1/2 只把各自的 `vl_pred` 合并进 hit 类条件，没有对应的 VL miss/mispred
输入参与本模块选择。若三个槽同拍都有反馈，retire1/2 的反馈不会排队保存，而是
被更老槽覆盖；能否在后续周期重送由 RTU 接口协议决定，不能从 SFP 单模块推断。

反馈在 `sfp_wr_buf_updt_vld` 成立后的写缓冲门控时钟边沿进入
`wr_buf_*_record`，同时把 `wr_buf_updt_vld` 置 1。条目比较、选择和
`entry_write_en` 使用这组已记录值；对应 entry 在其门控时钟有效边沿更新。
若下一拍没有新反馈，写缓冲边沿再清除 `wr_buf_updt_vld`。因此在无额外门控/暂停
影响的典型波形中，RTU 反馈与 entry 改变相隔一个流水阶段；不能只按信号文本顺序
把它们理解为同拍组合写表。

## 7. 条目选择与置信度

写选择有三类：

- `sfp_wr_fifo_select`：update type 为 miss、指令类型为 store 或 VL、写缓冲
  有效且 SF PC 未命中时，用 one-hot `sfp_entry_fifo` 指向的项新建；
- `sfp_wr_sf_pc_select`：SF/store/VL 侧 PC 已命中，更新已有项；
- `sfp_wr_record_select`：任意有效 load 反馈按最后记录的 store PC
  `sfp_sf_pc_record` 查找相关项；若该记录没有命中，`entry_write_en` 可以为全 0，
  并不会自动退化成新建条目。

`sfp_entry_fifo` 复位为 one-hot bit 0，每次轮转一位。但其轮转使能并不是
“每次新建”，而是严格的
`load && update_type.miss && wr_buf_updt_vld`；反过来，真正使用 FIFO 项新建的
条件是 store/VL miss 且未命中。这个交叉关系是当前 RTL 的实际连接。它可能是
反馈协议配对的一部分，也可能需要进一步定向验证；文档不能把它简化成普通的
“写满后循环替换”策略。

2-bit 计数器为饱和加减：

| `entry_write_data[3:0]` | 行为 |
|---|---|
| `1000` | store mispred：清零 |
| `0100` | hit：通常饱和加一，VL 特例可能清零 |
| `0010` | miss：置 `01` |
| `0001` | mispred：通常减一，特定 VL 改流条件下加一 |

计数器的教学意义是“迟滞”：一次偶发现象不会立即把条目变成强预测，也不会因
一次反例马上删除稳定相关性。代价是相位变化后需要若干次反馈才能重新收敛。

## 8. 非对称连接与验证边界

retire1 选择分支把 VL 类型位写成
`rtu_ifu_retire_inst0_vl_pred`，而同一分支的 PC、load/store 和 update type
来自 retire1；retire0/retire2 分支则各自使用对应槽。这个非对称连接是当前
可执行 RTL 的直接行为，但单凭本文件无法判断它来自上游协议约束还是生成过程
保留。修改 SFP 前应增加“只有 retire1 产生 VL 反馈”的定向仿真，确认 retire1
选择时采用 inst0 的 VL 类型位是否符合接口约定，再决定是否调整连接。

此外，源代码把 `sfp_wr_fifo_select` 附近注释为 store miss，却用另一处的 load
miss 来轮转 FIFO；个别 “load miss/store miss” 注释与布尔条件也不完全一致。
判断真实行为必须以 `inst_type`、`updt_type`、`entry_write_en` 和
`sfp_fifo_en` 方程为准，不能只读注释。

## 9. 正确性与性能边界

SFP 是性能提示结构。错误命中必须只能让后端更保守或触发可恢复预测，不能绕过
依赖检查、异常或退休顺序。需要保持：

1. 表项训练只使用 RTU 已确认反馈。
2. `pc_hit` 与 `hit_pc_lo/hit_type` 必须来自同一组命中选择。
3. 当前 SFP 没有以普通 pipeline flush 清空 12 项；写缓冲输入来自 RTU 退休反馈，
   所以不能把前端 flush 本身当作 SFP entry 的失效事件。
4. CP0 disable 后不能再让相关预测影响 IFDP。
5. 低位 PC 表示必须在 IFDP 中与当前 16-byte 地址块对齐，且恢复架构地址时补回
   固定的 bit 0。
6. 对保留的 VL 路径做结论时，必须注明当前 `x_vec_inst=0`、`misa_vector=0` 的
   配置边界，不能把结构存在等同于功能启用。
7. `entry_bar_pc` 与 `entry_sf_pc` 共用 `entry_hi_pc`；评估配对覆盖率时必须
   单列跨 8 KiB 子区域的 store-load 对，而不能只统计 12 项是否已占满。

性能上应同时统计覆盖率和准确率。SFP 命中少可能是 12 项容量不足，也可能是反馈
未建立置信度、PC 截断别名或配对跨 8 KiB；命中多但 no-spec 过度则可能降低
load 并行性。

### 9.1 门控时钟边界

写缓冲、store-PC 记录、替换位和每个 entry 都有独立
`gated_clk_cell`。entry 的功能更新条件还显式要求
`cp0_ifu_nsfe || sfp_vl_pred_en`；即使技术 ICG 的 module-enable 让局部时钟
翻转，`entry_*_updt_en` 为 0 时字段仍保持。未定义
`C910_USE_TSMC28_ICG` 时局部时钟在 RTL 中直接跟随主时钟，更不能用时钟是否
翻转代替 `entry_write_en/entry_*_updt_bit`。波形确认一次训练应按
“RTU feedback -> write-buffer record -> entry_write_en -> 字段 update-enable
-> entry 新值”的链条观察。

## 10. Verdi 观察方法

```text
pcgen_sfp_pc[16:0]
sfp_pc_hi_hit[11:0]
sfp_sf_pc_hit_raw[11:0]
sfp_sf_pc_hit[11:0]
sfp_bar_pc_hit[11:0]
sfp_vl_pc_hit_raw[11:0]
sfp_ifdp_pc_hit
sfp_ifdp_hit_type[3:0]
sfp_ifdp_hit_pc_lo[2:0]
sfp_rd_cur_state[1:0]

sfp_wr_buf_updt_vld
sfp_wr_buf_updt_type[2:0]
sfp_wr_buf_inst_type[2:0]
wr_buf_updt_vld
wr_buf_updt_pc_record[19:0]
entry_write_en[11:0]
entry_write_data[24:0]
sfp_entry_fifo[11:0]

x_ct_ifu_sfp_entry_*/entry_cnt_v[1:0]
x_ct_ifu_sfp_entry_*/entry_sf_pc_v[11:0]
x_ct_ifu_sfp_entry_*/entry_bar_pc_v[11:0]
```

先从 RTU 反馈找到一次 update，再在后续写缓冲有效阶段看记录值，最后确认
`entry_write_en` 和目标 entry 的计数/PC 改变。正常无别名时通常期望 one-hot
写使能，但比较逻辑本身没有强制多个重复 PC 条目只能命中一个；若
`wr_buf_hit_sf_pc` 或 `sf_pc_hit_sf_pc` 多位同时为 1，已有项更新路径可能形成
多位 `entry_write_en`。因此波形中应“检查是否 one-hot”，而不是先验断言一定
exactly one。读命中分析则反向进行：从 `sfp_ifdp_pc_hit` 找命中向量，再检查
PC、类型、计数器以及是否出现多项别名。
