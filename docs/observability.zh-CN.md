# 可观测性与成本闸

> 每次 Agent / LLM 调用要记什么，以及怎么在失控 Agent 把账单吃光前刹住它。
> English: [`observability.md`](./observability.md)

Agent 在生产上比在调试时更容易出问题。下面这套默认值，决定的是
**"我们找到了 bug"** 还是 **"我们因此收到了 $4,000 账单"**。

## 硬性规则

1. **每次 LLM 调用都有 trace。** OpenTelemetry span 或等价的结构化日志。
2. **每次 prompt 运行都记**：model、prompt 版本、in/out token 数、
   成本、延迟、输入 hash。
3. **PII 落日志前 redact**：邮箱、电话、姓名、地址、支付数据 —— 原始日志里
   绝不能有。
4. **per-session 设 token / 美元预算硬上限**。超过 Agent 立即停下并上报。
5. **LLM provider 有熔断器**：错误率超阈值，立即 fail fast，**不要**
   反复重试把自己拖垮。

## 每次调用记什么

```jsonc
{
  "trace_id": "01HXYZ...",
  "session_id": "sess_42",
  "agent": "invoice-extractor",
  "model": "claude-opus-4-7",
  "prompt_name": "extract_invoice",
  "prompt_version": "1.4.0",
  "input_hash": "sha256:...",
  "input_redacted": "<<INVOICE_BODY_REDACTED>>",
  "input_tokens": 1872,
  "output_tokens": 340,
  "cost_usd": 0.0186,
  "latency_ms": 2430,
  "status": "ok",
  "tool_calls": ["search_invoice_db"],
  "eval_offline_score": null
}
```

两个直接好处：

- **可回放**：知道 `prompt_version` + `input_hash` 通常就能复现失败，
  不必长期保留原始输入。
- **成本归因**：按 `agent` / `session_id` / `prompt_name` 聚合
  `cost_usd`，立刻知道该优化谁。

## OpenTelemetry 形状

尽量用 OTel 的 GenAI 语义约定：

- `gen_ai.system` —— `"anthropic"` / `"openai"` 等。
- `gen_ai.request.model` —— model ID。
- `gen_ai.usage.input_tokens` / `gen_ai.usage.output_tokens`。
- `gen_ai.response.id`。

这样 trace 在多 vendor 之间是 grep-able 的。

## PII 脱敏

输入进入日志 sink 之前，**在进程内**先过一道脱敏器：

- 正则 + 字典查表 drop 邮箱、电话、IBAN、银行卡号。
- 姓名用 per-tenant salt 做 hash，保留 hash 用于关联，但**不可逆**。
- 自由文本字段替换为 `<<REDACTED:type>>` 标记。
- **绝不**记录包含 secret 的工具原始入参。

**小、快、确定性的脱敏器，胜过完美但慢的脱敏器**。

## 预算闸

### Per-session

```ts
const ctx = createAgentContext({
  budget: { tokens: 200_000, costUsd: 2.00 },
  onExceeded: "halt"
});
```

超预算时：

- 立即停止 Agent loop。
- 发出结构化事件 `agent.budget.exceeded`。
- 明确告诉调用方"预算超了"，**不是**"内部错误"。

### Per-tenant / Per-environment

预算分层：

- 单次调用硬上限（一次调用合理的上界）。
- per-session 上限（如上）。
- per-tenant 日上限（多租户应用）。
- per-environment 月上限（整组织在 staging / production 的兜底）。

任何一层触发，停下并 page。**不要**等 6 小时后给客户发"账户超出配额" ——
那时候 $1k 已经烧出去了。

### 熔断器

LLM provider 在 60s 窗口错误率超过比如 20%，打开熔断器：

- 新调用立即 fail fast，进入冷却期。
- 少量探测调用偶尔放过，检测恢复。
- 触发状态页 / Slack 告警。

避免典型 AI 故障模式：**provider 退化 → 你加倍重试 → 你自己制造了一场故障**。

## 该报警什么

按重要性排：

1. 日成本接近上限（80% 告警，100% page）。
2. 错误率突增（provider 问题或 prompt 回归）。
3. p95 延迟回归（往往是成本回归的先行指标）。
4. per-session 成本异常值（一个 session 烧到中位数 10 倍）。
5. 工具调用循环检测（同工具、同参数，一个 session 里 > N 次 = 多半卡住了）。

## **不**该记什么

- 原始 `.env`（显然）。
- 未脱敏的完整用户消息（不那么显然，但常见）。
- INFO 级的啰嗦 retry 循环 —— 会撑爆日志预算。
- 成本归因日志里夹 stack trace —— 分管道。
- 错误信息里夹 provider API key（落日志前 mask）。

## 回放与调试

给定 `trace_id`，工程师应该能：

1. 拉出这个 session 的完整 LLM 调用序列。
2. 看到每次调用的 prompt 版本 + 输入 hash。
3. 在本地用同 model / prompt / 输入回放。
4. 通过脱敏后的输入定位失败模式，**不需要**访问原始 PII。

这套基础设施只搭一次，是 AI 应用最大的单点调试杠杆。

## 参考

- [OpenTelemetry GenAI 约定](https://opentelemetry.io/docs/specs/semconv/gen-ai/)
- [`prompts.zh-CN.md`](./prompts.zh-CN.md) 定义 `prompt_version` 语义。
- [`evals.zh-CN.md`](./evals.zh-CN.md) —— 离线对应物。
- [`agent-behavior.zh-CN.md`](./agent-behavior.zh-CN.md) §3 ——
  Retry 上限和熔断器是同一个故事的两面。
