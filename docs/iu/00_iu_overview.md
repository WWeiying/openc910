# C910 IU 总览（ct_iu_top）

> RTL 源文件：`C910_RTL_FACTORY/gen_rtl/iu/rtl/ct_iu_top.v`（1271 行）
>
> ct_iu_top 是纯结构性顶层：本身几乎没有逻辑，只做 8 个子模块的实例化与连线
> （外加 4 bit 调试信息拼接）。读懂它的意义在于：**把 IU 的全部对外接口和内部
> 数据流一次看清**。

---

## 1. IU 在 C910 整体架构中的位置

### 1.1 八条执行管线中的三条

C910 的 IDU 把就绪操作送到编号为 pipe0~pipe7 的 8 条执行路径（见
`docs/idu/00_idu_overview.md`），
其中 Pipe0~2 属于 IU：

| 管线 | 发射队列 | IU 内执行单元 | 典型指令 |
|------|----------|--------------|----------|
| Pipe0 | AIQ0 | ALU0 + DIV + SPECIAL | add/sub/逻辑/移位、div/rem、csrr*、vsetvli |
| Pipe1 | AIQ1 | ALU1 + MULT | add/sub/逻辑/移位、mul/mulh、mula（乘累加） |
| Pipe2 | BIQ  | BJU | beq/bne/blt…、jal/jalr、ret |
| Pipe3~5 | LSIQ/SDIQ | （LSU，见 `docs/lsu/`） | load/store |
| Pipe6~7 | VIQ0/1 | （VFPU） | 浮点/向量 |

这个划分的体系结构含义：

- **两套同构 ALU 数据通路**给常见整数运算提供每拍最多两条的执行能力。这里的
  “同构”只指 `ct_iu_alu` 被例化两次、组合功能和流水寄存器结构相同；整条
  Pipe0/Pipe1 并不完全对称：Pipe0 还挂 DIV/SPECIAL/CP0 返回路径，Pipe1 还挂
  MULT，并各自受到不同的发射、读端口和写回冲突约束。因此“两条 ALU 都可用”
  是双发射的必要条件，不是任意两条整数指令都必能同拍发射的充分条件；
- **长延迟单元挂在 ALU 管线上**（DIV 挂 Pipe0、MULT 挂 Pipe1），共享发射端口和
  写回端口，省面积——代价是 div/mult 发射那一拍，对应 ALU 管线不能再发 ALU 指令，
  由 IDU 的 AIQ 仲裁保证（见 `docs/idu/13_is_aiq.md`）；
- **分支检查微操作独占 Pipe2**：条件分支以及 jal/jalr 的跳转检查部分不在
  Pipe2 写通用寄存器结果；带链接的 jal/jalr 会由 IDU 拆出另一条
  `PSEUDO_AUIPC` 微操作，在 Pipe0 的 SPECIAL 单元计算 `PC+4`，压缩
  `C.JALR` 则计算 `PC+2`，并写入链接寄存器。跳转检查需要专用的误预测检测
  通路和 IFU 重定向接口，因此单独占用 BJU 管线。

### 1.2 EX 流水级

IU 内部统一以 EX1/EX2/EX3/EX4 计拍（RF 读寄存器之后的第 1~4 拍）：

```
          EX1            EX2            EX3            EX4
ALU    │ 运算+前递    │ 写回(wb)     │              │
BJU    │ 比较/算目标  │ 误预测广播    │              │
SPECIAL│ CSR读/异常   │ (经rbus写回) │              │
MULT   │ booth部分积  │ 压缩树       │ preg预告      │ 数据写回
DIV    │ ←──────  SRT radix-16 迭代，数据就绪即写回（变延迟） ──────→
CP0    │              │              │ ex3 结果/异常 │
```

为什么 ALU 在 EX1 就"前递"、EX2 才"写回"？——**前递（forward）**是把结果直接
送回 IDU 的前递网络（`docs/idu/20_rf_fwd.md`），为 back-to-back 依赖指令提供
尽早获得生产者结果的路径；消费者能否在紧邻周期发射还取决于具体执行单元、
唤醒拍点和端口/stall 条件，不能只由存在前递接口推出固定一拍间隔。
发射；**写回（writeback）**是把结果写进物理寄存器堆 PRF 并通知 RTU"这条指令完成"。
两者分开，是乱序核实现"1 拍 ALU 延迟"的标准做法。

---

## 2. 顶层结构：8 个子模块

`ct_iu_top.v` 实例化关系（行号为 instance 起始处）：

```
ct_iu_top
 ├── x_ct_iu_alu0      (ct_iu_alu,  ConnRule pipex→pipe0)      // ~L822
 ├── x_ct_iu_alu1      (ct_iu_alu,  ConnRule pipex→pipe1)      // L868
 ├── x_ct_iu_bju       (ct_iu_bju, 内含 pcfifo)                // L913
 ├── x_ct_iu_mult      (ct_iu_mult)                            // L996
 ├── x_ct_iu_div       (ct_iu_div)                             // L1031
 ├── x_ct_iu_special   (ct_iu_special)                         // L1065
 ├── x_ct_iu_cbus      (ct_iu_cbus,  完成总线 → RTU)           // L1112
 └── x_ct_iu_rbus      (ct_iu_rbus,  结果总线 → IDU/RTU)       // L1180
```

注意 ALU 是**同一模块例化两次**（`&ConnRule(s/pipex/pipe0|1/)`，
`ct_iu_top.v` 中的 `x_ct_iu_alu0/1`）。这能证明两套 **ALU 子模块**的逻辑
同构，不能据此把 Pipe0 与 Pipe1 的全部能力写成相同。教学上应区分：

```text
ALU0 与 ALU1：同一份 ct_iu_alu 结构
Pipe0 与 Pipe1：ALU 外围连接、附属长延迟单元和冲突条件不同
实际双发射：还要满足队列映射、源就绪、端口、stall 和 flush 条件
```

内部数据流全景：

```
   IDU rf_pipe0 ──────►┌──────┐ ex1 data/fwd ┌──────┐
                       │ ALU0 ├─────────────►│      │ ex1_fwd ──► IDU 前递网络
   IDU rf_pipe1 ──────►├──────┤              │      │
                       │ ALU1 ├─────────────►│ RBUS │ ex2_wb  ──► IDU PRF 写口
   IDU rf_div   ──────►├──────┤   div_rbus   │      │ ex2_wb_expand ──► RTU
                       │ DIV  ├─────────────►│      │
   IDU rf_mult  ──────►├──────┤  mult ex3/4  │      │◄── vfpu mfvr (pipe6/7)
                       │ MULT ├─────────────►│      │◄── cp0 ex3 rslt
   IDU rf_special ────►├──────┤ special_rbus └──────┘
                       │ SPEC ├──────┐
                       └──────┘      │special_cbus(ex1 异常/vsetvl)
   IDU rf_pipe2 ──────►┌──────┐      ▼
   IFU pcfifo_create ─►│ BJU  │   ┌──────┐ pipe0/1/2 cmplt/iid/expt
   RTU rob_read ──────►│      ├──►│ CBUS ├────────────────► RTU
                       └──┬───┘   └──────┘
                          │ chgflw(重定向)/bht_check ──► IFU
                          │ pcfifo_pop0/1/2 ──────────► RTU
```

---

## 3. 对外接口分组详解

ct_iu_top 的端口约 270 个，按"对端模块 + 流水级"分组后并不难记。

### 3.1 IDU → IU：发射接口（RF 阶段送来）

每条管线一组，以 pipe0 为例（ct_iu_top.v:305-329）：

| 信号 | 位宽 | 含义 |
|------|------|------|
| `idu_iu_rf_pipe0_sel` | 1 | 本拍 pipe0 有指令发射到 IU |
| `idu_iu_rf_pipe0_gateclk_sel` | 1 | 门控时钟使能（比 sel 早、范围宽） |
| `idu_iu_rf_pipe0_func` | 5 | 功能码（ALU 操作类型） |
| `idu_iu_rf_pipe0_src0/1/2` | 64×3 | 三个源操作数；ALU 的 `src2` 用于条件搬运成立时的新值，链接地址由 SPECIAL 结合 PCFIFO PC 与立即数计算 |
| `idu_iu_rf_pipe0_src1_no_imm` | 64 | 未经立即数替换的 src1（给 DIV/MULT/SPECIAL 用） |
| `idu_iu_rf_pipe0_imm` | 6 | 移位立即数 |
| `idu_iu_rf_pipe0_dst_preg` | 7 | 目的物理寄存器号（当前整数 PRF 实现 96 项，7 位编码覆盖该范围） |
| `idu_iu_rf_pipe0_dst_vld / dstv_vld` | 1 | 整数/向量目的有效 |
| `idu_iu_rf_pipe0_iid` | 7 | 指令 ID（ROB 索引，年龄标识） |
| `idu_iu_rf_pipe0_rslt_sel` | 21 | 结果多路选择独热码（见 01_alu.md） |
| `idu_iu_rf_pipe0_alu_short` | 1 | "短指令"标记：EX1 即可出结果 |
| `idu_iu_rf_pipe0_opcode/special_imm/expt_*` | - | 仅 SPECIAL 用：原始指令码/20 位立即数/译码期异常 |
| `idu_iu_rf_pipe0_vl/vlmul/vsew` | 8/2/3 | 向量配置（mtvr、vsetvli 用） |

pipe1 多出 `mult_func[7:0]`、`mla_src2_preg/vld`（乘累加第三操作数，ct_iu_top.v:340-342）；
pipe2（BJU）则完全不同：`offset[20:0]`（分支偏移）、`pcall`（函数调用）、`rts`（返回）、
`length`（2/4 字节指令）、`pid[4:0]`（PCFIFO 项号，ct_iu_top.v:352-363）。

另有独立的单元选择信号：`idu_iu_rf_bju_sel / div_sel / mult_sel / special_sel`
（ct_iu_top.v:299-304, 364-365）——同一管线上挂多个单元时，靠它们区分本拍发射给谁。

### 3.2 IU → IDU：前递、写回与忙信号

| 信号组 | 时机 | 作用 |
|--------|------|------|
| `iu_idu_ex1_pipe0/1_fwd_preg(_data/_vld)` | EX1 | ALU 结果前递给 RF 阶段的依赖指令 |
| `iu_idu_ex2_pipe0/1_wb_preg(_data/_vld)` | EX2 | 写 PRF；`_dup0~4` 是同一信号的 5 份物理复制 |
| `iu_idu_ex2_pipe0/1_wb_preg_expand[95:0]` | EX2 | preg 的 96 位独热扩展（直接当 PRF 写使能/唤醒位图用） |
| `iu_idu_ex2_pipe1_mult_inst_vld_dup*/preg_dup*` | EX2 | 乘法 EX3 将占用写回口的**预告**，供 AIQ 提前唤醒 |
| `iu_idu_div_busy / div_inst_vld / div_preg_dup* / div_wb_stall` | - | 除法忙/将写回，IDU 据此暂停发射会冲突的指令 |
| `iu_idu_ex1_pipe1_mult_stall` | EX1 | 乘法结构冲突反压 |
| `iu_idu_pipe1_mla_src2_no_fwd` | - | MLA 的累加源不能走前递（见 04_mult.md） |
| `iu_idu_mispred_stall` | - | 误预测后冻结发射窗口（见 02_bju.md） |

**为什么有 `_dup0~4` 五份复制？** 唤醒信号要同时广播给 AIQ0/AIQ1/BIQ/LSIQ/SDIQ
五个发射队列，每个队列里每一项都要比较 preg，逻辑扇出很大。RTL 显式提供多份
等值寄存器输出，使不同消费区域可由独立网络驱动；综合和布局工具仍可能进一步
复制、合并或缓冲，所以最终物理结构应以网表和时序报告为准。功能仿真中这些副本
应在各自有效时刻保持相同的 preg 值。

### 3.3 IFU ↔ IU：分支闭环

IFU 侧（创建 PCFIFO 项，每拍最多 2 条，ct_iu_top.v:366-385）：

| 信号 | 含义 |
|------|------|
| `ifu_iu_pcfifo_create0/1_en` | 创建使能 |
| `..._cur_pc[39:0] / tar_pc[39:0]` | 分支自身 PC / 预测目标 PC |
| `..._bht_pred` | BHT 预测方向（taken/not-taken） |
| `..._jal / jalr / dst_vld` | 分支类型信息 |
| `..._chk_idx[24:0]` | BHT 检查索引（写回 BHT 时定位表项用） |
| `..._jmp_mispred` | IFU 自己已发现并修过的误预测标记 |

IU 侧（检查结果回送 IFU，ct_iu_top.v:461-472）：

| 信号 | 含义 |
|------|------|
| `iu_ifu_chgflw_vld / chgflw_pc[62:0]` | **误预测重定向**：通知 IFU 从正确目标重新取指 |
| `iu_ifu_chgflw_vl/vlmul/vsew` | vsetvli 预译码恢复用的向量配置 |
| `iu_ifu_bht_check_vld / condbr_taken / bht_pred` | 条件分支实际方向 → BHT 训练 |
| `iu_ifu_chk_idx[24:0] / cur_pc[38:0]` | 回写 BHT/BTB 的定位信息 |
| `iu_ifu_pcfifo_full` | PCFIFO 满，反压 IFU 不许再发分支 |
| `iu_ifu_mispred_stall` | 误预测处理期间暂停 |

这里的 PC 总线有两种编码，观察波形时不能混用：

- PCFIFO 的 `cur_pc[39:0] / tar_pc[39:0]` 已经是完整的 40 位字节地址；
- `iu_ifu_chgflw_pc[62:0]` 保存架构虚拟地址 `VA[63:1]`，完整重定向地址为
  `{iu_ifu_chgflw_pc, 1'b0}`；
- `iu_ifu_cur_pc[38:0]` 保存架构字节地址 `PC[39:1]`，完整地址为
  `{iu_ifu_cur_pc, 1'b0}`。

这是 RISC-V 指令至少按 2 字节对齐带来的无损压缩，并不表示这些 PC 是奇地址或
缺少有效地址信息。

这组接口与 `docs/ifu/04_bht.md`、`docs/branch_prediction.md` 第 12 节的 Verdi 观察信号
一一对应：预测在 IFU，**验证与训练数据源在 IU 的 BJU**。

### 3.4 IU → RTU：完成与退休支持

| 信号组 | 含义 |
|--------|------|
| `iu_rtu_pipe0_cmplt/iid` + `expt_vld/expt_vec/mtval/flush/...`（ct_iu_top.v:480-494） | pipe0 完成 + 异常信息（pipe0 是唯一能报异常的整数管线，因为 SPECIAL/CSR 在它上面） |
| `iu_rtu_pipe1_cmplt/iid` | pipe1 完成（ALU/MULT 无异常，只报完成） |
| `iu_rtu_pipe2_cmplt/iid` + `bht_mispred/jmp_mispred/abnormal` | 分支完成 + 误预测标记（RTU 据此在退休时触发后端 flush） |
| `iu_rtu_ex2_pipe0/1_wb_preg_vld/expand[95:0]` | 写回通知（RTU 的 PST 用来标记 preg 数据就绪） |
| `iu_rtu_pcfifo_pop0/1/2_data[47:0]` | 退休的 3 条指令对应的 PC 信息（RTU 维护退休 PC 用） |
| `rtu_iu_rob_read0/1/2_pcfifo_vld`（输入） | RTU 退休读 PCFIFO 的弹出使能 |

**为什么退休 PC 要从 IU 的 PCFIFO 读？** ROB 为省面积不存完整 PC（只存增量信息），
跳转指令的真实 PC/目标存在 PCFIFO 里；退休时 RTU 按程序序弹出 PCFIFO 拿到精确 PC。
这是 C910 一个重要的面积优化设计，详见 03_bju_pcfifo.md 与 `docs/rtu/`。

### 3.5 CP0 / VFPU / HAD 杂项

- `cp0_iu_ex3_*`（ct_iu_top.v:270-283）：CP0 以 `ex3` 命名接口返回 CSR
  指令的结果、IID 和异常/flush 元数据，IU 再由 CBUS/RBUS 代为汇报和写回。
  这能确认 **CP0 借用 IU pipe0 的完成/写回通道**；端到端“执行几拍”还要以
  IDU 接受该 CSR 的起始拍与 CP0 `ex3_*_vld` 的实际间隔定义，不能只由端口名推断。
- `vfpu_iu_ex2_pipe6/7_mfvr_*`：mfvr（向量→整数搬运）指令在 VFPU 执行，但目的是
  整数寄存器，数据送回 IU 的 RBUS 写整数 PRF。
- `iu_vfpu_ex1/ex2_pipe0/1_mtvr_*`：反方向，mtvr（整数→向量）由 ALU 把 src0 转交 VFPU。
- `had_idu_wbbr_*`：硬件调试器（HAD）注入的写回数据。
- `iu_yy_xx_cancel`：BJU EX2 重定向脉冲。当前顶层把它送到 IDU 的 ID/IR/IS、
  split/fence 等控制路径，并在 IU 内送到 PCFIFO，用于立即停止或标记尚处于这些
  前端/派遣边界的旧路径状态。它不是逐个连接所有执行单元的“全核 kill”；
  更深的错误路径状态仍由后续 RTU flush 按各模块协议清理。

### 3.6 调试信息（ct_iu_top 唯一的自有逻辑）

```verilog
// ct_iu_top.v:1262-1265
assign iu_had_debug_info[0]   = bju_top_pcfifo_full;
assign iu_had_debug_info[1]   = div_top_div_no_idle;
assign iu_had_debug_info[2]   = div_top_div_wf_wb;
assign iu_had_debug_info[9:3] = bju_top_mispred_iid[6:0];
```

把"PCFIFO 满 / 除法器非空闲 / 除法器等写回 / 最近误预测 IID"打包给 HAD 调试模块。

---

## 4. 两条总线：CBUS 与 RBUS 的分工

初学者最容易混淆的就是这两条总线，先在总览里立好概念：

| | RBUS（结果总线） | CBUS（完成总线） |
|---|---|---|
| 内容 | **数据**：64 位结果 + preg 号 | **状态**：cmplt + iid + 异常向量 |
| 去向 | IDU（前递网络 + PRF 写口）、RTU（PST 就绪标记） | RTU（ROB 完成标记） |
| 关心 | 写哪个物理寄存器 | 哪条指令（按 ROB 序）完成了 |
| 源 | ALU ex1、SPECIAL ex1、MULT ex3/4、DIV、CP0 ex3、VFPU mfvr | ALU 管线 ex2、BJU ex2、SPECIAL ex1、CP0 ex3 |

为什么分开？**寄存器写回按 preg 组织，指令完成按 iid 组织**，消费者不同
（发射队列唤醒看 preg；ROB 退休看 iid），合并反而两头不讨好。这也是教科书上
"结果总线 + 完成/异常报告"分离的典型实现。

---

## 5. 时序速查：一条 add 和一条 beq 的生命周期

**`add x3,x1,x2`（发射到 pipe0）：**

```
拍0(RF) : IDU 读 PRF/前递网络拿到 src0/src1，idu_iu_rf_pipe0_sel=1
拍1(EX1): ALU0 运算；alu_rbus_ex1_pipe0_fwd_vld=1 → 依赖指令本拍即可在 RF 抓到数据
拍2(EX2): RBUS 驱动 iu_idu_ex2_pipe0_wb_preg_* 写 PRF；
          CBUS 驱动 iu_rtu_pipe0_cmplt=1 + iid → ROB 标记完成
```

**`beq x1,x2,offset`（发射到 pipe2）：**

```
取指期  : IFU 预测方向/目标，ifu_iu_pcfifo_create*_en=1 建 PCFIFO 项（拿到 pid）
拍0(RF) : BIQ 发射，idu_iu_rf_pipe2_* 带 pid 到 BJU
拍1(EX1): BJU 比较 src0/src1 得实际方向，读 PCFIFO[pid] 取预测信息对比
拍2(EX2): 若预测错：iu_ifu_chgflw_vld=1 重定向 IFU，iu_yy_xx_cancel 取消错误路径；
          无论对错：iu_rtu_pipe2_cmplt=1（+bht_mispred 标记），
                    iu_ifu_bht_check_vld=1 训练 BHT
退休期  : RTU 弹出 PCFIFO（rtu_iu_rob_read*_pcfifo_vld），项被回收
```

注意 C910 的选择：**误预测在 EX2 就重定向 IFU（推测刷新前端），但后端 flush 等到
该分支退休时由 RTU 发起**。前端早重启抢回取指延迟，后端按序刷新保证精确状态——
这是"早重定向 + 晚清理"的折中，详见 02_bju.md 第 5 节。

---

## 6. 核心机制速通（子文档精华浓缩）

> 本节把 01~08 各子文档最重要的机制压缩在此。读完本节即可对 IU 有完整认识；
> 需要源码级细节（行号引用、波形信号）时再进对应子文档。

### 6.1 ALU：译码前移与前递分级（详见 01）

- **rslt_sel[20:0] 独热码**由 IDU 在 RF 级生成，EX1 的结果选择只剩一层
  AND-OR——译码逻辑被移出执行级关键路径。EU 选择（adder/shifter/other）
  同样在 RF 级归并成 3 位 `eu_sel`。
- **前递只给"短指令"**：add/sub/逻辑/移位等 EX1 即出结果的指令走 EX1 前递
  （无其他阻塞时，依赖消费者最早可在紧邻拍利用前递）；max/min/addsl 等
  "长指令"虽然也在 EX1 形成结果，但走独立选择树、到达晚，**不进该 EX1 快速
  前递路径**，其消费者要等待后续 RBUS/PRF 可见时机——
  前递总线是全核时序最紧的网络，宁可牺牲长指令。
- ext/extu 位段提取用"符号位查表与移位并行"消除串行依赖；条件搬运 mveqz
  无条件写回（不成立时写回旧值 src0），让重命名/唤醒无需特判。
- 大量 T-Head 指令（addsl/ext/ff1/rev/mveqz/tstnbz）对应 XThead 类扩展的
  执行硬件。若某次 CoreMark 在开启和关闭相关编译扩展时出现分数差异，只能把
  这些指令的动态替换、代码尺寸变化和分支/访存变化列为候选原因；不能仅凭
  ALU RTL 把某组固定分数差全部归因于这些扩展。严谨验证应同时比较反汇编、
  动态指令数、IPC 和周期数。

### 6.2 BJU：误预测判定与"早重定向+晚清理"（详见 02/03）

**判定**（EX1）：
- 方向错 = `condbr_taken ^ bht_pred`（一个 XOR，预测值来自 PCFIFO）；
- 目标错（jalr）= `pcfifo_pc != src0`——PCFIFO 创建时 IFU 存的是
  **预测目标减 offset**，执行期免去加法直接比源寄存器（预计算技巧）。

**年龄闸门**：BIQ 乱序发射，新到的分支必须比"正在处理的误预测"和"历史
误预测记录（mispred_iid）"都老才有权发 chgflw——两个 compare_iid 在 RF 级
预比较（时序前移）。错误路径上的分支自己的"误预测"是无效的。

**恢复剧本（全核最重要的时序之一）**：

```
EX1 判错 → EX2 同时发三枪:
  ① iu_ifu_chgflw → IFU 立即从正确目标取指（前端抢跑）
  ② iu_yy_xx_cancel → 杀 IU 各级错误路径指令
  ③ idu/ifu_mispred_stall 拉高 → 新路径指令最远只到 ID 级等待
…… 后端继续执行/完成老指令（错误路径的被 cancel 压住）……
分支退休 → RTU flush 状态机: flush_fe → rtu_yy_xx_flush（后端 flush、
  重命名表恢复）→ stall 解除 → 新指令倾泻而下
```

为什么新指令要在 ID 等？后端还混着无法逐条精确杀死的错误路径指令、
重命名表是污染态，必须等退休级统一 flush。前端先行取指把损失压到最小。

**PCFIFO（32 项）**是这套机制的数据载体：IFU 创建（存预测现场：PC/方向/
chk_idx），IDU 派遣时发 pid，BJU 执行时按 pid 读出对比、EX2 回写真实结果，
RTU 退休时按序弹出（提供退休 PC，因为 ROB 不存 PC）。带链接寄存器的
jal/jalr 占两项（一项给计算 `PC+4` 或压缩指令 `PC+2` 的链接微操作，一项给
跳转检查）。满了反压 IFU，不许再接收需要创建 PCFIFO 现场的指令。

### 6.3 MULT：延迟感知唤醒与 MLA 私有前递（详见 04）

- 4 拍流水（EX1~EX4），65×65 有符号乘法器统一处理四种符号组合（无符号补
  0 位、有符号补符号位——"宽一位换统一"）；
- **EX3 发预告（preg）、EX4 出数据**：发射队列提前一拍唤醒消费者，消费者
  发射时数据恰好广播到——RBUS 里控制走寄存器、数据晚一拍走旁路 mux 对齐；
- **MLA 链私有前递**：连续乘累加（rz += rx×ry）的累加源若命中管线内较老
  MLA 的目的 preg，RF 级会记录匹配关系，随后从 EX3/EX4 结果路径取累加数。
  在没有其他发射限制时，相关 MLA 链的最小启动间隔可达到 2 拍；“2 拍”描述
  的是该特定依赖链的可达间隔，不是所有乘法流的无条件吞吐率；
- `mult_ex1_inst_vld` 产生 `iu_idu_ex1_pipe1_mult_stall`。在 AIQ1 中它与
  `lch_preg`/`dp_aiq1_create_alu` 等条件组合，阻止会发生 Pipe1 操作数锁存或
  资源冲突的候选。不能把这个单比特简单解释为“整条 Pipe1 下一拍完全停住”。

### 6.4 DIV：变延迟 + 结果缓存（详见 05）

- 状态机式非流水（同一时刻只跟踪一条除法），SRT 基 16 的主迭代按每轮
  4 个商位组织，**EX3 停留时间随规格化后的指数差和余数是否提前为零而变**。
  文档中若给出“6~22 拍”一类范围，必须同时注明从哪个握手信号计到哪个写回
  信号；静态 RTL 能证明变延迟机制，不能单独证明所有系统配置下的固定总拍数；
- 快速通道：除 0/溢出（RISC-V 定义返回值不 trap）、被除数<除数（商=0）
  1~2 拍直出；
- **2 项结果缓存**存 `{操作数, 商, 余数, signed, word-width}`。当 `a/b`
  与随后 `a%b` 使用完全相同的两个 64 位输入、符号模式和字宽，而且第一条
  已完成正常迭代并填充、对应表项尚未被两次后续填充替换、缓存未被 CP0 禁用时，
  第二条可以命中并复用商/余数；这是一条常见快路，不是无条件“必命中”；
- 写回借 pipe0 的口：REQ 状态先发 `div_wb_stall` 让 IDU 清场一拍再写。

### 6.5 SPECIAL：异常入口与 vsetvli 预测校验（详见 06）

- 处理 auipc（PC 从 PCFIFO 读口 1 取）、ecall/ebreak（纯产生异常，异常号
  随特权级 8/9/11）、译码期异常的占位 NOP（mtval 回填原始 opcode）；
- **vsetvli 预测校验**：IFU 取指期预译码猜新 vl，向量指令带预测 vl 提前
  派遣；SPECIAL 执行期算真值（vl = min(AVL, VLMAX)，7 档 VLMAX 并行算再
  16 路选）并比对——猜对时没有额外的配置恢复 flush，猜错置 abnormal →
  退休时 flush 重取；“没有额外 flush”不等于该指令不占执行与退休资源。
  vsetvl（寄存器源 vtype）无法预测，一律 flush。新配置借 mtval 通道传给
  CP0（复用暗道，波形里 mtval 不一定是地址！）。

### 6.6 CBUS/RBUS：完成与写回的双轨制（详见 07/08）

全 IU 最重要的抽象，务必吃透：

| | CBUS（完成） | RBUS（写回） |
|---|---|---|
| 传什么 | cmplt + iid + 异常 | 64 位数据 + preg |
| 给谁 | RTU 的 ROB（按 iid） | IDU 的 PRF/唤醒 + RTU 的 PST（按 preg） |
| 决定什么 | ROB 是否收到该执行成分的完成记账 | 物理结果何时可被消费者读取 |

- **推定完成**：ALU/MULT/DIV 的选择信号可在 RF 接受后经 CBUS 打一拍形成
  `cmplt`，不等待 MULT/DIV 真正产生数据。这里的 `cmplt` 是 ROB 的执行成分
  完成记账，不等同于“结果已经写入 PRF”。消费者仍由 preg 的 wakeup/writeback
  状态约束；异常、flush、物理寄存器生命周期和精确状态正确性则由 RTU/PST
  联合保证，不能用一句“互不干扰”略过。SPECIAL/CP0 可能携带异常或改流信息，
  因而必须等实际执行结果再上报。
- RBUS 是共享写回口的汇聚点（pipe0 五源/pipe1 三源），**无仲裁器**——
  同拍至多一源有效由 IDU 发射纪律保证（仲裁前移，数据通路保持哑）；
- preg 在打拍前展开成 96 位独热（expand_96），消费端（PRF 写使能、PST
  置位）零译码；唤醒信号物理复制 5 份（dup0~4）分驱 5 个发射队列。

### 6.7 数据就绪时刻总表（消费者视角）

下表的“间隔”以生产者在 RF 被相应执行单元接受为起点，描述无 stall、无 flush、
旁路条件成立时的最早可见时机。它不是端到端指令延迟，也不包含派遣前等待。

| 生产者 | 最早拿数途径 | 理想最早间隔 |
|--------|-------------|------|
| ALU 短指令 | EX1 前递 | 1 拍 |
| ALU 长指令 | EX2 写回广播 | 2 拍 |
| MULT | EX3 唤醒+EX4 数据 | 4 拍 |
| MLA→MLA | preg/宽度匹配后的乘法器私有前递 | 最小 2 拍 |
| DIV | `div_rbus_pipe0_data_vld` 写回广播 | 变延迟，需按波形实测 |
| CSR(CP0) | EX3 结果经 rbus | 4 拍 |

## 7. Verdi 观察层次

```
tb.x_soc.x_cpu_sub_system_axi.x_rv_integration_platform.x_cpu_top.x_ct_top_0
  .x_ct_core.x_ct_iu_top                      ← 本文档
     ├ x_ct_iu_alu0 / x_ct_iu_alu1
     ├ x_ct_iu_bju ─ x_ct_iu_bju_pcfifo
     ├ x_ct_iu_mult / x_ct_iu_div / x_ct_iu_special
     └ x_ct_iu_cbus / x_ct_iu_rbus
```

入门建议先抓一组信号看懂双发射：`idu_iu_rf_pipe0_sel`、`idu_iu_rf_pipe1_sel`、
`iu_idu_ex2_pipe0_wb_preg_vld`、`iu_idu_ex2_pipe1_wb_preg_vld`、
`iu_rtu_pipe0/1_cmplt`——跑 bench_frontend 的 Pattern 1 时这几个信号几乎拍拍有效。
