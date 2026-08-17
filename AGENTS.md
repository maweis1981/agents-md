# AGENTS.md

> Entry point for **OpenAI Codex / OpenAI Agents / Cursor / Devin /
> Windsurf** and any other AI coding agent that auto-reads `AGENTS.md`
> at repo root.

`agents-md` is a docs-only repository that *defines* how AI agents
should work. There is no app, no build, no test runner.

If you are an AI agent reading this file, follow these rules while
editing the repo.

---

## TL;DR — non-negotiable rules

1. **Don't push to `main`.** Use `ai/<feature>` branches.
2. **Don't commit on every change.** Group local edits into one stable
   commit per logical feature.
3. **One PR = one feature.** Open it as a draft until ready.
4. **No `push`-triggered CI** in this repo. PR-only or manual dispatch.
5. **Keep English and Chinese versions in sync.** Files ending in
   `.zh-CN.md` mirror their English counterpart.
6. **Don't add code / build tooling.** This is a Markdown spec repo.
7. **Track material work in GitHub Issues.** Start only Ready work,
   keep Project status truthful, and link the implementation PR.

The full standard is in [`STANDARDS.md`](./STANDARDS.md) (English) and
[`STANDARDS.zh-CN.md`](./STANDARDS.zh-CN.md) (中文). The summary you
just read is a subset, not a replacement.

## Issue and Project tracking

- Find or create the canonical Issue before material work. Put it in
  the repository that owns the primary deliverable.
- For cross-repository outcomes, use one parent Issue and linked
  repository-specific sub-issues; do not create unlinked duplicates.
- Confirm Definition of Ready before implementation. Assign an owner,
  record blockers, and move Status as reality changes.
- Link the Pull Request to the Issue. Mark Done only after acceptance
  criteria, required checks, merges, and dependencies are complete.
- Do not change Priority, Iteration, Target date, scope, or acceptance
  criteria when that would create a new commitment without human authority.

Canonical rules are in [section 19 of `STANDARDS.md`](./STANDARDS.md#19-github-issues-and-projects-workflow), with operating examples in
[`docs/github-issues-projects.md`](./docs/github-issues-projects.md).

---

## Where things live

| Path | Purpose |
| --- | --- |
| `STANDARDS.md` / `STANDARDS.zh-CN.md` | Full spec, single file. |
| `docs/` | Chaptered docs, bilingual. |
| `skills/` | Claude Code Skills (also useful as plain prompts). |
| `templates/` | Files downstream projects copy into their own repo. |
| `CLAUDE.md` | Claude Code's entry point (similar content to this file). |

## Conventions for editing

### Files

- English files use the bare name: `overview.md`.
- Chinese files use the suffix: `overview.zh-CN.md`.
- Don't rename files without updating cross-links in both `README` files
  and `STANDARDS.md`.

### Commits

Conventional Commits, kept terse and English:

```
feat: add cursor agent skill pack
docs(zh-CN): align database section with English
fix: correct broken link in STANDARDS.md
```

### Bilingual sync

If you change semantics in `docs/<topic>.md`, you also change
`docs/<topic>.zh-CN.md` in the **same commit**. If you cannot reasonably
translate (e.g. you are an English-only agent), add a top-of-file
`TODO(i18n): pending translation of <section>` and surface it in the PR
description so a human or another agent can finish the work.

### Skills

Every skill under `skills/<name>/SKILL.md` must have valid YAML
frontmatter:

```yaml
---
name: <name>
description: <when to use this skill, in one sentence>
---
```

A skill is *focused*. If you find yourself writing "and also …" in the
description, split it.

## What this repo is *not*

- Not an application — don't add `package.json`, `requirements.txt`, etc.
- Not a sandbox to demo code — don't add example apps unless asked.
- Not a place to test CI tooling — any workflow added here must itself
  obey the rules in [`docs/ci-cd.md`](./docs/ci-cd.md).
