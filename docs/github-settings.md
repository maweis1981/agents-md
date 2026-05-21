# GitHub Settings

> The repo-level settings that turn the spec from "we agreed to it" into
> "GitHub will enforce it".
> 中文：[`github-settings.zh-CN.md`](./github-settings.zh-CN.md)

## Branch protection on `main`

Settings → Branches → Add branch protection rule → `main`:

- [x] **Require a pull request before merging**
  - [x] Require approvals (≥ 1)
  - [x] Dismiss stale pull request approvals when new commits are pushed
  - [x] Require review from Code Owners *(if you use `CODEOWNERS`)*
- [x] **Require status checks to pass before merging**
  - Add the checks your CI emits (lint, type-check, test, build).
  - [x] Require branches to be up to date before merging
- [x] **Require conversation resolution before merging**
- [x] **Require signed commits** *(optional but recommended)*
- [x] **Require linear history** *(works together with squash merge)*
- [x] **Do not allow bypassing the above settings** — apply to admins too.
- [x] **Restrict who can push to matching branches** — empty allow-list,
      i.e. nobody pushes directly to `main`.

## Merge strategy

Settings → General → Pull Requests:

- [ ] Allow merge commits
- [x] Allow squash merging
  - Default commit message: **Pull request title and description**
- [ ] Allow rebase merging

## Branch hygiene

Settings → General → Pull Requests:

- [x] **Automatically delete head branches**

This collects the garbage left behind by short-lived `ai/` branches.

## Actions permissions

Settings → Actions → General:

- **Actions permissions**: allow your own actions and trusted publishers.
- **Workflow permissions**: read-only by default; grant write per-job.
- **Fork pull request workflows**: be explicit. Workflows from forks
  should *not* receive secrets by default.

## Secrets

Settings → Secrets and variables → Actions:

- Production secrets: stored as **environment secrets** scoped to a
  protected `production` environment.
- The `production` environment should require manual approval to
  deploy. This is the final guard against an agent accidentally
  shipping to prod.

## Environments

Settings → Environments → New environment → `production`:

- [x] Required reviewers (at least one human)
- [x] Wait timer (optional, e.g. 5 minutes for "abort window")
- Deployment branches: **selected branches** → `main` only

Optional: separate `staging` environment without required reviewers but
limited to PR branches.

## Repository visibility & policies

- Private repos with AI access: ensure your AI agent's GitHub App
  permissions are scoped to *only the repos it needs*. The spec
  assumes single-repo scoping by default.
- Public repos: be very careful about workflows that run on PRs from
  forks. They should not get production secrets.

## Optional: rulesets

GitHub Rulesets (a newer alternative to branch protection) let you
express the same rules with finer granularity and apply them across
multiple branches via patterns (e.g. `ai/**`). If you operate at scale
across many repos, prefer rulesets.

A starting ruleset for `ai/**`:

- Allow pushes from authenticated users.
- Disallow force-push (humans), allow force-push by the agent's bot
  user if necessary for history cleanup before PR.
- Require linear history.
- Require deletions to go through a PR (so agents can't `git push
  origin :ai/foo` to delete work in progress).

## Putting it together

Once configured, the agent cannot:

- Push to `main`.
- Merge a PR without a passing CI run.
- Merge a PR with a merge-commit instead of a squash.
- Bypass review on its own branch.
- Deploy to production without crossing the environment approval.

If you find the agent doing any of these anyway, the bypass came from
*missing* settings, not from a malfunctioning agent — fix the
settings.
