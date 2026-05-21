# agents-md

> **AI-Native Development Standards for the Vibe Coding Era**
>
> A bilingual (English / 简体中文) specification and installable skill pack
> for how AI agents — Claude Code, Cursor, Codex / OpenAI Agents, Devin,
> Windsurf, and friends — should commit code, manage branches, run CI/CD,
> handle database migrations, and ship to production.

[English](./README.md) ・ [简体中文](./README.zh-CN.md)

---

## Why this exists

AI agents generate code at a speed humans were never designed to commit at.
Naively wiring an agent into Git produces:

- GitHub API rate-limit storms
- Runaway GitHub Actions / CI bills
- Unreadable commit history (`fix`, `wip`, `update`, `asdf` × 500)
- Deployment storms in production
- Always-on database connections from short-lived agents
- Schema migrations applied through pooled connections (and breaking)

`agents-md` is a **compatibility layer between AI coding and traditional
Git workflows**. It encodes the rules a team needs so that AI can iterate
fast *locally* while the *system* remains low-churn and production-safe.

## What's inside

| Path | Purpose |
| --- | --- |
| [`STANDARDS.md`](./STANDARDS.md) / [`STANDARDS.zh-CN.md`](./STANDARDS.zh-CN.md) | The full single-file spec — read this first. |
| [`docs/`](./docs/) | Chaptered, human-readable docs (EN + zh-CN). |
| [`skills/`](./skills/) | Installable Claude Code **Skill** packages. |
| [`templates/`](./templates/) | Drop-in `CLAUDE.md`, `AGENTS.md`, GitHub Actions workflow, settings. |
| [`CLAUDE.md`](./CLAUDE.md) | Entry point Claude Code reads automatically. |
| [`AGENTS.md`](./AGENTS.md) | Entry point Codex / OpenAI Agents / Cursor read automatically. |

## Quick install

### Option A — Drop the whole standard into your project

```bash
# In your repo root
curl -L https://raw.githubusercontent.com/maweis1981/agents-md/main/templates/CLAUDE.md   -o CLAUDE.md
curl -L https://raw.githubusercontent.com/maweis1981/agents-md/main/templates/AGENTS.md   -o AGENTS.md
```

Both files reference the canonical `STANDARDS.md` and contain the
minimum rules the agent must follow.

### Option B — Install a single Skill (Claude Code, superpower-style)

```bash
# Project-scoped skill
mkdir -p .claude/skills
cp -r path/to/agents-md/skills/ai-native-git-workflow .claude/skills/
```

Claude Code will autoload the skill when its trigger conditions match
(see the YAML frontmatter in each `SKILL.md`).

### Option C — Vendor the whole repo as a submodule

```bash
git submodule add https://github.com/maweis1981/agents-md docs/agents-md
```

> **Tip on stable URLs**: The `curl` commands above point at `main`.
> For a reproducible setup, replace `main` with a tagged release
> (e.g. `v0.1.0`) so your install pinning doesn't drift when this
> repo evolves.

### Option D — Enforce the rules in CI

This repo also ships small `bash` lint scripts under
[`scripts/`](./scripts/) that check Conventional Commits, branch
naming, bilingual symmetry, and internal links. Copy them into your
own project's `scripts/` and wire them into a workflow modeled on
[`.github/workflows/lint.yml`](./.github/workflows/lint.yml). The
companion [`templates/.commitlintrc.json`](./templates/.commitlintrc.json)
configures `@commitlint/cli` with the same ruleset for projects that
already run commitlint via Husky.

## The ten rules at a glance

1. **AI may modify frequently — but must commit infrequently.**
2. **Never let an agent push directly to `main`.** Use `ai/<feature>` branches.
3. **One PR = one feature.** Merge with **squash**, not merge-commits.
4. **No `on: push` full deploys.** Use `pull_request` or `workflow_dispatch`.
5. **Production deploys come from `main` only.** Agent branches → preview / staging.
6. **Migrations run on a direct connection.** App runtime uses a pooled one.
7. **Aggregate schema changes.** No "one migration per prompt".
8. **Search before generating.** Reuse existing components, utils, schemas, prompts.
9. **No infinite retry loops.** Cap retries, surface failure, ask a human.
10. **Event-driven, not polling.** Scale-to-zero is the default posture.

The full ruleset, including rationale and examples, lives in
[`STANDARDS.md`](./STANDARDS.md).

## Status

`v0.1.0` — founding release. The spec is stable enough to adopt, and we
expect breaking changes only at major version bumps.

## Contributing

PRs, translations, and additional skill packs are welcome. See
[`CONTRIBUTING.md`](./CONTRIBUTING.md). All contributors are expected to
follow the [Code of Conduct](./CODE_OF_CONDUCT.md).

## License

[MIT](./LICENSE). Use it, fork it, ship it.

---

> *Git was not designed for AI agents. Until something better arrives,
> these rules are the bridge.*
