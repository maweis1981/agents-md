# Recommended Tech Stack

> Not requirements — just the defaults that align with this spec.
> 中文：[`tech-stack.zh-CN.md`](./tech-stack.zh-CN.md)

## Why have a recommended stack

The spec doesn't *need* a specific tech stack. But every rule in it is
easier to apply on some stacks than others. Listing the defaults makes
the rest of the doc more concrete and helps new projects start from a
known-good base.

## Defaults

| Layer | Recommended | Why it fits the spec |
| --- | --- | --- |
| **Version control** | Git + GitHub | Feature branches + squash merge + branch protection are first-class. |
| **CI/CD** | GitHub Actions | PR-triggered builds, concurrency groups, path filters, preview deploys all native. |
| **Hosting** | Vercel / Cloudflare / Netlify | Preview deploys per PR; scale-to-zero by default. |
| **Database** | Neon (Postgres) | Direct + pooled endpoints; branch-per-PR; scale-to-zero. |
| **ORM** | Prisma or Drizzle | Both support direct-vs-pooled URL split. |
| **Vector** | pgvector inside Neon | One DB to manage; no separate vector infrastructure. |
| **Queues** | Inngest / QStash | Event-driven workflows without running your own worker. |
| **Auth** | Clerk / Auth.js / Supabase Auth | Managed, scale-to-zero compatible. |
| **Observability** | Sentry + Axiom / Logflare | Captures agent-driven incidents without always-on infra. |
| **Agent IDE** | Claude Code / Cursor / Codex | All four read `AGENTS.md` (or `CLAUDE.md`) at repo root. |

## Equivalent substitutes

- **Postgres scale-to-zero alternatives**: Supabase (with pooled
  endpoint), CockroachDB Serverless.
- **Edge compute alternatives**: AWS Lambda + API Gateway, Google
  Cloud Run.
- **Queue alternatives**: AWS SQS, GCP Cloud Tasks, Trigger.dev.
- **CI alternatives**: GitLab CI, CircleCI — all the rules transfer,
  the YAML syntax differs.

## What we explicitly do **not** recommend by default

- Always-on RDS / Cloud SQL / self-hosted Postgres clusters for early
  projects (you'll pay for idle compute).
- Long-running Kubernetes deployments for AI workloads that could run
  serverlessly (you'll have agents holding pods open).
- Merge-commit Git workflows on `main` (defeats squash discipline).
- CI that runs full deploys on every push to every branch (defeats
  cost control).

## Recommended project layout

```
project/
├── app/               # routes / pages / handlers
├── components/        # UI components
├── lib/               # cross-cutting helpers, clients
├── prompts/           # prompt templates (versioned, reviewed)
├── workflows/         # agent workflows / state machines
├── agents/            # agent definitions
├── prisma/            # or drizzle/ — schema + migrations
├── scripts/           # one-shot ops scripts
└── docs/              # human docs, including a copy of CLAUDE.md / AGENTS.md
```

This layout shows up in `templates/` — if your repo doesn't match this,
that's fine; nothing in the spec breaks.

## What an "AI-native" repo additionally has

Beyond the layout above:

- A `CLAUDE.md` or `AGENTS.md` at the repo root.
- A `prompts/` directory under version control with the same review
  discipline as code.
- An `agents/` directory documenting each agent's role and the tools
  it has access to.
- (Optional) a small `skills/` directory of Claude Code Skills if you
  use Claude Code.
