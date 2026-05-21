---
name: ai-native-agent-behavior
description: Use whenever the agent is about to generate new code, retry a failing operation, or start a polling/wait loop — enforces 'search before generate', caps retries, and bans always-on polling. TRIGGER on any code generation, on tool/build/test failure, or before opening a wait/polling loop.
---

# AI-Native Agent Behavior

Apply this skill on **every** code-generation turn and on **every**
failed tool invocation.

## Rule 1 — Search before you generate

Before writing any new code, search the codebase for an existing:

- function with the same purpose
- API / route / handler
- React / Vue / Svelte component
- hook / composable
- utility
- type / interface / schema
- prompt template

If a near-match exists:

1. Read it.
2. Extend or refactor it.
3. Do NOT create a parallel implementation.

Bias to *reuse*. Generation is the last resort, not the first move.

## Rule 2 — Modify existing files first

Forbidden:

- `utils/foo-v2.ts` alongside `utils/foo.ts`
- `ButtonNew.tsx` alongside `Button.tsx`
- `schema-new.prisma` "to avoid breaking the old one"

If a file needs to be replaced, replace it. If it needs to be split,
split it. Additive duplication is banned.

## Rule 3 — Cap retries

On a failing tool, test, build, or deploy:

- Retry at most **3 times** by default.
- Each retry must include a *new hypothesis*. Re-running the same
  command unchanged is not a retry; it's a stall.
- After the cap, you MUST:
  - State a clear failure reason.
  - Stop.
  - Surface the failure to a human.

No infinite repair loops. If you find yourself stuck, the loop is the
bug.

## Rule 4 — No continuous polling

Forbidden:

```js
while (true) {
  const s = await checkStatus(id);
  if (s === 'done') break;
  await sleep(1000);
}
```

Why: it holds connections, eats quota, burns serverless cost.

Replace with:

- **Webhook** — the task notifies you.
- **Queue** — pick up the next task instead.
- **Event subscription** — register interest, get woken.

If polling is truly required: interval ≥ 30s, exponential backoff,
hard total-timeout. Document why polling was unavoidable.

## Rule 5 — Don't fake success

If you couldn't complete the task:

- Say so explicitly.
- State *what* failed and *what you tried*.
- Do NOT mark TODOs done to terminate a loop.
- Do NOT write a PR description that implies completion when it
  isn't.

## Rule 6 — Spec applies to generated infra code too

Whenever you generate:

- a GitHub Actions workflow → apply `ai-native-ci-cd`.
- a DB migration → apply `ai-native-database`.
- a branch / commit / PR → apply `ai-native-git-workflow` and
  `ai-native-commits`.

You cannot opt out of the spec by generating it instead of doing it
manually.

## Reference

`docs/agent-behavior.md` in the agents-md repo.
