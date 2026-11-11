# Agent Behavior

> Constraints on what an AI agent itself is allowed to do, regardless
> of platform.
> 中文：[`agent-behavior.zh-CN.md`](./agent-behavior.zh-CN.md)

## 1. Search before generation

Before writing any new code, the agent must search the codebase for an
existing:

- implementation of the same function
- API / route / handler
- React / Vue / Svelte component
- hook / composable
- utility
- type / interface / schema
- prompt template

If a near-match exists, **extend it** rather than create a parallel one.

When the agent needs *external* information — vendor design tokens,
SDK surface, configuration schema — the same rule applies one level
out: check whether the vendor publishes a machine-readable Markdown
endpoint (e.g. Vercel's [`/design.md`](https://vercel.com/design.md)
and [`/design.dark.md`](https://vercel.com/design.dark.md), or any
`llms.txt`-style endpoint) before scraping HTML or guessing.
See [`machine-readable-docs.md`](./machine-readable-docs.md).

Why: AI agents have an extreme bias toward generation. Unchecked, this
multiplies the maintenance surface forever. A duplicate `useDebounce`,
duplicate `Button`, duplicate `formatDate`, duplicate auth schema —
every one of these slows the team down for years.

## 2. Modify existing files first

Forbidden: generating a fan-out of new files when a single file edit
would suffice.

Examples of bad behavior the spec explicitly bans:

- Creating `utils/foo-v2.ts` next to the existing `utils/foo.ts`.
- Creating `ButtonNew.tsx` next to `Button.tsx`.
- Creating `schema-new.prisma` "to avoid breaking the old one".

If a file genuinely needs to be replaced, replace it. If it needs to
be split, split it. But "additive duplication" is forbidden.

## 3. Cap retries

If a tool / test / build / deploy fails:

- Retry at most **3 times** by default.
- Each retry must include a *new hypothesis* about the failure. Not
  just "run the same thing again".
- After the cap, the agent **must**:
  - Emit a clear failure reason.
  - Stop.
  - Request human intervention.

Infinite repair loops are forbidden. If an agent is "stuck", the loop
is not the bug — the loop *is* the bug.

## 4. No continuous polling

Forbidden:

```js
while (true) {
  const status = await checkTask(taskId)
  if (status === 'done') break
  await sleep(1000)
}
```

Why: Agents are short-lived workers. A polling loop holds resources
open, holds DB connections open, holds API quota open, and (on
serverless runtimes) burns money.

Recommended replacements:

- **Webhooks**: the task notifies the agent when it's done.
- **Queues**: the agent picks up the next task instead of waiting on
  this one.
- **Event subscriptions**: the agent registers interest and is woken
  up by the platform.

If the agent runtime *forces* polling (some don't expose webhooks),
poll at large intervals (≥ 30s), with exponential backoff, and a hard
cap on total wait time.

## 5. No silent failures

If an agent gives up on a task, it must say so. Forbidden:

- Returning a "success" message because the prompt expected one.
- Closing a PR description as if work was done when it wasn't.
- Marking a TODO as complete to make the loop terminate.

If you cannot finish, **say you couldn't finish, and why**.

## 6. Rule-baking flywheel

When your agent (or agent team — see
[`agent-teams.md`](./agent-teams.md)) detects a recurring failure,
the response is **not** to write a longer prompt. The response is
to turn the failure into a check that runs without an LLM call.

The loop:

```
Judge / human catches the same mistake twice
        ↓
Can it be caught statically?
   yes → add to scripts/lint-*.sh
    no ↓
Can it be caught by an eval case?
   yes → add to evals/<name>/dataset.jsonl
    no ↓
Add a dedicated Reviewer skill in skills/review-<topic>/SKILL.md
```

Why this specific escalation order:

- Static lint runs in milliseconds, costs nothing, never flakes.
- Eval cases run in CI, catch non-static regressions, cost pennies.
- Reviewer skills run per-PR and catch what the first two can't,
  at the cost of an LLM call.

A rule that lives only in a system prompt is the *weakest* form of
enforcement — the agent sees it, the agent sometimes ignores it,
and you have no record of why. Bake rules *out of* the prompt and
into the layers below.

### Signs a rule should be baked

- Same reviewer comment on three PRs → lint.
- Same eval regression across prompt versions → dataset case.
- Same "agent didn't know X" in session logs → Reviewer skill.
- Same human Slack message to the agent → static check.

### What NOT to bake

- One-off situational guidance ("this quarter, prefer pattern X").
  Baking policy that will change creates drag.
- Preferences that only apply to one project in a multi-tenant
  shared spec.
- Anything you can't articulate as a deterministic check with
  <10% false-positive rate.

### The flywheel's purpose

The agent gets smarter by **removing degrees of freedom**, not by
longer prompts. Every rule baked below the prompt line means one
less thing the next agent run can get wrong. The spec is the
long-term memory the prompt doesn't have.

## 7. Respect the spec when generating CI / DB / infra code

When the agent itself writes:

- a GitHub Actions workflow → it must follow [`ci-cd.md`](./ci-cd.md).
- a migration file → it must follow [`database.md`](./database.md).
- a branch / commit / PR → it must follow [`branching.md`](./branching.md),
  [`commits.md`](./commits.md), [`pull-request.md`](./pull-request.md).

The spec applies to *generated* code, not just to the agent's own
behavior.
