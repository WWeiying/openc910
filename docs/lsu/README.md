# C910 LSU 学习文档索引

LSU（Load Store Unit，访存单元）处理当前配置中路由到访存执行管线的
load/store、原子、屏障及 cache 维护类操作，管理 64KB L1 D-Cache、各级
缓冲队列、硬件预取与缓存一致性侦听。
它同时覆盖地址翻译接口、乱序访存正确性、cache miss、写出、预取和一致性，
因而是理解后端吞吐与存储层次瓶颈的关键单元。具体面积排名和某类性能瓶颈
是否占主导，应分别由当前综合报告与 workload 实测决定，不能由 RTL 行数断定。

> 当前目录含 70 个 Verilog 文件、约 6.33 万行，位于
> `C910_RTL_FACTORY/gen_rtl/lsu/rtl/`。
> 占据执行管线 Pipe3（load）、Pipe4（store 地址）、Pipe5（store 数据）。

## 资源速查表

| 结构 | 项数 | 作用 |
|------|------|------|
| Load Queue (LQ) | 16 | 已执行 load 的顺序违例监测 |
| Store Queue (SQ) | 12 | 推测 store 及已提交待转交项的地址/数据，store→load 前递 |
| Write Merge Buffer (WMB) | 8×16B entry | 已提交 store 的逐字节合并与写出；满足条件的连续 4 项可合成 4-beat、64B BIU 写突发 |
| Read Buffer (RB) | 8 | miss/非缓存读的 BIU 请求队列 |
| Line Fill Buffer (LFB) | 8 addr + 2 data | 缓存行回填 |
| Victim Buffer (VB) | 2 addr | 跟踪被替换行；整行数据使用 3 个与 snoop data buffer 共用的 64B data entry |
| Snoop Queue (SNQ) | 6 | 一致性侦听请求 |
| Core-To-Core Queue (CTCQ) | 6 | 远端 I-cache/TLB 失效控制事务；不承载 snoop cache-line 数据 |
| Prefetch Unit | PMB 8 / SDB 2 / PFB 8 | 从 PC/地址样本到 stride 确认，再到活跃预取流 |
| D-Cache | 64KB, 2 路, 64B 行 | PA[14:6] 物理索引；load tag 为 `512×54`（每路 26-bit tag+valid），store tag 为 `512×52`（每路 26-bit tag），另有 `512×7` 状态阵列和 8 个 `2048×32-bit` data bank |

## 目录结构

| 文件 | 内容 | 对应 RTL |
|------|------|----------|
| [00_lsu_overview.md](00_lsu_overview.md) | 总体架构、AG/DC/DA/WB 四级流水、数据流全景 | ct_lsu_top.v |
| **两条执行管线** | | |
| [01_ld_pipeline.md](01_ld_pipeline.md) | Load 管线四级逐站讲解（含前递接收端） | ld_ag/ld_dc/ld_da/ld_wb.v |
| [02_st_pipeline.md](02_st_pipeline.md) | Store 管线 + store data 管线 | st_ag/st_dc/st_da/st_wb/sd_ex1.v |
| **顺序与前递（乱序访存正确性）** | | |
| [03_lq.md](03_lq.md) | 16 项 LQ：RAR/RAW 顺序违例 → spec fail | ct_lsu_lq.v + entry |
| [04_sq.md](04_sq.md) | 12 项 SQ：store→load 前递、提交弹出 | ct_lsu_sq.v + entry |
| **写出与缺失处理** | | |
| [05_wmb.md](05_wmb.md) | 8 项 WMB：提交后合并写、NC/SO 响应归属与顺序维护 | ct_lsu_wmb.v + entry + ce |
| [06_rb_lfb_vb.md](06_rb_lfb_vb.md) | RB 请求 BIU → LFB 回填 → VB 逐出的 miss 全流程 | rb/lfb/vb.v + entries |
| **缓存本体与配套** | | |
| [07_dcache.md](07_dcache.md) | 64KB D-Cache 阵列组织与读写仲裁 | dcache_top/arb/*_array.v |
| [08_pfu.md](08_pfu.md) | 硬件预取：PMB/SDB/PFB 三级结构与 L1/L2 状态机 | ct_lsu_pfu*.v |
| [09_snoop.md](09_snoop.md) | 一致性侦听：SNQ 与数据应答 | snoop_snq/ctcq/resp/req_arbiter.v |
| [10_misc.md](10_misc.md) | icc(cache指令)/lm(原子)/amr/bus_arb/spec_fail_predict，以及 PTW 读 PTE 的 MCIC 桥 | 其余文件 |

## 推荐学习路径

```
第一轮  00_lsu_overview.md             ← 必读，四级流水 + 队列家族分工
第二轮  01_ld_pipeline.md → 04_sq.md   ← load 命中路径 + store 前递（最常见场景）
第三轮  02_st_pipeline.md → 05_wmb.md  ← store 从执行到落 cache 的全程
第四轮  03_lq.md → 10_misc.md(spec_fail_predict) ← 乱序访存正确性
第五轮  06_rb_lfb_vb.md → 07_dcache.md ← miss 处理全流程
第六轮  08_pfu.md → 09_snoop.md        ← 进阶：预取与一致性
```

## 与 perf 统计的对应（smart_run tb.v）

| perf 行 | HPCP 事件 | LSU 信号源 |
|---------|-----------|------------|
| L1D Load Miss/Access | event13/event12 | ld_da 的 miss 判定 / dcache 读口 |
| L1D Store Miss/Access | event15/event14 | st_da 同理 |
| LSU Spec Fail | - | LQ 的 RAR/RAW 检测经完成路径进入 RTU 恢复选择（见 03） |
| LSU Cross 4K Stall | - | ag 级跨页 stall |
| LSU SQ (Data) Discard | - | sq 依赖检查 discard（见 04） |
| LDST Unalign Access | - | ag 级非对齐拆分 |

表中“信号源”只说明事件由哪一类 RTL 条件产生，不自动定义统计口径。例如一次
非对齐体系结构指令可能经历两个子访问，而计数器可能按指令、子访问或有效 DA
事件采样。做定量分析前应回到 `smart_run` testbench 的采样表达式，确认分母、
去重方式、flush 错路径是否计入以及计数发生在 AG/DA/WB 哪个阶段。
