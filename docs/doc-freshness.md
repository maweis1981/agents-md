# Documentation Freshness

> "We'll update the docs later" is how docs become wrong.
> 中文：[`doc-freshness.zh-CN.md`](./doc-freshness.zh-CN.md)

AI agents are uniquely good at producing code without updating
related documentation. The rules below force the doc update to
happen in the same PR as the code change.

## Hard rules

1. **A code change to a documented area must update the docs in the
   same PR.** Not "next PR".
2. **Docs land in the diff, or the diff explains why no doc change
   was needed.** Reviewers enforce.
3. **Docs are tied to code via paths**, not vibes. CI fails when a
   tracked code path changes without a matching doc path.
4. **Stale docs are deleted, not preserved as historical curiosity.**

## Coupling code paths to doc paths

Define the coupling in a single config file at repo root:

```yaml
# .doc-coupling.yml
couples:
  - code: app/api/billing/**
    docs: docs/billing.md
    severity: error

  - code: prompts/**
    docs:
      - prompts/README.md
      - docs/prompts.md
    severity: error

  - code: prisma/schema.prisma
    docs:
      - docs/database.md
      - docs/schema-changelog.md
    severity: warn

  - code: lib/auth/**
    docs: docs/auth.md
    severity: error
```

A small CI script reads the PR's changed files and the config and
fails when a `severity: error` couple has its code changed but not
its docs (or vice versa).

A sketch of the script — wire this into your `lint` workflow:

```bash
#!/usr/bin/env bash
# scripts/check-doc-freshness.sh
changed=$(git diff --name-only "origin/${BASE:-main}"..HEAD)
yq '.couples[]' .doc-coupling.yml | while read -r couple; do
  code_glob=$(yq '.code' <<<"$couple")
  doc_paths=$(yq '.docs[]?, .docs?' <<<"$couple")
  severity=$(yq '.severity // "error"' <<<"$couple")
  # ... match changed against code_glob and doc_paths
done
```

(Adapt to your YAML tooling. The point is *some* check, not this
exact code.)

## What deserves coupling

The cost of a freshness check is the false-positive rate. Couple
only paths where:

- The doc materially helps a future developer.
- The code path changes more than monthly.
- A wrong doc would mislead an AI agent on next read.

Don't couple every file. Couple a handful of *load-bearing* docs.

## Stale doc deletion

If a doc describes something that no longer exists in the code:

- Delete it.
- Do not "leave it for context" or "mark as deprecated forever".
- An incorrect doc is worse than no doc, because agents and humans
  alike will trust it.

A quarterly sweep is fine; an annual one is too rare.

## Doc freshness signals (without strict coupling)

Even without `.doc-coupling.yml`, you can surface staleness:

- **Last-modified gap**: docs not edited in > 12 months that match
  code edited in the last month are likely out of date.
- **Reference rot**: docs that mention a file/function/route that no
  longer exists fail a link/symbol check.
- **Inbound link orphans**: a doc that nothing else references is
  often unreachable to readers — investigate before keeping it.

Plug whichever signal fits your tooling. Even a manual quarterly
review is better than nothing.

## When the rule fights the developer

There will be PRs where the doc update is genuinely separate work
(e.g. a tracked migration to a new pattern, with doc updates in a
dedicated follow-up). For those:

- Open a tracking issue.
- Reference the issue in the current PR description.
- Block the next minor release on the issue closing.

The exception is allowed; the *invisibility* is not.

## Reference

- [`agent-behavior.md`](./agent-behavior.md) §1 — search before
  generating (which often surfaces stale docs in the search).
- [`codeowners.md`](./codeowners.md) — doc owners should appear in
  CODEOWNERS so they get pinged on coupled changes.
