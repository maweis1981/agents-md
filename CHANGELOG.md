# Changelog

All notable changes to **agents-md** are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

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
