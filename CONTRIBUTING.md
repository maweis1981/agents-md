# Contributing

Thanks for considering a contribution to **agents-md**. This is a
docs-only repo whose entire purpose is to define how AI-driven
contribution should work — so we eat our own dogfood.

中文版本：[`CONTRIBUTING.zh-CN.md`](./CONTRIBUTING.zh-CN.md)

## What we accept

- **Typo / wording fixes** — always welcome.
- **Translations** — new language editions, or improving the existing
  English / 简体中文.
- **New skills** under `skills/` — focused, single-trigger Skill packs.
- **New templates** under `templates/` — drop-in files for downstream
  projects (other CI providers, other agents, other languages).
- **Clarifications to the spec** — opening a discussion / issue first
  is appreciated; rules that change semantics need explicit buy-in.
- **Bug reports** on broken links, broken examples, or contradictions
  between the chapters.

## What we do not accept (yet)

- New top-level directories beyond what's here.
- Build tooling (`package.json`, `pnpm-lock.yaml`, etc.). Plain
  Markdown is the build.
- Source-code examples bundled into the repo. We may add a separate
  `examples/` repository later, but not in this one.

## How to contribute (in this repo)

This repo is itself bound by the standard it documents. So:

1. **Branch**: `ai/<feature>` if your work is agent-driven; any other
   convention for human-driven work.
2. **Edits**: iterate locally. Don't push every save.
3. **Commits**: Conventional Commits — `docs:`, `feat:`, `fix:`,
   `refactor:`. One commit per coherent change.
4. **Bilingual sync**: any semantic change to `docs/<topic>.md` must
   be mirrored in `docs/<topic>.zh-CN.md` (and vice versa). If you
   can't reasonably translate, add `TODO(i18n)` and call it out in
   the PR.
5. **PR**: open as a **draft** until ready. One PR = one feature.
6. **Merge**: squash merge into `main`. We enforce this in repo
   settings.

## What a good PR looks like

- One purpose, expressible in one sentence.
- Touches one section or one skill — not three at once.
- English + Chinese kept in sync.
- Cross-links updated if you renamed or moved a file.
- Examples (if added) tested by re-reading them as if you were the
  agent.

## Asking questions

Use GitHub Discussions / Issues. Don't hesitate to open an issue
before doing the work — a 30-second "I'm thinking about X, opinions?"
saves a lot of rebasing.

## Code of conduct

All participation is subject to the [Code of Conduct](./CODE_OF_CONDUCT.md).
