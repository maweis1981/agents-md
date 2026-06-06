# Prompts as Code

> Prompts are production code. Treat them that way.
> 中文：[`prompts.zh-CN.md`](./prompts.zh-CN.md)

A prompt that ships in your app is part of the binary. It controls
LLM output, costs money on every call, and breaks when changed badly
— same as any other production code path.

## Hard rules

1. **Prompts live in version control.** Not in a notion doc, not in
   the agent's memory.
2. **One prompt change = one PR.** Reviewed like code.
3. **A prompt change must include an eval run.** See
   [`evals.md`](./evals.md). No eval = no merge.
4. **Semantic versioning.** Track per-prompt versions; downstream code
   pins by version.
5. **No inline prompts of more than ~10 lines.** Long prompts go in
   `prompts/<name>.md` and are imported.

## Recommended layout

```
prompts/
├── extract_invoice.md        # natural-language prompt body
├── extract_invoice.meta.json # version, owner, eval suite
├── classify_intent.md
├── classify_intent.meta.json
└── README.md                 # index + conventions
```

`prompts/<name>.meta.json` example:

```json
{
  "name": "extract_invoice",
  "version": "1.4.0",
  "owner": "@finance-team",
  "model_default": "claude-opus-4-7",
  "eval_suite": "evals/extract_invoice/",
  "deprecates": ["1.3.x"],
  "input_schema": "schemas/invoice_input.json",
  "output_schema": "schemas/invoice_output.json"
}
```

## Semantic versioning for prompts

Same shape as software semver:

| Bump | When |
| --- | --- |
| **MAJOR** | Output schema changes; downstream code must adapt. |
| **MINOR** | New behavior added; old inputs still produce compatible outputs. |
| **PATCH** | Wording tweak; outputs measurably equivalent on eval. |

Downstream code pins:

```ts
import { loadPrompt } from "@/prompts";
const prompt = loadPrompt("extract_invoice", "^1.4.0");
```

This lets you ship a new minor without breaking callers.

## Review rules

A prompt PR must:

- [ ] Touch exactly one prompt + its `meta.json`.
- [ ] Bump version per semver.
- [ ] Include the eval run output in the PR description (pass/fail +
      key metrics).
- [ ] Note any model the prompt was specifically tuned for. Prompts
      tuned to one model may regress on another.

A prompt PR must NOT:

- Bundle code changes that *use* the prompt, unless the version bump
  was MAJOR and the bump requires call-site changes.
- Skip eval ("trivial wording change" is not a valid excuse —
  trivial changes can still measurably regress outputs).

## A/B variants

When a prompt change is risky, ship the new version behind a flag
and run both for a percentage of traffic:

```ts
const prompt = featureFlag("invoice_prompt_v2", request.userId)
  ? loadPrompt("extract_invoice", "2.0.0")
  : loadPrompt("extract_invoice", "1.4.0");
```

Compare eval scores from production. Promote or revert based on real
data, not intuition.

## Anti-patterns

- **Inline prompts edited in place** — irreversible, no history.
- **Prompts hardcoded in TypeScript string literals over 10 lines** —
  no syntax highlighting, no diff readability, no separate review.
- **`f"..."` / template literals interpolating user input directly
  into a system prompt** — prompt injection waiting to happen.
- **Skipping eval because "it's just a typo fix"** — typo fixes have
  silently regressed outputs in published research.

## Prompt injection mitigation

User input that flows into a prompt must be:

1. **Delimited** with a clear marker (XML tags, `<<<>>>`, etc.) so the
   model can tell user content from instructions.
2. **Sanitized** for obvious injection markers ("ignore previous
   instructions") — at least logged for review.
3. **Schema-checked on output** — if the LLM returns something not
   matching the output schema, reject and retry rather than passing
   on.

## Reference

- [`evals.md`](./evals.md) — every prompt change must produce an eval
  result.
- [`observability.md`](./observability.md) — what to log when a prompt
  runs in production.
- [`agent-behavior.md`](./agent-behavior.md) §1 — search before
  generating a new prompt; reuse first.
