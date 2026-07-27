# C910 LSU 学习文档索引

LSU（Load Store Unit，访存单元）执行所有 load/store/原子/cache 操作指令，
管理 64KB L1 D-Cache、各级缓冲队列、硬件预取与缓存一致性侦听。
它是 C910 中仅次于 IDU 的第二大单元，也是**性能问题最常发生的地方**。

> LSU 共 60+ 个 RTL 文件，约 6.2 万行，位于 `C910_RTL_FACTORY/gen_rtl/lsu/rtl/`。
> 占据执行管线 Pipe3（load）、Pipe4（store 地址）、Pipe5（store 数据）。

## 资源速查表

| 结构 | 项数 | 作用 |
|------|------|------|
| Load Queue (LQ) | 16 | 已执行 load 的顺序违例监测 |
| Store Queue (SQ) | 12 | 未提交 store 的地址/数据，store→load 前递 |
| Write Merge Buffer (WMB) | 8 | 已提交 store 的合并写出 |
| Read Buffer (RB) | 8 | miss/非缓存读的 BIU 请求队列 |
| Line Fill Buffer (LFB) | 8 addr + 2 data | 缓存行回填 |
| Victim Buffer (VB) | 2 addr | 脏行逐出 |
| Snoop Queue (SNQ) | 6 | 一致性侦听请求 |
| Prefetch Buffer (PFB) | 8 | 硬件预取流跟踪 |
| D-Cache | 64KB, 2 路, 64B 行 | tag/dirty/data(8 bank) 阵列 |

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
| [05_wmb.md](05_wmb.md) | 8 项 WMB：提交后合并写、NC/SO 序维护 | ct_lsu_wmb.v + entry + ce |
| [06_rb_lfb_vb.md](06_rb_lfb_vb.md) | RB 请求 BIU → LFB 回填 → VB 逐出的 miss 全流程 | rb/lfb/vb.v + entries |
| **缓存本体与配套** | | |
| [07_dcache.md](07_dcache.md) | 64KB D-Cache 阵列组织与读写仲裁 | dcache_top/arb/*_array.v |
| [08_pfu.md](08_pfu.md) | 硬件预取：PMB/SDB/PFB 三级结构与 L1/L2 状态机 | ct_lsu_pfu*.v |
| [09_snoop.md](09_snoop.md) | 一致性侦听：SNQ 与数据应答 | snoop_snq/ctcq/resp/req_arbiter.v |
| [10_misc.md](10_misc.md) | icc(cache指令)/lm(原子)/amr/bus_arb/spec_fail_predict 等 | 其余文件 |

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
| LSU Spec Fail | - | lq 的 rar/raw spec_fail → rtu flush（见 03） |
| LSU Cross 4K Stall | - | ag 级跨页 stall |
| LSU SQ (Data) Discard | - | sq 依赖检查 discard（见 04） |
| LDST Unalign Access | - | ag 级非对齐拆分 |
