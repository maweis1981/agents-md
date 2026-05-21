# AI Agent Git / GitHub 开发规范（AI-Native Workflow）

> 版本 `0.1.0` —— 创始版本
>
> 一份关于 AI Agent 在 Git、GitHub、CI/CD、数据库和 Serverless
> 基础设施上行为方式的规范，针对 "vibe coding" 高速开发场景。
>
> English version: [`STANDARDS.md`](./STANDARDS.md)

---

## 文档目标

本规范用于约束 AI Agent（Cursor / Claude Code / OpenAI Agent / Devin /
Windsurf 等）在高速开发环境中的代码提交、分支管理、CI/CD、数据库迁移与
部署行为。

目标：

- 防止 GitHub 提交限流
- 防止 CI/CD storm
- 保持 commit history 可读
- 降低 deploy 成本
- 保持生产环境稳定
- 提高 AI coding 协作效率

---

## 一、核心原则

### 1. AI 不允许频繁提交

禁止：

- 每次文件修改立即 commit
- 每次 prompt 调整立即 push
- 每次代码生成立即 deploy

原因：GitHub API 限流、Actions 爆炸、deploy storm、commit 污染、review 不可读。

### 2. Commit 是"阶段快照"

不是：人类思考过程
而是：某个稳定阶段的状态快照

### 3. AI 可以频繁修改

但：**不能频繁提交**。

允许：

- 高频本地修改
- 多轮 agent 修复
- 连续自动重构

但必须：**延迟 commit**。

---

## 二、标准工作流

```
创建 feature branch
    ↓
AI 本地连续修改
    ↓
功能完整后统一 commit
    ↓
Push 到 feature branch
    ↓
创建 PR
    ↓
Squash Merge
    ↓
进入 main
```

---

## 三、分支规范（强制）

### 1. AI 不允许直接操作 main

禁止：

```bash
git checkout main
git push origin main
```

### 2. AI 必须使用 feature branch

命名规范：

```
ai/<feature-name>
```

示例：

```
ai/auth-system
ai/memory-agent
ai/landing-redesign
ai/chat-workflow
ai/vector-search
```

### 3. 每个 feature 独立 branch

禁止：多个 unrelated feature 在同一 branch。

### 4. 长生命周期 branch 禁止

AI branch 必须**短生命周期**，功能完成立即合并。

---

## 四、Commit 规范

### 1. AI 不允许自动 commit

必须关闭：Auto Commit / Auto Sync / Auto Push。

### 2. Commit 频率

禁止：每次改动立即 commit
推荐：一个稳定功能完成后 commit

### 3. Commit 粒度

允许：

- 完整 onboarding flow
- 完整 payment system
- 完整 auth module

禁止：

- fix typo
- fix padding
- update prompt
- change color
- fix import

### 4. Commit message 格式

```
type: feature summary
```

示例：

```
feat: complete onboarding workflow
feat: implement ai memory system
fix: resolve websocket reconnect issue
refactor: simplify vector search pipeline
```

### 5. 禁止生成垃圾 commit

```
update
fix
changes
wip
tmp
asdf
```

---

## 五、Push 规范

### 1. AI 不允许频繁 push

禁止：每次 commit 后 push。

### 2. Push 必须满足以下条件至少一个

- 功能完整
- 测试通过
- 页面稳定
- migration 已验证
- deployment ready

### 3. 高频修改必须本地缓存

AI 应优先**本地修改**而不是远程 push。

---

## 六、PR 规范

### 1. 所有 AI branch 必须通过 PR 合并

禁止：直接 merge 到 main。

### 2. 强制使用 Squash Merge

GitHub 设置：

```
Allow squash merging = ON
Allow merge commit  = OFF
```

### 3. 一个 PR 一个功能

禁止：一个 PR 包含多个 unrelated feature。

### 4. PR 必须可回滚

- schema 可回滚
- env 兼容
- migration 安全

---

## 七、CI / CD 规范（极其重要）

### 1. 禁止 push-triggered full deploy

禁止：

```yaml
on:
  push:
```

### 2. 推荐

```yaml
on:
  pull_request:
# 或
on:
  workflow_dispatch:
```

### 3. AI branch 不允许自动生产部署

仅允许：preview deploy / staging deploy。

### 4. Production deploy 只能来自 main branch

### 5. 高频 AI 修改必须 debounce

CI/CD 必须：合并触发 / 延迟触发 / 批量触发。
禁止：每次 push 自动 build。

---

## 八、数据库规范（Neon / PostgreSQL）

### 1. Migration 必须使用 Direct Connection

禁止：migration 使用 pooled connection。

### 2. App Runtime 使用 pooled connection

允许：serverless runtime / edge runtime / AI chat API。

### 3. AI 不允许频繁 migration

禁止：每次 schema 修改立即 migration
推荐：聚合 schema 修改、统一 migration

### 4. Neon Branch 使用规范

Neon branch 是**数据库时间线**，不是 git branch。

### 5. Import branch 直接作为生产 branch

禁止：尝试 merge branch → main
推荐：直接切换 `DATABASE_URL`

---

## 九、AI Agent 行为约束

### 1. AI 必须优先修改已有文件

禁止：无意义生成大量新文件。

### 2. AI 必须避免

- 重复组件
- 重复 util
- 重复 schema
- 重复 prompt

### 3. AI 修改前必须

- 搜索已有实现
- 搜索已有 API
- 搜索已有 hook
- 搜索已有 component

### 4. AI 不允许无限循环修复

必须：限制 retry 次数 / 输出失败原因 / 请求人工介入。

### 5. AI 不允许持续 polling

禁止：

```js
while (true) {
  checkTask()
}
```

推荐：event-driven / webhook-driven / queue-driven。

---

## 十、Serverless / AI Infra 规范

### 1. 所有 AI Workflow 优先 event-driven

推荐：消息触发 / 队列触发 / webhook 触发。
禁止：常驻 agent。

### 2. 数据库必须支持 scale-to-zero

推荐：Neon / Turso / PlanetScale。

### 3. API 必须无状态

推荐：短连接、请求即结束。
禁止：永久 DB connection。

---

## 十一、推荐技术栈

**Git**：Feature Branch · Squash Merge · Conventional Commit
**CI/CD**：GitHub Actions · Preview Deploy · PR Triggered Build
**Database**：Neon · PostgreSQL · pgvector
**Runtime**：Vercel · Edge Functions · Serverless Functions
**ORM**：Prisma · Drizzle

---

## 十二、AI Coding 最终原则

**AI 可以高频生成代码，但系统必须低频提交状态。**

最终目标：

- 高开发速度
- 低系统震荡
- 高可维护性
- 低运维成本

---

## 十三、推荐目录结构

```
project/
├── app/
├── components/
├── lib/
├── prompts/
├── workflows/
├── agents/
├── prisma/
├── scripts/
└── docs/
```

---

## 十四、推荐 GitHub 设置

### Branch Protection（main）

- Require PR
- Require review
- Require status checks
- Disable force push

### Merge Strategy

- 开启：Squash merge
- 关闭：Merge commit

---

## 十五、AI Agent 执行 Checklist（push 前）

- [ ] Feature 完整
- [ ] 无明显报错
- [ ] 无重复文件
- [ ] 无死循环 agent
- [ ] Migration 已验证
- [ ] Commit message 合规
- [ ] Branch 命名正确
- [ ] 不会触发 deploy storm
- [ ] 不会导致 DB 常驻连接
- [ ] 可以 squash merge

---

## 十六、未来演化方向

未来 AI Coding 会从：

`commit-driven`

逐渐转向：

`state-driven` · `semantic-diff-driven` · `workflow-driven`

Git 本身并不是为 AI Agent 协作设计的。未来会逐渐出现：

- semantic version control
- AST diff
- intent diff
- workflow snapshot
- AI-native IDE infra

**当前规范是 AI Coding 时代下，对传统 Git 工作流的兼容层。**

更完整的展望见 [`docs/outlook.zh-CN.md`](./docs/outlook.zh-CN.md)。
