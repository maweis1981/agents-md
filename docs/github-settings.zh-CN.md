# GitHub 设置

> 把规范从「我们口头同意」变成「GitHub 在强制」的仓库级配置。
> English: [`github-settings.md`](./github-settings.md)

## `main` 分支保护

Settings → Branches → Add branch protection rule → `main`：

- [x] **Require a pull request before merging**
  - [x] Require approvals（≥ 1）
  - [x] Dismiss stale pull request approvals when new commits are pushed
  - [x] Require review from Code Owners *(若使用 `CODEOWNERS`)*
- [x] **Require status checks to pass before merging**
  - 把 CI 暴露的 check 加进来（lint / type-check / test / build）。
  - [x] Require branches to be up to date before merging
- [x] **Require conversation resolution before merging**
- [x] **Require signed commits**（可选但推荐）
- [x] **Require linear history**（配合 squash merge）
- [x] **Do not allow bypassing the above settings** —— 包括管理员。
- [x] **Restrict who can push to matching branches** —— 空 allow-list，
      谁都不能直接 push `main`。

## Merge 策略

Settings → General → Pull Requests：

- [ ] Allow merge commits
- [x] Allow squash merging
  - Default commit message: **Pull request title and description**
- [ ] Allow rebase merging

## 分支卫生

Settings → General → Pull Requests：

- [x] **Automatically delete head branches**

收掉短生命周期 `ai/` 分支留下的垃圾。

## Actions 权限

Settings → Actions → General：

- **Actions permissions**：只允许自己的 action 和受信任的 publisher。
- **Workflow permissions**：默认只读，按 job 授予 write。
- **Fork pull request workflows**：显式配置。fork 的 workflow 默认**不**应
  获得 secret。

## Secrets

Settings → Secrets and variables → Actions：

- 生产 secret 放到 **environment secrets**，scope 到受保护的
  `production` environment。
- `production` environment 要求人工审批才能部署 —— 这是 Agent 不会"误上线"
  的最后一道闸。

## Environments

Settings → Environments → New environment → `production`：

- [x] Required reviewers（至少一个人类）
- [x] Wait timer（可选，例如 5 分钟"中止窗口"）
- Deployment branches：**Selected branches** → 仅 `main`

可选：单独建 `staging`，不要 required reviewer，但限制只能 PR 分支部署。

## 仓库可见性与策略

- 私有仓 + AI 访问：AI Agent 的 GitHub App 权限要 **scope 到它需要的仓库**。
  本规范默认按单仓 scope。
- 公开仓：对 fork PR 的 workflow 要非常小心，**不要**把生产 secret 给它们。

## 可选：Rulesets

GitHub Rulesets 是 branch protection 的更新版替代品，可以用 pattern
（例如 `ai/**`）跨多个分支表达更细粒度的规则。在多仓规模下用，
比 branch protection 更易管理。

`ai/**` 的起步 ruleset：

- 允许已认证用户 push。
- 禁止人类 force-push；如需 PR 前整理历史，允许 Agent bot 用户 force-push。
- 要求 linear history。
- 删除分支也走 PR（防止 Agent 用 `git push origin :ai/foo` 干掉
  正在做的工作）。

## 综合效果

配好之后，Agent **不能**：

- push 到 `main`；
- 在 CI 未通过时合并 PR；
- 用 merge-commit 而不是 squash 合并；
- 绕过自己分支的 review；
- 不经过 environment 审批就上生产。

如果发现 Agent 仍能做上述任一件事，问题在**漏配置**，不在 Agent —— 改配置。
