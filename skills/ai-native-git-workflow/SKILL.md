---
name: ai-native-git-workflow
description: Use when an AI agent is about to create a branch, commit, push, open a pull request, or merge — encodes the agents-md branching, push, and PR rules. TRIGGER on any Git operation that touches the remote.
---

# AI-Native Git Workflow

You are operating under the **agents-md** standard. Follow these rules
on **every** Git-touching action.

## Branching

- **Never** check out, commit to, or push `main` directly.
- Work on a branch named `ai/<feature-name>` (kebab-case).
- One feature ⇒ one branch. If the branch name needs "and", split it.
- Branch lifetime is hours to days, not weeks.

## Local edits vs. commits

- **Edit freely locally.** Do NOT commit on every file save.
- Commit only at *stable feature checkpoints* — one feature, one
  commit (or a small number of independently coherent commits).
- Disable auto-commit / auto-sync / auto-push in any tool you control.

## Commit messages

- Conventional Commits format: `type: short imperative summary`.
- Allowed types: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`,
  `perf`, `build`, `ci`.
- Forbidden messages: `update`, `fix`, `changes`, `wip`, `tmp`, `asdf`,
  `.`, `test`, `new`, anything single-word.

## Push

Push only when at least one is true:

- Feature is complete.
- Tests pass.
- Page / endpoint renders correctly.
- Migration verified.
- Branch is deployment-ready.

Do NOT push to "see if CI passes". Run tests locally first.

## Pull requests

- Open as **draft** until ready.
- One PR = one feature.
- PR description: What / Why / Testing / Rollback.
- If the change is not rollback-safe, say so explicitly.
- Merge with **squash** only.

## Before pushing

Run through this checklist:

- [ ] Branch is `ai/<feature>`.
- [ ] Commit message follows format; no junk messages.
- [ ] No secrets / `.env` / credentials in the diff.
- [ ] Local tests / type-check pass.
- [ ] No infinite loops or polling left running.
- [ ] You're not pushing just to see CI.

## Forbidden actions

- `git push origin main` (direct).
- Force-push to `main`.
- Force-push to someone else's review branch without telling them.
- Merge a PR with merge-commit or rebase-merge (must be squash).
- Long-lived `ai/` branches (> 1 week).

## When in doubt

Stop. Surface the question. Don't guess at Git history changes.

## Reference

Full spec: `STANDARDS.md` in the agents-md repo. Chaptered docs:
`docs/branching.md`, `docs/commits.md`, `docs/push.md`,
`docs/pull-request.md`.
