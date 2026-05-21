# Templates

Drop-in files for downstream projects that want to adopt the
`agents-md` standard with minimum effort.

## What's here

| File | Where to put it in your project | Purpose |
| --- | --- | --- |
| [`CLAUDE.md`](./CLAUDE.md) | Repo root | Entry point Claude Code reads automatically. |
| [`AGENTS.md`](./AGENTS.md) | Repo root | Entry point OpenAI Codex / Cursor / Devin / Windsurf read automatically. |
| [`.github/workflows/preview.yml`](./.github/workflows/preview.yml) | `.github/workflows/` | A PR-only, debounced preview workflow that follows the CI/CD section of the spec. |
| [`.github/PULL_REQUEST_TEMPLATE.md`](./.github/PULL_REQUEST_TEMPLATE.md) | `.github/` | PR description scaffold. |
| [`.commitlintrc.json`](./.commitlintrc.json) | Repo root | `@commitlint/cli` config enforcing the agents-md commit rules. |
| [`claude-settings.json`](./claude-settings.json) | `.claude/settings.json` | Claude Code project settings template (illustrative — verify syntax with your Claude Code version). |

## Quick install

From your project root:

```bash
# Pull in the agent entry points
curl -L https://raw.githubusercontent.com/maweis1981/agents-md/main/templates/CLAUDE.md   -o CLAUDE.md
curl -L https://raw.githubusercontent.com/maweis1981/agents-md/main/templates/AGENTS.md   -o AGENTS.md

# Pull in the PR template
mkdir -p .github
curl -L https://raw.githubusercontent.com/maweis1981/agents-md/main/templates/.github/PULL_REQUEST_TEMPLATE.md   -o .github/PULL_REQUEST_TEMPLATE.md

# Pull in the preview workflow
mkdir -p .github/workflows
curl -L https://raw.githubusercontent.com/maweis1981/agents-md/main/templates/.github/workflows/preview.yml   -o .github/workflows/preview.yml
```

After installing, **edit** the files to match your project: replace
the placeholder `<project>` references, point CI to your actual test
commands, set up the GitHub branch protection described in
[`../docs/github-settings.md`](../docs/github-settings.md).

## Note on `claude-settings.json`

Claude Code reads project settings from `.claude/settings.json`. The
template in this directory is named `claude-settings.json` so it
doesn't conflict with whatever's in this repo's own `.claude/`. Copy
it to `.claude/settings.json` in *your* project, not in this one.
