# IDP Integration

> How `agents-md` plugs into Internal Developer Platforms — Backstage,
> Harness IDP, Port, Cortex.
> 中文：[`idp-integration.zh-CN.md`](./idp-integration.zh-CN.md)

`agents-md` is methodology, not a tool. The natural home for
methodology inside a platform-engineering org is the **Internal
Developer Platform (IDP)** — Backstage being the most common base,
with Harness IDP / Port / Cortex sitting on top.

This chapter explains how to slot the spec, the docs, and the lint
scripts into an IDP without rewriting any of them.

## What this gives you

- **Discoverability**: developers (human or agent) find the rules
  through the same portal they use for everything else.
- **Enforcement-as-policy**: lint scripts wired into the IDP's CI
  governance fail PRs that violate the spec.
- **Scorecards**: per-repo "is this team following agents-md?" gauges.
- **Templates**: scaffolders that produce new services already wired
  to the spec.

## Backstage TechDocs (and Harness IDP, which is Backstage-based)

TechDocs renders Markdown under `docs/` directly. The `docs/` folder
in this repo is already Backstage-compatible. To publish it:

1. Add `mkdocs.yml` at repo root pointing at `docs/`.
2. Add a `catalog-info.yaml` describing the repo as a `System` or
   `Component` of kind `documentation`.
3. Reference `techdocs-ref: dir:.` so Backstage knows to build from
   the repo itself.

`catalog-info.yaml` example:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: agents-md
  title: AI-Native Development Standards
  annotations:
    backstage.io/techdocs-ref: dir:.
  tags:
    - methodology
    - ai-native
    - vibe-coding
spec:
  type: documentation
  lifecycle: production
  owner: platform-team
```

The Chinese versions render under the same tree — Backstage doesn't
care.

## Backstage Scaffolder template

A team can publish a "new service that follows agents-md" template:

```yaml
# templates/agents-md-service/template.yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: agents-md-service
  title: Service following agents-md
spec:
  steps:
    - id: fetch
      action: fetch:template
      input:
        url: ./skeleton
    - id: agents-md
      action: fetch:plain
      input:
        url: https://raw.githubusercontent.com/maweis1981/agents-md/v0.1.0/templates/
        targetPath: .
```

This stamps a new repo with `CLAUDE.md`, `AGENTS.md`, the preview
workflow, the commitlint config, and the PR template — all pinned to
a specific spec version.

## Scorecards (Cortex / Port / Backstage SoundCheck)

Define a scorecard "AI-Native Readiness" with checks like:

| Check | Source of signal |
| --- | --- |
| `CLAUDE.md` exists at repo root | Git API |
| `AGENTS.md` exists at repo root | Git API |
| Branch protection on `main` is on | GitHub API |
| Squash-only merge configured | GitHub API |
| Commitlint runs in CI | `.github/workflows/*.yml` parse |
| No `on: push: branches: ['**']` workflow | YAML parse |
| `DATABASE_URL` and `DIRECT_URL` both set in env schema | env schema parse |

Each repo gets a 0–100 score and a gap list.

## Harness IDP / Harness CI translation

If you're on Harness rather than GitHub Actions, the spec translates
1:1:

| `agents-md` rule | Harness equivalent |
| --- | --- |
| `on: pull_request` only | Pipeline Trigger filter on PR events |
| Concurrency group + cancel-in-progress | Stage parallelism + Queue policy |
| Branch protection on `main` | Pipeline Governance + Approval stage |
| Required reviewers on `production` env | Approval Stage with stakeholder users |
| Secret rotation via OIDC | Harness Connector with OIDC source |
| Cost / token budget caps | Custom Policy (OPA) on Pipeline executions |

You can copy `scripts/lint-*.sh` verbatim into a Harness CI step.

## Harness Policy-as-Code (OPA)

The lint rules can be re-expressed as Rego policies attached to
Harness Governance:

```rego
package commits

deny[msg] {
  some i
  input.commits[i].subject == "wip"
  msg := sprintf("Commit %s has banned subject 'wip'", [input.commits[i].sha])
}
```

This is heavier than running the bash script, but a Rego policy
applies to every repo under that Harness project automatically.

## Port: software catalog model

Port lets you model `agents-md` as a *blueprint*:

```json
{
  "identifier": "agents_md_adoption",
  "title": "agents-md Adoption",
  "properties": {
    "spec_version_pinned": { "type": "string" },
    "has_claude_md": { "type": "boolean" },
    "has_agents_md": { "type": "boolean" },
    "branch_protection_on": { "type": "boolean" },
    "last_lint_run": { "type": "string", "format": "date-time" }
  }
}
```

Self-service "this repo is agents-md compliant" stays accurate even
as repos drift, because Port re-reads the signals on a schedule.

## What does NOT belong in the IDP

- The lint scripts themselves are not "IDP-only" — they should run
  in the repo's own CI first. The IDP just *observes* the result.
- Eval data (`evals/`) stays in the application repo, not in the
  catalog. It's too domain-specific.

## Reference

- [Backstage docs](https://backstage.io/docs/)
- [Harness IDP](https://developer.harness.io/docs/internal-developer-portal)
- [Port docs](https://docs.getport.io/)
- [Cortex docs](https://docs.cortex.io/)
- [`github-settings.md`](./github-settings.md) — the repo-level
  enforcement primitives.
