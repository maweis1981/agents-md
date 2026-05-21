# CLAUDE.md

> Entry point for Claude Code in **<project-name>**.
> This project follows the [agents-md](https://github.com/maweis1981/agents-md)
> AI-native development standard (`v0.1.x`).

If you are Claude Code (or any AI agent) reading this file, follow the
rules below on every change. Hard rules are non-negotiable.

---

## Hard rules

1. **Never push to `main`.** Work on an `ai/<feature>` branch.
2. **Modify locally as much as you want; commit infrequently.** One
   commit per stable, coherent feature.
3. **Commit messages** follow Conventional Commits:
   `type: short summary` (`feat`, `fix`, `refactor`, `docs`, `chore`,
   `test`, `perf`, `build`, `ci`). No `wip`, `tmp`, `update`, `fix`,
   `asdf`.
4. **One PR = one feature.** Open as a draft. Squash merge only.
5. **No `on: push` full deploys.** PR-only / manual dispatch only.
6. **DB migrations**: direct connection. Runtime: pooled connection.
   No "one migration per prompt"; aggregate schema changes first.
7. **Search before generating** — reuse components / utils / schemas
   instead of creating parallel ones.
8. **Cap retries at 3**, with a new hypothesis each time. Then stop
   and surface the failure.
9. **No polling loops.** Use webhooks / queues / events.

## Project specifics (edit me)

- **Stack**: <e.g. Next.js + Prisma + Neon, deployed on Vercel>.
- **Migrations**: <e.g. `pnpm prisma migrate dev` with `DIRECT_URL`>.
- **Tests**: <e.g. `pnpm test`>.
- **Lint / type-check**: <e.g. `pnpm lint && pnpm typecheck`>.
- **Preview deploy**: <e.g. automatic on PR via Vercel>.
- **Production deploy**: <e.g. on merge to `main`>.

## Pre-push checklist (run through every time)

- [ ] Branch is `ai/<feature>`.
- [ ] Commit message follows the format.
- [ ] No secrets / `.env` / credentials in the diff.
- [ ] Local tests / type-check pass.
- [ ] No infinite loops or pollers left running.
- [ ] If a migration: verified on a non-production DB; reversible or
      rollback documented.
- [ ] You are not pushing solely to see if CI passes.

## When in doubt

Stop. Surface the question. Do not guess at Git history changes,
migrations, deployments, or anything else with cross-system effects.

## Reference

Full spec: <https://github.com/maweis1981/agents-md/blob/main/STANDARDS.md>.
中文: <https://github.com/maweis1981/agents-md/blob/main/STANDARDS.zh-CN.md>.
