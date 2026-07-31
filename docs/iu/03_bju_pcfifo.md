# C910 PCFIFO 详解（ct_iu_bju_pcfifo）

> RTL 源文件：
> - `ct_iu_bju_pcfifo.v`（3323 行，顶层：32 项管理 + 指针 + 读写口）
> - `ct_iu_bju_pcfifo_entry.v`（416 行，单个表项）
> - `ct_iu_bju_pcfifo_read_entry.v`（305 行，退休读缓冲项 ×3）
>
> 行数虽多，但 2/3 是 32 项例化和 32:1 选择 case 的机械展开，核心逻辑十分精炼。

---

## 1. 为什么需要 PCFIFO —— 设计动机

C910 的 ROB 表项**不存完整 PC**（为面积，ROB 只存 PC 增量/压缩信息），但有三类
消费者需要控制流指令在不同生命周期阶段的 PC/预测信息：

1. **BJU 执行时**：要对比"当时预测的方向/目标"和"现在算出的真实值"；
2. **pipe0 上的链接微操作**：jal/jalr 的链接寄存器写被 IDU 拆分后，计算
   `PC+4`（32 位 jal/jalr）或 `PC+2`（压缩 `C.JALR`）的微操作要知道原指令 PC；
3. **RTU 退休时**：要恢复后继退休 PC。非跳转项按 offset 递增，控制流项使用
   BJU 完成后写回 PCFIFO 的真实 next PC。此时消费的不是“仍保留的原始分支 PC”。

PCFIFO 就是为这三类消费者建立的 **32 项环形缓冲**：IFU 取指时按程序序创建，
BJU 执行时随机读+回写，RTU 退休时按程序序弹出。它可理解为
“控制流现场的伴随队列”。称作“影子 ROB”只能类比其顺序创建/顺序回收：
它不保存通用结果和完整异常状态，而且一个带链接的架构跳转可能占两项。

```
        创建(按序)            读/回写(乱序)            弹出(按序)
  IFU ──create0/1──► PCFIFO[32] ◄──pid 随机读/EX2回写── BJU
                          │
                          └──pop0/1/2(按序)──► RTU 退休 PC
```

### 表项编号（PID）的旅程

```
IFU 创建表项 → 占据 entry[create_ptr]
IDU IS 派遣分支时，从 assign_ptr 拿到该分支的 pid（5 bit）
pid 写进 BIQ 表项，随指令乱序流动
RF 级：idu_iu_rf_pipe2_pid 送回 PCFIFO 读出预测现场
EX2：按 pid 回写真实结果
退休：pop_ptr 按序弹出，表项回收
```

---

## 2. 表项内容（ct_iu_bju_pcfifo_entry.v）

每项三个状态位 + 两组数据字段：

| 字段 | 写入时机 | 内容 |
|------|----------|------|
| `vld` | 创建置 1 / 弹出或 flush 清 0（L278-290） | 表项占用 |
| `cmplt` | BJU EX2 回写置 1（L297-311） | 已执行完成 |
| `flush` | cancel/flush_fe 时对在错误路径上的项置 1（L319-329） | 待清除标记 |
| `chk_idx[24:0]` `bht_pred` `jmp_mispred` | **创建时**（create_clk 域，L336-353） | 预测现场：BHT 索引、预测方向、IFU 已修目标标记 |
| `pc[39:0]` `bju/condbr/pcall/pret/jmp` `bht_mispred` `length` | **创建时写 PC，EX2 回写其余**（cmplt_clk 域，L359-401） | 创建时 pc=预测相关 PC；完成时 pc 被**真实目标 PC 覆盖**，并补齐类型/误预测信息 |

注意 pc 字段的双重身份（L371-390）：创建时存的是"用于执行期对比的 PC"
（见第 4 节），完成时被覆盖为"真实目标 PC"（供 RTU 退休用）。一个字段两个
生命周期阶段，存储复用。

**flush 位的两段式清除**（L282, L323）很关键：

```verilog
// 置 flush：误预测 cancel 或前端 flush 时、且还没到后端 flush
else if(vld && (iu_yy_xx_cancel || rtu_iu_flush_fe) && !rtu_yy_xx_flush)
    flush <= 1'b1;
// 清 vld：后端 flush 时，flush 标记过的（或正赶上 cancel 的）项被回收
else if(vld && rtu_yy_xx_flush && (flush || iu_yy_xx_cancel || rtu_iu_flush_fe))
    vld <= 1'b0;
```

为什么不在 cancel 时立刻清掉错误路径表项？——因为**误预测分支自己以及更老的
分支还没退休**，RTU 接下来几拍还要按序弹出它们的表项；错误路径上的新表项只能
先打标记，等后端 flush（此时老表项都已弹完）再统一回收。这与 02_bju.md 第 2.6
节"早重定向 + 晚清理"的节奏完全对应。

---

## 3. 创建通路（顶层 L1671-2053）

### 3.1 IFU 创建数据打包与暂存（L1676-1842）

IFU 每拍最多送 2 条创建请求（create0/1），110 位打包格式（L1676-1693）：

```
[39:0] cur_pc   [79:40] tar_pc(预测目标)   [80] bht_pred
[81] jal  [82] jalr  [83] dst_vld  [84] jmp_mispred  [109:85] chk_idx
```

创建请求先在 `create_entry0/1_vld/data` 暂存一拍（L1765-1821）再真正写入表项。
注释（L1760-1762）解释了一个微妙点：**只要 PCFIFO 不满就必须接受创建**——
因为对应的分支指令可能已经在向 BIQ 派遣，如果创建被丢弃，指令执行时会读到
空表项。`available = !pcfifo_full` 是入口闸门，IFU 看到 full 就不再发分支。

### 3.2 一条分支可能占两项（L1844-1926）

```verilog
assign pcfifo_create0_2_entry = create_entry0_dst_vld;        // L1847
assign pcfifo_create1_en = (create_entry0_vld && pcfifo_create0_2_entry
                         || create_entry1_vld) && ...          // L1855
```

`dst_vld`（jal/jalr 带链接寄存器写）的分支**占用两个表项**。原因在创建 PC 的
选择逻辑（L1869-1907）里：

| 指令 | 第 1 项存 | 第 2 项存 |
|------|----------|----------|
| beq…（无 dst） | cur_pc | - |
| jr/ret（jalr 无 dst） | **tar_pc**（预测目标-offset） | - |
| jal ra（有 dst） | cur_pc（给链接微操作） | cur_pc（给分支检查算目标） |
| jalr ra（有 dst） | cur_pc（给链接微操作） | tar_pc（给目标比对） |

背景：IDU 把带链接的跳转拆成两个微操作——pipe0 SPECIAL 上的“用 PC 加
指令长度并写 rd”和 pipe2 上的“跳转检查”。**两个微操作各拿一个 pid，各自从
PCFIFO 读自己需要的 PC**：
链接微操作经读口 1（`idu_iu_rf_pipe0_pid` → `bju_special_pc`，L2403-2441）读
cur_pc；检查微操作经读口 0（`idu_iu_rf_pipe2_pid`，L2322-2363）读对比基准。

这也解释了 02_bju.md 中 jalr 目标检查"比 src0 而非比目标"的实现前提：jalr
检查项存的 tar_pc 在 IFU 侧已经减掉了 offset。

每拍最多创建 3 项（create0/1/2 三个写口）：entry0 双项 + entry1 单项，或
entry0 单项 + entry1 双项。这个上限与 IFU 的指令包掩码配套：IPDP 的
`chgflw_mask` 保留最老的无条件改变流指令及其可能存在的 32 位第二半字，并屏蔽
其后的年轻指令；条件分支不作为该掩码的截断点。因此同一有效指令包内，较老的
PC 操作可以是单项条件分支，较年轻的带链接跳转可占双项，但两条都要求双项的
无条件跳转不会同时送到 PCFIFO。

PCFIFO 自身没有第四个创建口，也没有在本地修复非法四项请求的逻辑，所以
“同拍两路不能同时都要求双项”仍是 IFU→PCFIFO 必须保持的接口不变量。验证时
可加断言：
`!(create_entry0_vld && create_entry1_vld &&
   create_entry0_dst_vld && create_entry1_dst_vld)`。

### 3.3 三组指针（一热环形）

| 指针 | 宽度 | 步进时机 | 用途 |
|------|------|----------|------|
| `pcfifo_create0_ptr` | 32 位独热（L1953-1977） | 每拍按创建数移 1~3 位 | 下一个写入位置 |
| `pcfifo_assign0~3_ptr` | 5 位二进制 ×4（L2084-2116） | IS 派遣 pcfifo 指令时 +num | 给 IDU 分发 pid |
| `pcfifo_pop0_ptr/pid` | 32 位独热 + 5 位 ×3（L2728-2778） | RTU 退休读 1~3 条时步进 | 按序弹出位置 |

独热指针移位即步进（`{ptr[30:0],ptr[31]}`），在直接按位使能的消费点无需再把
二进制索引译成 32 位独热；
二进制指针便于做加法。同一逻辑位置两种编码并存、各取所长，
`ct_rtu_encode_32 / expand_32` 负责两种编码互转（L1985-2011, L2119-2124）。

**满判定**（L2237）：

```verilog
assign pcfifo_full = |(pcfifo_create5_ptr[31:0] & entry_vld[31:0]);
```

`create5_ptr` 是从当前 create0 位置向前偏移 5 项的位置。该位置仍有效，表示
环上连续可用空间已经降到保护阈值，于是提前拉高 full。它不是传统意义上
“32 项全部占满才 full”，而是一个为创建暂存、最多三项的内部展开写入和反压
传播留出余量的低空闲水位。准确的瞬时占用数还受 create-entry 暂存和同拍 pop
影响，不能只把 `32-6` 当成固定可用容量。

**flush 时指针恢复**（L2736-2747）：误预测/前端 flush 时，assign_ptr 复位到
create_ptr（错误路径上分派出去的 pid 作废重发）；后端 flush 时 pop_ptr 视场景
恢复到 create_ptr（cancel 同拍）或 assign_ptr——保持三组指针重新一致。

---

## 4. 读通路

### 4.1 RF 级两个随机读口（L2284-2441）

```verilog
case (idu_iu_rf_pipe2_pid[4:0])          // 读口 0：BJU 检查用
  5'd0: pcfifo_bju_data = entry0_rf_read_data;  // {chk_idx,jmp_mispred,bht_pred,pc} 67 位
  ...
case (idu_iu_rf_pipe0_pid[4:0])          // 读口 1：pipe0 链接/auipc 用
  5'd0: pcfifo_special_data = entry0_rf_read_data;
```

32:1 组合选择，pid 为索引。输出在 BJU 的 RF→EX1 寄存器锁存（见 02_bju.md
2.2），因此该选择网络位于 RF 到 EX1 的时序区间；是否成为关键路径仍需综合
时序报告确认，不能把“位于某一级”直接等同于“延迟已经被隐藏”。

### 4.2 EX2 完成写口（L2449-2506）

`bju_pcfifo_ex2_pid_expand`（BJU 在 RF 级就展开好的独热码）直接作为 32 项的
`cmplt_en`。同时把写入数据拼成 48 位 bypass 格式（L2488-2496）备用：

```
[47]=length [46]=bht_pred [45]=1(bju已完成) [44]=bht_mispred
[43]=jmp [42]=pret [41]=pcall [40]=condbr [39:0]=真实目标pc
```

### 4.3 退休读：read_entry 缓冲 + 两级 bypass（L1619-1668, 2508-2677）

这是 PCFIFO 最精细的部分。RTU 每拍最多按序弹 3 项，直接做三个 32:1 mux 会把
延迟压到退休关键路径上。解法：**用 3 个 read_entry 寄存器把"接下来要弹的
3 项"提前缓存**：

```
pop_ptr ──► 6 个 32:1 mux（pop0~5_data，L2882-3325）
                  │  按本拍弹出数选 pop1~3/2~4/3~5
                  ▼
        read_entry0/1/2（寄存器，下一拍就绪）──► RTU 直接读寄存器
                  ▲
   entry 状态变化时刷新（create_to_read_entry_en，L2577-2585）
```

- 弹 N 条时，read_entry 用 popN~popN+2 的数据刷新（L2514-2572）——这就是
  pop3/4/5 三个"超前读口"存在的原因；
- 不弹但下 3 项的 vld/cmplt 状态变了（如 BJU 刚完成回写），也要刷新
  （L2577-2585 比较 pop 数据与 read_entry 现值的 VLD/CMPLT 位）；
- 万一 BJU 的 EX2/EX3 回写与 RTU 读同拍发生，read_entry 来不及刷新，则输出级
  做 pid 比较直接选 EX2/EX3 bypass 数据（L2783-2799, 2634-2677）：

```verilog
assign pcfifo_pop0_bypass_sel[1] = bju_pcfifo_ex2_inst_vld
                                   && (bju_pcfifo_ex2_pid == pcfifo_pop0_pid);
assign pcfifo_pop0_bypass_sel[2] = bju_pcfifo_ex3_inst_vld && (ex3_pid == pop0_pid);
case(pcfifo_pop0_bypass_sel)  // read_entry / ex2 bypass / ex3 bypass 三选一
```

这正是 02_bju.md 2.8 节 BJU 保留 EX3 级 `bju_pcfifo_ex3_*` 信号的消费处：
**EX2 写还没沉淀进 read_entry 寄存器、EX3 时 read_entry 才更新，两拍窗口
都要能 bypass**，否则刚完成就退休的分支会读到旧值。

最终送 RTU 的 `iu_rtu_pcfifo_pop0/1/2_data[47:0]` 去掉了内部状态高 3 位
（vld/flush/cmplt 不需要给 RTU，L2633 注释）。

---

## 5. 容量与性能

- **32 项**：限制了在飞分支数（每条带链接的跳转还占双项）。分支密集代码
  （如 bench_br_* 系列）中若 PCFIFO 满，`iu_ifu_pcfifo_full` 反压 IFU 停止
  取分支——perf 中前端 stall 的一个隐性来源；
- `create5_ptr` 阈值会在物理 32 项尚未全占满时提前反压；预留项用于吸收已经
  在途的创建，不应把 PCFIFO 对外能力简单写成“有效容量 26 项”。应在波形中
  对 `entry_vld[31:0]` 做 popcount，并与 create 暂存、create0/1/2、pop 数和
  `pcfifo_full` 同拍对齐，才能得到真实占用与水位；
- ROB 是 64 项，而 PCFIFO 表项只分配给需要保存控制流现场的微操作，且带链接
  跳转可能占两项。两者不能按固定比例换算；判断 PCFIFO 是否成为限制，应直接
  观察 `pcfifo_full`、创建数、分配数和 ROB 水位，而不能从静态分支比例推导。

---

## 6. Verdi 观察建议

层次：`...x_ct_iu_bju.x_ct_iu_bju_pcfifo`

| 信号 | 看什么 |
|------|--------|
| `ifu_iu_pcfifo_create0_en/cur_pc/tar_pc/bht_pred` | IFU 创建一个预测现场 |
| `pcfifo_create0_ptr`（独热） | 写指针环形移动 |
| `iu_idu_pcfifo_dis_inst0_pid` | 派遣时 pid 发放 |
| `idu_iu_rf_pipe2_pid` + `pcfifo_bju_pc/bht_pred` | 执行期读回现场 |
| `entry_pop_en`、`iu_rtu_pcfifo_pop0_data` | 退休按序弹出 |
| `pcfifo_full` | 分支密集段的反压 |
| 某一项的 `vld/cmplt/flush`（如 `x_ct_iu_bju_pcfifo_entry5`） | 单项生命周期：创建→完成→弹出/flush 回收 |

推荐用 bench_br_ras（call/ret 密集）观察 dst_vld 分支的双项创建现象：
`pcfifo_create0_en` 与 `pcfifo_create1_en` 同拍有效但 `ifu_iu_pcfifo_create1_en` 为 0。
