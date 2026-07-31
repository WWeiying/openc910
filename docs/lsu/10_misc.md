# C910 LSU 配套模块速览（icc / lm / amr / bus_arb / spec_fail_predict / ctrl 等）

> RTL 源文件（均在 lsu/rtl/）：
> `ct_lsu_icc.v`(572) `ct_lsu_lm.v`(542) `ct_lsu_amr.v` `ct_lsu_bus_arb.v`(783)
> `ct_lsu_spec_fail_predict.v` `ct_lsu_ctrl.v`(1051) `ct_lsu_mcic.v`
> `ct_lsu_rot_data.v` `ct_lsu_idfifo_8.v`+entry `ct_lsu_cache_buffer.v`
> `ct_lsu_sd_ex1.v`（已在 02 讲）

每个模块职责单一，一节讲一个。

---

## 1. icc —— Cache 操作指令引擎

执行 T-Head cache 维护指令对应的按地址或全量 cache 操作，借用 LSU/D-cache
内部路径完成 tag 查询、clean、invalidate 等动作；脏数据需要经逐出/写回路径
处理。全量操作需要遍历大量 set/way 并与正常访存竞争资源，延迟通常显著高于
普通 load/store。不能简单把 `512×2` 直接等同于固定“上千拍”：每个状态需要
几拍、是否遇到脏行、是否等待 VB/BIU，以及 borrow 仲裁都会改变总周期。

`ct_lsu_icc` 的 3-bit 状态机把三类工作统一起来：

```text
IDLE
  -> WAIT_FOR_READY
       -> INV_DCACHE_LINE -> WAIT_VB_EMPTY       // 全量 invalidate
       -> REQ_VB_WAY0 <-> REQ_VB_WAY1
                         -> WAIT_VB_EMPTY         // 全量 clean/clear
       -> READ_DCACHE -> WAIT_DATA               // CP0 调试读阵列
```

- `WAIT_FOR_READY`不是固定延迟。它等待 WMB、RB、LFB、VB、SNQ 满足空闲条件，
  PFU 报告 ready；由 CP0 发起时还要求 SQ 为空。该状态同时置
  `icc_wmb_write_imme`，先推动 WMB 排空；
- 全量 invalidate 逐 set 把 dirty/status 阵列写成 0，并访问 load tag 侧；
  64KB 配置下 9-bit `icc_cnt` 在第 512 个 set 后结束；
- 全量 clear 不是简单清 valid：每个 set 依次对 way0、way1 请求 VB，使脏行
  具备写回/逐出机会，遍历完成后仍要在 `WAIT_VB_EMPTY` 等待 VB 真正排空；
- CP0 阵列读按请求类型借 load data/load tag 或 store tag/dirty 端口，
  `READ_DCACHE` 后在 `WAIT_DATA` 等待 `ld_da` 或 `st_da` 返回。这个调试读
  路径不等于普通 load，也不修改 cache 状态。

因此 `icc_done` 只说明相应状态机达到完成条件；清理操作的总时长必须分解为
“等待系统安静 + 逐 set/way 仲裁 + 脏行逐出/总线响应”，不能只看计数器宽度。

## 2. lm —— Local Monitor（原子指令）

`lm` 维护 LR/SC 所需的本地保留/监视状态，并接收会使保留失效的本地或一致性
事件；SC 是否成功还取决于地址命中、异常、cache/总线响应和相关原子控制。
AMO 的完整“读-改-写”还跨越 load、store、SQ/WMB 和 cache ownership 路径，
不能把整个原子协议都归为 `lm` 单模块保证。即使单核，异常、地址不匹配、
cache 操作或外部一致性主设备也可能使 SC 失败，因此“单核几乎恒成功”只能是
某个封闭测试环境的观测，不能写成 RTL 性质。

状态机揭示了 LR/SC 与 AMO 在同一模块中如何分流：

| 状态 | 体系结构含义 | 主要退出条件 |
|------|--------------|--------------|
| `IDLE` | 没有本地监视或 AMO cache-line 锁 | `ld_ag_lm_init_vld` 建立地址、访问大小和页面属性 |
| `WAIT_REQ` | 原子 load 已进入 LSU，等待确定是本地完成还是由 RB 发总线读 | 本地无请求时转入 exclusive wait；RB 分配响应 ID 时转 `WAIT_RESP` |
| `WAIT_RESP` | 等待匹配 `lm_ar_id` 的 BIU R 响应 | 总线错误清除；LR 成功转 `EX_WAIT_LOCK`；AMO 成功转 `AMO_LOCK` |
| `EX_WAIT_LOCK` | LR 保留有效，等待后续 SC 或使保留失效的事件 | SC 地址/大小比较、同 line snoop invalidate、victim evict、flush 等 |
| `AMO_LOCK` | AMO 对相关 cache index 的局部互锁期 | WMB 完成原子写后以 `wmb_lm_state_clr` 解锁 |

`lm_sq_sc_fail` 的直接比较条件是：必须处于 `EX_WAIT_LOCK`，且 SC 的完整物理
地址和访问大小都与 LR 保存值一致。snoop/victim 的失效比较采用 64B line；
AMO 锁期间对 load DA、store DA、SNQ 和 PFU 主要按 cache index `[13:6]`
阻断冲突，防止同 index 的阵列操作破坏原子序列。这也说明 LM 同时保存了
“体系结构保留地址”和“实现层 cache 资源互锁”两层状态。

## 3. amr —— 连续整块写模式识别与写分配调节

RTL 没有给出 AMR 缩写的权威英文展开，因此不应把它固定翻译成
“All Miss Write”。从 `ct_lsu_amr.v` 的实际逻辑看，它是一个观察
**SQ 已成功弹入/合并到 WMB 的 store 流**的自适应模式识别器：

1. 每次 `wmb_ce_pop_vld`，记录 `PA[39:4]` 与 `bytes_vld[15:0]`；
2. 当前 16B 块尚未全覆盖时，只接受同一 `PA[39:4]` 的互补字节，并把
   byte mask 按位 OR；若新写与已覆盖字节重叠，则模式失败并从当前 store
   重新开始，避免把覆盖更新误算成“新完成一个整块”；
3. 当前 16B 已全覆盖后，只把相邻的前一个或后一个 16B 块视为连续更新。
   每完成并跨过一个完整 16B 块，`amr_cnt` 增加；
4. 计数达到 8 时从 `JUDGE` 进入 `MEM_SET_0`；达到 16、48 时继续升级到
   `MEM_SET_1`、`MEM_SET_2`。地址/字节模式失败会逐级降档，ICC 非 idle、
   AMR 被 CP0 关闭、出现非 cacheable store 或 no-op 请求也会取消当前判断；
5. 三个 `MEM_SET_*` 状态的 bit0 都令 `amr_wa_cancel=1`。该信号在
   `st_da` 中把后续 store miss 的 `page_wa` 清掉，也抑制相关 store
   预取写分配；最高档且 `cp0_lsu_amr2=1` 时，`amr_l2_mem_set=1`，进一步
   修改 WMB 64B BIU 写事务的 cache/write-allocate 属性。

因此 AMR 不是“当前 WMB 正好有四项时才省一次旧行读取”，而是根据一段时间内
连续、完整的 16B store 覆盖建立信心，再把后续流量切向更适合 streaming
store 的写分配策略。它可能减少无用的 read-for-ownership 和 cache 污染，
但收益只适用于持续整块覆盖的写流；稀疏、反复覆盖、非连续或很短的 store
序列不会稳定进入高档。

## 4. bus_arb —— BIU 端口仲裁

`bus_arb`在 RB、PFU、WMB、VB 等来源之间组织 LSU 到 BIU 的读写请求，并输出
`lsu_biu_ar_*`、`lsu_biu_aw_*` 等内部 BIU 接口。信号名借用了 AXI 的
AR/AW/R/B 语义，但 LSU 文档应把它称作“到 BIU 的请求通道”；最终如何映射到
芯片外部总线由 BIU/系统集成决定。优先级也应分别按读地址、写地址、写数据及
当前请求状态检查，不能用一句“demand 永远大于预取”替代所有 grant 条件。

当前 RTL 的精确边界是：

- **AR 读地址通道**在 LSU 内真正做固定选择，优先级为
  `WMB > RB > PFU`。WMB 的 ownership/维护读会压过 demand RB，RB 再压过
  prefetch；所以“demand 永远最高”并不准确；
- 三个来源都有 `dp_req` 与真正 `req`。若某来源给出 datapath 请求但最终
  请求被自身条件屏蔽，`bus_arb_*_mask` 会在下一拍临时屏蔽它，防止空占选择
  位置使低优先级请求无法前进；
- **AW 写地址通道**没有在本模块内把 VB 与 WMB mux 成单一接口，而是分别
  输出 `lsu_biu_aw_vict_*` 和 `lsu_biu_aw_st_*`。谁被接受由 BIU 返回的
  `biu_lsu_aw_vb_grnt/biu_lsu_aw_wmb_grnt` 决定；源码中的“VB>WMB”注释是
  接口协议意图，不能仅从本模块组合逻辑推导每拍固定仲裁；
- **W 写数据通道**同样保留 victim 与 store 两组独立输出，由 BIU 分别返回
  grant。不能把 AR 的固定优先级机械套到 AW/W。

性能分析时应分别统计“来源提出 dp_req”“真正 req”“被选中”“BIU ready/grant”
四层事件。只有 req 长期存在而 grant 缺失才是下游/仲裁阻塞；仅有 dp_req
而 req 被屏蔽，原因仍在来源模块自己的地址冲突、顺序或状态条件。
## 5. spec_fail_predict —— 违例恢复附近的地址相关跟踪

这个模块名称容易让人误以为它是一张“按 load PC 索引、长期学习历史”的预测
表，但 RTL 接口中**没有 PC 输入，也没有 PC hash 表**。它保存的是短期的
store 冲突信息：

| 临时记录 | 保存内容 | 建立与使用 |
|----------|----------|------------|
| `sf_start_*` | store `PA[39:4]`、`bytes_vld[15:0]`、store IID | `st_da_sf_no_spec_miss`先记录候选；只有 RTU 后来以相同 IID 通报 spec-fail flush，记录才进入有效匹配状态；重放 load 与地址块、字节掩码重叠时产生 `sf_spec_mark` |
| `sf_mispred_chk_*` | store `PA[39:4]`、`bytes_vld[15:0]`、IID | `st_da_sf_spec_chk`建立检查记录；后续 load 重叠时产生 `sf_spec_hit`，用于检查 no-spec 选择是否命中真实冲突 |

两个记录都会在匹配 load 出现、flush/新事件覆盖或检查计数达到 12 等条件下
清理，属于围绕一次冲突和恢复窗口的地址相关器，而不是跨越任意长时间保留的
分支预测器式学习表。

`ld_da`根据 `sf_spec_mark`、`sf_spec_hit` 与本条 load 的 `no_spec` 属性产生
`no_spec_miss/hit/mispred`完成信息。因而分析链应写成：

```text
store 在 DA 暴露 no-spec/spec-check 事件
  -> 记录具体 store 的地址块、字节掩码和 IID
  -> RTU 的 spec-fail IID 确认该候选是否对应真实恢复
  -> 重放/后续 load 按地址与字节重叠得到 mark/hit
  -> 完成路径报告 no-spec 策略的命中或误判
```

真正按取指 PC 维护 Store-Fetch Prediction 状态的是 IFU 中的
`ct_ifu_sfp.v`。两者可能服务于相关的依赖预测目标，但模块输入、状态寿命和
职责不同，文档不能把 LSU 的地址相关器直接写成 IFU 的 PC 预测表。

## 6. ctrl —— 全局排序控制

`ctrl`汇总 load/store 各级 restart、等待与唤醒来源，生成到 LSIQ 的
`lsu_idu_wakeup/wait_*`位图，并集中产生 load/store/special 门控时钟、HPCP
事件和 LSU no-op/debug 汇总。fence/sync 的事务状态本身主要保存在 RB/WMB
等结构中：`lsu_has_fence`及其反相信号 `lsu_idu_no_fence`实际由
`ct_lsu_rb.v`维护，再送给 ctrl 和其他模块使用，不能把该信号写成 ctrl 原生
生成。

教学上可以把屏障理解为“等待规定范围内更老内存操作达到所需可见点”，但不能
机械写成“SQ/WMB/RB/LFB/VB 五个队列全空才放行所有屏障”：不同指令、页面
属性和状态机阶段的完成条件并不完全相同。性能计数也应由当前 testbench 对
具体 stall 信号的采样定义确认。

## 7. mcic —— MMU Cache Interface Controller（PTW 读取 PTE 的 LSU 桥）

`ct_lsu_mcic`不是 cache maintenance/invalidate 控制器。它接收 MMU/PTW
发出的 `mmu_lsu_data_req` 和物理地址 `mmu_lsu_data_req_addr[39:0]`，把一次
64-bit PTE 读取接入 LSU 已有的 D-cache、load DA、RB 和 BIU 数据通路。这里的
“MCIC”应理解为 **MMU Cache Interface Controller**。

一次请求按 RTL 可分成以下阶段：

```text
MMU/PTW 保持 data_req 与物理地址
  -> MCIC 请求 D-cache load tag/data 端口
  -> dcache_arb grant 后，mcic_frz 置位，禁止同一请求重复申请阵列
  -> load DA 判断：
       hit / data error -> 经 ld_da_mcic_bypass_data 或错误完成返回
       miss 且 RB 可用 -> RB 建立读事务，MCIC 记录分配到的 BIU AR ID
       miss 但 RB full -> 等 rb_mcic_not_full 后解除 freeze 并重试
  -> BIU R 通道出现匹配 ID -> 按地址 bit 3 从 128-bit beat 选出目标 64 bit
  -> lsu_mmu_data_vld/data/bus_error 返回 MMU/PTW
```

几个微小但重要的时序语义：

- `mmu_lsu_data_req=1`只表示 MMU 正在提出请求；只有
  `dcache_arb_mcic_ld_grnt=1`才表示本次 D-cache 访问已被仲裁接受；
- `mcic_frz`在 grant 后的时钟沿置位，是“该请求已进入 LSU、先不要重复发起”
  的状态，不是 D-cache miss 信号；它会在本地数据返回、LFB/DA 唤醒或 RB
  重新可用后清除；
- D-cache 命中数据来自 `ld_da_mcic_bypass_data`。D-cache miss 后，
  `rb_mcic_biu_req_success`才表示 RB 已成功取得总线读事务 ID；
- `biu_lsu_r_vld=1`本身不等于该 PTE 已返回，还必须满足
  `biu_lsu_r_id == mcic_ar_id`；总线错误也只在这次匹配响应上由
  `lsu_mmu_bus_error`报告；
- MCIC 用物理地址 `[14:6]`访问 D-cache tag，并按地址 `[3]`选择返回 beat
  中的低/高 64 bit。它不负责修改 TLB，也不实现 `sfence.vma`。

体系结构上，这条桥接路径使页表项可能命中本核 D-cache；miss 时再复用正常
的 RB/BIU 请求能力，而不为 PTW 单独建一套数据 cache 和总线主口。代价是 PTW
读取会与普通 load、回填及其他 D-cache 使用者竞争资源，因此“PTW 已发请求”
不能直接推导为“PTE 已在某个固定周期返回”。

## 8. rot_data / cache_buffer / idfifo_8

- **rot_data**：64-bit 字节旋转网络。输入虽然是 128 bit，但 RTL 先把
  `data_in[63:0] | data_in[127:64]` 合成一个 64-bit 候选，再由 one-hot
  `rot_sel[7:0]` 选择循环右移 0～7 字节的结果，输出高 64 bit 恒为 0。
  上游必须保证两个输入半部不会在同一结果位提供互相冲突的数据；它不是任意
  128-bit barrel shifter。该组合件用于按地址低 3 位把 load/store 数据归一
  到 64-bit 标量位置；
- **cache_buffer**：不是 VB/snoop 的通用 borrow 缓冲。它保存一份
  `PA[39:4] + 128-bit`近期 load cache 数据，服务 `acclr_en` 的跨 16B
  边界加速路径：后续子访问若 `addr1`命中该地址块，DA 可把 buffer 中字节与
  当前 cache 数据按 `bytes_vld1`合并。D-cache 写中同 index、cache disable、
  ICC 活动、no-op 请求或当前 load 未重新提供有效数据都会使该项失效；
- **idfifo_8**：8 深 ID FIFO 模板，使用带回绕位的 4-bit create/pop pointer，
  8 个 entry 只存 3-bit ID；`idfifo_pop_id_oh`把当前队首 ID 解码成 one-hot。
  WMB 用两个实例记录固定 NC/SO B 响应应归属的 WMB entry，RB 也复用该模板
  处理共享响应 ID。它保存的是 ID 顺序，不保存请求地址或数据。

## 9. 阅读完成后的全景自检

至此 LSU 文档完结。检验掌握程度的三个问题：

1. 一条 store 从发射到数据可被外核看到，经过哪 6 个结构？
   （st_ag/dc/da → SQ → WMB → dcache（或 BIU），途中 RTU 退休触发提交）
2. load 读到错数据的两种风险与各自的检测/恢复位置？
   （越过老 store：LQ RAW 检测、RTU 精确恢复，并由 IFU/LSU 的相关 no-spec
   机制减少重复冲突；前递数据未就绪或覆盖关系不满足：SQ/WMB discard/replay）
3. perf 报表里 LSU 相关的 8 个计数分别由哪个模块产生？
   （见 README 的对应表，逐一回指模块）

能回答则 LSU 部分达成学习目标。
