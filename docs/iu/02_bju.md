# C910 IU 分支跳转单元详解（ct_iu_bju）

> RTL 源文件：`C910_RTL_FACTORY/gen_rtl/iu/rtl/ct_iu_bju.v`（1122 行）
> 内部例化：`ct_iu_bju_pcfifo`（见 03_bju_pcfifo.md）、2 个 `ct_rtu_compare_iid`、1 个 `ct_rtu_expand_32`
>
> BJU 是分支预测闭环的"裁判"：IFU 负责猜（BTB/BHT/RAS 预测），BJU 负责验
> （算出真实方向和目标、与预测对比），错了就重定向 IFU 并触发恢复。

---

## 1. 模块概述

### 1.1 职责

1. **执行 Pipe2 上的所有控制流指令**：条件分支（beq/bne/blt/bltu/bge/bgeu）、
   直接跳转（jal）、间接跳转（jalr，含 ret）；
2. **误预测检测**：方向错（BHT mispred）和目标错（JMP mispred）两类；
3. **发起重定向**：EX2 拍向 IFU 发 `chgflw`，并广播 `iu_yy_xx_cancel` 取消错误路径；
4. **预测器训练数据回传**：实际方向/目标/chk_idx 送回 IFU 更新 BHT/BTB/indirect BTB；
5. **管理 PCFIFO**：保存分支 PC 与预测信息（IFU 创建、BJU 读改、RTU 弹出）。

### 1.2 流水结构

```
   RF             EX1                    EX2                      EX3
────────┬──────────────────────┬─────────────────────────┬──────────────────
IID年龄  │ 方向判定(比较器)       │ 重定向: iu_ifu_chgflw    │ PCFIFO 第二级
比较     │ 目标计算(两个加法器)   │ 取消:   iu_yy_xx_cancel  │ bypass 写
读PCFIFO │ BHT/JMP 误预测判定    │ BHT训练: bht_check_vld   │ (供 RTU 晚读)
        │ chgflw_vld 生成       │ CBUS:   cmplt+mispred    │
        │                      │ PCFIFO 回写(EX2 bypass)  │
```

注意与 ALU 的不同：**BJU 的"动作"集中在 EX2**。EX1 算出了一切，但重定向、取消、
完成汇报都打一拍到 EX2 才发出——因为这些信号扇出巨大（IFU 整个前端、IDU 所有
发射队列、RTU），必须从寄存器直接驱动，不能带组合逻辑。

---

## 2. 逐逻辑块讲解

### 2.1 RF 级：IID 年龄比较（ct_iu_bju.v:476-506）

```verilog
// L485-499: 两个年龄比较器
ct_rtu_compare_iid  x_..._rf_older_ex1     (.x_iid0(idu_iu_rf_pipe2_iid), .x_iid1(ex1_pipe2_iid),  .x_iid0_older(bju_rf_older_ex1));
ct_rtu_compare_iid  x_..._rf_older_mispred (.x_iid0(idu_iu_rf_pipe2_iid), .x_iid1(mispred_iid),    .x_iid0_older(bju_rf_older_mispred));

// L505-506
assign bju_rf_iid_oldest = (!bju_chgflw_vld    || bju_rf_older_ex1)
                        && (!idu_mispred_stall || bju_rf_older_mispred);
```

**为什么需要年龄比较？** BIQ 乱序发射分支：程序序 `B1 … B2` 可能 B2 先执行。
若 B2 报了误预测、下一拍 B1 又到 EX1，会出现两种情况：

- B1 比 B2 **老** → B1 的检查结果依然有效（它不在 B2 的错误路径上），允许它
  产生新的误预测信号（甚至覆盖 B2 的，因为更老的分支优先级更高）；
- B1 比 B2 **新** → B1 本身就在错误路径上，结果作废，绝不能再发 chgflw。

`bju_rf_iid_oldest` 同时检查两个对象：正在 EX1 报误预测的分支（`bju_chgflw_vld`）
和已记录的历史误预测（`mispred_iid` 寄存器）。只有比它们都老，本指令才有
"发言权"。RTL 注释（L479-483）点明这是**时序优化：把本应在 EX1 做的比较挪到
RF 级**——RF 级 IID 已知而比较结果 EX1 才用，白捡一拍。

`ct_rtu_compare_iid` 是处理环形 IID 空间比较的小模块（IID 高位是 wrap 标志位），
详见 doc/rtu/ 的 encode/compare 章节。

### 2.2 RF→EX1 流水寄存器（ct_iu_bju.v:508-609）

锁存内容除了 IDU 给的操作数/功能码，还有**三个来自 PCFIFO 的同拍读出值**
（L581-584）：

```verilog
ex1_pipe2_pc[39:0]      <= pcfifo_bju_pc[39:0];        // 分支自身 PC（创建时存入）
ex1_pipe2_bht_pred      <= pcfifo_bju_bht_pred;        // 当时的 BHT 预测方向
ex1_pipe2_jmp_mispred   <= pcfifo_bju_jmp_mispred;     // IFU 已修过目标的标记
ex1_pipe2_chk_idx[24:0] <= pcfifo_bju_chk_idx[24:0];   // BHT 训练定位索引
```

即 RF 级用 `idu_iu_rf_pipe2_pid` 当地址查 PCFIFO（详见 03），把"当年预测时
的现场"取出来与马上要算出的真实结果对比。**这就是 PCFIFO 存在的根本原因：
预测信息产生于取指期，消费于执行期，中间隔了整个乱序调度，必须有个按 pid
索引的存储池把它带过来。**

### 2.3 EX1：方向判定（ct_iu_bju.v:614-661)

```verilog
assign bju_inst_br     = ex1_pipe2_func[6];   // jal 类（直接跳转）
assign bju_inst_jmp    = ex1_pipe2_func[7];   // jalr 类（间接跳转）
assign bju_inst_condbr = |ex1_pipe2_func[5:0];// 条件分支（6 位独热: BGEU..BEQ）

assign branch_beq_taken  = (src0 == src1);                       // L635
assign branch_bltu_taken = (src0 < src1);                        // L646
assign branch_blt_taken  = src0[63] && !src1[63]                 // L639-641
                        || (src0[63] ^~ src1[63]) && (src0[62:0] < src1[62:0]);
assign branch_bge_taken  = !branch_blt_taken;
assign condbr_taken = func[0]&bgeu | func[1]&bge | func[2]&bltu
                    | func[3]&blt  | func[4]&bne | func[5]&beq;   // L656-661
```

实现细节：

- **有符号比较不用 `$signed`**，而是手工分解：符号不同看符号（负<正），符号
  相同比低 63 位无符号大小。这让 blt 可以**复用 bltu 的比较器低位结果**
  （注释 L634 "Reduce logic consumption"）；
- bge/bgeu 直接取反，不再做比较；
- `func[5:0]` 是独热码，方向选择是一层 AND-OR——和 ALU 的 rslt_sel 同一套
  "译码前移"哲学。

### 2.4 EX1：目标地址计算（ct_iu_bju.v:663-727）

两条独立加法路径：

**分支/jal 路径（PC 相对，L673-690）**：

```verilog
assign bju_br_taken_tarpc[38:0]   = ex1_pipe2_pc[39:1] + sext(offset[20:1]);  // taken
assign bju_br_untaken_tarpc[38:0] = ex1_pipe2_pc[39:1] + (length ? 2 : 1);    // fall-through
assign bju_br_tarpc = bju_br_taken ? taken_tarpc : untaken_tarpc;
```

细节：地址按**半字**算（`pc[39:1]`，RVC 最小 2 字节对齐），fall-through 加
1 或 2 个半字由 `length`（2/4 字节指令）决定。L677-679 注释提到 corner case：
cjalr 被 IDU 拆成 lrw+jmp32 两个微操作时，链接地址要用原始 cjalr 的长度——
所以 length 必须从 ID 级一路带下来，不能在 BJU 重新猜。

**jalr 路径（寄存器间接，L695-718）**：

```verilog
assign bju_jump_tarpc[39:0] = src0[39:0] + sext(offset[11:0]);
```

**虚拟地址溢出检查（L688, 702-713）**：C910 虚拟地址有效位是 40 位（Sv39 + 1
位扩展），bit[39:38] 之上必须是符号扩展。分支只需检查 `tarpc[38]^tarpc[37]`
（偏移最多 ±1MB 跨不过更高位）；jalr 的 src0 是任意 64 位值，要检查 src0 高
26 位是否落在 4 个合法编码（全 0/全 1/±1 边界），加法后 bit[39]^~bit[38] 验证
无进位破坏。**非法目标不在 BJU 报异常，而是置 `page_fault` 标记并把 msb 清 0
（L690），让 IFU 取指时触发 instruction page fault**——异常统一从取指口报，
精确异常逻辑只需要处理一处。

### 2.5 EX1：误预测判定（ct_iu_bju.v:729-765）—— 本模块的灵魂

```verilog
// 方向误预测（L732-735）
assign bju_bht_mispred = bju_inst_condbr && (condbr_taken ^ ex1_pipe2_bht_pred)
                      || (bju_inst_condbr || bju_inst_uncondbr) && bju_br_page_fault;

// 目标误预测（L742-747）
assign bju_tarpc_cmp_fail = (ex1_pipe2_pc[39:0] != ex1_pipe2_src0[39:0]);
assign bju_jmp_mispred = bju_inst_jump && bju_tarpc_cmp_fail
                      || bju_inst_jump && !ex1_pipe2_rts && ex1_pipe2_jmp_mispred
                      || bju_inst_jump && bju_jump_page_fault;
```

三个精妙之处：

1. **方向检查就是一个 XOR**：实际 taken ^ 预测 taken。预测值是 PCFIFO 带来的
   "案发现场记录"。
2. **jalr 目标检查不比目标、比源**（L740-742 注释）：PCFIFO 创建时 IFU 存的
   不是预测目标本身，而是 **预测目标减去 offset**。于是执行期只需比较
   `pcfifo_pc == src0`，省掉一次"src0+offset 再比较"的串行路径——加法和比较
   并行化了。这是很漂亮的预计算技巧。
3. **`!rts && jmp_mispred`**：`ex1_pipe2_jmp_mispred` 是 IFU 在取指期就发现且
   已自行修正的目标错（如 indirect BTB 与 RAS 不一致）。对非 ret 指令，这标记
   说明预测目标信息已不可信，保守按误预测处理；ret（rts=1）则信 RAS 修正结果，
   只看地址比较。

**有效性闸门（L752-765）**：

```verilog
assign bju_older_inst_vld  = ex1_pipe2_inst_vld && ex1_pipe2_iid_oldest;
assign bju_chgflw_vld      = (bju_bht_mispred || bju_jmp_mispred)
                             && !rtu_iu_flush_chgflw_mask
                             && bju_older_inst_vld;
```

误预测要"算数"，必须：指令有效 + 比所有未决误预测老（2.1 的年龄比较）+
不处于 RTU flush 状态机的屏蔽窗口（`rtu_iu_flush_chgflw_mask`，flush 进行中
错误路径分支的 chgflw 必须压住，否则刚恢复的前端又被带偏）。

### 2.6 误预测 stall 状态机（ct_iu_bju.v:767-839）

两个独立的 stall 寄存器，**置位条件相同（chgflw_vld），清除条件不同**：

```verilog
// idu_mispred_stall（L798-816）: 清除条件 = rtu_yy_xx_flush（退休级flush）
else if(rtu_yy_xx_flush)   idu_mispred_stall <= 1'b0;
else if(bju_chgflw_vld) begin
    idu_mispred_stall <= 1'b1;
    mispred_iid[6:0]  <= ex1_pipe2_iid[6:0];     // 记下误预测者年龄
end

// ifu_mispred_stall（L822-837）: 多一个提前清除条件 = rtu_iu_flush_fe
else if(rtu_iu_flush_fe)   ifu_mispred_stall <= 1'b0;
else if(bju_chgflw_vld)    ifu_mispred_stall <= 1'b1;
```

这揭示了 C910 误预测恢复的完整剧本（"早重定向 + 晚清理"）：

```
EX1: 发现误预测
EX2: chgflw → IFU 立即从正确目标取指（前端抢跑）
     cancel → 杀死 IU 各级错误路径指令
     同时 idu_mispred_stall/ifu_mispred_stall 拉高
  …… 新指令最远只能走到 ID（被 stall 挡住），不进重命名 ……
退休期: 误预测分支成为 ROB 头 → RTU 发 flush_fe（前端可恢复取指节奏）
        → RTU 发 rtu_yy_xx_flush（后端按序刷新，重命名表回滚）
        → 两个 stall 解除，新路径指令开始 pipedown
```

**为什么新指令要在 ID 停住而不直接进入后端？** 因为后端此刻还混着错误路径
指令（已发射的无法精确逐条杀死），重命名表也是污染状态。等 RTU 在分支退休时
统一 flush 后端、恢复重命名映射，新指令才能安全进入。前端那段时间先把 IBUF
填满，flush 一到立即满速供指——损失被压到最小。L828-831 的注释解释了为何
ifu_stall 可以更早解除：flush_fe 后不会再有旧 RAS/JMP 指令退休来弄脏 RAS，
IFU 可以先恢复，但 IDU 必须等到完全 flush。

### 2.7 EX2：动作发出（ct_iu_bju.v:841-1019）

EX1→EX2 锁存所有结果（L881-968），然后：

**回写 PCFIFO（L973-984）**：把真实目标 PC、实际方向（condbr 的 taken）、
误预测标记写回 PCFIFO 对应项。`pid_expand[31:0]` 是 RF 级就展开好的 32 位
独热写使能（L848-852 用 ct_rtu_expand_32，又一个时序前移）。写回的意义：
RTU 退休时从 PCFIFO 弹出的将是**修正后的**信息，可直接用于更新退休 PC。

**完成总线（L989-997）**：`bju_cbus_ex2_pipe2_sel/iid/abnormal/bht_mispred/jmp_mispred`
→ CBUS 转发给 RTU。`abnormal` = 任一误预测，RTU 看到它就知道该指令退休时要
触发 flush 流程。

**取消与重定向（L1003-1019）**：

```verilog
assign iu_yy_xx_cancel    = ex2_pipe2_chgflw_vld;            // 全核取消
assign iu_ifu_chgflw_vld  = ex2_pipe2_chgflw_vld;            // IFU 重定向
assign iu_ifu_chgflw_pc   = {tar_pc_msb[23:0], tar_pc[38:0]};// 架构 VA[63:1]
assign iu_ifu_bht_check_vld    = ex2_pipe2_conbr_vld;        // 条件分支必发（不只误预测时）
assign iu_ifu_bht_condbr_taken = ex2_pipe2_conbr_taken;
assign iu_ifu_chk_idx[24:0]    = ex2_pipe2_chk_idx[24:0];
```

`iu_ifu_chgflw_pc[62:0]` 没有携带架构虚拟地址的 `VA[0]`。RISC-V 指令地址至少
按 2 字节对齐，因此 `VA[0]` 恒为 0；IFU 使用的完整字节地址应理解为
`{iu_ifu_chgflw_pc, 1'b0}`。同理，本模块中的 `tar_pc[38:0]` 表示低地址部分
`VA[39:1]`，其内部最低位对应架构地址位 1，而不是架构地址位 0。

注意 `bht_check_vld` 的条件是 `conbr_vld`（有效条件分支）而非 mispred——
**BHT 是计数器，预测对了也要加强**。这组信号对应 `doc/ifu/04_bht.md` 的写口，
也是 perf 统计 `Cond Branch Misp`（hpcp 相关 event）的数据源头。

`chgflw_vl/vlmul/vsew`（L1017-1019）：vsetvli 预译码机制需要——IFU 会根据
预测的向量配置预译码后续向量指令，重定向后必须连配置一起恢复，否则新路径
上的向量指令会被按错误的 vtype 预译码。

### 2.8 EX3：PCFIFO 二次 bypass（ct_iu_bju.v:1021-1116）

EX2 的写回信息再延一拍，以 `bju_pcfifo_ex3_*` 第二次送进 PCFIFO。这不是再写
一次 RAM，而是给 PCFIFO 的**读 bypass 网络**用的：RTU 的退休读发生在 EX2 写
的同拍或下一拍时，读出值必须反映最新写入——PCFIFO 内部用 ex2/ex3 两级 bypass
源做前递（详见 03_bju_pcfifo.md）。这是"写延迟 vs 读即时性"矛盾的标准解法。

---

## 3. 误预测代价量化

从本模块时序可推出 C910 的分支误预测最小代价：

```
EX2 重定向 → IFU 重新走 IP/IB/ID… 取指管线（~5 拍）
            + 新指令在 ID 等待分支退休 flush（取决于分支前还有多少未退休指令）
```

最好情况（分支立即退休）约 10+ 拍，ROB 里积压多时更久。这解释了 coremark
perf 报告中 `Cond Branch Misp 9.67%` 对 IPC 的显著伤害——每次误预测损失的
不只是取指延迟，还有后端排空时间。

---

## 4. 接口汇总

| 方向 | 对端 | 信号 | 拍 |
|------|------|------|-----|
| 入 | IDU | `idu_iu_rf_pipe2_*`（src/func/offset/pid/iid/rts/pcall/length） | RF |
| 入 | IFU | `ifu_iu_pcfifo_create0/1_*` | 取指期 |
| 入 | RTU | `rtu_iu_rob_read*_pcfifo_vld`（退休弹出）、`rtu_iu_flush_chgflw_mask/flush_fe/rtu_yy_xx_flush` | 退休期 |
| 出 | IFU | `iu_ifu_chgflw_*`（重定向）、`iu_ifu_bht_*`（训练）、`iu_ifu_pcfifo_full` | EX2 |
| 出 | IDU | `iu_idu_mispred_stall`、`iu_idu_pcfifo_dis_inst*_pid`（分发 pid） | - |
| 出 | 全核 | `iu_yy_xx_cancel` | EX2 |
| 出 | CBUS | `bju_cbus_ex2_pipe2_*` | EX2 |
| 出 | RTU | `iu_rtu_pcfifo_pop0/1/2_data[47:0]` | 退休期 |
| 出 | SPECIAL | `bju_special_pc[39:0]`（auipc 类指令需要的 PC） | RF |

---

## 5. Verdi 观察建议

层次：`...x_ct_iu_top.x_ct_iu_bju`

**看一次完整误预测**（推荐跑 bench_br_bimodal）：

| 顺序 | 信号 | 现象 |
|------|------|------|
| 1 | `ex1_pipe2_inst_vld` + `condbr_taken` vs `ex1_pipe2_bht_pred` | 两者不等的拍 |
| 2 | `bju_chgflw_vld`（EX1） | 同拍拉高 |
| 3 | `iu_ifu_chgflw_vld` + `iu_ifu_chgflw_pc`（EX2） | 下一拍重定向 |
| 4 | `iu_yy_xx_cancel`、`idu_mispred_stall`↑ | 取消+冻结 |
| 5 | `rtu_iu_flush_fe` → `rtu_yy_xx_flush` → `idu_mispred_stall`↓ | 若干拍后退休 flush 解冻 |

把这 5 步的波形截下来，就是 C910 误预测恢复机制的全部时序证据，与
`doc/branch_prediction.md` 第 12 节的观察组 5 配合使用。
