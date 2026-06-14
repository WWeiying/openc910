# C910 硬件预取单元详解（ct_lsu_pfu）

> RTL 源文件：`ct_lsu_pfu.v`（2385 行）+
> `pfu_pmb_entry / pfu_sdb_entry / pfu_pfb_entry(×8) / pfu_gpfb / pfu_gsdb /
> pfu_pfb_l1sm / l2sm / tsm / pfu_sdb_cmp.v`
>
> PFU 监视 load/store 的地址流，识别**步长（stride）模式**，提前把后续行
> 拉进 L1/L2。对数组扫描类负载（bench_cache_stride、矩阵运算）收益巨大。

---

## 1. 三级结构

```
ld_dc/st_da 的访存 PC+地址 ──► PMB（PC Match Buffer）
                                │ 同 PC 再次出现 → 算 delta
                                ▼
                              SDB（Stride Detect Buffer）+ sdb_cmp
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

- **以 PC 为流标识**：同一条指令的连续地址差才是有意义的 stride
  （多个数组交错访问时按 PC 分流，互不污染）；
- **ld/st 同拍竞争 PMB 创建**：load 优先（pfu.v:928-930 注释）；
- **gpfb/gsdb（global）**：跨 PFB 项的全局过滤与历史，避免重复预取；
- **L1/L2 双深度**：L1 预取近距离（怕污染，保守），L2 预取远距离
  （容量大，激进）——l1sm/l2sm 独立推进各自的"领先量"；
- **timeout 计数**（L2375）：流不再命中则老化释放 PFB 项；
- `lfb_pfu_dcache_hit` 回馈：预取目标已在 cache → 白发，训练降温。

## 2. 与 demand 流的资源协调

预取请求走与 demand miss 相同的 LFB/BIU 通道，但优先级更低（bus_arb 仲裁）；
LFB 紧张时预取被丢弃——**预取永远是机会主义的**，丢了无害（顶多变回 miss）。
sync.i/fence 会清 PFU 状态（sq.v 弹出屏障时,04_sq.md）。

## 3. 怎么验证它在干活

跑 bench_cache_stride（固定步长扫数组）：

1. 前几次迭代：ld_da miss → RB/LFB 正常 miss 流程（训练期）；
2. SDB 确认 stride 后：PFB 项建立，`pfu` 发预取读；
3. 稳态：demand load 几乎全命中（L1D miss 率骤降），LFB 的创建源从
   ld_da 变成 pfu。

perf 对照：开关 `cp0_lsu_*` 预取使能位（CSR MHINT 的 dpld/dpst 位）跑同一
case，L1D Load Miss 计数差即预取收益。

## 4. Verdi 观察建议

层次：`...x_ct_lsu_top.x_ct_lsu_pfu`

| 信号 | 看什么 |
|------|--------|
| PMB/SDB 创建 | 训练期 |
| PFB entry vld ×8 | 活跃流数量 |
| l1sm/l2sm 状态 | 预取领先量推进 |
| pfu→biu 请求 vs ld_da miss | 预取替代 demand miss 的占比 |
