# GitHub Issues and Projects Workflow — Design

## Purpose

Add a public, platform-neutral standard for AI agents and human teams that use
GitHub Issues and Projects as their development system of record. The standard
must work for one repository or many repositories and must not depend on any
specific organization, product, platform, or team.

## Audience and scope

The rules apply to AI coding agents, maintainers, and mixed human-agent teams.
They cover issue ownership, cross-repository work, backlog and Kanban flow,
iterations, structured metadata, pull-request linkage, automation, and the
permission boundary between agents and humans.

The standard distinguishes:

- **MUST / MUST NOT** rules required for traceability and safe agent behavior.
- **SHOULD / MAY** recommendations that teams can adapt to their size and
  delivery model.

## Canonical model

Issues are the canonical work records. Projects are views and planning metadata
over those issues. Pull requests are implementation evidence. Information must
have one authoritative location and must not be duplicated across labels,
fields, issue bodies, and separate boards.

The recommended baseline flow is:

```text
Backlog -> Ready -> In Progress -> In Review -> Done
```

Teams may rename states but must preserve equivalent semantics and explicit
entry and exit criteria.

Recommended structured fields are Status, Priority, Size or Estimate,
Iteration, Area, and Target date when a real deadline exists.

## Agent rules

An agent must find or create an issue before material code work, place the
issue in the repository that owns the primary code change, and use a parent
issue with repository-specific sub-issues for cross-repository work. It must
not create unlinked duplicate issues.

An agent may start only Ready work, must set ownership and move active work to
In Progress, must link its pull request to the issue, and must not mark work
Done until acceptance criteria and required merges are complete. It must use
explicit issue dependencies for blocking relationships.

Agents must not make new product commitments by changing Priority, Iteration,
Target date, scope, or acceptance criteria without authority. If those values
are missing or contradictory, the agent must surface the decision to a human.

## Documentation structure

The feature will be integrated in four layers:

1. A complete bilingual chapter in `STANDARDS.md` and
   `STANDARDS.zh-CN.md`.
2. Standalone bilingual chapter files under `docs/`.
3. Concise mandatory entry rules in root and distributable agent entry files.
4. Discoverability updates in bilingual READMEs and the changelog.

The English and Chinese documents must remain semantically equivalent and pass
the repository's bilingual and internal-link checks.

## Operational guidance

The chapter will define:

- Definition of Ready and Definition of Done.
- The distinct meaning of Status, Priority, Size/Estimate, Iteration, Area,
  labels, milestones, and dates.
- Cross-repository parent and sub-issue patterns.
- WIP limits and review-age guidance.
- Backlog refinement, iteration planning, daily flow, and retrospectives.
- Recommended built-in automations without prescribing exact field names.
- Agent checklists for starting, updating, blocking, reviewing, and completing
  work.

Examples must use neutral names such as `service-api`, `web-client`,
`ios-client`, and `android-client`.

## Validation

Run the repository's bilingual symmetry and internal-link checks. Review all
mandatory language for conflicts with existing branch, commit, pull-request,
and agent-behavior rules. Confirm that no example contains organization- or
product-specific identifiers.
