# AI 功能的 Evals

> 单测检查确定性，Eval 检查非确定性那一部分。两者都得有。
> English: [`evals.md`](./evals.md)

## Eval 和单测的区别

单测：给定 X，`f(X)` 是不是等于 Y？—— pass/fail 二值，函数是确定性的。

Eval：给定一个代表性数据集，LLM 行为是否满足某个质量阈值？——
pass/fail 是统计的，函数是非确定性的。

**单测换不了 Eval，Eval 也换不了单测**。

## 硬性规则

1. **每个 prompt 配一套 eval suite。** 没 eval 不上生产。
2. **改 prompt 的 PR 必须跑 eval。** 结果贴 PR 描述里。
3. **Eval 阈值入库**，不放在 reviewer 脑子里。
4. **回归阻断合并。** Eval 套件可测量下降 = CI 失败，不是讨论话题。
5. **Eval 数据集打版本。** 别为了让失败 PR 通过悄悄往数据集里加样本。

## Eval Suite 的结构

```
evals/
└── extract_invoice/
    ├── dataset.jsonl          # 输入/期望对，入库
    ├── thresholds.json        # 通过标准
    ├── runner.ts              # 怎么调被测 LLM
    └── reports/               # 历史 run 输出（gitignore）
```

`thresholds.json` 示例：

```json
{
  "min_exact_match": 0.85,
  "min_field_recall": 0.92,
  "min_field_precision": 0.95,
  "max_p95_latency_ms": 4000,
  "max_avg_cost_usd": 0.012
}
```

一次 run 产生一份 report；CI 对比 report 和 thresholds，回归则非零退出。

## Eval 类型（至少组合 3-4 种）

| 类型 | 抓的是 |
| --- | --- |
| **Exact match / schema match** | 输出形状回归。 |
| **LLM-as-judge** | 主观质量（有用度、语气）。判官 model 不要和被测 model 同款。 |
| **Reference-based**（BLEU / ROUGE / 向量相似度） | 漂离已知良输出。 |
| **行为检查** | "拒绝有害请求？" "调对工具了？" |
| **成本 & 延迟** | token 花销、p50/p95 延迟。 |
| **对抗 / Prompt injection** | 已知攻击模式下还稳吗？ |

只挑一种没意义，组合 3-4 种才有信号。

## CI 里怎么跑 Eval

Eval 很贵，按集成测试对待，**不要**按单测对待：

- `pull_request` 触发，仅对 `prompts/` / `evals/` / 调 LLM 的代码路径。
- 文档 PR 跳过（path filter）。
- 激进缓存：`dataset.jsonl` 和 prompt 都没变就回放缓存 report。
- 每个 eval suite 一个 concurrency group，避免 push 风暴跑 10 份并发的
  `$0.50` eval。

```yaml
name: Evals
on:
  pull_request:
    paths:
      - 'prompts/**'
      - 'evals/**'
      - 'lib/llm/**'

concurrency:
  group: evals-${{ github.ref }}
  cancel-in-progress: true
```

## Eval 纪律（人的部分）

- **不要在同一个 PR 里同时改阈值和数据集**，两个的信号互相抵消。
- **生产挂了再加 case，不是 reviewer 挑刺时加 case**。客户报告的每一个
  坏输出变成一个新 case。
- **case 打标记 provenance**："来自事故 #42"、"来自用户 X 的边缘场景"。
  未来的你会感谢现在的你。

## 回归发生时：先调查再调阈值

PR eval 挂了，团队第一反应想降阈值时，**停下**。正确顺序：

1. 在 eval 数据集上复现失败。
2. 看回归的 case 具体是什么。
3. 判断这是**真**质量下降还是数据集错（期望输出本来就不对）。
4. 修 prompt、修数据集，或者**最后一步** —— 调阈值，
   **同时在 PR 描述里写明理由**。

## 值得知道的工具

- [Inspect](https://inspect.aisi.org.uk/)（UK AI Safety Institute）——
  场景化 eval 框架。
- [promptfoo](https://www.promptfoo.dev/) —— 配置驱动，CI 友好。
- [DeepEval](https://github.com/confident-ai/deepeval) —— Python，pytest 风格。
- [Braintrust](https://www.braintrust.dev/) / [Langfuse](https://langfuse.com/) ——
  托管的 eval + 可观测性。
- Anthropic 的 [`anthropic-cookbook`](https://github.com/anthropics/anthropic-cookbook)
  有 eval 入门菜谱。

**只选一个**。中途换框架的代价比将就一个不完美选择高得多。

## 参考

- [`prompts.zh-CN.md`](./prompts.zh-CN.md) —— Prompt 和 Eval 成对出现。
- [`observability.zh-CN.md`](./observability.zh-CN.md) ——
  Eval 是离线的，可观测性是在线对应物。
- [`ci-cd.zh-CN.md`](./ci-cd.zh-CN.md) —— 把 Eval 接到 PR pipeline 里。
