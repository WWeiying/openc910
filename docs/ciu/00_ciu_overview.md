# C910 CIU 总览与一致性互联教学

> 主要 RTL：`C910_RTL_FACTORY/gen_rtl/ciu/rtl/`
>
> 顶层：`ct_ciu_top.v`
>
> 本文先说明当前 OpenC910 RTL 能直接证明的实现，再补充理解这些实现所需的
> 体系结构背景。协议背景、设计推断与 RTL 事实会明确区分。

---

## 1. CIU 在系统中的职责

CIU（Coherence Interconnect Unit）位于各处理器核的 BIU、共享 L2 Cache 和
片外总线之间。当前双核配置下，它主要完成以下工作：

1. **接收核侧事务**：PIU0 和 PIU1 接收两个真实处理器核发来的 AR、AW、W
   请求，也把 CIU 的 R、B、AC 响应送回对应核。
2. **处理可缓存一致性访问**：两个 SNB 按物理地址位 `[6]` 分流事务；每个
   SNB 内的 SAB 保存正在处理的请求，访问 L2、依据 `cp[3:0]` 选择侦听目标，
   收集 CR/CD 响应并把结果返回请求者。
3. **处理非相干访问**：NCQ 保存并排序非相干读写，根据地址把访问送往 EBIU
   或片上 APB 外设。
4. **处理 CTC/DVM 维护操作**：CIU CTCQ 广播缓存、TLB 和 DVM 维护请求，并
   分别跟踪“已向目标派发”和“目标已经完成”。
5. **连接共享 L2**：L2CIF 对两个 L2 bank 的地址、数据、响应以及
   `set_cp/clr_cp` 元数据更新进行仲裁和转接。
6. **连接片外总线**：EBIU 把 CIU 内部读写请求转换成片外 AXI 数据通道事务，
   并用事务 ID、队列和地址冲突表把响应送回正确来源。

CIU 不是简单的“总线转接器”。一个一致性读请求可能依次经历：

```text
核侧提出请求
  -> PIU 接收并分类
  -> SNB/SAB 分配事务项
  -> 访问 L2 tag/status
  -> 根据 cp 元数据向有关核派发 AC
  -> 收集目标核的 CR，必要时接收 CD 数据
  -> 更新 L2 数据或一致性元数据
  -> 向原始请求核返回 R
```

这些步骤具有不同的握手和完成条件。“某模块发出 `req`”“下游给出 `grant`”
和“原始事务最终完成”通常不是同一个周期，也不能相互替代。

---

## 2. 系统位置与有效配置

```text
   CPU0 + BIU             CPU1 + BIU
       |                      |
   AR/AW/W/R/B            AR/AW/W/R/B
   AC/CR/CD               AC/CR/CD
       |                      |
   +---v----------------------v--------------------------------+
   |                         CIU                               |
   |  PIU0(real)  PIU1(real)  PIU2(dummy)  PIU3(dummy)        |
   |       |           |                                      |
   |       +-----------+------------+                         |
   |                                  |                       |
   |        +----------+----------+---+------+                 |
   |        | SNB0/SAB | SNB1/SAB | CTCQ    | NCQ            |
   |        +-----+----+-----+----+----+----+---+-------------+
   |              |          |         |        |              |
   |              +------ L2CIF -------+        |              |
   |                        |                    |              |
   |                   L2 bank0/1          EBIU / APBIF        |
   |                                             |              |
   +---------------------------------------------+--------------+
                                                 |
                                      片外 AXI / 片上 APB 目标
```

当前公开 RTL 的有效配置必须和参数化接口区分开：

- 一致性位图和接口按最多四个核保留；
- PIU0、PIU1 是真实 `ct_piu_top`；
- PIU2、PIU3 是 `ct_piu_top_dummy`；
- 顶层还实例化了 `ct_piu_top_dummy_device`，但该模块把请求输出置 0、
  不接收 R/B，并固定给出 `piu_xx_no_op=1`；
- 因而不能把当前 PIU4 路径描述成“已经启用的外部 DMA/设备主端口”；
- `smpen[3:2]` 在当前寄存器连接中为 0，dummy 核不会成为实际侦听目标。
- EBIU 的 snoop channel 实例是 `ct_ebiu_snoop_channel_dummy`，外部 AC
  固定无效，EBIUIF 的外部 CR/CD 返回也固定无效；当前不能验证端到端片外
  snoop 或 DVM。

这里的“最多四核”“预留设备路径”属于接口容量；“当前两个真实核、其余为
dummy”才是当前配置的实际行为。

---

## 3. PIU：核侧协议的接入点

### 3.1 五个顶层实例的准确角色

| 逻辑端口 | 实例类型 | 当前行为 |
|----------|----------|----------|
| PIU0 | `ct_piu_top` | 真实核 0 接口，参与一致性 |
| PIU1 | `ct_piu_top` | 真实核 1 接口，参与一致性 |
| PIU2 | `ct_piu_top_dummy` | 不主动发请求；可接受 AC，并返回零数据控制响应 |
| PIU3 | `ct_piu_top_dummy` | 与 PIU2 相同，但当前 `smpen[3]=0` |
| PIU4 | `ct_piu_top_dummy_device` | 纯占位桩；当前不形成有效 NCQ 或其它事务 |

“dummy coherent PIU”也不是所有信号简单钉 0。PIU2/3 不主动访问系统，但模块
仍实现了对传入 AC 的接受和随后 CR 返回，以使未使用接口具有协议上可终止的
行为。不过每个 dummy 来源只有一个 CR 保存寄存器，AC 接受又没有用“上一笔
CR 尚未返回”作背压；若违反当前集成假设，连续向同一 dummy 发送多笔未完成
AC，后到 SID 可以覆盖先到 SID。因此它是当前未使用端口的最小协议占位，不是
可承受任意 outstanding 的完整 coherent agent。由于当前 `smpen[3:2]=0`，
正常一致性选择不会把它们作为有效目标。

### 3.2 核侧普通请求的分类

PIU 对读地址请求的关键分类来自可执行 RTL：

```verilog
ar_ca  = |arcache[3:2]
      || (arcache[1] && (ardomain[1] ^ ardomain[0]));
ar_ctc = &arsnoop[3:0];
```

读请求的优先分类顺序是：

1. barrier 请求先进入 BMBIF；
2. `arsnoop==4'b1111` 的 CTC 类维护请求进入 CTCQ；
3. 非 CTC 且 `ar_ca==0` 的请求进入 NCQ；
4. 其余可缓存请求按物理地址位 `[6]` 进入 SNB0 或 SNB1。

写地址请求没有对应的 CTCQ 路径。RTL 仅用 `|awcache[3:2]` 判断写请求是否走
可缓存 SNB 路径；否则送往 NCQ。

分类信号只表示当前请求应该由哪个下游处理。事务被下游接受还需要对应
`req/grant` 条件成立，并在时钟沿后写入相应队列。

### 3.3 AC、CR、CD 三条侦听通道

| 通道 | 方向 | 内容 | 不能误解为 |
|------|------|------|------------|
| AC | CIU -> 核 | 侦听或维护请求的地址、类型、SID | 请求已在核内执行完成 |
| CR | 核 -> CIU | 控制响应，如是否有数据传输、错误等 | cache line 数据本身 |
| CD | 核 -> CIU | 被侦听核返回的数据 beat | CR 已被原请求者接收 |

PIU 的 AC 来源可能是 SNB0、SNB1 或 CTCQ。PIU 内部先仲裁并写入两项 AC FIFO；
该来源得到的 `*_ac_grant` 只表示 **AC 已进入 PIU 的 FIFO**。直到
`ciu_ibiu_acvalid && ibiu_ciu_acready` 成立，AC 才被真实核侧接口接受。

类似地，核给出 CR 后，PIU 先把它写入 CR FIFO，再结合响应队列保存的 SID、
地址和来源把响应送回 SNB/CTCQ。`crresp[0]` 在本 RTL 中表示
DT（Data Transfer），不能翻译成 dirty；若 DT=1，后续 CD 数据需要依靠保存的
SID 找到对应事务。

---

## 4. CIU 子模块全景

| 子模块 | 数量/容量 | 当前 RTL 中的职责 |
|--------|-----------|-------------------|
| `ct_piu_top` | 2 个真实实例 | 核侧请求分类、FIFO、AC/CR/CD 关联 |
| `ct_piu_top_dummy` | 2 个 | 未实例化核的协议占位 |
| `ct_piu_top_dummy_device` | 1 个 | 当前为静态桩，不产生有效设备请求 |
| `ct_ciu_snb` | 2 个 bank | 可缓存一致性请求处理 |
| `ct_ciu_snb_sab` | 每 bank 24 项 | 16 个读项、8 个写项；保存 outstanding 事务 |
| `ct_ciu_snb_sab_entry` | 每 SAB 24 项 | 单事务的 14 态主 FSM、侦听子 FSM 和数据 |
| `ct_ciu_ctcq` | reqq 8、respq 16 | CTC/DVM 维护操作的派发与完成跟踪 |
| `ct_ciu_vb` | AW 项 2 | 缓冲来自 L2/SNB 的写地址和 512-bit 数据 |
| `ct_ciu_ncq` | 多个浅队列 | 非相干读写、顺序约束、APB/EBIU 分流 |
| `ct_ciu_ncq_gm` | 当前 2 个核 | 非相干独占访问的全局监视 |
| `ct_ciu_l2cif` | 双 bank | SNB、CTCQ、DCA 与 L2 的接口仲裁 |
| `ct_ebiu_top` | 1 | 片外 AXI 读写通道及响应路由 |
| `ct_ciu_bmbif` | 1 | barrier/维护请求的目的队列与仲裁 |
| `ct_ciu_apbif` | 1 | PLIC、CLINT、HAD、L2PMP、RMR 的 APB 桥 |
| `ct_ciu_regs` | 1 | `smpen`、过滤开关、时钟门控等配置 |

容量是硬件资源上限，不代表每周期都能接收同样多的请求。例如 SAB 有 24 项，
但请求还要经过 bank 分流、源仲裁、空闲项选择和下游背压；“有空项”只是接受
请求的必要条件之一。

---

## 5. 一致性背景与本 RTL 能证明的边界

### 5.1 MOESI 是有用的背景模型，不是本文对状态寄存器的断言

体系结构教材常用 MOESI 解释多核缓存行为：

| 状态 | 一般含义 |
|------|----------|
| M, Modified | 唯一、已修改的副本 |
| O, Owned | 已修改数据的责任者，同时允许其它共享副本 |
| E, Exclusive | 唯一、未修改的副本 |
| S, Shared | 可与其它核共享的未修改副本 |
| I, Invalid | 本地无有效副本 |

这套背景有助于理解“为什么要侦听”“为什么 CR 可能指示数据传输”“为什么
写独占前要作废其它副本”。但是，在已审阅的 CIU RTL 中没有找到一个明确命名
并编码为 M/O/E/S/I 的状态寄存器，也没有找到把 CIU CTCQ 用作 Owned 数据直传
队列的逻辑。

当前 RTL 可直接证明的是：

- 核请求携带 ACE 风格的 `arsnoop/awsnoop/domain/cache` 属性；
- SAB 根据请求类型生成对 L2 的操作和对其它核的 AC；
- CR 中 DT 位决定是否还有 CD 数据；
- L2 返回命中、响应和 `cp[3:0]`，SAB又生成 `set_cp/clr_cp` 更新请求；
- 一致性数据可经核侧 CD、SAB 数据寄存器、L2CIF 和返回路径流动。

因此本文不把“实现完整 MOESI，且显式使用 Owned 态”写成 RTL 事实。若需要
确认精确协议状态转换，还必须联合核内 L1 状态阵列、L2 状态位、snoop 编码和
系统级一致性验证环境分析。

### 5.2 `cp[3:0]` 是 presence/filter 元数据

SAB 从 L2 响应中锁存 `l2c_cp[3:0]`：

```verilog
if (l2c_resp_wen) begin
  l2_resp[4:0] <= l2c_resp[4:0];
  cp[3:0]      <= l2c_cp[3:0];
end
```

它随后按以下逻辑得到侦听目标：

```verilog
cp_after_sf   = (sf_dis && l2_hit) ? 4'b1111 : cp;
cp_mask       = inst ? 4'b0000 : piu_sel;
cp_after_mask = cp_after_sf & ~cp_mask & smpen;
```

逐项解释如下：

1. 正常情况下使用 L2 返回的 `cp` 作为候选核位图；
2. L2 命中且 `sf_dis=1` 时，候选位图退化成 `1111`；
3. 对普通数据请求，`piu_sel` 用于去掉请求核自身；
4. 对 `inst` 请求，RTL 令 `cp_mask=0`，不能套用“始终去掉请求者”的概括；
5. 最后再用 `smpen` 屏蔽不参与 SMP 的核。

`cp` 可作为侦听过滤元数据理解，但仅凭这段 CIU 逻辑不能断言它在所有时刻都是
完整、精确、无保守位的全系统目录。文档采用“presence/filter 元数据”这一较为
严格的称呼。

### 5.3 `set_cp/clr_cp` 是发给 L2 的更新请求

SAB 在特定状态下产生更新掩码：

- `set_cp`：在 `L2CW` 处理读分配且不是 L2 预取时，掩码为请求者
  `piu_sel`；
- `clr_cp`：在 `L2C` 处理 RU/CU/WS/WB/CI/MI/Evict 等类型时产生；
- WB/Evict 使用 `piu_sel`，其它清除类使用 `~piu_sel`。

这些信号表示 **SAB 请求 L2 更新 presence 元数据**，并不是 SAB 内部直接把
L2 tag 写完。必须等 L2 接口接受相应操作并按其内部流水完成后，持久状态才真正
改变。

---

## 6. Snoop Filter 如何减少无效侦听

如果每个一致性事务都广播给所有核，即使某核根本没有该 line，也必须占用 AC、
CR 队列和核侧查询资源。`cp_after_mask` 允许 SAB 只启动有关目标核的侦听子
FSM：

```verilog
cp_vld = |cp_after_mask
      && !(rns || wns || evict || l2_prf);
snp_req_en = {4{snp_req_vld}} & cp_after_mask;
```

这里还有两层容易忽略的限制：

- 位图非零并不必然发侦听；RNS、WNS、Evict、L2 prefetch 被 `cp_vld` 排除；
- `snp_req_en[x]=1` 只启动对应侦听子 FSM；AC 还要经过 SNB 仲裁、PIU AC
  仲裁和 PIU FIFO，最后才可能被核侧接受。

若 `cp_after_mask=4'b0010`，RTL 只要求核 1 执行真实侦听。其它目标的子流程按
“无需请求即可完成”处理。这减少了无效工作，但实际延迟收益仍取决于 AC 争用、
目标核响应时间、L2 操作以及返回路径，不能从一个位图直接推导固定周期收益。

---

## 7. 一次可缓存读的阶段化观察

下面用“核 0 读某行，而 `cp` 指示核 1 可能持有副本”说明主要阶段。示例用于
教学，不预先断言核 1 的具体 M/O/E/S 状态。

### 阶段 1：PIU 接收并分类

核 0 保持 AR payload 和 `arvalid`。PIU0 的两项 AR FIFO 未满时给
`arready`；只有 `arvalid && arready` 为 1 的时钟沿，AR 内容才成为 PIU 内部
已接收事务。PIU 随后把可缓存请求按 PA[6] 送到 SNB0 或 SNB1。

### 阶段 2：SNB/SAB 创建事务项

SNB 选择请求，SAB 找到空闲读项或写项。创建使能在时钟沿把地址、请求类型、
来源和数据写入 entry，并把主 FSM 从 IDLE 推向后续状态。仅看到组合请求有效，
还不能认为 SAB 已分配成功。

### 阶段 3：访问 L2 并取得元数据

SAB 通过 L2CIF 发地址操作。L2 请求被接受、流水执行并返回后，entry 才锁存
`l2_hit`、`l2_resp` 和 `cp`。如果存在地址依赖或下游资源冲突，entry 可能先在
DEPD 等状态等待。

### 阶段 4：派发 AC

假设过滤后只有核 1 需要侦听，SAB 启动对应子 FSM并提出 AC 请求。AC 经过：

```text
SAB entry -> SNB AC 仲裁 -> PIU1 AC 仲裁
          -> PIU1 AC FIFO -> 核 1 的 AC ready/valid 接口
```

每一级的 grant 只确认该级交接完成。最终核侧接受条件是
`ciu_ibiu_acvalid && ibiu_ciu_acready`。

### 阶段 5：收集 CR，必要时接收 CD

核 1 返回 CR。CR 的 DT 位若为 1，表示该侦听响应还伴随 CD 数据。PIU 用此前
保存的 SID 把 CR/CD 与 SAB entry 关联。CR 被 PIU 接收不代表全部 CD beat
已经到齐；CD 的 valid/ready/last 必须单独观察。

### 阶段 6：完成 L2 更新和原请求响应

根据 L2 与侦听结果，SAB 可能执行 L2 数据写入、状态或 cp 更新、内存访问等
后续步骤。最后 PIU0 的 R 通道被拉起，并在核 0 接受 R 后推进返回队列。SAB
entry 的释放条件由其 FSM 和相关完成信号决定，不应简单等同于第一笔 CR 到达。

---

## 8. CIU CTCQ 与 LSU snoop CTCQ 必须区分

当前代码中有两个容易混淆的 “CTCQ”：

| RTL | 内容 | 作用 |
|-----|------|------|
| `ct_ciu_ctcq` | 维护地址、目标位图、请求/响应 ID、完成位 | CTC/DVM 维护操作的广播和完成跟踪 |
| `ct_lsu_snoop_ctcq` | coherence data response | 核内 LSU 缓冲侦听返回数据 |

CIU CTCQ 解码 TLBI、I-cache invalidate、L2 cache maintenance 和 DVM 操作。
它给原始 PIU 返回的控制响应数据字段固定为 0，因此不能把它解释成“64B 数据
从拥有者核直接传给请求者”的队列。

CIU CTCQ 内：

- 8 项 reqq 跟踪内容、各目标是否完成派发/跳过，以及原始响应是否被接收；
- 16 项 respq 跟踪每个被点名目标是否真正完成；
- `aim[5:0]` 对应 PIU0、PIU1、PIU2、PIU3、EBIU、L2C；
- reqq 的 `resp_done` 来自原始响应 grant，不等于 respq 已全部完成。

详细时序见 [03_ciu_ctcq_vb.md](03_ciu_ctcq_vb.md)。

---

## 9. Evict、cp 更新与过滤精度

缓存替换一条未修改的 line 时，数据本身不需要写回内存，但系统仍可能需要更新
侦听过滤元数据。SAB 对 Evict 生成 `clr_cp=piu_sel`，其体系结构意图是清除
请求核的 presence 位，减少今后对已经没有该 line 的核进行无效侦听。

这里需要区分两个动作：

1. **数据写回**：只在协议属性和数据状态要求时发生；
2. **presence 元数据更新**：干净 Evict 也可能需要。

进入 VB 也不能自动证明“这一定是脏行写回”。VB 保存来自 L2C/SNB 的 AW/W，
而 EBIU 对 `awsnoop==3'b100` 的 Evict 可令 `aw_needissue=0`，即不向片外发出
AW/W。判断数据是否真正写出必须观察 EBIU 的 `aw_needissue`、AW 握手、W
握手和最终 B，而不能只观察 VB entry 有效。

---

## 10. 非相干、L2 与片外路径

### 10.1 NCQ

NCQ 的有效输入来自 PIU0～PIU3；当前 PIU4 dummy-device 不发请求。NCQ 包含：

- 深度 2 的 RAQ、RDQ、WAQ、WDQ、WBQ；
- 深度 16 的 WOQ；
- 深度 16 的 DSQ；
- 当前仅为核 0、核 1 实例化的全局监视器。

WOQ 记录 AW 被接受时的来源，以约束后续 W 的来源顺序。它不应笼统翻译成
“所有强序访问语义的完整实现”。NCQ 按地址选择：

- PA `[39:27]` 等于 `sysio_ciu_apb_base[39:27]`：进入 APBIF；
- 否则：进入 EBIU。

### 10.2 L2CIF

L2CIF 面向两个 L2 bank。每个 bank 的地址请求优先关系为：

```text
CTCQ > DCA > SNB
```

CTCQ 维护操作会扇出到两个 bank，并分别等待 ready 和 completion。DCA 是
PIU 侧调试/CSR 直接缓存访问路径。L2CIF 还传递 `set_cp/clr_cp`、来源、SID、
类型和 512-bit 数据。Victim 数据方向是 L2/SNB 到 VB，不应把 VB 说成一个
主动访问 L2 的请求者。

### 10.3 EBIU

当前 EBIU 对外暴露 AXI 的 AR/R/AW/W/B 数据通道，同时带有 ACE 风格属性和
RACK/BACK/低功耗握手；它没有对外 AC/CD/CR 端口。因此更准确的说法是
“带一致性属性的外部 AXI 主接口子集”，而不是未经限定地称为完整 ACE 相干
节点。

EBIU 用 RID/BID 和内部表项路由响应。读 ID 的高位区分 NCQ、SNB 和 CTCQ；
写侧还有：

- 16 项 NCWT：只跟踪 `ncq_aw_wo` 指示的 write-ordered NCQ 写；
- 32 项 CAWT：跟踪已发往外部、等待 B 的 VB/相干地址写；
- 独立的强序 outstanding 控制；
- 16 项 W 来源顺序环，保持已接受 AW 与后续 W 的来源次序。

NCWT/CAWT 的地址冲突比较只使用 PA `[13:6]`，属于保守的低索引冲突检查，
不是完整物理地址相等判断。

### 10.4 APBIF

APBIF 的目标包括 PLIC、CLINT、HAD、四路 L2PMP 和 RMR。读事务经历地址
接收、APB setup、APB access 和返回；写事务先接收 AW，再等待 W，并按
地址 `[3:2]` 选择 128-bit WDATA 中的一个 32-bit lane。

`ct_piu_other_io` 中当前 L2PMP 返回接口固定为 `pready=1`、`perr=0`、
`rdata=0`。因此文档可以说明顶层保留该 APB 目标，但不能断言当前配置已经把
真实 L2PMP 寄存器功能完整接入。

---

## 11. 排序、并行和时钟门控的准确理解

### 11.1 双 SNB bank

PA[6] 把事务分到 SNB0/SNB1，使两个 bank 有机会并行处理不同低位索引的
cache line。它增加的是可用并行度，不等于吞吐固定翻倍；热点地址分布、L2
冲突、EBIU 带宽、侦听目标和返回争用仍会限制实际吞吐。

### 11.2 SAB 年龄向量

SAB entry 创建时记录当时更老的有效项，选择逻辑寻找“当前有请求且不存在更老
请求者”的 entry。这可实现 bank 内、特定资源上的 oldest-requester 选择。
“最老优先”不等于无条件的全系统公平或绝不饥饿；完整结论还依赖下游最终持续
给出 grant，以及不同请求类别之间没有永久屏蔽。

### 11.3 保守地址依赖

SAB 和 VB/EBIU 的若干冲突检查只比较物理地址低位索引，而不是完整 tag：

- SAB 在单 bank 内比较 `[13:7]`，结合外部 bank 位 `[6]` 等价于低 line
  索引 `[13:6]`；
- VB、NCWT、CAWT 也使用 `[13:6]`。

因此，不同高位地址但低索引相同的事务可能被保守串行化。文档不能把这些信号
直接称为“同一 cache line 精确冲突”。

### 11.4 门控时钟实例不等于当前仿真中时钟真的被门控

RTL 广泛使用 `gated_clk_cell`。但通用实现中，未定义
`C910_USE_TSMC28_ICG` 时 `clk_out=clk_in`；DC 文件列表会定义该宏并替换成
工艺 ICG。由此应分别表述：

- RTL 的门控条件表达了设计意图和寄存器更新使能；
- 当前仿真是否看到真实门控波形，取决于编译宏和所用 cell；
- 功耗收益必须以综合后网表或功耗分析为依据，不能由实例名直接得出。

---

## 12. 阅读 CIU 波形时的统一方法

对任何事务都按以下五层检查：

1. **请求意图**：源端 `req/valid` 和 payload 是否稳定；
2. **本级接受**：对应 `grant` 或 `valid&&ready` 是否成立；
3. **状态落地**：时钟沿后 FIFO valid、entry valid、指针、FSM 是否更新；
4. **目标执行**：L2、目标核、EBIU 或 APB 是否真正接受并完成；
5. **原始完成**：R/B/CR 或维护 completion 是否回到原发起端并被接受。

例如看到 `sab_piu1_ac_req=1` 只说明 SAB 想向 PIU1 发 AC；看到
`piu1_snb_ac_grant=1` 说明 AC 被 PIU1 FIFO 接收；看到
`ciu_ibiu_acvalid && ibiu_ciu_acready` 才说明真实核接收；后续 CR/CD 完成
又是独立阶段。

这种分层方法可以避免最常见的波形误判：把请求当接受、把队列接受当目标完成、
把目标完成当原始响应已经退休。

---

## 13. 分册阅读顺序

| 文档 | 核心内容 |
|------|----------|
| [01_ciu_piu.md](01_ciu_piu.md) | PIU 分类、FIFO、AC/CR/CD 关联和 dummy 行为 |
| [02_ciu_snb_sab.md](02_ciu_snb_sab.md) | SNB/SAB、14 态 FSM、cp 过滤、数据和响应 |
| [03_ciu_ctcq_vb.md](03_ciu_ctcq_vb.md) | CTC/DVM 维护队列、完成位和 VB 写出 |
| [04_ciu_ncq_ebiu_regs.md](04_ciu_ncq_ebiu_regs.md) | NCQ、GM、EBIU、L2CIF、BMBIF、APBIF、寄存器 |

阅读时先以本文建立边界，再进入各分册核对具体握手。CIU 的关键不只是“有哪些
模块”，而是弄清一个事务在哪一级被接受、由谁保存、等待哪些目标、何时才对
原始请求者可见为完成。
