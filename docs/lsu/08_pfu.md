# C910 硬件预取单元详解（ct_lsu_pfu）

> RTL 源文件：`ct_lsu_pfu.v`（2385 行）+
> `pfu_pmb_entry / pfu_sdb_entry / pfu_pfb_entry(×8) / pfu_gpfb / pfu_gsdb /
> pfu_pfb_l1sm / l2sm / tsm / pfu_sdb_cmp.v`
>
> PFU 监视 load/store 的地址流，识别**步长（stride）模式**，提前把后续行
> 拉进 L1/L2。规则数组流可能受益，但收益取决于训练长度、访存延迟、流数量、
> 预取距离、带宽和污染；不能由“数组扫描”这一程序标签直接推断收益大小。

---

## 1. 三级结构

```
ld_dc/st_da 的访存 PC+地址 ──► PMB（PC Match Buffer）
                                │ 同 PC 再次出现 → 算 delta
                                ▼
                              SDB（Stride Detect Buffer，2 项）+ sdb_cmp
                                │ 连续 N 次 delta 相同 → 确认稳定流
                                ▼
                              PFB（Prefetch Buffer，8 项）
                                │ 每项 = 一条活跃预取流:
                                │  l1sm（L1 预取状态机：领先 demand 若干行）
                                │  l2sm（L2 预取状态机：领先更多行）
                                │  tsm（training 状态机：流的维持/淘汰）
                                ▼
                          预取请求 → mmu 翻译（L1933 mmu pop entry）
                                   → biu/lfb 发读（L2053 biu pop entry）
```

- **容量是 PMB 8 / SDB 2 / PFB 8**：PMB 暂存较多 PC/地址样本，SDB 用较少
  表项确认候选 stride，PFB 保存最多 8 条活跃自动预取流。每一级 full/evict
  条件不同，不能只看 PFB 水位判断训练端是否丢流；
- **以 PC 为流标识**：同一条指令的连续地址差才是有意义的 stride
  （多个数组交错访问时按 PC 分流，互不污染）；
- **ld/st 同拍竞争 PMB 创建**：load 优先（pfu.v:928-930 注释）；
- **GSDB/GPFB 是另一条显式预取指令路径**：GSDB 只观察
  `ld_da_pfu_pf_inst_vld`一类 prefetch instruction 事件，并结合 IID/commit
  维护 stride 置信度；确认后由单个 GPFB 生成 L1/L2 请求。它不是“跨 8 个
  PFB 项做重复过滤”的目录。普通 load/store 的自动 stride 流走
  PMB→SDB→PFB，显式预取指令流走 GSDB→GPFB，两条路径最后共享 MMU/BIU
  请求选择；
- **L1/L2 两套状态机**：`l1sm`、`l2sm`分别推进对应层次的请求状态。
  “L1 近、L2 远”可作为理解预取层次的直觉，但具体领先距离和激进程度必须
  从 entry 参数、状态转移和当前 CP0 配置读取，不能仅由模块名断定；
- **timeout 计数**（L2375）：流不再命中则老化释放 PFB 项；
- `lfb_pfu_dcache_hit` 回馈：预取目标已在 cache → 白发，训练降温。

## 2. 与 demand 流的资源协调

预取请求与 demand 共享部分 LFB/BIU/cache 资源，并在相应仲裁条件下接受或
取消。丢弃预取不会改变程序的体系结构正确性，但不能说“性能无害”：已训练、
翻译或发出的预取可能消耗带宽和队列，也可能污染 cache；反过来，过早丢弃会
失去隐藏延迟的机会。评价 PFU 要同时看 useful、late、duplicate、dropped 和
pollution 相关现象，而不只是 demand miss 是否减少。

屏障/同步事件可触发 PFU 状态清理或约束；应观察 SQ 弹出项类型、PFU clear
输入和各 entry vld 的时钟沿变化，避免把所有 `fence`都概括成同一种清除。

AMR 识别到持续完整块写流后，可能通过 `amr_wa_cancel`约束 store write
allocate 和 store-side 自动预取，并在更高置信状态下通过 `amr_l2_mem_set`
改变相应外层属性。因此，评价 store 预取时还应同时观察 AMR 状态；否则会把
“PFU 没有建立 store 流”和“AMR 主动抑制该类流”混为一谈。AMR 的判定条件
和阈值见 [10_misc.md](10_misc.md)。

## 3. 怎么验证它在干活

跑 bench_cache_stride（固定步长扫数组）：

1. 前几次迭代：ld_da miss → RB/LFB 正常 miss 流程（训练期）；
2. SDB 确认 stride 后：PFB 项建立，`pfu` 发预取读；
3. 若训练及时且资源充足，部分 demand miss 会转成 hit，LFB/BIU 请求中 PFU
   来源占比上升；并不保证“几乎全命中”，也不会要求 demand 来源完全消失。

perf 对照应固定二进制、输入、初始 cache 状态和采样区间，再开关相应预取
使能。L1D miss 差值只是效果之一，还要比较周期、退休指令、BIU 流量、L2
miss、cache 污染和运行间波动；miss 减少但额外带宽或冲突增大时，性能未必
提高。

## 4. Verdi 观察建议

层次：`...x_ct_lsu_top.x_ct_lsu_pfu`

| 信号 | 看什么 |
|------|--------|
| PMB/SDB 创建 | 训练期 |
| PFB entry vld ×8 | 活跃流数量 |
| l1sm/l2sm 状态 | 预取领先量推进 |
| GSDB state / GPFB vld | 显式预取指令流的训练与活动；不要与普通 PFB 水位相加 |
| pfu→biu 请求 vs ld_da miss | 预取替代 demand miss 的占比 |
