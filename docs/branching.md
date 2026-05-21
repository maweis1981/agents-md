# Branching

> Rules for branch creation, naming, and lifetime when an AI agent is
> the one driving Git.
> 中文：[`branching.zh-CN.md`](./branching.zh-CN.md)

## Hard rules

1. **Agents never operate on `main` directly.** No `git checkout main`,
   no `git push origin main`.
2. **Every AI-driven change lives on an `ai/<feature-name>` branch.**
3. **One feature ⇒ one branch.** No bundling unrelated work.
4. **Agent branches are short-lived.** Merge when coherent; delete after.

## Naming

```
ai/<feature-name>
```

`<feature-name>` is kebab-case, descriptive, scope-narrow:

```
ai/auth-system
ai/memory-agent
ai/landing-redesign
ai/chat-workflow
ai/vector-search
ai/fix-websocket-reconnect
```

If the name needs a conjunction ("and", "plus", "with"), the branch is
probably doing two things. Split it.

### Sub-prefixes (optional)

If you need finer separation:

```
ai/feat/<feature>
ai/fix/<issue>
ai/refactor/<area>
ai/docs/<topic>
```

This is optional. The minimum is `ai/<something>`.

## Lifetime

- **Target**: hours to a few days.
- **Cap**: one week. If a branch lives longer than a week, the work
  has been mis-scoped.
- **Stale branch policy**: branches with no activity for > 14 days
  should be auto-archived or deleted. Configure this in GitHub's
  branch-cleanup settings.

## What humans use

Humans on the team are free to use any branching convention they like
(e.g. `feature/...`, `fix/...`, `username/...`). The `ai/` prefix is
specifically a *signal*: this branch was driven primarily by an AI
agent and is subject to this spec.

This signal is useful for:

- Filtering branch protection rules.
- Filtering CI cost reports.
- Knowing whether a review needs "human-written code" scrutiny or
  "AI-generated code" scrutiny.

## Cleanup

After a successful squash merge:

```bash
git branch -d ai/<feature>          # local
git push origin --delete ai/<feature>  # remote
```

Most projects can also enable GitHub's "automatically delete head
branches" setting to do this for them.

## Common mistakes

- **Reusing a branch across unrelated features.** Once a branch has
  merged once, *don't keep working on it*. Create a new one.
- **Letting the agent name the branch.** Agents often produce
  unhelpfully verbose or non-deterministic names. Hand it the name.
- **Mixing `ai/` and direct edits.** If a human takes over an `ai/`
  branch and rewrites large parts of it, the `ai/` prefix is now
  misleading. Either rename the branch or be honest in the PR
  description.
