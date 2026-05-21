# AI-Native Development Standards

> Version `0.1.0` — Founding release
>
> A specification for AI Agent behavior on Git, GitHub, CI/CD,
> databases and serverless infrastructure during high-velocity
> "vibe coding" development.
>
> 中文版本：[`STANDARDS.zh-CN.md`](./STANDARDS.zh-CN.md)

---

## Goals

This standard constrains how AI Agents (Cursor, Claude Code, OpenAI
Agents, Devin, Windsurf and similar) commit, branch, deploy, migrate
and operate during a fast-moving development cycle.

It exists to:

- Prevent GitHub API rate-limit storms
- Prevent CI/CD storms
- Keep commit history readable
- Lower deploy cost
- Keep production stable
- Improve human ↔ AI collaboration efficiency

---

## 1. Core principles

### 1.1 Agents must not commit frequently

Forbidden:

- Committing on every file modification
- Committing on every prompt iteration
- Deploying on every code generation

Why: GitHub API limits, Actions cost explosion, deploy storms, polluted
history, unreadable diffs.

### 1.2 A commit is a "stable snapshot"

A commit is **not** the agent's thinking process. It is the state of
the system at a stable checkpoint.

### 1.3 Agents may modify frequently — but must commit infrequently

Allowed:

- High-frequency local modification
- Multi-round agent self-repair
- Continuous automated refactoring

Required:

- **Delay the commit** until the change is coherent.

---

## 2. Standard workflow (mandatory)

```
Create feature branch
    ↓
AI modifies locally, many rounds
    ↓
Once feature is complete: a single commit
    ↓
Push to feature branch
    ↓
Open PR
    ↓
Squash merge
    ↓
Land in main
```

---

## 3. Branching (mandatory)

### 3.1 Agents must not operate on `main` directly

Forbidden:

```bash
git checkout main
git push origin main
```

### 3.2 Agents must use a feature branch

Naming:

```
ai/<feature-name>
```

Examples:

```
ai/auth-system
ai/memory-agent
ai/landing-redesign
ai/chat-workflow
ai/vector-search
```

### 3.3 One feature ⇒ one branch

Forbidden: bundling unrelated features into the same branch.

### 3.4 Long-lived agent branches are forbidden

Agent branches must be **short-lived**. As soon as the feature is
coherent, merge.

---

## 4. Commits

### 4.1 No automatic commits

Disable:

- Auto Commit
- Auto Sync
- Auto Push

### 4.2 Commit frequency

Forbidden: commit on every change.
Recommended: one commit per stable, coherent feature.

### 4.3 Commit granularity

Allowed (good size):

- complete onboarding flow
- complete payment system
- complete auth module

Forbidden (too small):

- fix typo
- fix padding
- update prompt
- change color
- fix import

### 4.4 Commit message format

```
type: feature summary
```

Examples:

```
feat: complete onboarding workflow
feat: implement ai memory system
fix: resolve websocket reconnect issue
refactor: simplify vector search pipeline
```

### 4.5 Forbidden commit messages

```
update
fix
changes
wip
tmp
asdf
```

---

## 5. Push

### 5.1 No high-frequency push

Forbidden: pushing after every commit.

### 5.2 A push requires at least one of

- Feature complete
- Tests pass
- Page renders correctly
- Migration verified
- Deployment-ready

### 5.3 High-frequency modifications must stay local

Prefer local edits over remote pushes during exploration.

---

## 6. Pull requests

### 6.1 All AI branches merge through a PR

Forbidden: direct merge into `main`.

### 6.2 Squash merge is mandatory

GitHub repository settings:

```
Allow squash merging   = ON
Allow merge commit     = OFF
```

### 6.3 One PR = one feature

Forbidden: a single PR bundling multiple unrelated features.

### 6.4 A PR must be rollback-safe

- Schema is reversible
- Env vars are backwards-compatible
- Migration is safe to roll back

---

## 7. CI / CD (critical)

### 7.1 No push-triggered full deploy

Forbidden:

```yaml
on:
  push:
```

### 7.2 Recommended triggers

```yaml
on:
  pull_request:
# or
on:
  workflow_dispatch:
```

### 7.3 Agent branches never deploy to production

Allowed for agent branches:

- preview deploy
- staging deploy

### 7.4 Production deploys come from `main` only

### 7.5 High-frequency agent edits must be debounced

CI/CD must be:

- merged-triggered
- delay-triggered
- batched

Forbidden: build on every push.

---

## 8. Database (Neon / PostgreSQL)

### 8.1 Migrations must use a direct connection

Forbidden: running migrations through a pooled connection.

### 8.2 App runtime uses pooled connections

Allowed for:

- serverless runtime
- edge runtime
- AI chat API

### 8.3 No high-frequency migrations

Forbidden: running a migration after every schema tweak.
Recommended: aggregate schema changes, then migrate.

### 8.4 Neon branch usage

A Neon branch is a **database timeline**, not a git branch. Don't conflate
the two.

### 8.5 Import branch becomes production directly

Forbidden: trying to "merge" a Neon branch into `main`.
Recommended: swap `DATABASE_URL` instead.

---

## 9. Agent behavior constraints

### 9.1 Modify existing files first

Forbidden: generating large numbers of pointless new files.

### 9.2 Avoid duplication

No duplicate:

- components
- utilities
- schemas
- prompts

### 9.3 Search before generating

Before writing new code, an agent must search the codebase for an
existing:

- implementation
- API
- hook
- component

### 9.4 No infinite repair loops

Required:

- cap retries
- emit a reason for failure
- request human intervention

### 9.5 No continuous polling

Forbidden:

```js
while (true) {
  checkTask()
}
```

Recommended: event-driven, webhook-driven, queue-driven.

---

## 10. Serverless / AI infra

### 10.1 AI workflows are event-driven by default

Recommended triggers: messages, queues, webhooks.
Forbidden: always-on resident agents.

### 10.2 Databases must support scale-to-zero

Recommended: Neon, Turso, PlanetScale.

### 10.3 APIs are stateless

Short connections. Forbidden: permanent DB connections from short-lived
agents.

---

## 11. Recommended stack

**Git**: Feature branch · Squash merge · Conventional Commits
**CI/CD**: GitHub Actions · Preview deploy · PR-triggered build
**Database**: Neon · PostgreSQL · pgvector
**Runtime**: Vercel · Edge Functions · Serverless Functions
**ORM**: Prisma · Drizzle

---

## 12. Final principle of AI coding

**Agents may generate code at very high frequency.
The system must commit state at very low frequency.**

The end goals:

- High development velocity
- Low system churn
- High maintainability
- Low operating cost

---

## 13. Recommended project layout

```
project/
├── app/
├── components/
├── lib/
├── prompts/
├── workflows/
├── agents/
├── prisma/
├── scripts/
└── docs/
```

---

## 14. Recommended GitHub settings

### Branch protection on `main`

- Require PR
- Require review
- Require status checks
- Disable force push

### Merge strategy

- Enable: Squash merge
- Disable: Merge commit

---

## 15. Agent execution checklist (before push)

Before any push, the agent must verify:

- [ ] Feature is complete
- [ ] No obvious errors
- [ ] No duplicate files
- [ ] No infinite agent loops left running
- [ ] Migration has been verified
- [ ] Commit message is compliant
- [ ] Branch name is correct
- [ ] Will not trigger a deploy storm
- [ ] Will not leave a resident DB connection
- [ ] Can be squash-merged cleanly

---

## 16. Future direction

AI coding will gradually shift from:

`commit-driven`

toward:

`state-driven` · `semantic-diff-driven` · `workflow-driven`

Git itself was not designed for AI agent collaboration. Over time we
expect to see:

- semantic version control
- AST diff
- intent diff
- workflow snapshots
- AI-native IDE infrastructure

**This standard is, for now, the compatibility layer between AI coding
and traditional Git workflows.**

See [`docs/outlook.md`](./docs/outlook.md) for the long view.
