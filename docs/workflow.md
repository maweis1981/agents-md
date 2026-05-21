# Standard Workflow

> The canonical AI-native development loop.
> 中文：[`workflow.zh-CN.md`](./workflow.zh-CN.md)

## The loop

```
Create feature branch  ai/<feature-name>
        ↓
AI modifies locally, many rounds
        ↓
Feature reaches a coherent state
        ↓
One commit + push to feature branch
        ↓
Open PR (draft → ready for review)
        ↓
Squash merge into main
        ↓
Preview → staging → production
```

## Step by step

### 1. Create a feature branch

```bash
git checkout -b ai/<feature-name>
```

Examples:

```
ai/auth-system
ai/memory-agent
ai/landing-redesign
```

One feature ⇒ one branch. Lifetime measured in hours / days, not weeks.

### 2. Let the agent iterate locally

This is the part where most failures happen. The default for nearly
every AI tool is to **commit on every save**. Turn that off:

- Disable "Auto Commit" / "Auto Sync" / "Auto Push" in your IDE / agent.
- Tell the agent explicitly in `CLAUDE.md` / `AGENTS.md` that this is
  a multi-iteration session, not one commit per change.

### 3. Stabilize, then commit once

When the feature works end-to-end, then:

```bash
git add -A
git commit -m "feat: complete <feature>"
```

If you commit twice in this loop, you probably should have made it
one commit. If you commit ten times, something has gone wrong.

### 4. Push when ready

Push only when the branch is in a state where it could survive being
merged. See [`push.md`](./push.md) for the explicit checklist.

### 5. Open a PR

Default to **draft PRs** so CI / reviewers don't react until you're
ready. See [`pull-request.md`](./pull-request.md).

### 6. Squash merge

Branch protection on `main` should enforce squash-only merge. See
[`github-settings.md`](./github-settings.md).

## Anti-patterns

- "Let me just push to `main` to test the CI quickly." → No.
- "I'll commit each small fix so I can revert one." → Use `git stash`
  or local branches instead. The remote does not need to see your
  intermediate states.
- "I'll keep this branch open for two weeks while I figure things out."
  → Open a tracking *issue*, not a long-lived branch.

## Why one branch ≠ one PR ≠ one commit might still be OK

Sometimes a feature genuinely needs multiple PRs (e.g. schema first,
then code). That's fine — keep each PR independently coherent and
mergeable. The rule isn't "exactly one commit ever", it's "no
intermediate commits exposed to the remote that don't stand on their
own."
