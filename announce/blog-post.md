# Blog post (English)

> Long-form story version of the launch. Suitable for dev.to,
> Medium, Hashnode, or your own blog. ~1400 words. Pair with
> [`blog-post.zh-CN.md`](./blog-post.zh-CN.md) for the Chinese
> audience.
>
> Suggested title: **"My AI agent's CI bill was 6× higher than my
> last project's. Here's the spec I wrote to fix it."**

---

## My AI agent's CI bill was 6× higher than my last project's. Here's the spec I wrote to fix it.

For three months I let Claude Code and Cursor drive a real
production project — a small B2B SaaS, Next.js on Vercel, Postgres
on Neon, three engineers and two designers. By week two, the AI
agents were producing code maybe three times faster than the team
could review. The numbers that should have been celebrated were
instead a problem:

- 80 commits per day on `main`
- Half of those commits titled `wip`, `fix`, `update`, or `asdf`
- A CI bill 6× our comparable non-AI project
- Four partial-migration incidents in three weeks, all the same
  pattern (Prisma migration run against a pooled connection, half-applied,
  app crashed)

None of this was Claude's or Cursor's fault. The agents were doing
exactly what their default settings told them to do: commit on save,
push on commit, run CI on every push, deploy preview on every CI
green. The economics of Git, GitHub, and managed databases were
designed for a few commits per day per human developer. Plugging in
an agent that does 50 doesn't break Git — it breaks the bill.

So I started writing down what we actually changed to get back to
sane.

### What the rules look like

Three principles, then a lot of detail.

**1. AI may modify frequently. Systems may not commit frequently.**

The single most important rule, and the one all the others
derive from. *Modification* — editing a file, regenerating a function
— is local, cheap, reversible. *Commit / push / merge / deploy /
migrate* is system-wide, expensive, observable, not always reversible.
Agents naturally want to commit at the speed they modify. The discipline
is to slow them at exactly that boundary.

In practice: disable "Auto Commit" / "Auto Sync" / "Auto Push" in
every tool you control. Configure CLAUDE.md and AGENTS.md to make
this expectation explicit. Use `git stash` and local feature branches
for intermediate states. The remote does not need to see your
agent's middle-of-iteration state.

**2. A commit is a stable snapshot, not a thought process.**

A useful commit answers *"what is the system, in a coherent state,
after this change?"* — not *"what was the agent thinking at minute 14?"*
Commit messages describe the resulting capability ("complete
onboarding workflow"), not the journey ("fix typo, retry, fix import,
retry, fix padding"). One feature, one commit. Squash-merge into
`main`. Conventional Commits.

We added a tiny bash lint script that rejects commit subjects like
`wip`, `fix`, `update`, `asdf`. It catches the agent embarrassingly
often.

**3. Search before generating.**

AI agents have an extreme bias toward generation. Without explicit
discipline, every prompt produces a near-duplicate of something
that already exists in the codebase. Six months later you have
`useDebounce`, `useDebounce2`, `useDebouncedValue`, and `useDelay`
— all subtly different, all maintained by nobody.

The rule: before writing any new code, search the codebase for
existing implementations, APIs, hooks, components, schemas,
prompts. Extend the existing one. Only generate if nothing exists.

### Where the bill actually went

Once the commit cadence got under control, the CI bill dropped
~70%. The single biggest lever was `concurrency:
cancel-in-progress` in every GitHub Actions workflow — when the
agent pushes 20 times in 10 minutes, only the latest build runs
to completion. The rest are cancelled before they consume
minutes.

The second biggest lever was `paths-ignore`. The agent does a lot
of doc edits while iterating; building the full app for a
docs-only PR is pure waste. Filtering docs paths out of expensive
workflows cut another ~20%.

And `on: push` got banned for everything except `main`. Production
deploys come from merging to `main`, full stop. AI branches get
preview deploys, not production deploys.

### Where the migrations actually went

The four migration incidents had a common cause: Prisma migration
running against `DATABASE_URL`, which on Neon is the pooled
endpoint. Pooled connections in transaction mode don't reliably
support `CREATE INDEX CONCURRENTLY` and don't preserve
session-scoped settings. The migration starts, the agent moves on,
half the changes apply, the app deploys, the app crashes.

Fix: split into two URLs.

```
DATABASE_URL=postgres://...?pgbouncer=true   # runtime
DIRECT_URL=postgres://...                    # migrations
```

Prisma and Drizzle both support this split natively. The agent
should never have been running migrations through the pooled
endpoint to begin with — but the default configuration didn't
distinguish, and the agent did what was easy.

### What's actually in the spec

The repo is structured for three audiences:

- **Humans** read `STANDARDS.md` (single file) or `docs/<topic>.md`
  (chaptered). Both bilingual EN / 中文.
- **Vibe-coding tools** autoload from `skills/` (Claude Code Skill
  packages, superpower-style with YAML frontmatter) or read
  `CLAUDE.md` / `AGENTS.md` at repo root.
- **Downstream projects** copy `templates/` (CLAUDE.md, AGENTS.md,
  preview workflow, CODEOWNERS, commitlint config) and `scripts/`
  (four bash lint scripts that enforce most rules in CI).

The v0.2 release this week adds eight new chapters:

- AI-specific: secrets & OIDC, prompts as code, evals for AI
  features, observability + cost guardrails
- Platform engineering: IDP integration (Backstage / Harness IDP /
  Port / Cortex), CODEOWNERS for AI-authored diffs, doc
  freshness, DORA metrics adapted for AI cadence

### What you should steal

If you do nothing else this week:

- Add `concurrency: cancel-in-progress` to every workflow file you
  own. It's three lines and it costs you nothing if no flurry of
  pushes happens.
- Disable auto-commit, auto-sync, auto-push in your editor / agent
  settings. Three minutes of looking through preferences.
- Run `grep -r "DATABASE_URL"` in your repo and verify your
  migrations are not pointed at a pooled endpoint. If they are,
  fix it before the next migration lands.
- Add a one-line CODEOWNERS entry for any path that touches
  payments, auth, or schema. Two minutes.

Those four take an afternoon and roughly halve your AI-driven
project's pain.

### What I got wrong, and what's next

The first version of the spec said "one feature = one commit, ever."
After three months I had to relax it: in practice features often
need two commits (the change + tests, or schema + code) and forcing
them into one made the diffs worse, not better. The rule is now
"no intermediate commits exposed to the remote that don't stand on
their own."

What I haven't figured out yet:

- **Evals at scale.** The spec says "every prompt has a suite,
  every PR runs it, regressions block merge." This works for 5
  prompts. For 500 prompts, even cached evals get expensive.
  There's a chapter to write here once I've seen it work.
- **Monorepo CI affected detection** with three different tools
  in play (Turborepo, Nx, custom). The monorepo chapter is OK
  for one tool; reality is messier.
- **Solo-maintainer branch protection.** The spec assumes ≥ 2
  reviewers exist. For a 1-person OSS repo, you're either the
  author or you're not merging — needs a documented exception.

### The repo

[github.com/maweis1981/agents-md](https://github.com/maweis1981/agents-md)
— MIT licensed, no commercial interest, no upsell. The spec
itself is in `STANDARDS.md` / `STANDARDS.zh-CN.md`; chaptered
docs are under `docs/`; installable Claude Code Skills are
under `skills/`; drop-in templates are under `templates/`.

PRs, translations, and "your team does it differently and it
works better"-style issues are very welcome.

---

## Publishing notes

- **dev.to**: tag with `ai`, `productivity`, `webdev`, `opensource`,
  `devops`. Add the cover image (the case-study numbers table).
- **Medium**: submit to the *Better Programming* publication if
  you have submission rights. Otherwise post personally.
- **Hashnode**: similar tags as dev.to.
- **Your blog**: add a TL;DR box up top with the four "steal this
  week" actions. Most blog readers don't make it past paragraph 3.
- **Cross-post**: don't republish identical body to multiple
  platforms within 24 hours — search engines penalize. Stagger by
  a day, or rewrite the intro per platform.
