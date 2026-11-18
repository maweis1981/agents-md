# AGENTS.md

> Entry point for OpenAI Codex / Cursor / Devin / Windsurf and any
> other AI agent that auto-reads `AGENTS.md` at repo root.
>
> This project follows the [agents-md](https://github.com/maweis1981/agents-md)
> AI-native development standard (`v0.1.x`).

## TL;DR — non-negotiable rules

1. **No direct pushes to `main`.** Use `ai/<feature>` branches.
2. **Don't commit on every change.** Group local edits into one
   stable commit per logical feature.
3. **One PR = one feature.** Draft until ready. Squash merge only.
4. **CI is PR-triggered, not push-triggered.** Production deploy is
   from `main` only.
5. **DB migrations** run on a **direct** connection; runtime uses
   **pooled**. Aggregate schema changes; don't migrate per prompt.
6. **Search before generating.** Reuse existing code; don't create
   parallel duplicates.
7. **Cap retries at 3.** Then surface the failure. No infinite loops.
8. **No polling.** Use events / webhooks / queues.
9. **Track material work in Issues.** Start only Ready work, keep
   Project status truthful, and link the implementation PR.

## Issue and Project tracking

- Find or create the canonical Issue in the repository that owns the
  primary deliverable before material implementation.
- Use one parent Issue and linked repository-specific sub-issues for
  cross-repository outcomes; do not create unlinked duplicates.
- Confirm Definition of Ready, assign ownership, and record dependencies
  and blockers before starting.
- Link the Pull Request and mark Done only after Definition of Done is met.
- Do not change Priority, Iteration, Target date, scope, or acceptance
  criteria when that creates a new commitment without human authority.

## Team playbook (agent edition)

Seven practices from Atlassian's Team Playbook, cut down to what changes
an agent's output. Everything lives in files the agent already reads:
`POSTER.md`, Issues, PRs and this file.

**Dropped on purpose**, because agents do not need them: standups and
status meetings (status is the Issue and PR state), story points and
velocity (size is "fits one PR"), sprint ceremonies, workshop timeboxes,
sign-off documents beyond `POSTER.md`, and retrospectives as meetings.

### 1. Roles: who decides (DACI)

| Role | Who | Does |
| --- | --- | --- |
| **Driver** | the agent doing the task | plans, builds, checks, reports |
| **Approver** | one named human (edit me: `<owner>`) | the only yes for the stop list below |
| **Contributors** | reviewer agents, CI, data sources | checks and evidence, no veto |
| **Informed** | the team | reads the Issue, PR and weekly report |

The Driver decides alone, and says what it did: branches, draft PRs,
work inside the agreed scope, fixes from review, reverting its own
change.

The Driver **stops and asks the Approver once, with a recommendation**,
before anything that costs money, cannot be undone, or speaks for the
product in public:

- buying or renewing anything (domains, plans, seats, ads) or spend
  above budget; never turn on auto-renew by default;
- deploys outside merge-to-`main`, and infrastructure changes that
  `plan` / `diff` cannot preview;
- launching: removing `noindex`, store submissions, announcements,
  messages to users;
- deleting a repository, database, cloud resource, or a public page
  with traffic (redirect it instead);
- changing the poster's goal, metrics or non-goals.

Standing approvals (edit me): `<e.g. the Driver merges its own PR when
Definition of Done holds>`.

### 2. Project poster: work backwards

`POSTER.md` at the repository root
([template](https://github.com/maweis1981/agents-md/blob/main/templates/POSTER.md))
holds the result written first: headline, problem, success metrics,
non-goals, pre-mortem. If it is missing or has `TODO`, draft it from the
repository and its data and get the Approver's sign-off before feature
work. Every Epic names the poster metric it moves.

### 3. Work breakdown: Epic, Story, Subtask

| Level | Is | Lives in | Size |
| --- | --- | --- | --- |
| **Epic** | an outcome that moves a poster metric | parent Issue | days to weeks |
| **Story** | one user-visible change, shippable alone | sub-issue, one PR | one agent run |
| **Subtask** | a step inside the story | checklist in the PR | minutes |

Agents write the breakdown themselves from the poster; the Approver
approves Epics, not Stories. Independent Stories run in parallel (one
worktree each, see [agent teams](https://github.com/maweis1981/agents-md/blob/main/docs/agent-teams.md)).

### 4. INVEST: the gate before a Story starts

A Story is Ready when it is:

- **Independent**: merges without waiting on another open Story;
- **Negotiable**: states the outcome, not the implementation;
- **Valuable**: names the poster metric or user it serves;
- **Estimable**: the agent can list its subtasks now; if not, open a
  research Story first;
- **Small**: one PR a reviewer reads in one sitting;
- **Testable**: its Definition of Done line below is checkable by a
  command or a URL.

Split a Story that fails one; never start it as is.

### 5. Definition of Done (per task type)

A task is Done when every line for its type holds and the PR says how
each was checked. These add to
[STANDARDS.md §19.3](https://github.com/maweis1981/agents-md/blob/main/STANDARDS.md#193-ready-done-and-iterations).

| Task | Done when |
| --- | --- |
| Feature | acceptance criteria met; tests cover the new behaviour; preview checked; docs updated |
| Bug fix | a test that failed before the fix passes after it; root cause named in the PR |
| Content / SEO page | facts checked against sources; title, description, canonical set; linked from an existing page; after deploy: 200, no `noindex`, in the sitemap |
| UI change | checked at phone and desktop width; Lighthouse mobile Accessibility and SEO 90 or more |
| Analytics event | in the tracking plan first; seen in the analytics realtime view |
| Migration | run on a non-production database first; rollback written down; direct connection |
| Infrastructure | `plan` / `diff` reviewed, no surprise deletes; after apply the next `plan` is empty |

### 6. Pre-mortem: before an Epic or an irreversible step

Write five lines in the Issue, not a meeting: "It is three months later
and this failed. The most likely reasons are…" List the top three, and
for each the cheapest early check or the guard you add now. Revisit
them when the Epic closes.

### 7. Retrospective: lessons become rules

After each Epic closes and after each weekly report, the Driver writes
at most three lines under **Lessons** below: what to keep, stop or
start, each phrased as a rule an agent can follow, with the evidence
(PR, Issue or report link). A lesson seen twice moves up into the rules
above or into a lint, test or hook
([rule-baking flywheel](https://github.com/maweis1981/agents-md/blob/main/docs/agent-behavior.md#6-rule-baking-flywheel)).
Delete lessons that no longer hold.

### Communication

- Lead with the result or the decision needed; evidence as links.
- Ask once, with a recommendation and the options; keep working on the
  recommended option unless the step is on the stop list.
- Report state changes, not activity. No "still working on it" updates.
- Silence is never approval.

## Project specifics (edit me)

- **Stack**: <e.g. Next.js + Prisma + Neon, deployed on Vercel>.
- **Branches**: `ai/<feature-name>`, kebab-case, short-lived.
- **Commits**: Conventional Commits — `feat`, `fix`, `refactor`,
  `docs`, `chore`, `test`, `perf`, `build`, `ci`, `style`, `revert`.
- **Tests**: `<your test command>`.
- **Lint**: `<your lint command>`.
- **Migrations**: `<your migration command>`; uses `DIRECT_URL`.

## What you must not do

- `git checkout main` followed by edits.
- `git push origin main`.
- Force-push to `main` or to a review branch in progress.
- Commit with messages like `wip`, `tmp`, `fix`, `update`, `asdf`.
- Add a workflow that runs full deploy on every `push`.
- Run migrations against the pooled DB URL.
- Open a PR that bundles unrelated changes.
- Open a polling loop (`while (true) { await sleep(...) }`).

## Pre-push checklist

- [ ] Branch is `ai/<feature>`.
- [ ] Commit message follows the format.
- [ ] No secrets / `.env` / credentials in the diff.
- [ ] Local tests / type-check pass.
- [ ] No infinite loops or pollers left running.
- [ ] Migration (if any) verified, reversible / rollback documented.
- [ ] Not pushing just to "see if CI passes".

## Lessons (newest first, at most 20)

<!-- Written by agents after each Epic and weekly report. Format:
- YYYY-MM-DD: <rule>. Evidence: <link>. -->

## Reference

Full spec: <https://github.com/maweis1981/agents-md/blob/main/STANDARDS.md>.
中文: <https://github.com/maweis1981/agents-md/blob/main/STANDARDS.zh-CN.md>.
Workflow: <https://github.com/maweis1981/agents-md/blob/main/docs/github-issues-projects.md>.
