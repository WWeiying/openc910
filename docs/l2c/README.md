# C910 L2 Cache 学习文档索引

L2 Cache 是 C910 的二级统一缓存，也是 cluster 内一致性目录信息的保存点之一。当前启用配置为：

**1 MiB / 16 路 / 64 B 行 / 1024 个全局 set / 2 个 sub-bank / PIPT / 轮转式近似 FIFO 替换 / tag、data 访问延迟可配置 / 指令与 TLB next-line 预取 / 3 项纯响应 rfifo。**

这里有四个必须先分清的边界：

1. 两个 sub-bank 由物理地址 `PA[6]` 直接选择，不是哈希，也不代表“两颗核”。
2. 普通数据路径是 `tag -> cmp -> data -> wb`；ICC 是主流水排空后接管 SRAM 端口的维护/DCA 引擎，不是第五个顺序流水级。
3. `cp[3:0]` 由 L2C 保存并返回，CIU 再根据它产生逐 PIU snoop；L2C 不是独自完成全部一致性路由。
4. 开源版 ECC 仅保留接口、结构和注释骨架：tag/status 读出直通、fatal error 恒 0，ECC SRAM 未实例化，不能写成当前已启用 SECDED 保护。

## 目录结构

| 文件 | 内容 | 适合阶段 |
|------|------|----------|
| [00_l2c_overview.md](00_l2c_overview.md) | L2 总体架构、精确地址位映射、请求/接收/完成边界、主流水与 ICC、普通 miss 的 CIU/L2C 分工 | 先读，建立全局观 |
| [01_l2c_tag_status.md](01_l2c_tag_status.md) | Tag 阵列、`status[7:0]={cp[3:0],valid,shared,dirty,pend}`、替换与 refill 指针、ECC 预留边界 | tag/一致性状态核心 |
| [02_l2c_data.md](02_l2c_data.md) | Data 阵列组织、bank 划分、数据通路、可编程访问延迟 | 数据存储 |
| [03_l2c_pipeline.md](03_l2c_pipeline.md) | cmp 状态更新、victim CleanInvalid 请求、sub-bank 装配、顶层 flush 与握手 | 主流水控制核心 |
| [04_l2c_prefetch_icc_wb.md](04_l2c_prefetch_icc_wb.md) | 指令/TLB 预取、ICC 整体维护、DCA 诊断读、RDL 脏行下推、响应 rfifo | 预取/维护/响应 |

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
地址           PA[39:16]=tag；PA[15:7]=local set；PA[6]=sub-bank；PA[5:0]=行内偏移
替换           每组 16-bit 轮转式选择字段；allocate 选 victim，refill 另找 !valid & pend
保护           ECC 通路预留但当前未启用实际纠错；fatal error 恒 0
主流水         tag → cmp → data → wb；ICC 为排空后互斥运行的维护/DCA 引擎
状态位         status[7:0] = {cp[3:0], valid, shared, dirty, pend}
cp 位图        4-bit presence bitmap；L2 返回目录信息，CIU 生成逐 PIU snoop
预取           指令预取(iprf) + TLB 预取(tprf)
写回响应       wb 级 3 项 rfifo（每项 14 位=resp+cp+sid），缓存无数据的纯响应
RDL            仅用于 ICC clean/flush 的脏行下推，不是普通 read miss 的下级读
```

> 配套：体系结构总览见 `docs/C910_体系结构总览.md`；一致性事务、侦听路由与 CIU 见 `docs/ciu/`。
