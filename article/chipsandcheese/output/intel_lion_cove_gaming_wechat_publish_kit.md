# Lion Cove 游戏负载微信公众号发布资料

## 正式标题

Lion Cove 跑游戏：八宽核心为何大部分时间仍在等待

## 备选标题

- 从 Top-Down 看 Lion Cove：游戏为什么难以用满八宽
- 64 KB L1I 很强，Arrow Lake 的 L3/DRAM 却拖住了游戏
- Lion Cove 的游戏瓶颈：不是执行单元不够

## 作者与来源

- 作者栏：Chester Lam
- 首发：Chips and Cheese
- 英文题目：*Intel’s Lion Cove P-Core and Gaming Workloads*
- 发布日期：2025 年 7 月 6 日
- 阅读原文：https://chipsandcheese.com/p/intels-lion-cove-p-core-and-gaming

## 摘要

Lion Cove 能八宽分配、12-wide 退休，却在游戏中只有约 1～1.7 IPC。Top-Down 与 PMU 表明少量 L3/DRAM miss 和误预测后的取指延迟主导等待。

## 分享卡片文案

192 KB L1.5 接住不少 L1 miss，为什么游戏仍 Memory Bound？一次误预测又为什么可能把分支惩罚放大到数百 cycle？

## 封面

- 主标题：Lion Cove 跑游戏
- 副标题：八宽核心为何仍在等待
- 小字：Top-Down / L1.5 / Branch Recovery / Retirement
- 比例：2.35:1，Intel 蓝，流水线宽度与 Cache 延迟阶梯形成对照

## 推荐标签与栏目

- 标签：Intel、Lion Cove、Arrow Lake、P-Core、游戏性能、Cache、分支预测、PMU
- 栏目：处理器体系结构

## 图片与排版

- 正文图片：17 张，按 01～17 上传
- 图 7、14 是机制路径，图 8～10、13～17 数据密集
- `L1.5`、`Top-Down`、`BAClear`、`BPClear` 保留原缩写

## 后台设置

- 作者栏：Chester Lam
- 阅读原文：https://chipsandcheese.com/p/intels-lion-cove-p-core-and-gaming
- 原创声明：关闭
- AI 内容标识：开启后台相应标识

## 发布前边界

- BIOS 关闭 E-Core 是为避免 Call of Duty 的亲和性卡顿；不能当作常规平台设置。
- ARB 3.8 GHz 到核心 5.7 GHz 的换算是近似，动态频率会增大误差。
- `RECOVERY_CYCLES` 与映射表恢复有研究支持，但非 Lion Cove RTL 直接确认。
- Top-Down Slot 与执行端利用率不是同一口径。
