# C910 BIU（总线接口单元）学习文档索引

> 本套文档基于 OpenC910 RTL 源码（`C910_RTL_FACTORY/gen_rtl/biu/rtl/`），
> 逐文件、带 file:line 地讲清 BIU 的职责、结构、ACE 协议与设计取舍。教学导向，全中文。

## 目录结构

| 文件 | 内容 | 对应 RTL（行数） | 适合阶段 |
|------|------|------------------|----------|
| [00_biu_overview.md](00_biu_overview.md) | 每核 BIU 与 CIU 的边界；请求/接受/完成的区别；ACE 通道、固定 ID 分类及局部缓冲边界 | `ct_biu_top.v`(1254) + 全模块综述 | 先读，建立全局观 |
| [01_biu_read_write.md](01_biu_read_write.md) | read_channel（2 项 AR/R 槽、固定 ID 分类、RACK）+ write_channel（12 项写来源队列、store/victim、三数据槽、BACK） | `ct_biu_read_channel.v`(740) + `ct_biu_write_channel.v`(1078) | 第一个精读 |
| [02_biu_snoop.md](02_biu_snoop.md) | AC/CR/CD 三通道、两项缓冲、LSU 转发边界、粗粒度 snoop 活动锁存 | `ct_biu_snoop_channel.v`(563) | 一致性核侧接口 |
| [03_biu_arbiters_lp.md](03_biu_arbiters_lp.md) | 读/CSR 固定选择、ready 与接受的区别、12 个局部门控、`no_op` 边界、中断/调试同步与其它单级寄存 | `ct_biu_req_arbiter.v`(567) + `ct_biu_csr_req_arbiter.v`(101) + `ct_biu_lowpower.v`(360) + `ct_biu_other_io_sync.v`(445) | 配套机制 |

合计覆盖 8 个 RTL 文件、5108 行逻辑。

## 两个必须掌握的通用思想

| 思想 | 一句话 | 在哪落地 |
|------|--------|----------|
| ① **AXI ID 用于固定分类** | IFU 读拼 `10000/10001`，返回精确匹配这两个值；其余返回送 LSU | req_arbiter 拼 ID(`:465`) → read_channel 分类(`:528-536`) |
| ② **一个端点同时发起访存并响应 snoop** | read/write 处理主动事务，AC/CR/CD 处理被侦听事务；两组通道方向不同 | read/write_channel + snoop_channel |

## 推荐学习路径

```
第一轮（建立全局观）
  └── 00_biu_overview.md
        重点：核→BIU→CIU 边界、BIU vs CIU、ID 固定分类、ACE 双向通道

第二轮（主角色：主动访存）
  └── 01_biu_read_write.md
        重点：两项缓冲如何握手、rid 精确匹配、12 项来源队列及无 full 约束

第三轮（从角色：响应侦听）
  └── 02_biu_snoop.md
        重点：AC/CR/CD 三通道、BIU 只转发不判定、snoop_vld 为何用 forever_coreclk

第四轮（配套机制）
  └── 03_biu_arbiters_lp.md
        重点：三处固定选择、门控实际使能、只有中断/调试使用双触发器同步
```

## 学习提示

- BIU 是浅边界缓冲，不是完整 outstanding 表。12 项结构只记录有数据写事务的
  store/victim 来源，且没有显式 full 反压。
- `ready/grnt` 多数表示本地容量；必须与对应 `valid/req` 同时成立才是接受事件。
- `no_op` 只观察本地 read/write 状态，不等价于系统无在途事务。
- 看到 `for timing` / `to cut timing` 注释要留意：BIU 大量结构（三写缓冲、位移 FIFO、
  选源前瞻、valid/data 拆分门控）都是为时序和背靠背服务。
- 抓住两个通用思想，三大通道一通百通。
