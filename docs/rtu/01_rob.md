# C910 ROB 详解（ct_rtu_rob / ct_rtu_rob_entry）

> RTL 源文件：
> - `ct_rtu_rob.v`（6487 行，顶层：64 项例化 + 指针 + 完成端口 + 读端口）
> - `ct_rtu_rob_entry.v`（535 行，单个表项）
> - 内部还例化 `ct_rtu_rob_rt`（见 02）与 `ct_rtu_rob_expt`（见 03）
>
> 6500 行中约 4000 行是 64 项例化与 64:1 选择的机械展开，模式与 IU 的
> PCFIFO（doc/iu/03）完全相同：独热环形指针 + entryN 重命名连线。

---

## 1. 核心设计：40 位的"瘦"表项 + 指令折叠

### 1.1 表项字段（ct_rtu_rob_entry.v:168-195）

```verilog
parameter ROB_WIDTH = 40;
// [0]vld [1]cmplt [3:2]cmplt_cnt [6:4]pc_offset [7]split [8]intmask
// [9]bju [10]pcfifo [11]ras [12]store [14:13]bkpta/b_data [16:15]bkpta/b_inst
// [18:17]inst_num [19]fp_dirty [20]load [23:21]no_spec_hit/miss/mispred
// [30:25]vlmul/vsew/vsetvli/vec_dirty [38:31]vl [39]vl_pred
```

对比教科书 ROB（PC+目的寄存器+结果+异常码，每项上百位），C910 的表项**只有
40 位**，因为三类信息都被外包了：

| 教科书 ROB 存什么 | C910 放哪里 | 为什么 |
|------------------|------------|--------|
| 完整 PC | 不存！只存 3 位 `pc_offset`，跳转目标在 PCFIFO | 顺序执行段 PC 可增量重建（见 02） |
| 结果数据 | PRF（物理寄存器堆，写回即入） | 重命名架构的标准做法 |
| 异常向量/mtval | 单独一个异常缓冲项（见 03） | 异常极少，64 项各留 50 位太浪费 |

**64 项 × 40 位 ≈ 2.5Kb**，比保守设计小一个数量级。这是 C910 退休系统的
最核心取舍：**ROB 只管"序"，不管"值"**。

### 1.2 指令折叠（folding）

`inst_num[1:0]`：一个表项最多代表 **3 条指令**。IDU 把相邻的简单指令
（无依赖冲突、同类）折叠进一个 ROB 项派遣，于是：

- 4 个创建口/拍 × 3 条/项 → 派遣带宽峰值 12 条/拍（实际受 IDU 3 译码限制）；
- 3 个退休口/拍 × 3 条/项 → 退休带宽峰值 9 条/拍。

`pc_offset[2:0]` 是这一项**全部折叠指令的总长度**（半字数，2/4 字节混合），
退休 PC 一次加完。`cmplt_cnt[1:0]` 跟踪"还有几条没完成"。

### 1.3 表项状态机（entry.v:285-388）

```verilog
// vld（L285-297）
flush → 0;  create → data[VLD];  pop → 0
// cmplt_cnt（L340-354）: 创建装入折叠数，每收到完成递减
// cmplt（L376-386）: cmplt_cnt 即将归零时置 1
```

完成递减逻辑（L307-335）很讲究：7 条管线的完成可能**同拍命中同一表项**
（折叠的 3 条指令在不同管线同时完成）。`cmplt_1/2/3_fold_inst` 枚举
pipe0/1/5/6（可承载折叠指令的管线）的同拍组合，cnt 一次减 1/2/3：

```verilog
assign cmplt_cnt_cmplt_exist =
    {2{无完成}}        & cnt
  | {2{1条折叠完成}}    & (cnt - 1)
  | {2{2条折叠完成}}    & (cnt - 2)
  | {2{3条折叠完成}}    & 0
  | {2{|x_cmplt_vld[6:2]}} & 0;     // 非折叠管线(BJU/LSU)完成→必为单指令项,直接清
```

注意最后一行：BJU/LSU/CSR 指令**不参与折叠**（一项一条），它们的完成直接把
cnt 清零置 cmplt——又省了一个减法器。

`x_cmplt_vld[6:0]` 的生成在顶层（rob.v:4589-4664）：7 条管线的 iid 低 6 位
经 `ct_rtu_expand_64` 展开成 64 位独热，AND 上 cmplt 有效，第 N 位连给
entryN——**完成端口就是 7 个 64 位独热位图的按位或**，无任何地址译码器。

### 1.4 LSU 专属字段（entry.v:393-443）

`bkpta/b_data`（数据断点命中）、`no_spec_hit/miss/mispred`（LSU 数据推测
训练信息）只能由 pipe3/4 完成时更新——这些是 load/store 执行后才知道的事实，
退休时转交 HAD（断点）和 LSU 预测器（no_spec 系列）。它们有独立门控时钟
（`lsu_cmplt_clk`，L242-260），平时不翻转。

---

## 2. 指针体系（rob.v:4286-4488）

与 PCFIFO 同款三套指针：

| 指针 | 形式 | 步进 |
|------|------|------|
| `rob_create0_ptr` | 64 位独热环形（L4318-4373） | 每拍 +0~4（按创建数移位） |
| `rob_create0~3_iid` | 7 位二进制 ×4（同步 +0~4） | 派遣时发给 IDU 当 IID |
| pop 指针（rob_rt 内） | 64 位独热 ×3 | 每拍 +0~3（按退休项数） |

**iid 的 wrap 位天然形成**：`iid+4` 在 64 边界自然溢出进第 7 位，无需专门
维护——这就是 IID 编码与 ROB 索引绑定的好处。

**满判定用计数器而非指针比较**（L4408-4488）：

```verilog
rob_entry_num <= num + create_add(0~4) - pop_sub(0~3);
assign rob_full_updt_val = (updt >= 61);     // 留 4 项余量(61~64 都算满)
```

为什么留 4 项？IDU 的派遣决定在前一拍做出，full 反压晚一拍生效，途中最多
还有一拍 ×4 项的创建在路上。与 PCFIFO 留 6 的道理相同（doc/iu/03 第 3.3 节）。

`rtu_idu_rob_empty = rob_empty && retire_rob_retire_empty`（L4466）：ROB 计数
为 0 还不够，**退休读缓冲里的项也要清空**才算真空——CSR 串行化等待管线排空
时靠这个信号。

---

## 3. 读端口结构（rob.v:3884-4001, 4814-）

与 PCFIFO 的 read_entry 异曲同工：

```
64 项主体 ──5 个 64:1 读 mux（read0~4_ptr 顺序错开）──►
   3 个 retire read entry（独立的 ct_rtu_rob_entry 例化，L3884-4001）
   ──► rob_rt 模块做退休判定与 PC 重建
```

退休最多 3 项/拍，读 5 个口是为了**退休的同时预取后续表项**刷新读缓冲
（弹 3 项时 read3/4 的数据补位）。退休读缓冲是真正的 rob_entry 实例而非
纯寄存器——它们还要继续接收完成更新（指令进入退休窗口后才完成的情况）。

---

## 4. 创建数据从哪来

`idu_rtu_rob_create0~3_data[39:0]` 由 IDU 的 is_ctrl 打包（见
`doc/idu/11_is_ctrl.md`），表项 case 四选一装入（entry.v:265-280）。
注意 ROB 表项创建发生在**派遣拍**（IS），而非取指或译码——表项内容
（折叠数、store/load/bju 标记、vl 配置）都是派遣时刻已确定的静态属性。

---

## 5. Verdi 观察建议

层次：`...x_ct_rtu_top.x_ct_rtu_rob`

| 信号 | 看什么 |
|------|--------|
| `rob_entry_num[6:0]` | ROB 水位：满 64 → 后端堵塞（Backend Stall 的来源之一） |
| `rob_create0_iid[6:0]` | IID 发放，观察 wrap 位翻转 |
| `idu_rtu_rob_create0_en` ~ `create3_en` | 派遣宽度 |
| 任一 `x_ct_rtu_rob_entryN` 的 `cmplt_cnt/cmplt` | 折叠项的完成递减 |
| `rtu_idu_rob_full` | 反压 IDU 的瞬间 |

跑 coremark 时 `rob_entry_num` 的均值大致反映后端拥塞度；配合 perf 的
`Backend Stall 38%` 对照看很直观。
