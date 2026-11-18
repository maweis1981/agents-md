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

## Project poster

Every product repository has a `POSTER.md` at its root, written backwards
from the result: goal, success metrics, non-goals, risks
([template](https://github.com/maweis1981/agents-md/blob/main/templates/POSTER.md)).

- Work towards it. A PR that moves no success metric says why it is
  still worth doing.
- If `POSTER.md` is missing or still has `TODO`, draft it from what the
  repository and its data show, and get the Approver's sign-off before
  building features.
- Changing a goal, metric or non-goal is the Approver's decision.

## Who decides (DACI)

| Role | Who |
| --- | --- |
| **Driver** | the agent doing the task: plans it, does it, reports it |
| **Approver** | one named human (edit me: `<owner>`); the only one who can say yes to the list below |
| **Contributors** | reviewer agents, CI, and anyone whose data or code the task uses |
| **Informed** | the team, through the Issue, the PR and the regular report |

The Driver decides alone, and says what it did: branches, draft PRs,
code and content inside the agreed scope, fixes from review, reverting
its own change. Merging its own PR once Definition of Done holds is the
Driver's call only if the Approver has given that standing approval
below.

The Driver **stops and asks the Approver once, with a recommendation**,
before anything that costs money, cannot be undone, or speaks for the
product in public:

- buying or renewing anything (domains, plans, seats, ads), or spend
  above the agreed budget; never turn on auto-renew by default;
- production deploys outside the normal merge-to-`main` path, and
  infrastructure changes that `plan` / `diff` cannot preview;
- launching: removing `noindex`, store submissions, announcements,
  emails or messages to users;
- deleting a repository, a database, a cloud resource, or a public
  page that has traffic (redirect it instead);
- changing the poster's goal, metrics or non-goals.

Standing approvals (edit me): `<e.g. the Driver may merge its own PR
when Definition of Done holds>`.

## Definition of Done (per task type)

A task is Done when every line for its type holds and the PR says how
each one was checked. These add to the general Definition of Done in
[STANDARDS.md §19.3](https://github.com/maweis1981/agents-md/blob/main/STANDARDS.md#193-ready-done-and-iterations).

| Task | Done when |
| --- | --- |
| Feature | acceptance criteria met; tests cover the new behaviour; preview deploy checked by hand; docs updated |
| Bug fix | a test that failed before the fix passes after it; root cause named in the PR |
| Content / SEO page | facts checked against sources; title, description and canonical set; linked from at least one existing page; after deploy: returns 200, no `noindex`, in the sitemap |
| UI change | checked at phone and desktop width; Lighthouse mobile Accessibility and SEO 90 or more |
| Analytics event | defined in the tracking plan first; seen arriving in the analytics tool's realtime view |
| Migration | run on a non-production database first; rollback written down; direct connection |
| Infrastructure | `plan` / `diff` reviewed with no surprise deletes; after apply, the next `plan` is empty |

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

## Reference

Full spec: <https://github.com/maweis1981/agents-md/blob/main/STANDARDS.md>.
中文: <https://github.com/maweis1981/agents-md/blob/main/STANDARDS.zh-CN.md>.
Workflow: <https://github.com/maweis1981/agents-md/blob/main/docs/github-issues-projects.md>.
