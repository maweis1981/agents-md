# Agent Teams

> The spec's first 19 sections assume one agent works on one task at
> a time. Reality has moved: real teams now run 10–50+ agents in
> parallel. This chapter says how.
> 中文：[`agent-teams.zh-CN.md`](./agent-teams.zh-CN.md)

Single-agent discipline (sections 1–19) is still correct — it just
describes a solo contributor. When you run multiple agents at once,
new failure modes appear that the single-agent rules don't address:
agents stomping on each other's working trees, two agents producing
contradictory output on overlapping tasks, an agent judging its own
work, costs spiraling because nothing stops the fleet.

This chapter codifies the orchestration pattern now emerging in the
wild (Lauren Tan / Cursor 2.0 / Grok Build / Claude Code worktrees).

## Hard rules

1. **Every multi-agent run has three distinct roles**: Chief of
   Staff, Executor(s), Judge(s). Flat "N equal agents sharing files"
   is forbidden.
2. **Each Executor runs in its own isolated workspace** —
   `git worktree` by default, container or remote VM when needed.
   No shared working directory.
3. **A Judge uses a different model family than the Executor it
   judges.** Cross-vendor preferred when evals are cheap enough.
4. **Rubrics are written before Executors start**, not after.
5. **Chief of Staff does not write code.** It only plans, assigns,
   monitors, aggregates.
6. **A hard budget cap exists on Chief of Staff** (tokens, dollars,
   wall time). Exceeded → halt the whole fleet, report.
7. **Every agent action is logged** (prompt, tools, cost, decision).
   See [`observability.md`](./observability.md) §17.4.
8. **Human review happens on the aggregated result**, not on each
   Executor's PR. The Judge is how volume scales; human review is
   the meta-gate.

## The 5-layer validation stack

Every change produced by an agent team passes through, in order:

```
1. Local sanity        lint / type-check / syntax
2. Isolated unit tests Executor runs them in its worktree
3. Integration / eval  cross-component behavior check
4. Cross-model judge   different-vendor model scores against rubric
5. Human meta-gate     one sign-off on the aggregated set
```

Any layer failing kicks the change back to the Executor. Four
rejections from Judge → Chief of Staff re-plans (possibly re-splits
the task or raises for human).

A single-agent run uses layers 1–3 and 5. A team run uses all five.

## Chief of Staff pattern

Responsibilities:

- Read the task, produce a `plan.yaml` (or equivalent) with
  subtasks, rubric, assigned Executor profile, assigned Judge model.
- Spawn one Executor + one Judge per subtask.
- Monitor status, cost, and time.
- Aggregate accepted Executor outputs into one coherent patch set.
- Re-plan on Judge rejection cascade or Executor timeout.
- Report final result (success / partial / halted) to the human.

Forbidden for Chief of Staff:

- Writing or editing code directly.
- Approving its own plan without rubric generation.
- Running Executors that share a worktree.

## Executor pattern

Responsibilities:

- Receive subtask spec + rubric from Chief of Staff.
- Work in its own isolated worktree.
- Emit a patch + self-report (what it did, where it's uncertain).
- Terminate cleanly on budget overrun; never busy-wait.

Forbidden for Executors:

- Accessing another Executor's worktree.
- Approving its own output.
- Modifying the rubric.

## Judge pattern

Responsibilities:

- Receive rubric + Executor output. **Nothing else.** Not the task
  prompt, not the plan context, not the Executor's self-report.
  Context bias is the main reason LLM-as-judge fails.
- Score against the rubric; emit pass/fail + score + rationale.
- Independent of the Executor it judges.

A two-vote quorum (two judges from different vendors) beats a single
strong judge when disagreement is cheap to resolve.

Forbidden for Judges:

- Modifying the Executor's output.
- Running on the same model family as the Executor they judge.
- Judging their own earlier output.

## Worktree lifecycle

```bash
# Chief of Staff spawns Executor e42
git worktree add .worktrees/e42 -b ai/exec-e42

# Executor works freely inside .worktrees/e42
# ... commits as needed on ai/exec-e42 ...

# Chief of Staff collects the patch
git -C .worktrees/e42 format-patch main --stdout > out/e42.patch

# If Judge accepts → apply to the aggregate branch
# If Judge rejects → either re-prompt Executor or discard

# Teardown
git worktree remove .worktrees/e42
git branch -D ai/exec-e42
```

The Executor branch (`ai/exec-e42`) is **disposable**. Promotion to
`main` happens only via the aggregated Chief-of-Staff PR, which
still follows [`pull-request.md`](./pull-request.md) rules (one
feature, squash merge, draft by default).

## When NOT to use agent teams

The orchestration overhead is non-trivial. For a single Executor to
beat running a team, you need **at least three** of:

- Task is genuinely parallelizable (independent subtasks).
- Each subtask is ≥ 10 minutes of agent work.
- Rubric is writable before work starts.
- Human can't meaningfully review each subtask individually.
- Aggregated cost per task is bounded (budget cap).

If your task is a 5-minute single-file change, run one agent. The
orchestration is bigger than the work.

## Interactions with other sections

- **[`pull-request.md`](./pull-request.md)** — Chief of Staff's
  aggregated output is still one PR, one feature, squash-merged.
  Executors do not open their own PRs to `main`.
- **[`agent-behavior.md`](./agent-behavior.md)** — Cap retries at 3
  applies per Executor; Chief of Staff enforces across the fleet.
  The rule-baking flywheel (§9.7) feeds static rules back into
  Judges.
- **[`evals.md`](./evals.md)** — Cross-model judge is specified in
  §17.3; this chapter's Judge role implements it.
- **[`observability.md`](./observability.md)** — Every agent in the
  fleet traces; Chief of Staff rolls up cost + latency.
- **[`secrets.md`](./secrets.md)** — Each worktree inherits the same
  env; never duplicate secrets per Executor.
- **[`github-issues-projects.md`](./github-issues-projects.md)** —
  Chief of Staff updates the Issue status; Executors do not directly
  touch Project fields.

## Anti-patterns

- **Flat multi-agent** — "N agents editing the same file, see who
  wins." Guaranteed data loss and silent conflicts.
- **Self-judge** — Executor and Judge same model family. Produces
  false positives on exactly the mistakes the model is bad at.
- **Rubric after the fact** — writing the rubric after seeing
  Executor output means the rubric describes success instead of
  defining it.
- **Unbounded Chief of Staff** — orchestrator without a hard budget
  cap burns through quotas in minutes.
- **Executor opens its own PR to `main`** — defeats aggregation;
  floods the review surface.
- **Judge sees the full task context** — biases toward "whatever
  the Executor produced, that's the task."

## Minimum viable implementation

If you want to try this on one task today, without adopting a full
orchestration framework:

1. In your task prompt, instruct your agent to create one `plan.md`
   with subtasks before writing code.
2. For each subtask, `git worktree add` a fresh branch.
3. Run the same agent (different session) in each worktree with
   just the subtask spec + rubric.
4. In a third session with a different model, paste only the patch
   + rubric, ask for pass/fail + rationale.
5. Apply accepted patches to one aggregation branch. Open one PR.

This is manual; the point is the shape. Tooling (Cursor 2.0
worktree mode, pstack, Claude Code `/agents`) automates the same
shape.

## Reference

- Lauren Tan's `pstack` (ex-Cursor, now SpaceX/xAI) — the
  most-cited open implementation of this pattern (MIT).
- [Cursor 2.0 parallel agents](https://cursor.com/) — worktree
  isolation shipped as a product feature.
- [`agent-behavior.md`](./agent-behavior.md) §9.7 — rule-baking
  flywheel that feeds back into Judge checks.
- [`evals.md`](./evals.md) §Cross-model judge — the Judge-side
  contract.
