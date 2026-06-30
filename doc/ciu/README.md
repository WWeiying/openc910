# C910 CIU 学习文档索引

CIU（Coherence Interconnect Unit，一致性互联单元）把多核 BIU 汇聚，做缓存一致性（MOESI + 侦听过滤），并对接 L2 Cache 与片外总线。

RTL 位于 `C910_RTL_FACTORY/gen_rtl/ciu/rtl/`（37 个 `.v` 文件，约 34600 行）。

## 目录结构

| 文件 | 内容 | 适合阶段 |
|------|------|----------|
| [00_ciu_overview.md](00_ciu_overview.md) | CIU 职责、5 个 PIU 端口、子模块全景、完整侦听数据流、MOESI 与 cp 位图侦听过滤、CTC/Owned、Evict 通知、关键设计决策 | 先读，建立全局观 |
| [01_ciu_piu.md](01_ciu_piu.md) | PIU 每核接入口：AR/AW 请求路由、AC/CR/CD 侦听三通道、dummy 与 dummy_device 变体、other_io | 第一个精读 |
| [02_ciu_snb_sab.md](02_ciu_snb_sab.md) | SNB 双 bank 侦听广播 + SAB 24 项过滤器（16 读+8 写）、cp 位图、14 态主 FSM、每核子 FSM、acsnoop 类型、年龄向量仲裁、DEPD | 一致性核心（重点） |
| [03_ciu_ctcq_vb.md](03_ciu_ctcq_vb.md) | CTCQ cache-to-cache 传输（reqq×8 + respq×16）、MOESI Owned 直传、DVM 同步、VB 逐出缓冲（2 项）、地址依赖 | 直传与逐出 |
| [04_ciu_ncq_ebiu_regs.md](04_ciu_ncq_ebiu_regs.md) | NCQ 非相干队列、ncq_gm 独占监视、EBIU AXI 主口（读/写通道 + NCWT×16/CAWT×32）、L2CIF 双 bank、BMBIF、APBIF、CIU regs（smpen/sf_dis） | 非相干与对外 |

## 推荐学习路径

```
第一轮（建立全局观）
  └── 00_ciu_overview.md

第二轮（核接入与侦听通道）
  └── 01_ciu_piu.md          PIU：AC/CR/CD 三通道、5 个端口角色

第三轮（一致性核心，重点）
  └── 02_ciu_snb_sab.md      SNB 广播 + SAB 侦听过滤 + 14 态主 FSM

第四轮（直传与逐出）
  └── 03_ciu_ctcq_vb.md      CTCQ cache-to-cache、VB 逐出缓冲

第五轮（非相干与对外）
  └── 04_ciu_ncq_ebiu_regs.md  NCQ、EBIU(AXI)、L2CIF、APB、寄存器
```

## 核心概念速查

| 概念 | 一句话 | 详见 |
|------|--------|------|
| 5 个 PIU 口 | piu0-3 相干（2 实 2 dummy）+ piu4 非相干设备口 | 00 §3 / 01 |
| cp 位图 | L2C tag 里每条 line 配 `cp[3:0]`，记哪些核缓存了它 | 00 §5 / 02 §5 |
| Snoop Filter | `cp_after_mask = cp & ~自己 & smpen`，只侦听真正持有的核，不广播 | 00 §6 / 02 §6 |
| MOESI O 态 | 脏行降级 Owned 后核间直传（CTC），绕过内存 | 00 §8 / 03 §4 |
| Evict 通知 | 干净行替换也要上报清 cp，否则过滤退化 | 00 §9 / 02 §10 |
| 14 态主 FSM | 每个 SAB 项一个状态机，管完整一致性事务 | 02 §7 |
| 双 bank | 按地址 bit[6] 分 SNB0/SNB1，奇偶 line 并行 | 01 §5 / 02 §1 |

## 关键数字（均带 file:line，见各文档）

- PIU 端口：5（`ct_ciu_top.v:2041-2664`）
- SNB bank：2（`ct_ciu_top.v:2745,2934`）
- SAB 项：24 = 16 读 + 8 写（`cpu_cfig.h:468-470`）
- cp 位图宽度：4（`ct_ciu_snb_sab_entry.v:1940`）
- 主 FSM 状态：14（`ct_ciu_snb_sab_entry.v:677-690`）
- CTCQ reqq：8，respq：16（`ct_ciu_ctcq.v:212,514`）
- VB AW 项：2（`ct_ciu_vb.v:219`）
- NCQ WOQ：16（`ct_ciu_ncq.v:1236`）
- EBIU NCWT：16，CAWT：32（`ct_ebiu_write_channel.v`）
