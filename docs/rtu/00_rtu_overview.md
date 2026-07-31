# C910 RTU 总览（ct_rtu_top）

> RTL 源文件：`C910_RTL_FACTORY/gen_rtl/rtu/rtl/ct_rtu_top.v`（2475 行）
>
> 与 IU/IFU 顶层一样，ct_rtu_top 是结构性顶层，例化 6 个子模块并连线。
> RTU 的全部智慧在子模块里，但接口分组值得在这里先看全。

---

## 1. RTU 解决什么问题

乱序核把指令打乱执行，但体系结构状态（寄存器、PC、CSR）必须表现得像顺序
执行一样。这要求三件事，分别由 RTU 的三大件承担：

| 问题 | 答案 | 模块 |
|------|------|------|
| 谁先谁后？乱序完成的指令如何按序生效 | ROB：按程序序排队，队头完成才退休 | ct_rtu_rob |
| 异常指令后面的指令已经执行了怎么办 | 异常缓冲 + flush 状态机：退休时才认账，之后全部作废重来 | ct_rtu_rob_expt / ct_rtu_retire |
| 旧物理寄存器何时能给新指令用 | PST：跟踪每个 preg 的生命周期，新映射退休后才释放旧映射 | ct_rtu_pst_* |

```
ct_rtu_top
 ├── x_ct_rtu_rob       (ROB 64项 + 3个退休读项 + 异常缓冲 + 退休PC)   L1826
 │     ├── ct_rtu_rob_entry ×64 + ×3
 │     ├── ct_rtu_rob_rt   （退休读出与 PC 重建）
 │     └── ct_rtu_rob_expt （最老异常仲裁）
 ├── x_ct_rtu_retire    (退休判定/异常仲裁/flush状态机)                L2133
 ├── x_ct_rtu_pst_preg  (整数 96 preg 状态表)                          L1554
 ├── x_ct_rtu_pst_ereg       (32 项 EREG 状态贡献物理版本表)            L1623
 ├── x_ct_rtu_pst_vreg_dummy (当前向量 PST 的空壳配置)                  L1688
 └── x_ct_rtu_pst_freg       (浮点 64 freg 状态表，复用 pst_vreg 模块)  L1750
```

注意浮点 freg 状态表复用 `ct_rtu_pst_vreg` 的完整实现，但当前向量实例使用
`ct_rtu_pst_vreg_dummy`，完整向量 PST 的 `ct_rtu_pst_vreg` 实例只保留在生成器
注释中。这里能确认的是“完整模块源码可复用”，不能把它写成当前顶层已有两套
活动的 64 项状态表。dummy 的分配有效恒为 0、恢复映射恒为 0，并把
`pst_retired_vreg_wb` 恒置 1，以免未启用的向量状态阻塞 flush 等待。

---

## 2. IID：贯穿全核的指令身份证

RTU 文档里处处是 IID（Instruction ID），先把它讲透：

- **7 位 = 1 位 wrap + 6 位 ROB 索引**。低 6 位直接是 ROB 表项号（64 项）；
  最高位是"圈数奇偶"标志，每当分配指针绕回 entry0 时翻转；
- IDU 派遣时从 RTU 领取 IID（`rtu_idu_rob_inst0~3_iid`，rob.v:4376-4379），
  指令带着它走完一生：发射队列年龄比较、执行单元完成汇报、LSU 顺序检查，
  最后退休时用它定位 ROB 表项；
- **年龄比较**靠 `ct_rtu_compare_iid`（见 07_encode_compare.md）：wrap 位相同
  比大小、不同则反过来。严格前提是参与比较的两个有效 IID 位于同一个 64 项
  ROB 活跃窗口内；这里约束的是 ROB 项距离，不是折叠后的架构指令条数。

为什么不直接用 ROB 指针比较？因为消费 IID 的地方（BJU、LSU、发射队列）远离
ROB，没法实时知道头尾指针；自带 wrap 位让任意两个 IID 可以**就地**比出老幼。

---

## 3. 接口分组

### 3.1 IDU → RTU：创建（派遣拍）

| 信号组 | 说明 |
|--------|------|
| `idu_rtu_rob_create0~3_en/dp_en/gateclk_en/data[39:0]` | 每拍最多使用 4 个 ROB 创建端口；IDU 的 inst0~3 是内部派发/微操作槽，不能不加限定地等同为 4 条体系结构指令；折叠表项还可用 `inst_num` 表示 1~3 条体系结构指令 |
| `idu_rtu_pst_dis_inst0~3_*`（preg_iid/dst_reg/rel_preg、vreg/ereg 同构） | PST 分配信息：新 preg 给哪条指令(iid)、对应哪个逻辑寄存器(dst_reg)、退休时该释放哪个旧 preg(rel_preg) |
| 返回：`rtu_idu_rob_inst0~3_iid`、`rtu_idu_rob_full/empty`、`rtu_idu_srt_en` | IID 发放、满反压、单退休模式 |

### 3.2 七条管线 → RTU：完成（乱序）

| 来源 | 信号 | 异常能力 |
|------|------|----------|
| IU pipe0 | `iu_rtu_pipe0_cmplt/iid` + 全套异常字段 | 异常/flush/vsetvl/efpc |
| IU pipe1 | `iu_rtu_pipe1_cmplt/iid` | 不接入 rob_expt abnormal 负载 |
| IU pipe2 | `iu_rtu_pipe2_cmplt/iid/abnormal/bht_mispred/jmp_mispred` | 误预测 |
| LSU pipe3(load)/pipe4(store) | `lsu_rtu_wb_pipe3/4_cmplt/iid` + expt/mtval/spec_fail/bkpt/no_spec_* | 访存异常/顺序违例 |
| VFPU pipe6/7 | `vfpu_rtu_pipe6/7_cmplt/iid` | 不接入 rob_expt；浮点状态标志经 EREG/fflags 路径提交 |

写回（数据就绪）通知与完成分开：`iu_rtu_ex2_pipe0/1_wb_preg_vld/expand[95:0]`、
`lsu_rtu_wb_pipe3_wb_preg_*`、`vfpu_rtu_ex5_pipe6/7_wb_vreg_*` → 直接进 PST
置写回位。**ROB 收 cmplt（按 iid），PST 收 wb（按物理版本号）**——两者描述
不同事实，可能相关但不应当作同一个事件。完成总线见 `docs/iu/07_cbus.md`。

### 3.3 RTU → 全核：退休与 flush

| 信号 | 说明 |
|------|------|
| `rtu_yy_xx_retire0/1/2` | 三个 ROB 退休槽有效；不是完整的架构指令计数 |
| `rtu_yy_xx_flush` | **后端恢复脉冲**：实际连接的各模块按局部语义恢复映射或清推测状态 |
| `rtu_ifu_flush / rtu_idu_flush_fe / rtu_iu_flush_fe` | 前端 flush |
| `rtu_idu_flush_is / rtu_idu_flush_stall` | IS 级 flush（误预测专用，比 flush_fe 轻） |
| `rtu_ifu_xx_expt_vld/expt_vec`、`rtu_ifu_chgflw_*` | 异常向量与重定向 PC → IFU 转向 trap 入口 |
| `rtu_iu_rob_read0/1/2_pcfifo_vld` | 退休需要完整 next PC 的项消费 PCFIFO 数据（见 `docs/iu/03_bju_pcfifo.md`） |
| `rtu_lsu_expt_flush/eret_flush/spec_fail_flush/spec_fail_iid` | 告诉 LSU flush 的原因（决定 LSU 内部哪些项作废） |
| `rtu_hpcp_*`（retire pc/inst num/condbr/jmp 等） | 性能计数事件源 |
| `rtu_cp0_*` | 异常进入 CP0：epc/mtval/vec、vstart/vl 更新 |

---

## 4. 一条指令在 RTU 的一生

```
派遣拍 : IDU 发 rob_create*（40 位打包：pc_offset/bju/store/fold数/vl...）
         → ROB[create_ptr] 写入，vld=1, cmplt_cnt=折叠条数
         同拍 PST 表项 ALLOC（记录 iid/dst_reg/rel_preg）
执行后 : 执行单元 cmplt 报来（iid 低位译码后命中表项）→ cmplt_cnt 递减，到 0 置 cmplt
         （部分 IU 完成事件由 CBUS 按管线协议形成，见 docs/iu/07_cbus.md）
         数据写回 → PST 对应 preg 的 wb 状态置 WB
退休窗 : 表项滑入 3 个 retire read entry（rob_rt），按序检查：
         头项 cmplt？ 无异常？ → retire0/1/2 拉高
         - PC 重建：cur_pc += pc_offset（跳转则取 PCFIFO 弹出的目标）
         - PST：新 preg ALLOC→RETIRE，旧 preg（rel_preg）释放→等 DEALLOC
         - 有异常/误预测 → 启动 flush 状态机（见 04_retire.md）
```

---

## 5. 核心机制速通（子文档精华浓缩）

> 读完本节即可对 RTU 有完整认识；源码级细节进 01~07 子文档。

### 5.1 ROB：40 位瘦表项 + 指令折叠（详见 01）

64 项 × 仅 40 位。教科书 ROB 该存的三样东西全被外包：

| 教科书存 | C910 放哪 |
|----------|----------|
| 完整 PC | 不存，只存 3 位 pc_offset（增量重建，见 5.2）；跳转目标在 IU 的 PCFIFO |
| 结果数据 | PRF（写回即入） |
| 异常向量/mtval | 单独 1 项异常缓冲（见 5.3） |

**ROB 只管"序"，不管"值"**——这是 RTU 全部设计的纲。

**折叠**：一项最多表示 3 条架构指令；具体资格由 IDU folding 控制决定，
RTU 只消费创建数据中的折叠结果。`cmplt_cnt[1:0]`
跟踪剩余未完成数，多个完成源同拍命中同一项时可一次减 1~3。退休端每拍最多
弹 3 个 ROB 项，每项的 `inst_num` 又可为 1~3，因此某一拍的架构退休计数求和
可能达到 9。这个数表示**瞬时计数能力**，不表示长期可持续 9 IPC：前端最多
3 条架构指令/拍，折叠只压缩 ROB 控制项，不会凭空增加程序指令。BJU/LSU 等
不可折叠项通常一项一条，完成路径也与折叠 ALU 项不同。

性能统计时应明确三种量：

```text
retired_rob_slots = retire0 + retire1 + retire2
hpcp_minstret_inc = Σ((retire_slot_valid[i] && !split[i]) ? inst_num[i] : 0)
benchmark_IPC = Σ hpcp_minstret_inc / measured_cycles
```

`ct_hpcp_top.v` 的 `minstret_adder` 采用第二种算法：split 微操作可以占用并
退出 ROB 槽，但不会被再次计成一条架构指令。只观察
`rtu_yy_xx_retire0/1/2` 适合研究退休槽利用率和队头阻塞，不适合直接当作
架构 IPC。还需注意，retire 模块送 HPCP 的 valid 直接来自
`rob_retire_instN_vld`，该处没有再用 `!rob_retire_inst0_expt_vld` 屏蔽。
因此上式首先是**当前 RTL 的 minstret 候选增量公式**；对无异常 benchmark
区间可作为 IPC 分子，对同步异常指令的规范计数边界则应做定向测试确认。

完成端口在 ROB 顶层显式译码：7 个完成源的 IID 低 6 位分别经过
`ct_rtu_expand_64` 形成独热位图，再把第 N 位送给 entryN。这样 entry 内部
直接消费自己的 7 位完成向量，不再重复做 7 位 IID 比较；“entry 内不译码”
不能简写成“整个完成端口零译码”。

指针照例三套：64 位独热创建指针（移位即步进）+ 4 个二进制 iid（派遣时
发给 IDU，wrap 位自然溢出形成）+ 退休弹出指针。满判定用计数器，
更新后计数为 61~64 时置 full。该阈值为最多 4 项的在途创建提供吸收余量，
但不表示每个周期始终固定空着 4 项。

### 5.2 退休 PC 增量重建（详见 02）

RTU 维护一个**退休游标 rob_cur_pc**：

```
非跳转项退休: cur_pc += pc_offset（本项折叠指令总长，半字数）
跳转项退休:   cur_pc = PCFIFO 弹出的真实目标
```

一拍退休 3 项时 inst1/inst2 的 PC 是级联选择：前面有跳转就从其目标起算，
否则累加 offset。实现上先选择并锁存 39 位基值和 5 位偏移，再进行 39 位结果
加法，从 RTL 结构上把主要选择逻辑与输出加法分开；实际关键路径仍需综合时序
报告确认。异常返回（rte）时游标直接装 CP0 的 EPC。
**少量固定的退休侧加法逻辑替代了每个 ROB 表项各存一份 39 位 PC**——这就是
ROB 可以只保存半字增量和跳转标记的基础。RTL 中分别存在退休槽 PC 累加、
当前基准 PC 更新和 split FOF 修正等加法表达式；综合后具体形成多少个加法器
取决于共享、常量传播和时序约束，不能从功能 RTL 断言只有一个物理加法器。

`rob_cur_pc[38:0]` 保存的是字节 PC 的 `[39:1]`，最低位 0 被省略；
`pc_offset` 的单位也是 16 位半字。波形中应使用 `{rob_cur_pc,1'b0}` 与
反汇编的字节地址比较。

### 5.3 异常单项擂台（详见 03）

异常现场（70 位：iid/vec/mtval/spec_fail/mispred/vsetvl…）只存**一项**。
它保存的是 pipe0/2/3/4 已经报告且仍有效的 abnormal 中当前已知最老者，
并不提前代表尚未完成的全局最老异常。10 个 compare_iid 对四路新候选和现存项
两两比较；更老 abnormal 后续完成时仍可替换当前项，而 ROB 的顺序退休阻止年轻
候选越过未完成老指令先被消费。退休 inst0 的 IID 与缓冲项匹配时再按类型处置：

- expt_vld=1 → 真异常，走 trap；
- 只有 mispred/spec_fail/flush 标记 → 非 trap 的 flush 流程。

误预测、LSU 顺序违例、vsetvl flush **复用同一套擂台**——它们都需要
"最老者退休时触发恢复"的语义。

### 5.4 flush 状态机（详见 04）—— 全核恢复总指挥

```
触发A 异常/中断/CSR副作用/调试 → FLUSH_FE 路线（前端要转向）
触发B 误预测分支正常退休       → FLUSH_IS 路线（IFU 早被 BJU 重定向过，只清 IS/RF）

IDLE → FLUSH_FE(或IS) → [WF_EMPTY 等待] → FLUSH_BE → IDLE
                ↑ 保留状态已就绪时可使用组合状态（FLUSH_FE_BE/IS_BE）
```

信号名 `retire_flush_pipeline_empty` 实际只检查
`pst_retire_retired_reg_wb && lsu_rtu_all_commit_data_vld`：前者汇总当前
需要保留或释放的物理寄存器版本是否满足 WB 条件，后者检查已提交 store 数据。
它不是逐级扫描所有执行流水线 valid 的“全核为空”信号，也不能用其低电平单独
判断究竟是寄存器版本还是 store data 在等待。

各状态动作：FLUSH_IS 清 IDU IS/RF；FLUSH_FE 加清 IFU 和 IDU 全级；
FLUSH_BE 发出后端恢复脉冲 **rtu_yy_xx_flush**。各接收模块只按照各自 RTL 中
与该信号相连的分支恢复映射或清除局部推测状态；已提交状态必须保留，不能描述成
“所有模块、所有状态在这一拍全部消失”。整个非 IDLE 期间
ID 级 stall、错误路径分支的 chgflw 被 mask。

中断在退休口注入（只打 inst0，从队头 PC 形成精确 EPC）；中断/调试/拆分指令
spec fail 等场景启用单退休模式（srt）。SRT 限制的是每拍最多一个 ROB 退休槽，
不是直接把架构退休数强制为 1；对非 split 折叠项仍需读取 `inst_num`，而
split 微操作按 HPCP 规则不计入 `minstret`。

### 5.5 PST：preg 五态生命周期（详见 05/06）

整数物理编号共 96 个。preg0 是 x0 的固定映射，没有例化五态 entry；preg1~95
共有 95 个有状态项。复位后是“preg0 固定映射 + preg1~31 的 31 个 RETIRE
映射 + preg32~95 的 64 个 DEALLOC 项”；逻辑上仍为 32 个提交映射和 64 个
空闲编号。运行中后 64 项容量还可能被 WF_ALLOC、ALLOC、RELEASE 等状态占用，
不能全部等同于“64 条在飞写指令”。preg1~95 的状态机为：

```
DEALLOC(空闲) → WF_ALLOC(IDU已预取) → ALLOC(已派给指令,推测态)
   → RETIRE(生产者退休,我是某逻辑寄存器的正身) 
   → RELEASE(下任写者退休,等 WB 且无 SDIQ 引用) → DEALLOC
```

三条铁律：

1. **flush 时 ALLOC/WF_ALLOC 回 DEALLOC，RETIRE 纹丝不动**——
   "重命名表恢复"不需要 walk ROB 或 checkpoint：每个 RETIRE 态项输出
   "我是逻辑寄存器 X"的位图，flush 拍 RAT 整表重写即可；
2. **旧 preg 在"下一任写者退休"时释放**：每项记着 rel_preg（前任），
   自己退休的同拍把前任送进 RELEASE；
3. **没写回或仍被 SDIQ 引用都不回收**：entry 使用
   `WB && !x_dealloc_mask` 作为可释放条件，防止 store-data 队列仍按旧 preg
   号取数时物理存储已被新主人覆盖。这也是 PREG 压力不能只看写回端口的原因。

整数 PREG 和完整 FREG PST 的退休匹配包含提前提供 IID、预比较或更新值接口等
时序优化；具体是否使用锁存的 match 位，应以对应 entry 的有效逻辑为准，不能
把生成器保留的注释逻辑也算作活动数据通路。当前 FREG PST 为 64 项，向量 PST
是 dummy，EREG PST 为 32 项。完整 `ct_rtu_pst_vreg` 源码的存在不表示当前
向量物理状态管理已启用，更不表示浮点和向量共享体系结构寄存器或数据存储。

### 5.6 机制联动图

```
            完成(iid)            退休判定           flush
7管线 ──► ROB cmplt_cnt ──► retire 0/1/2 ──┬─► PC游标前进(5.2)
                ▲                          ├─► PST: ALLOC→RETIRE + 释放前任(5.5)
异常完成 ──► 擂台(5.3) ──退休命中──► flush FSM(5.4) ──► rtu_yy_xx_flush
                                                          └─► RAT按RETIRE位图恢复
```

## 6. Verdi 观察层次

```
tb...x_ct_core.x_ct_rtu_top
 ├ x_ct_rtu_rob            ← rob_entry_num[6:0]（占用数）、rob_full
 │  ├ x_ct_rtu_rob_rt      ← rob_cur_pc（退休PC）、retire_inst0_cur_pc
 │  └ x_ct_rtu_rob_expt    ← expt_entry_vld/iid（挂起的最老异常）
 ├ x_ct_rtu_retire         ← flush_cur_state[4:0]（flush 状态机）
 └ x_ct_rtu_pst_preg       ← 任一 entry 的 lifecycle_cur_state[4:0]
```

入门建议同时观察 `rtu_yy_xx_retire0/1/2`、三个槽的 `inst_num`、
三个槽的 `split`、`rob_entry_num` 与 `flush_cur_state`。只有
`valid && !split` 的槽才按 `inst_num` 加入 HPCP 的 `minstret` 增量；valid
本身反映退休槽占用。跑 CoreMark 可比较“槽利用率”“split 微操作退出量”和
“加权 minstret 增量”，跑 exception case 除观察 flush 状态机外，还可专门
核对异常指令前后 `minstret` 的变化。
