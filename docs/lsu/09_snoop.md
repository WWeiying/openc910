# C910 缓存一致性侦听详解（snoop_snq / snoop_ctcq / snoop_resp / snoop_req_arbiter）

> RTL 源文件：
> - `ct_lsu_snoop_snq.v`（1841 行）+ entry（964 行）×6 —— 侦听队列（主体）
> - `ct_lsu_snoop_ctcq.v`（730 行）—— core-to-core 传输队列
> - `ct_lsu_snoop_resp.v` / `ct_lsu_snoop_req_arbiter.v` —— 应答与请求仲裁
>
> 多核 C910 经 CIU（doc 外模块）互联，外核的访存请求会以 snoop 形式打进
> 本核 LSU，要求查询/降级/交出 D-cache 中的行。

---

## 1. snoop 处理全流程（snq.v 的三个状态机）

```
CIU snoop 请求 ──► SNQ 创建（6 项，L500-575）
   │ 选最老可发项（L576-632）
   ▼
读 dcache store-tag/dirty（借 store 侧路径，L633-695）→ 命中?
   │
   ├─ 未命中: 直接应答 "I don't have it"
   │
   ├─ 命中且无需数据(如 invalidate): 改 tag 状态 → 应答
   │
   └─ 命中需数据(读共享/读独占):
        SNPDT FSM（L733-948）: 借 load 侧 data 路径分两次读阵列
                              (256b×2=64B, L869-871)
  → 数据进共享 SDB/VB data entry（3 项，每项 512b）
        → CDR FSM(L950): 4×128b 经 sdb_biu_cd_* 交付 BIU
        同时按 snoop 类型降级行状态: M/E→S 或 →I
```

三个嵌套 FSM 的分工：**SNPT**（per-entry，tag 阶段）启动 **SNPDT**
（共享单例，数据读取）再交 **CDR**（数据应答传输）——tag 查询可多项流水，
数据搬运串行复用，与 LFB 的 addr 多/data 少是相似的“控制跟踪与宽数据容量
解耦”设计。源码附近仍有“2 entry”的旧注释，但当前有效总线
`sdb_*[2:0]`和 `ct_lsu_vb_sdb_data` 的 3 个实例证明本配置是 3 个共享 data
entry，应以有效 RTL 而不是残留注释为准。

## 2. 与本地访问的互锁

snoop 与本核在飞操作的竞争是一致性协议最难的部分：

- snoop 命中 **LFB 在飞行**：refill 没完成，snoop 等待或按协议 stall；
- snoop 命中 **WMB 已提交写**：SNQ/WMB 的地址依赖与状态互锁决定 snoop
  是否等待，以及相关 WMB 项何时能够继续推进；不能把所有这种冲突概括为
  “写先落地”或“合并应答”；
- LQ 的 RAR 检查用于约束相关 load 的反序执行，一致性写是这种约束的重要
  动机之一；但 LQ entry 比较器没有 snoop 输入，不能把某次 RAR 命中直接
  解释成“这一周期 snoop 改写了该行”；
- SNQ 会与本地 D-cache 请求竞争具体 tag/data/dirty 资源。是否在某资源上
  优先，要检查该资源对应的 arb select/grant，不能写成跨所有端口无条件最高。

## 3. CTCQ：控制失效队列，不是 snoop data queue

`ct_lsu_snoop_ctcq`有 6 项，但它保存的是 `ctc_type`、VA/PA、ASID 以及是否
需要第二次传输等**控制事务**。选中的 entry 向 IFU 产生 I-cache 全量/按行
失效，或向 MMU 产生按 VA/ASID 组合的 TLB 失效；收到
`ifu_lsu_icache_inv_done`或 `mmu_lsu_tlb_inv_done`后再经 CR 通道完成应答，
必要时还产生 `lsu_rtu_ctc_flush_vld`。

真正的 snoop cache-line 数据不进入 CTCQ：SNQ/SNPDT 读出的 64B 行存入共享
SDB data entry，CDR 按 4 个 128-bit beat 直接通过 `sdb_biu_cd_data/valid/last`
送 BIU。把两者分开后，波形归因很清楚：

```text
外部 D-cache snoop: SNQ -> store tag/dirty -> load data -> SDB -> BIU CD
远端控制失效事务:   CTCQ -> IFU I-cache 或 MMU TLB -> done -> BIU CR
```

## 4. 单核仿真下的观察

某个 smart_run 配置若只有一个核且没有一致性 DMA/外部 coherent master，
SNQ 可能长期静默；但“单核”本身不能证明 CIU 永不发 snoop。cache 维护指令
走 ICC/维护路径，也不能不经验证就当作外部 snoop 的替代来源。观察前先检查
顶层 CIU snoop request 接口是否有事务；若无，再换用真正支持一致性请求的
多核或系统级平台。

## 5. Verdi 观察建议

层次：`...x_ct_lsu_top.x_ct_lsu_snoop_snq`

| 信号 | 看什么 |
|------|--------|
| snq entry vld ×6 | 侦听压力 |
| SNPDT/CDR FSM 状态 | 数据应答流程 |
| `snq_dcache_arb_st_*` 与 `st_da_snq_borrow_snq` | tag/状态查询及返回 |
| `snq_dcache_arb_ld_*` 与 `ld_da_snq_borrow_sndb` | 两次 256-bit 数据读取 |
| `sdb_vld[2:0]`、`sdb_biu_cd_*` | 共享数据项占用和 4-beat 返回 |
| `ctcq_vld[5:0]`、I-cache/TLB inv/done | 独立的远端控制失效链 |
