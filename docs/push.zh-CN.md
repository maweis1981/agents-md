# Push 规范

> 什么时候该 push，什么时候不该 push，以及 push 时必须满足的前提。
> English: [`push.md`](./push.md)

## 规则

**Push 是一个跨系统事件**：触发 CI、触发 deploy、触发通知。
Agent 的本地思考过程不需要被远端看到。
只有分支处于"值得被看到"的状态时才 push。

## 必要条件

只有以下条件**至少满足一个**时，push 才是可以接受的：

- 功能完整。
- 测试通过。
- 页面 / 接口能正常渲染。
- Migration 已经本地验证。
- 分支已经 deployment-ready。

一条都不满足，就是 push 早了。

## 禁止的模式

- 每次 commit 都 push。
- 用 push 触发 CI 来"试试看"，本地能跑就别 push，必要时用 `act`。
- 焦虑驱动的 push。

## 高频修改留在本地

Agent 探索阶段的默认动作是：

- 改文件
- 本地跑测试 / type check
- 必要时再生成

远端不需要看到这个过程。如果你的 Agent 基础设施有 auto-push，**关掉它**。

## Force push

在 `ai/` feature 分支上，整理 Agent 历史时用 `git push --force` /
`--force-with-lease` 是 OK 的。
**永远不要**对 `main` force push。
**永远不要**在别人正在 review 的分支上 force push 而不打招呼。

## Push 与 CI

CI 章节（[`ci-cd.zh-CN.md`](./ci-cd.zh-CN.md)）对此有严格要求：

- Push 到 `ai/` 分支**不**应触发生产部署。
- Push 到 `ai/` 分支*可以*触发 preview / staging 部署，
  但高频编辑必须 debounce。

如果你陷入 `push → CI 挂 → 再 push` 的紧循环，停下，先在本地修。

## Push 前 checklist

- [ ] 分支名是 `ai/<feature>`。
- [ ] commit history 干净（必要时已 squash）。
- [ ] commit message 符合规范。
- [ ] diff 里没有 secret / `.env` / 凭据。
- [ ] 本地测试 / type check 通过。
- [ ] 如有 migration，已验证。
- [ ] 不是为了"看 CI 过不过"才 push。
