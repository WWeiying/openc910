# C910 指令预取缓冲详解（`ct_ifu_ipb`）

> 这里的 IPB 是 **Instruction Prefetch Buffer**，不是 IFU 的 IP 流水级。
> RTL 依据：`ct_ifu_ipb.v`、`ct_ifu_l1_refill.v`、`ct_ifu_icache_if.v`。

## 1. 在存储层次中的位置

```text
I-Cache miss
    |
    v
ct_ifu_l1_refill
    | refill 请求/返回
    v
ct_ifu_ipb  <---->  I-Cache tag（先查下一行是否已存在）
    |
    v
BIU / L2 / 外部存储层次
```

IPB 有两项职责：

1. 把 demand refill 请求转换为 BIU 读请求，并把返回的 128-bit beat 送给
   `l1_refill`。
2. cache-line demand refill 获得 BIU grant 后，尝试预取物理地址上的下一条
   64-byte cache line；预取数据
   先存入本地 4×128-bit PBUF，等后续真实 miss 命中该行时再回放。

因此它不是通用、多流、跨页预取器，而是一个受严格条件约束的 **next-line
prefetcher + 单行缓冲**。

## 2. 为什么先查 I-Cache

预取下一行前，IPB 通过 `ipb_icache_if_req` 读取下一行的 I-Cache tag。这里要
区分两类地址：

- `pref_line_addr = l1_refill_ipb_ppc[39:6] + 1` 保存下一行的**物理行地址**，
  用于后续 BIU 预取地址和 demand 是否命中 PBUF 的比较；
- `ipb_icache_if_index = l1_refill_ipb_vpc[39:6] + 1` 保存下一行的**虚拟索引**，
  用于读取 VIPT I-Cache 的相应 set。

由于 `ref_addr_within_4k` 禁止跨 4 KiB 页，下一行仍与 demand 行共享
`ppc[39:12]`。因此 CMP 阶段实际用当前 demand 的物理页号
`l1_refill_ipb_ppc[39:12]` 比较两路 tag 的 `[27:0]`，而不是拿 34-bit
`pref_line_addr` 整体直接与 tag 比较。请求状态机为：

```text
IDLE -> CACHE -> CMP
                  | hit
                  +------> IDLE
                  | miss
                  v
                PF_REQ -> PF0 -> PF1 -> PF2 -> PF3 -> IDLE
```

- `CACHE` 给 tag 读结果一个周期，并在 `icache_flop_clk` 的有效边沿把两路
  29-bit `{valid, physical_tag}` 锁存到本地寄存器。
- `CMP` 检查两路 `valid` 和物理页号是否匹配。
- 已命中则取消预取，避免重复占用 BIU 和 PBUF。
- 未命中才进入 `PF_REQ`。

这体现一个常见微结构原则：**预取不能为了减少未来 miss，先制造当前不必要的
带宽和能耗**。但 tag 查询本身也会与正常 I-Cache 操作竞争端口，所以
IFCTRL、L1-refill、IPB 与 PCGEN 必须遵守共享 index 的互斥时序。`icache_if`
把 IPB 归入 higher-request 类、可覆盖默认 pcgen index，但 higher 类内部依赖
one-hot 契约，并没有一个可处理任意并发的固定优先级仲裁器。

## 3. 预取启动条件

`pref_launch_vld` 是组合启动条件，同时要求：

```text
demand refill 已获 BIU grant
请求状态机为 IDLE，且写回状态机也为 PF_IDLE
本次传输为 cache-line 大小
CP0 打开 I-Cache prefetch
I-Cache invalidate 不在进行
l1_refill 允许预取
下一行仍在同一个 4 KiB 页
```

这里的“空闲”是 `pref_idle = (req_cur_st==IDLE) && (wb_cur_st==PF_IDLE)`。
因此只要 PBUF 中已有完整行处于 `PF_VLD`，即使请求状态机表面上已经回到 IDLE，
也不会启动第二条预取。当前结构不会用一条新预取静默覆盖尚未消费的旧行。

启动也不是“grant 同拍直接进入 CACHE”。`pref_launch_vld` 先在
`pref_launch_clk` 有效边沿把 `icache_if_req` 和下一行虚拟索引寄存下来；随后
`pref_launch_start = ipb_icache_if_req && enable && !invalidate` 才驱动请求状态机
从 IDLE 进入 CACHE。波形上应把 demand grant、I-Cache tag 请求和 CACHE 状态
看成连续的控制阶段，而不是同一个脉冲。

`l1_refill_ipb_pre_cancel` 只组合屏蔽已寄存的
`icache_if_req`，形成最终 `ipb_icache_if_req`；当前来源是 change-flow 或
I-Cache invalidation busy。它会使 `pref_launch_start` 失效，从而不进入 CACHE，
也会避免这次 Tag Array 查询成为有效请求。但
`ipb_icache_if_req_for_gateclk` 仍直接取未屏蔽的 `icache_if_req`，所以取消请求时
相关 wrapper 时钟条件仍可能出现。不能把 `pre_cancel` 描述成已经撤销一个获
BIU grant 的预取事务：此时预取 BIU 请求尚未经过 CACHE/CMP/PF_REQ 发出。

不跨 4 KiB 是关键正确性边界。下一页可能具有不同地址翻译、权限、内存类型和
安全属性；IPB 没有独立发起下一页翻译，因此不能直接继承当前行属性跨页预取。

## 4. BIU 仲裁与事务标识

在共享 BIU 请求输出的选择上，demand refill 优先于尚未获 grant 的 prefetch：

```verilog
ref_req_for_biu  = l1_refill_ipb_req &&
                   (pref_idle || !ref_hit_pref);
pref_req_for_biu = req_state == PF_REQ;
ifu_biu_rd_id    = !ref_req_for_biu;
```

当前 RTL 用 ID=0 表示 demand refill，ID=1 表示 prefetch，并用返回 ID 把
`grant/data/error` 分流。预取请求在 `PF_REQ` 尚未获得 grant 时，如果新的
demand refill 到来且不是命中已预取行，`ref_req_for_biu` 会覆盖输出地址、属性
和 ID，状态机也退回 IDLE，让需求请求先走。

`ifu_biu_rd_req_gate` 是 `req_gate` 的寄存输出，用于接口低功耗/提前开钟语义；
真正表示当前请求有效的是
`ifu_biu_rd_req=(ref_req_for_biu || pref_req_for_biu) && cp0_yy_clk_en`。波形中
不能用 `_req_gate` 代替协议请求，更不能把它的提前或滞后一拍记成额外事务。

“demand 优先”不能误读成总线只允许一个未完成事务：prefetch 已经获得 grant 并
进入 PF0~PF3 后，新的不命中 demand 仍可能以 ID=0 发出，而旧 prefetch 的返回以
ID=1 继续被 PBUF 接收。两个 ID 正是用来在返回通道区分这两类事务。当前文件没有
给出 BIU/L2 的固定仲裁延迟，也不能仅凭 `ifu_biu_rd_req` 推断外部总线一定同拍
接受。

总线参数在 `tsize==1` 的 cache-line 传输时为 4 个 128-bit beat：

- demand 地址由 `{ppc[39:4],4'b0}` 按当前 16-byte beat 对齐，因此可从 line
  内 critical beat 开始；prefetch 地址由 `{pref_line_addr,6'b0}` 按 64-byte
  line 对齐；
- `len=3`，表示 4 个 beat；
- `size=4`，每 beat 16 byte；
- `burst=2'b10`，配合 demand 的 line 内起始 beat 支持 wrap 形状；当
  `tsize==0` 时则是 `len=0`、`burst=2'b01` 的单 beat demand；
- PBUF 的 PF0~PF3 分别接收四拍。

这些字段说明传输形状，不应从 RTL 文档进一步推断具体 L2/DDR 固定延迟。

## 5. 4×128-bit PBUF

PBUF 由四组 128-bit 寄存器构成：

```text
PF0 beat -> pbuf_entry0
PF1 beat -> pbuf_entry1
PF2 beat -> pbuf_entry2
PF3 beat -> pbuf_entry3
总容量 = 512 bit = 64 byte = 1 条 I-Cache line
```

它不是可存多行的 queue，也没有多表项 tag。`pref_line_addr` 保存唯一预取行的
物理行地址；当该行处于 PF_VLD 等待消费时，`pref_idle` 为 0，新的 next-line
预取不会启动。旧行只有被匹配 demand 消费、被不匹配 demand 丢弃，或因
invalidate/no-op 被撤销后，结构才重新允许预取。

### 为什么不直接写 I-Cache

当前设计先保留在 PBUF，等 demand miss 真正请求该行时再通过与 refill 相同的
接口回放。从数据流上可以得到：

- 无用预取不会在收到 BIU 数据时立即写入 I-Cache data/tag array，因此不会在
  预取完成当下改变其两路 valid/tag；
- refill 仍统一处理 predecode、data/tag 写入和异常时序；
- 需求 miss 可以把预取数据当作低延迟返回源。

“不会污染替换状态”这一更强结论还需要结合 I-Cache 替换位实现核查，不能只由
IPB 文件推出。可以确定的代价是只能保存一行，且回放仍需 PF_WB0~PF_WB3 四个
数据周期。

## 6. 写回/回放状态机

第二个状态机管理“预取数据已经到齐，何时交给 refill”：

```text
PF_IDLE -> PF_VLD
             | 后续 refill 地址命中 pref_line_addr
             v
          PF_GRNT -> PF_WB0 -> PF_WB1 -> PF_WB2 -> PF_WB3 -> PF_IDLE
```

- `PF_VLD` 表示 PBUF 中有完整预取行等待消费。
- 匹配 demand refill 时，`PF_GRNT` 通过 `pref_grnt_ref` 向 refill 提供一个
  grant 周期；这是 IPB 内部 PBUF 命中响应，不是新的 BIU grant。
- 进入 PF_GRNT 时，`pref_line_offset` 采样 demand 物理地址
  `l1_refill_ipb_ppc[5:4]`。`PF_WB0..3` 从这个 critical 16-byte beat 开始，
  每个状态周期将 offset 加一并按 2-bit 自然回绕。因此回放顺序可能是
  `2,3,0,1` 等，并不固定为 entry0、1、2、3。
- `pref_wb_from_pbuf = wb_cur_st[2]` 在四个 PF_WB 状态均为 1，因此每个状态周期
  都向 `l1_refill` 拉高 data valid 并输出当前 offset 对应的 128-bit entry。
- invalidate、no-op 请求或不匹配的新 refill 会丢弃当前预取行。

需求返回与 PBUF 回放在同一组 refill 接口复用：

```text
ipb_l1_refill_grnt     = PBUF grant 或 BIU demand grant
ipb_l1_refill_data_vld = PBUF writeback 或 BIU demand data
ipb_l1_refill_rdata    = 两者二选一
```

`grnt` 与数据本来就可能处在不同周期，因此不能要求三者同拍拉高。真正的不变量
是：PBUF grant 只能在 PF_GRNT，PBUF data valid 只能在 PF_WB0~3；BIU 侧只有
返回 ID=0 且没有 `resp[1]` error 的 beat 才成为 demand data valid。`rdata`
组合总线在无 `data_vld` 时没有事务语义，波形分析不能脱离 valid 单独消费其值。

## 7. 错误、取消与 invalidate

### 7.1 预取错误

预取事务在 PF0、PF1 或 PF2 遇到 `biu_pref_trans_err` 时进入 `INV`，随后等待
同一 ID=1 事务的 `last` 再回 IDLE。若错误发生在 PF3，RTL 直接回 IDLE，并未再
进入 INV；这隐含依赖末 beat/总线响应协议的一致性，文档不能泛化为“所有错误都
进入 INV”。所有 ID=1 error 都不会形成 `ipb_l1_refill_trans_err`，因此错误
预取不会作为 demand 取指错误送给 refill。

### 7.2 Demand refill 错误

ID=0 且 `biu_ifu_rd_data_vld` 有效、`resp[1]==1`、当前又没有
`l1_refill_ipb_ctc_inv` 时，才形成 `biu_ref_trans_err` 并通过
`ipb_l1_refill_trans_err` 送回 `l1_refill`。它表示需求取指返回错误；最终如何
形成程序可见访问异常还要结合 refill/IFDP/RTU 异常链路，不能在 IPB 单模块把
错误输入直接等同于已经提交的异常。

### 7.3 Invalidate 竞争

若 `ifctrl_ipb_inv_on` 到来时 IPB 非空闲，`icache_inv_record` 置位，并保持到
`pref_idle` 才清除。`icache_inv_for_pref = ifctrl_ipb_inv_on ||
icache_inv_record` 会阻止新预取启动，并让写回状态机在 PF_IDLE/PF_VLD 丢弃本地
可用状态。

但请求状态机的 next-state 方程没有直接用 invalidate 强行取消一个已发出的
prefetch：已进入 PF0~PF3 的事务仍按 ID=1 接收并完成协议，出错时仍按 INV 收尾。
另一个信号 `ifu_biu_r_ready = !l1_refill_ipb_ctc_inv` 只直接受 refill 的 CTC
invalidate 控制，不等价于 `ifctrl_ipb_inv_on`；二者不能在波形中合并成一个含糊
的“invalidate”事件。

教学上应把“取消本地使用”与“总线事务已经发出后必须完成协议收尾”分开：
错误路径可以不消费数据，但不能随意遗忘一个已经获 grant 的事务。

## 8. 正确性不变量

1. prefetch 不得跨 4 KiB 页继承地址属性。
2. demand refill 与尚未获 grant 的 PF_REQ 同时竞争输出时，demand 的地址、属性
   和 ID 优先；已获 grant 的 prefetch 返回仍须按 ID=1 完成。
3. 返回 ID 必须决定数据属于 demand 还是 prefetch。
4. 请求状态必须依次在 PF0~PF3 各接受一个无 `resp[1]` 错误的 ID=1 data-valid
   beat，PF3 的有效 beat 才产生 `req_sm_pref_cmplt`；当前完成条件本身没有额外
   检查 `biu_ifu_rd_last`，其一致性依赖总线协议。
5. 预取传输错误不能变成程序可见取指异常。
6. demand error 必须送到 refill/异常路径，不能被预取逻辑吞掉。
7. invalidate 时旧 PBUF 行不得在之后被当成有效 refill 数据。
8. PBUF 回放必须命中相同物理行地址，并按 demand `ppc[5:4]` 指定的 critical
   beat 起始、四拍回绕顺序输出。
9. `ipb_l1_refill_rdata` 只有在配套 `ipb_l1_refill_data_vld` 为 1 时才可解释，
   无 valid 周期的数据总线值不构成返回。
10. 内部 `pref_idle` 同时要求 `req_cur_st==IDLE` 和 `wb_cur_st==PF_IDLE`；
    对外 `ipb_ifctrl_prefetch_idle` 却只译码请求状态机 IDLE。后者为 1 时，
    PBUF 仍可能处于 `PF_VLD/PF_GRNT/PF_WBn`，不能用它判断整个 IPB 已空。

### 8.1 门控时钟与功能有效

IPB 分别为主预取状态、launch/index、I-Cache tag 锁存、request-gate 和四个
PBUF entry 生成局部时钟。PBUF entry 的 local-enable 就是各自的
`pref_pbuf_wenN`，但技术 ICG 下 `cp0_ifu_icg_en` 仍可覆盖 local-enable；
非技术分支则直接传递主时钟。无论时钟是否翻转，只有
`pref_pbuf_wenN=1` 的 entry 才执行功能更新。类似地，判断 BIU 请求必须看
`ifu_biu_rd_req`，判断 PBUF 回放必须看 `pref_wb_from_pbuf`，不能以局部时钟或
`*_for_gateclk` 信号替代 valid。

## 9. Verdi 观察方法

### 9.1 Demand miss 到 BIU

```text
l1_refill_ipb_req
l1_refill_ipb_ppc[39:0]
ref_req_for_biu
ifu_biu_rd_req
ifu_biu_rd_grnt
ifu_biu_rd_id
biu_ifu_rd_data_vld
biu_ifu_rd_id
ipb_l1_refill_grnt
ipb_l1_refill_data_vld
ipb_l1_refill_rdata[127:0]
```

### 9.2 下一行预取

```text
pref_launch_vld
pref_line_addr[33:0]
pref_line_offset[1:0]
req_cur_st[3:0]
ipb_icache_if_req
ipb_way0_hit
ipb_way1_hit
pref_req_for_biu
ifu_biu_rd_id
biu_ifu_rd_id
biu_ifu_rd_resp[1:0]
biu_ifu_rd_last
pref_pbuf_wen0..3
wb_cur_st[2:0]
ref_hit_pref
pref_wb_from_pbuf
```

### 9.3 状态解释

| `req_cur_st` | 含义 |
|---|---|
| `0000` | IDLE |
| `0001` | CACHE |
| `0011` | CMP |
| `0010` | PF_REQ |
| `0110/0111/0101/0100` | PF0/PF1/PF2/PF3 |
| `1000` | INV |

| `wb_cur_st` | 含义 |
|---|---|
| `000` | PF_IDLE |
| `001` | PF_VLD |
| `011` | PF_GRNT |
| `110/111/101/100` | PF_WB0/PF_WB1/PF_WB2/PF_WB3 |

## 10. 性能分析

IPB 是否有效不能只看 I-Cache miss 下降，还应统计：

- 预取发起数、I-Cache 已有而取消数；
- PBUF 完成数、后续 demand 命中数和无用丢弃数；
- demand 命中 PBUF 后节省的等待周期；
- 预取占用 BIU 周期及对 demand grant 的干扰；
- 4 KiB 边界抑制比例；
- PBUF 单行容量造成的覆盖不足。

高准确率但覆盖率低，可能说明 next-line 模式、4 KiB 边界或单行占用约束限制了
覆盖；覆盖率高但有用率低，可能说明工作负载不是顺序取指、改流频繁，或预取行在
被消费前被不匹配 demand/invalidate 丢弃。上述归因都需要对应事件计数支撑，不能
只由最终 I-Cache miss 率反推，更不能简单归因于 I-Cache 容量。
