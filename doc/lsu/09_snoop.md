# C910 缓存一致性侦听详解（snoop_snq / snoop_ctcq / snoop_resp / snoop_req_arbiter）

> RTL 源文件：
> - `ct_lsu_snoop_snq.v`（1841 行）+ entry（964 行）×6 —— 侦听队列（主体）
> - `ct_lsu_snoop_ctcq.v`（730 行）—— core-to-core 传输队列
> - `ct_lsu_snoop_resp.v` / `ct_lsu_snoop_req_arbiter.v` —— 应答与请求仲裁
>
> 多核 C910 经 CIU（doc 外模块）互联，外核的访存请求会以 snoop 形式打进
> 本核 LSU，要求查询/降级/交出 D-cache 中的行。

---

## 1. snoop 处理全流程（snq.v 的三个状态机）

```
CIU snoop 请求 ──► SNQ 创建（6 项，L500-575）
   │ 选最老可发项（L576-632）
   ▼
读 dcache tag（借 ld 管线，L633-695）→ 命中?
   │
   ├─ 未命中: 直接应答 "I don't have it"
   │
   ├─ 命中且无需数据(如 invalidate): 改 tag 状态 → 应答
   │
   └─ 命中需数据(读共享/读独占):
        SNPDT FSM（L733-948）: 分两次读 data 阵列(256b×2=64B, L869-871)
        → 数据进 sdb(2 项数据缓冲, L1012-1095)
        → CDR FSM(L950): 经 ctcq 把数据传给请求核 / 写回
        同时按 snoop 类型降级行状态: M/E→S 或 →I
```

三个嵌套 FSM 的分工：**SNPT**（per-entry，tag 阶段）启动 **SNPDT**
（共享单例，数据读取）再交 **CDR**（数据应答传输）——tag 查询可多项流水，
数据搬运串行复用，与 LFB 的 addr 多/data 少同一哲学。

## 2. 与本地访问的互锁

snoop 与本核在飞操作的竞争是一致性协议最难的部分：

- snoop 命中 **LFB 在飞行**：refill 没完成，snoop 等待或按协议 stall；
- snoop 命中 **WMB 已提交写**：写必须先落地或合并应答（05_wmb.md 提及的互锁）；
- snoop 命中 **LQ 中已完成的 load**：触发 RAR spec fail 语义的基础——
  这正是 03_lq.md 中"多核下同地址 load 乱序"违例的物理来源；
- dcache 口竞争：snq 优先级最高（07_dcache.md），外核在等，本核让路。

## 3. ctcq（Core-To-Core Queue）

缓存到缓存的直接传输（cache-to-cache transfer）：被侦听核直接把数据给
请求核，绕过内存——多核共享数据的关键加速。ctcq 管理这些在途传输的
请求/应答配对（reqq/respq 项见 ciu 侧的 ctcq 模块）。

## 4. 单核仿真下的观察

smart_run 默认单核，CIU 不会发真实 snoop，SNQ 基本静默。要看 snoop 活动
需要多核平台或 ISA_BARRIER/cache 维护指令间接触发（icc 的 clean/inval 广播
路径）。因此本模块建议**读懂结构即可**，波形验证留待多核环境。

## 5. Verdi 观察建议

层次：`...x_ct_lsu_top.x_ct_lsu_snoop_snq`

| 信号 | 看什么 |
|------|--------|
| snq entry vld ×6 | 侦听压力 |
| SNPDT/CDR FSM 状态 | 数据应答流程 |
| 与 dcache_arb 的 req/grnt | 抢口优先权 |
