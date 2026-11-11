# Evals for AI Features

> Unit tests check determinism. Evals check the parts that aren't
> deterministic. You need both.
> 中文：[`evals.zh-CN.md`](./evals.zh-CN.md)

## Why evals are different from unit tests

A unit test answers "given X, does `f(X)` equal Y?" — pass/fail is
binary, the function is deterministic.

An eval answers "given a representative dataset, does the LLM
behavior meet some quality threshold?" — pass/fail is statistical,
the function is non-deterministic.

You cannot replace evals with more unit tests. You cannot replace
unit tests with evals.

## Hard rules

1. **Every prompt has an eval suite.** No prompt ships to production
   without one.
2. **Every PR that changes a prompt runs its eval.** Result is in the
   PR description.
3. **Eval thresholds are committed to the repo**, not held in a
   reviewer's head.
4. **Regressions block merge.** A measurable drop on the eval suite
   is a CI failure, not a discussion topic.
5. **Eval data is versioned.** Don't quietly extend the dataset to
   make a failing PR pass.

## Anatomy of an eval suite

```
evals/
└── extract_invoice/
    ├── dataset.jsonl          # input/expected pairs, versioned
    ├── thresholds.json        # pass criteria
    ├── runner.ts              # how to invoke the LLM under test
    └── reports/               # historical run outputs (gitignored)
```

`thresholds.json` example:

```json
{
  "min_exact_match": 0.85,
  "min_field_recall": 0.92,
  "min_field_precision": 0.95,
  "max_p95_latency_ms": 4000,
  "max_avg_cost_usd": 0.012
}
```

A run produces a report; CI compares the report to thresholds and
exits non-zero on regression.

## Types of evals (use more than one)

| Type | What it catches |
| --- | --- |
| **Exact match / schema match** | Output shape regressions. |
| **LLM-as-judge** | Subjective quality (helpfulness, tone). Use a different model than the one under test. |
| **Reference-based metrics** (BLEU, ROUGE, embedding similarity) | Drift from a known-good output. |
| **Behavioral checks** | "Does it refuse harmful requests?", "Does it call the right tool?" |
| **Cost & latency** | Token spend, p50/p95 latency. |
| **Adversarial / prompt injection** | Does the system hold under known attack patterns? |

Don't pick one; combine 3–4 for a meaningful signal.

## Running evals in CI

Evals are expensive. Treat them like integration tests, not unit
tests:

- Triggered on `pull_request` for paths under `prompts/`, `evals/`,
  or the LLM-calling code.
- Skipped for docs-only PRs (path filter).
- Cached aggressively — if `dataset.jsonl` and the prompt haven't
  changed, replay the cached report.
- A single concurrency group per eval suite so a flurry of pushes
  doesn't run 10 parallel `$0.50` evals.

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

## Eval discipline (the human part)

- **Don't change thresholds and dataset in the same PR.** Each makes
  the other's signal meaningless.
- **Add cases when production fails, not when reviewers fail.** Every
  customer-reported bad output becomes a new test case.
- **Tag cases with provenance**: "added after incident #42", "edge
  case from user X". Future you will thank you.

## Regressions: investigate before adjusting

If a PR fails the eval and the team is tempted to lower the
threshold, stop. The order of operations is:

1. Reproduce the failure on the eval dataset.
2. Inspect the cases that regressed.
3. Determine whether the regression is a *real* loss of quality or a
   dataset issue (e.g. an expected output was actually wrong).
4. Fix the prompt, fix the dataset, or — last resort — change the
   threshold *with a justification committed to the PR description*.

## Cross-model judge (required for agent-team runs)

When an **LLM-as-judge** eval scores an Executor's output (see
[`agent-teams.md`](./agent-teams.md)), the judge must:

- **Use a different model family than the Executor.** Executor
  Claude Sonnet → Judge GPT-5 / Gemini / open-weights.
- **Where eval cost allows, use a different vendor.** Reduces
  shared-training bias.
- **Receive only the rubric and the Executor output.** Not the
  original task prompt, not the plan, not the Executor's self-report.
  Context bias is the #1 reason LLM-as-judge false-positives:
  the Judge rationalizes whatever the Executor produced as "fitting
  the task."
- **Return pass/fail + score + rationale.** No modifying the output.

### Two-vote quorum

When a single judge is cheap but wrong often, two judges from
different vendors + majority vote beats one strong judge. Cost ~2×
and false positives drop ~5–10× in internal reports from teams
running the Lauren Tan / `pstack` pattern.

```
Executor:   Claude Sonnet 4.5
Judge 1:    GPT-5
Judge 2:    Gemini 2.5 Pro
Result:     2/2 pass → accept
            1/2 pass → request third opinion or human
            0/2 pass → reject + prompt re-run
```

### Judge prompt skeleton

The Judge prompt should literally be:

```
You are scoring the following output against the following rubric.
You will NOT be given the original task.
Return JSON: { "pass": bool, "score": 0..1, "rationale": "..." }

RUBRIC:
<pasted rubric>

OUTPUT:
<pasted output>
```

Keep it short. The Judge's job is scoring, not helping.

## Tooling worth knowing

- [Inspect](https://inspect.aisi.org.uk/) (UK AI Safety Institute) —
  scenario-based eval framework.
- [promptfoo](https://www.promptfoo.dev/) — config-driven evals, good
  CI integration.
- [DeepEval](https://github.com/confident-ai/deepeval) — Python,
  pytest-style.
- [Braintrust](https://www.braintrust.dev/), [Langfuse](https://langfuse.com/) —
  hosted eval + observability.
- Anthropic's [`anthropic-cookbook`](https://github.com/anthropics/anthropic-cookbook)
  has eval starter recipes.

Pick *one*. Switching frameworks mid-project is more expensive than
living with a slightly imperfect choice.

## Reference

- [`prompts.md`](./prompts.md) — prompts and evals are paired.
- [`observability.md`](./observability.md) — eval is offline; obs is
  the online counterpart.
- [`ci-cd.md`](./ci-cd.md) — wiring evals into the PR pipeline.
