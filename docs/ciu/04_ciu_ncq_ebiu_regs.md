# C910 CIU NCQ、EBIU、L2CIF 与控制接口教学文档

> 主要 RTL：`ct_ciu_ncq.v`、`ct_ciu_ncq_gm.v`、
> `ct_ebiu_top.v`、`ct_ebiu_read_channel.v`、
> `ct_ebiu_write_channel.v`、`ct_ebiu_ncwt_entry.v`、
> `ct_ebiu_cawt_entry.v`、`ct_ciu_l2cif.v`、
> `ct_ciu_ebiuif.v`、`ct_ciu_bmbif.v`、
> `ct_ciu_bmbif_kid.v`、`ct_ciu_apbif.v`、`ct_ciu_regs.v`

---

## 1. 数据路径总览

```text
PIU0..3 非相干 AR/AW/W
          |
          v
         NCQ --------------------+
          |                      |
          v                      v
        EBIU                  APBIF
          |                      |
          v                      +-> PLIC/CLINT/HAD/L2PMP/RMR
       片外 AXI

SNB 外部读 / CTCQ DVM读 -------> EBIU read channel
L2C/SNB victim AW/W -> VB ------> EBIU write channel

SNB0/SNB1/CTCQ/DCA ------------> L2CIF -> L2 bank0/1
```

当前 NCQ 的请求端是 PIU0～PIU3。PIU4 对应
`ct_piu_top_dummy_device`，其请求信号固定无效，不能把它计入当前有效 DMA 或
设备主流量。

---

## 2. NCQ：非相干请求的排队与分流

### 2.1 “非相干”在本模块中的含义

PIU 已根据 cache/domain 属性把请求分类到 NCQ。NCQ 不执行 SNB 的 cp 查询和
per-core AC snoop，而是把请求送往 EBIU 或 APBIF。它仍然需要：

- 保存地址、数据和返回；
- 维持 AW 与 W 的对应关系；
- 对 write-ordered 和 strongly-ordered 类别应用不同约束；
- 处理 exclusive/locked 访问；
- 把返回按 ID 送回正确 PIU。

因此“绕开一致性”不等于“无排序、无状态、单周期直通”。

### 2.2 队列容量和真实用途

| 结构 | 深度 | 主要保存内容 |
|------|------|--------------|
| RAQ | 2 | 已被 NCQ 接受、待 APBIF/EBIU 接受的读地址 |
| RDQ | 2 | APBIF/EBIU 返回、待 PIU 接收的读数据 |
| WAQ | 2 | 已被 NCQ 接受、待 APBIF/EBIU 接受的写地址 |
| WOQ | 16 | AW 接受顺序中的 PIU/source ID |
| WDQ | 2 | 核侧写数据 |
| DSQ | 16 | 已接受 AW 对应的 W 目的地是 APB 还是 EBIU |
| WBQ | 2 | APBIF/EBIU 返回、待 PIU 接收的 B 响应 |

WOQ 源码中存在过时的“32-entry”注释，但可执行参数为
`WOQ_DEPTH=16`，文档以实例参数为准。

### 2.3 为什么 WOQ、DSQ 比地址 FIFO 深

AW 与 W 是解耦通道。NCQ 接受 AW 后，W 可能稍后才到。NCQ 使用：

- WOQ 保存 AW 接受的 PIU/ID 顺序，使后续 W 只从当前队首来源接收；
- DSQ 在 AW 真正送往 APBIF 或 EBIU 时记录目的地，使同序 W 发往同一目标。

这是一种 **地址和数据重新关联机制**。它不能单独代表所有内存类型的完整顺序
语义；strongly-ordered outstanding、外部总线返回顺序和 barrier 还由其它
状态机共同实现。

### 2.4 APB 与 EBIU 的地址选择

NCQ 使用：

```verilog
addr[39:27] == sysio_ciu_apb_base[39:27]
```

选择 APB 区域，未命中则选择 EBIU。读写路径还分别保存
`ncq_ar_apbif_sel/ncq_aw_apbif_sel`，在一个 APB 事务未返回时限制另一类 APB
事务插入。因而：

- 地址比较只是目标区域分类；
- `ncq_apbif_*valid` 还受到当前 outstanding 状态门控；
- 最终接受必须看 APBIF/EBIU grant；
- grant 后 RAQ/WAQ 才 pop。

### 2.5 返回队列

APBIF 和 EBIU 的 R 都先竞争 RDQ 空位；B 都先竞争 WBQ 空位。若同周期两端
同时返回，RTL 对 R 和 B 都采用 **APBIF 固定优先**：

```verilog
rdq_create_bus = apbif_ncq_rvalid ? apbif_rbus : ebiu_rbus;
wbq_create_bus = apbif_ncq_bvalid ? apbif_bbus : ebiu_bbus;
```

因此此处不是轮询仲裁。APBIF valid 为 1 时，NCQ 只给 APBIF grant，EBIU 必须
继续保持返回。NCQ 给下游的 R/B grant 表示返回已进入 RDQ/WBQ，不表示 PIU
已接收；PIU 的 grant 出现后，返回队列才 pop。

---

## 3. 全局监视器 `ct_ciu_ncq_gm`

当前 NCQ 只实例化核 0、核 1 两个 GM。核 2、核 3 的 `gm_success/gm_vld`
固定为 0，这与当前双核配置一致。

### 3.1 建立监视

当 RAQ 头部的 locked read 被 APBIF 或 EBIU 接受时：

```verilog
gm_ar_req = raq_valid && raq_pop_en && arlock && !bar;
```

按 ARID 中的 core 编号选择对应 GM，在时钟沿：

```text
gm_exclusive <- 1
gm_cont[73:0] <- raq_pop_bus[73:0]
```

所以监视建立点是 **读地址从 NCQ 被目的端接受**，不是 PIU 刚把读送入 RAQ
的周期。

### 3.2 清除与成功判定

任意被 NCQ 接受处理的写地址若与监视项的完整 40-bit PA 相等，会清除该 GM：

```verilog
gm_clr_vld = gm_aw_req && waq_pop_en
          && (waq_addr == gm_cont.addr);
```

当前写是否成功还要求：

```verilog
gm_aw_req
&& waq_pop_bus[LOCK]
&& gm_exclusive
&& (gm_cont[73:0] == waq_pop_bus[73:0])
```

最后一项比较整个 74-bit 总线，不只是地址。这比“地址相同且 monitor 有效”更
严格，属性或 ID 不同也可能失败。NCQ 把所有核的 `gm_success` 归约成
`ncq_xx_aw_needissue`：

- 成功或普通写：继续向 APB/EBIU 发实际写；
- failed exclusive：不向目标发实际 AW/W，但仍产生失败响应路径。

该结构可作为非相干 exclusive monitor 理解。把它直接称为 RISC-V LR/SC 的
全部架构实现仍需结合核侧 AMO/LR/SC 解码和总线 lock 映射验证。

---

## 4. EBIU 的外部接口边界

`ct_ebiu_top` 实例化读通道、写通道、低功耗控制和 dummy snoop channel。外部
可见的主要接口是：

```text
AR/R/AW/W/B
RACK/BACK
CACTIVE/CSYSREQ/CSYSACK
```

外部没有 AC/CD/CR 端口。因此准确称呼是“带 ACE 风格属性和确认信号的外部
AXI 主接口子集”，不宜写成不加限定的完整 ACE coherent interconnect。

RACK/BACK 在 EBIU 读写通道中根据已消费的最终 R/B 生成确认脉冲和计数状态，
不是由名称自动产生，也不是所有配置下固定常量。

---

## 5. EBIU 读通道

### 5.1 请求源与地址缓冲

读通道有三类来源：

| 来源 | 典型用途 |
|------|----------|
| NCQ | 非相干内存读 |
| EBIUIF/SNB | 可缓存 miss、维护等需要的外部读 |
| CTCQ | 保留的 DVM operation/sync 类外部读请求；当前配置不产生有效流量 |

仲裁结果先写入一个当前 AR 地址缓冲。`ebiu_pad_arvalid` 由该缓冲 valid 驱动，
只有 `arvalid && pad_ebiu_arready` 后才能清除或装入下一请求。因此来源 grant
表示其请求已进入 EBIU 地址缓冲，不等于外部 slave 已经在同周期接受。

三源选择状态 `ar_snb_sel[2:0]` 在“任一来源 valid 且 `clk_en`”时轮转，并不
要求本周期已经 grant。也就是说，依赖阻塞或地址缓冲忙时，优先状态仍可能
继续推进；它实现的是随请求活动轮转的选择偏好，而不是严格按成功服务次数
轮询。当前 `ct_ebiu_snoop_channel_dummy` 又使外部 DVM AC 入口无效，
`ct_ciu_ctcq` 也不产生有效的 DVM Complete AR，因此 CTCQ 读源是保留结构，
不能据此声称当前系统已有端到端片外 DVM 流量。

### 5.2 ARID 编码

EBIU 用 8-bit ARID 的高位区分返回目标：

| ARID | 来源 |
|------|------|
| bit7=0 | NCQ，低位保留 NCQ ID |
| `[7:6]=10` | SNB，bit5 区分 SNB0/1，`[4:0]` 是 SAB entry |
| `[7:6]=11` | CTCQ，`[5:0]` 是 CTCQ ID |

外部 R 返回时按 RID 组合解码，不需要额外按发出顺序猜测来源。

### 5.3 两项 R FIFO 与最终交付

外部 `rvalid` 且 R FIFO 未满时，数据、RID、RRESP、RLAST 进入深度 2 的
RFIFO。RFIFO 头部再向 NCQ、SNB0、SNB1 或 CTCQ保持 valid，直到目标 grant。

对 SNB，`RID[4:0]` 解码成 24-bit one-hot entry select。该选择只定位哪个
SAB entry 接收数据；entry 是否收齐整个 burst、后续是否写 L2、是否已返回
PIU，要看 RLAST 和 SAB 状态机。

---

## 6. EBIU 写通道

### 6.1 两个地址来源

写地址来源为：

- NCQ：非相干写；
- VB：来自 L2C/SNB 的 victim、writeback 或维护类写。

两源使用状态位轮换选择，但还分别受到 NCWT/CAWT 空间、地址依赖和 SO 控制
门控。`aw_vb_sel` 和读通道相似：只要任一来源 valid 且 `clk_en` 就翻转，
而不是等真实 AW grant 后才翻转。被 EBIU grant 后，地址先进入当前 AW
缓冲；外部 AW 接受仍需
`ebiu_pad_awvalid && pad_ebiu_awready`。

波形中还会看到 `ebiu_*_aw_grant_gated`。它们由“来源已选中且跟踪队列未满”
产生，主要用于数据路径和时钟门控，并没有包含全部地址依赖、SO 状态以及当前
AW 缓冲 ready 条件。只有不带 `_gated` 的 `ebiu_*_aw_grant` 才表示该请求
真正创建进 EBIU 写地址路径。不能用 `_grant_gated` 单独统计已接受事务数。

### 6.2 `aw_needissue`

```verilog
aw_needissue =
  NCQ ? ncq_xx_aw_needissue
      : (vb_ebiu_awsnoop != 3'b100);
```

因此两类请求可能被 EBIU 在内部“接受并完成本地处理”，但不发片外 AW/W：

- failed exclusive NCQ 写；
- VB 的 Evict 编码 `awsnoop==100`。

判断片外写是否真实发生，必须观察：

```text
aw_needissue
ebiu_pad_awvalid && pad_ebiu_awready
ebiu_pad_wvalid && pad_ebiu_wready
ebiu_pad_wlast
pad_ebiu_bvalid 与内部 B 接受
```

### 6.3 NCWT：16 项 write-ordered 写跟踪

只有 `ncq_aw_wo` 被接受时创建 NCWT：

```verilog
ncq_aw_wo = ncq_xx_awcache[1];
ncq_aw_so = !ncq_xx_awcache[1];
```

每个 NCWT 保存：

- valid；
- PA[13:6]；
- ID；
- 总线 B 是否完成；
- 响应是否已交回 NCQ；
- exclusive fail 和 B response。

释放要求 bus side 和 source response side 都完成。failed exclusive 可在创建
时把 bus_done 视为完成，因为没有实际片外写。

NCWT 只比较 PA[13:6] 做 write-ordered 地址依赖。这是保守低索引比较，不是
完整 PA 相等；不同高位地址可能发生假冲突。

### 6.4 Strongly-ordered 写

SO 写不创建 NCWT，而是使用每核 outstanding 状态、计数和独占失败 FSM。
`ciu_so_ostd_dis` 进一步限制 SO outstanding 行为。不能把 NCWT 描述成所有
NCQ 写的统一跟踪表。

RTL 注释还明确假定：同核相同 AWID 的返回由 slave 保序；不同核同时访问同一
IP 的约束部分依赖软件。因此，完整 SO 语义包含硬件协议假设，不能只从一个
队列深度推导。

### 6.5 CAWT：32 项已发 VB 写跟踪

VB 写被 EBIU 接受且 `aw_needissue=1` 时创建 CAWT。CAWT 保存 PA[13:6] 和
MID，直到对应外部 B 返回才释放。它参与：

- 新 VB 写与已有写的冲突；
- SNB/EBIUIF 读与正在外写 line 的冲突；
- 保留的外部 snoop index 与写出的冲突。

这些比较同样只用 PA[13:6]，会保守阻塞低索引相同的不同 tag 地址。CAWT=32、
NCWT=16 是 RTL 容量事实；“前者更大一定是因为来源更多”没有源码直接证据，
不作为确定结论。

当前 `ct_ebiu_snoop_channel_dummy` 把外部 AC valid 固定为 0，因此 CAWT 中
面向外部 snoop index 的命中比较器虽然存在，正常配置下没有有效请求驱动；
当前实际活跃的是新 VB 写和 SNB/EBIUIF 外部读等内部路径的地址依赖检查。

### 6.6 AW 与 W 来源顺序

写通道还有 16 项 source-order 环形队列。AW 被接受时记录来源是 NCQ 还是
VB；W 通道按队头选择相同来源，直到该笔写数据完成后推进。它解决 AXI 中 AW/W
解耦后的来源匹配。

VB entry 在最后一个 W beat 交给 EBIU 时即可释放，而对应片外 B 继续由 CAWT
跟踪。这是“数据源缓冲释放”和“总线事务最终完成”分离的典型例子。

---

## 7. L2CIF

### 7.1 bank 与源优先关系

每个 L2 bank 的地址类接口有：

```text
CTCQ maintenance > DCA > SNB
```

RTL 直接体现为：

```verilog
snb_addr_vld = snb_req && !ctcq_req && !dca_req;
dca_req_out  = dca_req && !ctcq_req;
ctcq_req_out = ctcq_req;
```

SNB 得到的 `l2c_snb_addr_grant` 来自 L2 ready，但它只有在 SNB 实际未被更高
优先源屏蔽时才具有接受意义。波形分析不能只看 ready 常高而忽略最终 valid。

### 7.2 CTCQ maintenance 扇出

一笔 CTCQ L2 maintenance 同时针对 bank0、bank1。L2CIF FSM：

1. 分别保持两 bank 请求；
2. 每个 bank ready 后清其 pending request；
3. 分别记录两 bank completion；
4. 两个 completion 都到达后，给 CTCQ 一个总 completion。

因此 `l2c_ctcq_cmplt` 不是任意一个 bank 完成，而是两 bank 完成位均已记录。

### 7.3 DCA

DCA 是 PIU 侧用于直接 cache access 的调试/CSR 读路径。四个 PIU 请求按
`casez` 固定优先选择，精确优先级为
`PIU0 > PIU1 > PIU2 > PIU3`；它按 index bit6 只访问一个 L2 bank。这里应
称为固定优先，不应与 `ct_prio` 的有状态优先级混淆。

### 7.4 SNB 数据与元数据

L2CIF 透传：

- 13-bit L2 操作类型；
- `set_cp/clr_cp`；
- SRC、SID、MID；
- 地址；
- 512-bit 数据；
- response、cp、completion。

L2C 的 prefetch、snpl2 和 victim 请求则经 L2CIF 返回 SNB/VB。VB 不是主动
向 L2 发地址请求的源；victim 数据方向是 L2 -> VB。

---

## 8. EBIUIF

EBIUIF 连接 SNB 与 EBIU 读通道，并把 EBIU R 解码后的 bank/entry 选择和数据
送回对应 SNB。它也接收 EBIU 对 CAWT 地址冲突的结果，供 SNB 外部访问排序。
EBIUIF 还保留外部 snoop 与 CAWT 的依赖比较接口，但当前外部 AC 由 dummy
通道固定为无效，所以这部分比较逻辑在当前配置中是静默的。

VB 写不经 EBIUIF 转发数据，而是直接连接 EBIU write channel；CTCQ 的外部
DVM AR 也直接连接 EBIU read channel。把 EBIUIF笼统画成“所有
SNB/VB/CTCQ 到 EBIU 的统一桥”会掩盖真实端口关系。

---

## 9. BMBIF

`ct_ciu_bmbif` 为四个目的模块各实例化一个 `ct_ciu_bmbif_kid`：

```text
SNB0、SNB1、NCQ、CTCQ
```

每个 kid 接收 PIU0～PIU3 的目的请求，用有状态 `ct_prio` 选择一个来源，并把
one-hot 来源写入深度 4 的 FIFO。目的模块看到 FIFO 头部的请求，grant 后 pop。

### 9.1 kid 不是 CDC 同步模块

源码中没有双触发器同步器；它是仲裁和来源 FIFO。`kid` 名称不能作为 CDC
证据。

### 9.2 一个细微但重要的 payload 约束

FIFO 只保存 4-bit 来源 one-hot，不保存 9-bit 请求 payload。输出 payload 是
用 FIFO 头部 one-hot 从 **当前 PIU live bus** 中选择：

```verilog
bmbif_xx_req_bus =
  source_onehot[3] ? piu3_bmbif_req_bus :
  ...
```

因此集成协议要求 PIU 在该目的事务真正被 grant 前保持请求 bus 内容稳定。
另外 create 逻辑未用 `xx_fifo_full` 门控；正常工作依赖每个 PIU/目的组合不会
违反保持和 outstanding 约束。这里不应把 FIFO 存在误解成“payload 已被完全
缓冲，源端可立即任意改变”。

BMBIF 提供 barrier 向四个目的的排队和来源关联。体系结构上的“屏障前访问已
全局可见”还取决于 SNB、NCQ、CTCQ 对 barrier 的完成条件，不能只由 BMBIF
自身证明。

---

## 10. APBIF

### 10.1 FSM 与接受事件

```text
IDLE --read accepted--> REQ -> PEND -> IDLE
IDLE --AW accepted----> WADDR --W accepted--> REQ -> PEND -> IDLE
```

- IDLE 中读优先于写；
- AR/AW grant 表示 APBIF 已在时钟沿锁存地址、ID、保护属性；
- 写还要在 WADDR 等 W，并按地址 `[3:2]` 选 128-bit WDATA 中的 32-bit lane；
- REQ 是 APB setup，`psel=1, penable=0`；
- PEND 是 APB access，`psel=1, penable=1`；
- 目标 `pready` 或 no-target/no-issue 条件使事务完成。

### 10.2 精确地址解码

| 目标 | 解码 |
|------|------|
| PLIC | `addr[26] == 0` |
| CLINT | `addr[26:16] == 11'h400` |
| HAD | `addr[26:16] == 11'h401` |
| L2PMP | `addr[26:16] == 11'h402` |
| RMR | `addr[26:16] == 11'h403` |

L2PMP 再用地址 `[15:14]` 选择 core0～core3。

### 10.3 返回

APB 32-bit read data 被复制四次形成 128-bit NCQ RDATA。目标 `perr` 形成
`{resp_err,1'b0}` 的 RRESP/BRESP。地址没有命中任何目标时，`perr` 也被置 1，
并通过 `psel_none` 完成本地错误返回。

当前 `ct_piu_other_io_sync` 的 L2PMP `pready/perr/rdata` 固定为
`1/0/0`，所以虽然 APBIF 有完整 L2PMP decode，当前连接只提供零数据 dummy
响应。

---

## 11. CIU 寄存器

### 11.1 多核访问仲裁

`regs_sel_raw={piu3,piu2,piu1,piu0}`。同时请求时，`casez` 选择优先级：

```text
PIU3 > PIU2 > PIU1 > PIU0
```

这是真正的固定优先。寄存器 FSM 非空闲后把选择锁存在 `regs_sel_ff`，保持当前
owner 直到访问完成；新高优先请求不能中途抢占。

### 11.2 CHR2 位定义

| bit | 输出 | RTL 作用 |
|-----|------|----------|
| 0 | `ciu_chr2_bar_dis` | barrier completion 可绕过依赖 |
| 1 | `ciu_icg_en` | CIU 子模块 ICG module enable |
| 4 | `ciu_chr2_sf_dis` | L2 hit 时过滤候选退化为 `1111` |
| 5 | `ciu_chr2_dvm_dis` | 寄存器输出存在，但当前 `ct_ciu_ctcq` 可执行逻辑未使用 |
| 6 | `l2c_icg_en` | L2C 时钟门控使能 |
| 7 | `regs_apbif_icg_en` | regs/APBIF 时钟门控使能 |
| 8 | `ciu_sysio_icg_en` | sysio 相关门控 |
| 9 | `ciu_global_icg_en` | CIU 全局门控控制 |
| 10 | `ciu_so_ostd_dis` | SO outstanding 限制 |

bit2、bit3 在 `chr2_data[10:0]` 中存在，但当前列出的输出没有赋予它们上述功能，
不能擅自补名称。

bit5 清楚地展示了“端口存在”和“功能生效”是两个不同层次。`ct_ciu_regs` 确实把
`chr2_data[5]` 导出为 `ciu_chr2_dvm_dis`，顶层也把它连入 `ct_ciu_ctcq`；
但该信号在当前生成 RTL 中除端口声明和 `Force` 注释外没有被任何可执行表达式
引用。因此写 bit5 对当前 CTCQ/DVM 行为没有可由 RTL 证明的影响，不能把它当
作已经生效的 DVM disable 开关。

`bar_dis=1` 的可执行效果应描述成允许 SAB barrier completion 忽略
`depd_vld`，比笼统说“关闭全部屏障处理”更准确。

### 11.3 SMP enable

核 0、核 1 有真实 `ct_ciu_regs_kid`，SMPR bit0 可写入 `smpen[0/1]`。当前：

```verilog
smpen[2] = 0;
smpen[3] = 0;
```

`smpen` 参与 SAB 的 `cp_after_mask` 和 CTCQ DVM 目标选择。它不直接改写所有
cache line 的 cp，也不能把置位瞬间理解成全系统目录已经自动重建。

### 11.4 时钟门控结论边界

这些 ICG 位控制 RTL 的 gated-clock enable。未定义工艺 ICG 宏时，通用
`gated_clk_cell` 可能把输出直接连输入；DC 文件列表则使用工艺 ICG。文档因此
只断言门控意图和逻辑使能，不由寄存器位单独推导实际动态功耗。

---

## 12. 波形分析方法

### 12.1 NCQ 读

```text
piuN_ncq_ar_req / ncq_piuN_ar_grant
raq_create/pop/full
raq_apbif_sel
ncq_apbif_arvalid / apbif_ncq_ar_grant
ncq_ebiu_arvalid / ebiu_ncq_ar_grant
rdq_create/pop/full
ncq_piuN_rvalid / piuN_ncq_r_grant
```

这能区分等待 NCQ 空间、目的选择、APB/EBIU 接受、目标 latency 和 PIU 返回
背压。

### 12.2 外部写

```text
NCQ/VB AW valid 与 EBIU grant
aw_needissue
cur_waddr_buf_awvalid / pad_awready
source-order FIFO head
pad_wvalid / pad_wready / wlast
pad_bvalid / bfifo
NCWT 或 CAWT valid/pop
最终 NCQ B grant；VB 查看本地写数据完成和 CAWT 的片外 B 释放
```

若 `aw_needissue=0`，没有片外 AW/W 是设计行为，不是总线卡死。

VB 的生命周期尤其不能只看信号名：`ebiu_vb_bvalid` 是 EBIU 在接收 VB 最后
一个 W beat 后本地产生的一周期固定 OK 响应，用于结束 VB 本地数据源事务；
它不是片外 B。真实片外 B 是
`pad_ebiu_bvalid && ebiu_pad_bready`，先进入 BFIFO，再按 BID 命中并释放
CAWT。因而“VB entry 已释放”和“外部写已收到 B”可以相隔很多周期。

### 12.3 L2

```text
ctcq/dca/snb req
最终 ciu_l2c_*_vld
l2c ready
SID/MID/type/set_cp/clr_cp
l2c completion/resp/cp
```

同时看“源请求”和“最终输出 valid”，才能发现请求是否被更高优先源屏蔽。

---

## 13. 关键结论

1. NCQ 当前接收 PIU0～PIU3，PIU4 device 口是静态 dummy。
2. WOQ/DSQ 解决 AW/W 来源和目的关联，不等于完整强序语义。
3. GM 当前只实现核 0/1，成功比较整个 74-bit 请求内容。
4. EBIU 外部是 AXI 数据通道加一致性属性/确认，不是完整外部 AC/CD/CR 节点。
5. RID 高位精确区分 NCQ、SNB bank/SAB entry 和 CTCQ。
6. NCWT 只跟踪 write-ordered NCQ 写；SO 写使用独立每核状态。
7. CAWT 跟踪真实发出的 VB 写到片外 B 返回；VB 本地 `ebiu_vb_bvalid` 不是
   片外 B，NCWT/CAWT 地址依赖都只比较 PA[13:6]。
8. `aw_needissue=0` 的 failed exclusive 或 Evict 不发片外 AW/W。
9. L2CIF 地址优先级为 CTCQ、DCA、SNB；CTCQ maintenance 等两个 bank 完成。
10. BMBIF kid 是仲裁器和来源 FIFO，不是 CDC，也不保存 9-bit payload。
11. APBIF 实现标准 setup/access 时序、精确目标 decode 和本地错误返回。
12. CIU regs 同时请求时固定 PIU3 最高优先，访问期间锁定 owner；
    `CHR2[5]` 虽导出 DVM disable 信号，但当前 CTCQ 可执行逻辑未使用它。
