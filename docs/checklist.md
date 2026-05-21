# Agent Pre-Push Checklist

> Single-page checklist an agent (or its human reviewer) should run
> through before `git push`.
> 中文：[`checklist.zh-CN.md`](./checklist.zh-CN.md)

Copy this into your `CLAUDE.md` / `AGENTS.md` if you want the agent to
self-check.

## Branch

- [ ] Branch name is `ai/<feature>` (or `ai/<type>/<feature>`).
- [ ] Not `main`. Not `master`. Not a long-lived shared branch.
- [ ] One feature, not many.

## Commits

- [ ] No "wip", "tmp", "fix", "asdf", or single-word junk messages.
- [ ] Conventional Commits format (`type: summary`).
- [ ] If more than one commit, each commit is independently coherent.
- [ ] No commits introducing secrets, `.env`, credentials, or large
      binaries.

## Code changes

- [ ] Existing components / utils / schemas were searched before
      generating new ones.
- [ ] No duplicate parallel files (`foo-v2.ts`, `ButtonNew.tsx`, etc.).
- [ ] Local type-check passes.
- [ ] Local tests pass (or you explicitly note which ones are skipped
      and why).

## Migrations (if any)

- [ ] Migration runs through a **direct** DB URL, not pooled.
- [ ] Migration has been verified on a Neon branch / staging DB.
- [ ] Migration is reversible, or rollback path is documented.
- [ ] App deploy that needs new schema is gated on migration completion.

## CI / deploy posture

- [ ] No workflow added that runs full deploy on every `push`.
- [ ] No always-on agent / polling loop left behind.
- [ ] No production deploy attempted from this branch.
- [ ] Preview / staging deploy is debounced (concurrency group, path
      filter, or equivalent).

## PR readiness

- [ ] Opens as a **draft** unless explicitly ready.
- [ ] PR description follows the template (What / Why / Testing /
      Rollback).
- [ ] If not rollback-safe, that's called out in the description.

## After-action

- [ ] Will be squash-merged into `main`.
- [ ] Branch will be auto-deleted after merge.
- [ ] No lingering DB connections from your local agent run.

---

If any item is unchecked and you're about to push anyway, **stop and
explain why** in the commit message or PR description. The point of
the checklist is not to delay you; it's to make exceptions visible.
