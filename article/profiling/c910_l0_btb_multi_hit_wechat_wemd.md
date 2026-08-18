---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "c910_l0_btb_multi_hit_wechat"
---

> 本文基于 OpenC910 当前开源 RTL、CoreMark 仿真波形与事件级 Trace。量产玄铁 C910 可能采用不同版本或后续修订，不能由这组实验直接判断其是否存在相同行为。

OpenC910 前端有一层仅 16 项的 L0-BTB。它在热点分支命中时提前给出跳转目标，让 PCGEN 不必等待更晚的主 BTB，从而缩短 Taken 分支的取指间隙。

正常情况下，16 路 Tag 比较后应当只有一个表项命中，随后读取该项的 Counter 和 Target。但当前 RTL 允许相同 Tag 同时存在于多个有效表项中，读取时又没有优先选择，而是把所有命中项的状态和目标按位 OR。只要这些表项保存的 Target 不同，就可能拼出一个从未写入过的地址。

## 波形中出现的错误目标

CoreMark 波形在 `mcycle=76042` 捕获到了一个完整实例：

```text
entry_hit_flop = 0x00d1

Entry 0/4 target = 0x1b5c
Entry 6/7 target = 0x1a70

0x1b5c | 0x1a70 = 0x1b7c
```

Entry 0、4、6、7 同时命中。`0x1b5c` 和 `0x1a70` 都是真实表项中的目标，OR 得到的 `0x1b7c` 却不属于任何一项。

![图 1：L0-BTB 对多个命中项的 Target 进行按位 OR](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/c910_l0_btb_multi_hit_wechat/35c4175b91ee1c9f_-2026-08-15-165530.png)

只要任意命中项的 Counter 允许预测，L0-BTB 就会接受这次重定向。

![图 2：Counter 汇总与早期重定向条件](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/c910_l0_btb_multi_hit_wechat/99b60d186e3b8b55_-2026-08-15-165651.png)

合成的 Target 随后被直接送入 PCGEN。

![图 3：L0-BTB 输出目标的生成逻辑](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/c910_l0_btb_multi_hit_wechat/058cacb13c82e5c3_-2026-08-15-165806.png)

下一拍，IP 级发现预测错误，又把 PC 从 `0x1b7c` 纠正回真实目标 `0x1a70`。

![图 4：错误早转向以及随后的 IP 级纠正](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/c910_l0_btb_multi_hit_wechat/31c51a8dbc4f2bca_-2026-08-15-170426.png)

后续流水级能够纠正控制流，所以这个实例没有改变程序最终结果，但错误路径取指仍会浪费前端带宽和能耗。

## 重复表项是怎样形成的

CoreMark 主波形中共有 3729 次 L0-BTB 创建，其中 741 次在创建前，表内已经存在相同 Tag，占 19.87%。

最主要的来源是重定向期间 L0 查询被屏蔽，共 538 次。取指包没有得到查询结果，却继续进入后续流水级；到达 IB 时，“没有查询”被当成“没有命中”，于是再次创建表项。另有 198 次来自同一取指包中的 RAS 与普通分支冲突：L0 Tag 只标识取指包，没有包含包内具体分支位置和类型，因此同一 Tag 可能对应不同控制流。剩余 5 次来自在途竞争，两个请求先后查询时都看到 Miss，前一个完成写入后，后一个仍携带旧 Miss 再次创建。

FIFO 不检查相同 Tag，写入时也不重新核对当前表状态，使这些情况最终变成重复项。读取端又默认命中向量一定是 one-hot，于是重复项从容量浪费进一步发展成目标混合。独立事件级 Trace 中记录到 2622 次多表项命中，其中 1378 次 OR 结果不等于任何真实 Target，282 次合成目标实际参与了早期重定向。

因此，问题不只是替换策略不够好。单独改成 LRU、优先使用无效项，或者看到相同 Tag 就直接覆盖，都无法同时处理过期 Miss 和同一取指包的多个真实后继。

## 修改方案

修改后，每个取指包 Tag 在 16 项主表中只保留一个 owner，写入时复查并复用已有项，读取时也只允许一个表项提供预测结果。少数确有两个稳定后继的取指包由 4 项稀疏 sidecar 保存第二候选，避免重新引入重复主表项。

## 验证结果

在相同的 CoreMark 单次迭代中，修改后没有再出现重复 Tag 或实际查询多命中，退休指令仍为 254641 条。总周期从 203642 降至 203135，改善约 0.249%；这只能说明当前配置获得了些许提升，仍需更多工作负载和综合结果验证。
