# CODEOWNERS & Review Routing

> AI-generated diffs need different review rigor than human ones.
> Route them differently.
> 中文：[`codeowners.zh-CN.md`](./codeowners.zh-CN.md)

A reviewer scanning a diff makes one of two implicit assumptions:

- "Human wrote this. They had a reason for each line."
- "Agent wrote this. The reason for each line is whatever the prompt
  asked for."

The second assumption demands more scrutiny. CODEOWNERS is the
mechanism to make sure the *right* reviewer is on the hook.

## Hard rules

1. **A `CODEOWNERS` file exists at repo root.**
2. **High-blast-radius paths require human review.** Migrations,
   auth, IAM, billing, payment, prompts.
3. **AI-generated diffs to high-blast-radius paths require an
   *additional* reviewer**, not just the default owner.
4. **CODEOWNERS lives behind the same branch protection as `main`.**
   Removing an owner is itself a PR.

## High-blast-radius paths (the must-cover set)

```
# CODEOWNERS

# Schema / migrations — always senior + DBA
/prisma/                      @team-platform @dba-on-call
/drizzle/                     @team-platform @dba-on-call
/migrations/                  @team-platform @dba-on-call

# Auth & IAM
/lib/auth/                    @team-security
/middleware/auth/             @team-security
/.github/workflows/           @team-platform

# Payment / billing
/lib/billing/                 @team-finance @team-platform
/app/api/billing/             @team-finance @team-platform

# Prompts — paired review with eval owner
/prompts/                     @team-llm @team-product
/evals/                       @team-llm @team-product

# Secrets / config
/.env.example                 @team-security
/scripts/deploy/              @team-platform

# The spec for THIS repo
/STANDARDS.md                 @maintainers
/docs/                        @maintainers
```

## Marking AI-authored PRs

Three workable signals; pick the one your tooling supports:

1. **Branch prefix**: `ai/...` already encodes "agent driven".
   Branch-protection rules can require an extra review for `ai/**`.
2. **PR label**: every agent-opened PR gets an `ai-authored` label
   (set by your agent runner). A workflow can require a label-gated
   additional reviewer.
3. **Trailer in commit**: `Co-Authored-By: Claude <…>` is detectable
   from the commit message. Less reliable than a label.

Pick one and apply consistently.

## Required-reviewers ruleset for `ai/**`

In GitHub Rulesets, scope a rule to branches matching `ai/**`:

- Require pull request before merging.
- Require approvals: at least 2 if any owner of a high-blast-radius
  path is touched.
- Require review from Code Owners.
- Block merge if the PR author resolves their own reviews.

This turns "must have human review" into a structural property of the
branch namespace, not a social one.

## Failure modes

- **CODEOWNERS gets stale**. The named team disbands; nobody reviews.
  Mitigation: a monthly check that every team referenced in
  CODEOWNERS still exists in GitHub.
- **Single owner becomes a bottleneck**. Always list at least two
  owners (`@a @b`) for high-blast-radius paths.
- **Agent-author is also the owner**. If the agent's "user" is in a
  CODEOWNERS team, exclude it from auto-approval. The agent must not
  self-approve.

## CODEOWNERS templates

A drop-in template lives in [`../templates/CODEOWNERS`](../templates/CODEOWNERS).
Edit teams and paths to match your project.

## Reference

- [GitHub CODEOWNERS docs](https://docs.github.com/en/repositories/managing-your-repositories-settings-and-features/customizing-your-repository/about-code-owners)
- [`github-settings.md`](./github-settings.md) for the wider
  branch-protection setup.
- [`pull-request.md`](./pull-request.md) for what a PR needs to look
  like.
