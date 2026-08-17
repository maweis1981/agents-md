# GitHub Issues and Projects Workflow

This chapter defines a platform-neutral way for people and AI agents to manage
development with GitHub Issues and GitHub Projects. It applies to a single
repository, a product split across repositories, and a portfolio containing
several products.

The keywords **MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT**, and **MAY** are
normative. Teams may adapt names and optional fields, but must preserve the
meaning and control boundaries described here.

## 1. One system of record

- An Issue is the authoritative work record: problem, scope, acceptance
  criteria, decisions, dependencies, and completion evidence.
- A Project is a planning view over Issues. Its fields describe flow and
  planning; they do not replace the Issue.
- A Pull Request is implementation and review evidence. It MUST link to its
  Issue, but MUST NOT become the only place where scope or acceptance criteria
  are recorded.
- Information MUST have one authoritative home. Do not maintain competing
  status, priority, or iteration values in labels, Issue text, and Project
  fields.

Small, non-material maintenance such as correcting a typo MAY proceed without
an Issue when repository policy allows it. Material implementation, behavior
changes, defects, migrations, and planned documentation work MUST have an Issue
before work starts.

## 2. Repository ownership

Create the Issue in the repository that owns the primary deliverable:

- API, persistence, and service behavior belong with the service repository.
- Platform-specific UX belongs with that client repository.
- Shared contracts or libraries belong with their source repository.
- Product-wide coordination belongs in the designated planning repository, if
  the organization has one.

An agent MUST search for an existing Issue before creating one. It MUST NOT
create duplicate tracking Issues merely to make work visible on another board;
add the existing Issue to the appropriate Project instead.

## 3. Cross-repository work

Use one parent Issue for the outcome and one sub-issue per independently owned
repository deliverable:

```text
Parent feature
├── service-api: contract and persistence
├── web-client: browser experience
├── ios-client: iOS experience
└── android-client: Android experience
```

The parent records shared acceptance criteria, sequencing, and overall status.
Each sub-issue records repository-specific scope, owner, estimate, and Pull
Request. Dependencies MUST be explicit (`blocked by` / `blocking`) rather than
implied by prose. The parent MUST NOT be marked Done until every required
sub-issue is complete or explicitly removed from scope by an authorized human.

## 4. Structured fields

Prefer Project fields for values used to filter, sort, group, chart, or
automate. Recommended fields are:

| Field | Purpose | Guidance |
| --- | --- | --- |
| Status | Current flow state | Exactly one value; see the lifecycle below. |
| Priority | Relative business urgency | Keep the scale small, such as P0–P3. It is not an estimate. |
| Size / Estimate | Delivery effort or complexity | Use one shared scale. Split work that cannot be estimated meaningfully. |
| Iteration | Near-term delivery window | Assign only committed work; Backlog normally has no iteration. |
| Area | Stable product or technical ownership | Use a small, maintained vocabulary. |
| Target date | A real external or operational deadline | Do not use it as a wish date. Record the reason in the Issue. |

Use labels for taxonomy that belongs to the repository, such as `bug`,
`security`, or `dependencies`. Do not duplicate Project fields with labels.
Use milestones only when a release or externally meaningful outcome needs a
repository-level grouping.

## 5. Backlog and Kanban lifecycle

The recommended baseline is:

```text
Backlog -> Ready -> In Progress -> In Review -> Done
```

Teams MAY rename states, but each state MUST retain an explicit meaning:

| Status | Entry condition | Exit condition |
| --- | --- | --- |
| Backlog | The work is worth retaining but is not yet committed. | It meets Definition of Ready and is selected. |
| Ready | The work is actionable, prioritized, and unblocked. | An owner starts it. |
| In Progress | One accountable owner is actively implementing it. | A reviewable Pull Request is open, or work returns to Ready/Backlog with a reason. |
| In Review | Implementation is awaiting review, checks, or acceptance. | Required review, checks, and acceptance complete. |
| Done | Definition of Done is satisfied. | Reopened only when completion evidence was incorrect or the accepted scope regressed. |

Status describes what is true now; it MUST NOT be used to express priority,
team, release, or issue type. Owners MUST update status when reality changes,
not at the end of a reporting period.

## 6. Definition of Ready

An Issue MAY enter Ready only when:

- the desired outcome and user or system impact are clear;
- acceptance criteria are observable and testable;
- repository ownership and an accountable owner are known;
- dependencies and blocking decisions are identified;
- security, privacy, migration, rollout, and documentation implications have
  been considered where relevant;
- the work is small enough to complete within the team's normal delivery
  horizon, or has been split;
- Priority is set by an authorized person; and
- the Issue has no unresolved contradiction about scope or intent.

An agent MUST NOT treat an underspecified Backlog item as authorized work. It
MAY improve the Issue, propose acceptance criteria, or ask for a decision, but
MUST NOT silently invent product behavior.

## 7. Definition of Done

An Issue MAY enter Done only when:

- all acceptance criteria are satisfied;
- required code, tests, documentation, migrations, and rollout safeguards are
  complete;
- required checks and reviews have passed;
- the Pull Request is merged, or the repository's documented equivalent is
  complete;
- relevant sub-issues and dependencies are resolved;
- follow-up work is either completed or captured as linked Issues; and
- the Issue contains enough evidence for another person to verify completion.

Closing a Pull Request, publishing a build, or finishing code locally is not by
itself sufficient. If work is cancelled or superseded, close it with that
reason instead of presenting it as delivered.

## 8. Work-in-progress limits

Flow improves when starting work is harder than finishing work. Each person or
agent SHOULD normally own no more than one active implementation Issue at a
time. Teams SHOULD set an explicit WIP limit for In Progress and In Review.

When a limit is reached, contributors SHOULD review, test, unblock, or split
existing work before starting another Ready item. Blocked work remains visible
in its truthful status and MUST include the blocker, responsible party, and
next review point. A separate `Blocked` field or marker MAY be used; moving an
item to Backlog merely to hide blocked WIP is prohibited.

Teams SHOULD review aging In Review items daily and define a local response
target. The target is a service expectation, not permission to bypass required
review.

## 9. Iterations and planning cadence

Iterations are commitment windows, not containers for the entire Backlog.
Teams SHOULD use a stable cadence—one or two weeks is a common starting point—
and leave uncommitted work without an Iteration.

At iteration planning:

1. confirm capacity and current WIP;
2. select only Ready items in Priority order;
3. validate dependencies and ownership;
4. assign the Iteration; and
5. record any explicit delivery risk.

Incomplete work MUST NOT be rolled forward automatically without review.
Reconfirm its scope, priority, estimate, and owner. Backlog refinement SHOULD
remove duplicates and stale work, split oversized Issues, and prepare only a
reasonable near-term supply of Ready work. Retrospectives SHOULD use flow data
to improve the system, not to evaluate individuals.

## 10. Automation

Automation SHOULD reduce clerical work without concealing decisions. Useful
baseline automations include:

- add new or matching open Issues from approved repositories to the Project;
- set newly added items to Backlog;
- move an Issue to In Progress when linked implementation begins;
- move an Issue to In Review when a linked Pull Request becomes reviewable;
- move an Issue to Done only when the Issue is actually closed under the local
  completion policy; and
- archive old Done items from the active view without deleting their records.

Automation MUST NOT assign Priority, Iteration, Target date, acceptance
criteria, or product scope unless an authorized policy supplies that decision.
Every automated transition SHOULD be reversible and auditable. Teams MUST
periodically inspect workflow failures and repository filters, especially when
repositories are added, renamed, transferred, or archived.

## 11. Agent authority boundary

An AI agent MAY perform clerical updates that reflect observed reality: add an
Issue to the Project, set itself as owner, link a Pull Request, update Status,
record evidence, and declare or clear a verified blocker.

Without explicit authority, an agent MUST NOT:

- change Priority, Iteration, Target date, scope, or acceptance criteria in a
  way that creates a new product or delivery commitment;
- remove required work from a parent Issue;
- mark work Done before Definition of Done is met;
- close unresolved Issues to improve board metrics; or
- infer approval from silence, assignment, or an automated field value.

When fields conflict with the Issue or current repository state, the agent
MUST preserve evidence, identify the contradiction, and request a human
decision. It MAY propose a specific resolution.

## 12. Agent operating checklists

### Before starting

- Search for the canonical Issue; create one only if none exists.
- Confirm repository ownership and cross-repository structure.
- Verify Definition of Ready, dependencies, Priority, and authority.
- Assign an owner and move the Issue to In Progress only when work begins.

### During work

- Keep scope and acceptance decisions in the Issue.
- Record blockers and dependencies immediately.
- Link implementation evidence and keep Status truthful.
- Create linked follow-up Issues instead of hiding additional scope in a Pull
  Request.

### Before review

- Open or update the linked Pull Request under the repository's existing
  Pull Request standard.
- Confirm tests, checks, documentation, migration, and rollout requirements.
- Move to In Review only when the work is genuinely reviewable.

### Before completion

- Verify every acceptance criterion and the full Definition of Done.
- Confirm required sub-issues and dependencies are complete.
- Add concise completion evidence to the Issue.
- Move to Done only after the repository's merge and closure policy is met.

## 13. Recommended views and review rhythm

A single Project can support several views without duplicating Issues:

- **Backlog:** prioritized, grouped by Area, excluding Done.
- **Ready queue:** Ready only, sorted by Priority and age.
- **Delivery board:** Ready through In Review, grouped by Status.
- **Current iteration:** grouped by Status, filtered to the active Iteration.
- **Review queue:** In Review, sorted oldest first.
- **Roadmap:** only work with meaningful iterations or target dates.

Review the delivery board daily, refine the Backlog regularly, plan at the
iteration boundary, and periodically audit stale Issues, field vocabularies,
automation, and WIP limits. The Project is healthy when it makes delivery
reality easier to see—not when every cell is populated.
