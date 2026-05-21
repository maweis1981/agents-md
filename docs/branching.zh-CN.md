# 分支规范

> AI Agent 在驱动 Git 时，分支的创建、命名与生命周期规则。
> English: [`branching.md`](./branching.md)

## 硬性规则

1. **Agent 永远不直接操作 `main`。** 不 `git checkout main`，
   不 `git push origin main`。
2. **每个 AI 驱动的变更都在 `ai/<feature-name>` 分支上。**
3. **一个 feature 一个分支。** 不打包无关变更。
4. **AI 分支生命周期要短。** 一致后立即合并、合并后立即删除。

## 命名

```
ai/<feature-name>
```

`<feature-name>` 用 kebab-case，描述清楚、范围窄：

```
ai/auth-system
ai/memory-agent
ai/landing-redesign
ai/chat-workflow
ai/vector-search
ai/fix-websocket-reconnect
```

如果名字里要写「和」「以及」「加上」，这个分支多半在做两件事，拆开。

### 可选的二级前缀

如果需要更细分类：

```
ai/feat/<feature>
ai/fix/<issue>
ai/refactor/<area>
ai/docs/<topic>
```

不是必须的，最低要求是 `ai/<something>`。

## 生命周期

- **目标**：几小时到几天。
- **上限**：一周。超过一周说明 scope 拆错了。
- **过期清理**：14 天没活动的分支应当自动归档或删除，可在 GitHub
  分支清理设置里配置。

## 人类用什么前缀

团队里的人类成员可以用任何分支前缀（`feature/...` / `fix/...` /
`username/...`）。`ai/` 前缀本质是一个**信号**：这个分支主要由 AI Agent
驱动，受本规范约束。

这个信号有用：

- 用来过滤 branch protection 规则。
- 用来过滤 CI 成本报表。
- 让 reviewer 知道这是 "人写代码" 还是 "AI 生成代码"，按对应方式审查。

## 清理

squash merge 之后：

```bash
git branch -d ai/<feature>             # 本地
git push origin --delete ai/<feature>  # 远端
```

大多数项目可以直接在 GitHub 开启 "Automatically delete head branches"，
让它自己删。

## 常见错误

- **跨多个无关 feature 复用同一个分支**。一个分支合并一次之后就别再用了，
  开新分支。
- **让 Agent 起名字**。Agent 起的名字常常过长或不稳定，
  名字应当由人/规范决定。
- **`ai/` 分支被人类大改**。如果一个 `ai/` 分支被人类接管并大幅改写，
  `ai/` 前缀就是误导。要么改名，要么在 PR 描述里说清楚。
