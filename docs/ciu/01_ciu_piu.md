# C910 CIU PIU 模块详细教学文档

> 主要 RTL：`ct_piu_top.v`
>
> 相关 RTL：`ct_piu_top_dummy.v`、`ct_piu_top_dummy_device.v`、
> `ct_piu_other_io.v`、`ct_piu_other_io_sync.v`、
> `ct_piu_other_io_dummy.v`

---

## 1. PIU 的准确定位

`ct_piu_top` 是一个真实处理器核的 BIU 与 CIU 内部模块之间的接口适配器。它
不负责决定一条 cache line 的最终一致性状态；它负责：

1. 接收核侧 AR、AW、W，并把请求分类到 BMBIF、CTCQ、NCQ 或两个 SNB；
2. 保存“地址请求已经从核侧接受、但下游尚未接受”的状态；
3. 仲裁 SNB0、SNB1、CTCQ 发给该核的 AC；
4. 把已被核接受的 AC 与将来的 CR/CD 响应按顺序重新关联；
5. 汇聚 SNB、NCQ、CTCQ、barrier 的 R/B，并送回核；
6. 产生 `piu_xx_no_op`，表示 PIU 内若干主要队列和 barrier FSM 处于空闲。

一条事务在 PIU 中至少可能经过三次不同意义的交接：

```text
核 -> PIU 输入缓冲
PIU 输入缓冲 -> CIU 下游模块
CIU 返回缓冲 -> 核
```

因此“PIU 接收到请求”“SNB 接收到请求”和“核收到结果”是三个独立事件。

---

## 2. 当前实例与接口边界

| 端口 | 实例 | 当前行为 |
|------|------|----------|
| PIU0 | `ct_piu_top` | 真实核 0 |
| PIU1 | `ct_piu_top` | 真实核 1 |
| PIU2 | `ct_piu_top_dummy` | 不主动请求；可终止传入 AC |
| PIU3 | `ct_piu_top_dummy` | 与 PIU2 相同 |
| PIU4 | `ct_piu_top_dummy_device` | 全部请求与响应路径均为静态桩 |

PIU0/1 核侧接口带有 AXI/ACE 风格的 AR、R、AW、W、B 和 AC、CR、CD 信号。
当前 EBIU 外部端口并没有 AC/CR/CD，因此不能由 PIU 接口形式推导整个外部接口
是完整 ACE 节点。

---

## 3. 先建立统一的握手语义

### 3.1 `valid/ready`

对核侧标准通道，接受事件是：

```text
accept = valid && ready
```

在该周期的有效时钟沿，接收方才可把 payload 记入寄存器或 FIFO。仅有 valid
表示源端提出并保持请求；仅有 ready 表示接收方有能力接收。

### 3.2 CIU 内部 `req/grant`

CIU 内部许多接口使用 `req/grant`。通常：

```text
accept = req && grant
```

部分 RTL 的 `grant` 已经隐含当前请求被选择，例如 PIU AC 的来源 grant 由
`ac_sel` 和 FIFO 空闲共同生成。阅读时仍应同时核对请求是否有效、选择信号和
目标寄存器的 create 条件。

### 3.3 状态更新

组合逻辑算出 create/pop 后，FIFO valid、读写指针或 FSM 只在时钟沿更新。
所以波形上常见：

```text
周期 N：valid && ready = 1
周期 N 的时钟沿：payload 被采样
周期 N+1：内部 FIFO valid 和输出 payload 可见
```

`ct_fifo` 没有组合 fall-through；新请求不会在同一组合周期直接穿过空 FIFO。

---

## 4. AR：读地址接收、分类与下游交接

### 4.1 分类表达式

PIU 对读请求使用：

```verilog
ar_ca  = |arcache[3:2]
      || (arcache[1] && (ardomain[1] ^ ardomain[0]));
ar_ctc = &arsnoop[3:0];
```

随后生成四个路由位：

```verilog
CTCQ = !arbar[0] &&  ar_ctc;
NCQ  = !arbar[0] && !ar_ctc && !ar_ca;
SNB1 = !arbar[0] && !ar_ctc &&  ar_ca &&  araddr[6];
SNB0 = !arbar[0] && !ar_ctc &&  ar_ca && !araddr[6];
```

若 `arbar[0]=1`，上述四个位都为 0，请求由单独的 barrier 路径识别。这里的
`ar_ca` 是本 RTL 的路由判据，不能简化成“`arcache!=0` 就一定可缓存”。

### 4.2 两项 AR FIFO

核侧 ready 为：

```verilog
ciu_ibiu_arready = !ar_dfifo_full;
```

入队条件为 `ibiu_ciu_arvalid && !ar_dfifo_full`，等价于核侧 AR 握手。FIFO
保存完整地址、属性、ID、barrier 位和 PIU 已生成的路由位，深度为 2。

AR FIFO 头部随后向唯一目标保持请求：

| FIFO 中的标签 | 下游 |
|---------------|------|
| barrier | BMB/barrier 合并逻辑 |
| CTCQ | CTCQ |
| NCQ | NCQ |
| SNB0 | SNB0 |
| SNB1 | SNB1 |

只有相应下游 grant 出现时，`ar_grant` 才使 FIFO pop。也就是说：

- 核侧 AR 握手：请求的所有权从核转给 PIU；
- 下游 grant：请求的所有权从 PIU AR FIFO 转给目标模块；
- 两者可以不是同一周期。

### 4.3 PA[6] 分 bank 的含义

对于可缓存非 CTC 读，PA[6]=0 进入 SNB0，PA[6]=1 进入 SNB1。因为 cache
line 为 64B，PA[5:0] 是 line 内字节偏移，PA[6] 是相邻 line 的最低索引位。
两个 SNB 可并行处理不同 bank 的事务，但这只是提供并行机会，不保证吞吐量
严格翻倍。

---

## 5. AW 与 W：写地址分类和数据关联

### 5.1 写地址分类与读地址并不完全相同

写侧只用：

```verilog
aw_ca = |awcache[3:2];
```

路由为 barrier、NCQ、SNB0 或 SNB1，没有 AW 到 CTCQ 的路径。文档不能把
AR 的 `domain/cache/snoop` 判定公式机械套到 AW。

### 5.2 AW 是两个分类槽位，不是普通的二项 FIFO

PIU 把 AW 分成：

- WS 类：特定 WU/WLU 且 domain 为 `01`，或 barrier；
- WNS 类：其余写地址。

每类各有一个 valid 和一个 payload 寄存器。ready 按当前 AW 类型返回：

```verilog
awready = (aw_create_ws  && !ws_dfifo_vld)
       || (!aw_create_ws && !wns_dfifo_vld);
```

虽然源码中的总 create 信号写成 `awvalid`，真正的槽位 create 还与对应
`~*_dfifo_vld` 相与。因此，合法接受仍对应 `awvalid && awready`，并在时钟沿
写入所选槽位。

输出选择优先 WNS：

```verilog
aw_req_bus = wns_dfifo_vld ? wns_dfifo_data : ws_dfifo_data;
```

这只是当前组合选择优先关系，不应扩展成完整体系结构写顺序的唯一规则；后续
还有 WD SID FIFO、NCQ/SNB 排序和 EBIU 写跟踪。

### 5.3 AW grant 后建立 W 数据归属

AW 被 BMBIF、NCQ 或某个 SNB 接受后，PIU 把目标 XID、SID、地址低位等写入
WD SID FIFO。后续核侧 W beat 不再携带完整目标信息，PIU 用该 FIFO 头部把
写数据重新关联到接受该 AW 的下游。

Evict 是特殊情况：`aw_pop_evict` 时不创建 WD SID 项，因为这种事务不要求
核侧跟随普通 W 数据。是否最终向片外发 AW/W，还要由 EBIU 的 `aw_needissue`
判断。

---

## 6. AC：从 CIU 维护/侦听源到真实核

### 6.1 三个来源与有状态仲裁

PIU 接收三个 AC 来源：

```text
SNB0、SNB1、CTCQ
```

`ct_prio #(.NUM(3))` 是会更新内部优先关系的仲裁器，不应描述成固定优先级。
SNB 请求还可能被 `ctcq_mask_snb` 屏蔽。

`ct_prio` 采用优先关系矩阵。复位后低编号来源优先；某来源被选择并写入 AC
FIFO 时，`clr` 使该来源在后续竞争中降到其它来源之后。因此它具有轮转式的
有状态公平性，而不是每周期简单从 bit0 开始编码。不过这种公平性只覆盖
**同时具备仲裁资格且仲裁器持续获得入 FIFO 机会** 的来源：CTCQ 对 SNB 的
显式屏蔽、AC FIFO 满和下游长期背压仍会改变实际等待时间。

### 6.2 来源 grant 的准确含义

当 AC FIFO 未满时：

```verilog
piu_snb0_ac_grant = ac_idle && ac_sel[0];
piu_snb1_ac_grant = ac_idle && ac_sel[1];
piu_ctcq_ac_grant = ac_idle && ac_sel[2];
```

这些 grant 表示 **被选 AC 已被 PIU 的两项 AC FIFO 接收**。它们不表示：

- 真实核已经看到 AC；
- 核已经查询 L1；
- CR 已经返回；
- 整个原始一致性事务已经完成。

### 6.3 从 AC FIFO 到核侧

FIFO 头部仅在 RSPQ 未满时对核拉高 `ciu_ibiu_acvalid`。最终核侧接受事件是：

```verilog
ciu_ibiu_acvalid && ibiu_ciu_acready
```

同一个事件同时：

1. pop AC FIFO；
2. 在 12 项 RSPQ 中创建记录；
3. 保存该 AC 的 `xid[4:0]`、`sid[4:0]` 和地址 `[5:4]`。

因此 RSPQ 只记录 **已被核侧接受** 的 AC，不记录仍在 PIU AC FIFO 中等待的
请求。这一细节保证后续按序到达的 CR 能与真实已发 AC 一一对应。

### 6.4 `ctcq_mask_snb` 的严格解释

CTCQ AC 被 PIU FIFO 接受时，PIU 把该 AC 地址字段最低位锁存到
`ctcq_mask_snb`。源码注释说明该位表示还有第二次 transfer。该位为 1 时，
SNB0/1 AC 暂不参与仲裁；下一次 CTCQ AC grant 再根据其 addr[0] 更新该位。

可以据此断言的是：两段 CTC 维护 AC 之间不会插入普通 SNB AC。不能据此断言
所有 cache-to-cache 数据、所有 DVM 或所有系统事务都获得了全局原子性。

---

## 7. CR：控制响应的缓存、关联与回送

### 7.1 核侧接受

CR FIFO 深度为 2：

```verilog
ciu_ibiu_crready = !cr_dfifo_full;
cr_create = ibiu_ciu_crvalid && ciu_ibiu_crready;
```

核侧 CR 握手只表示五位 `crresp` 进入 PIU。它还没有被原始 SNB/CTCQ 接收。

### 7.2 与 RSPQ 头部配对

CR 没有重新携带原 AC 的完整来源信息。PIU 假定核按已接受 AC 的协议顺序返回
CR，因此把 CR FIFO 头与 RSPQ 头组合：

```text
RSPQ.xid  -> 选择 SNB0、SNB1 或 CTCQ
RSPQ.sid  -> 找到目标模块内部事务项
CRRESP    -> 返回控制结果
```

当对应下游给出 `*_cr_grant` 时，同一个事件 pop CR FIFO 和 RSPQ。若下游持续
背压，CR 与 RSPQ 均保持，核侧最终也可能因两项 CR FIFO 满而看到
`crready=0`。

### 7.3 DT 不是 dirty

RTL 明确定义 `CR_RRESP_DT=0`。DT 是 Data Transfer：若该位为 1，表示该
侦听响应之后存在 CD 数据。因此，下游接受 CR 时，PIU 还会把该事务的 XID、
SID 和地址 `[5:4]` 写入 8 项 CD SID FIFO。

“DT=1”不能单独证明 line 是 Modified 或 dirty；CR 的其它位、请求类型、核内
状态和数据路径必须联合解释。

---

## 8. CD 与普通 W：共享 package buffer

### 8.1 CD SID FIFO

CD SID FIFO 只为 **已经被 SNB/CTCQ 接受且 DT=1 的 CR** 创建。其内容为：

- 两位 XID：区分 SNB0/SNB1；
- 地址 `[5:4]`：决定 128-bit beat 在 512-bit line 中的位置；
- 五位 SID：定位目标事务项。

FIFO 实例深度为 8。RTL 另外维护四位计数器，并用最高位作为
`cd_sid_fifo_full`：计数从 0 增到 8 后 `cnt[3]=1`。此时 `cr_req_vld` 被压低，
所以 SNB/CTCQ 不能 grant 一个还需要创建 CD SID 的 CR；已经进入两项 CR FIFO
的响应可以暂存等待。CD SID pop 后计数降回 7，CR 回送才继续。这里应按这条
create/pop/计数链理解容量，不能只看 FIFO 实例输出被命名为
`cd_sid_fifo_full_fake`。

### 8.2 package buffer 的实际功能

PKB 在 CD 与普通核侧 W 之间仲裁，并把最多四个 128-bit beat 组装成
512-bit 数据：

```text
输入：128-bit data + byte strobe/error + SID/XID/address-low
内部：按地址[5:4]或递增/递减顺序写 data0..data3
完成：收到 last 后 pkb_rdy=1
输出：535-bit WCD 总线或 NCQ 的 128-bit W 数据
```

空闲时若 CD 和 WD 同时请求，CD 优先；同一包尚未收完时，PKB 保持已选择的
来源，不能在四个 beat 中途切换。这是局部 package-buffer 仲裁，不应写成所有
系统写数据永远“CD 全局优先”。

### 8.3 输出目标

完整包依据保存的 XID 送往 BMBIF、NCQ、SNB1 或 SNB0。NCQ 只取由地址
`[5:4]` 指定的一个 128-bit lane；SNB/BMB 路径可接收打包后的 512-bit
内容。

数据进入 PKB 只表示 PIU 已经收齐并保存它。只有目标 `*_wcd_grant` 出现，
PKB 才 pop；目标模块后续写 L2、进入 VB 或完成外部写仍属于更下游阶段。

---

## 9. Barrier 合并与完成

PIU 的 barrier FSM 状态为：

```text
BAR_IDLE -> BAR_REQ -> BAR_WAIT/W_BAR_CMPLT -> BAR_RESP -> BAR_IDLE
```

读 barrier 从 AR FIFO 头部识别；写 barrier 还需要等待相应写数据被接收。
PIU 经 BMBIF 把 barrier 要求送往 CTCQ、NCQ、SNB0、SNB1，并等待相关完成
条件，最后构造对核的 R 或 B 响应。

“barrier 已进入 PIU”“BMBIF 已接受 barrier”“各目标报告完成”和“核已接收
barrier 响应”是不同阶段。体系结构上的可见性保证来自整条协议和各目标对
barrier 的实现，不应只由 `bar_cur_state` 某一个状态名推导。

---

## 10. 返回 R/B 与 `no_op`

PIU 对来自 SNB0、SNB1、NCQ、barrier、CTCQ 的 R 进行仲裁并保存到返回缓冲，
再驱动核侧 R。B 路径同样先仲裁、缓冲，再交给核。来源模块得到的 R/B grant
表示 PIU 已接收其返回，不表示核已在同周期接收。

真实 PIU 的 `piu_xx_no_op` 由 AR、AW、WD SID、barrier、R/B、RACK/BACK
等主要内部状态共同计算。它适合表示“PIU 所跟踪的主要事务为空闲”，但不是
整个核、整个 CIU 或所有异步外设绝对静止的证明。

---

## 11. dummy 变体的真实行为

### 11.1 `ct_piu_top_dummy`

PIU2/3：

- AR/AW/WCD/BMB 请求固定无效；
- 不接收 SNB/NCQ/CTCQ 的普通 R/B；
- 对传入 SNB0、SNB1、CTCQ AC，组合产生 AC grant；
- 在时钟沿保存 AC SID，随后保持零 `crresp` 的 CR 请求，直到来源 grant；
- `piu_xx_no_op=1`。

所以“dummy 所有输出全 0”并不准确；其主动请求和数据响应为零，但保留了最小
AC->CR 终止路径。

这个终止路径有严格使用边界。每个 AC 来源只有一个 CR 请求寄存器，但 AC
grant 没有用“本来源 CR 尚未处理”作为条件；同一来源在前一个 CR 被 grant
之前再次送入 AC，会覆盖已保存的 SID。当前配置通过 `smpen[3:2]=0` 不把
PIU2/3 作为正常侦听目标，因此正常路径依赖的是“不会向 dummy 连续投递 AC”
这一系统不变量，而不是 dummy 内部具备排队能力。

此外，SNB0 CR 被 grant 后，源码把 `piu_snb0_cr_sid` 赋成
`piu_snb1_cr_sid`，而不是保持自己的 SID。该周期同时清除了
`piu_snb0_cr_req`，所以 valid 为 0 时这通常只是无效载荷上的拷贝粘贴痕迹；
验证环境仍应遵守“只在 `cr_req=1` 时解释 CR bus”，不能把无效周期 SID 当成
有效事务信息。`piu_xx_no_op` 又被固定为 1，因此它也不反映 dummy 内部尚待
grant 的 CR。

### 11.2 `ct_piu_top_dummy_device`

该模块当前：

- 所有 SNB AR/AW/WCD 请求固定为 0；
- 不接受 SNB R/B；
- `piu_xx_no_op=1`；
- 没有形成有效外部 DMA 到 NCQ 的实现。

模块名中的 `device` 只能说明预留角色或生成配置来源，不能用来宣称当前硬件已
提供可工作的非相干设备主入口。

---

## 12. `ct_piu_other_io`

真实核旁还有一个 `ct_piu_other_io`，内部实例化 `ct_piu_other_io_sync`。主要
信号包括：

- 机器态/监督态中断转发；
- debug request、低功耗模式和性能计数相关控制；
- 核侧 CSR select/wdata 与 CIU regs 回读；
- L2PMP APB 目标接口。

### 12.1 “sync” 名称不能替代 CDC 证据

在当前可见 RTL 中，中断和若干 debug 信号主要是直接赋值，没有看到统一的
两级触发器同步器。CSR 请求则在 `forever_cpuclk` 下锁存并保持。因此，文档
不能仅凭模块名 `*_sync` 宣称所有接口都完成了标准双触发器跨时钟域同步。

### 12.2 当前 L2PMP 路径是 dummy 返回

`ct_piu_other_io_sync.v` 当前固定：

```verilog
pready_l2pmp_x = 1'b1;
perr_l2pmp_x   = 1'b0;
rdata_l2pmp_x  = 32'b0;
```

所以 APBIF 虽然解码并连接 L2PMP 目标，当前核侧这一路只会立即返回零数据且
无错误。接口存在与功能实现完整必须分别描述。

---

## 13. 波形观察建议

### 13.1 观察一次 AR

按顺序加入：

```text
ibiu_ciu_arvalid, ciu_ibiu_arready, ibiu_ciu_araddr
ar_dfifo_create_en, ar_dfifo_full, ar_dfifo_pop_bus_vld
ar_req_snb0/snb1/ncq/ctc/bar
piu_*_ar_req, *_piu_ar_grant
```

先确认核侧接受，再确认 FIFO 头分类，最后确认下游接受。

### 13.2 观察一次完整 AC/CR/CD

```text
snb0/snb1/ctcq_piu_acvalid, ac_sel, piu_*_ac_grant
ac_dfifo_full, ac_dfifo_pop_bus_vld
ciu_ibiu_acvalid, ibiu_ciu_acready, rspq_create_en
ibiu_ciu_crvalid, ciu_ibiu_crready, crresp
piu_*_cr_req, *_piu_cr_grant
cd_sid_fifo_create_en, ibiu_ciu_cdvalid
pkb_vld, pkb_rdy, piu_*_wcd_req, *_piu_wcd_grant
```

这组信号能回答：AC 是仅进入 PIU，还是已被核接受；CR 是否指示 CD；CD 是否
收齐；最终数据是否已转交下游。

### 13.3 时钟门控解释

PKB 的四段数据寄存器各有 gated clock，使能只在对应 128-bit 段写入时拉起。
这是 RTL 的更新和低功耗意图。仿真中是否看到实际门控后的时钟，取决于
`gated_clk_cell` 编译宏；面积与功耗收益则需要综合实现结果支持。
