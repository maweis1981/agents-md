# CI / CD 规范

> 成本控制最关键的一章。CI 规则写错，AI Agent 的生产力会变成你的云账单。
> English: [`ci-cd.md`](./ci-cd.md)

## 为什么难

人类一天 push 几次，CI 成本线性增长，能扛。
AI Agent 放任不管能一天 push 几百次。**相同的 CI 配置，100 倍的账单、
100 倍的 deploy storm、100 倍打挂生产的概率。**

## 硬性规则

1. **生产部署禁止 `on: push` 触发。**
2. **昂贵 workflow 用 `on: pull_request` 或 `on: workflow_dispatch`。**
3. **AI 分支不允许自动部署到生产。** 只有 `main` 可以。
4. **高频编辑必须 debounce** —— 合并触发 / 延迟触发 / 批量触发。

## 推荐触发器

```yaml
# Preview 部署：仅 PR
on:
  pull_request:
    types: [opened, synchronize, reopened]

# 生产部署：仅 merge 到 main
on:
  push:
    branches: [main]

# 高成本临时任务：仅手动
on:
  workflow_dispatch:
```

## 禁止触发器

```yaml
# 别这么写
on:
  push:                # 任何分支、每次 push
on:
  push:
    branches: ['**']
```

如果一定要在 AI 分支每次 push 跑点东西，只跑最便宜的（lint、type-check）。
**永远不要**跑全量 build + deploy。

## Debounce 策略

Agent 10 分钟内 push 20 次，你不需要 20 次完整部署。可选：

### Concurrency groups

```yaml
concurrency:
  group: preview-${{ github.ref }}
  cancel-in-progress: true
```

新 push 一来就取消当前 build，只让最新状态完成构建。

### 时间型 debounce

push 触发但前 N 秒不做事的小 workflow，让密集的 push 合并成一次。

### Path filters

只改文档时不要重新构建整个应用：

```yaml
on:
  pull_request:
    paths-ignore:
      - 'docs/**'
      - '**/*.md'
```

## 生产部署

- 仅 `main` 的 `push`。
- 必须等对应 PR 的 status check 通过。
- 必须是生产的**唯一**入口。

通过 `main` 的 branch protection 来强制 ——
见 [`github-settings.zh-CN.md`](./github-settings.zh-CN.md)。

## Preview / Staging 部署

- 从 PR 分支跑。
- **不**碰生产数据。用单独的 DB branch（Neon branch 等）或 staging DB。
- 拉起/销毁都要便宜。
- PR 关闭时自动销毁。

## CI 中的 Secret

- 对 fork 的 PR，secret 不可见。如果 Agent 跑在 fork 上（有些平台是这样），
  预期会失败，写优雅降级。
- 永远不要在日志里打印完整 env，mask secret。

## 一个 PR-only workflow 示例

最小模板见
[`../templates/.github/workflows/preview.yml`](../templates/.github/workflows/preview.yml)。
