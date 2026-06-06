# DORA Metrics for AI-Driven Teams

> Track the same four metrics — but redefine them honestly for AI cadence.
> 中文：[`dora.zh-CN.md`](./dora.zh-CN.md)

The four DORA metrics (Deployment Frequency, Lead Time for Changes,
Change Failure Rate, Mean Time to Restore) were defined for human-led
teams. AI-driven development warps two of the four if you take them
literally. Track all four, but use the adapted definitions below.

## The four metrics, AI-adapted

| Metric | Classic definition | AI-adapted definition | Why |
| --- | --- | --- | --- |
| **Deployment Frequency** | How often the team deploys to production. | How often `main` deploys to production. | Agent push frequency is meaningless if it doesn't reach `main`. The spec already forces production-from-main only. |
| **Lead Time for Changes** | Time from first commit to deploy. | Time from PR opened to deploy. | First commit on an `ai/` branch happens too early to be a meaningful start signal. PR-open is when the change becomes "intended for production". |
| **Change Failure Rate** | % of deploys that cause a failure / rollback. | Same — but separate AI-authored PRs (label / branch prefix) from human-authored, and track both. | If AI's failure rate is 3× human's, you know where to invest review effort. |
| **Mean Time to Restore (MTTR)** | Time from incident to recovery. | Same. | Unchanged — the incident doesn't care who wrote the code. |

## Two new metrics worth tracking alongside

These aren't part of DORA, but they directly measure AI-team health:

| Metric | What it tells you |
| --- | --- |
| **PR junk-commit ratio** | % of PRs that, before squash, had any banned commit message (`wip`, `fix`, etc.). High = agents committing too often. |
| **Eval pass rate on first push** | % of PRs touching prompts whose eval passes without threshold adjustment. Low = prompts shipping unproven. |

## Target ranges (use as starting points, not gospel)

Based on the public DORA report bands, adjusted lightly for AI:

| Tier | Deploy Freq | Lead Time | CFR | MTTR |
| --- | --- | --- | --- | --- |
| Elite | Multiple/day | < 1 hr | 0–15% | < 1 hr |
| High | Daily–weekly | 1 day–1 week | 16–30% | < 1 day |
| Medium | Weekly–monthly | 1 week–1 month | 16–30% | < 1 week |
| Low | < monthly | > 1 month | > 30% | > 1 week |

AI-driven teams *typically* improve Deployment Frequency and Lead
Time but **regress on Change Failure Rate** unless the spec is
followed. Tracking CFR explicitly is the early warning.

## How to compute

Cheap and cheerful — even Elite teams start with a spreadsheet, not
a dashboard:

```sql
-- Deployment Frequency
SELECT DATE_TRUNC('week', deployed_at) AS week, COUNT(*) AS deploys
FROM deployments
WHERE environment = 'production' AND status = 'success'
GROUP BY 1;

-- Lead Time
SELECT
  AVG(EXTRACT(EPOCH FROM (deployed_at - pr_opened_at))/3600) AS avg_hours
FROM deployments
JOIN prs USING (commit_sha)
WHERE deployed_at >= NOW() - INTERVAL '30 days';

-- Change Failure Rate
SELECT
  100.0 * SUM(CASE WHEN caused_incident THEN 1 ELSE 0 END) / COUNT(*) AS cfr_pct
FROM deployments
WHERE deployed_at >= NOW() - INTERVAL '30 days';
```

Once you've stared at the numbers in a sheet for a quarter, *then*
build the dashboard.

## What to do with the numbers

- **Weekly skim** the four metrics. Three or four data points per
  metric are enough to spot a shift.
- **Monthly deep dive** — separate AI-authored from human-authored
  series, see if the gap is widening.
- **Quarterly re-target** — if you're holding Elite on all four for
  two quarters, raise the bar; if you're sliding, find the bottleneck.

## Anti-patterns

- **Optimizing for one metric in isolation**. Increasing Deploy
  Frequency by deploying broken code wrecks the other three.
- **Hiding AI-authored failures inside the aggregate**. Use the label
  / branch-prefix split honestly.
- **Treating MTTR < 1hr as proof of resilience**. It might just mean
  you're paged a lot.

## Reference

- [Google's DORA research](https://dora.dev/)
- [`pull-request.md`](./pull-request.md) — PR-open as Lead Time start.
- [`observability.md`](./observability.md) — feeds the incident /
  recovery timestamps.
- [`evals.md`](./evals.md) — Eval pass rate is the AI-specific
  reliability lens.
