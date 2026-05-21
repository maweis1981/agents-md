# Commit 规范

> AI 驱动开发下，commit 的频率、粒度与 message 格式。
> English: [`commits.md`](./commits.md)

## Commit 是什么

Commit 是系统的一个**稳定快照**。
任何人拉到这个 SHA，应该看到一个连贯、合理的状态。

它**不是** Agent 思考过程的一帧；**不是**未完成尝试的检查点。

## 频率

- 禁止：每次文件修改 commit。
- 禁止：每次 prompt 调整 commit。
- 推荐：**一个稳定、一致的 feature 一次 commit**。

如果一个 feature 真的需要两次 commit（比如 "schema migration" +
"使用新 schema 的代码"），保证每一次 commit 都自身一致：每一次都是
"回滚到这里也能跑" 的状态。

## 粒度

### 好

- `feat: complete onboarding workflow`
- `feat: implement ai memory system`
- `feat: implement vector search pipeline`
- `refactor: simplify auth middleware`

### 不好

- `fix typo`
- `fix padding`
- `update prompt`
- `change color`
- `fix import`

如果最近五次 commit 合成一次后**反而更好懂**，那它们本来就太小。

## Message 格式

Conventional Commits，英文，简洁：

```
type: short imperative summary
```

`type` ∈ {`feat`, `fix`, `refactor`, `docs`, `chore`, `test`, `perf`,
`build`, `ci`}。

可选 scope：

```
type(scope): summary
docs(zh-CN): align database section
fix(auth): handle expired refresh token
```

可选正文（~72 列折行），解释 *为什么*：

```
feat: implement vector search pipeline

We index embeddings in pgvector with HNSW and query through
Prisma. Queries that previously took ~500ms now run in ~30ms.
```

### 黑名单

以下 message 一律不接受：

```
update
fix
changes
wip
tmp
asdf
.
test
new
```

它们大部分意味着「commit 得太早」。

## Co-author 与署名

AI 共同作者的 commit 可以记录（本规范不强制）：

```
feat: complete onboarding workflow

Co-Authored-By: Claude <noreply@anthropic.com>
```

也有项目选择不在公开历史里署名 AI。两种都合理，**选一个并保持一致**。
本仓不强制偏好。

## 实操建议

- 把 Agent 的 commit 工具设为**仅手动**：不在保存时自动 commit，
  不在工具成功后自动 commit。
- 真的要 commit 时，自己 `git status` + `git diff --staged` 看一眼。
  如果一句话讲不清 diff，diff 太大。
- 中间态用 `git stash` 或本地分支，远端不需要它们。
