# C910 LSU 配套模块速览（icc / lm / amr / bus_arb / spec_fail_predict / ctrl 等）

> RTL 源文件（均在 lsu/rtl/）：
> `ct_lsu_icc.v`(572) `ct_lsu_lm.v`(542) `ct_lsu_amr.v` `ct_lsu_bus_arb.v`(783)
> `ct_lsu_spec_fail_predict.v` `ct_lsu_ctrl.v`(1051) `ct_lsu_mcic.v`
> `ct_lsu_rot_data.v` `ct_lsu_idfifo_8.v`+entry `ct_lsu_cache_buffer.v`
> `ct_lsu_sd_ex1.v`（已在 02 讲）

每个模块职责单一，一节讲一个。

---

## 1. icc —— Cache 操作指令引擎

执行 `dcache.cva/civa/ipa...`（T-Head cache 维护指令）与 `fence` 的 cache
部分：按地址/全量遍历 set/way，借管线 borrow 口做 clean（脏行经 VB 写出）/
invalidate（清 vld）。全 cache 遍历 512 set×2 way 需上千拍，期间 icc 占口，
管线性能显著下降——这是 cache 维护指令昂贵的微架构原因。

## 2. lm —— Local Monitor（原子指令）

lr/sc 与 amo 的监视器：lr 登记保留地址，期间该行被 snoop 夺走/本核写覆盖
→ 保留失效 → sc 失败返回 1。amo（amoadd 等）走"读-改-写"原子序列，
lm 保证序列期间行独占不被打断。多核正确性的基石，单核仿真里 sc 几乎恒成功。

## 3. amr —— 写分配模式调节（All Miss Write）

检测**连续整行写**模式（如 memset 大块内存）：正常 store miss 要先读整行
（写分配），但马上会被全部覆盖——白读。amr 发现连续写满整行的流后切换
"不读直接写"模式，省一半带宽。WMB 的整行合并是它的判断输入。

## 4. bus_arb —— BIU 端口仲裁

RB（demand 读）/ PFU（预取读）/ WMB（写）/ VB（逐出写）四方抢 BIU 的
AR/AW 通道。demand > 预取；写通道 WMB/VB 按紧迫度。输出打包成
`lsu_biu_ar_*/aw_*` AXI 请求。

## 5. spec_fail_predict —— 顺序违例预测器

记录曾发生 RAW spec fail 的 load 特征（PC hash）。命中预测的 load 发射时
**保守化**：等所有更老 store 地址已知才执行，宁慢勿错。
flush 太贵（几十拍），预测器把"反复在同一处跌倒"的代价压成一次。
`rtu_lsu_spec_fail_iid`（doc/rtu/04）是它的训练输入。perf 中
`LSU Spec Fail 169` 偏高时，先查这里是否训练失效（hash 冲突/容量）。

## 6. ctrl —— 全局排序控制

fence/fence.i/sync 的总控：向各队列（SQ/WMB/RB/LFB/VB）发"排空"查询，
全空才放行屏障后的指令；管理 `lsu_idu_no_fence` 等发射约束。
perf 的 `Sync Stall` 计数源。

## 7. mcic —— MMU Cache Invalidate Channel

tlb 维护指令（sfence.vma）对 dcache 侧的配合通道（虚拟 cache 一致性）。

## 8. rot_data / cache_buffer / idfifo_8

- **rot_data**：字节旋转网络——非对齐访问的数据对齐、store 数据按地址
  低位旋转入位，纯组合工具件；
- **cache_buffer**：borrow 操作的数据中转站（如 vb 读行时暂存）；
- **idfifo_8**：8 深 id FIFO 模板，WMB/RB 的 NC/SO 序列化复用同一模块
  ——RTL 复用的又一例。

## 9. 阅读完成后的全景自检

至此 LSU 文档完结。检验掌握程度的三个问题：

1. 一条 store 从发射到数据可被外核看到，经过哪 6 个结构？
   （st_ag/dc/da → SQ → WMB → dcache（或 BIU），途中 RTU 退休触发提交）
2. load 读到错数据的两种可能与各自的守门员？
   （越过老 store：LQ-RAW + spec_fail_predict；前递部分覆盖：SQ discard）
3. perf 报表里 LSU 相关的 8 个计数分别由哪个模块产生？
   （见 README 的对应表，逐一回指模块）

能回答则 LSU 部分达成学习目标。
