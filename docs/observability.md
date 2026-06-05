# Observability & Cost Guardrails

> What to record about every agent / LLM call, and how to stop a
> runaway one before it eats the bill.
> 中文：[`observability.zh-CN.md`](./observability.zh-CN.md)

Agents are easier to break in production than to debug in production.
The defaults below are what makes the difference between "we found
the bug" and "we got a $4,000 invoice for it".

## Hard rules

1. **Every LLM call is traced.** OpenTelemetry span, or an equivalent
   structured log line.
2. **Every prompt run logs**: model, prompt version, token in/out,
   cost, latency, hash of input.
3. **PII is redacted before logging.** Email, phone, name, address,
   payment data — never in the raw log.
4. **Per-session token / dollar budget.** Hard cap. When exceeded,
   the agent halts and reports.
5. **A circuit breaker exists for the LLM provider.** If error rate
   crosses a threshold, fail fast instead of retrying into a meltdown.

## What to log per call

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

Two things this enables:

- **Replay**: given `prompt_version` + `input_hash`, you can usually
  reproduce the failure without keeping the raw input.
- **Cost attribution**: roll up `cost_usd` by `agent` / `session_id`
  / `prompt_name` and you know what to optimize.

## OpenTelemetry shape

Use OTel semantic conventions for GenAI when possible:

- `gen_ai.system` — `"anthropic"`, `"openai"`, etc.
- `gen_ai.request.model` — model ID.
- `gen_ai.usage.input_tokens` / `gen_ai.usage.output_tokens`.
- `gen_ai.response.id`.

This makes your traces grep-able across vendors.

## PII redaction

Run input through a redactor *before* it leaves your process for the
log sink:

- Drop emails, phones, IBANs, card numbers via regex + dictionary
  lookup.
- Drop names by hashing with a per-tenant salt; keep the hash so you
  can correlate without recovering the name.
- For free-form fields, replace with `<<REDACTED:type>>` markers.
- Never log raw tool inputs that include secrets.

A small, fast, deterministic redactor beats a perfect-but-slow one.

## Budget guardrails

### Per-session

```ts
const ctx = createAgentContext({
  budget: { tokens: 200_000, costUsd: 2.00 },
  onExceeded: "halt"
});
```

When the budget is exceeded:

- Halt the agent loop.
- Emit a structured event (`agent.budget.exceeded`).
- Tell the caller the budget was the reason, not "internal error".

### Per-tenant / per-environment

Stack budgets:

- Per-call hard cap (sane upper bound for one invocation).
- Per-session cap (above).
- Per-tenant daily cap (for multi-tenant apps).
- Per-environment monthly cap (whole-org guard for staging /
  production).

If any cap trips, halt and page someone. Don't email "your account
exceeded its quota" to the customer six hours later — by then the
$1k bill is already incurred.

### Circuit breakers

If your LLM provider's error rate over a 60s window crosses, say,
20%, open the circuit:

- New calls fail fast for a cooldown period.
- A small number of probe calls leak through to detect recovery.
- Status page / Slack alert fires.

This prevents the classic AI outage pattern: provider degrades,
you retry harder, you cause your own outage.

## What to alert on

Set alerts for, in order of importance:

1. Daily cost approaches its cap (warn at 80%, page at 100%).
2. Error rate spike (provider issues, prompt regressions).
3. p95 latency regression (often a leading indicator of cost
   regression).
4. Per-session cost outlier (one session burning 10× the median).
5. Tool-call loop detection (same tool, same args, > N times in one
   session → likely stuck).

## What NOT to log

- Raw `.env` contents (obvious).
- Full user messages without redaction (less obvious; common).
- Verbose retry loops at INFO level — they'll fill your log budget.
- Stack traces in production-cost-attribution logs — separate
  pipeline.
- Provider API keys in error messages (mask before logging).

## Replay & debugging

Given `trace_id`, the engineer should be able to:

1. Pull the full sequence of LLM calls for that session.
2. See the prompt version + input hash for each.
3. Replay the call locally with the same model / prompt / inputs.
4. Inspect the redacted input for the failure pattern, without
   needing access to the raw PII.

Build this once. It's the single biggest debugging lever for AI apps.

## Reference

- [OpenTelemetry GenAI conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/)
- [`prompts.md`](./prompts.md) for `prompt_version` semantics.
- [`evals.md`](./evals.md) — offline counterpart to online obs.
- [`agent-behavior.md`](./agent-behavior.md) §3 — retry caps tie into
  the circuit breaker.
