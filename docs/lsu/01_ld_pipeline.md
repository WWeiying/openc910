# C910 Load 管线详解（ld_ag / ld_dc / ld_da / ld_wb）

> RTL 源文件：
> - `ct_lsu_ld_ag.v`（1462 行）— 地址生成
> - `ct_lsu_ld_dc.v`（1848 行）— cache 访问与依赖检查
> - `ct_lsu_ld_da.v`（2739 行）— 数据装配（全管线最复杂的一站）
> - `ct_lsu_ld_wb.v`（1259 行）— 写回仲裁
>
> Pipe3 的四级流水。命中 load 的延迟 = 发射后 4 拍出数据（业界典型 L1 延迟）。

---

## 1. AG 级（ct_lsu_ld_ag.v）

### 1.1 虚地址生成（L785-835）

`VA = base + offset`，一个 64 位加法器。特例（L787 注释）：非对齐跨 16 字节
边界指令的**第二次执行**用 `addr+offset+128`（即 +16 字节）作 VA——非对齐
访问被拆成两个 boundary 访问，各取一半字节。

### 1.2 非对齐与字节有效（L837-986）

按访问宽度（1/2/4/8/16B）和 VA 低位生成 `bytes_vld[15:0]`（16 字节窗口内
哪些字节属于本次访问）。bytes_vld 是后面所有依赖比较的"通用语言"：SQ 前递、
LQ 违例检查都按字节位图相交判断重叠（见 03/04），比按地址范围比较精确得多。
跨 16B 边界 → unalign，置 `LDST Unaligh Access` 计数并触发两段式执行。

### 1.3 MMU 翻译（L1032-1105）

AG 级同拍把 VA 送 dUTLB（`lsu_mmu_va*`），**下拍 PA 即回**（dUTLB 命中）。
miss 则走 jtlb/PTW（doc 未展开，见 mmu 模块），本指令 restart 等待。
`ld_ag_pa`（L1064）拼出物理地址送 DC 级。

### 1.4 dcache 请求（L1122-1198）

AG 级**就发出** tag 阵列读请求（地址用 VA 的 index 位——C910 D-cache 是
VIPT：64KB/2way=32KB/way=index+offset 15 位 > 12 位页内偏移，借 PA[14:12]
做物理 index 的一部分，所以请求等 PA 低位回来，时序刚好）。下一拍 DC 级
tag 出来与 PA 比较。

### 1.5 stall/restart（L1244-1338）

- **跨 4K stall**：两段访问跨页时第二段的翻译要等第一段完成
  （perf 的 `LSU Cross 4K Stall 607` 即此计数，hpcp 接口 L1445）；
- restart 类型打包回 IDU 的 LSIQ（L1410）：指令不死，回发射队列等条件
  满足再来——LSU 大量采用"restart-replay"而非"stall-in-place"，
  保持管线不被单条指令卡死。

## 2. DC 级（ct_lsu_ld_dc.v）

### 2.1 创建 LQ 项（L1281-1324）

每条进入 DC 的 load 在 LQ 登记（PA + bytes_vld + iid）。注释（L1283）提醒：
`lq_create_vld is not accurate, comparing iid is a must`——创建有效要再过
iid 比较确认非错误路径。LQ 是后续检测顺序违例的"案底库"（03_lq.md）。

### 2.2 依赖检查发起（L1325-1432）

DC 级把本 load 的 PA/bytes_vld 广播给 SQ 和 WMB 的每一项做**逐项比较**
（实际比较逻辑在 sq/wmb entry 内，L1403-1405 注释）。比较结果分三档：

| 结果 | 含义 | 动作 |
|------|------|------|
| 无重叠 | 无依赖 | 正常走 cache |
| 重叠且数据就绪且完全覆盖 | 可前递 | DA 级取 SQ/WMB 数据 |
| 重叠但数据未就绪/部分覆盖 | 真依赖没法转发 | **discard**：load 回 LSIQ 重发（perf 的 `LSU SQ (Data) Discard`） |

同时接受 **st_dc 的 RAW 反查**（L1351-1353 注释：同拍在 DC 级的 store 要
检查正在 DC 的 load——管线内同拍指令的依赖在这里就地解决）。

### 2.3 取数请求（L1554-1742）

`data_bias_sel`（L1556）按地址低位生成数据 bank 选择；向 dcache 的 8 个
data bank 发读（每 bank 64 位，两路并行读出 DA 级再选）；同时把"去 pfu
训练"（L1723）和 cache_buffer（L1743，borrow 机制的数据暂存）的信息备好。

## 3. DA 级（ct_lsu_ld_da.v）—— 数据从五个来源汇聚

### 3.1 命中判定与数据选择（L1707-2011）

```
tag 比较（两路）──┐
                  ├─ case: cache way0 / way1 / SQ 前递 / WMB 前递（L1769-1970）
SQ/WMB 前递数据 ──┘        ↓
                    数据规整 + 符号扩展（L1971-2011）→ 64 位结果
```

前递数据优先于 cache 数据（store 还没写进 cache，SQ 里才是最新值）。
ECC 解码（L2271 起，27bit 2 段 ECC）在此级并行做。

### 3.2 miss 走 RB（L2012-2165）

miss（或 NC 访问）→ 申请 read buffer 项。L2149 的"compare index"处理
corner case：**同 index 的访问不许同时在飞**（refill 时会撞 way 选择），
撞上则 discard 重发。RB 满同样 discard。
此级还产生 L1D miss 的 hpcp 计数（event13 的源头）。

### 3.3 spec fail 汇总与 restart（L2180-2264）

LQ 反馈的 RAR/RAW 违例、bkpt 等在此合流成 `lsu_rtu_wb_pipe3_spec_fail` 等
完成标记（L2585-2593 的 RTU 接口）——注意 spec fail 不在 LSU 内处理，
而是作为"异常类"标记报给 RTU，退休时触发 flush（doc/rtu/03/04）。

### 3.4 borrow 机制（L2462）

refill/snoop 等内部操作"借用" load 管线的空拍访问 dcache 阵列——
阵列只有一套口，管线气泡被内部维护操作充分利用。

## 4. WB 级（ct_lsu_ld_wb.v）

### 4.1 写回仲裁（L507-689）

pipe3 的写回口有多个抢用者：DA 级命中数据、RB 返回的 miss 数据（关键字
优先）、cache_buffer 补发的数据。WB 级仲裁后统一走
`lsu_idu_wb_pipe3_wb_preg_*` 写 PRF、`lsu_rtu_wb_pipe3_*` 报完成。

**miss load 的完成时序**：cmplt 可以在 DA 级先报（指令"完成"了，等数据），
数据后到时走 wb 口补写——又是完成/写回分离（与 doc/iu/07 同理）。

### 4.2 二次符号扩展（L1050-1077）

RB 返回的数据未经过 DA 的规整通路，WB 级备一份 settle+sign extend 逻辑。

---

## 5. 一条 load 的完整时间线（命中/前递/miss 三景）

```
        发射  AG      DC          DA            WB
命中:    │   VA/PA   tag读+依赖查  tag比较+选数   写回(4拍)
前递:    │   VA/PA   SQ命中且就绪  取SQ数据       写回(4拍,与命中同速!)
miss:    │   VA/PA   tag读        miss→RB登记    (完成先报)
                                   ↓
                       BIU 读(~数十拍) → 关键字到 → WB口补写数据
```

store→load 前递与命中同延迟，是 SQ 设计的最大收益。

## 6. Verdi 观察建议

| 信号 | 看什么 |
|------|--------|
| `ld_ag_dc_inst_vld / ld_dc_da_inst_vld / ld_da_wb_inst_vld` | 流水推进与气泡 |
| `ld_ag_pa` vs 反汇编的访存地址 | 地址正确性 |
| DA 级 cache/SQ/WMB 选择信号 | 前递发生的拍 |
| `lq_create_vld`、SQ 的 discard 信号 | 依赖三档结果 |
| RB 创建 + `lsu_rtu_wb_pipe3_cmplt` 早于数据写回 | miss 的完成/数据分离 |

跑 bench_cache_stride（miss 密集）和 bench_mem（前递密集）各一次对比最直观。
