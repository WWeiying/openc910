# C910 IU 除法单元详解（ct_iu_div）

> RTL 源文件：
> - `ct_iu_div.v`（1278 行，控制状态机 + 预处理 + 结果选择）
> - `ct_iu_div_srt_radix16.v`（319 行，SRT 基 16 迭代核，内部复用 VFDSU 的迭代单元）
> - `ct_iu_div_entry.v`（187 行，2 项除法结果缓存）
>
> 挂在 Pipe0，非流水（同一时刻只服务一条除法），**变延迟**。除零、溢出和
> 缓存命中可跳过 SRT 迭代；一般情况的主迭代按每轮 4 个商位组织。这里的
> “跳过迭代”不等于从 RF 到写回只需 1~2 个周期，因为状态机仍要经过请求、
> 写回口预约和写回状态。模块还包含一个 2 项除法结果缓存。

---

## 1. 总体结构与状态机

### 1.1 状态机（ct_iu_div.v:222-388）

```verilog
parameter IDLE=6'b000_000; DIV_RF=6'b000_011; EX1=6'b001_011; EX2=6'b010_011;
          EX3=6'b011_011; REQ=6'b100_011; DIV_WF_WB=6'b011_010;
          DIV_WB=6'b000_101; DIV_WB1=6'b001_101;
```

`DIV_WB1` 在参数和源码注释中被保留为“经 pipe1 写回”的编码，但当前
`div_next_state` 的全部转移都不会进入它：`DIV_WF_WB` 固定转到 `DIV_WB`，
实际结果借用 pipe0 写回通道。因此不能把 `DIV_WB1` 画成当前可达功能状态；
它更像是遗留或预留编码。

```
          issue           rf_sel        非特殊         disp>=0       迭代完
 IDLE ────────► DIV_RF ────────► EX1 ────────► EX2 ────────► EX3 ──┐
   ▲                              │特殊结果       │被除数<除数      │循环
   │                              ▼              ▼               ▼
   │                             REQ ◄──────────┴───────────  x_srt_finish
   │                              │
   └──── DIV_WB ◄── DIV_WF_WB ◄──┘
        （写回 rbus）  （等 pipe0 写回口空闲）
```

各状态含义（L304-313 注释）：EX1 取绝对值+特殊检测；EX2 移位对齐；EX3 SRT
迭代（停留多拍）；REQ→DIV_WF_WB→DIV_WB 是写回三部曲。

状态编码暗藏玄机——**控制信号直接取状态位**（L368-388）：

```verilog
assign iu_idu_div_busy     = div_cur_state[1];        // xx_x1x 的状态都算 busy
assign div_wb_inst_vld     = div_cur_state[2];        // xx_1xx = 写回窗口
assign div_wb0_inst_vld    = (div_cur_state[3:2] == 2'b01);
assign iu_idu_div_wb_stall = div_cur_state[5];        // REQ 状态预约写回口
```

状态编码不是普通递增序号，而是让若干控制条件可直接取状态位或少量位比较。
这减少了部分译码门级，但“直接取位”仍有寄存器 Q 到组合线的传播延迟，不能写成
物理意义上的“0 延迟”。

### 1.2 与 IDU 的握手

| 信号 | 含义 |
|------|------|
| `idu_iu_is_div_issue` | IS 级发射除法（早于 RF 一拍，启动状态机） |
| `idu_iu_rf_div_sel` | RF 级确认（发射可能失败，DIV_RF 状态没等到就回 IDLE，L338-341） |
| `iu_idu_div_busy` | 除法器占用中，AIQ0 不许再发除法 |
| `iu_idu_div_wb_stall` | REQ 状态拉高：**预约下拍的 pipe0 写回口**，IDU 暂停向 pipe0 发会用写回口的指令 |
| `iu_idu_div_inst_vld + preg_dup0~4` | 写回窗口 + 目的 preg 广播（5 份复制，唤醒消费者） |

**为什么写回要"等待+预约"？** 除法器没有自己的写回端口，借用 pipe0 ALU 的
rbus ex1 通道（见 08_rbus.md）。变延迟单元随时可能完成，必须先用 wb_stall
在 IDU 处"清场"一拍，确保写回那拍 pipe0 的 EX1 没有 ALU 结果与之冲突。
这是**共享写回口的低成本仲裁**：让低频的除法迁就高频的 ALU。

---

## 2. 逐逻辑块讲解

### 2.1 EX1：操作数预处理（ct_iu_div.v:445-904）

```verilog
// 字宽指令先把 32 位操作数符号扩展成 64 位（L451-459）
assign div_ex1_div_src0 = word_width ? {{32{sign_en && src0[31]}}, src0[31:0]} : src0;
// 取绝对值（L889-897）—— SRT 核只做无符号除法
assign div_ex1_src0_abs = (sign_en && src0[63]) ? (~src0 + 1) : src0;
// 结果符号在 EX1 就定下（L898-900）
assign div_ex1_div_result_neg = sign_en && (src0[63] ^ src1[63]);  // 商：异号为负
assign div_ex1_rem_result_neg = sign_en && src0[63];               // 余数：随被除数
```

**有符号除法 = 绝对值无符号除 + 符号修正**，这是教科书做法；符号提前算好，
写回前对 SRT 结果取补（L1086-1092）即可。

与取绝对值**并行**，EX1 还做了两组前导 1 检测（L467-884，四个巨型 64 项
优先编码器）：正数直接找首 1（`pos_ff1_disp`），负数用专门的"取反后首 1"
检测器（`neg_ff1_disp`，L619-747——在原码上等价地找"首个 0 的位置"附近判定，
避免等待取反加 1 完成后再编码，**消掉了串行依赖**）。按符号选择（L879-884）。

### 2.2 EX1：特殊结果检测（L906-927）—— 快速通道

```verilog
assign div_ex1_div_by_0 = (src1 == 0);
assign div_ex1_overflow = sign_en && (src0 == 64'h8000...0) && (src1 == -1);
assign div_ex1_match_entry0/1 = 操作数与缓存项完全相同（L913-922）;
assign div_ex1_special_result = 以上任一 → 状态机跳过 EX2/EX3 直达 REQ;
```

RISC-V 规定除 0 和溢出**不产生异常**而是返回规定值（L1163-1177）：

| 情形 | 商 | 余数 |
|------|----|----|
| 除 0 | 全 1（-1） | 被除数本身（字宽时取低 32 符扩，L1164-1169 引 riscv-isa-manual issue 56） |
| 溢出（MIN/-1） | MIN（0x8000…/0xffffffff80000000） | 0 |
| 被除数<除数（disp_0，EX2 检出） | 0 | 被除数 |

第三种"快速结果"在 EX2 检出：`div_exp_disp = dvr_disp - dvd_disp` 为负
（即被除数有效位数 < 除数，L990-993）说明商必为 0，同样跳过迭代。

### 2.3 除法结果缓存（ct_iu_div_entry.v + L1104-1157）—— 特色设计

2 项并行比较缓存，每项 258 位：

```
[63:0] src0  [127:64] src1  [191:128] 商  [255:192] 余数  [256] sign_en  [257] word_width
```

- **命中**（EX1 同时比较两项；操作数、`sign_en` 和 `word_width` 全相同）：
  跳过整个迭代，按缓存
  返回（L1226-1254 的结果四选一中 entry0/entry1 两路）；
- **填充**：只有正常 SRT 结果在写回窗口写入；除零、溢出和缓存命中结果不会
  再填充。`div_entry0_older` 是两项替换/近因状态：命中 entry0 后将 entry1
  标成较老，命中 entry1 后将 entry0 标成较老，写入时替换较老项并更新状态。
  因此它不只是“每次写机械交替”，读命中也会影响下一次替换选择；
- `cp0_iu_div_entry_disable` 可由 CSR 关掉此功能（验证/规避用）。

该结构没有单独的 valid 位：复位时两项被初始化成两组合法的哨兵操作数/结果，
命中完全由字段相等决定。这不会造成错误，因为复位值本身就是对应运算的正确商余；
但观察“缓存命中率”时应知道，极少数输入可能命中复位预置项，而不是先前动态填充项。

**为什么值得做？** 编译器可能为同一对操作数生成相邻的 `div` 与 `rem`。
第一条若走正常迭代并完成填充，第二条在表项未被替换、缓存未禁用，且两个输入、
signed/unsigned 模式和 word/xlen 模式完全一致时即可命中，复用同一份商和余数。
所以准确说法是“典型成对序列有很高的命中机会”，不是“第二条必然命中”，也
不等同于前端把两条指令融合成一条：ROB、发射和写回仍分别处理两条指令。

### 2.4 SRT 基 16 迭代核（ct_iu_div_srt_radix16.v）

预处理（srt_radix16.v:164-168）：

```verilog
assign initial_remainder_in[70:0] = {7'b0, dvd << dvd_disp};   // 被除数左对齐
assign initial_divisor_in[65:0]   = {dvr << dvr_disp, 2'b0};   // 除数左对齐
```

两个操作数都**规格化到最高位**，于是迭代次数只取决于
`exp_disp = dvd 有效位数 - dvr 有效位数`（srt_radix16.v:263-264）：

```verilog
assign srt_cnt_ini_tmp[6:0] = x_srt_exp_disp + 2;
assign srt_cnt_ini[6:0]     = srt_cnt_ini_tmp >> 2;   // 每轮出 4 位商（radix-16）
```

`srt_cnt_ini_tmp = exp_disp + 2`，随后通过右移、低位非零归约和减一形成内部
倒计数初值。它表达的是“指数差越大，需要覆盖的商位越多”，但倒计数初值、
EX3 实际驻留拍数和 RF 到写回的总延迟不是同一个量；`srt_remainder_zero`
还可以提前终止（`srt_radix16.v:276-278`）。

因此不应把 `6~22` 直接写成无条件延迟规格。建议在波形中定义：

```text
接收时刻 = idu_iu_rf_div_sel
迭代拍数 = div_cur_state == EX3 的周期数
结果时刻 = div_rbus_pipe0_data_vld
总延迟   = 结果时刻 - 接收时刻
```

再分别统计除零/溢出、缓存命中、`disp_0`、余数提前为零和完整迭代。这样得到的
范围才对应当前仿真配置，也能解释每个样本为何长或短。

迭代体复用了浮点除法器的 `ct_vfdsu_srt_radix16_only_div`（srt_radix16.v:172
例化）——基 16 SRT 即每拍做两级基 4 商选择（查商表 + CSA 部分余数更新），
商以冗余形式（正/负两个向量）累积，最后用一次减法恢复（on-the-fly conversion
在 qt 寄存器中完成）。整数与浮点共享迭代核，又是一处面积复用。

### 2.5 写回（L1216-1273）

```verilog
// 四选一：正常 SRT / 缓存命中 0 / 缓存命中 1 / 特殊值（L1226-1234）
case({expt, entry1, entry0, normal}) ...
// div/rem 由指令类型选（L1272-1273）
assign div_rbus_data = div_ex1_div ? div_result_data : rem_result_data;
assign div_rbus_pipe0_data_vld = div_wb0_inst_vld;   // DIV_WB 状态，借 pipe0 通道
```

写回同拍，`iu_idu_div_inst_vld + preg_dup*` 向 IDU 广播目的 preg 的数据就绪
窗口。依赖消费者据此更新 ready，但能否在下一拍发射还取决于队列选择、源操作数
是否全部就绪、执行端口竞争以及 stall/flush，不能由这组广播信号单独保证。

---

## 3. 完成汇报路径

除法的 CBUS 记账由 `idu_iu_rf_div_sel` 打一拍形成，因此可能在 SRT 迭代结束前
到达 ROB。准确术语应是：**CBUS `cmplt` 已到达，但 preg 数据尚未 writeback**。
消费者仍要等待真正的 preg 唤醒/写回，不能把 `cmplt` 当作可读数据。

RISC-V 整数除法本身不因除零或有符号溢出产生同步异常，这使“提前报告无异常的
执行成分”成为可能。但整机正确性还涉及退休后的物理映射、PST 生命周期、后续
flush 是否会取消仍在飞的长延迟单元等跨模块协议；不能只凭 `ct_iu_cbus.v` 一条
assign 就下结论“提前退休永远无风险”。验证时应把同一 IID/preg 的 CBUS cmplt、
ROB 退休、PST 状态、`div_rbus_pipe0_data_vld` 和 flush/cancel 放在一起观察。

---

## 4. Verdi 观察建议

层次：`...x_ct_iu_top.x_ct_iu_div`

| 信号 | 看什么 |
|------|--------|
| `div_cur_state[5:0]` | 状态机全轨迹（IDLE=00 → 0B → 0B/4B…） |
| `div_ex1_special_result` | 快速通道命中（除0/溢出/缓存） |
| `div_ex1_match_entry0/1` | 成对 div/rem 是否满足全部命中条件 |
| `x_srt_finish`、EX3 停留拍数 | 变延迟的直观体现 |
| `iu_idu_div_wb_stall` → `div_rbus_pipe0_data_vld` | 写回口预约-占用时序 |

测试激励建议：写一个含 `a/b; a%b;` 的小 case，确认第一条完成填充后第二条
是否走缓存通道，并按上面的信号定义实测总拍数；再试 `x/1` 与 `1/x` 对比
EX3 驻留拍数。不要预先假定缓存路径固定为“约 5 拍”，因为 RF 接受、共享写回
口预约和当时的 stall 都会影响端到端间隔。
