# 同一取指块双条件分支处理原型

该目录给出一个**尚未接入 `ct_ifu_top`** 的可综合控制原型，用于固定双条件分支方案的顺序语义，并防止实验阶段直接删除 `br_more_than_one_stall`。

`ct_ifu_multi_branch_resolver.v` 假定上游已经为第二条条件分支生成独立且正确的 BHT 上下文。它完成以下工作：

- 第一条预测 Taken 时立即截断，第二条不进入预测序列；
- 第一条预测 Not-Taken 时，只有第二条 BHT 上下文有效才消费第二条；
- 两条预测按程序顺序推进 VGHR；
- 第二条预测 Taken 时选择第二目标；
- 还有第三条条件分支时，在第二条之后截断并回到串行重放；
- 第二条上下文不可用时，退回当前单路行为。

本原型不能单独提升性能。接入真实 C910 RTL 前还必须完成：

1. BHT 为第二条条件分支提供独立的 prediction counter、selector 和预测前 VGHR。
2. IPDP 识别第二条条件分支位置，并生成“第一条后”和“第二条后”两套 tail mask。
3. IPDP→IBDP→PCFIFO 传递第二套预测元数据，取消 PCFIFO 中“两项至多一条条件分支”的现有假设。
4. PCFIFO 两个 create port 分别生成正确的 `bht_pred` 和 `chk_idx`。
5. 对 BHT 更新旁路、flush、H0、L0 纠正和异常优先级做一致性验证。

原型自检命令：

```bash
cd smart_run/experiments/branch_predictor/multi_branch
iverilog -g2012 -o /tmp/c910_multi_branch_resolver \
  ct_ifu_multi_branch_resolver.v tb_ct_ifu_multi_branch_resolver.v
vvp /tmp/c910_multi_branch_resolver
```

预期输出为 `PASS ct_ifu_multi_branch_resolver`。
