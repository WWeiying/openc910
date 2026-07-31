# C910 ROB 详解（ct_rtu_rob / ct_rtu_rob_entry）

> RTL 源文件：
> - `ct_rtu_rob.v`（6487 行，顶层：64 项例化 + 指针 + 完成端口 + 读端口）
> - `ct_rtu_rob_entry.v`（535 行，单个表项）
> - 内部还例化 `ct_rtu_rob_rt`（见 02）与 `ct_rtu_rob_expt`（见 03）
>
> 6500 行中约 4000 行是 64 项例化与 64:1 选择的规则展开。它与 IU 的
> PCFIFO（`docs/iu/03_bju_pcfifo.md`）采用了相近的实现母题：独热环形指针、
> 逐项实例以及展开后的选择网络；但二者的容量、表项格式、满阈值、读窗口和
> 创建/弹出协议并不相同，因此只能类比阅读，不能把 PCFIFO 的具体参数直接套到 ROB。

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

`inst_num[1:0]`：一个表项最多代表 **3 条架构指令**。是否允许折叠以及哪些
指令能够折叠，由 IDU 的 folding/派遣控制逻辑决定；RTU 不重新检查“是否简单、
是否同类、是否存在依赖”，只接收创建数据中的 `inst_num`、`cmplt_cnt` 及属性位，
并按这些字段维护完成与退休。因此，从 RTU 文档中可以确认“一个 ROB 项可代表
1~3 条指令”，但不能仅凭 RTU 反推出 IDU 的全部折叠资格条件。

- 4 个创建口表示最多接收 4 个内部派遣槽/ROB 项，不能简单乘以 3 得出 12 条
  架构指令；同拍全部 `inst_num` 的和受上游实际输入、拆分和折叠选择约束；
- 3 个退休槽各可弹出一个 `inst_num=1~3` 的项，所以**单拍**架构退休计数求和
  最大可到 9；这是折叠项在不同周期积累后同时到达队头的瞬时值，不是可持续 IPC。

折叠优化的本质是减少简单指令占用的 ROB 表项数和退休控制槽数，而不是提高前端产生
架构指令的速率。研究普通无异常 benchmark 时，ROB 水位按“项”统计，
`minstret`/IPC 按 `inst_num` 加权且屏蔽 `split` 项，二者不能混用。典型现象
是：三个 retire valid 只拉高一个，但若该项是非 split 折叠项且
`inst_num=3`，本拍的 `minstret` 增量仍为三；反过来，split 微操作退出 ROB
会占退休槽，却不单独增加 `minstret`。同步异常的计数边界见
`docs/rtu/04_retire.md` 第 4、6 节。

`pc_offset[2:0]` 是这一项覆盖的顺序指令长度，单位为 16 位半字；折叠项中可以
混合 16 位和 32 位指令。退休 PC 重建时加的是这个编码值，换算成字节地址后等价于
`pc_offset * 2`。`cmplt_cnt[1:0]` 则跟踪该项尚未收到的折叠完成数。两者都与
“ROB 项数”不同：前者是指令字节跨度，后者是完成事件数量。

### 1.3 表项状态机（entry.v:285-388）

```verilog
// vld（L285-297）
flush → 0;  create → data[VLD];  pop → 0
// cmplt_cnt（L340-354）: 创建装入折叠数，每收到完成递减
// cmplt（L376-386）: cmplt_cnt 即将归零时置 1
```

完成递减逻辑（L307-335）很讲究：7 个完成来源可能**同拍命中同一表项**
（折叠的 3 条指令在不同管线同时完成）。`cmplt_1/2/3_fold_inst` 枚举内部完成
向量 `x_cmplt_vld[0]`、`[1]`、`[5]`、`[6]` 的同拍组合，cnt 一次减
1/2/3。这四位在 ROB 顶层分别接体系结构执行 pipe0、pipe1、pipe6、pipe7：

```verilog
assign cmplt_cnt_cmplt_exist =
    {2{无完成}}        & cnt
  | {2{1条折叠完成}}    & (cnt - 1)
  | {2{2条折叠完成}}    & (cnt - 2)
  | {2{3条折叠完成}}    & 0
  | {2{|x_cmplt_vld[4:2]}} & 0;     // 体系结构 pipe2/3/4 对应非折叠项，直接清零
```

上面的伪代码刻意把最后一项写成 `[4:2]`，以表达真正的语义边界。原 RTL 在
`cmplt_cnt_cmplt_exist` 的清零项中写的是 `|x_cmplt_vld[6:2]`，但内部位
`[5]`、`[6]` 同时也包含在前面的 folding 枚举中；由于该清零项贡献的是常数
`2'b0`，不会覆盖它们已经算出的减计数结果。真正无条件令 `cmplt` 置位的是
`|x_cmplt_vld[4:2]`，也就是体系结构 pipe2、pipe3、pipe4。阅读这种按位或
形式时，必须先区分“内部向量下标”和“体系结构 pipe 编号”，也不能把某个
信号“出现在一个乘零项里”误解为它采用了该项的完成语义。

`x_cmplt_vld[6:0]` 的生成在顶层（rob.v:4589-4664）：7 条管线的 iid 低 6 位
经 `ct_rtu_expand_64` 展开成 64 位独热，AND 上 cmplt 有效，第 N 位连给
entryN。这里**确实存在地址译码**：`ct_rtu_expand_64` 就是显式的
6-to-64 二进制到独热译码器。更准确的描述是：译码在 ROB 顶层集中完成，
随后把 7 组逐项完成位分发给 64 个 entry；entry 内不再用 IID 做二进制比较，
而是直接消费属于自己的 7 位 `x_cmplt_vld`。

### 1.4 LSU 专属字段（entry.v:393-443）

`bkpta/b_data`（数据断点命中）、`no_spec_hit/miss/mispred`（LSU 数据推测
训练信息）只能由 pipe3/4 完成时更新——这些是 load/store 执行后才知道的事实，
退休时转交 HAD（断点）和 LSU 预测器（no_spec 系列）。它们有独立门控时钟
（`lsu_cmplt_clk`，L242-260），平时不翻转。

---

## 2. 指针体系（rob.v:4286-4488）

与 PCFIFO 相似，但参数和消费者不同的三组位置状态：

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
assign rob_full_updt_val = (updt == 61 || updt == 62 ||
                            updt == 63 || updt == 64);
```

这里的“满”是根据**本拍创建数减退休弹出数后的更新值**寄存出来的，不是简单的
`create_ptr == pop_ptr`。更新值达到 61~64 时，下一拍向 IDU 报 full。这样做的
意义是给已经进入创建路径、最多 4 项的一批派遣保留吸收空间。需要注意两点：

1. 阈值 61 并不表示 ROB 永远机械地空出 4 项；当可见 full 仍为 0 时，本拍更新
   可以从 60 到 64，随后 full 才拉高。
2. 该阈值是 ROB 的派遣时序保护参数。它与 PCFIFO 的提前反压思想相近，但不能仅凭
   “同样有余量”推出两者具有相同的流水延迟或相同余量值。

`rtu_idu_rob_empty = rob_empty && retire_rob_retire_empty`（L4466）不能只按
信号名猜第二项的含义。`rob_empty` 是 `rob_entry_num==0`；而
`retire_rob_retire_empty` 在当前 `ct_rtu_retire.v` 中直接等于
`lsu_rtu_all_commit_data_vld`，表示 LSU 已提交 store 所需的数据全部有效。
所以给 IDU fence/串行化逻辑的“ROB empty”实际上同时要求 **ROB 项数为零**
和**已提交 store 数据就绪**，不是在检查三个退休读缓冲项是否为空。

---

## 3. 读端口结构（rob.v:3884-4001, 4814-）

读窗口也采用“主体表项 + 前端读缓冲”的结构，与 PCFIFO 可以作实现方式上的类比：

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
`docs/idu/11_is_ctrl.md`），表项 case 四选一装入（entry.v:265-280）。
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

在某一次具体 benchmark 运行中，`rob_entry_num` 的均值和高水位持续时间可以描述
ROB 占用程度，但**不能单独证明后端执行单元是瓶颈**：高水位还可能由队头长延迟、
异常恢复等待、PREG/发射队列反压或 LSU 提交约束造成。应把它与 ROB 头部
`cmplt`、各 IQ not-ready 原因、写回事件和 `rtu_idu_rob_full` 同周期对齐。
任何固定百分比都属于某次运行结果，不是 ROB 结构的固有参数。
