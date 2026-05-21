# Case Study — Adopting agents-md in a 3-person AI Startup

> A composite, synthetic narrative based on common patterns. Not a
> specific company, not legal advice, not a guarantee of results.
> 中文：[`case-study.zh-CN.md`](./case-study.zh-CN.md)

## Setting

- **Team**: 3 engineers, 2 designers.
- **Product**: an AI-first SaaS (B2B), Next.js + Prisma + Neon on
  Vercel, ~12 weeks old at adoption time.
- **Agents in use**: Claude Code for one engineer, Cursor for two,
  occasionally Codex from the CLI for batch refactors.
- **Pain before adoption**: 80+ commits/day on `main`, half of them
  with messages like `wip` / `fix` / `update`. CI cost was 6× higher
  than a comparable non-AI project. Production had 4 unrelated mini-
  outages in 3 weeks, all caused by partially-applied migrations.

## Week 1 — installing the standard

1. Dropped `CLAUDE.md` and `AGENTS.md` from `templates/` into the repo
   root and edited the "Project specifics" section.
2. Pulled in `templates/.github/workflows/preview.yml` (replacing an
   existing workflow that built on `push` for all branches).
3. Configured branch protection on `main` per
   `docs/github-settings.md`:
   - Require PR + 1 approval.
   - Squash merge only.
   - Required status check: `lint`.
   - Disabled merge-commit and rebase-merge.
4. Added the `scripts/lint-*.sh` checks and the corresponding `lint`
   workflow.
5. Bookmarked `STANDARDS.md` in the team's Linear handbook.

Total elapsed time: half a day. No application code changed.

## Week 2 — first observable change

- **Commits dropped from ~80/day to ~12/day**. Same amount of code
  produced; people stopped pushing every save.
- **CI minutes dropped ~70%** mostly thanks to `concurrency: cancel-in-progress`
  catching superseded runs. The bill stopped being an emergency.
- One engineer's Cursor configuration was still auto-syncing; spent
  ~30 minutes turning off "Auto Commit" and "Auto Push" in three
  places (Cursor settings, project `.vscode/settings.json`, and a
  pre-commit hook that had been installed by an earlier agent loop).
- The team had its first "I lost a feature because I committed too
  often" conversation. Result: agreement to use `git stash` for
  exploratory work.

## Week 4 — DB-related habits change

- Pulled the `ai-native-database` Skill into `.claude/skills/`.
- Refactored `DATABASE_URL` / `DIRECT_URL` in `.env` so Prisma
  migrations went through the direct endpoint. Discovered (and
  removed) one always-on serverless function that had been holding 30
  direct connections to Neon.
- Stopped running `prisma migrate dev` after every schema edit during
  exploration. Pattern that worked: edit `schema.prisma` freely, run
  `prisma migrate dev --create-only` once per feature, review the SQL
  before letting it apply.
- One previously-painful incident — partially-applied migration that
  blocked deploys — became impossible because Neon branch + direct
  URL caught it on the preview deploy.

## Week 8 — what the team kept and what they dropped

**Kept:**

- `ai/<feature>` branches everywhere. No more `username/whatever`
  patterns from before.
- Draft PR by default. Reviewers ignored drafts until requested.
- Squash merge as the *only* option.
- Concurrency-group debounce on every CI workflow.
- Pre-push checklist as a 30-second self-check.

**Dropped:**

- The recommendation to commit *only* once per feature. In practice
  ~2 commits per feature happened (one for the change, one for tests
  or docs). The rule "one commit per stable feature" was too tight;
  "no commits exposed to the remote that don't stand on their own"
  was tight enough.

**Modified:**

- The team added a `human/<topic>` branch prefix for human-only work
  (no AI involvement) so that PRs could route to a different review
  template. Not in the spec — just useful locally.

## Week 12 — the numbers

| Metric | Before adoption | After 12 weeks |
| --- | --- | --- |
| Commits per day | ~80 | ~14 |
| Junk commits on `main` (squashed history) | ~50% | 0 (squash + commit lint) |
| CI minutes / month | 8,400 | 2,300 |
| Production migration incidents | 4 in 3 weeks | 0 in 9 weeks |
| Average open PR age | 5.2 days | 1.4 days |
| "Where did my branch go?" support pings | weekly | none |

**Numbers are composite and synthetic.** Your mileage will vary; the
shape of the wins (commit volume down, CI cost down, migration
incidents down) is the consistent pattern across teams we've heard
from.

## What surprised them

1. **The biggest win wasn't the spec — it was disabling auto-commit
   in every tool.** The spec gave the team permission to demand it.
2. **The "draft PR by default" rule** turned out to be the biggest
   morale win. Engineers stopped being interrupted by their own
   half-finished work.
3. **The bilingual standard mattered more than expected.** Two
   designers and one engineer read the Chinese version preferentially
   and only switched to English when discussing specifics with the
   rest of the team.
4. **The lint workflow caught more "from-AI" mistakes than from
   humans.** That's the point — humans had years of training; the
   agents have hours.

## What they'd do differently

- Adopt earlier. Most of the productivity hit pre-adoption was
  recovering from `main` damage, not the AI itself.
- Set up the lint scripts on day 1, not week 1.
- Configure `concurrency.cancel-in-progress` before anything else in
  CI. It's the single biggest cost lever.

## Reference

This case study is a composite. If you'd like to share your own (real
or anonymized), open a translation/case-study issue from the
[`.github/ISSUE_TEMPLATE/`](../.github/ISSUE_TEMPLATE/).
