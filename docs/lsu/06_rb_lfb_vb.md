# C910 Miss 处理三件套（ct_lsu_rb / ct_lsu_lfb / ct_lsu_vb）

> RTL 源文件：
> - `ct_lsu_rb.v`（2917 行）+ entry（1581 行）×8 —— Read Buffer
> - `ct_lsu_lfb.v`（1890 行）+ addr_entry×8 + data_entry×2 —— Line Fill Buffer
> - `ct_lsu_vb.v`（1668 行）+ addr_entry×2 + sdb_data —— Victim Buffer
>
> 三者串成 D-cache miss 的完整流水线：**RB 发请求，LFB 收数据填行，VB
> 处理被替换行的脏数据写回或 clean-evict 一致性通知**。

---

## 1. miss 全流程图

```
ld_da/st_da miss
   │ 登记
   ▼
┌──────┐  请求(经bus_arb)  ┌─────┐
│ RB 8 ├──────────────────►│ BIU │ 读地址/数据通道
└──┬───┘                   └──┬──┘
   │ 可用返回 beat ─────────► ld_wb 数据仲裁（可早于整行 refill 完成）
   │                          ▼ 整行 64B 分批返回
   │                      ┌───────┐
   └── 行数据归属 ───────► │ LFB   │ addr 8项(跟踪) + data 2项(64B 缓冲)
                          └──┬────┘
                  refill 仲裁 │ dcache_arb
                             ▼
                      写 dcache(tag+data+dirty)
                             │ 被替换行需写回或发一致性 evict?
                             ▼
                          ┌──────┐
                          │ VB 2 ├── 脏行读数据；clean evict 无数据 ──► BIU
                          └──────┘    (宽数据使用 3 个与 snoop 共享的 64B entry)
```

## 2. RB（Read Buffer）

- **8 项**，收容三类读：load miss、store miss 的 read-for-ownership、
  NC/SO 读（设备读不进 cache，数据直接给 ld_wb）；
- NC/SO 各有一个 `ct_lsu_idfifo_8`（rb.v:832-912）。这两类请求分别共用固定
  `BIU_R_NC_ID/BIU_R_SO_ID`，因此 AR 被接受时把当前 RB entry ID 压入 FIFO，
  收到对应 R ID 时用 FIFO 队首 one-hot ID 把数据和完成状态送给正确 entry。
  它首先解决“共享总线 ID 下的响应归属与顺序”问题，不是每个 RB entry
  之外又复制一份地址/数据队列；
- **同 index 冲突抑制**：在 RB 尚未成功发 BIU 请求时，新的 cacheable miss
  会与有效 RB 项比较 set index；LFB/LM 也做相应 index 比较。命中时新 load
  通常 discard，并把 LSIQ entry 记入 LFB 的等待位图，待事务推进/回填后唤醒
  重发。因重发可命中已填入的行，多个访问可能最终只产生一次外部取行，但 RTL
  不是把任意同行 load 的目的寄存器列表都“挂在同一个 RB 项”；
- RB 中名为 `WAIT_MERGE` 的状态主要服务跨边界 load：首段建立 RB 项，第二段
  按同 IID 回来后把两个子访问的数据/字节有效范围合并。不要把这个 merge 与
  一般 MSHR 的同行请求合并混为一谈；
- fence/sync 支持（rb.v:2283-2302 "Fence signal"，`lsu_has_fence`）：屏障要
  等 RB 排空；
- 数据返回路径可在整行回填尚未完成时申请 `ld_wb` 数据口，形成 early
  restart/按 beat 交付能力。仅凭这条旁路不能断言“总线第一 beat 必定是
  critical word”：还要核对 `rb_biu_ar_addr[3:0]`、burst 类型、beat ID、
  返回选择和目标字偏移。准确结论是 load 不必无条件等待整行写入 D-cache，
  但何时收到目标字由具体请求和返回次序决定。

## 3. LFB（Line Fill Buffer）

**addr 8 项 / data 2 项分离**：地址 entry 保存行地址、way、依赖和事务信息，
data entry 承担宽数据接收/回填。该拆分减少了把宽数据复制 8 份的面积，但也
使“可跟踪 8 个事务”和“可同时占用宽数据缓冲的事务数”成为两个不同容量
上限。2 个 data entry 是否足够应由返回并发、回填服务率和 full stall 统计
验证，不能直接当成普遍充分。

- **linefill 状态机**（lfb.v:1543-1620）：单实例服务两个 data entry，
  `lf_sm_cnt` 翻转表示一行分两次（2×32B）写入 dcache 数据阵列；
  `lfb_lf_sm_permit = !vld || cnt`——上一行写完后半段时下一行即可申请，
  流水化 refill；
- **refill way 选择**：创建/传递信息中带有 `refill_way`；替换状态由 D-cache
  dirty/status bit6 及相关选择逻辑产生。未完整跟踪更新算法前不把它定名为
  某一种 PLRU；
- **唤醒队列**（L1751）：refill 完成后唤醒等待该行的 LSIQ 项（被 discard
  的同行访问精确重发）；
- 给 PFU 回话（L1428-1430 `lfb_pfu_dcache_hit`）：预取请求若实际命中
  cache，告诉 PFU 别白忙；
- RTL 含有针对 `rready`/资源互锁的防死锁条件。理解时要追踪“谁持有 LFB
  data entry、谁在等待 D-cache 口、谁控制 BIU ready”的等待环，而不能只
  把某个保底条件理解为性能优化。

## 4. VB（Victim Buffer）

- **2 个 addr entry**跟踪被替换行，但宽数据不是简单的“VB 自有 2 项”。
  `ct_lsu_vb_sdb_data`实际例化 3 个 512-bit data entry，供 VB 逐出和 SNQ
  snoop data buffer 共享；因此 VB 地址容量、共享数据容量和 snoop 占用可能
  形成不同的资源边界；
- **rcl（read cache line）状态机**（vb.v:629/883）：从 D-cache 把整行脏数据
  读进 sdb_data 缓冲。该过程通过 `borrow` 请求借用 load-side 数据阵列访问
  通路，并受相应仲裁和 stall 条件约束；`borrow`不能简单理解成“只使用管线
  空拍”；
- **写出状态机**（L1514-1618）：经 BIU 写地址/数据接口发出事务，并等待带
  `b_id` 的写响应。`aw/w/b`命名具有 AXI 通道语义，但该处仍是 LSU-BIU
  内部接口，外部总线实现由 BIU/系统顶层决定；
- **evict 通知**（L1400-1403 注释）：即使行不脏，被替换时也需要发相应
  evict 事务以维护外层 snoop filter/目录；脏行还必须携带数据写回。因而
  “clean victim 不需要数据写回”与“完全没有一致性逐出事务”是两回事。

## 5. 性能视角

miss 延迟分解（理想链路）：

```
ld_da 判 miss(拍3) → RB 仲裁+BIU AR(数拍) → 内存/L2(主体延迟)
→ 目标数据可用 → RB申请 ld_wb 数据口 → 写回
整行 refill/evict 可以与消费者继续执行重叠，但并非永远与性能无关。
```

LFB addr/data、VB、D-cache 写口或 BIU 被占用会延长 entry 生命周期，进而
阻止新 miss、拖慢后续写回，甚至使原本“后台”的 refill/evict进入关键路径。
RB 的 8 项只是局部结构容量上限之一，不等于实际 MLP 必然为 8：

- `WAIT_MERGE`主要合并同一条跨边界 load 的两个子访问，不应据此假设任意
  同行 load 都能共享一个 RB entry；同 index 冲突常使后续 load discard，
  待回填后再重发；
- LFB addr/data、BIU ID/credit、NC/SO 响应归属队列和同 index 冲突会更早限流；
- 响应延迟与发射/退休窗口决定程序能否产生足够多独立 miss；
- 原子、设备、屏障和 snoop 会进一步序列化。

应在波形中同时统计 RB 有效项高水位、创建被拒、边界 load merge、同 index
discard/wakeup、LFB full 和总线在途事务，才能把“容量 8”转成真实可持续
MLP。

## 6. Verdi 观察建议

| 信号 | 看什么 |
|------|--------|
| RB entry vld ×8 | 在飞 miss 数（MLP） |
| `lfb_lf_sm_vld/cnt` | refill 两段节拍 |
| VB 的 rcl/写出状态机 | 脏行数据写回全程；clean evict 只走无数据逐出通知 |
| RB→ld_wb 数据 grant vs LFB refill 完成 | 数据提前交付能力及其与整行回填的时间差 |

使用工作集超过 L1 且具有多个独立地址链的微基准容易观察这条链。单一依赖链
即使每次都 miss 也无法形成高 MLP；固定 stride 还可能被 PFU 预取改变结果，
因此应同时做预取开/关和独立链数量扫描。
