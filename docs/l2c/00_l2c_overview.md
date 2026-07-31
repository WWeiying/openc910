# C910 L2C 总体架构详细教学文档

> RTL 目录：`C910_RTL_FACTORY/gen_rtl/l2c/rtl/`
>
> 配置文件：`C910_RTL_FACTORY/gen_rtl/cpu/rtl/cpu_cfig.h`
>
> 本文以仓库当前启用的 `L2_CACHE_16WAY + L2_CACHE_1M` 配置为准。文中明确区分“本配置的 RTL 事实”“由接口可见的架构职责”和“尚未在开源 RTL 中实现的预留框架”。

## 目录

- [1. L2C 的位置和职责](#1-l2c-的位置和职责)
- [2. 物理组织与地址位映射](#2-物理组织与地址位映射)
- [3. 顶层接口与握手语义](#3-顶层接口与握手语义)
- [4. 主访问流水与旁路引擎](#4-主访问流水与旁路引擎)
- [5. 一致性状态和侦听过滤](#5-一致性状态和侦听过滤)
- [6. 典型事务的完整过程](#6-典型事务的完整过程)
- [7. 维护、DCA、预取和 flush](#7-维护dca预取和-flush)
- [8. 实现边界与设计取舍](#8-实现边界与设计取舍)

---

## 1. L2C 的位置和职责

### 1.1 它位于哪里

L2C 位于 CIU 之后。核侧请求先进入 PIU/SNB，由 CIU 完成事务排队、侦听路由、下级内存访问和数据汇聚，再通过两组按 sub-bank 分开的接口访问 L2C。

```text
核内 IFU/LSU
    |
    v
PIU / CIU / SNB
    |  根据物理地址 PA[6] 选择 L2 sub-bank
    +--------------------+--------------------+
    |                                         |
    v                                         v
L2 sub-bank 0                            L2 sub-bank 1
tag -> cmp -> data -> wb                 tag -> cmp -> data -> wb
    ^                                         ^
    |                                         |
    +------ 各自的 ICC 维护/DCA 引擎 ----------+

两路 cmp miss 观察信号 -> 一个共享的 next-line prefetch 引擎 -> CIU/SNB
```

这里的两个 sub-bank 是**缓存地址分片**，不是“两颗核”。`cp[3:0]` 和 CIU 的四路 PIU 接口表明一致性存在位宽为 4 的参与者位图；具体 SoC 实例启用了几个核/PIU，应由顶层配置和集成连线判断，不能由“两路 L2 bank”反推为“两核”。

### 1.2 它负责什么

当前 L2C RTL承担以下职责：

1. **统一二级缓存**：本配置为 1 MiB、16 路组相联、64 B cache line。
2. **保存一致性元数据**：每路保存 `valid/shared/dirty/pend` 和 `cp[3:0]`。
3. **向 CIU 返回目录信息**：命中时把命中路的 `cp[3:0]`、shared、dirty 等编码到响应中。
4. **为替换提供 victim 和占位状态**：用 16 位轮转式替换选择字段和 `pend` 位串联 allocate、victim 清理、refill/release。
5. **处理整缓存维护**：ICC 引擎遍历本 sub-bank 的全部 set，执行失效，或先下推脏行再失效。
6. **提供 DCA 诊断读通路**：可按 way/index 读取 tag/status、128 位 data 分片或 ECC 占位值。
7. **产生简单硬件预取**：观察 IFU/TLB 来源的 L2 读 miss，产生不跨 4 KiB 页的 next-line 请求。

L2C 不应被描述为独立完成全部一致性协议。它保存并返回目录状态；CIU/SNB 根据返回状态、事务类型和发起者掩码决定是否以及向哪些 PIU 发侦听，并负责普通 miss 的下级取数与后续整行写入。

---

## 2. 物理组织与地址位映射

### 2.1 当前配置

`cpu_cfig.h` 当前启用：

| 配置项 | 当前值 | 直接含义 |
|---|---:|---|
| `L2_CACHE_16WAY` | defined | 16 路组相联 |
| `L2_CACHE_1M` | defined | 总容量 1 MiB |
| `L2C_TAG_INDEX_WIDTH` | 9 | 每个 sub-bank 512 个 local set |
| `L2C_TAG_DATA_WIDTH` | 24 | tag 为 24 位 |
| `L2C_DATA_INDEX_WIDTH` | 13 | data SRAM 深度索引为 13 位 |

容量关系为：

```text
总行数       = 1 MiB / 64 B = 16384
全局 set 数  = 16384 / 16   = 1024
每 sub-bank  = 1024 / 2     = 512 set
每 sub-bank 的 data 行槽 = 512 set * 16 way = 8192
```

因此每个 sub-bank 包含：

- 16 路 tag，单路 tag 为 24 位，local set 深度为 512；
- 一份 512 x 144 bit 的 status/replacement 阵列；
- 4 份 8192 x 128 bit 的 data 阵列，四份同地址读出后组成 512 bit，即 64 B。

### 2.2 地址不是哈希分 bank

普通缓存请求在 CIU 中按物理地址 `PA[6]` 直接选择 L2 sub-bank：

- `PA[6] = 0`：sub-bank 0；
- `PA[6] = 1`：sub-bank 1。

CIU 送入某个 sub-bank 的 `ciu_l2c_addr_x[32:0]` 是 `PA[39:7]`。因此必须把“接口内地址”和“完整物理地址”分开看：

```text
完整物理地址 PA[39:0]

PA[39:16]  24 bit tag
PA[15:7]    9 bit local-set index，送入选中的 sub-bank
PA[6]       1 bit sub-bank select，由 CIU 路由，不包含在 addr_x[32:0] 中
PA[5:0]     6 bit 64 B 行内偏移，L2 行级请求中不传递
```

合起来，全局 set index 是 `PA[15:6]` 共 10 位；L2C 内部则把其最低位 `PA[6]` 转化为“选择哪一个 sub-bank”，每个 sub-bank 只看到其余 9 位 `PA[15:7]`。

这也解释了三个看似矛盾的数字：

- 全局有 1024 set；
- 每份 tag/status SRAM 只有 512 深；
- 内部普通地址只有 33 位。

33 位内部地址不能笼统写成“40 位 PA 去掉 7 个低位”而不说明 bank 位。它确实等于 `PA[39:7]`，但完整 cache-line 编号 `PA[39:6]` 还需要把 sub-bank 选择位 `PA[6]` 拼回去。

### 2.3 Data SRAM 索引

data SRAM 不以 tag 作为索引。其 13 位索引为：

```text
data_index[12:9] = way[3:0]
data_index[8:0]  = local_set = PA[15:7]
```

所以单个 128 位 data 阵列的 8192 个地址恰好覆盖 `16 way * 512 set`。四个 128 位阵列在普通读写中使用相同的 data index，分别存放一条 64 B cache line 的四个 16 B 分片。

---

## 3. 顶层接口与握手语义

### 3.1 主要接口

| 接口组 | 代表信号 | 精确语义 |
|---|---|---|
| 地址请求 | `ciu_l2c_addr_vld_x`, `ciu_l2c_addr_x`, `ciu_l2c_type_x` | CIU 正在提出一个普通 L2 地址事务 |
| 地址接收 | `l2c_ciu_addr_ready_x` | 当前拍该地址事务被 tag 入口接受 |
| 写数据 | `ciu_l2c_data_vld_x`, `ciu_l2c_wdata_x` | 与已有事务关联的 512 位整行写数据 |
| 数据接收 | `l2c_ciu_data_ready_x` | 当前拍 L2C 能接收该写数据 |
| 完成 | `l2c_ciu_cmplt_x` | 先前已接收事务的响应在当前拍有效 |
| 响应内容 | `l2c_ciu_resp_x`, `l2c_ciu_cp_x`, `l2c_ciu_sid_x` | 响应状态、presence 位图和 source ID |
| 读数据 | `l2c_ciu_data_x[511:0]` | 带数据响应的整条 cache line |
| victim 清理请求 | `l2c_ciu_snpl2_*` | allocate 选中有效 victim 后，请 CIU/SNB执行 CleanInvalid |
| 维护脏行下推 | `l2c_ciu_rdl_*` | ICC clean/flush 遍历时向 CIU 下推一条脏行 |
| 预取 | `l2c_ciu_prf_*` | 共享预取器向 CIU/SNB提出 next-line 预取 |
| CTC/DCA | `ciu_l2c_ctcq_req_x`, `ciu_l2c_dca_req_x` | 整 sub-bank 维护请求或诊断读请求 |

### 3.2 Request、accept 和 complete 不是同一个事件

普通地址请求的接收条件为：

```verilog
l2c_ciu_addr_ready_x = ciu_req_vld && !tag_stage_stall;
```

其中 `ciu_req_vld` 还要求 ICC 空闲、ECC 写回 FIFO 空、cmp 没有占用 tag 写端口，并通过局部地址冲突检查。因此：

1. `ciu_l2c_addr_vld_x=1` 只说明 CIU 在提出请求；
2. 同拍 `l2c_ciu_addr_ready_x=1` 才说明 L2C 接收了请求；
3. 请求经过 tag/cmp，必要时再经过 data/wb；
4. 后续某拍 `l2c_ciu_cmplt_x=1` 才是事务完成响应。

波形分析时，不能用 `addr_vld` 的上升沿代替“请求进入”，也不能用 `addr_ready` 代替“命中数据已经返回”。

### 3.3 入口冲突比较的准确含义

`ct_l2c_tag` 用新请求内部地址的低 7 位，与 tag/cmp/data 中在途请求的相应低 7 位比较：

```text
addr_x[6:0] = PA[13:7]
```

这只是一个**局部、保守的 SRAM 地址冲突屏障**。它既没有比较完整 tag，也没有比较完整 9 位 local-set index，所以不能称为“完整同地址检测”或“精确同 set 检测”。两个仅在 `PA[15:14]` 不同的请求也可能因低 7 位相同而被串行化。其作用是避免当前实现的共享 SRAM/流水更新发生危险，而不是判定 cache hit。

---

## 4. 主访问流水与旁路引擎

### 4.1 普通请求的主路径

普通带数据访问的逻辑路径是：

```text
tag / tag-read completion -> cmp -> data -> wb
```

| 阶段 | 主要 RTL | 职责 |
|---|---|---|
| tag | `ct_l2c_tag` | 接收请求，访问 tag/status SRAM，等待可编程访问计数完成，比较 16 路 tag，产生命中向量和替换相关信息 |
| tag ECC 边界 | `ct_l2c_tag_ecc` | 当前开源版把 tag/status 直通并将 fatal error 置 0；仍保留独立的结构和信号命名 |
| cmp | `ct_l2c_cmp` | 归约 hit/miss，选中命中路或 victim，计算 status 更新，产生 data 访问、纯响应、预取观察和 victim 清理请求 |
| data | `ct_l2c_data` | 访问四份 data SRAM，等待可编程访问计数完成，锁存 512 位读数据和随路响应信息 |
| wb | `ct_l2c_wb` | 在带数据响应与纯响应 FIFO 之间仲裁，输出 `cmplt/resp/cp/sid/data` |

“tag/cmp/data/wb”描述的是逻辑阶段，不等于每级固定一拍。tag 和 data 都有可编程访问计数器，`setup` 还决定 SRAM 控制是否先锁存一拍；后级反压也会使级寄存器保持。

### 4.2 ICC 不是普通流水的第五拍

`ct_l2c_icc` 与主路径并列实例化。普通 hit/miss 请求不会在 wb 后再进入 ICC。ICC 只处理：

- CTC 整 sub-bank 维护；
- reset 引起的整 sub-bank 失效；
- SoC flush；
- DCA 诊断读取。

ICC 只有在 `l2c_pipeline_rdy=1` 时才能开始。这个条件要求 tag、cmp、data、wb 和响应 FIFO 都为空。ICC 开始后，`icc_idle=0` 又阻止新的普通地址请求进入。因此更准确的说法是：

> ICC 等主流水排空后接管 tag/status/data 阵列端口；完成后释放端口。它是互斥的维护/诊断引擎，不是普通数据流水中的一级。

---

## 5. 一致性状态和侦听过滤

### 5.1 每路状态

每个 way 的 8 位状态编码为：

```text
status[7:0] = {cp[3:0], valid, shared, dirty, pend}
```

| 位 | 含义 | 不应误解为 |
|---|---|---|
| `cp[3:0]` | 四个一致性参与者的 presence 位图，由 CIU 请求置位/清位，命中时返回 CIU | L2C 内部直接发往四个核的 snoop valid |
| `valid` | tag/data 行在 L2 中有效 | 该行一定也存在于某个 L1 |
| `shared` | L2 保存的 shared/unique 属性；0 表示 RTL 命名中的 unique | 完整 MOESI 状态编码 |
| `dirty` | L2 数据相对下级存储层为脏 | 某个 L1 一定脏 |
| `pend` | 该 way 已被 allocate 占位，相关 refill/release 尚未收尾 | 一般意义的“所有未完成请求”计数 |

这是一个 MESI 风格的压缩状态表示，但 RTL 没有单独保存完整的 `M/E/S/I` 枚举，更没有独立的 owner 位。因此文档应描述具体 bit 及其使用方式，不应简单宣称这是完整 MOESI 编码。

### 5.2 `cp` 如何成为 snoop filter

侦听过滤跨 L2C 与 CIU 两个模块完成：

1. L2C 命中时从命中 way 选择 `cp[3:0]`，随响应返回 CIU/SNB。
2. CIU 的 SAB entry 锁存该位图。
3. CIU 再应用发起者掩码、SMP enable 和 snoop-filter disable 条件，得到 `cp_after_mask`。
4. `snp_req_en[3:0] = {4{snp_req_vld}} & cp_after_mask[3:0]`，按位产生对四路 PIU 的 snoop 请求。

所以“L2 的 cp 目录过滤侦听”是正确的系统级结论；但把“按 cp 产生每核 snoop”写成 `ct_l2c_cmp` 本地完成则不准确，实际逐 PIU 路由逻辑位于 CIU。

### 5.3 `snpl2` 是另一条路径

`l2c_ciu_snpl2_*` 由 allocate 选中一个当前有效的 victim 时触发。L2C 提供 victim 的旧 tag、当前 local-set 和原事务 SID；CIU 把 sub-bank 位拼回完整行地址，并构造 `CleanInvalid` 事务交给 SNB。

因此 `snpl2` 的精确含义是“为 L2 victim 腾位置而发起的 CleanInvalid 事务”，不是每次一致性请求都使用的通用逐核 snoop 接口，也不是由 victim 的 `cp` 在 L2C 内直接选择目标核。

---

## 6. 典型事务的完整过程

### 6.1 读命中

```text
1. CIU 保持 addr_vld、地址和 type=read。
2. L2C 满足入口条件，addr_ready 拉高；请求在该时钟边沿进入 tag stage。
3. tag/status SRAM 读取选中 local set 的全部 16 路。
4. tag 访问计数归零后，把 PA[39:16] 与 16 路 tag 并行比较，再与 valid 相与。
5. cmp 归约命中向量，选择命中 way，形成 data_index={way, PA[15:7]}。
6. data SRAM 读取四个 128 位分片。
7. data 访问计数归零后锁存 512 位整行。
8. wb 输出 cmplt=1，并同时给出 sid、resp、cp 和 512 位 data。
```

第 2 步是“请求接收”，第 8 步才是“请求完成”。中间所需周期由 tag/data 的 setup、latency 配置和流水反压共同决定。

### 6.2 读未命中

读 miss 在 cmp 级生成一个**不带数据的 miss 响应**并进入 3 深 rfifo，随后由 wb 输出给 CIU。L2C 本模块没有因为普通 read miss 而通过 `l2c_ciu_rdl_*` 发出下级读请求。

后续下级访问由 CIU/SNB 的事务状态机发起。数据返回并在 CIU/SNB 形成完整 512 位行后，再通过 L2 write/allocate/refill 相关协议写入 L2C。因而普通 miss 的责任边界是：

```text
L2C：查 tag -> 报告 miss/状态
CIU/SNB：侦听、访问下级、汇聚整行、组织 allocate/write/release
L2C：记录 pend、清理 victim、安装新 tag/status/data
```

### 6.3 写命中和整行写

L2 数据输入固定为 512 位。cmp 只有在相应写事务有效且 `ciu_l2c_data_vld_x` 到达后，才允许 `data_wr` 成立。写类型决定新行的 shared/dirty 属性：

- `write_ud` / `write_sd` 置 dirty；
- `write_uc` / `write_sc` 清 dirty；
- `write_sd` / `write_sc` 置 shared；
- `write_ud` / `write_uc` 清 shared。

写命中更新命中 way；写 miss 被 RTL 命名为 `cmp_stage_refill`，使用此前 allocate 产生的 `!valid && pend` way 安装 tag 和状态，并在同一协议阶段清除 pend。

### 6.4 Allocate、victim 清理和 refill

allocate 首先由 `l2c_way_fifo` 选择 victim：

- victim 无效：可直接给该 way 置 pend；
- victim 有效：先提出 `snpl2`，待 CIU 接受后才允许置 pend；
- refill/release 不重新按 FIFO 选路，而是从 `!valid && pend` 中优先编码出 `cmp_refill_ptr`。

这说明 `l2c_way_fifo` 和 `cmp_refill_ptr` 不是同一个概念：

- 前者选择“本次 allocate 要占用哪个 victim”；
- 后者寻找“此前已经占位、现在等待 refill 或 release 的 way”。

这里存在一个必须明确的系统协议前提：pending way 只保存一位 `pend`，没有保存
未来新 tag、SID 或返回次序。若 refill/release 到来时没有
`!valid && pend` 候选，L2C 不会自动阻塞或报错；写 refill 的 data way 解码还会
回落到 way0，而 tag/status 没有 way 可写。若同一 set 有多个候选，也只选择最低
编号 way。因此上游必须保证 allocate 与后续 refill/release 的同 set 顺序能够
由该规则唯一对应，并用断言检查每次 refill/release 恰有一个候选。

---

## 7. 维护、DCA、预取和 flush

### 7.1 ICC 整体维护

每个 sub-bank 的 ICC 遍历 512 个 local set。

- `inv_all` 路径直接把每组 tag/status 失效，不读出并下推脏数据；
- `cln_all` 路径先读 tag/status，保存 valid/dirty 快照，把该组 status 清零，再逐个读取快照中的有效脏 way 并通过 `RDL` 下推；正常无 fatal error 时旧 tag 位可以留在 SRAM，但因 valid 已清零而不再命中；
- SoC `flush_req` 同时令 `inv_all=1` 和 `cln_all=1`，实际走 `cln_all` 的“写回脏行后失效”路径；
- reset 请求走不回写的整体失效路径。

需要特别注意：在当前开源 RTL 中，`cln_all` 的 `STATUS_UPDT` 会把 status 写为 0；tag 只有在纯 `ICC_INV` 或 fatal-error 清理条件下写 0。无论旧 tag 位是否保留，`valid=0` 都使该行逻辑失效。因此它不是“写回后保留有效行”的 clean-only 实现，而是“保存脏状态、使该组失效、再把脏数据下推”的整体维护。

`l2c_ciu_rdl_*` 仅在 ICC 的 `WAIT_RDL` 状态有效，代表维护过程的脏行下推。`rdl_rvld` 和 `rdl_dvld` 同时有效，CIU 的 `rdl_ready` 才表示该行被接收。

### 7.2 DCA

DCA 请求编码可选择：

- tag/status；
- 128 位 data 分片；
- tag ECC；
- data ECC。

当前 RTL 只有读取返回路径，没有从 CIU 输入 DCA 写数据的端口，也没有 DCA 写 SRAM 的控制。因此准确表述是“直接诊断读取”，不能写成“DCA 读写/注入缓存”。

tag/status 返回值由 tag、部分 index 和 8 位 status 拼成 128 位；data 返回值由 `offset[1:0]` 从 512 位行中选择一个 128 位分片；两个 ECC 类型在当前开源实现中恒返回 0。

### 7.3 Next-line 预取

共享预取器把某个 sub-bank 的内部地址和 bank 位重新拼成：

```text
{addr_x[32:0], bank_bit} = PA[39:6]
```

这个 34 位值是以 64 B cache line 为单位的地址。对它加 1，物理地址正好前进 64 B，而不是 1 B。

该 line-number 的 bit 6 对应原物理地址 `PA[12]`。当前值与 `+1` 后的 bit 6 异或，可以检测 64 条 cache line，即 4096 B 边界是否发生翻转。预取器据此避免跨 4 KiB 页。

两个 bank 同拍候选时，实际地址选择偏向 bank1，但 `bank1_sel`的条件比
`pref_en_1`更宽：它没有检查 read，也没有检查对应 `iprf/tprf`使能。若
bank0 提供真正的有效触发，而 bank1 只满足较宽的 valid/miss/source 条件，
整体使能可能来自 bank0、地址却取自 bank1。系统协议可能约束这些信号成组
出现，但 L2C 预取模块本身没有断言该约束；这应作为双 bank 并发定向验证项。

预取输出采用 valid/ready 语义：`l2c_ciu_prf_vld` 表示请求有效，只有 `ciu_l2c_prf_ready` 才令地址和计数推进。不能把 valid 单独当作一次预取已经发出。

### 7.4 SoC flush 顶层握手

顶层 flush FSM 有 `IDLE/REQ/WAIT_1/WAIT_0/DONE` 五态：

1. 仅在 `sysio_l2c_flush_req && ciu_xx_no_op` 时从 IDLE 接受请求；
2. REQ 同时向两个 sub-bank 保持 `l2c_flush_req_bank_0/1`；
3. 某 bank 先完成后进入对应 WAIT 状态，只等待另一个 bank；
4. 两 bank 都完成后进入 DONE，`l2c_sysio_flush_done=1`；
5. 请求方撤销 `sysio_l2c_flush_req` 后才回到 IDLE。

`ciu_xx_no_op` 是 flush 的接收前提；它不是 flush 完成条件。两 bank 的 `flush_done` 才决定从 REQ/WAIT 进入 DONE。

---

## 8. 实现边界与设计取舍

| 主题 | 当前 RTL 事实 | 分析边界 |
|---|---|---|
| Banking | `PA[6]` 直接选择两个 sub-bank | 不是哈希；两 bank 也不等于两核 |
| 主流水 | tag/cmp/data/wb，tag/data 延迟可配置 | 逻辑级数不等于固定拍数 |
| ICC | 排空后接管阵列的维护/DCA 引擎 | 不是普通访问的第五级 |
| 普通 miss | L2C 返回 miss，CIU/SNB完成下级访问 | `RDL` 不是普通 miss read |
| 目录 | L2C 保存并返回 `cp[3:0]` | 最终逐 PIU snoop enable 在 CIU 产生 |
| victim 清理 | `snpl2` 触发 CIU/SNB CleanInvalid | 不等同于通用 cp-filtered snoop 接口 |
| 替换 | 16 位轮转式选择并跳过 pending way | 不是真 LRU；不能仅凭字段名断言任意时刻严格 one-hot |
| 命中唯一性 | 16 路比较向量直接被 cmp 消费 | 无 multi-hit 检测；同 set 同 tag 至多一个 valid way 必须由协议和验证保证 |
| refill 关联 | 从 `!valid && pend` 中选择最低编号 way | pending 不保存 SID/新 tag；找不到候选也不报错，必须保证 allocate→refill/release 顺序 |
| HPCP | 上游标记的首次 L2 读/写 access 与其中的 miss，按 MID 归属 | 不是全部内部 L2C 操作，也不直接给出延迟、并发度或预取有效性 |
| ECC | tag/status 纠错逻辑旁路，data/tag ECC SRAM 未实例化，fatal 恒 0 | 信号和注释体现预留意图，不等于当前具备 ECC 保护 |
| DCA | 直接读取 tag/status/data/ECC 占位值 | 当前没有 DCA 写入/注入路径 |
| 纯响应 FIFO | 14 bit x 3 entries | `rfifo_full` 未反馈到 create 逻辑，依赖上游协议保证不溢出 |
| 参数化容量 | `cpu_cfig.h` 声明多种容量/路数宏 | 每种组合仍须核查数组 wrapper 是否有对应实例，不能只因宏存在就宣称全部配置已验证 |

最后一项尤其值得注意：当前 16-way dirty/status wrapper 从 256 KiB 配置开始提供实例，没有 `L2_CACHE_128K` 分支。因此“同一 RTL 已完整支持 16-way 128 KiB 到 8 MiB 所有组合”并不能由宏表推出。本文只对当前 1 MiB/16-way 组合给出确定结论。

---

*分篇阅读：`01_l2c_tag_status.md` 解释 tag/status、命中与替换；`02_l2c_data.md` 解释 data 阵列与访问时序；`03_l2c_pipeline.md` 解释 cmp、sub-bank 和顶层协议；`04_l2c_prefetch_icc_wb.md` 解释预取、维护、DCA 与响应输出。*
