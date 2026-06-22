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

## 6. Respect the spec when generating CI / DB / infra code

When the agent itself writes:

- a GitHub Actions workflow → it must follow [`ci-cd.md`](./ci-cd.md).
- a migration file → it must follow [`database.md`](./database.md).
- a branch / commit / PR → it must follow [`branching.md`](./branching.md),
  [`commits.md`](./commits.md), [`pull-request.md`](./pull-request.md).

The spec applies to *generated* code, not just to the agent's own
behavior.
