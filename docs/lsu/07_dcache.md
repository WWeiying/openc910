# C910 L1 D-Cache 阵列与仲裁（ct_lsu_dcache_top / dcache_arb / *_array）

> RTL 源文件：
> - `ct_lsu_dcache_top.v`（480 行，阵列例化与连线）
> - `ct_lsu_dcache_arb.v`（1393 行，访问仲裁）
> - `ct_lsu_dcache_ld_tag_array / tag_array / dirty_array / data_array.v`（SRAM 包装）
> - `ct_lsu_dcache_info_update.v`（写口信息旁路）

---

## 1. 组织参数

| 参数 | 值 | 推导 |
|------|----|----|
| 容量 | 64KB（当前 `DCACHE_64K` 配置） | 8 个 `2048×32 bit` data SRAM，共 64KB |
| 路数 | 2 way | 每个 set 的 tag 输出为 `2×26 bit`，DA 级分别比较 way0/way1 |
| 行大小 | 64B | 物理地址 `[5:0]` 为行内偏移；LFB 以两个 256-bit 数据段完成一行回填 |
| set 数 | 512 | 64KB/2/64B |
| tag index | PA[14:6] | `ld_ag_pa` 由翻译所得页号与 VA[11:0] 拼成，随后直接生成 `ag_dcache_arb_ld_tag_idx`；当前 SRAM 接口是**物理索引、物理标签（PIPT）** |
| tag | PA[39:14] | `st_dc` 将地址高 26 位分别与 tag 输出 `[25:0]`、`[51:26]` 比较 |
| data bank | 全 cache 共 8 个 | 每个 bank 是 `2048×32 bit`，不是“每路各 8 个”；bank0~3 组成 low 128-bit 组，bank4~7 组成 high 128-bit 组 |
| data index | 11 bit | load 路径生成 `low_idx=PA[14:4]`、`high_idx={PA[14:5],~PA[4]}`；该索引不仅包含 set，还把 way/16B 位置映射进单个 2048 深 SRAM |
| tag 阵列 | load 副本 + store 副本 | load 阵列是 `512×54 bit`，每路保存 `{valid, 26-bit tag}`；store 阵列是 `512×52 bit`，每路只保存 26-bit tag。复制的是 tag 信息，不是两份 cache 数据 |
| dirty/状态阵列 | `512×7 bit` | `[2:0]` 为 way0、`[5:3]` 为 way1，各组按 `{dirty,share,valid}` 使用；bit6 是替换 way 状态/选择信息 |
| ECC | 当前生成 RTL 未启用 | data SRAM 为原始 `2048×32 bit`；ld_da 内 ECC decoder 实例被注释，相关 stall/error 接口绑 0 |

这里最容易混淆的是“路”和“bank”。两个 way 体现在 tag 的两个候选以及
data SRAM 的地址映射中；RTL 顶层实际只例化 8 个 data array，每个 array
输出 32 bit。一次 load 根据访问范围使能若干 bank，low/high 两组可各提供
128 bit 窗口，DA 级再按命中的 way、地址低位和访问宽度完成选择与对齐。

**load/store tag 分立**是关键决策：load 与 store 地址管线可以分别请求自己的
tag 副本，减少二者对单个 tag 读口的直接争用。但两份阵列并非逐位相同：

```
load tag way0/way1 = {valid, PA[39:14]}  // 27 bit/way
store tag way0/way1 = {PA[39:14]}         // 26 bit/way
store 侧状态        = dirty array 中每路 {dirty, share, valid}
```

refill/invalidate 等操作必须让两份阵列中对应 way 的 26-bit tag 与状态语义
保持一致；不能写成两个 SRAM 的 52/54 位内容完全相同。data 容量较大，RTL
没有复制两份，而是依靠 8 bank、地址映射和 `dcache_arb` 的逐资源仲裁共享。

### 1.1 为什么这里不是 VIPT

“AG 与地址翻译并行”不能单独证明 cache 是 VIPT。判断应看送进 SRAM 的实际
索引：

```verilog
ld_ag_pa = {translated_page_number, ld_ag_va[11:0]};
ag_dcache_arb_ld_tag_idx = ld_ag_pa[14:6];
```

其中 `[14:12]` 来自翻译后的物理页号，而不是 VA 页内偏移，因此有效 RTL 在
tag/data SRAM 请求接口上使用 PA 索引。更精确的说法是：AG 级同时组织 MMU
和 D-cache 请求，但 cache 索引依赖 `ld_ag_pa`；不能把这种流水重叠写成
“先按 VA 查阵列、后用 PA 比 tag”的经典 VIPT 流程。

## 2. dcache_arb：按资源分别仲裁

`dcache_arb` 接收 load/store 指令路径以及 LFB、VB、SNQ、WMB、ICC 和 MCIC
等内部请求。其中 ICC 是 cache 操作指令路径，MCIC 是 PTW 读取 PTE 时使用的
MMU-to-LSU 桥，后者不是 cache 维护请求。这里不存在一条可以覆盖所有信号的
“六方统一优先级”：
tag 读、dirty 读写、8 个 data bank 的读写具有不同的请求集合和选择逻辑。
同一周期也可能在不冲突的阵列或 bank 上完成不同来源的操作。

因此观察优先级时必须限定具体资源，例如“load tag 读选择了谁”或
“bank3 本周期由谁写”，不能仅由某个源的 `req=1` 推断它已经访问 SRAM。
应同时检查该资源对应的 select/grant、最终 active-low SRAM 使能和 index。
`dcache_info_update`（被 sq/wmb 例化）把"写口正在写什么 index/way"旁路给
比较逻辑，处理读写同拍的 RAW 冒险。

**borrow 机制**（ld_da/st_da 的 borrow 接口）：snq/vb/icc 这些"非指令"访问
可以借用 load/store 管线中的阶段寄存器和数据处理路径。这里的“borrow”
不等于所有维护操作只会在管线完全空闲时发生；能否进入、是否挤压指令请求，
要由对应请求、选择和 stall/restart 条件共同判断。

## 3. MESI 状态编码

虽然模块名仍叫 dirty array，但其每路 3 bit 实际同时保存
`{dirty,share,valid}`。按 RTL 的组合判定可得到：
M=`valid && dirty && !share`，E=`valid && !dirty && !share`，
S=`valid && share`，I=`!valid`。
snoop 降级/升级即改写这两个阵列（09_snoop.md）。

bit6 用于替换 way 相关选择。只凭这个单 bit 的存在不足以把整个替换算法写成
某种特定的树形 PLRU；若要判断更新规则，应继续跟踪
`dcache_arb_st_dirty_din[6]` 的各来源和写使能条件。

## 4. 当前 ECC 边界

当前源码保留了 ECC 相关端口、控制信号和被注释的 decoder 模板，但有效硬件
路径并未包含 D-cache ECC：

- 8 个 data array 每项输出 32 bit，没有附带校验位；
- `ct_lsu_ld_da.v` 中 `ct_lsu_32bit_ecc_decode` 实例均被注释；
- `ld_da_ecc_stall`、`ld_da_lm_ecc_err`、`ld_da_mcic_data_err`、
  `ld_da_fwd_ecc_stall` 等被常量 0 驱动。

所以阅读波形或做功能/性能归因时，不能把 data error correction、ECC
reissue 或 ECC stall 算入当前配置。若项目以后替换 SRAM 宏并恢复 ECC 逻辑，
需要重新核对数据阵列位宽、编码写入、解码纠错、不可纠错异常和维护请求五条
路径，不能仅取消某个 stall 常量绑定。

## 5. Verdi 观察建议

层次：`...x_ct_lsu_top.x_ct_lsu_dcache_top` / `x_ct_lsu_dcache_arb`

| 信号 | 看什么 |
|------|--------|
| 各来源 req + 对应资源 select/grant | 区分“提出请求”和“实际占用该阵列/bank” |
| `ag_dcache_arb_ld_tag_idx`、最终 tag SRAM index | 验证 PA[14:6] 物理索引 |
| `ld_ag_pa[14:6]` 与 `ld_ag_va[14:6]` | 地址翻译开启且二者不同的页面上，可直接验证索引来自 PA |
| 8 个 data bank 的 select/index | 哪些 32-bit bank 被访问，以及 low/high 128-bit 窗口如何形成 |
| dirty 阵列写 | store 首写一行的瞬间 |

dcache 阵列信号位宽大，建议只抓 arb 层的 req/grnt 概览，具体数据用
ld_da 的 tag 比较结果间接观察。分析时必须先确定采样周期边界：SRAM 请求
出现在 AG/仲裁一侧，输出在后续 DC/DA 路径中被寄存和使用，不能把请求拍与
比较拍当成同一个组合事件。
