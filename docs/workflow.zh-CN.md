# 标准工作流

> AI-Native 开发循环的标准形态。
> English: [`workflow.md`](./workflow.md)

## 循环

```
创建 feature branch  ai/<feature-name>
        ↓
AI 本地多轮修改
        ↓
功能进入稳定状态
        ↓
一次 commit + push 到 feature branch
        ↓
开 PR（草稿 → ready for review）
        ↓
Squash merge 进 main
        ↓
Preview → staging → production
```

## 逐步说明

### 1. 创建 feature 分支

```bash
git checkout -b ai/<feature-name>
```

示例：

```
ai/auth-system
ai/memory-agent
ai/landing-redesign
```

一个 feature 一个分支，生命周期按小时/天计，而不是按周。

### 2. 让 Agent 本地迭代

大多数失败都出在这一步。几乎所有 AI 工具的默认行为都是**每次保存就 commit**，
请关掉它：

- 在 IDE / Agent 里关掉 "Auto Commit" / "Auto Sync" / "Auto Push"。
- 在 `CLAUDE.md` / `AGENTS.md` 里明确告诉 Agent：这是多轮迭代会话，
  不是一改一提交。

### 3. 稳定后再 commit 一次

功能端到端跑通之后再 commit：

```bash
git add -A
git commit -m "feat: complete <feature>"
```

这一轮如果 commit 了两次，多半本来该合成一次。如果 commit 了十次，
肯定哪里错了。

### 4. 准备好了再 push

只在分支处于"被合并也能活"的状态时才 push。
具体 checklist 见 [`push.zh-CN.md`](./push.zh-CN.md)。

### 5. 开 PR

默认 **草稿 PR**，避免 CI / reviewer 在你还没准备好时被打扰。
见 [`pull-request.zh-CN.md`](./pull-request.zh-CN.md)。

### 6. Squash merge

`main` 的 branch protection 应该强制 squash-only merge。
见 [`github-settings.zh-CN.md`](./github-settings.zh-CN.md)。

## 反模式

- "我直接 push 到 main 试一下 CI"。→ 不行。
- "我每次小修都 commit 一下，方便回滚"。→ 用 `git stash` 或本地分支，
  远端不需要看到你的中间态。
- "这个分支我开两周慢慢搞"。→ 开一个 tracking *issue*，不是长生命周期分支。

## 为什么 "一个分支 ≠ 一个 PR ≠ 一次 commit" 也可以接受

有时候一个 feature 天然需要多个 PR（比如先 schema 再代码）。这是 OK 的——
保证每个 PR 自身一致、独立可合并即可。规则不是 "永远只有一次 commit"，
而是 "不要把不能独立成立的中间态暴露到远端"。
