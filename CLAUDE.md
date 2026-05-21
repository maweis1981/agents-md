# CLAUDE.md

> Entry point for **Claude Code** working inside the `agents-md` repository.
> If you are an AI agent reading this file: stop and read it fully before
> editing anything.

## What this repository is

`agents-md` is **a specification**, not an application. It documents how
AI agents should behave when operating on Git, GitHub, CI/CD, databases
and serverless infrastructure during a *vibe coding* engagement.

There is no app to run, no test suite to pass, no migration to apply.
The "build artifacts" are Markdown files.

## Where to look

| Looking for… | Go to |
| --- | --- |
| The full spec (single file) | [`STANDARDS.md`](./STANDARDS.md) / [`STANDARDS.zh-CN.md`](./STANDARDS.zh-CN.md) |
| Chaptered human docs | [`docs/`](./docs/) |
| Installable skills (superpower-style) | [`skills/`](./skills/) |
| Drop-in templates for downstream projects | [`templates/`](./templates/) |
| Machine-executable spec checks | [`scripts/`](./scripts/) |
| Future direction | [`docs/outlook.md`](./docs/outlook.md) |
| 1-page overview | [`docs/overview.md`](./docs/overview.md) |

## How you should behave in this repo

This repository is itself a real-world test of its own rules. You must
follow them when editing it.

### Branching

- **Never** commit to or push `main` directly.
- Work on a `ai/<feature>` branch — e.g. `ai/clarify-ci-section`,
  `ai/add-cursor-skill`.
- Branch lifetime should be short: open a PR as soon as the feature is
  coherent, not when every typo is fixed.

### Commits

- Modify freely *locally*. Do **not** commit on every file save.
- Commit only at *stable feature checkpoints* — e.g. "one full chapter
  translated", "one skill pack added", not "fixed a typo in line 42".
- Use Conventional Commits prefixes (`feat:`, `fix:`, `docs:`, `refactor:`).
- Never produce empty / filler commits (`update`, `wip`, `tmp`).

### Pull requests

- One PR = one logical change.
- Default to **draft PRs** until ready for review.
- Squash-merge into `main`.

### Bilingual consistency

- Any change to an English doc that affects semantics **must** be
  mirrored in the Chinese version, and vice versa. If you cannot
  reasonably translate, leave a `TODO(i18n):` marker and call it out in
  the PR description.
- File naming: English is the default (`overview.md`), Chinese uses the
  `.zh-CN.md` suffix (`overview.zh-CN.md`).

### Skills

- Each skill lives under `skills/<skill-name>/SKILL.md` with valid YAML
  frontmatter (`name`, `description`).
- Keep skills *focused*. If a skill description starts saying "and also
  …", split it.
- Skill content should be actionable rules, not prose.

### What you must NOT do here

- Generate "examples" of source code, apps, migrations, agents, etc.
  unless explicitly asked. This is a docs repo.
- Create new top-level directories without being asked.
- Add npm / pnpm / pip / build tooling. Plain Markdown is the build.
- Add CI that runs on `push` to every branch. If you add CI, it must
  follow [`docs/ci-cd.md`](./docs/ci-cd.md) — `pull_request` only,
  preview deploys only.

## Quick recap of the standards you yourself must follow

1. **High-frequency edits, low-frequency commits.**
2. **`ai/<feature>` branches only — never `main`.**
3. **One PR, one feature, squash merge.**
4. **No `push`-triggered full deploys.**
5. **Production from `main` only.**
6. **Direct connection for migrations; pooled for runtime.**
7. **Aggregate schema changes.**
8. **Search before generating; reuse before creating.**
9. **Cap retries; never loop forever.**
10. **Event-driven, scale-to-zero.**

The canonical wording lives in [`STANDARDS.md`](./STANDARDS.md).
