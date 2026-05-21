# Agent Push 前 Checklist

> Agent（或它的人类 reviewer）在 `git push` 之前应该过一遍的单页清单。
> English: [`checklist.md`](./checklist.md)

如果你希望 Agent 自查，把这一页拷到自己的 `CLAUDE.md` / `AGENTS.md` 里。

## 分支

- [ ] 分支名是 `ai/<feature>`（或 `ai/<type>/<feature>`）。
- [ ] 不是 `main` / `master` / 长生命周期共享分支。
- [ ] 只做一个 feature，不是好几个。

## Commit

- [ ] 没有 "wip" / "tmp" / "fix" / "asdf" 等单词级垃圾 message。
- [ ] Conventional Commits 格式（`type: summary`）。
- [ ] 多 commit 时每一个都自身一致。
- [ ] 没有引入 secret / `.env` / 凭据 / 大二进制文件的 commit。

## 代码变更

- [ ] 写新组件 / util / schema 之前先搜过已有的。
- [ ] 没有平行副本文件（`foo-v2.ts` / `ButtonNew.tsx` 等）。
- [ ] 本地 type-check 通过。
- [ ] 本地测试通过（如有跳过，显式说明跳了哪些、为什么）。

## Migration（若有）

- [ ] Migration 走 **direct** DB URL，不是 pooled。
- [ ] Migration 已在 Neon branch / staging DB 上验证。
- [ ] Migration 可逆，或回滚路径已记录。
- [ ] 依赖新 schema 的应用 deploy 等 migration 完成后才放行。

## CI / 部署姿态

- [ ] 没有新增 "每次 push 都跑完整部署" 的 workflow。
- [ ] 没有遗留的常驻 Agent / polling 循环。
- [ ] 没有尝试从本分支直接上生产。
- [ ] Preview / staging 部署有 debounce（concurrency group / path
      filter / 等价机制）。

## PR 就绪

- [ ] 默认开成 **draft**，除非确实 ready。
- [ ] PR 描述遵循模板（What / Why / Testing / Rollback）。
- [ ] 不可回滚时已在描述里显式说明。

## 收尾

- [ ] 会用 squash 合到 `main`。
- [ ] 合并后分支自动删除。
- [ ] 本地 Agent 没有遗留的 DB 连接。

---

任意一项没勾还要 push，**停下来在 commit message 或 PR 描述里说明原因**。
Checklist 的目的不是拖慢你，而是把例外变成显式可见的。
