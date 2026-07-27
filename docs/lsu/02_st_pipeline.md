# C910 Store 管线详解（st_ag / st_dc / st_da / st_wb / sd_ex1）

> RTL 源文件：
> - `ct_lsu_st_ag.v`（1406 行）/ `ct_lsu_st_dc.v`（1304 行）/
>   `ct_lsu_st_da.v`（1641 行）/ `ct_lsu_st_wb.v`（约 350 行）
> - `ct_lsu_sd_ex1.v`（约 300 行）— Pipe5 store data 单级管线
>
> Pipe4 走地址，Pipe5 走数据，在 SQ 汇合。store 在管线里**从不写存储器**——
> 写动作全部推迟到退休后的 SQ→WMB→dcache 路径（05_wmb.md）。

---

## 1. 地址/数据双管线的汇合

```
 pipe4(st addr): AG → DC(创建SQ项,登记地址) → DA(命中判定) → WB(报完成)
                          ▲
 pipe5(st data): sd_ex1 ──┘ 按 sdid 把数据写进对应 SQ 项
```

**sdid**（store data id）：SQ 项号的别名。st_dc 创建 SQ 项时编码 sdid
（st_dc.v:978-996），IDU 的 SDIQ（store data 发射队列，doc/idu/16）发射
数据指令时带着 sdid，sd_ex1 一拍完成"选数→写 SQ[sdid]"（sd_ex1.v:186-279）。
地址与数据**到达顺序任意**，SQ 项内各有 vld 位，齐了才算就绪。

为什么数据只要一级管线？数据不需要翻译、不查 cache、不做依赖检查——
它只是寄存器值的搬运，做平 IDU 发射延迟即可。

## 2. st_ag（与 ld_ag 高度同构）

差异点：
- 不创建 LQ 项（store 自己不会"读到旧值"）；
- 异常检查多 TEE（可信执行）相关项（st_ag.v:1166 注释 "for tee"）；
- store 的非对齐同样两段式（bytes_vld 机制共享）。

## 3. st_dc：SQ 创建与 RAW 反查

### 3.1 创建 SQ 项（st_dc.v:978-1062）

登记 PA、bytes_vld、iid、sdid。SQ 满则 restart 回 LSIQ。

### 3.2 反查 LQ —— RAW 违例检测的发起端（st_dc.v:1063-1107）

```
本 store 的 PA/bytes_vld ──广播──► LQ 16 项逐项比较:
   有"比我年轻 + 地址重叠 + 已经拿到数据"的 load？
   有 → 那个 load 读早了(读到了本 store 写之前的旧值) → RAW spec fail
```

这是乱序访存最经典的难题：load 提前执行赌"前面没有同地址 store"，
st_dc 到达时开奖。违例的处理在 RTU（标记 → 退休时 flush 重执行，
doc/rtu/03/04），LSU 只负责"抓现行"。详见 03_lq.md。

### 3.3 cache 写口冲突检查（st_dc.v:1108-1125）

`dcwp_hit_idx`：本 store 的 index 与 dcache 当前写口（WMB 正在写的行）
比较——同 index 操作串行化，避免 tag/dirty 更新竞争。

## 4. st_da：命中判定与 dirty 语义

- tag 比较（st_da.v:1087-1187）：决定 store 将来从 WMB 写出时走 cache
  还是 BIU——**注意命中信息此刻只是"预查"**，真正写出在退休后，期间行可能
  被逐出/侦听，WMB 写出时还会再确认；
- **dirty 预登记**（L1188-1253，注释解释 dc 级后 dirty 可能再变的窗口处理）；
- miss store 同样申请 RB 做写分配读（read-for-ownership）；
- 把命中/way/dirty 信息写回 SQ 项（L1369），供 WMB 写出阶段使用；
- spec_fail_predict 训练接口（L1571）：被 RAW 打脸的 store 地址特征
  送预测器，下次相关 load 保守执行（10_misc.md）。

## 5. st_wb：只报完成

st_wb.v 仅 ~350 行：仲裁（L176）打拍（L257）后 `lsu_rtu_wb_pipe4_*` 报完成。
store **没有寄存器写回**，wb 级如此之薄正是"写推迟"设计的体现——
执行期的 store 唯一产出就是 SQ 里那一项。

## 6. 设计动机总结

| 决策 | 理由 |
|------|------|
| store 不在管线写 cache | 推测写无法撤销；退休后写保证只写体系结构态 |
| 地址/数据分管线 | 地址早到解锁 load 依赖判断；数据晚到无害 |
| st_da 预查命中 | WMB 写出时少一次 tag 访问（多数情况预查仍有效） |
| sdid 间接寻址 | SQ 项乱序分配、数据乱序到达，靠 id 配对 |

## 7. Verdi 观察建议

| 信号 | 看什么 |
|------|--------|
| `st_ag_dc_inst_vld → st_dc_da_inst_vld` | pipe4 推进 |
| st_dc 的 sq create 信号 + sd_ex1 的写 SQ 信号 | 地址/数据两路汇合（谁先谁后都有） |
| st_dc 反查 LQ 的 spec fail 输出 | RAW 抓现行瞬间 |
| `lsu_rtu_wb_pipe4_cmplt` vs SQ 项 commit 位 | "完成"与"提交"的时间差 |

配合 03_lq.md / 04_sq.md 的队列内部信号一起看效果最好。
