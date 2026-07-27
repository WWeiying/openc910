# C910 BIU（总线接口单元）学习文档索引

> 本套文档基于 OpenC910 RTL 源码（`C910_RTL_FACTORY/gen_rtl/biu/rtl/`），
> 逐文件、带 file:line 地讲清 BIU 的职责、结构、ACE 协议与设计取舍。教学导向，全中文。

## 目录结构

| 文件 | 内容 | 对应 RTL（行数） | 适合阶段 |
|------|------|------------------|----------|
| [00_biu_overview.md](00_biu_overview.md) | BIU 是每核 ACE 主端口；完整外出路径 核→BIU→CIU→L2→DDR；BIU 与 CIU 分工；ACE/128bit/AXI ID；两大通用思想；关键设计决策汇总 | `ct_biu_top.v`(1254) + 全模块综述 | 先读，建立全局观 |
| [01_biu_read_write.md](01_biu_read_write.md) | read_channel（2 项 ping-pong、按 AXI ID 路由 IFU/LSU、RACK 自发）+ write_channel（12 项保序写 FIFO、store/victim 两路、victim 优先、三缓冲、BACK 自发） | `ct_biu_read_channel.v`(740) + `ct_biu_write_channel.v`(1078) | 第一个精读 |
| [02_biu_snoop.md](02_biu_snoop.md) | snoop_channel：AC/CR/CD 三通道、转发给 LSU SNQ、snoop_vld 防熄火、ACE 一致性全景 | `ct_biu_snoop_channel.v`(563) | 一致性核心 |
| [03_biu_arbiters_lp.md](03_biu_arbiters_lp.md) | req_arbiter（读 LSU>IFU、ID 拼装、写两路直通）+ csr_req_arbiter（CP0>HPCP）+ lowpower（12 门控时钟 + no_op）+ other_io_sync（中断/调试 2 级同步、L2 CSR 寄存） | `ct_biu_req_arbiter.v`(567) + `ct_biu_csr_req_arbiter.v`(101) + `ct_biu_lowpower.v`(360) + `ct_biu_other_io_sync.v`(445) | 配套机制 |

合计覆盖 8 个 RTL 文件、5108 行逻辑。

## 两个必须掌握的通用思想

| 思想 | 一句话 | 在哪落地 |
|------|--------|----------|
| ① **AXI ID = 乱序事务的名牌** | 发请求挂 ID，响应回来认 ID 分发；与 ROB-IID、LSU-MSHR 同一方法论 | req_arbiter 盖名牌(`:465`) → read_channel 认名牌(`:528-536`) |
| ② **ACE 让一个端口演主+从两角** | 同一 BIU 端口既主动访存(read/write 通道=主)，又被动响应侦听(snoop 通道=从)，一致性是对称的 | read/write_channel(主) + snoop_channel(从) + snoop_vld 防熄火 |

## 推荐学习路径

```
第一轮（建立全局观）
  └── 00_biu_overview.md
        重点：核→BIU→CIU→L2→DDR 全程、BIU vs CIU、AXI ID、ACE 主+从

第二轮（主角色：主动访存）
  └── 01_biu_read_write.md
        重点：2 项 ping-pong 怎么背靠背、rid 怎么路由、12 项 FIFO 怎么保序、victim 为何优先

第三轮（从角色：响应侦听）
  └── 02_biu_snoop.md
        重点：AC/CR/CD 三通道、BIU 只转发不判定、snoop_vld 为何用 forever_coreclk

第四轮（配套机制）
  └── 03_biu_arbiters_lp.md
        重点：三处优先级哲学、门控粒度、CDC 2 级同步
```

## 学习提示

- BIU 是"薄边界层"，不是大缓冲：每通道只放 1~2 项，写 FIFO 12 项是保序刚需。
  真正的缺失队列在 LSU，乱序排队在 CIU/L2。
- 看到 `for timing` / `to cut timing` 注释要留意：BIU 大量结构（三写缓冲、位移 FIFO、
  选源前瞻、valid/data 拆分门控）都是为时序和背靠背服务。
- 抓住两个通用思想，三大通道一通百通。
