# C910 Write Merge Buffer 详解（ct_lsu_wmb）

> RTL 源文件：`ct_lsu_wmb.v`（4749 行）+ `ct_lsu_wmb_entry.v`（2329 行）×8
> + `ct_lsu_wmb_ce.v`（626 行，SQ→WMB 的创建打包级）
>
> WMB 收容**已提交**的 store，做相邻写合并，再写入 dcache 或经 BIU 写出。
> 普通后端推测 flush 不会把已经进入 WMB 的 store 当作错路径写丢弃；这些
> store 已越过提交边界，必须继续完成其内存副作用。异步 flush 仍会参与
> response/success 等控制状态处理，所以不应把这句话扩大成“任何 flush
> 信号都完全不影响 WMB 内部状态”。

---

## 1. 为什么要在 SQ 之后再加一级 WMB

| 动机 | 说明 |
|------|------|
| **写合并** | 同一 16B 块内逐字节合并；连续四项满足条件时可形成一个 64B 的 BIU 写突发，减少写地址和事务开销。实际收益取决于地址连续性、字节覆盖、cache 状态和 BIU 接受能力 |
| **解耦提交与写出** | store 退休即可让出 SQ 项（SQ 是昂贵的 CAM 结构），写 cache 的慢动作交给便宜的 WMB |
| **写序与响应管理** | cacheable、NC（非缓存）和 SO（强序）走不同约束；特别是 NC/SO 的 BIU B 响应使用固定事务 ID，WMB 需要两个 idfifo 记录请求对应的 entry，才能把响应按发出顺序归还给正确项 |
| **前递延伸** | 数据在 WMB 期间仍可被 load 前递（与 SQ 同协议），保证"提交但未写出"窗口的可见性 |

## 2. 结构（wmb.v）

```
SQ 弹出 ──► wmb_ce(打包/对齐) ──► 8 项 entry（每项16B数据+16bit字节有效+属性）
                                     │
            ┌────────────────────────┼──────────────────┐
            ▼                        ▼                  ▼
       命中: 写 dcache          miss/NC/SO: 走 BIU    被 load 查前递
       (抢 dcache_arb 写口)     (抢 bus_arb)
```

每个 `ct_lsu_wmb_entry` 内的数据寄存器是 128 bit，`bytes_vld` 是 16 bit，
地址比较也以 `PA[39:4]` 的 16B 块为基础。因此“一项等于一条 64B cache
line”是错误的。RTL 中的整行写条件会同时检查 write pointer 及其后续
`next1/next2/next3` 四个连续 entry 均已准备好；四个 16B entry 才覆盖一条
64B 行。单个 entry 内可通过逐字节有效位合并同一 16B 块中的多个 store，
相邻四项再进一步形成 cache-line 级 BIU burst。

- **NC FIFO / SO FIFO**（L1418-1502，两个 `ct_lsu_idfifo_8`）：NC 与 SO
  写地址被 BIU 接受时，把当前 `wmb_write_ptr` 编码后的 entry ID 压入对应
  FIFO；收到固定的 `BIU_B_NC_ID` 或 `BIU_B_SO_ID` 响应时弹出。FIFO 顶部的
  one-hot entry ID 作为 `next_nc_bypass/next_so_bypass`，让该 B 响应只完成
  最老的对应在飞项。它首先是**响应归属队列**，同时保留这两类请求的发出
  次序；不是“store 一进入 WMB 就压入的第二份写队列”；
- **多指针体系**（L3076-3414）：`create_ptr` 选择新建项；`read_ptr` 管理
  需要从 BIU 取得旧行/权限或执行维护读请求的 AR 阶段；`write_ptr` 管理
  D-cache 写、VB 请求或 BIU AW 阶段；`data_ptr` 管理 BIU W 数据阶段。
  三个消费指针可独立前进，使“读请求、写地址、写数据”能够处于不同 entry，
  但都通过循环位与 `create_ptr` 比较，不能越过尚未创建的项；
- **write imme**（L3624-3688）：RTL 注释明确区分低水位的 leisure write 与
  `entry >= 6` 的立即排空模式。ICC 等待清空、LSU no-op、entry 自身依赖/
  冲突以及高水位都可置位；未进入立即模式时，普通 D-cache 写只在 load/store
  AG 都空闲时借用端口。它是在合并机会、前台访存带宽和 WMB 满风险之间折中；
- **64B BIU 写突发**（L3212-3231、L4389-4397）：当 write pointer 指向
  line 内 offset 0，后续三项按地址递增，或指向 offset 3、后续三项按地址
  递减，并且四项都是完整 16B、cacheable、普通 store、已有 read response，
  `wmb_write_biu_dcache_line` 才成立。此时 AW `len=3`，W 通道依次发送四个
  128-bit beat；递减情形使用对应的 burst 编码。**这是一笔送往 BIU 的 64B
  写事务，不是 D-cache data array 在一个周期内被写 64B。**普通 D-cache
  命中写仍由选中的单个 entry 提供 128-bit 数据和 16-bit byte enable。

## 3. entry 内部（wmb_entry.v，2329 行）

entry 没有一个集中编码的“大状态寄存器”，而是用 `read_req_success/read_resp`、
`write_req_success/write_resp`、`data_req_success`、WB completion/data success
等分布式状态位表达生命周期。它接收 16B 块地址和属性，必要时发 AR 取得旧行
或权限，再申请 D-cache、VB 或 BIU AW/W 路径，最后在
`wmb_entry_pop_vld` 条件成立时释放。

同一 16B 块的后续 store 只有在地址、属性和合并许可均满足，且该 entry 尚未
进入不可合并的写出阶段时才能合入。每个新 store 有效的字节覆盖旧字节，
`bytes_vld` 按位 OR，因此同地址较新的 store 数据自然覆盖较老数据。entry
还带与 `ld_dc` 的前递比较器：普通 load 命中已有效字节时可前递；原子访问、
覆盖关系不满足或加速路径冲突则通过 discard/replay 保证正确性。

`rtu_yy_xx_flush`不会直接把有效 entry 清零；entry 的体系结构生命周期由
创建、写出成功和 pop 控制。与此同时，`rtu_lsu_async_flush`会参与某些
writeback completion/data success 状态的收尾。波形里看到 async flush
导致 success 位变化，不能误判为“已提交 store 被撤销”。

## 4. 一致性配合

WMB 写 D-cache 前要结合预查 tag/dirty 状态、当前一致性状态和在飞维护操作
判断是否能直接写；需要取行或获取写权限时会经读请求/LFB 等路径继续处理。
snoop 命中 WMB 在飞写时也有依赖和握手。准确结论是：**WMB 的写出与 cache
状态、ownership、refill/evict 和 snoop 互锁耦合，不是只看地址命中就落数据**。
至于某个具体状态是否直接写、发何种请求，应由该 entry 的 `read_req`、
`write_dcache_req`、`write_biu_req` 及其 grant/response 联合判定。

## 5. Verdi 观察建议

层次：`...x_ct_lsu_top.x_ct_lsu_wmb`

| 信号 | 看什么 |
|------|--------|
| entry vld ×8 | WMB 水位（写密集时满 → 反压 SQ 弹出 → SQ 满 → st_dc restart 的连锁） |
| 同一 entry 的 `bytes_vld[15:0]` 增长 | 同一 16B 块内发生逐字节合并 |
| `read/write/data/create_ptr` | AR、AW/D-cache、W data 和新建四个阶段之间的距离 |
| `wmb_write_imme` 及其 set/clear 条件 | 是空闲借口写出，还是高水位/维护/依赖迫使立即排空 |
| `wmb_write_biu_dcache_line` 与 next1/2/3 ready | 四个完整 16B 项何时组成一笔 4-beat、64B BIU 写事务 |
| NC/SO FIFO create/pop 与 `next_*_bypass` | 固定 BIU 响应 ID 如何映射回正确的 WMB entry |
| D-cache grant、BIU AR/AW/W grant、B response | 一个 entry 在本地命中写、旧行/权限请求和外部写出之间走了哪条路径 |

设备输出可用于观察 SO/NC 序列化，但是否同时出现普通 cacheable 合并取决于
该程序实际访存和页属性。应先确认地址属性信号，再给波形中的 FIFO 活动归因。
