# 玄铁 C910 微信公众号发布资料

## 正式发布信息

- 正式标题：从 RTL 到实测：玄铁 C910 微结构深度拆解
- 署名：Chester Lam
- 来源：Chips and Cheese
- 日期：2025 年 2 月 4 日
- 英文标题：Alibaba/T-HEAD's Xuantie C910
- 原始链接：https://chipsandcheese.com/p/alibabat-heads-xuantie-c910

### 摘要

结合公开 OpenC910 RTL、TH1520/LicheePi 4A 微基准与官方资料，分析 C910 的前端、乱序执行、Load/Store、Cache 与多核表现，并区分核心 IP、SoC 实现和测试推断。

### 封面与分享文案

- 主标题：玄铁 C910 微结构
- 副标题：从公开 RTL 到 TH1520 实测
- 分享文案：C910 的前端、乱序窗口和存储层次如何配合？文章把公开 RTL 与 LicheePi 4A 微基准放在一起，并保留核心 IP、SoC 实现和反推结论之间的边界。
- 备选标题：玄铁 C910：公开 RTL 告诉了我们什么；C910 的前端、乱序执行与存储系统

### 标签与栏目

- 标签：玄铁 C910、OpenC910、RISC-V、TH1520、乱序执行、分支预测、Cache
- 栏目：RISC-V 与处理器微体系结构

## 图片与移动端排版

- 正文共 30 张图，位于专用目录 `xuantie_c910_figures/`，发布前按图 1～30 的顺序检查。
- 微结构框图和延迟矩阵保留原尺寸，手机端应能点击查看。
- 重点复核 ROB、Load/Store Queue、L2 带宽和核间延迟的数字、单位与近似限定。

## 后台设置与发布前检查

- 后台作者栏：Chester Lam
- 阅读原文：https://chipsandcheese.com/p/alibabat-heads-xuantie-c910
- 原创声明：不勾选。
- AI 标识：按发布平台届时规则如实选择。
- 发布前确认母稿与 WeMD 正文一致，30 张图片均能访问，所有 RTL 结论与实测反推仍然分开表述。
