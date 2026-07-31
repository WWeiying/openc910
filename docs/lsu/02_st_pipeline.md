# C910 Store 管线详解（st_ag / st_dc / st_da / st_wb / sd_ex1）

> RTL 源文件：
> - `ct_lsu_st_ag.v`（1406 行）/ `ct_lsu_st_dc.v`（1304 行）/
>   `ct_lsu_st_da.v`（1641 行）/ `ct_lsu_st_wb.v`（350 行）
> - `ct_lsu_sd_ex1.v`（292 行）— Pipe5 store data 单级管线
>
> Pipe4 走地址，Pipe5 走数据，在 SQ 汇合。执行期的普通 store 不在
> st_ag/dc/da/wb 路径上产生不可撤销的内存写副作用；数据先进入 SQ，提交后
> 才经 WMB 写 D-cache 或 BIU。这里的“管线不写存储器”是指普通推测 store
> 的体系结构副作用，不表示 st_da 与 cache/RB/维护控制完全没有交互。

---

## 1. 地址/数据双管线的汇合

```
 pipe4(st addr): AG → DC(创建SQ项,登记地址) → DA(命中判定) → WB(报完成)
                          ▲
 pipe5(st data): sd_ex1 ──┘ 按 sdid 把数据写进对应 SQ 项
```

**sdid**（store data id）不是 SQ entry 的物理下标，而是把同一条 store 的
地址 uop 与数据 uop 重新配对的标识。IDU/LSU 接口上既可看到 12-bit one-hot
的 SDIQ entry 选择，也可看到由其编码得到的 4-bit `sdid`：

1. st_dc 将 `st_dc_sdid_oh[11:0]`编码成 `st_dc_sdid[3:0]`，随 SQ 项保存；
2. pipe5 发射时，`sd_ex1`也把 `idu_lsu_rf_pipe5_sdiq_entry[11:0]`编码为
   `sd_rf_ex1_sdid[3:0]`；
3. 每个有效 SQ entry 比较两个 4-bit ID，命中的项接收 store data。

因此波形中不能把 `sdid=5`直接解释为“写 SQ[5]”；真正被更新的是所有 entry
比较后的唯一命中项。地址和数据允许在不同周期到达，SQ 分别维护地址/entry
有效与 `data_vld`，提交后的写出还要求相应数据已经就绪。

为什么数据路径比地址路径短？store data 不需要重复执行地址翻译和 tag 查询，
主要完成数据选择、旋转/对齐信息配合以及按 sdid 更新 SQ。不过“一级”不表示
它是无代价导线：pipe5 的选择、寄存器、时钟门控、flush 屏蔽和 SQ 多项匹配
仍有真实时序与功耗成本。

## 2. st_ag（与 ld_ag 高度同构）

差异点：
- 不创建 LQ 项（store 自己不会"读到旧值"）；
- 异常检查多 TEE（可信执行）相关项（st_ag.v:1166 注释 "for tee"）；
- store 的非对齐同样两段式（bytes_vld 机制共享）。

## 3. st_dc：SQ 创建与 RAW 反查

### 3.1 创建 SQ 项（st_dc.v:978-1062）

`st_dc_sq_create_vld`要求 DC 中指令有效，并排除 vector nop、已有同指令 SQ
记录、uTLB miss 和指定异常；成功后登记 PA、`bytes_vld`、IID、SDID 及访问
属性。SQ 满则 restart 回 LSIQ。这里同样要区分较宽松的数据通路/门控有效与
真正创建成功，不能只看某一个 create 前置信号。

### 3.2 反查 LQ —— RAW 违例检测的发起端（st_dc.v:1063-1107）

```
本 store 的 PA/bytes_vld ──广播──► LQ 16 项逐项比较:
   有"表项有效 + 比我年轻 + 同一16B地址块 + 实际字节重叠"的 load？
   有 → 那个 load 读早了(读到了本 store 写之前的旧值) → RAW spec fail
```

这是乱序访存的经典难题：load 提前执行时，较老 store 的地址可能尚未可知；
st_dc 到达后才具备精确地址重叠检查条件。LSU 产生违例标记，RTU 在精确恢复
路径上选择 flush/replay。参见 [03_rob_expt.md](../rtu/03_rob_expt.md)、
[04_retire.md](../rtu/04_retire.md) 和 03_lq.md。LQ 不保存 load 数据返回位，
所以“已经拿到数据”不是 `lq_entry_raw_spec_fail` 的独立比较条件。

### 3.3 cache 写口冲突检查（st_dc.v:1108-1125）

`st_dc_dcwp_hit_idx`比较本 store 的 set index 与当前 dirty/status 写口
`dcache_idx`，并要求 `dcache_dirty_gwen`有效。它本身不进入
`st_dc_restart_vld`，不是“命中就把 store 串行化”；DC 同时把写口的
`dirty_din/wen`寄存到 DA。DA 若确认同 index，就先把该写掩码应用到此前读出的
状态阵列快照，再继续判断命中 way 的 dirty/share/valid。这个机制本质上是
**状态阵列读后遇到并发写的旁路/转发**，避免 DA 使用过期状态。

## 4. st_dc 预比较、st_da 最终判定与 dirty 语义

- tag 的两路 26-bit 比较实际在 `st_dc` 形成
  `st_dc_da_tag0_hit/tag1_hit`，并与 `512×7` dirty/status 阵列输出一起送入
  DA；DA 再用每路 valid、页属性和 cache enable 形成最终 hit/miss，选择命中
  way 或替换 way；
- 该结果决定 store 将来从 WMB 写出时的候选 cache 路径——**注意此刻只是
  预查**，真正写出在退休后，期间行可能被逐出/侦听，WMB 写出时仍需处理状态
  变化；
- **dirty/status 更新旁路**（st_da.v:1190 起）：先合并 DC 拍观察到的同 index
  写口，再通过 `ct_lsu_dcache_info_update`处理 DA 拍的并发写，避免 SQ 保存
  过期状态；
- cacheable、允许 write-allocate 且 miss 的 store 可创建 RB/LFB 请求；是否
  读入旧行还受 `page_wa`、AMR cancel、异常、RB 资源和原子/维护类型等条件
  约束，不能概括成“所有 store miss 都发 read-for-ownership”；
- 把命中/way/dirty 信息写回 SQ 项（L1369），供 WMB 写出阶段使用；
- 向 `spec_fail_predict` 提供 store 的 no-spec/spec-check 地址与字节掩码事件。
  该模块保存短期地址相关记录，不是按 load PC 训练的长期表，详见
  10_misc.md。

## 5. st_wb：只报完成

st_wb.v 仅 ~350 行：仲裁（L176）打拍（L257）后 `lsu_rtu_wb_pipe4_*` 报完成。
store **没有寄存器写回**，wb 级如此之薄正是"写推迟"设计的体现——
执行期最主要的持久结果是 SQ 中的地址、数据和 cache 预查元数据；同时 WB
仍需向 RTU报告完成、异常和恢复相关信息，所以不能把 SQ 项称为“唯一输出”。

## 6. 设计动机总结

| 决策 | 理由 |
|------|------|
| store 不在管线写 cache | 推测写无法撤销；退休后写保证只写体系结构态 |
| 地址/数据分管线 | 地址尽早参与依赖检查；数据可以在另一条短路径到达，但未到时会造成前递等待/discard |
| st_da 预查命中 | 提前保存候选 way/状态信息；WMB 写出时仍需处理状态变化和冲突 |
| sdid 配对 | 地址 uop 与数据 uop 可在不同周期执行，靠逻辑 ID 匹配到同一 SQ 项 |

## 7. Verdi 观察建议

| 信号 | 看什么 |
|------|--------|
| `st_ag_dc_inst_vld → st_dc_da_inst_vld` | pipe4 推进 |
| st_dc 的 sq create 信号 + sd_ex1 的写 SQ 信号 | 地址/数据两路汇合（谁先谁后都有） |
| st_dc 反查 LQ 的 spec fail 输出 | RAW 抓现行瞬间 |
| `lsu_rtu_wb_pipe4_cmplt` vs SQ 项 commit 位 | "完成"与"提交"的时间差 |

配合 03_lq.md / 04_sq.md 的队列内部信号一起看效果最好。
