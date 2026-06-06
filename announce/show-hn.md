# Show HN draft

> Paste at https://news.ycombinator.com/submit. Posting window:
> Tue / Wed / Thu, 9:00 – 10:00 EST. Title goes in the "Title" box,
> URL goes in the URL box. The "comment" section below is a
> separate text comment to post on the thread within 5 minutes of
> submission.

## Title (80 chars max — HN's hard limit)

```
Show HN: Agents-md – AI-native dev standards for the Claude Code / Cursor era
```

Alternates if the above gets buried:

- `Show HN: Conventions for code written by AI agents (bilingual)`
- `Show HN: Why my AI agent's CI bill was 6x higher, and the spec I wrote`

## URL

```
https://github.com/maweis1981/agents-md
```

## First comment (post within 5 min of submission)

```
Hi HN — author here.

I'm a dev who started letting Claude Code and Cursor drive a real
production project for ~12 weeks. By week 2 I had:

  - ~80 commits/day on main, half titled `wip`/`fix`/`update`
  - A CI bill 6× what comparable non-AI projects pay
  - Four partial-migration incidents in three weeks

None of those are Claude or Cursor's fault. They're the result of
naively wiring an AI agent into a Git/GitHub workflow that was
designed for human commit cadence. So I wrote down the rules I
ended up needing.

Agents-md is a bilingual (English + 简体中文) spec covering:

  - Branching, commits, push, PRs (incl. one PR = one feature,
    squash-only merge)
  - CI/CD posture (no on:push deploys, concurrency-group debounce,
    preview-only for AI branches)
  - Database hygiene (direct connection for migrations, pooled
    for runtime, no "one migration per prompt")
  - AI-specific concerns: secrets/OIDC, prompts as code, evals
    for AI features, observability + cost guardrails
  - Platform-engineering chapters: how it slots into Backstage,
    Harness IDP, Port, Cortex

It ships with:
  - Bash lint scripts that enforce most of the above on PRs
  - Installable Claude Code Skill packages (the
    superpower-style SKILL.md format)
  - Drop-in templates: CLAUDE.md, AGENTS.md, GitHub Actions
    workflow, CODEOWNERS, commitlint config

What I'd love feedback on:

  1. Are any of the rules just wrong or too opinionated?
  2. What's missing? I know there's no "secret rotation runbook"
     or "evals at scale" chapter yet.
  3. Has anyone done this differently and found something that
     works better? (E.g. anyone using AST diffs successfully
     instead of squash + Conventional Commits?)

Also happy to take requests for new chapters — secrets, monorepos,
DORA-for-AI-teams, IDP integration, etc. are all in there;
DX-around-evals is what I'd write next.

MIT licensed, no commercial interest, no upsell. Just the rules
I wish I'd had on day 1.
```

## Tactical notes for posting

- **Don't edit the title after submission.** HN punishes title
  edits and there's no way to recover.
- **Reply to every top-level comment in the first 4 hours**, even
  the dismissive ones. Engagement signals matter for ranking.
- **Don't argue with detractors.** Thank them, concede where you
  can, explain the tradeoff where you can't.
- **No emojis in the title or first comment.** HN crowd reads
  emoji as cringe/marketing.
- **If submission gets <10 upvotes in 30 min**, it won't recover.
  Consider re-posting with a different title 48 hours later (HN
  allows this; back-to-back resubmissions get flagged).
- **If submission hits front page**, immediately switch to "monitor
  mode" — checking every 10 min is enough, the discussion drives
  itself.

## Backup hook variants

If you find yourself needing a different angle in a follow-up
post:

- The pain hook (used above): "My CI bill was 6× higher"
- The discipline hook: "I let AI agents commit to my repo for 3
  months and learned 18 rules"
- The bilingual hook: "An English/中文 spec for the AGENTS.md era"
- The tools hook: "Conventions + a Claude Code Skill pack +
  GitHub Actions workflow"
