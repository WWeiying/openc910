# C910 异常缓冲详解（ct_rtu_rob_expt）

> RTL 源文件：`C910_RTL_FACTORY/gen_rtl/rtu/rtl/ct_rtu_rob_expt.v`（822 行）
>
> 在 ct_rtu_rob 内部例化。它回答一个问题：**乱序完成的多条异常指令，
> 怎样只留下"程序序最老"的那个异常？** 答案是一个 70 位的单项擂台。

---

## 1. 设计动机：异常缓冲为什么只要一项

精确异常的规则：只有**最老的**未退休异常才会真正发生——它退休时触发 trap
并 flush 之后所有指令，更年轻的异常随之作废。所以同一时刻 RTU 只需要记住
一个异常现场。把 mtval/expt_vec 等 50+ 位放进 64 项 ROB 是浪费，
单独一项 + 年龄仲裁就够了。

```
 pipe0(IU)   ┐ abnormal cmplt
 pipe2(BJU)  ┤      ┌──────────────────────────┐
 pipe3(LSU L)┼─────►│ 擂台：5 路年龄两两比较      │──► expt_entry (70位,单项)
 pipe4(LSU S)┘      │ 最老者上位/守擂            │      │
                    └──────────────────────────┘      ▼
                       ▲ 当前擂主 expt_entry_iid    退休时 inst0 iid 匹配 → trap
```

只有 pipe0/2/3/4 接入——它们是会报 abnormal 的管线（pipe1/6/7 无异常，
见 doc/iu/07_cbus.md）。注意 pipe2 的"异常"其实是误预测标记。

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

5 位独热 sel 选出写入数据（L542-559）。**为什么敢只比一轮？** 因为任何
更老的异常将来完成时还会再来挑战；擂台保证的不变量是"当前已知最老"，
最终退休判定时它必然已收敛到全局最老（异常指令退休前必已完成）。

### 2.2 异常现场打包（L478-540）

70 位 `expt_cmplt_data` 各管线统一格式：

```
[6:0]iid [7]expt_vld [12:8]expt_vec [13]high_hw_expt [14]immu_expt
[54:15]mtval[39:0] [55]bht_mispred [56]jmp_mispred [57]flush [58]bkpt
[59]spec_fail [60]efpc_vld [61]vsetvl [62]vstart_vld [69:63]vstart
```

各管线只填自己有的字段（L478-540）：pipe2 只有 mispred 两位；pipe3/4 带
spec_fail（LSU 顺序违例）和 40 位访存地址 mtval；pipe0 带 immu_expt/bkpt/
vsetvl/efpc。**spec_fail、误预测、vsetvl flush 都走异常缓冲**——它们不是
trap，但同样需要"最老者退休时触发 flush"的语义，复用同一套机制。

### 2.3 有效位与消费（L561-627）

```verilog
// L570-584
else if(retire_rob_flush || rtu_yy_xx_flush) expt_entry_vld <= 0;  // 与ROB同流合污地清
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

向量/原子指令被 IDU 拆成多个微操作（split），若其中某个微操作发生 LSU
spec fail（顺序违例需重执行），**不能只重跑那一个微操作**——拆分组必须
作为整体处理。这段 FSM（L696 起）：

- 记录拆分组中最老的 spec fail iid（L751-810 又是一组 compare_iid 擂台，
  比较 pipe3/pipe4/已记录值）；
- 强制进入**单退休模式**（`rob_retire_split_spec_fail_srt`，注释 L741-742：
  "to simplify the design, enable srt"），让拆分组的 flush 边界清晰；
- 退休到该组时触发 spec_fail flush，从组头重取。

## 3. 与 LSU spec fail 的闭环

`rtu_lsu_spec_fail_iid`（retire.v:2056-2070）把触发 flush 的违例指令 iid
回传 LSU，LSU 的 `spec_fail_predict` 模块据此训练，下次对同地址 load 保守
执行——perf 报告中的 `LSU Spec Fail 169` 次就是这条通路的计数。

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
