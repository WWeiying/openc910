# C910 CIU 文档索引

CIU 连接真实核 PIU、两个 SNB、共享 L2、非相干路径和片外总线。本文档组以当前
OpenC910 RTL 为准，并明确区分当前双核配置、预留接口和体系结构背景。

## 阅读顺序

| 文档 | 主要内容 |
|------|----------|
| [00_ciu_overview.md](00_ciu_overview.md) | 有效双核配置、全局数据流、一致性事实边界和波形阅读方法 |
| [01_ciu_piu.md](01_ciu_piu.md) | AR/AW 分类，AC/CR/CD 的 FIFO、握手、关联以及 dummy 行为 |
| [02_ciu_snb_sab.md](02_ciu_snb_sab.md) | 双 SNB、24 项 SAB、512-bit 数据、cp 过滤、14 态 FSM、依赖和年龄 |
| [03_ciu_ctcq_vb.md](03_ciu_ctcq_vb.md) | CTC/DVM 维护 reqq/respq、双 bank completion 和两项 VB |
| [04_ciu_ncq_ebiu_regs.md](04_ciu_ncq_ebiu_regs.md) | NCQ、GM、EBIU、L2CIF、BMBIF、APBIF 和 CIU regs |

## 当前配置的关键数字

| 项目 | 当前 RTL |
|------|----------|
| 真实 PIU | PIU0、PIU1 |
| coherent dummy | PIU2、PIU3 |
| dummy-device | PIU4，当前不产生有效请求 |
| SNB | 2 个，PA[6] 分 bank |
| 每个 SAB | 24 项：16 读、8 写 |
| 单个 SAB entry 数据 | 4 x 128 bit |
| presence/filter 元数据 | `cp[3:0]` |
| SAB 主 FSM | 14 态 |
| CIU CTCQ | reqq 8 项、respq 16 项 |
| VB | 2 个 AW entry |
| NCQ WOQ / DSQ | 各 16 项 |
| EBIU NCWT / CAWT | 16 / 32 项 |

当前配置还实例化 `ct_ebiu_snoop_channel_dummy`：片外 AC 输入固定无效，
外部 CR/CD 返回也未启用。文档中出现的外部 snoop/DVM 比较器和状态机是保留
结构，不等于当前顶层已有端到端外部 snoop/DVM 功能。

## 必须避免的五个误解

1. **CIU CTCQ 不是 cache-line 数据直传队列。** 它处理 CTC/DVM 缓存与 TLB
   维护；实际 coherence data response 的同名 CTCQ 位于 LSU snoop。
2. **不能仅凭 CIU RTL 宣称显式完整 MOESI/O 状态机。** 当前能证明的是
   ACE 风格请求、shared/unique 和 dirty/clean 组合、CR/CD、cp 过滤及更新。
3. **SAB 不是无数据目录项。** 每项有四个 128-bit 数据寄存器以及 byte
   select、错误和有效状态。
4. **PIU4 不是当前可用 DMA 入口。** `ct_piu_top_dummy_device` 的请求与返回
   路径固定无效。
5. **当前 EBIU 不是完整外部 snoop 节点。** AR/R/AW/W/B、RACK/BACK 和
   ACE 风格属性是活跃路径，但 AC/CR/CD 由 dummy/tie-off 关闭，不能凭保留的
   DVM 或 CAWT snoop 比较逻辑声称外部一致性接收已启用。

## 统一波形语义

阅读所有分册时都按以下顺序判断：

```text
请求 valid/req
  -> 本级 ready/grant
  -> 时钟沿后的 FIFO/entry/FSM 更新
  -> 目标模块真正接受并执行
  -> completion 或 R/B/CR/CD 返回
  -> 原始发起端最终接受
```

“请求被提出”“进入缓冲”“目标完成”和“原发起端看到完成”是不同事件。文档
对 grant、completion、pop 和返回握手均按这一原则解释。
