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
 │ ld_ag   │ 虚地址生成+MMU    │ st_ag   │ 同左              │ sd_ex1  │ 数据接收
 ├─────────┤                  ├─────────┤                  └────┬────┘
 │ ld_dc   │ 读tag/lq sq检查   │ st_dc   │ 读tag/创建sq      数据写入 SQ
 ├─────────┤                  ├─────────┤
 │ ld_da   │ 数据选择+前递合并  │ st_da   │ 命中判定/dirty
 ├─────────┤                  ├─────────┤
 │ ld_wb   │ 写回PRF/RTU      │ st_wb   │ 完成报RTU
 └─────────┘                  └────┬────┘
                                   │ 指令退休后
                              ┌────▼────┐    ┌─────┐
                              │   SQ    ├───►│ WMB │──合并──► dcache 写 / BIU 写
                              └─────────┘    └─────┘
   miss 路径: ld_da/st_da miss ──► RB ──req──► BIU(AXI) ──data──► LFB ──refill──► dcache
                                                  逐出脏行: dcache ──► VB ──► BIU
   一致性:   外部 snoop ──► SNQ ──读tag/data──► 应答/降级
   预取:     ld/st 流检测 ──► PFU(PMB/SDB/PFB) ──► 预取请求进 LFB
```

### 1.1 四级流水职责

| 级 | load(pipe3) | store(pipe4) |
|----|-------------|--------------|
| AG | 基址+偏移算 VA；非对齐拆分；MMU 翻译得 PA；跨 4K 检查 | 同左 |
| DC | 读 dcache tag；查 SQ/WMB 依赖；创建 LQ 项；被 st_dc 反查 RAW | 读 tag；**创建 SQ 项**；反查 LQ |
| DA | tag 比较定命中；从 cache/SQ/WMB 选数据；符号扩展；miss 则申请 RB | 命中判定；更新 dirty；结果给 SQ |
| WB | 数据写回 PRF + 完成报 RTU | 完成报 RTU（数据不在此写，等退休后从 SQ→WMB） |

**为什么 store 拆成地址(pipe4)/数据(pipe5)两条管线？** 地址早算可以让后续
load 尽早做依赖判断（地址未知的 store 会挡住所有更年轻 load）；数据晚到
无所谓——store 反正要等退休才真正写。地址/数据解耦是高性能核标配。

### 1.2 队列家族：一条 store 的旅程

```
执行期(推测): st_ag/dc/da 走完 → 地址+数据躺在 SQ（12项）
退休(提交):   RTU retire → SQ 项标记 commit → 弹出进 WMB（8项）
写出:        WMB 合并相邻写 → 命中则写 dcache，miss/NC 则走 BIU
```

SQ 是**推测域**（flush 可清），WMB 是**已提交域**（flush 不可清，必须写完）
——这就是 doc/rtu/04 中 `lsu_rtu_all_commit_data_vld` 检查的对象。

一条 miss load 的旅程：

```
ld_da miss → RB 登记（8项）→ BIU AXI 读 → 关键字优先返回:
  ├─ 数据直接送 ld_wb 写回（不等整行）
  └─ 整行进 LFB → 仲裁 dcache 写口 refill → 若逐出脏行 → VB → BIU 写回
```

## 2. 顶层级联的其他模块

| 模块 | 职责 | 文档 |
|------|------|------|
| dcache_top | tag/dirty/data 阵列例化 | 07 |
| dcache_arb | 五方抢 dcache 口（ld/st/lfb/vb/snq/icc）的仲裁 | 07 |
| lq/sq/wmb/rb/lfb/vb | 六大队列 | 03-06 |
| pfu | 硬件预取 | 08 |
| snoop_* | 一致性 | 09 |
| icc | cache 操作指令（dcache.cva 等） | 10 |
| lm | 原子指令 local monitor（lr/sc/amo） | 10 |
| amr | 写分配模式调节（连续整行写时不再读内存） | 10 |
| spec_fail_predict | 顺序违例预测器（被打过脸的 load 下次保守执行） | 10 |
| bus_arb | RB/WMB/VB/PFU 抢 BIU 端口 | 10 |
| ctrl | fence/sync 全局排序控制 | 10 |
| vmb | 向量访存缓冲 | （向量部分从略） |

## 3. 正确性三大机制预览

1. **store→load 前递**（04_sq.md）：load 在 DC 级查 SQ/WMB 中"比我老、地址
   重叠、数据就绪"的 store，DA 级直接拿其数据，免去等写 cache；
2. **顺序违例检测**（03_lq.md）：load 推测执行越过了更老的 store/load，
   st_dc/ld_dc 反查 LQ，发现重叠 → spec fail → RTU flush 重执行；
3. **一致性侦听**（09_snoop.md）：外部核的读写经 CIU 侦听本核 dcache，
   SNQ 读 tag/数据并降级行状态（MESI）。

## 4. 核心机制速通（子文档精华浓缩）

> 读完本节即可对 LSU 有完整认识；源码级细节进 01~10 子文档。

### 4.1 两条管线的逐级要点（详见 01/02）

**load（pipe3）**：
- AG：VA=base+offset；非对齐拆两段（第二段 VA+16B）；按宽度和低位生成
  `bytes_vld[15:0]`——后续一切依赖比较的"通用语言"（16B 窗口字节位图，
  比地址区间比较精确且便宜）；dUTLB 同拍翻译；跨 4K 第二段 stall；
- DC：读 tag（VIPT）；**创建 LQ 项**（登记案底）；PA+bytes_vld 广播给
  SQ/WMB 逐项比依赖；接受同拍 st_dc 的 RAW 反查；
- DA：tag 比较定命中；数据五选一（cache way0/1、SQ 前递、WMB 前递）；
  符号扩展；miss 申请 RB；ECC 解码并行做；
- WB：仲裁写回口（DA 命中数据 / RB miss 返回 / cache_buffer 补发）。

**store（pipe4 地址 + pipe5 数据）**：地址早算解锁 load 依赖判断，数据
晚到无害（sd_ex1 一级，按 sdid 写进 SQ 项）。st_dc 创建 SQ 项并**反查 LQ**
（RAW 抓现行）；st_da 只做命中"预查"写进 SQ 项；st_wb 仅报完成——
**store 在管线里从不写存储器**，推测写无法撤销，写动作全部推迟到退休后。

LSU 大量用 **restart-replay**（指令回 LSIQ 等条件满足重发）而非原地 stall，
单条指令不卡死管线；被 discard 的 load 有精确唤醒队列防重发风暴。

### 4.2 store→load 前递三步协议（详见 04）

```
① ld_dc 广播 PA[39:4]+bytes_vld+iid → SQ 12 项并行比:
   比我老? 同16B? 字节相交? 数据就绪?
② 三种结论:
   可前递（唯一最年轻的重叠老 store）→ ③ ld_da 拍独热选数，与命中同延迟!
   重叠但数据没到/部分覆盖 → discard: load 回 LSIQ 重发
   无关 → 走 cache
```

**部分覆盖为什么不拼接**：load 的字节可能一半在 SQ 一半在 cache，拼接
mux 代价高验证难——用偶发重发换数据通路简单（perf 里 SQ Discard 仅个位数，
编译器排序已让它罕见）。WMB 里的已提交未写出数据同样可前递。

### 4.3 顺序违例：LQ 抓现行 → RTU flush → 预测器免疫（详见 03/10）

load 乱序执行是赌博，两种输法：

- **RAW**：load 越过地址未知的老 store，读到旧值。st_dc 到达时反查 LQ，
  发现"比我年轻 + 16B 相同 + bytes_vld 相交 + 已拿到数据"的 load → 违例；
- **RAR**（多核）：同地址两 load 乱序，中间夹外部 snoop 写 → 违反同地址读序。
  ld_dc 反查 LQ 同构判定。

处理链：违例只是标记 → 随完成进 RTU 异常擂台（expt_vld=0 的非 trap 类）
→ 违例指令退休时 flush 重执行（这次 SQ 已有数据，前递成功）→ 同时训练
spec_fail_predict：该 load 的 PC 下次保守执行（等所有老 store 地址已知）。
一次 flush 几十拍，预测器把"反复跌倒"压成一次——perf 的 LSU Spec Fail 计数
偏高时先查它。

### 4.4 SQ→WMB：推测域与提交域（详见 04/05）

```
SQ(12项,推测域): 地址(pipe4)+数据(pipe5)按 sdid 配对 → RTU 退休 → commit 位置 1
  → 按程序序弹出 → WMB(8项,提交域): 相邻写合并 → 命中写 dcache / miss·NC 走 BIU
```

- flush 清 SQ 未提交项，**WMB 与 SQ 已 commit 项不可清**（体系结构已承诺）
  ——RTU flush 状态机等的 `lsu_all_commit_data_vld` 就是它们；
- WMB 合并让 memset 类小写凑成整行（配合 amr 整行写免读内存）；
- NC（非缓存）/SO（强序设备）各有独立 idfifo 严格串序——设备寄存器写序
  错乱是致命 bug，普通内存才许合并乱序。RB 对设备读同样串序。

### 4.5 miss 三件套：RB→LFB→VB（详见 06）

```
ld_da/st_da miss → RB(8项)登记 → BIU AXI 读
  ├─ 关键字优先: 首拍数据直接仲裁 ld_wb 交付（load 延迟只到首字!）
  └─ 整行 → LFB(addr 8项跟踪 + data 2项64B缓冲) → 仲裁 dcache 写口
     refill(2×32B 两拍) → 被替换脏行 → VB(2项) 读出 → AXI 写回
     （不脏也发 evict 事务，维护外层 snoop filter 目录）
```

- 同行多 miss 合并一次 BIU 请求；同 index 在飞访问 discard（refill 撞 way）；
- LFB addr 多/data 少 = "账多本、钱少柜"（同时收数据的行很少）；
- refill 完成精确唤醒等待该行的 LSIQ 项；
- **MLP 上限 ≈ RB 8 项**——bench_cache_stride 能跑出来的并发 miss 数。
- miss 的完成可先报（cmplt）、数据后补（wb 口）——完成/写回分离同 IU。

### 4.6 D-Cache 组织与端口仲裁（详见 07）

64KB / 2 way / 64B 行 / 512 set，VIPT（index 含 PA[14:12]，故 tag 访问等
AG 拿到 PA 后发起）。**load/store tag 阵列物理复制两份**换双管线同拍各查
各的；data 阵列 8 bank 交织。dirty 独立小阵列。MESI 状态 = tag 的
vld/share + dirty 位组合。

dcache_arb 六方抢口，优先级 snq(外核在等) > vb > lfb refill > st 提交写 >
ld > icc；snq/vb/icc 不设专用管线，**borrow** load/store 管线的空拍干活。

### 4.7 预取与一致性（详见 08/09）

- **PFU 三级**：PMB（按 PC 配对算 delta）→ SDB（连续同 delta 确认流）→
  PFB（8 条活跃流，L1/L2 双状态机分别领先 demand 近/远距离）。预取走
  LFB/BIU 同通道但低优先级，资源紧张直接丢（机会主义，丢了顶多变回 miss）；
- **SNQ（6 项）**：外核请求 → 借管线读 tag → 命中则 SNPDT FSM 分两次读
  64B 数据 → ctcq 缓存到缓存直传 + 行状态降级（M/E→S/I）。与 LFB 在飞行、
  WMB 在途写、LQ 已完成 load 都有互锁——LQ 的 RAR 违例物理来源正是 snoop。

### 4.8 全景自检三问

1. store 从发射到外核可见：st_ag/dc/da → SQ →（退休）→ WMB → dcache/BIU；
2. load 读错数据的两道防线：LQ-RAW 抓现行 + SQ 部分覆盖 discard；
3. 屏障（fence）= ctrl 模块查询 SQ/WMB/RB/LFB/VB 全空才放行。

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
