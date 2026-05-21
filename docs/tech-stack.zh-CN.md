# 推荐技术栈

> 不是强制要求，只是和本规范契合度最高的默认选项。
> English: [`tech-stack.md`](./tech-stack.md)

## 为什么列默认栈

规范本身不依赖具体技术栈。但规则在某些栈上更容易实施。把默认列出来
能让其余文档更具体，也能让新项目从一个已知良好的基线起步。

## 默认

| 层 | 推荐 | 为什么匹配规范 |
| --- | --- | --- |
| **版本控制** | Git + GitHub | Feature branch + squash merge + branch protection 一等公民。 |
| **CI/CD** | GitHub Actions | PR 触发构建、concurrency group、path filter、preview 部署都原生支持。 |
| **托管** | Vercel / Cloudflare / Netlify | 每个 PR 自动 preview；默认 scale-to-zero。 |
| **数据库** | Neon (Postgres) | direct + pooled endpoint；branch-per-PR；scale-to-zero。 |
| **ORM** | Prisma 或 Drizzle | 都支持 direct vs pooled 的 URL 拆分。 |
| **向量** | Neon 内置的 pgvector | 只管理一个 DB，无需独立向量基础设施。 |
| **队列** | Inngest / QStash | 事件驱动工作流，无需自托管 worker。 |
| **Auth** | Clerk / Auth.js / Supabase Auth | 托管，scale-to-zero 兼容。 |
| **可观测性** | Sentry + Axiom / Logflare | 不依赖常驻基础设施即可捕获 Agent 事件。 |
| **Agent IDE** | Claude Code / Cursor / Codex | 都会自动读取仓库根的 `AGENTS.md`（或 `CLAUDE.md`）。 |

## 等价替代

- **Scale-to-zero Postgres 替代**：Supabase（用 pooled endpoint）、
  CockroachDB Serverless。
- **Edge compute 替代**：AWS Lambda + API Gateway、Google Cloud Run。
- **队列替代**：AWS SQS、GCP Cloud Tasks、Trigger.dev。
- **CI 替代**：GitLab CI、CircleCI —— 所有规则照搬，只是 YAML 语法不同。

## 默认不推荐什么

- 早期项目用常驻 RDS / Cloud SQL / 自托管 Postgres 集群
  （会为闲置计算付费）。
- 把本可以 serverless 的 AI 负载放进长跑的 Kubernetes 部署
  （会有 Agent 长期占住 Pod）。
- `main` 用 merge commit 的 Git 工作流（破坏 squash 纪律）。
- CI 在每个分支每次 push 都做完整部署（破坏成本控制）。

## 推荐目录结构

```
project/
├── app/               # routes / pages / handlers
├── components/        # UI 组件
├── lib/               # 横切 helper / client
├── prompts/           # prompt 模板（受版本控制和 review）
├── workflows/         # Agent workflow / 状态机
├── agents/            # Agent 定义
├── prisma/            # 或 drizzle/，schema + migration
├── scripts/           # 一次性运维脚本
└── docs/              # 人类文档，包含 CLAUDE.md / AGENTS.md 副本
```

这个布局在 `templates/` 里有体现 —— 你的仓库结构如果不同，没关系，
规范本身不会因此失效。

## "AI-Native" 仓库会额外有什么

在上述结构之外：

- 仓库根有 `CLAUDE.md` 或 `AGENTS.md`。
- 版本控制下的 `prompts/`，按代码同等纪律 review。
- `agents/` 目录记录每个 Agent 的角色与可用工具。
- （可选）若使用 Claude Code，有一个小的 `skills/` 目录。
