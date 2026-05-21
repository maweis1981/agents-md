# Overview

> One-page introduction to `agents-md`.
> 中文：[`overview.zh-CN.md`](./overview.zh-CN.md)

## The problem

Modern AI coding agents — Claude Code, Cursor, Codex / OpenAI Agents,
Devin, Windsurf — can produce hundreds of code changes per hour. Git,
GitHub, CI/CD pipelines, and managed databases were designed around
*human* commit cadence (a few commits per day per developer).

When you naively wire an agent into that pipeline, you get:

- **Rate-limit storms**: GitHub API blocks; agents fail mid-task.
- **Cost explosions**: every push triggers a build; staging spins up
  hundreds of times.
- **Unreadable history**: `fix`, `wip`, `update`, `tmp`, repeated
  dozens of times — review becomes impossible.
- **Deploy storms**: production redeploys on every save.
- **DB damage**: schema migrations applied through pooled connections
  break in production.
- **Resident agents**: long-running loops hold open connections to
  scale-to-zero databases, breaking the cost model.

## The thesis

> **AI may modify frequently. The system must commit infrequently.**

A *commit* should be a stable snapshot of the system, not a frame of
the agent's thinking. The agent's high-frequency activity stays local;
the cross-system event (push, merge, deploy, migrate) stays low-frequency.

## What `agents-md` provides

1. **A bilingual specification** (`STANDARDS.md` / `STANDARDS.zh-CN.md`)
   covering ten topic areas — branching, commits, push, PRs, CI/CD,
   databases, agent behavior, serverless, stack, and GitHub settings.

2. **Chaptered docs** under `docs/` for teams who prefer chapter-sized
   reading and link-friendly references.

3. **Installable Claude Code Skills** under `skills/`, written
   superpower-style with `SKILL.md` + YAML frontmatter, so a vibe-coding
   tool can autoload only the skill it needs (e.g. only the
   commit-discipline skill, only the CI/CD skill).

4. **Drop-in templates** under `templates/` — a project that wants the
   whole standard can copy `CLAUDE.md`, `AGENTS.md`, and the example
   GitHub Actions workflow into their repo and be done.

## Who this is for

- Teams running a "vibe coding" workflow with AI agents touching real
  Git repos.
- Open-source maintainers who want a baseline ruleset to point AI
  contributors (and humans) at.
- Tooling authors building AI-native CI/CD, DB migration, or branching
  systems.

## What it is not

- Not an opinion about *which* AI agent you use. It's stack-agnostic.
- Not a build system. Plain Markdown is the only artifact.
- Not a runtime enforcement tool. You wire enforcement into your own
  CI / branch-protection rules; this repo just gives you the rules.

## Where to go next

- [`outlook.md`](./outlook.md) — Where AI-native development goes from here.
- [`../STANDARDS.md`](../STANDARDS.md) — Full specification, single file.
- Topic-by-topic docs in this directory.
- [`../skills/`](../skills/) — Installable Skill packs.
- [`../templates/`](../templates/) — Drop-in files for your repo.
