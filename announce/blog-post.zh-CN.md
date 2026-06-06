# 博客长文（中文）

> 发布故事的长文版。适合**掘金 / InfoQ / 公众号 / 知乎专栏**。
> 约 1800 字。配套英文版：[`blog-post.md`](./blog-post.md)。
>
> 建议标题：**「我让 AI Agent 在生产项目跑了三个月，CI 账单是同类项目的 6 倍 —— 然后我写了这套规范」**

---

## 我让 AI Agent 在生产项目跑了三个月，CI 账单是同类项目的 6 倍 —— 然后我写了这套规范

三个月前，我让 Claude Code 和 Cursor 接管了一个真实的生产项目 ——
一个小型 B2B SaaS，Next.js 跑在 Vercel，Postgres 跑在 Neon，三个工程师
两个设计师。**第二周开始**，Agent 产出代码的速度大约是团队 review 速度
的 3 倍。本来该庆祝的数字，反倒成了问题：

- 每天 80 次 commit 直接落 `main`
- 一半 commit 标题是 `wip` / `fix` / `update` / `asdf`
- **CI 账单是同类非 AI 项目的 6 倍**
- 3 周内 4 次部分应用的 migration 事故，全是同一个模式（Prisma migration 走 pooled connection，半途中断，应用上线即崩）

这不怪 Claude 也不怪 Cursor。Agent 做的就是它们默认设置允许的事：
保存即 commit、commit 即 push、push 即触发 CI、CI 绿即部 preview。
**Git、GitHub、托管数据库的经济模型，本来是按"每个人类开发者每天几次
commit"设计的。接进来一个每天 commit 50 次的 Agent，不会让 Git 坏掉 ——
会让账单坏掉。**

于是我开始记录团队实际改过哪些东西，才把节奏调回来。

### 规则长什么样

三条原则，加上一堆细节。

**1. AI 可以高频修改，系统不能高频提交。**

最重要的一条，其它都是它的推论。**修改**（改文件、重写函数）是本地的，
便宜、可逆。**Commit / push / merge / deploy / migrate** 是跨系统的，
昂贵、可观测、不一定可逆。Agent 天然想以修改的速度提交。**纪律就是在
这个边界上显式刹车。**

实操：在每个你能控制的工具里关掉 "Auto Commit" / "Auto Sync" / "Auto Push"。
在 `CLAUDE.md` 和 `AGENTS.md` 里把这个期望写明。探索阶段用
`git stash` 和本地分支，**远端不需要看到 Agent 中间态**。

**2. Commit 是稳定快照，不是思考过程。**

一次有用的 commit 回答：**"这次变更之后，系统处于哪个稳定状态？"** ——
不是"Agent 在第 14 分钟在想什么"。Commit message 描述**结果能力**
（"complete onboarding workflow"），不是**过程**（"fix typo, retry, fix
import, retry, fix padding"）。**一个 feature 一次 commit，squash merge
进 `main`，Conventional Commits。**

我们加了一段小 bash 脚本，commit 标题是 `wip` / `fix` / `update` / `asdf`
直接 fail。**它抓 Agent 抓得相当狠。**

**3. 先搜索，再生成。**

AI Agent 有极强的"生成"偏好。没有显式纪律，每个 prompt 都会产出
和已有东西高度相似的近似复制品。六个月后你会有 `useDebounce`、
`useDebounce2`、`useDebouncedValue`、`useDelay` —— 都细微不同，
都没人维护。

规则：写新代码之前，先搜代码库里已有的实现、API、hook、component、
schema、prompt。**扩展已有的，只在真没有时才生成。**

### CI 账单到底烧在哪

Commit 节奏控住之后，CI 账单降了 ~70%。最大的单点杠杆是每个 workflow
都加 `concurrency: cancel-in-progress`。Agent 10 分钟内 push 20 次时，
**只有最新一次构建跑到完，其余被取消，不消耗分钟数**。

第二大的杠杆是 `paths-ignore`。Agent 迭代过程中会改大量文档；为
文档 PR 跑整个 app 的构建是纯浪费。把文档路径排除出昂贵 workflow，
又砍掉 ~20%。

然后 **`on: push` 在除 `main` 之外的所有触发器上禁用**。生产部署只来自
merge 到 `main`，没有别的入口。AI 分支只跑 preview deploy，不跑生产。

### Migration 事故到底烧在哪

4 次 migration 事故有共同原因：Prisma migration 走的是 `DATABASE_URL`，
而它在 Neon 上是 pooled endpoint。**Pooled connection 在事务模式下，
对 `CREATE INDEX CONCURRENTLY` 支持不可靠、session 级 setting 丢失。**
Migration 开始跑，Agent 走开，一半改动应用了，应用上线，应用炸。

修复：拆成两个 URL。

```
DATABASE_URL=postgres://...?pgbouncer=true   # runtime
DIRECT_URL=postgres://...                    # migration
```

Prisma 和 Drizzle 都原生支持这种拆分。**Agent 一开始就不该用 pooled
endpoint 跑 migration —— 但默认配置不区分，Agent 选了 easy path。**

### 规范里到底有什么

仓库的结构是给三类受众的：

- **人类**读 `STANDARDS.zh-CN.md`（单文件）或 `docs/<topic>.zh-CN.md`
  （分章节）。中英双语严格对称。
- **Vibe coding 工具**从 `skills/` 自动加载（Claude Code Skill 包，
  superpower 风格的 YAML frontmatter），或读仓库根的 `CLAUDE.md` /
  `AGENTS.md`。
- **下游项目**拷 `templates/`（CLAUDE.md、AGENTS.md、preview workflow、
  CODEOWNERS、commitlint 配置）和 `scripts/`（四个在 CI 里强制规则
  的 bash lint 脚本）。

这周发的 v0.2 新增 8 章：

- **AI 专属**：secrets 与 OIDC、prompt 即代码、AI 功能的 Evals、
  可观测性与成本闸
- **平台工程**：IDP 接入（Backstage / Harness IDP / Port / Cortex）、
  CODEOWNERS 对 AI diff 的路由、文档新鲜度、AI 修正版 DORA

### 你这周能直接抄走的四件事

如果这周你只做四件事：

- 在你拥有的每个 workflow 文件里加 `concurrency: cancel-in-progress`。
  3 行，没有 push 风暴的时候零代价。
- 关掉编辑器 / Agent 设置里的 auto-commit / auto-sync / auto-push。
  3 分钟翻一遍设置。
- 仓库里 `grep -r "DATABASE_URL"`，确认 migration 没指向 pooled
  endpoint。**如果是 pooled，下次 migration 上线前修掉。**
- 给碰过支付 / 认证 / schema 的路径加一行 CODEOWNERS。2 分钟。

**这四件事一个下午做完，大致能让 AI 驱动项目的痛减半。**

### 我搞错了什么，下一步是什么

规范第一版说"一个 feature = 一次 commit，永远"。**3 个月后我必须放宽** ——
实际上 feature 往往需要两次 commit（改动 + 测试，或 schema + 代码），
硬凑成一次反而让 diff 更难读。规则现在是："不要把不能独立成立的中间态
暴露到远端"。

还没搞清楚的：

- **Eval 规模化**。规范说"每个 prompt 一套 suite、每个 PR 跑、回归阻断
  merge"。**5 个 prompt 这套有效，500 个 prompt 时连带缓存的 eval 也开始烧钱。**
  得我亲眼看到大规模工作的方案才能写这一章。
- **Monorepo CI affected 检测**，同时混用 Turborepo / Nx / 自研三种工具。
  Monorepo 那章对单工具够用，**现实更乱**。
- **单人 maintainer 的 branch protection**。规范默认 ≥ 2 个 reviewer，
  1 个人的 OSS 仓 —— **你要么是作者要么不能 merge** —— 需要文档化例外。

### 仓库

[github.com/maweis1981/agents-md](https://github.com/maweis1981/agents-md)
—— MIT 协议，没有商业兴趣，没有 upsell。**规范本身**在 `STANDARDS.zh-CN.md`，
**分章节文档**在 `docs/`，**可安装 Claude Code Skill** 在 `skills/`，
**可直接拷贝的模板**在 `templates/`。

欢迎 PR、欢迎翻译、欢迎"我们队里做法不一样但效果更好"这种 issue。

---

## 发布注意

- **掘金**：标签 `AI` / `开源` / `Git` / `CI/CD`。掘金封面用 `docs/case-study.zh-CN.md`
  里的数字对比表（80 → 14 commit/天那一段截图）。
- **InfoQ**：投编辑邮箱时附上"agents-md 是一份方法论 spec，不是工具"的
  一句说明，避免被误归类。
- **公众号**：把"四件事这周抄走"那段拉到开头，公众号读者很少看完全文。
- **知乎专栏**：标题党化一点 ——「我让 AI Agent 写了三个月代码，
  CI 账单暴涨 6 倍，然后…」会比理性标题高 5-10 倍点击。
- **跨平台**：**24 小时内不要原文转发到多个平台**，搜索引擎会判重并降权。
  错开一天发，或者每平台改一下导语。
