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
| 容量 | 64KB | |
| 路数 | 2 way | tag 比较 ×2 |
| 行大小 | 64B | refill 2×32B（lfb sm 两拍） |
| set 数 | 512 | 64KB/2/64B |
| index | PA[14:6] | 9 位——超出 4K 页内偏移 3 位，VIPT 需 PA[14:12]，故 tag 访问在 AG 拿到 PA 后发起 |
| data bank | 8 个/路 ×2 路 | dcache_top.v:221-292 例化 ld_data_bank0~7；bank 交织消除并发访问冲突 |
| tag 阵列 | ld_tag（load 管线用）与 st_tag 分立 | load/store 双管线同拍各查各的 tag，物理双份换并发（dcache_top.v:151-196） |
| dirty 阵列 | 独立小阵列（含 FIFO/PLRU 位） | dirty 位更新频繁，独立阵列避免写 tag |
| ECC | data 27bit 2 段 ECC（ld_da 解码） | 软错误防护 |

**load/store tag 分立**是关键决策：两条管线每拍各需一次 tag 读，单阵列双口
SRAM 昂贵，复制 tag（每路 512×~26 位，复制代价小）即可双发——data 阵列则
靠 8 bank 交织+仲裁解决（数据阵列太大不能复制）。

## 2. dcache_arb：六方抢口

dcache 阵列口的竞争者与典型优先序：

```
snq(一致性侦听，最高——外部等着) > vb 读行 > lfb refill 写
> st(WMB 提交写) > ld 管线读 > icc(cache 指令)
```

仲裁粒度到"阵列种类"：tag 读、data bank 读、tag/dirty/data 写可分别授予
不同人——例如 load 读 bank0-3 与 refill 写 bank4-7 同拍并行。
`dcache_info_update`（被 sq/wmb 例化）把"写口正在写什么 index/way"旁路给
比较逻辑，处理读写同拍的 RAW 冒险。

**borrow 机制**（ld_da/st_da 的 borrow 接口）：snq/vb/icc 这些"非指令"访问
不占独立管线，而是借用 ld/st 管线的空拍走完 tag→data 流程——省两条专用
管线的代价是仲裁复杂度。

## 3. MESI 状态编码

行状态分布在 tag（valid+share）与 dirty 阵列（dirty）中：
M=vld·dirty·!share，E=vld·!dirty·!share，S=vld·share，I=!vld。
snoop 降级/升级即改写这两个阵列（09_snoop.md）。

## 4. Verdi 观察建议

层次：`...x_ct_lsu_top.x_ct_lsu_dcache_top` / `x_ct_lsu_dcache_arb`

| 信号 | 看什么 |
|------|--------|
| arb 各源 req/grnt | 端口竞争热点（refill 风暴时 load 被挤的拍） |
| tag 阵列读使能 vs index | VIPT 时序：AG 发请求 DC 出 tag |
| dirty 阵列写 | store 首写一行的瞬间 |

dcache 阵列信号位宽大，建议只抓 arb 层的 req/grnt 概览，具体数据用
ld_da 的 tag 比较结果间接观察。
