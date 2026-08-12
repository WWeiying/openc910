# Arm Cortex-A73 微信公众号发布资料

## 正式发布信息

- 正式标题：Arm Cortex-A73：资源上限？那是什么
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2024 年 7 月 18 日
- 英文标题：Arm’s Cortex A73: Resource Limits, What are Those?
- 文章链接：https://chipsandcheese.com/p/arms-cortex-a73-resource-limits-what-are-those
- 阅读原文链接：https://chipsandcheese.com/p/arms-cortex-a73-resource-limits-what-are-those

### 摘要

从 27 张图理解 Cortex-A73：两宽前端、Slot-based 乱序、通用 AGU、低延迟 L1D，以及 S922X 的共享 L2 和 32-bit DDR4 如何塑造最终表现。

### 封面文案

主标题：Cortex-A73

副标题：资源上限？那是什么

### 分享文案

测不出传统 ROB 上限，不等于没有资源限制。27 张图看 A73 如何收窄前端、折叠已完成状态、重排执行端口，并用持续性能赢回手机 SoC。

### 备选标题

- Cortex-A73：一次从峰值性能转向持续能效的设计
- 27 张图看懂 Cortex-A73 的 Slot-based 乱序执行
- Cortex-A73 架构分析：两宽核心如何赢回 Qualcomm

### 文章标签

- Arm Cortex-A73
- Amlogic S922X
- CPU 微架构
- 乱序执行
- 分支预测
- Load Store
- Cache 与 TLB

### 所属栏目

CPU 微架构

## 图片资料

- 正文图片：27 张；目录：`arm_cortex_a73_figures/`；顺序：`01` 至 `27`
- 图 17、18 有网页正式图注，图 24 正式注明来自 Amlogic S922X 数据表；其他中文图注用于辅助读图
- 图 4、5、8、17、18 为高密度曲面或矩阵，移动端保留点击查看
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，可使用 Odroid N2+ 或 A73 Slot-based/两宽核心示意
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- BTB、RAS、ROB、AGU、TLB、SCU、VIPT/PIPT 等缩写保留
- “体系结构视角”小节显式保留

## 后台设置

- 标题：Arm Cortex-A73：资源上限？那是什么
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/arms-cortex-a73-resource-limits-what-are-those
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～27

## 来源与表述要求

- A73 测试平台是 Odroid N2+ / Amlogic S922X；A57 来自 Nintendo Switch，A72 来自 AWS Graviton 1，平台不可完全比较。
- 网页未披露 OS/Kernel、编译器、固定频率、预热、重复次数与误差。
- 约 3072 项主 BTB、Return 深度 16/47 两段行为来自曲线，不能写成确认表深。
- A73 很可能取消 L1I 预译码是结合两宽 Decode 与存储预算的推测，不是 RTL 事实。
- “理论无限重排序”只表示传统 filler 方法未触及已完成指令资源上限；Scheduler 与 Load/Store Slot 仍会限制执行。
- 八个 Slot 的字段、折叠条件和恢复逻辑没有公开，正文只给通用机制假说。
- Scheduler/端口图来自行为重建，不能当作 Arm Floorplan。
- A73 不做或如何做内存依赖投机没有 RTL 确认；Forwarding 图只确认延迟分布。
- A73/A72 L1D Fill 数的网页表述存在“八对八却称增加”的口径问题，正文已保留。
- 512-bit L2 Fetch Path 不等于端到端 64 B/cycle。
- 跨集群约 267 ns、8.02 GB/s DRAM 与 139.79 ns 延迟属于 S922X 系统路径，不能全部归因于 A73 IP。
- 图 27 的 A57 使用主动散热，应用结果不是同平台能效对比。

## 发布预览要点

- 27 张图片和图注编号连续，本地链接有效，真实 MIME 与扩展名一致。
- `2-wide`、`48 L1 BTB`、`16/47 return`、`48/1024/128 TLB`、`4–5/9-cycle forwarding`、`25-cycle L2` 等数字正常。
- Slot-based 的未知项、Fill 口径矛盾和 SoC 边界均未被润色抹掉。
- 腾讯云 COS URL 全部返回 HTTP 200，且 `Content-Type` 与图片格式一致。
- 母稿与 WeMD 除 H1、YAML 和图片 URL 外正文一致。
