# C910 Miss 处理三件套（ct_lsu_rb / ct_lsu_lfb / ct_lsu_vb）

> RTL 源文件：
> - `ct_lsu_rb.v`（2917 行）+ entry（1581 行）×8 —— Read Buffer
> - `ct_lsu_lfb.v`（1890 行）+ addr_entry×8 + data_entry×2 —— Line Fill Buffer
> - `ct_lsu_vb.v`（1668 行）+ addr_entry×2 + sdb_data —— Victim Buffer
>
> 三者串成 D-cache miss 的完整流水线：**RB 发请求，LFB 收数据填行，VB 送走
> 被替换的脏行**。

---

## 1. miss 全流程图

```
ld_da/st_da miss
   │ 登记
   ▼
┌──────┐  请求(经bus_arb)  ┌─────┐
│ RB 8 ├──────────────────►│ BIU │ AXI AR 读
└──┬───┘                   └──┬──┘
   │ 关键字优先: 首拍数据 ──► ld_wb 直接写回（load 不等整行!）
   │                          ▼ 整行 64B 分批返回
   │                      ┌───────┐
   └── 行数据归属 ───────► │ LFB   │ addr 8项(跟踪) + data 2项(64B 缓冲)
                          └──┬────┘
                  refill 仲裁 │ dcache_arb
                             ▼
                      写 dcache(tag+data+dirty)
                             │ 被替换行是脏的?
                             ▼
                          ┌──────┐
                          │ VB 2 ├── 读出脏行 ──► BIU AXI AW/W 写回内存
                          └──────┘    (evict 事务还要通知 snoop filter, vb.v:1400-1403)
```

## 2. RB（Read Buffer）

- **8 项**，收容三类读：load miss、store miss 的 read-for-ownership、
  NC/SO 读（设备读不进 cache，数据直接给 ld_wb）；
- NC/SO 各有 idfifo 串序（rb.v:832-875，与 WMB 同款）——设备读同样不可乱序；
- **merge 抑制**：同行的多个 miss 只发一次 BIU 请求，后来者挂在同一项等数据
  （ld_da 的 compare index 部分职责）；
- fence/sync 支持（rb.v:2283-2302 "Fence signal"，`lsu_has_fence`）：屏障要
  等 RB 排空；
- 数据返回路径（L2627 起 "Request ld_wb stage"）：**critical word first**，
  AXI 返回的第一笔含目标字，立刻仲裁 ld_wb 写回口交付，剩余数据继续收集
  转交 LFB——load 的 miss 延迟因此只到首字而非整行。

## 3. LFB（Line Fill Buffer）

**addr 8 项 / data 2 项分离**：跟踪在飞 miss 行的"账"（地址/way/属性）便宜，
64B 的数据缓冲贵——同时真正处于"收数据"阶段的行很少，2 个数据项够用。
账多本、钱少柜，资源错配设计。

- **linefill 状态机**（lfb.v:1543-1620）：单实例服务两个 data entry，
  `lf_sm_cnt` 翻转表示一行分两次（2×32B）写入 dcache 数据阵列；
  `lfb_lf_sm_permit = !vld || cnt`——上一行写完后半段时下一行即可申请，
  流水化 refill；
- **refill way 选择**：创建时已带 `refill_way`（PLRU 替换决策在 tag 读时做）；
- **唤醒队列**（L1751）：refill 完成后唤醒等待该行的 LSIQ 项（被 discard
  的同行访问精确重发）；
- 给 PFU 回话（L1428-1430 `lfb_pfu_dcache_hit`）：预取请求若实际命中
  cache，告诉 PFU 别白忙；
- 防死锁（L1812 "for avoid deadlock with no rready"）：BIU 通道阻塞时的
  保底放行逻辑——这类注释是验证工程师的血泪，读到要心存敬意。

## 4. VB（Victim Buffer）

- **2 addr 项**：同时在途的逐出行最多 2 个（逐出带宽需求低）；
- **rcl（read cache line）状态机**（vb.v:629/883）：从 dcache 把整行脏数据
  读进 sdb_data 缓冲（借用管线空拍，borrow 机制）；
- **写出状态机**（L1514-1618）：AXI 写 + 等 bresp（比较 b_id，L1596）；
- **evict 通知**（L1400-1403 注释）：即使行不脏，被替换时也发 evict 事务——
  维护外层 snoop filter 的目录正确性（否则 filter 以为本核还有该行，
  白发 snoop）。

## 5. 性能视角

miss 延迟分解（理想链路）：

```
ld_da 判 miss(拍3) → RB 仲裁+BIU AR(数拍) → 内存/L2(主体延迟)
→ 关键字回 → ld_wb 交付
之后的 refill/evict 都在后台，不在 load 延迟路径上。
```

但**资源耗尽会把后台拉到前台**：LFB addr 满 → 新 miss discard 重发；
data 项忙 → refill 排队 → 占住 addr 项更久。bench_cache_cap/stride 跑出的
MLP（memory level parallelism）上限 ≈ RB 8 项。

## 6. Verdi 观察建议

| 信号 | 看什么 |
|------|--------|
| RB entry vld ×8 | 在飞 miss 数（MLP） |
| `lfb_lf_sm_vld/cnt` | refill 两段节拍 |
| VB 的 rcl/写出状态机 | 脏行逐出全程 |
| RB→ld_wb 交付 vs LFB refill 完成 | 关键字优先的时间差 |

bench_cache_stride 以 >64B 步长扫大数组是观察这条链的最佳负载。
