# Changelog

All notable changes to **agents-md** are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added

- `docs/agent-teams.md` (+ zh-CN) — new `STANDARDS.md` §20. Codifies
  the orchestration pattern now shipping in the wild (Lauren Tan /
  Cursor 2.0 / Grok Build / Claude Code worktrees): Chief of Staff
  plans and aggregates, Executors work in isolated `git worktree`s,
  Judges score against a pre-written rubric using a different model
  family. Covers the 5-layer validation stack
  (lint → unit → eval → cross-model judge → human meta-gate), when
  NOT to go parallel, worktree lifecycle, anti-patterns, and a
  minimum manual implementation that needs no orchestration
  framework.
- `docs/evals.md` (+ zh-CN) — new "Cross-model judge" section:
  different model family than the Executor; different vendor when
  cost allows; judge receives only rubric + output (never the task);
  two-vote quorum beats single strong judge on
  disagreement-cheap tasks; Judge prompt skeleton.
- `docs/agent-behavior.md` (+ zh-CN) §6 Rule-baking flywheel —
  recurring failures must escalate out of the prompt into
  `scripts/lint-*.sh`, then into `evals/<name>/dataset.jsonl`, then
  into dedicated Reviewer skills. The spec is the long-term memory
  the prompt doesn't have.
- `STANDARDS.md` §20 (+ zh-CN) — pointer-index for the agent-teams
  chapter, with the three-role contract summarized inline per the
  canonical-source rule.
- `STANDARDS.md` §17.3 (+ zh-CN) — cross-ref to the new cross-model
  judge section.
- `docs/README.md` — new "Orchestration (multi-agent)" section.

### Added

- `docs/github-issues-projects.md` (+ zh-CN) — a platform-neutral
  Backlog and Kanban workflow for GitHub Issues and Projects, including
  multi-repository parent/sub-issue ownership, structured fields,
  definitions of Ready and Done, WIP limits, iterations, and automation.
- `STANDARDS.md` §19 (+ zh-CN) — canonical lifecycle and agent-authority
  rules for issue-based work tracking.
- Root and distributable `AGENTS.md` / `CLAUDE.md` entry points now require
  canonical Issues, linked PRs, truthful status, and human authorization
  for new planning commitments.
- `docs/machine-readable-docs.md` (+ zh-CN) — new §17.5 in
  `STANDARDS.md`. Codifies the emerging pattern where vendors
  publish their docs at predictable `.md` endpoints (e.g. Vercel's
  [`/design.md`](https://vercel.com/design.md) and
  [`/design.dark.md`](https://vercel.com/design.dark.md), or the
  [`llms.txt`](https://llmstxt.org/) proposal). Covers both
  consumer rules (fetch the `.md` before scraping HTML; pin
  versions; cache aggressively) and producer rules (expose your own
  `.md`; keep it in sync with the code; version the URL).
- `docs/agent-behavior.md` §1 extended with a one-paragraph
  reference to the new chapter — the "search before generating"
  rule now applies to external vendor docs as well as internal
  codebase.
- `docs/outlook.md` "concrete signals" list gains a bullet for
  Vercel Geist `/design.md` and the `llms.txt` proposal.

## [0.2.0] - 2026-06-06

### Added — AI-specific & platform-engineering chapters

- `docs/secrets.md` (+ zh-CN) — secrets, credentials, OIDC, redaction.
- `docs/prompts.md` (+ zh-CN) — prompts as code, semver, A/B variants.
- `docs/evals.md` (+ zh-CN) — eval suites, thresholds, regression
  blocking, tooling map.
- `docs/observability.md` (+ zh-CN) — per-call trace, OTel GenAI
  conventions, PII redaction, budget guardrails, circuit breaker.
- `docs/idp-integration.md` (+ zh-CN) — Backstage / Harness IDP /
  Port / Cortex integration, Backstage Scaffolder template,
  OPA policy sketch.
- `docs/codeowners.md` (+ zh-CN) and `templates/CODEOWNERS` —
  high-blast-radius routing, additional reviewers for AI-authored
  PRs.
- `docs/doc-freshness.md` (+ zh-CN) — `.doc-coupling.yml` pattern,
  stale-doc deletion, freshness signals.
- `docs/dora.md` (+ zh-CN) — AI-adapted DORA metrics, two AI-specific
  companions (junk-commit ratio, eval pass rate).
- `STANDARDS.md` §17 / §18 — pointer indexes to the new chapters.

### Changed

- `STANDARDS.md` / `STANDARDS.zh-CN.md`:
  - Banned commit message list aligned to 9 items (was 6) — matches
    `docs/commits.md`, skills and `scripts/lint-commit-msg.sh`.
  - Conventional Commits type list expanded to 11 — adds `style` and
    `revert` to match the lint scripts and commitlint template.
  - "Canonical source" disclaimer added at the top.
- `docs/commits.md` / `.zh-CN.md`, all `skills/*/SKILL.md`,
  `templates/CLAUDE.md`, `templates/AGENTS.md` — type list updated
  to 11.

### Fixed

- `scripts/lint-commit-msg.sh` — `--pretty=format:` produces no
  trailing newline, which caused `while IFS= read -r line` to
  silently drop the final commit in a range. Switched to
  `--pretty=tformat:` so every commit is inspected.
- `.github/workflows/lint.yml` — merge commits in `pull_request`
  builds are now excluded from the commit-message lint (their
  subjects are auto-generated by GitHub and intentionally don't
  follow Conventional Commits).

## [0.1.0] - 2026-05-20

### Added — Founding release

- Bilingual (English / 简体中文) standards for AI-native Git, GitHub, CI/CD,
  database and agent-behavior workflows.
- `STANDARDS.md` / `STANDARDS.zh-CN.md`: full single-file specification.
- `docs/`: chaptered, human-readable documentation in both languages,
  including `overview`, `outlook`, `principles`, `workflow`, `branching`,
  `commits`, `push`, `pull-request`, `ci-cd`, `database`, `serverless`,
  `tech-stack`, `github-settings`, `agent-behavior`, `checklist`,
  `monorepo`, and `case-study`.
- `skills/`: installable Claude Code Skill packages (superpower-style
  `SKILL.md` with YAML frontmatter) for:
  - `ai-native-git-workflow`
  - `ai-native-commits`
  - `ai-native-ci-cd`
  - `ai-native-database`
  - `ai-native-agent-behavior`
- `templates/`: drop-in `CLAUDE.md`, `AGENTS.md`, GitHub Actions workflow,
  PR template, `.commitlintrc.json`, and Claude Code `settings.json`
  template for downstream projects.
- `scripts/`: portable bash lint scripts —
  - `lint-commit-msg.sh` — Conventional Commits + banned-message check.
  - `lint-branch-name.sh` — `ai/<feature>` convention check.
  - `check-bilingual.sh` — every EN doc has a `.zh-CN.md` pair.
  - `check-links.sh` — every relative `*.md` link resolves.
- `.github/workflows/lint.yml`: spec self-enforcement workflow (PR-only,
  concurrency-debounced).
- `.github/ISSUE_TEMPLATE/`: bug, spec-question, translation, and config.
- `.editorconfig`: shared formatting baseline across tools and agents.
- Project entry points: `CLAUDE.md`, `AGENTS.md`, `docs/overview.md`,
  `docs/outlook.md`.
- Open-source meta: `LICENSE` (MIT), `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`.
