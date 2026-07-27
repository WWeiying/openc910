# C910 Write Merge Buffer 详解（ct_lsu_wmb）

> RTL 源文件：`ct_lsu_wmb.v`（4749 行）+ `ct_lsu_wmb_entry.v`（2329 行）×8
> + `ct_lsu_wmb_ce.v`（626 行，SQ→WMB 的创建打包级）
>
> WMB 收容**已提交**的 store，做相邻写合并，再写入 dcache 或经 BIU 写出。
> 它是 LSU 中唯一"flush 也不能清"的队列——里面全是体系结构已承诺的写。

---

## 1. 为什么要在 SQ 之后再加一级 WMB

| 动机 | 说明 |
|------|------|
| **写合并** | 连续小写（memset/结构体填充）合并成整行写，dcache 写口和 AXI 带宽利用率倍增；整行合并满还能触发 amr 写分配优化（不读内存直接写，10_misc.md） |
| **解耦提交与写出** | store 退休即可让出 SQ 项（SQ 是昂贵的 CAM 结构），写 cache 的慢动作交给便宜的 WMB |
| **写序管理** | normal 内存允许写合并乱序写出，但 NC（非缓存）/SO（强序，设备）必须按序——WMB 用两个 idfifo 单独串序 |
| **前递延伸** | 数据在 WMB 期间仍可被 load 前递（与 SQ 同协议），保证"提交但未写出"窗口的可见性 |

## 2. 结构（wmb.v）

```
SQ 弹出 ──► wmb_ce(打包/对齐) ──► 8 项 entry（地址+64B数据+bytes_vld+属性）
                                     │
            ┌────────────────────────┼──────────────────┐
            ▼                        ▼                  ▼
       命中: 写 dcache          miss/NC/SO: 走 BIU    被 load 查前递
       (抢 dcache_arb 写口)     (抢 bus_arb)
```

- **NC FIFO / SO FIFO**（L1418-1504，两个 `ct_lsu_idfifo_8`）：记录 NC/SO
  项的进入次序，写出严格按 FIFO 弹出——设备寄存器写序错乱是致命 bug，
  普通内存则不进 FIFO、可合并乱序；
- **多指针体系**（L3076-3414）：read ptr（下一个写出候选）、write ptr
  （写 dcache 进度）、data ptr 分立，"Select signal from read/write/data ptr"
  把三种视角的项选出来并行处理；
- **write imme**（L3624）：水位/屏障触发立即写出模式，否则可懒散合并等待
  更多合并机会；
- **write burst**（L3700-3719 "last create pop entry"）：连续地址项凑 AXI
  burst 写出。

## 3. entry 内部（wmb_entry.v，2329 行）

每项是一个小状态机：等数据合并 → 请求写出 → 等 grnt →（cache 路）写 tag/
dirty/data →（BIU 路）等 AXI bresp → 释放。支持同项多次合并写入
（bytes_vld 按位或累积，数据按字节覆盖）。还带与 ld_dc 的前递比较器
（与 SQ entry 同协议）。

## 4. 一致性配合

WMB 写 dcache 前要确认行处于可写状态（M/E），否则触发升级请求（经 LFB 走
read-for-ownership）；snoop 命中 WMB 在飞写时有专门的互锁（snq 与 wmb 的
握手）——这些细节在 entry 状态机里占了相当篇幅，初学可先跳过，记住结论：
**WMB 的写出与 MESI 状态机耦合，不是无脑写**。

## 5. Verdi 观察建议

层次：`...x_ct_lsu_top.x_ct_lsu_wmb`

| 信号 | 看什么 |
|------|--------|
| entry vld ×8 | WMB 水位（写密集时满 → 反压 SQ 弹出 → SQ 满 → st_dc restart 的连锁） |
| 合并发生（同项 bytes_vld 增长） | memset 类代码很容易看到 |
| NC/SO fifo 进出 | 设备访问的强序 |
| 写 dcache grnt vs BIU 写 grnt | 命中/缺失两条写出路 |

跑 hello_world（uart 写 = SO 设备写）可同时看到 SO FIFO 与普通合并两种行为。
