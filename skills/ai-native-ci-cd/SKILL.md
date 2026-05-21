---
name: ai-native-ci-cd
description: Use when editing GitHub Actions workflows, CI configuration, or deployment pipelines — prevents push-triggered full deploys, enforces PR-only / manual triggers, and adds debounce for high-frequency agent pushes. TRIGGER on changes to .github/workflows/*.yml or any CI config.
---

# AI-Native CI / CD

Apply this skill whenever you are creating or modifying a CI/CD
workflow file (`.github/workflows/*.yml`, similar for GitLab CI,
CircleCI, etc.). Bad CI rules turn AI productivity into a cloud bill.

## Hard rules

1. **No `on: push` full deploys** to production.
2. Expensive workflows trigger on `pull_request` or `workflow_dispatch`.
3. AI branches never auto-deploy to production. Only `main` does.
4. High-frequency edits must be debounced.

## Recommended triggers

```yaml
# Preview deploys — PRs only
on:
  pull_request:
    types: [opened, synchronize, reopened]

# Production deploys — merge into main only
on:
  push:
    branches: [main]

# Expensive ad-hoc workflows — manual only
on:
  workflow_dispatch:
```

## Forbidden triggers

```yaml
# Do NOT do this
on:
  push:                # any branch, every push
on:
  push:
    branches: ['**']
```

## Debounce patterns to add by default

### Concurrency group (almost always include this)

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

### Path filters for docs-only / config-only changes

```yaml
on:
  pull_request:
    paths-ignore:
      - 'docs/**'
      - '**/*.md'
      - 'LICENSE'
```

## Production deploy gating

If you add a deploy step:

- Production deploy must come from `main` only.
- It should require status checks on the PR that produced the commit.
- Use a GitHub `environment` named `production` with required
  reviewers and a wait timer.

## Secrets

- Never log full env. Mask secrets in any debug output.
- Secrets must not be available to fork-PR workflows by default.
- Production secrets belong to the `production` environment, not to
  repo-level Actions secrets.

## When generating CI for a new repo

Start from the template in `templates/.github/workflows/preview.yml`
in the agents-md repo (or copy below):

```yaml
name: Preview
on:
  pull_request:
    types: [opened, synchronize, reopened]
    paths-ignore:
      - 'docs/**'
      - '**/*.md'

concurrency:
  group: preview-${{ github.ref }}
  cancel-in-progress: true

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "lint, type-check, test — and only deploy preview here"
```

## Reference

`docs/ci-cd.md` and `docs/github-settings.md` in the agents-md repo.
