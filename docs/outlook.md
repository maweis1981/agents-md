# Outlook

> Where AI-native development goes from here.
> 中文：[`outlook.zh-CN.md`](./outlook.zh-CN.md)

## Today: a compatibility layer

`agents-md` is, in honest terms, a **compatibility layer** between
AI coding agents and a Git/GitHub world that was designed for humans.

The compatibility layer is necessary because:

- Git diffs are line-based, not intent-based.
- GitHub Actions assume each push is a deliberate human decision.
- Branch protection assumes a small, named set of reviewers.
- Database migration tooling assumes humans coordinate one change at
  a time.
- Most CI providers bill per build invocation, not per *coherent* unit
  of work.

The rules in `STANDARDS.md` are the minimum set that lets an AI agent
operate inside that world without setting it on fire.

## Tomorrow: from `commit-driven` to `state-driven`

The longer-term direction we expect is a shift away from commit-as-unit
toward higher-level abstractions:

| Today | Tomorrow |
| --- | --- |
| **commit-driven** version control | **state-driven** version control |
| line diffs | semantic / AST diffs |
| commit messages | intent diffs |
| commit history | workflow snapshots |
| `git rebase` | semantic merge |
| PR review by humans | PR review by humans + agents |
| branch protection | policy-as-code, applied per intent |

In a state-driven world, the unit of change is **"a coherent intent
applied to the system"** — not "a tarball of line edits". The agent
records the intent; tooling produces the diff; humans review the
intent rather than the diff.

We do not have those tools yet. So we use Git, and we discipline the
agent.

## Concrete signals to watch

- **Semantic / AST diff tooling**. Tools like
  [Difftastic](https://difftastic.wilfred.me.uk/) (structural diff
  over tree-sitter) and `git diff --word-diff` for prose already exist;
  the next step is an *intent diff* — "this PR adds a feature flag,
  doesn't change auth, and refactors three components". Once intent
  diffs are as cheap as line diffs, "one PR = one feature" stops
  being a social rule and becomes a structural one.
- **AI-native IDE infrastructure**. Claude Code, Cursor, Codex, Devin,
  Windsurf, etc. are gradually treating *sessions* and *workflows*,
  rather than files, as the source of truth. The `AGENTS.md` /
  `CLAUDE.md` convention this spec leans on is itself an early
  artifact of that shift.
- **Scale-to-zero databases**. Neon, Turso, PlanetScale, and
  Supabase's pooled+direct split are already production-grade. Always-on
  Postgres clusters as a default for early-stage projects are on the
  way out.
- **Event-driven serverless runtimes**. Inngest, Trigger.dev, QStash,
  Cloudflare Queues, etc. replace always-on agent loops with
  message-triggered workers. The economics finally match AI's bursty
  load profile.
- **Policy-as-code branch protection**. GitHub Rulesets, OpenSSF
  Scorecard, and per-repo GitOps policy engines hint at where this
  goes: rules expressed not as "must pass these checks" but as "must
  satisfy this intent" — verifiable by another agent.
- **Machine-readable vendor docs**. Vercel publishes Geist at
  [`/design.md`](https://vercel.com/design.md) and
  [`/design.dark.md`](https://vercel.com/design.dark.md); the
  [`llms.txt`](https://llmstxt.org/) proposal is converging across
  doc sites. Agents stop scraping HTML; vendors stop pretending the
  docs site is the only consumer. See
  [`machine-readable-docs.md`](./machine-readable-docs.md).

None of these are speculative — every category above has at least one
shipping product. The speculation is about *which* of them becomes the
default within ~24 months.

## What we will and will not promise

We will:

- Keep the spec stable across minor versions.
- Treat breaking changes as major-version events.
- Track new agent platforms and add per-platform templates where
  helpful.
- Accept community-translated language editions.

We will not:

- Pretend Git is the final answer.
- Add tooling that *requires* a specific cloud / IDE / agent.
- Optimize for any single vendor's roadmap.

## Versioning intent

- `0.x` — Stabilizing the rules and bilingual phrasing. Expect minor
  rewording PRs.
- `1.0` — Frozen rule set. Tooling integrations (Skill packs,
  templates, examples) can keep evolving on top of a stable spec.
- `2.0` and beyond — Reserved for the moment one of the "tomorrow"
  technologies above arrives in a usable form and the spec needs to
  meaningfully change shape.

## Closing

If, two years from now, this repository is *less* necessary because
the underlying tooling caught up — that's success, not failure.

Until then: high-frequency edit, low-frequency commit.
