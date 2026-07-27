# C910 L2 Cache 学习文档索引

L2 Cache 是 C910 的二级统一缓存，也是 cluster 内多核一致性的汇聚点与侦听过滤器载体：
**1MB / 16 路 / 64B 行 / 1024 组（物理上 2 个 sub-bank × 512 组并行）/ PIPT / FIFO 替换 /
tag SECDED ECC / 5 级流水（tag→cmp→data→wb→icc）/ 可编程访问延迟 / 指令+TLB 预取 / wb 级 3 项响应 rfifo**。

## 目录结构

| 文件 | 内容 | 适合阶段 |
|------|------|----------|
| [00_l2c_overview.md](00_l2c_overview.md) | L2 总体架构、几何参数、5 级流水、作为一致性汇聚点+snoop filter、完整访问数据流、设计决策汇总 | 先读，建立全局观 |
| [01_l2c_tag_status.md](01_l2c_tag_status.md) | Tag 阵列 + `status[7:0]={cp[3:0],valid,shared,dirty,pend}` 编码 + tag SECDED ECC + FIFO 替换（l2c_way_fifo） | tag/一致性状态核心 |
| [02_l2c_data.md](02_l2c_data.md) | Data 阵列组织、bank 划分、数据通路、可编程访问延迟 | 数据存储 |
| [03_l2c_pipeline.md](03_l2c_pipeline.md) | 比较流水（cmp）、sub-bank 双 bank 并行、顶层连接、命中/选路 | 流水线核心 |
| [04_l2c_prefetch_icc_wb.md](04_l2c_prefetch_icc_wb.md) | 指令+TLB 预取、ICC（核间一致性/维护/DCA/flush）、响应 rfifo（3 项×14 位） | 预取/一致/写回 |

## 推荐学习路径

```
第一轮（建立全局观）
  └── 00_l2c_overview.md

第二轮（存储与状态）
  └── 01_l2c_tag_status → 02_l2c_data

第三轮（流水线与控制）
  └── 03_l2c_pipeline

第四轮（预取/一致性/写回）
  └── 04_l2c_prefetch_icc_wb
```

## 关键数字速查

```
容量/组织      1MB / 16 路 / 64B / 1024 组 = 2 sub-bank × 512 组
索引           每 bank tag index = 9 bit；data index = 13 bit
替换           FIFO（每组 16-bit 轮转指针 l2c_way_fifo）
保护           tag/dirty SECDED ECC（ct_l2c_tag_ecc）；data ECC 本 build 关闭
流水           5 级：tag → cmp → data → wb → icc；访问延迟可编程（tag≤5 / data≤9 拍）
状态位         status[7:0] = {cp[3:0], valid, shared, dirty, pend}（MOESI 编码）
cp 位图        最多 4 核 presence bitmap，兼任 snoop filter
预取           指令预取(iprf) + TLB 预取(tprf)
写回响应       wb 级 3 项 rfifo（每项 14 位=resp+cp+sid），缓存无数据的纯响应
共享           cluster 内 2 核共享，L2 是一致性汇聚点（详见 doc/ciu/）
```

> 配套：体系结构总览见 `doc/C910_体系结构总览.md` 第 8.4 节；多核一致性与 CIU 见 `doc/ciu/`。
