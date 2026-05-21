---
name: ai-native-commits
description: Use when an AI agent is about to author a commit message or stage a commit — enforces Conventional Commits, prevents per-edit micro-commits, and bans single-word junk messages. TRIGGER whenever 'git commit' is about to run.
---

# AI-Native Commits

A commit is a **stable snapshot** of the system, not a frame of your
thinking. Apply this skill every time you are about to run
`git commit`.

## Frequency

- One commit per **stable, coherent feature**.
- Do NOT commit on every file save.
- Do NOT commit on every prompt iteration.
- If a feature legitimately needs multiple commits (e.g. schema + code
  that uses it), each commit must be independently coherent.

## Message format

```
type: short imperative summary

optional body explaining why (wrap ~72 cols)
```

Allowed `type`: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`,
`perf`, `build`, `ci`. Scopes (`type(scope): …`) are optional.

### Good examples

```
feat: complete onboarding workflow
feat: implement ai memory system
fix: resolve websocket reconnect issue
refactor: simplify vector search pipeline
docs(zh-CN): align database section with English
```

### Banned messages

These are never acceptable. If you find yourself typing one, you are
committing too early:

```
update
fix
changes
wip
tmp
asdf
.
test
new
```

## Granularity test

If your last 5 commits could be squashed into 1 and the result would
be **more** understandable, the commits were too small.

If a single commit changes 10 unrelated things, the commit was too big.

## Process

Before running `git commit`:

1. `git status` — verify only the intended files are staged.
2. `git diff --staged` — read your own diff. If you can't explain it
   in one sentence, the diff is too big.
3. Compose a Conventional Commits message.
4. Commit once. Do not loop.

## When co-authoring with a human

If a commit is meaningfully assisted by an AI agent, recording
co-authorship is good practice (not mandatory in this spec):

```
feat: complete onboarding workflow

Co-Authored-By: Claude <noreply@anthropic.com>
```

Pick a policy at the project level and apply it consistently.

## Reference

`docs/commits.md` in the agents-md repo for the full rationale.
