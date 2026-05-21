# PR 规范

> 一个 PR 一个 feature、Squash merge、默认可回滚。
> English: [`pull-request.md`](./pull-request.md)

## 硬性规则

1. **所有 AI 分支必须通过 PR 合并。** 不允许直接 merge 到 `main`。
2. **必须 squash merge。** 仓库设置里关闭 merge commit、关闭 rebase merge。
3. **一个 PR 一个 feature。** 不打包无关变更。
4. **PR 必须可回滚。**

## 为什么必须 squash merge

Squash merge 把 Agent 的中间 commit（或残留的过渡 commit）合并成 `main`
上的一个 commit。这样 `main` 的历史一行对应一个上线特性，而不是四十行。

它也是 commit 纪律的"第二次机会"：哪怕分支上的 commit 没那么干净，
squash 之后历史依然清晰。

GitHub 设置：

```
Allow squash merging   = ON
Allow merge commit     = OFF
Allow rebase merging   = OFF
```

## 一个 PR 一个 feature

如果 PR 描述以「这个 PR 做了 X 还顺便做了 Y」开头，拆开。

如果机械上必须打包（例如加新字段 + 读这个字段的代码），那是 OK 的，
它们逻辑上就是一个 feature。判据是**逻辑一致性**，不是文件数。

## 默认草稿

每个 AI 驱动的 PR 默认开成 **draft**，直到：

- Agent 停止迭代。
- 测试通过。
- 作者（或 reviewer）扫过 diff。

一旦变成非草稿，就开始消耗 CI / reviewer 时间，别让它浪费在未完成的工作上。

## 可回滚

PR 可回滚意味着：

- Schema 迁移可逆（或显式写明回滚路径）。
- 环境变量向后兼容（新变量有合理默认值；不删除生产仍在读的变量）。
- 高风险变更默认 feature flag 关闭。
- diff 不强依赖另一个服务必须同时上线的变更。

任意一条不满足，PR 描述必须显式写一段
"**Not rollback-safe because…**"。

## PR 描述模板

```
## What changed
一句话：本次变更带来的能力。

## Why
关联 issue / 任务 / rationale。

## Testing
本地 / preview 测试了什么。UI 改动欢迎放截图。

## Rollback
"Safe to revert" —— 或者写明回滚步骤。
```

## Review 预期

- AI 生成的 diff 需要**更**严格的 review，不是更松。
- Reviewer 要重点检查 Agent 在搜索阶段漏掉的重复 component / util。
- 重点关注 migration、IAM、环境变量变更。

## Merge 之后

- 分支自动删除（开启 "Automatically delete head branches"）。
- 生产部署来自 `main`，不是 PR 分支。
- 本地 `git branch -d ai/<feature>` 清理。
