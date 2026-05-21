# Lint Scripts

Machine-executable checks for the `agents-md` spec. Used by this
repo's own CI (`.github/workflows/lint.yml`) and copy-paste-friendly
for downstream projects.

| Script | What it checks |
| --- | --- |
| [`lint-commit-msg.sh`](./lint-commit-msg.sh) | Commit subjects against the Conventional Commits format and the banned-message list. |
| [`lint-branch-name.sh`](./lint-branch-name.sh) | Branch names against the `ai/<feature>` convention. |
| [`check-bilingual.sh`](./check-bilingual.sh) | Every English doc has a matching `*.zh-CN.md` (and vice versa). |
| [`check-links.sh`](./check-links.sh) | Every relative `*.md` link in the repo resolves. |

## Run them all

```bash
chmod +x scripts/*.sh

scripts/lint-branch-name.sh
scripts/lint-commit-msg.sh main..HEAD
scripts/check-bilingual.sh docs
scripts/check-links.sh
```

## Using these in your own project

These are pure `bash` with no external deps beyond `git`, `grep`,
`sed`, `find`. Copy them into your repo's `scripts/` and wire them
into a workflow modeled on this repo's `.github/workflows/lint.yml`.

Adjust:

- `lint-commit-msg.sh`: tweak `TYPE_RE` if you use additional
  Conventional Commits types or scopes.
- `lint-branch-name.sh`: edit the `dependabot/*` / `claude/*` / etc.
  allow-list to match your tooling.
- `check-bilingual.sh`: edit `explicit_pairs` if your bilingual
  surface differs.

## Exit codes

All scripts: `0` on pass, non-zero on any violation. Stderr explains
what failed; stdout shows passes.
