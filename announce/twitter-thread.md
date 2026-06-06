# Twitter / X thread

> Five tweets, posted ~2 hours after the Show HN goes up so the
> traffic spikes overlap. Tag the agent vendors and 2–3 voices in
> the niche — don't overdo the tagging.

## Tweet 1 (the hook)

```
After 12 weeks of letting @AnthropicAI Claude Code and @cursor_ai drive a
real production project, I had:

– 80 commits/day on main, half titled "wip" / "fix" / "update"
– A CI bill 6× the comparable non-AI project's
– Four partial-migration prod incidents in 3 weeks

So I wrote the rules.
```

> Attach: a screenshot of `git log --oneline` showing the
> "before" mess. Crop tight. (Take this from a real repo or
> mock one up — `scripts/lint-commit-msg.sh` flagging "wip" makes
> a great visual.)

## Tweet 2 (the artifact)

```
agents-md is a bilingual (EN / 简体中文) spec for how AI agents
should commit, branch, run CI, handle DB migrations, and ship.

It ships with bash lint scripts, Claude Code Skill packages
(superpower-style SKILL.md), and drop-in templates for
CLAUDE.md / AGENTS.md / GitHub Actions / CODEOWNERS.

https://github.com/maweis1981/agents-md
```

> Attach: the `docs/case-study.md` numbers table — "80 → 14
> commits/day, 8400 → 2300 CI minutes/month, 4 → 0 migration
> incidents".

## Tweet 3 (the deep cut)

```
The new v0.2 chapters cover the AI-only concerns:

– secrets & OIDC (no more long-lived PATs in repo Secrets)
– prompts as code (semver, A/B variants, paired with evals)
– evals for AI features (thresholds in repo, regressions block merge)
– observability + cost guardrails (per-session token budgets,
  circuit breaker on the LLM provider)

Plus IDP integration for @backstageio / @harnessio.
```

## Tweet 4 (the social proof)

```
The bash lint scripts:

scripts/lint-commit-msg.sh main..HEAD
scripts/lint-branch-name.sh
scripts/check-bilingual.sh docs
scripts/check-links.sh

You can paste them into any repo's CI in 5 minutes and start
catching what the agent missed. (And: an off-by-one in one of
them was caught by linting this PR itself. Recursion.)
```

> Attach: terminal screenshot of `lint-commit-msg.sh` rejecting
> a `wip` commit.

## Tweet 5 (the call)

```
MIT licensed. Bilingual EN / 中文 in lockstep. No upsell, no
SaaS hidden in there.

Looking for feedback on:
– what's wrong or too opinionated
– what's missing (esp. evals-at-scale)
– what your team does differently

PRs and translations very welcome.

→ https://github.com/maweis1981/agents-md
```

## Notes

- **Tag carefully**. The above tags `@AnthropicAI @cursor_ai
  @backstageio @harnessio`. Don't pile on celebrities — they
  ignore drive-by tags. Vendor-relevant tags get noticed.
- **Don't quote-tweet yourself** to push the thread back up.
  Twitter algorithm sees this as spam.
- **Reply with the thread URL** to your own follow-up content
  (newsletter, longer blog) when those land. Threads compound
  when re-surfaced naturally.
- **Track which tweet got the most engagement**. The hook tweet
  usually wins; if not, you've learned something about the audience.

## Versions for other platforms

- **LinkedIn**: combine all 5 tweets into a single ~600-word post.
  Drop the @-mentions, keep the numbers, add a more "platform
  engineering"-flavored framing in the lead.
- **Mastodon / Bluesky**: same content, looser tagging convention.
  Bluesky audience is small but more technical.
- **Weibo / 即刻**: use `blog-post.zh-CN.md`'s hook paragraph
  instead. EN tweets translated literally underperform.
