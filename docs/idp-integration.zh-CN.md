# IDP 接入

> `agents-md` 如何接进 Internal Developer Platform —— Backstage、
> Harness IDP、Port、Cortex。
> English: [`idp-integration.md`](./idp-integration.md)

`agents-md` 是方法论，不是工具。在一个有平台工程的组织里，方法论自然的
归宿是 **Internal Developer Platform (IDP)** —— Backstage 是最常见的底座，
Harness IDP / Port / Cortex 在它之上。

本章讲怎么把规范、文档、lint 脚本无改动地嵌进 IDP。

## 能得到什么

- **可发现性**：开发者（人或 Agent）从同一个 portal 找规则。
- **政策化执行**：lint 接进 IDP 的 CI governance，违反就 fail PR。
- **Scorecard**：每个仓的"是否遵循 agents-md"打分。
- **Template**：脚手架直接生成已对齐规范的新服务。

## Backstage TechDocs（以及基于 Backstage 的 Harness IDP）

TechDocs 直接渲染 `docs/` 下的 Markdown。本仓的 `docs/` 已经
Backstage 兼容。要发布：

1. 在仓库根加 `mkdocs.yml`，指向 `docs/`。
2. 加 `catalog-info.yaml`，把仓库描述为
   `kind: Component` 的 `documentation`。
3. 用 `techdocs-ref: dir:.` 让 Backstage 直接从仓库构建。

`catalog-info.yaml` 示例：

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

中文版本在同一棵树下渲染 —— Backstage 不在乎。

## Backstage Scaffolder 模板

团队可以发一份"按 agents-md 起新服务"的脚手架：

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
        url: https://raw.githubusercontent.com/maweis1981/agents-md/v0.2.0/templates/
        targetPath: .
```

一键产出已配好 `CLAUDE.md` / `AGENTS.md` / preview workflow /
commitlint 配置 / PR 模板的新仓，且 pin 在特定规范版本上。

## Scorecard（Cortex / Port / Backstage SoundCheck）

定义一个 "AI-Native Readiness" scorecard：

| 检查项 | 信号来源 |
| --- | --- |
| 仓库根有 `CLAUDE.md` | Git API |
| 仓库根有 `AGENTS.md` | Git API |
| `main` 有 branch protection | GitHub API |
| 仅 squash merge | GitHub API |
| CI 跑 commitlint | 解析 `.github/workflows/*.yml` |
| 没有 `on: push: branches: ['**']` | YAML 解析 |
| env schema 里同时有 `DATABASE_URL` 和 `DIRECT_URL` | env schema 解析 |

每个仓得 0–100 分 + 缺口列表。

## Harness IDP / Harness CI 翻译

如果用 Harness 而不是 GitHub Actions，规范规则 1:1 翻译：

| `agents-md` 规则 | Harness 对应 |
| --- | --- |
| 仅 `on: pull_request` | Pipeline Trigger filter 设 PR 事件 |
| Concurrency group + cancel-in-progress | Stage parallelism + Queue policy |
| `main` branch protection | Pipeline Governance + Approval stage |
| `production` env 必需 reviewer | Approval Stage with stakeholder users |
| OIDC 短期凭据 | Harness Connector + OIDC source |
| 成本 / token 预算闸 | 对 Pipeline 执行加 Custom Policy (OPA) |

`scripts/lint-*.sh` 可原样作为 Harness CI step。

## Harness Policy-as-Code（OPA）

Lint 规则可改写成 Rego policy 挂到 Harness Governance：

```rego
package commits

deny[msg] {
  some i
  input.commits[i].subject == "wip"
  msg := sprintf("Commit %s has banned subject 'wip'", [input.commits[i].sha])
}
```

比跑 bash 重，但 Rego policy 会自动应用到 Harness project 下所有仓库。

## Port：软件目录模型

Port 把 `agents-md` 建模成 *blueprint*：

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

"本仓 agents-md 合规"是自维护的：Port 定时重读信号，仓库 drift 时自动反映。

## 哪些**不**该放进 IDP

- Lint 脚本本身**不是** IDP-only 的，它们应当先在仓库自己的 CI 里跑。
  IDP 只是**观察**结果。
- Eval 数据集（`evals/`）留在应用仓，不进 catalog。它太业务特定了。

## 参考

- [Backstage 文档](https://backstage.io/docs/)
- [Harness IDP](https://developer.harness.io/docs/internal-developer-portal)
- [Port 文档](https://docs.getport.io/)
- [Cortex 文档](https://docs.cortex.io/)
- [`github-settings.zh-CN.md`](./github-settings.zh-CN.md) —— 仓库级
  的强制原语。
