# C910 CIU SNB/SAB 模块详细教学文档

> 主要 RTL：`ct_ciu_snb.v`、`ct_ciu_snb_arb.v`、
> `ct_ciu_snb_sab.v`、`ct_ciu_snb_sab_entry.v`
>
> 选择器 RTL：`ct_ciu_snb_dp_sel.v`、`ct_ciu_snb_dp_sel_16.v`、
> `ct_ciu_snb_dp_sel_8.v`

---

## 1. SNB 和 SAB 分别解决什么问题

CIU 实例化两个 SNB。PIU 已按 PA[6] 把可缓存请求分流：

```text
PA[6]=0 -> SNB0
PA[6]=1 -> SNB1
```

单个 `ct_ciu_snb` 内有两个主要部分：

- `ct_ciu_snb_arb`：在 PIU、外部 snoop、L2 prefetch/snpl2 和各类返回接口
  之间仲裁；
- `ct_ciu_snb_sab`：保存 24 个 outstanding 事务，并从这些 entry 中选择当前
  可以使用 L2、PIU AC、EBIU、R/B 返回等资源的事务。

每个 `ct_ciu_snb_sab_entry` 是一个小型事务引擎。它保存请求控制、依赖、年龄、
L2/CR 响应、最多 512-bit 数据和多个状态机。它不是只有“地址和目录位图”的
无数据控制项。

### 1.1 一个事务项处理的典型阶段

```text
创建 entry
  -> 等依赖和写数据
  -> 访问 L2 tag/status
  -> 计算侦听目标
  -> 向目标核发 AC，收 CR/CD
  -> 读写 L2 或访问外部内存
  -> 形成 R/B/CR
  -> 返回被接受后释放 entry
```

不同请求类型会跳过部分阶段。状态名表示 entry 当前等待的主要资源，不等于该
体系结构操作已完成。例如 `L2C` 表示 entry 正在发起或等待 L2 操作；只有
`l2c_cmplt_x` 到达才说明该次 L2 子操作完成。

上面的“外部 snoop”是 RTL 中保留的 `snpext` 结构。当前可综合顶层实例化
`ct_ebiu_snoop_channel_dummy`，它把外部 AC valid 固定为 0；
`ct_ciu_ebiuif` 又把外部 CR/CD 返回固定为无效，SAB entry 内的
`ebiu_cr_done` 也固定为 0。因此当前配置不会创建 `snpext` 事务，不能把这条
结构路径当成已经可工作的外部 ACE snoop 功能。

---

## 2. 双 bank 的能力与边界

PA[6] 是 64B cache line 之上的最低地址位，因此相邻 line 交替进入两个 SNB。
这允许两个 bank 同时推进各自的 SAB 事务。需要严格区分：

- **硬件提供两个并行处理域**：RTL 事实；
- **吞吐固定翻倍**：不能由 RTL 结构直接保证。

若访问长期集中在同一个 PA[6]、两个 bank 竞争共享 L2/EBIU，或者事务都等待
相同核的侦听响应，实际吞吐不会达到理想的两倍。

---

## 3. SAB 容量和创建

配置宏定义：

```verilog
SAB_DEPTH  = 24;
SAB_RDEPTH = 16;
SAB_WDEPTH = 8;
```

entry 0～15 分配给读地址类请求，entry 16～23 分配给写地址类请求。读写分区
意味着：

- 读只在 16 个读项中寻找空位；
- 写只在 8 个写项中寻找空位；
- 一类用满不会直接占用另一类预留 entry。

这能防止一种流量把全部 24 项都占满，但“设计者一定为了某个具体性能目标选择
16:8”属于推断，源码没有给出完整设计依据。

名义深度还要结合来源预留来理解。读区创建使能为：

```verilog
snpl2_create_en  = ~(&sab_rentry_vld[15:0]);
snpext_create_en = ~(&sab_rentry_vld[14:0]);
piu_ar_create_en = ~(&sab_rentry_vld[13:0]);
```

因此：

- L2 `snpl2` 可使用 16 个读项；
- 外部 `snpext` 只在 entry 0～14 至少有一项空闲时创建，相当于为 `snpl2`
  保留 entry15；
- 普通 PIU/L2 prefetch AR 只在 entry 0～13 至少有一项空闲时创建，相当于
  再为 `snpext` 保留 entry14。

当前外部 snoop 被 dummy 禁用，但这套保留逻辑仍存在，所以普通 AR 的可持续
占用上限是 14 项，而不是看到 `SAB_RDEPTH=16` 就认为普通核读可以占满 16 项。

写区也有类似的非对称预留：

```verilog
sab_wentry_full = (aw_bar_wns && !aw_bar_sel[5])
                ? &sab_wentry_vld[7:0]
                : &sab_wentry_vld[6:0];
```

来自 PIU 的 WNS/WB/WC/Evict 类可以使用全部 8 个写项；其它 AW 和 barrier
只在前 7 项中有空位时接受，从而把最后一个写项保留给这类必须继续排空的写
事务。于是“16 读/8 写”是物理 entry 数，“普通 PIU AR 14 项、普通非 WNS
AW 7 项”才是相应入口的有效准入上限。

### 3.1 请求、创建和状态变化

创建过程至少包含：

1. `snb_arb` 选出一个候选 AR 或 AW；
2. SAB 在对应读区或写区选出空 entry；
3. `sab_*_create_en` 与 one-hot create select 形成 `sab_cen0/1`；
4. 时钟沿把 create bus、依赖向量和年龄向量写入 entry；
5. 时钟沿后 `sab_vld`、`sab_busy` 和 FSM 状态体现新事务。

所以 `piu_snb_ar_req=1` 只是 PIU 正在请求 SNB；SNB grant 才表示请求被本 bank
接受；entry 的 `x_cen` 及随后 `vld` 才能确认事务状态已经落地。

---

## 4. 单个 SAB entry 保存的内容

### 4.1 控制与身份

`sab_cont[74:0]` 保存地址、snoop、domain、cache、size、len、ID、MID、读写
属性等。主要派生信号包括：

| 派生信号 | RTL 判定 |
|----------|----------|
| `rs` | ReadShared |
| `ru` | ReadUnique |
| `rns` | ReadNoSnoop 且 Non-shareable |
| `ro` | ReadOnce |
| `cu/ci/cs/mi/mu` | CleanUnique/CleanInvalid/CleanShared/MakeInvalid/MakeUnique |
| `wu/wlu` | WriteUnique/WriteLineUnique 类 |
| `wns_i` | WriteNoSnoop |
| `wb/wc/evict` | WriteBack/WriteClean/Evict |
| `snpext` | MID `110` |
| `snpl2` | MID `111` |
| `l2_prf` | L2 prefetch 来源或 user 属性 |

这些名称是 RTL 的内部请求分类。对外协议名称和完整语义仍应结合总线规范解释，
不能仅按英文缩写猜测。

### 4.2 数据存储

每个 entry 明确包含：

```verilog
reg [127:0] data0;
reg [127:0] data1;
reg [127:0] data2;
reg [127:0] data3;
```

四段合计 512 bit，可保存一条 64B line。entry 还有每段 byte select、数据
选择、写数据有效和错误状态。数据可能来自：

- 原始核侧写数据；
- 被侦听核返回的 CD；
- L2 返回的数据；
- 外部内存读响应。

不同来源经 write-enable 和 data select 写入相应 128-bit 段。因此，“SAB
只存地址、不存数据”是错误的。更准确的说法是：SAB 是 **控制与数据合一的
outstanding transaction buffer**，但它不是长期保存 cache line 的 cache。

### 4.3 响应与元数据

entry 还保存：

- `l2_resp[4:0]`：L2 子操作响应；
- `cp[3:0]`：L2 返回的 presence/filter 元数据；
- `crresp[4:0]`：多个目标核 CR 的按位或累积；
- `depd_val[23:0]`：仍需等待的 SAB entry；
- `agevec[23:0]`：比本 entry 更老的事务；
- 主 FSM、四个 snoop FSM、L2/MEM 子 FSM。

---

## 5. L2 与 CR 响应位不能混用

SAB 对五位响应使用以下位：

| 位 | CR 中的解释 | L2 响应中的解释 |
|----|-------------|-----------------|
| 0 | DT，Data Transfer | 由具体 L2 子操作定义 |
| 1 | ERR | ERR |
| 2 | PD | PD |
| 3 | IS | IS |
| 4 | SAB 当前决策逻辑未单独命名或解码 | HIT |

RTL 中：

```verilog
l1_dt  = crresp[0];
l1_err = crresp[1] | wt_err;
l1_pd  = crresp[2];
l1_sh  = crresp[3];

l2_err = l2_resp[1];
l2_pd  = l2_resp[2];
l2_sh  = l2_resp[3];
l2_hit = l2_resp[4];
```

DT 表示后续存在 CD 数据，不是 dirty。PD 与数据状态有关，但具体协议语义仍需
结合请求类型。另一个细节是，L2 在 allocate 路径复用 HIT/IS 位表示
`alct_cmplt/alct_done`；不能把同一 bit 在所有状态下一概翻译成普通 tag hit。

多个核 CR 到达时，entry 对 `crresp` 做按位或。这会保留“至少一个目标报告该
属性”的聚合结果，但不保留每个目标各自的五位响应。每核是否已完成由各自
snoop FSM 跟踪。

特别地，CR bit4 虽然会进入聚合寄存器并可沿 CR 总线传播，但本 entry 的状态
转移没有像 DT/ERR/PD/IS 那样给它定义独立语义。仅凭该位位置不能把它翻译成
某个 ACE 状态；L2 响应 bit4 的 HIT 解释也绝不能反向套到 CR。

---

## 6. `cp` 过滤：候选目标如何形成

L2 相关子操作完成后，entry 在 `l2c_resp_wen` 时锁存：

```verilog
l2_resp <= l2c_resp;
cp      <= l2c_cp;
```

然后计算：

```verilog
cp_after_sf   = (ciu_chr2_sf_dis && l2_hit) ? 4'b1111 : cp;
cp_mask       = inst ? 4'b0000 : piu_sel;
cp_after_mask = cp_after_sf & ~cp_mask & smpen;
```

逐层解释：

1. `cp` 给出 L2 返回的候选核集合；
2. 关闭 snoop filter 且 L2 hit 时，候选集合强制为所有四核；
3. 普通数据请求去掉发起核自身；
4. `inst=1` 时不使用该自核 mask，这个特例不能省略；
5. `smpen` 去掉当前不参与 SMP 的核。

最终还有请求类型门控：

```verilog
cp_vld = |cp_after_mask
      && !(rns || wns || evict || l2_prf);
```

所以 `cp_after_mask!=0` 并不保证一定发 AC；被排除的请求类别不会启动普通
per-core snoop 流程。

`cp` 可用于解释侦听过滤，但不能仅凭 CIU 这一处寄存器断言它是全系统始终精确
的 sharer directory。精确性还依赖 L1 Evict/WriteBack 通知、L2 元数据更新和
异常/复位流程。

---

## 7. 四个 per-core snoop FSM

每个目标核有四态子 FSM：

```text
IDLE -> REQ -> WAIT -> CD -> IDLE
                  \--------> IDLE   (DT=0)
```

准确事件如下：

| 状态 | 等待事件 | 事件含义 |
|------|----------|----------|
| IDLE | `snpX_req_vld` | 本 entry 的目标位选择了核 X |
| REQ | `piuX_ac_grant_x` | AC 已被 PIU X 的 AC FIFO 接收 |
| WAIT | `piuX_crvld_x` | 对应 CR 已回到该 SAB entry |
| CD | `piuX_cdvld_x` | DT=1 时，对应完整 CD 包已交给 entry |

`piuX_ac_grant_x` 不是核侧 AC 握手；中间还隔着 PIU AC FIFO。SAB 的目标 FSM
进入 WAIT，只说明 PIU 已经承担后续交付责任。

若 CR 的 DT=0，WAIT 在 CR 到达时完成；若 DT=1，FSM 进入 CD，等数据有效后
完成。`snpX_cmplt` 在 IDLE 也为 1，因此未被 `cp_after_mask` 选择的核不会阻塞
总完成：

```verilog
snp_cmplt = snp0_cmplt & snp1_cmplt & snp2_cmplt & snp3_cmplt;
```

### 7.1 AC 类型的 RTL 选择

entry 产生：

```verilog
acsnoop = (cu || snpl2 || ru || wu) ? 4'b1001
        : (mu || wlu)                ? 4'b1101
        : rs                         ? 4'b1000
                                     : original_snoop;
```

RTL 注释把 `1001` 标为 CI、`1101` 标为 MI、`1000` 标为 CS。文档可以说明
它们通常对应 clean/invalidate/shared 类动作，但不要擅自写出未由核内 L1 状态
机验证的 “M->O” 或 “所有目标直接 I” 等具体状态转换。

---

## 8. 14 态主 FSM

状态编码为：

| 状态 | 本 entry 正在做什么 |
|------|---------------------|
| IDLE | 等待创建或尚未启动 |
| DEPD | 等更老冲突、写数据或其它依赖 |
| L2C | 发起/等待首个 L2 操作，常见为 tag/status 相关操作 |
| SNOP | 等所有选中目标核的 CR/CD |
| L2CR | 读 L2 数据 |
| L2CW | 写 L2 数据/状态或执行维护更新 |
| L2CA | 请求 L2 分配 |
| MEMR | 发起并等待外部内存读 |
| L2CT | 再次检查 L2 tag/status |
| MEMW | 发起并等待外部内存写 |
| BAR | 等 barrier 依赖解除 |
| POP | 形成/等待最终读写响应并释放 |
| CR | 为外部 snoop 预留的 CR 返回路径；当前配置不可达 |
| ECC_ERR | 错误返回和清理 |

状态名是简写。例如 `L2CW` 不只等价于“写 512-bit 数据”；它还可能发 clean、
invalidate、unique、shared 或 cp 更新等 L2 操作。

### 8.1 IDLE 与 DEPD

新非 barrier 请求：

- 没有创建时依赖，且不是写请求：可直接进入 L2C；
- 有依赖，或是需要等待数据的写请求：进入 DEPD；
- barrier：进入 BAR。

DEPD 只有在 `depd_val` 清空且所需写数据已到达时才进入 L2C；写数据错误可转
ECC_ERR。因而一个 entry 占用 SAB 但长期停在 DEPD，可能是地址别名串行，也
可能是 AW 已到而 W 数据迟到，不能只归因于 L2。

### 8.2 L2C

L2 子操作 completion 到达后：

- 有有效侦听目标：进入 SNOP；
- Evict 或特定 CleanShared-L1 且无需侦听：可进入 POP；
- 维护/L2 snoop：可能进入 L2CW，或等待依赖后再进入；
- L2 hit：按请求性质进入 L2CR、L2CW 或 MEMR；
- L2 miss：可能进入 CR、L2CA、MEMW、MEMR 或 L2CR；
- L2 error：进入 ECC_ERR。

这说明 “L2 miss 必然直接访问内存”并不准确。分配、外部 snoop、部分写以及
unique 路径有各自分支。

这里的“外部 snoop”只是在 `snpext=1` 时存在的状态分支。当前
`ebiu_ebiuif_acvalid=0`，所以正常仿真不应出现 `snpext` entry 或进入 CR；
若强制内部信号使其进入 CR，由于 `ebiu_cr_done=0`，entry 将无法正常释放。

### 8.3 SNOP

只有 `snp_cmplt && !depd_vld` 才能离开。无错误时，下一步可能是：

- L2CR：需要 L2 数据；
- POP：特定 clean-L1 且没有 PD；
- MEMR：unique 类且 L2 处于 shared 条件；
- L2CW：其它数据/状态更新。

如果聚合 CR 或写数据指示错误，则进入 ECC_ERR。

### 8.4 L2CR、L2CA、MEMR、L2CT、L2CW、MEMW

- L2CR 等 L2 数据返回；
- L2CA 等分配成功、完成或 ECC 错误；
- MEMR 同时考虑外部读完成和 `snpl2_done`；
- ReadUnique 某些路径在内存返回后通过 L2CT 再查；
- L2CW 等 L2 更新 completion，或走 `l2c_req_mask` 的无需实际请求路径；
- MEMW 等外部写 completion。

这些状态可能多次访问 L2。教学中把整个事务简化成“查一次 L2、侦听、返回”
只适合最简单 hit；分析真实波形必须跟踪每一次 `x_l2c_addr_bus` 的 req type。

### 8.5 POP、CR 和 entry 释放

POP 是响应与清理阶段，不是“进入 POP 的时钟沿立即释放”。entry 还要等相应
`rack/back`：SNB 把 R/B 交给 PIU 只是第一步，PIU 继续等待核侧接受后才返回
RACK/BACK，entry 据此释放。预留的外部 snoop 路径理论上在 CR 状态等待
`ebiu_cr_done`，但当前该信号固定为 0 且入口 AC 已被 dummy 禁用。判断 entry
生命周期应观察 `sab_pop_en_x`、RACK/BACK 和下一周期 `vld`，不能只看
`main_cur_state==POP` 或 SNB 的首个 R/B grant。

---

## 9. L2 请求类型

entry 生成 13 位 one-hot `req_type`：

| RTL 名称 | 注释中的作用 |
|----------|--------------|
| `req_read` | 读 cache line |
| `req_alct` | 分配 entry，必要时处理被替换 line |
| `req_cln` | clean |
| `req_icln` | clean and invalidate |
| `req_wtsd` | 写 Shared Dirty |
| `req_wtuc` | 写 Unique Clean |
| `req_wtud` | 写 Unique Dirty |
| `req_wtsc` | 写 Shared Clean |
| `req_atag` | 访问 tag，返回 cp 和状态 |
| `req_inv` | invalidate |
| `req_rls` | release pending |
| `req_uni` | 设置 unique |
| `req_sh` | 设置 shared |

这些是 **发给 L2CIF/L2 bank 的操作编码**，不是 SAB 内部已经完成的状态变化。
例如 `req_inv=1` 表示本 entry 正在请求 L2 执行 invalidate；还需目标接受和
`l2c_cmplt_x` 才能确认该子操作结束。

源码中的 SD/UC/UD/SC 名称说明 L2 使用 shared/unique、dirty/clean 组合表达
状态。它仍不足以证明 CIU 内存在一个显式完整 MOESI 五态寄存器，尤其不能把
某个组合未经核内验证地等同于 Owned。

---

## 10. `set_cp` 与 `clr_cp`

RTL 为 L2 生成：

```verilog
clr_cp_vld = state==L2C && (ru || cu || ws || wb || ci || mi || evict);
clr_cp     = (wb || evict) ? piu_sel : ~piu_sel;

set_cp_vld = state==L2CW && rd_alct && !l2_prf;
set_cp     = piu_sel;
```

准确理解是：

- WB/Evict 请求清请求者对应位；
- 其它列出的 unique/invalidate/write 类请求提供 `~piu_sel` 清除掩码；
- 非预取读分配在 L2CW 提供请求者置位掩码；
- `set_cp_sel/clr_cp_sel` 随 L2 地址操作送往 L2。

这些是更新请求，不是 entry 本地立即改写 `cp` 的语句。当前 `cp` 寄存器只在
L2 响应写使能时更新。分析波形时要同时看：

```text
set_cp_sel/clr_cp_sel
L2CIF 地址请求与 grant/ready
L2 completion
后续再次读出的 l2c_cp
```

---

## 11. 年龄向量和资源选择

entry 创建时锁存比它更老的有效项：

```verilog
create0_age = sab_entry_vld
            | {同周期创建的写项, 读区全0};
create1_age = sab_entry_vld;
```

这个细节处理同一周期读写同时创建时的相对年龄：新读项把同周期写项也视为更
老，而新写项只记录此前已有效项。

对某个共享资源，选择器判断：

```verilog
sel[n] = req_vld[n]
      && !(|(req_vld & entryN_age_vect));
```

即 entry N 有该资源请求，并且当前请求集合中没有一个被它标为更老的 entry。
entry 释放时，其位从其它 entry 的 agevec 清除。

| 选择器 | 范围 | 典型用途 |
|--------|------|----------|
| `ct_ciu_snb_dp_sel` | 24 项 | PIU AC、L2、EBIU 等 |
| `ct_ciu_snb_dp_sel_16` | 读区 16 项 | R 响应 |
| `ct_ciu_snb_dp_sel_8` | 写区 8 项 | B 响应 |

这能证明的是 **同一 bank、同一类共享资源、当前请求者之间的 oldest-requester
选择**。它不自动证明：

- 不同资源之间具有统一全局顺序；
- 两个 SNB bank 之间严格 oldest-first；
- 下游永久不给 grant 时仍绝不饥饿。

公平性和活性结论必须加入“下游最终前进”等协议假设。

---

## 12. 地址依赖是保守的低索引比较

`snb_arb` 提取新请求：

```verilog
ar_crt_entry_index = ar_addr[13:7];
aw_crt_entry_index = aw_addr[13:7];
```

每个已有 entry 比较：

```verilog
new_index[6:0] == sab_cont[ADDR_13:ADDR_7]
```

一个 SNB bank 已由 PA[6] 选定，因此跨顶层看，依赖分类使用 line index
PA[13:6]。它 **没有比较 PA[39:14] 的高位 tag**。

结果是：

- 真正同一 line 一定落入同一低索引类别并被保护；
- 高位 tag 不同、但 PA[13:6] 相同的地址也会被保守视为冲突；
- 文档不能把它称为“完整物理地址精确依赖”；
- 高别名流量可能造成额外 DEPD 停顿，这是潜在性能代价。

依赖不只是简单“新读等旧写”。RTL 还处理：

- barrier 对已有请求的依赖；
- 写请求与已有读写的重排约束；
- 为外部 snoop 保留的 `snpext` 与正在处理事务的依赖；当前入口被禁用；
- WNS back marking；
- entry pop 对 `depd_val` 的逐位清除。

`depd_val==0` 只说明 SAB 级记录的前序依赖已清除；写事务仍可能等待 W 数据，
其它子 FSM 也可能等待下游资源。

---

## 13. 一次真实可观察的读事务

以下示例假设核 0 发 ReadUnique，过滤结果选择核 1。它不预设核 1 的 MOESI
状态，只按 CIU 可见信号说明。

### 13.1 创建

```text
PIU0 piu_snbX_ar_req=1
SNB arb 选中 PIU0
SAB 读区有空项
SNB 给 PIU0 ar_grant
时钟沿：entry5 x_cen=1，保存请求和 create_age/create_depd
```

### 13.2 L2 子操作

entry5 无依赖时进入 L2C，提出 `sab_l2c_req_x`。经过 SAB oldest 选择和 L2CIF
交接后，L2 才接受请求。待 `l2c_cmplt_x=1`，entry 锁存响应与 cp。

### 13.3 侦听

若 `cp_after_mask=0010` 且请求类型允许侦听：

```text
entry5 snp1 FSM: IDLE -> REQ
SAB 选择 entry5 的 PIU1 AC
PIU1 AC FIFO 接受，piu1_ac_grant_x=1
snp1 FSM: REQ -> WAIT
PIU1 再把 AC 送给核1
核1 返回 CR
```

若 CR.DT=0，snp1 完成；若 CR.DT=1，snp1 转 CD，等对应数据包到 entry 后完成。

### 13.4 后续与返回

主 FSM 根据 L2/CR 聚合结果选择 L2CR、L2CW、MEMR 等路径。最终进入 POP，
向 PIU0 提出 R。PIU0 接受 SNB 的 R 后还要缓冲并送给核 0；只有核侧 R
`valid&&ready` 才是处理器看到的响应交付。

### 13.5 分析延迟时怎么拆

总延迟可按等待原因分解：

```text
PIU AR FIFO 等待
+ SNB 创建仲裁
+ DEPD/W-data 等待
+ L2 请求仲裁与 L2 latency
+ AC 仲裁与 PIU FIFO 等待
+ 目标核 snoop latency
+ CD 数据返回
+ 后续 L2/内存操作
+ R 返回仲裁和核侧背压
```

只有这种分段统计才能判断瓶颈在目录过滤、目标核、L2、外部内存还是返回通道。

---

## 14. 关键结论

1. SAB 是 24 项事务缓冲，物理上固定分成 16 读、8 写；来源预留使普通 PIU
   AR 和普通非 WNS AW 的准入上限分别为 14 和 7。
2. 每个 entry 不仅有控制状态，还能保存完整 512-bit line。
3. `cp` 是 L2 返回的 presence/filter 元数据，经 sf、自核和 smpen 三层处理。
4. DT 表示存在 CD 数据，不能翻译成 dirty。
5. 四个 snoop FSM 独立跟踪 AC、CR 和可选 CD。
6. 主 FSM 有 14 态，复杂事务可能多次访问 L2，并可能访问外部内存。
7. `set_cp/clr_cp` 是送给 L2 的更新请求，不是本地状态已经改变。
8. 年龄向量实现局部 oldest-requester 选择，不等于无条件全局公平。
9. 地址依赖比较 PA[13:6] 的低 line 索引，正确但保守，可能产生别名串行化。
10. 当前 RTL 展示 ACE 风格请求、shared/unique、dirty/clean 和 cp 维护，但不能
    仅凭 CIU 文本断言存在一个显式完整 MOESI/O 状态实现。
11. `snpext/CR` 是保留结构；当前 EBIU snoop dummy、CR/CD tie-off 和
    `ebiu_cr_done=0` 共同表明外部 snoop 功能未完成。
