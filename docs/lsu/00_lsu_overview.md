# C910 LSU 总览（ct_lsu_top）

> RTL 源文件：`C910_RTL_FACTORY/gen_rtl/lsu/rtl/ct_lsu_top.v`（6372 行，结构性顶层）
>
> 顶层按流水级组织例化（源码 L2794 起的分区注释即是地图）：
> AG/EX1 级 → DC 级（含 dcache_top）→ DA 级 → WB 级 → LFB/VB → Snoop → 其他。

---

## 1. 全景图

```
   IDU 发射                      IDU 发射                    IDU 发射
   pipe3(load)                  pipe4(store addr)           pipe5(store data)
      │                            │                            │
 ┌────▼────┐                  ┌────▼────┐                  ┌────▼────┐
 │ ld_ag   │ 地址生成+MMU接口  │ st_ag   │ 同左              │ sd_ex1  │ 数据接收/配对
 ├─────────┤                  ├─────────┤                  └────┬────┘
 │ ld_dc   │ 读tag/lq sq检查   │ st_dc   │ 读tag/创建sq      数据写入 SQ
 ├─────────┤                  ├─────────┤
 │ ld_da   │ 命中/前递/数据规整  │ st_da   │ 命中及状态预查
 ├─────────┤                  ├─────────┤
 │ ld_wb   │ 写回PRF/RTU      │ st_wb   │ 完成报RTU
 └─────────┘                  └────┬────┘
                                   │ 指令退休后
                              ┌────▼────┐    ┌─────┐
                              │   SQ    ├───►│ WMB │──合并──► D-cache 写 / BIU 写
                              └─────────┘    └─────┘
   miss 路径: 符合创建条件的 ld/st miss ─► RB ─req─► BIU ─data─► LFB ─refill─► D-cache
                                                  逐出脏行: D-cache ─► VB ─► BIU
   一致性:   外部 snoop ──► SNQ ──读tag/data──► 应答/降级
   预取:     ld/st 流检测 ──► PFU(PMB/SDB/PFB) ──► 预取请求进 LFB
```

### 1.1 四级流水职责

| 级 | load(pipe3) | store(pipe4) |
|----|-------------|--------------|
| AG | 基址+偏移形成 VA；组织拆分访问；与 MMU 交互形成 PA/页属性；生成 D-cache 请求和 restart 条件 | 同类地址、翻译、异常和 cache 请求准备 |
| DC | 接收阵列输出/地址元数据；发起 SQ/WMB 依赖比较；创建 LQ 候选；参与 store 反查 | 接收 tag/状态输出；创建 SQ 候选；向 LQ 发起 RAW 检查 |
| DA | 使用 DC 形成的 tag 命中信息；cache 与 SQ/WMB 数据选择；规整/扩展；按条件创建 RB，或为跨边界 load 合并第二段 | 使用 DC 形成的 tag 比较结果和状态阵列输出完成命中/替换判定；按 write-allocate、异常和资源条件创建 RB；把预查结果回填 SQ |
| WB | 完成与数据分别仲裁、寄存，再分别通报 RTU/写 PRF | 寄存并向 RTU 报完成/异常；普通 store 数据仍留在 SQ |

**为什么 store 拆成地址(pipe4)/数据(pipe5)两条管线？** 地址早算可以让后续
load 尽早判断真实地址依赖；地址仍未知时，年轻 load 可能被 no-spec 机制
约束，也可能推测越过并由 LQ 在以后检测冲突。数据路径不需要再做地址翻译和
tag 查询，所以可以更短，但数据迟到仍可能让重叠 load discard/replay，并使
已提交 SQ 项等待数据。地址/数据解耦的价值是允许两部分按各自依赖独立调度，
不是“数据何时到都无所谓”。

### 1.2 队列家族：一条 store 的旅程

```
执行期(推测): st_ag/dc/da 走完 → 地址+数据躺在 SQ（12项）
退休(提交):   RTU retire → SQ 项标记 commit → 弹出进 WMB（8项）
写出:        WMB 合并相邻写 → 命中则写 dcache，miss/NC 则走 BIU
```

SQ 同时包含未提交和已提交但尚未转交 WMB 的项：普通后端 flush 只清
`!commit`项；WMB 主要属于已提交内存副作用域，普通推测 flush 不会丢弃其
有效写。异步 flush 仍参与部分完成/响应状态收尾，不能把“不可撤销”误解为
所有 flush 输入对 WMB 完全无作用。`lsu_rtu_all_commit_data_vld`的含义也
不是“所有提交队列都为空”，而是所有已提交 SQ 项所需 store data 均已有效
（并与 load 侧对应条件合并）。

一条 miss load 的旅程：

```
符合条件的 ld_da miss → RB 登记（8项）→ BIU 读请求 → 返回数据:
  ├─ 目标 beat 可经 RB 申请 ld_wb 数据口（不必无条件等待整行回填）
  └─ 整行进 LFB → 仲裁 dcache 写口 refill → 若逐出脏行 → VB → BIU 写回
```

这条路径不保证总线第一 beat 一定是目标字，也不表示 refill/evict 永远不影响
load；应结合请求低位、burst 组织、返回 beat、WB grant 和缓冲区满状态判断。

## 2. 顶层级联的其他模块

| 模块 | 职责 | 文档 |
|------|------|------|
| dcache_top | tag/dirty/data 阵列例化 | 07 |
| dcache_arb | 按 tag/dirty/data bank 分别仲裁指令、refill、逐出、snoop、WMB、cache 维护等请求 | 07 |
| lq/sq/wmb/rb/lfb/vb | 六大队列 | 03-06 |
| pfu | 硬件预取 | 08 |
| snoop_* | 一致性 | 09 |
| icc | cache 操作指令（dcache.cva 等） | 10 |
| lm | 原子指令 local monitor（lr/sc/amo） | 10 |
| amr | 识别连续完整 16B store 覆盖流，分级调节后续 L1/L2 写分配属性 | 10 |
| spec_fail_predict | store 地址/字节/IID 的短期冲突相关与 no-spec 命中检查；不是 PC hash 表 | 10 |
| mcic | 把 MMU/PTW 的 64-bit PTE 读取接入 D-cache、RB 和 BIU；不是 cache 失效控制 | 10 |
| bus_arb | RB/WMB/VB/PFU 抢 BIU 端口 | 10 |
| ctrl | fence/sync 全局排序控制 | 10 |
| vmb | 向量访存缓冲 | （向量部分从略） |

## 3. 正确性三大机制预览

1. **store→load 前递**（04_sq.md）：load 在 DC 级查 SQ/WMB 中"比我老、地址
   重叠、数据就绪"的 store，DA 级直接拿其数据，免去等写 cache；
2. **顺序违例检测**（03_lq.md）：更老 store/load 后到检查点时，反查到已
   建立记录的年轻重叠 load，可产生 spec fail，经 RTU 精确恢复；
3. **一致性侦听**（09_snoop.md）：外部核的读写经 CIU 侦听本核 dcache，
   SNQ 读 tag/数据并降级行状态（MESI）。

## 4. 核心机制速通（子文档精华浓缩）

> 读完本节即可对 LSU 有完整认识；源码级细节进 01~10 子文档。

### 4.1 两条管线的逐级要点（详见 01/02）

**load（pipe3）**：
- AG：形成 `va_ori`与边界访问所需的 `va_plus`，按宽度和低位生成
  `bytes_vld[15:0]`——后续一切依赖比较的"通用语言"（16B 窗口字节位图，
  用于精确表达同一 16B 地址块内的覆盖范围）；与 MMU 交互，跨页/翻译忙等
  情况可能 restart/stall；
- DC：接收以 PA[14:6] 索引的 PIPT tag/data SRAM 输出；创建 LQ 候选；
  PA+bytes_vld 广播给
  SQ/WMB 逐项比依赖；接受同拍 st_dc 的 RAW 反查；
- DA：tag/状态比较；在 cache 与 SQ/WMB 前递来源间选数并规整；满足条件的
  miss 创建 RB，跨边界 load 的第二段可合并进首段对应 RB 项；restart/discard
  条件共同决定数据是否有效。源码保留了
  ECC 接口和被注释的解码模板，但当前生成 RTL 将相关 stall/error 输出绑为 0，
  因而不能把 ECC 纠错或 ECC stall 当成当前配置的有效功能；
- WB：完成和数据分开仲裁/寄存，来源包含 DA、RB 以及 WMB/VMB 等内部路径。

**store（pipe4 地址 + pipe5 数据）**：地址早算解锁 load 依赖判断，数据
路径较短（sd_ex1 一级接口，按 sdid 匹配 SQ 项）。st_dc 创建 SQ 项并**反查 LQ**
（RAW 抓现行）；st_da 只做命中"预查"写进 SQ 项；st_wb 仅报完成——
普通推测 store 不在执行管线产生不可撤销的内存写副作用，实际写动作推迟到
提交后；管线仍会访问 tag/状态并创建 RB 等内部事务。

LSU 大量用 **restart-replay**（指令回 LSIQ 等条件满足后重发），也存在
ECC、跨页和内部资源造成的局部 stall。restart 减少一条等待指令长期占住某级
的情况，但仍会占用发射带宽并扩大完成延迟；部分 discard 通过记录等待者，在
数据到达等事件后定向唤醒。

### 4.2 store→load 前递三步协议（详见 04）

```
① ld_dc 广播 PA[39:4]+bytes_vld+iid → SQ 12 项并行比:
   比我老? 同16B? 字节相交? 数据就绪?
② 三种结论:
   可前递（满足当前单源覆盖条件，并保持最近老 store 语义）→ ③ DA 选择前递数据
   重叠但数据没到/部分覆盖 → discard: load 回 LSIQ 重发
   无关 → 走 cache
```

**部分覆盖为什么可能 replay**：load 的字节可能分布在多个 SQ/WMB 项和
cache，完整拼接会扩大逐字节多源 mux 与验证空间。当前前递通路不能可靠满足
覆盖/数据条件时会 discard；相关数据到达后可重新发射，并不一定要等待 store
落入 cache。事件是否罕见必须按当前 workload 的 discard/load 比率实测。

### 4.3 顺序违例：LQ 检测 → RTU 精确恢复 → no-spec 机制减少复发（详见 03/10）

load 乱序执行是赌博，两种输法：

- **RAW**：load 越过地址未知的老 store。st_dc 到达时反查 LQ，发现
  "表项有效 + load 比该 store 年轻 + 16B 相同 + bytes_vld 相交" → 违例。
  LQ 表项不保存 load 数据或“数据已最终返回”状态；它记录的是已按有效条件
  建立的在飞 load 地址范围，不能额外把“已拿到数据”写成比较器输入；
- **RAR**：较老 load 后到 DC，发现更年轻重叠 load 已建立 LQ 记录。在需要
  维护相关 load 顺序的配置下产生 spec fail；外部一致性写是该机制的重要
  动机，但 LQ 命中本身不证明真的发生了 snoop。

处理链：违例只是标记 → 随完成进 RTU 异常擂台（expt_vld=0 的非 trap 类）
→ 违例在精确恢复点触发 flush/replay。重放时依赖条件通常更成熟，但不保证
必然由 SQ 前递成功；它仍可能遇到 cache/TLB/资源等待。IFU 的 SFP 负责 PC
相关 Store-Fetch Prediction，LSU 的同名 `spec_fail_predict`则短期保存具体
store 的 PA[39:4]、字节掩码和 IID，验证 no-spec mark/hit。恢复代价必须由
事件附近的退休断流实测，不能固定写成几十拍。

### 4.4 SQ→WMB：推测域与提交域（详见 04/05）

```
SQ(12项,含未提交及待转交项): 地址(pipe4)+数据(pipe5)按 sdid 配对
  → RTU 退休后置 commit → 按队列顺序转交
  → WMB(8项×16B,提交域): 同16B块逐字节合并；连续4项可形成64B BIU写突发
     → 写 D-cache 或经 BIU 完成
```

- 普通后端 flush 清 SQ 未提交项，**WMB 与 SQ 已 commit 项不能按错路径丢弃**
  ——RTU flush 状态机等的 `lsu_all_commit_data_vld` 就是它们；
- `lsu_all_commit_data_vld`表示已提交 SQ 项的数据均有效，不表示这些项已写完
  或所有 LSU 队列为空；
- WMB 单项保存 128-bit 数据和 16-bit byte-valid；四个连续 16B 项在满足
  地址、属性、完整覆盖和 read-response 条件时，可合成一笔 `4×128-bit` 的
  64B BIU 写事务；这不是 D-cache data array 单周期写入 64B；
- AMR 观察已经从 SQ 成功进入/合并到 WMB 的 cacheable store 流，按连续完整
  16B 块数量建立信心，再调节后续 store miss、store prefetch 和 64B BIU 写
  的写分配属性；它不是只检查“当前四个 WMB 项是否成行”；
- NC（非缓存）/SO（强序设备）各有独立 idfifo。在 WMB 中，这两个 FIFO
  记录使用固定 BIU B 响应 ID 的请求应归属哪个 WMB entry，收到响应时按队首
  one-hot ID 完成正确项。它们是顺序/响应归属机制，不是普通 store 数据队列；
  普通 cacheable 写仍需遵守 WMB 指针、地址属性和一致性约束。

### 4.5 miss 三件套：RB→LFB→VB（详见 06）

```
符合条件的 ld/st miss → RB(8项)登记 → BIU 读
  ├─ 返回的目标数据可在整行回填完成前申请 ld_wb 数据仲裁
  └─ 整行 → LFB(addr 8项跟踪 + data 2项64B缓冲) → 仲裁 dcache 写口
     refill(2×32B 两个数据段) → 被替换脏行 → VB(2项) 读出 → BIU 写通道
     （不脏也发 evict 事务，维护外层 snoop filter 目录）
```

- 同 index 的后续 miss 在已有 RB/LFB/LM 事务占用相关窗口时会 discard，并在
  LFB 维护的 LSIQ 等待位图中登记；refill 完成后定向唤醒，重发通常转为 hit。
  这可以间接避免重复外部请求，但不是把任意同行 load 的多个目的寄存器都合并
  保存到同一个 RB entry；
- LFB 的 8 个地址项允许跟踪较多事务，而 2 个 64B data entry 限制同时接收或
  等待回填的数据行数量；地址跟踪容量和宽数据驻留容量必须分别分析；
- refill 完成精确唤醒等待该行的 LSIQ 项；
- RB 8 项只是 MLP 的一个容量上限；LFB data、BIU credit、跨边界子访问
  merge、同 index 冲突、顺序属性和程序独立地址链数量都可能使实际并发更低；
- miss 的完成可先报（cmplt）、数据后补（wb 口）——完成/写回分离同 IU。

### 4.6 D-Cache 组织与端口仲裁（详见 07）

当前配置为 64KB / 2 way / 64B 行 / 512 set。tag index 是 PA[14:6]，
tag 比较 PA[39:14]，因此有效 SRAM 接口是 PIPT。load 读口使用
`512×54 bit` tag 阵列，每路为 `{valid, 26-bit tag}`；store 读口使用
`512×52 bit` tag 阵列，只保存两路 26-bit tag，valid/share/dirty 由独立
`512×7 bit`状态阵列提供。data 只有全 cache 共用的 8 个
`2048×32 bit` bank。两份 tag 中对应的 26-bit tag 内容必须协同更新，但两份
阵列的位布局和职责并不完全相同。

`dcache_arb`按 tag、dirty、各 data bank 的读写资源分别仲裁 load/store、
LFB、VB、SNQ、WMB、ICC、MCIC 等来源，不存在一条统一的“六方绝对优先级”。
其中 ICC 服务 cache 操作指令，MCIC 服务 PTW 的物理 PTE 读取。部分内部请求
可通过 **borrow** 接口复用 load/store 的阶段寄存器和数据路径；是否只使用
空拍、是否反压正常指令，要看具体资源的 request/select/grant，不能把所有
borrow 请求统称为维护请求。

### 4.7 预取与一致性（详见 08/09）

- **PFU 三级**：PMB（按 PC 配对算 delta）→ SDB（连续同 delta 确认流）→
  PFB（8 条活跃流，L1/L2 双状态机分别领先 demand 近/远距离）。预取走
  LFB/BIU 等资源；资源冲突时请求可能被取消或延迟。丢弃不破坏正确性，但会
  损失潜在覆盖，也不能抹去已产生的带宽/污染成本；
- **SNQ（6 项）**：外核 snoop 请求先借 store 侧路径查询 tag/状态；命中且
  需要数据时，SNPDT 再借 load 侧 data 路径分两次读取 2×256 bit，并存入 3 个
  与 VB 共享的 64B data entry 之一，最后以 4×128 bit 的 `sdb_biu_cd_*`
  握手送回 BIU，同时按请求语义把行降级到 S/I。CTCQ 是另一条 6 项控制队列，
  用于远端 I-cache/TLB 失效，不传这条 cache-line 数据。SNQ 与 LFB 在飞行、
  WMB 在途写等都有互锁。LQ 的 RAR 检查用于相关 load 顺序，snoop 是设计
  动机之一，但两条 RTL 检测链不能直接画等号。

### 4.8 全景自检三问

1. store 从发射到外核可见：st_ag/dc/da → SQ →（退休）→ WMB → dcache/BIU；
2. load 读错数据的两道防线：LQ-RAW 抓现行 + SQ 部分覆盖 discard；
3. 屏障不是简单的“五队列全空”：`ctrl`按具体 fence/sync 类型、页面属性、
   在途事务和各模块完成条件判断何时满足所需内存序。

## 5. Verdi 观察层次

```
tb...x_ct_core.x_ct_lsu_top
 ├ x_ct_lsu_ld_ag/dc/da/wb     x_ct_lsu_st_ag/dc/da/wb
 ├ x_ct_lsu_lq / x_ct_lsu_sq / x_ct_lsu_wmb / x_ct_lsu_rb
 ├ x_ct_lsu_lfb / x_ct_lsu_vb / x_ct_lsu_dcache_top / x_ct_lsu_dcache_arb
 ├ x_ct_lsu_pfu / x_ct_lsu_snoop_snq
 └ x_ct_lsu_icc / x_ct_lsu_lm / x_ct_lsu_bus_arb ...
```

入门信号组（跑 bench_mem 或 coremark）：
`ld_ag_dc_inst_vld → ld_dc_da_inst_vld → ld_da_wb_inst_vld`（流水推进）+
`lsu_rtu_wb_pipe3_cmplt`（完成）+ dcache_arb 各 grnt（端口竞争）。
