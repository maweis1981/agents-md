# Push

> When to push, when not to push, and what must be true at push time.
> 中文：[`push.zh-CN.md`](./push.zh-CN.md)

## Rule

**A push is a system-visible event.** It triggers CI, deploys,
notifications. The agent's local thinking does not need to be visible.
Only push when the branch is in a state worth being seen.

## Required conditions

A push is only acceptable when **at least one** of the following is
true:

- Feature is complete.
- Tests pass.
- The page / endpoint renders correctly.
- Migration has been verified locally.
- The branch is deployment-ready.

If none of these are true, you are pushing too early.

## Forbidden patterns

- Pushing after every commit.
- Pushing to trigger CI as a way of "trying things out". Use local
  test runs or `act` instead.
- Pushing because the agent felt anxious.

## High-frequency edits stay local

The default for an agent during exploration is:

- modify files
- run tests / type checks locally
- regenerate as needed

The remote does not need to see this. If your agent infrastructure
auto-pushes, *turn that off*.

## Force push

Force-push (`git push --force` / `--force-with-lease`) on `ai/` feature
branches is allowed if it cleans up the agent's history before opening
a PR. **Never** force-push to `main`. Never force-push to a branch
someone else is reviewing without telling them.

## Push and CI

The CI section ([`ci-cd.md`](./ci-cd.md)) is strict about this:

- Push to an `ai/` branch should **not** trigger production deploys.
- Push to an `ai/` branch *may* trigger a preview / staging deploy,
  but high-frequency edits should be debounced.

If you find yourself in a tight loop of `push → CI fails → push again`,
stop. Fix locally first.

## A practical push checklist

Before `git push`:

- [ ] Branch is named `ai/<feature>`.
- [ ] Commit history is clean (squashed if necessary).
- [ ] Commit message follows the format.
- [ ] No secrets / `.env` / credentials in the diff.
- [ ] Local tests / type-check pass.
- [ ] Migration (if any) has been verified.
- [ ] You're not pushing just to "see if CI passes".
