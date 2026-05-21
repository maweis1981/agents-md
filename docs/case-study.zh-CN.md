# 案例研究 —— 一家 3 人 AI 初创公司的落地过程

> 一个合成、虚构、基于常见模式的叙事。不针对任何具体公司，不构成法律建议，
> 不保证同样效果。
> English: [`case-study.md`](./case-study.md)

## 背景

- **团队**：3 名工程师 + 2 名设计师。
- **产品**：AI-first 的 B2B SaaS，Next.js + Prisma + Neon，部署在
  Vercel，落地规范时大约上线 12 周。
- **在用的 Agent**：一名工程师用 Claude Code，两名用 Cursor，偶尔从
  命令行用 Codex 跑批量重构。
- **落地前的痛点**：每天 80+ commit 直接落 `main`，一半的 message 是
  `wip` / `fix` / `update`。CI 成本是同类非 AI 项目的 6 倍。3 周内生产环境
  出过 4 次不相关的小事故，全部由"部分应用的 migration"导致。

## 第 1 周 —— 安装规范

1. 把 `templates/` 里的 `CLAUDE.md` 和 `AGENTS.md` 落到仓库根，
   编辑 "Project specifics" 段。
2. 引入 `templates/.github/workflows/preview.yml`，替换掉原来对所有分支
   `push` 就 build 的 workflow。
3. 按 `docs/github-settings.zh-CN.md` 配置 `main` 的 branch protection：
   - 必须 PR + 1 个 approve。
   - 仅 squash merge。
   - 必需 status check：`lint`。
   - 关闭 merge-commit 和 rebase-merge。
4. 加入 `scripts/lint-*.sh` 和对应的 `lint` workflow。
5. 在团队 Linear handbook 里把 `STANDARDS.zh-CN.md` 加书签。

总耗时：半天。没改一行应用代码。

## 第 2 周 —— 首个可观察变化

- **commit 从 ~80/天 降到 ~12/天。** 代码产量不变，只是不再每次保存就 push。
- **CI 分钟数下降 ~70%**，主要靠 `concurrency: cancel-in-progress`
  把被取代的 run 自动取消。账单不再是紧急事项。
- 一位工程师的 Cursor 还在 auto-sync，花了大约 30 分钟在三处关掉
  "Auto Commit" 和 "Auto Push"（Cursor 设置、项目 `.vscode/settings.json`、
  早期 Agent loop 装的一个 pre-commit hook）。
- 团队第一次出现"我因为 commit 太勤丢了一个 feature"的对话。结论：
  探索性工作改用 `git stash`。

## 第 4 周 —— DB 习惯改变

- 把 `ai-native-database` Skill 装到 `.claude/skills/`。
- 重写 `.env` 里的 `DATABASE_URL` / `DIRECT_URL`，让 Prisma migration
  走 direct endpoint。期间发现并干掉了一个常驻 serverless 函数，
  它一直占着 30 条 Neon 直连。
- 探索阶段不再每次 schema 改完就 `prisma migrate dev`。可行的范式：
  自由编辑 `schema.prisma`，每个 feature 完成时跑一次
  `prisma migrate dev --create-only`，review SQL 后再应用。
- 之前最折磨的「部分应用的 migration 阻塞部署」事件再也没出现，因为
  Neon branch + direct URL 在 preview 部署时就能抓住。

## 第 8 周 —— 留下什么、丢掉什么

**留下：**

- 全员 `ai/<feature>` 分支前缀，不再有以前的 `username/whatever`。
- 默认 draft PR。reviewer 看到 draft 就不打开。
- Squash merge 作为**唯一**合并方式。
- 每个 CI workflow 都加 concurrency-group debounce。
- 每次 push 前的 30 秒自查 checklist。

**丢掉：**

- "一个 feature 只 commit 一次"的强约束。实际平均 2 次 commit
  （一个改动、一个测试或文档）。"一次稳定 feature 一次 commit"
  太紧，"不要把不能独立成立的中间态暴露到远端"够紧了。

**修改：**

- 团队加了一个 `human/<topic>` 前缀给纯人类工作（无 AI 介入），
  让 PR 走另一个 review 模板。不在规范里，本地觉得好用。

## 第 12 周 —— 数字

| 指标 | 落地前 | 12 周后 |
| --- | --- | --- |
| 每日 commit 数 | ~80 | ~14 |
| `main` 上的垃圾 commit（squash 历史） | ~50% | 0（squash + commit lint） |
| 每月 CI 分钟数 | 8,400 | 2,300 |
| 生产 migration 事故 | 3 周内 4 次 | 9 周内 0 次 |
| 平均 PR 开放时长 | 5.2 天 | 1.4 天 |
| "我分支哪儿去了"求助 | 每周一次 | 0 |

**这些数字是合成的、虚构的。** 实际效果因团队而异；不过"commit 量下降、
CI 成本下降、migration 事故下降"这个形状，是我们听到的团队普遍出现的。

## 出乎意料的发现

1. **最大的收益不是规范本身，而是关掉每个工具里的 auto-commit。**
   规范的作用是「让团队有底气要求关掉它」。
2. **「默认 draft PR」是士气提升最大的一条。** 工程师不再被自己半成品
   的 CI 邮件打扰。
3. **双语规范比预期更重要。** 两位设计师 + 一名工程师优先读中文版，
   只在和团队其他人讨论细节时才切英文。
4. **lint workflow 抓到的 "AI 错误" 比人类错误多。** 这正是它的目的 ——
   人类有多年训练，Agent 只有几小时。

## 假如重来一遍

- 更早落地。规范前的生产力损失大部分来自从 `main` 的乱象里恢复，
  而不是 AI 本身。
- 第 1 天就装 lint 脚本，而不是第 1 周。
- CI 里第一个动的就该是 `concurrency.cancel-in-progress`。
  它是单点最大的成本杠杆。

## 引用

这个案例是合成的。如果你想分享自己的（真实或脱敏的），用
[`.github/ISSUE_TEMPLATE/`](../.github/ISSUE_TEMPLATE/) 里的
translation/case-study issue。
