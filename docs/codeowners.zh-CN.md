# CODEOWNERS 与 Review 路由

> AI 生成的 diff 和人写的 diff 需要不同 review 严格度，把它们路由开。
> English: [`codeowners.md`](./codeowners.md)

Reviewer 看 diff 时默认假设是其中之一：

- "人写的。每一行都有它的道理。"
- "Agent 写的。每一行的道理是 prompt 要求的。"

第二种假设需要更严格审查。**CODEOWNERS 是确保正确的 reviewer 被钉住
的机制**。

## 硬性规则

1. **仓库根有 `CODEOWNERS` 文件。**
2. **高爆炸半径路径必须人工 review。** Migration / Auth / IAM / 计费 /
   支付 / Prompt。
3. **AI 生成的高爆炸路径 diff 需要*额外*一名 reviewer**，不仅是默认 owner。
4. **CODEOWNERS 自身受 `main` 同样的 branch protection。**
   删 owner 也要走 PR。

## 高爆炸半径路径（必须覆盖的集合）

```
# CODEOWNERS

# Schema / migration —— 必须 senior + DBA
/prisma/                      @team-platform @dba-on-call
/drizzle/                     @team-platform @dba-on-call
/migrations/                  @team-platform @dba-on-call

# Auth & IAM
/lib/auth/                    @team-security
/middleware/auth/             @team-security
/.github/workflows/           @team-platform

# 支付 / 计费
/lib/billing/                 @team-finance @team-platform
/app/api/billing/             @team-finance @team-platform

# Prompt —— 和 eval owner 配对 review
/prompts/                     @team-llm @team-product
/evals/                       @team-llm @team-product

# Secret / 配置
/.env.example                 @team-security
/scripts/deploy/              @team-platform

# 本仓的规范
/STANDARDS.md                 @maintainers
/docs/                        @maintainers
```

## 怎么标记"AI 写的 PR"

三种可行信号，按你的工具栈选一种：

1. **分支前缀**：`ai/...` 已经表达"Agent 驱动"。Branch protection
   可对 `ai/**` 要求额外 review。
2. **PR label**：Agent 开 PR 时打 `ai-authored` label（由 Agent
   runner 设置）。workflow 可以按 label 强制额外 reviewer。
3. **Commit trailer**：`Co-Authored-By: Claude <…>`，从 commit message
   能读到。比 label 不可靠。

**选一种，全员一致**。

## `ai/**` 的 Required-reviewers Ruleset

GitHub Rulesets 里 scope 到 `ai/**`：

- 必须 PR 才能 merge。
- 必需 approval ≥ 2（如果碰了任何高爆炸半径路径的 owner）。
- 必须 Code Owners review。
- 阻止 PR 作者 resolve 自己的 review。

把"必须人工 review"从社会规则变成分支命名空间的结构属性。

## 失败模式

- **CODEOWNERS 过期**：被引用的团队解散，没人 review。
  缓解：每月扫一次 CODEOWNERS 引用的团队是否还在 GitHub 上。
- **单一 owner 成瓶颈**：高爆炸路径至少列两个 owner（`@a @b`）。
- **Agent 自己也是 owner**：如果 Agent 的"用户"在 CODEOWNERS 团队里，
  排除自动 approve。**Agent 不能 self-approve。**

## CODEOWNERS 模板

`templates/CODEOWNERS` 提供了一份可拷贝模板：
[`../templates/CODEOWNERS`](../templates/CODEOWNERS)。
按项目改 team 和 path。

## 参考

- [GitHub CODEOWNERS 文档](https://docs.github.com/en/repositories/managing-your-repositories-settings-and-features/customizing-your-repository/about-code-owners)
- [`github-settings.zh-CN.md`](./github-settings.zh-CN.md) —— 更大的
  branch protection 设置面。
- [`pull-request.zh-CN.md`](./pull-request.zh-CN.md) —— 一个合格 PR
  长什么样。
