# C910 异常缓冲详解（ct_rtu_rob_expt）

> RTL 源文件：`C910_RTL_FACTORY/gen_rtl/rtu/rtl/ct_rtu_rob_expt.v`（822 行）
>
> 在 ct_rtu_rob 内部例化。它回答一个问题：**多个异常或恢复类完成事件乱序到达时，
> 怎样保存当前已经观察到的、程序序最老的那个事件？** 答案是一个 70 位单项缓冲
> 加年龄仲裁。这里的 “abnormal” 范围比 RISC-V 架构 trap 更宽。

---

## 1. 设计动机：异常缓冲为什么只要一项

对于架构异常，只有程序序最老、最终走到 ROB 头部的异常能够被精确提交；其后的
推测状态会被 flush。C910 还把分支误预测、LSU spec fail 和若干 instruction
flush 原因复用到同一个缓冲中，所以更准确的不变量是：

> `expt_entry` 保存当前所有**已到达异常完成接口且仍有效**的 abnormal 事件中，
> IID 最老的一个。

它不是“全 ROB 最老未退休指令”，也不保证尚未完成的更老 abnormal 已经被看见。
如果更老事件稍后完成，它会重新参加仲裁并替换当前项。ROB 的顺序退休保证更年轻
事件不能越过仍未完成的更老指令先被消费；这才是单项缓冲足够的关键前提。

```
 pipe0(IU)   ┐ abnormal cmplt
 pipe2(BJU)  ┤      ┌──────────────────────────┐
 pipe3(LSU L)┼─────►│ 擂台：5 路年龄两两比较      │──► expt_entry (70位,单项)
 pipe4(LSU S)┘      │ 最老者上位/守擂            │      │
                    └──────────────────────────┘      ▼
                       ▲ 当前擂主 expt_entry_iid    退休时 inst0 iid 匹配
                                                        → trap 或恢复处置
```

只有 pipe0/2/3/4 接入这个 abnormal 缓冲接口；这表示当前 RTL 只从这些完成源
接收这类恢复元数据，并不等价于宣称其他执行管线在体系结构上“永远不可能产生任何
异常”。pipe2 的 abnormal 负载主要是分支误预测恢复信息，不是 RISC-V trap。
完成总线的分工见 `docs/iu/07_cbus.md`。

## 2. 逐逻辑块讲解

### 2.1 年龄擂台（L338-476）

10 个 `ct_rtu_compare_iid` 实例（L343-442）两两比较 5 个候选：
pipe4、pipe3、pipe2、pipe0 的新完成 + 现任擂主（expt_entry）。

胜者判定是标准的"全胜才上位"逻辑（L452-476）：

```verilog
assign expt_entry_write_sel[4] = pipe4_expt_cmplt        // 自己有异常完成
         && (!pipe3_expt_cmplt || pipe4_older_3)         // 且比每个对手老
         && (!pipe2_expt_cmplt || pipe4_older_2)
         && (!pipe0_expt_cmplt || pipe4_older_0)
         && (!expt_entry_vld   || pipe4_older_e);        // 且比现任擂主老
...
assign expt_entry_write_sel[0] = expt_entry_vld && 所有挑战者都不比我老;  // 守擂
```

5 位独热 sel 选出写入数据（L542-559）。其中四路是本拍新候选，一路是
`expt_entry_vld` 使能的现存候选；现存项无效时，它的 IID 数值没有年龄含义，
比较结果也必须由 valid 条件屏蔽。

**为什么一项就够？** 仲裁器不需要在某一拍预知尚未完成的异常。任何更老 abnormal
将来完成时都会作为新候选重新挑战；在它完成之前，ROB 又不会让位于它之后的当前
候选越过队头退休。因此，缓冲始终维护“当前已知最老”，而“真正被 inst0 消费”
这一时刻才要求它同时也是可提交的最老事件。

### 2.2 异常现场打包（L478-540）

70 位 `expt_cmplt_data` 各管线统一格式：

```
[6:0]iid [7]expt_vld [12:8]expt_vec [13]high_hw_expt [14]immu_expt
[54:15]mtval[39:0] [55]bht_mispred [56]jmp_mispred [57]flush [58]bkpt
[59]spec_fail [60]efpc_vld [61]vsetvl [62]vstart_vld [69:63]vstart
```

输入打包确实为 `expt_vec[4:0] -> data[12:8]`，但当前有效输出只连接
`expt_entry_expt_vec[3:0]=data[11:8]`；`data[12]` 的输出赋值在源码中被注释，
retire 端再把 4 位异常号扩成 `{2'b0, expt_vec[3:0]}`。因此，不能因为缓冲内
保留了 5 位就宣称当前 trap 路径消费 5 位同步异常号。这个区别是“存储格式”
与“当前有效消费者接口”的区别。

各管线只填自己拥有的字段（L478-540）：pipe2 提供分支误预测相关位；pipe3/4
可提供 spec fail 和 LSU 相关地址/异常信息；pipe0 提供整数/系统类异常与
instruction flush 元数据。其中 pipe3/4 把 40 位 `mtval` 原样写入，pipe0
只提供 32 位 `mtval` 并在高 8 位补零。字段被装入缓冲只表示“随最老
abnormal 保存”，
是否形成架构 trap 仍由 `expt_vld`、退休 inst0 匹配和 retire 端仲裁共同决定。
因此，不能看到 `expt_entry_vld=1` 就直接计为一次架构异常。

### 2.3 有效位与消费（L561-627）

```verilog
// L570-584
else if(retire_rob_flush || rtu_yy_xx_flush) expt_entry_vld <= 0;  // 恢复阶段作废
else if(expt_cmplt)                          expt_entry_vld <= 1;
else if(retire_expt_inst0_vld && retire_expt_inst0_abnormal) expt_entry_vld <= 0; // 被消费
```

L574-575 注释点出微妙处：flush 时清擂台，但**错误路径指令可能在 flush 窗口
内又报异常**——所以清除条件同时挂在 retire_rob_flush 和 rtu_yy_xx_flush
两个阶段（flush 状态机期间持续压制）。

消费端（L622-627）：退休 inst0 的 iid 与擂主 iid 匹配（`retire_expt_inst0_abnormal`
由 rob_rt 做匹配）且 `expt_entry_expt_vld` 为真 → `rob_retire_inst0_expt_vld`
→ retire 模块走 trap 流程（04_retire.md）。若擂主只是误预测/spec_fail/flush
标记（expt_vld=0），则走对应的非 trap flush 流程。

### 2.4 拆分指令 spec fail 状态机（L656-810）

某些指令被 IDU 拆成多个微操作（split）。如果 LSU pipe3/4 报告
`split_spec_fail`，恢复边界不能随意落在拆分组内部；当前 RTL 用一个三态 FSM
把恢复点推迟到拆分组之后。这段 FSM（L696 起）的准确时序是：

- 记录拆分组中最老的 spec fail iid（L751-810 又是一组 compare_iid 擂台，
  比较 pipe3/pipe4/已记录值）；
- 强制进入**单退休模式**（`rob_retire_split_spec_fail_srt`，注释 L741-742：
  "to simplify the design, enable srt"），先在 `WF_RETIRE` 中等待记录的
  `ssf_iid` 到达退休槽 0；
- 命中该 IID 后转入 `RETIRING`，继续以单退休方式越过后续 split 项；
- `RETIRING` 中遇到第一个有效的非 split 退休项时，
  `ssf_split_spec_fail_flush` 拉高，该非 split 项形成
  `rob_retire_inst0_inst_flush`。retire 模块随后以这个非 split 项的
  `rob_retire_inst0_cur_pc` 作为 `rtu_ifu_chgflw_pc`，从该架构边界重新取指；
- 回传 LSU 的 `rtu_lsu_spec_fail_iid` 仍选择先前记录的 `ssf_iid`，因此
  “IFU 从哪里重新取”与“LSU 中哪一个 IID 是原始违例来源”不是同一个标识。

所以，这套逻辑的直接 RTL 结论是：**不在拆分组内部 flush，而是在紧随其后的
第一个非 split 边界恢复**。不能把它写成“只重跑违例微操作”，也不能写成
“从拆分组头重取”；后者与当前 `rtu_ifu_chgflw_pc` 的实际选择不符。

## 3. 与 LSU spec fail 的闭环

`rtu_lsu_spec_fail_iid`（retire.v:2056-2070）把触发 flush 的违例指令 IID
回传 LSU，供 LSU 的 spec-fail 处理/预测路径定位相应事件。某次 perf 日志中的
`LSU Spec Fail` 数值是具体 workload、输入、编译选项和采样区间的动态结果，
不能写成该硬件通路的固定次数；做闭环验证时应同时对齐 pipe3/4 的 spec-fail
完成、异常缓冲入选、退休 inst0 匹配和 LSU 回传 IID。

## 4. Verdi 观察建议

层次：`...x_ct_rtu_rob.x_ct_rtu_rob_expt`

| 信号 | 看什么 |
|------|--------|
| `expt_entry_vld / expt_entry_iid` | 擂台上挂着谁 |
| `expt_entry_write_sel[4:0]` | 换擂主的瞬间（多路同拍异常很罕见，能抓到说明用例好） |
| `expt_entry_expt_vec/mtval` | 异常现场 |
| `rob_retire_inst0_expt_vld` | 异常被退休"认领"→ 下一拍看 retire 的 flush FSM |

跑 exception case：ecall 从 IU pipe0 进擂台；跑 bench_mem 类可看 LSU
spec_fail 进擂台但 expt_vld=0 的"非 trap flush"路径。
