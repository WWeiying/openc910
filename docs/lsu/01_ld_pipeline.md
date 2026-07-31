# C910 Load 管线详解（ld_ag / ld_dc / ld_da / ld_wb）

> RTL 源文件：
> - `ct_lsu_ld_ag.v`（1462 行）— 地址生成
> - `ct_lsu_ld_dc.v`（1848 行）— cache 访问与依赖检查
> - `ct_lsu_ld_da.v`（2739 行）— 数据装配（全管线最复杂的一站）
> - `ct_lsu_ld_wb.v`（1259 行）— 写回仲裁
>
> Pipe3 在文档中按 AG、DC、DA、WB 四个可见接口阶段讲解。不能仅凭“四级”
> 就把命中延迟固定写成“发射后 4 拍”：起点是 IDU 选择、RF 接受还是 AG
> 寄存器，终点是 WB 请求、PRF 写使能还是消费者可发射，会得到不同数字；
> restart、borrow 仲裁和写回口竞争也会改变实际延迟。源码中虽保留 ECC
> stall/error 接口，但当前生成 RTL 将相关信号绑为 0，不能把 ECC stall
> 计入当前配置的实际命中延迟。

---

## 1. AG 级（ct_lsu_ld_ag.v）

### 1.1 虚地址生成（L785-835）

普通路径形成 `va_ori = base + shifted_offset`。对需要跨 16B 窗口拆分的访问，
RTL 还形成 `va_plus = base + sign_extend(offset_plus[12:0])`，并在
`boundary_unmask && ld_inst && !secd && !ldr` 时选择它；第二段 `secd`
则回到 `va_ori` 路径。这里的 `offset_plus` 是 IDU 预先生成并编码传入的
13-bit 偏移，不能仅根据源码注释中的“+128”擅自换算成“固定 +16B”。

从体系结构上看，关键不是记住某个未经证明的常数，而是理解两组地址各自的
职责：一组用于当前被拆分子访问，另一组保留原访问的 16B 窗口基准，使
`bytes_vld`、旋转选择和第二段地址仍能对应同一条体系结构指令。

### 1.2 非对齐与字节有效（L837-986）

按访问宽度（1/2/4/8/16B）和 VA 低位生成 `bytes_vld[15:0]`（16 字节窗口内
哪些字节属于本次访问）。bytes_vld 是后面所有依赖比较的"通用语言"：SQ 前递、
LQ 违例检查都按字节位图相交判断重叠（见 03/04），比按地址范围比较精确得多。
跨 16B 边界 → unalign，置 `LDST Unaligh Access` 计数并触发两段式执行。

### 1.3 MMU 翻译（L1032-1105）

AG 级把 VA 和访问属性送 MMU 接口（`lsu_mmu_va*`），并使用
`mmu_lsu_pa0_vld`、页号和页属性决定本次地址是否可继续。dTLB 命中时，
MMU 可以在该流水接口预算内及时给出物理页号；文档不把它简化成对所有条件都
成立的“固定下拍返回”。TLB busy/miss、页表遍历、异常和跨页拆分会走不同的
restart/stall 路径。

`ld_ag_pa = {ld_ag_pn, ld_ag_va[11:0]}`：高位来自 MMU 给出的物理页号，
低 12 位保留页内偏移。后续 cache、LQ/SQ 和总线相关比较使用该物理地址。

### 1.4 dcache 请求（L1122-1198）

AG 级形成 tag/data 阵列请求，但实际送给 tag SRAM 的索引是
`ld_ag_pa[14:6]`；data 索引也来自 PA。因此当前有效 RTL 的 D-cache SRAM
接口应描述为 PIPT，而不是 VIPT。`ag_dcache_arb_ld_req` 为时序目的没有把
`mmu_lsu_pa0_vld`直接并入请求条件，这意味着波形中可能看到“阵列请求已经
拉起、但本条指令随后因翻译/异常/restart 失效”的情况。请求发生不等于该
次读数最终被 DA 级作为有效 load 数据消费。

### 1.5 stall/restart（L1244-1338）

- **跨 4K/拆分 stall**：跨页访问的两个子访问可能需要分别完成翻译和异常
  判定，相关 immediate stall/restart 条件会阻止错误页号被直接复用。具体
  发生次数应读取当前运行的计数器，不能把某一次运行中的固定数值当成结构参数；
- restart 类型打包回 IDU 的 LSIQ（L1410）：指令不死，回发射队列等条件
  满足再来——LSU 大量采用"restart-replay"而非"stall-in-place"，
  保持管线不被单条指令卡死。

## 2. DC 级（ct_lsu_ld_dc.v）

### 2.1 创建 LQ 项（L1281-1324）

不是每条出现在 DC 接口上的操作都会无条件占用 LQ。`ld_dc_lq_create_dp_vld`
要求本拍是有效普通 load，并排除 old、SO 页、uTLB miss、已存在同 IID/同
分段记录以及指定异常；真正的 `create_vld` 还屏蔽立即依赖重启和 addr1 依赖
discard。非对齐加速路径需要时可再创建第二项。源码注释
`lq_create_vld is not accurate, comparing iid is a must`提醒下游仍须用 IID
确认同一条在飞指令，不能只看较宽松的数据通路/门控条件。每个成功表项保存
PA[39:4]、`bytes_vld[15:0]`、IID 和分段标志，供后续顺序违例检测使用
（见 03_lq.md）。

### 2.2 依赖检查发起（L1325-1432）

DC 级把本 load 的 PA/bytes_vld 广播给 SQ 和 WMB 的每一项做**逐项比较**
（实际比较逻辑在 sq/wmb entry 内，L1403-1405 注释）。比较结果分三档：

| 结果 | 含义 | 动作 |
|------|------|------|
| 无重叠 | 无依赖 | 正常走 cache |
| 重叠且数据就绪且完全覆盖 | 可前递 | DA 级取 SQ/WMB 数据 |
| 重叠但数据未就绪/部分覆盖 | 真依赖没法转发 | **discard**：load 回 LSIQ 重发（perf 的 `LSU SQ (Data) Discard`） |

同时接受 **st_dc 的 RAW 反查**（L1351-1353 注释：同拍在 DC 级的 store 要
检查正在 DC 的 load——管线内同拍指令的依赖在这里就地解决）。

### 2.3 取数请求（L1554-1742）

地址低位和访问宽度共同决定 bank 使能与后续数据偏置选择。D-cache 顶层共有
8 个 `2048×32 bit` data array：bank0~3 构成 low 128-bit 组，bank4~7
构成 high 128-bit 组；way 选择被编码进 11-bit data index/后续选择关系中，
不是“每个 bank 同时读出两个 way 的 64-bit 数据”。DC 级还准备 PFU 训练
信息以及 borrow/cache-buffer 路径所需的元数据。

## 3. DA 级（ct_lsu_ld_da.v）—— 数据从五个来源汇聚

### 3.1 命中判定与数据选择（L1707-2011）

```
tag 比较（两路）──┐
                  ├─ cache 命中数据或 SQ/WMB 前递数据
SQ/WMB 前递数据 ──┘        ↓
                    数据规整 + 符号扩展（L1971-2011）→ 64 位结果
```

前递数据优先于 cache 数据（store 还没写进 cache，SQ 里才是最新值）。

当前生成 RTL **没有启用 D-cache ECC 解码**。`ct_lsu_ld_da.v` 中 8 个
`ct_lsu_32bit_ecc_decode` 实例均处于注释状态，实际 data SRAM 仍是
`2048×32 bit` 原始数据宽度；`ld_da_ecc_stall`、`ld_da_lm_ecc_err`、
`ld_da_mcic_data_err`、`ld_da_fwd_ecc_stall` 等接口被绑为 0。源码保留这些
接口和模板，说明设计框架考虑过 ECC 配置，但“接口存在”不等于当前 RTL 已有
纠错、报错或重读行为。

### 3.2 miss 走 RB（L2012-2165）

miss（或 NC 访问）→ 申请 read buffer 项。L2149 的"compare index"处理
corner case：**同 index 的访问不许同时在飞**（refill 时会撞 way 选择），
撞上则 discard 重发。RB 满同样 discard。
此级还产生 L1D miss 的 hpcp 计数（event13 的源头）。

### 3.3 spec fail 汇总与 restart（L2180-2264）

LQ 反馈的 RAR/RAW 违例、bkpt 等在此形成送往 WB 的恢复/完成元数据，WB 再
通过 `lsu_rtu_wb_pipe3_spec_fail` 等接口交给 RTU。注意 spec fail 不是
LSU 自己完成的体系结构 trap；它进入 RTU 的异常/恢复仲裁，在精确点触发
flush/replay。参见 [03_rob_expt.md](../rtu/03_rob_expt.md) 与
[04_retire.md](../rtu/04_retire.md)。

### 3.4 borrow 机制（L2462）

refill、snoop、victim、ICC、MMU/PTW 等内部事务可以通过 borrow 接口复用
load 管线的阶段寄存器或数据处理通路。不能把它统一解释成“只借空拍”：
不同来源先在对应资源上请求和仲裁，选中后形成 `borrow_vld`，并可能与正常
指令的 stall/restart 条件互锁。分析波形时应同时看来源 request、资源
select/grant、`ld_dc_borrow_vld` 及具体 `borrow_*` 类型，才能判断本拍是利用
气泡还是占用了指令原本可能使用的资源。

## 4. WB 级（ct_lsu_ld_wb.v）

### 4.1 写回仲裁（L507-689）

pipe3 的完成与数据部分分别仲裁。完成请求可来自 DA 或 RB；数据请求可来自
DA、WMB、VMB、RB。WB 级仲裁并寄存后统一走
`lsu_idu_wb_pipe3_wb_preg_*` 写 PRF、`lsu_rtu_wb_pipe3_*` 报完成。

**miss load 的完成/数据分离**：普通 cacheable load 可在 DA 侧生成
`ld_da_wb_cmplt_req`，由 WB 完成寄存器在后续时钟沿接收，再通过
`lsu_rtu_wb_pipe3_cmplt`通报 RTU；miss 数据则可由 RB 在以后单独申请
data 仲裁并写回。这里“DA 先报”指请求来源和逻辑先后，不表示 DA 组合信号
未经 WB 寄存器直接连到 RTU。

### 4.2 二次符号扩展（L1050-1077）

RB 返回的数据未经过 DA 的规整通路，WB 级备一份 settle+sign extend 逻辑。

---

## 5. 一条 load 的理想时间线（命中/前递/miss 三景）

```
   RF/AG 接收       DC                 DA                  WB
命中: 地址/MMU+阵列请求  地址/依赖与阵列输出传递  命中判定+选数       完成/数据仲裁并寄存
前递: 地址/MMU          SQ/WMB并行比较            选择前递数据        完成/数据仲裁并寄存
miss: 地址/MMU          tag路径                    miss→RB创建请求     完成可先进入WB
                                   ↓
                         BIU返回可用数据 → RB申请WB数据口
```

这张图只表达“无 restart、无仲裁冲突”时的接口顺序，不承诺固定拍数。当前
配置的 ECC stall 固定为 0；若以后启用另一 ECC 配置，才需要把纠错/重读延迟
重新纳入时间线。SQ/WMB 前递与 cache 命中共享 DA/WB 后半段，因此目标是避免
等待 store 真正写入 D-cache；它是否与某次 cache hit 完全同拍完成，应以
该次波形中的 DC/DA 有效信号和 WB grant 为准。

## 6. Verdi 观察建议

| 信号 | 看什么 |
|------|--------|
| `ld_ag_dc_inst_vld / ld_dc_da_inst_vld / ld_da_wb_inst_vld` | 流水推进与气泡 |
| `ld_ag_pa` vs 反汇编的访存地址 | 地址正确性 |
| DA 级 cache/SQ/WMB 选择信号 | 前递发生的拍 |
| `lq_create_vld`、SQ 的 discard 信号 | 依赖三档结果 |
| RB 创建 + `lsu_rtu_wb_pipe3_cmplt` 早于数据写回 | miss 的完成/数据分离 |

选择能稳定制造 miss 的 stride 工作集和含 store→load 重叠的微基准对比最
直观。开始分析前应先用反汇编或动态 trace 确认编译器确实保留了目标访存模式，
不能仅凭 benchmark 名称推断波形中一定存在大量 miss 或前递。
