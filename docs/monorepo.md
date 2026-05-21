# Monorepos

> How the spec applies when one repo contains many packages / apps.
> 中文：[`monorepo.zh-CN.md`](./monorepo.zh-CN.md)

Most rules in `STANDARDS.md` carry over to a monorepo unchanged. The
sections below cover the cases that change.

## Branch naming

Add a scope prefix when the change is package-local:

```
ai/<package>/<feature>
```

Examples:

```
ai/web/auth-system
ai/api/memory-agent
ai/shared-ui/button-variants
```

If a single feature genuinely spans multiple packages, omit the scope
and let the PR description list the touched packages:

```
ai/cross-pkg-billing
```

But be honest: most "cross-package" branches are actually two features
that should be split.

## One PR = one feature, even across packages

A feature that legitimately needs changes in `apps/web` *and*
`packages/sdk` *and* `prisma/` is one feature. Don't split it just
because it touches three directories — split it only if each part
is independently shippable.

Splitting *too* aggressively in a monorepo is the more common mistake
than splitting too little: you end up with three PRs that can only
land in one order, and reviewers have to mentally reassemble the change.

## CI: scope your builds to what changed

The biggest cost trap in monorepos under AI editing is **building
everything on every push**. Combine these:

### Path filters per workflow

```yaml
on:
  pull_request:
    paths:
      - 'apps/web/**'
      - 'packages/shared-ui/**'
      - 'pnpm-lock.yaml'
```

One workflow per logical "scope of change". A docs-only PR shouldn't
build the API container.

### Turborepo / Nx affected detection

If you use Turborepo:

```yaml
- run: pnpm turbo run lint test build --filter='...[origin/main]'
```

`--filter='...[origin/main]'` runs only packages whose inputs changed
since `main`. Same idea in Nx: `nx affected --target=...`.

### Concurrency groups per scope

Don't share one concurrency group across all PRs. Scope to the branch:

```yaml
concurrency:
  group: ci-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

## Database migrations

Migrations in a monorepo are particularly easy to mess up because
multiple packages may write to the same DB. Rule of thumb:

- **One canonical migration owner** per database. Usually a top-level
  `prisma/` or `db/` package.
- **Other packages consume the generated client**, they do not run
  migrations.
- The migration owner package is the only one whose CI runs migrations
  against staging.
- A PR that changes schema **must** modify the migration-owner package.
  If only an app changed, no migration; if the schema changed, the
  migration package shows up in the diff.

This makes "did this PR change the DB?" a one-line `git diff --stat`
check.

## Skills installation

Claude Code Skills can be installed at three scopes:

| Scope | Location | When to use |
| --- | --- | --- |
| Repo-wide | `.claude/skills/` at the monorepo root | Skills that apply to every package (git workflow, commits). |
| Package-scoped | `apps/<x>/.claude/skills/` | Stack-specific skills (e.g. a Drizzle-only skill in an API package). |
| User-scoped | `~/.claude/skills/` | Your personal additions. Not in the repo. |

For most teams, all the `agents-md` skills live at the monorepo root.

## CLAUDE.md / AGENTS.md placement

In a monorepo, put one at the **repo root** with the global rules,
and optionally smaller ones in each package for package-specific
context (build commands, test commands, package-specific gotchas).

The root file should explicitly say: "see also `apps/<x>/CLAUDE.md`
for per-package details."

## Stale package detection

In a monorepo, dead packages accumulate. Add a periodic check
(`workflow_dispatch` or a monthly cron) that flags packages with no
changes for > 6 months. AI agents are particularly prone to copying
patterns from dead code, so keeping the tree pruned helps everyone.

## What does *not* change in a monorepo

- All the commit rules.
- All the push rules.
- The squash-merge rule.
- The "agent never pushes to `main`" rule.
- The migration-direct / runtime-pooled rule.
- The "no infinite polling" rule.

If anything, monorepos make those rules *more* important because the
blast radius of a bad commit is larger.
