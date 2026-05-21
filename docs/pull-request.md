# Pull Requests

> One PR, one feature, squash merge. Rollback-safe by default.
> 中文：[`pull-request.zh-CN.md`](./pull-request.zh-CN.md)

## Hard rules

1. **All AI branches merge through a PR.** No direct merge into `main`.
2. **Squash merge is mandatory.** Disable merge-commit and rebase-merge
   in repo settings.
3. **One PR = one feature.** No bundled unrelated work.
4. **A PR must be rollback-safe.**

## Squash merge — why

Squash merge collapses the agent's per-iteration commits (or any
remaining intermediate commits) into a single commit on `main`. This
keeps `main`'s history readable: one line per landed feature, not
forty.

It also prevents the agent's intermediate states from polluting
history if the agent didn't quite follow the commit-discipline rules
upstream. Squash merge is the "second chance" to keep history clean.

GitHub setting:

```
Allow squash merging   = ON
Allow merge commit     = OFF
Allow rebase merging   = OFF
```

## One PR, one feature

If a PR description starts with "this PR does X and also Y", split it.

If a PR is mechanically required to bundle two things (e.g. add a new
column *and* the code that reads it), that's fine — they're one
logical feature. The test is *logical coherence*, not raw file count.

## Drafts by default

Open every AI-driven PR as a **draft** until:

- The agent has stopped iterating.
- Tests pass.
- The author (or reviewer) has eyeballed the diff.

Once it's a non-draft PR, CI / reviewer time is being spent. Don't
burn that on incomplete work.

## Rollback-safety

A PR is rollback-safe when:

- Schema migrations are reversible (or the rollback path is explicitly
  documented).
- Env vars are backwards-compatible (new vars have safe defaults; no
  removed vars that production still reads).
- Feature flags are off by default if the change is risky.
- The diff doesn't *require* coupled changes in another service to
  ship simultaneously.

If any of these are violated, the PR description must call it out
explicitly under a "**Not rollback-safe because…**" section.

## PR description template

```
## What changed
One sentence: the resulting capability.

## Why
Link to issue, ticket, or rationale.

## Testing
What you tested locally / in preview. Screenshots welcome for UI.

## Rollback
"Safe to revert" — OR — what to do if this needs to be undone.
```

## Review expectations

- AI-generated diffs deserve **more** review, not less.
- Reviewers should check for duplicate components / utils that the
  agent missed during search.
- Reviewers should specifically check migrations, IAM changes, and
  env-var changes.

## After merge

- Branch is auto-deleted (enable "Automatically delete head branches").
- Production deploy happens from `main`, not from the PR branch.
- The local branch is removed: `git branch -d ai/<feature>`.
