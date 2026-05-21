# CI / CD

> The most important chapter for cost control. Bad CI rules turn an
> AI agent's productivity into your cloud bill.
> 中文：[`ci-cd.zh-CN.md`](./ci-cd.zh-CN.md)

## Why this is hard

A human developer pushes a handful of times per day. CI cost scales
roughly linearly with that. An AI agent, left to its own devices, can
push hundreds of times per day. Same CI config, 100× the bill, 100×
the deploy storms, 100× the chance of breaking production.

## Hard rules

1. **No `on: push` full deploys** to production.
2. **Use `on: pull_request` or `on: workflow_dispatch`** for any
   expensive workflow.
3. **AI branches never auto-deploy to production.** Only `main` does.
4. **High-frequency edits must be debounced** — merged-triggered,
   delay-triggered, or batched.

## Recommended triggers

```yaml
# Preview deploys: PRs only
on:
  pull_request:
    types: [opened, synchronize, reopened]

# Production deploys: merge to main only
on:
  push:
    branches: [main]

# Expensive ad-hoc workflows: manual only
on:
  workflow_dispatch:
```

## Forbidden triggers

```yaml
# Don't do this
on:
  push:                # any branch, every push
on:
  push:
    branches: ['**']
```

If you must run something on every push to an AI branch, scope it to
the cheapest possible workflow (lint, type-check). Never full build +
deploy.

## Debounce strategies

When an agent pushes 20 times in 10 minutes, you don't need 20 full
deploys. Pick one of:

### Concurrency groups

```yaml
concurrency:
  group: preview-${{ github.ref }}
  cancel-in-progress: true
```

This cancels the in-flight job when a new push lands — only the most
recent state ever finishes building.

### Time-based debounce

A small workflow that triggers on push but does nothing for the first
N seconds, allowing a flurry of pushes to coalesce.

### Path filters

Don't rebuild the whole app when only docs changed:

```yaml
on:
  pull_request:
    paths-ignore:
      - 'docs/**'
      - '**/*.md'
```

## Production deploy

- Only on `push` to `main`.
- Should require status checks to have passed on the corresponding PR.
- Should be the *only* path to production.

Branch protection on `main` is how you enforce this — see
[`github-settings.md`](./github-settings.md).

## Preview / staging deploys

- Run from PR branches.
- Should *not* hit production data. Use a separate database branch
  (Neon branch, etc.) or a staging DB.
- Should be cheap to spin up and spin down.
- Should tear down automatically when the PR closes.

## Secrets in CI

- Secrets in CI are *not* available to forks. If your AI agent is
  running in a fork (some platforms do this), expect failures and
  handle them gracefully.
- Never log a full env dump. Mask secrets in logs.

## An example PR-only workflow

A minimal template lives in
[`../templates/.github/workflows/preview.yml`](../templates/.github/workflows/preview.yml).
