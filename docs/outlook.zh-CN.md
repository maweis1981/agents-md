# 未来展望

> AI-Native 开发将走向何处。
> English: [`outlook.md`](./outlook.md)

## 现在：一层兼容层

老实说，`agents-md` 是 AI 编程 Agent 与「为人类设计的 Git / GitHub 世界」
之间的**兼容层**。

之所以需要这层兼容，是因为：

- Git diff 是行级的，不是意图级的。
- GitHub Actions 默认每次 push 都是人类的一次主动决定。
- Branch protection 默认 reviewer 是一小撮有名有姓的人。
- 数据库迁移工具默认人类一次只协调一个变更。
- 大多数 CI 平台按 build 次数计费，而不是按一个 "完整工作单位" 计费。

`STANDARDS.md` 里的规则，就是让 AI Agent 不烧掉这个世界的最小规则集。

## 未来：从 `commit-driven` 到 `state-driven`

更长期看，我们预期会发生这样的迁移：

| 现在 | 未来 |
| --- | --- |
| **commit-driven** 版本控制 | **state-driven** 版本控制 |
| 行级 diff | 语义 / AST diff |
| commit message | 意图 diff |
| commit 历史 | workflow snapshot |
| `git rebase` | 语义合并 |
| 人类 review PR | 人类 + Agent 共同 review PR |
| Branch protection | policy-as-code，按意图实施 |

在 state-driven 的世界里，变更的最小单位是**「一个施加在系统上的连贯意图」**，
而不是「一坨行级编辑」。Agent 记录意图，工具产生 diff，人类 review
意图本身。

这套工具现在还不存在。所以我们用 Git，并约束 Agent。

## 值得关注的具体信号

- **语义 / AST diff 工具**。基于 tree-sitter 的结构 diff
  ([Difftastic](https://difftastic.wilfred.me.uk/))、`git diff --word-diff`
  之类已经存在；下一步是**意图 diff** ——"这个 PR 加了一个 feature flag、
  没动认证、重构了三个组件"。一旦意图 diff 像行 diff 一样便宜，
  "一个 PR 一个 feature" 就从社会规则升级为结构规则。
- **AI-Native IDE 基础设施**。Claude Code、Cursor、Codex、Devin、
  Windsurf 等正在把 *session* 和 *workflow*（而不是文件）当作 source of
  truth。本规范依赖的 `AGENTS.md` / `CLAUDE.md` 约定，本身就是这一
  迁移的早期产物。
- **Scale-to-zero 数据库**。Neon / Turso / PlanetScale、以及 Supabase
  的 pooled+direct 拆分，已经是生产级。早期项目默认上常驻 Postgres
  集群的时代正在结束。
- **事件驱动的 Serverless 运行时**。Inngest、Trigger.dev、QStash、
  Cloudflare Queues 等用消息触发的 worker 替代常驻 Agent 循环。
  经济模型终于和 AI 的突发负载对齐。
- **Policy-as-code 分支保护**。GitHub Rulesets、OpenSSF Scorecard、
  以及按仓 GitOps policy engine 暗示了走向：规则不再写成
  「必须通过这些 check」，而是「必须满足这个意图」—— 由另一个 Agent 验证。

以上没有一个是空想 —— 每一类都至少有一个在产的产品。真正的猜测在于
**哪一个**会在 ~24 个月内成为默认。

## 我们的承诺与不承诺

会做：

- minor 版本之间保持规范稳定。
- 破坏性变更只在 major 版本发生。
- 跟踪新出现的 Agent 平台，必要时给出对应模板。
- 接受社区翻译版本。

不会做：

- 假装 Git 是终极答案。
- 增加对任何特定云 / IDE / Agent 的强依赖工具。
- 为任何单一厂商的 roadmap 做优化。

## 版本规划

- `0.x` —— 稳定规则措辞和中英表述，主要是用词类 PR。
- `1.0` —— 规则集冻结。Skill 包、模板、示例等工具集成可以继续演化。
- `2.0` 及以后 —— 留给「未来」部分中的某一项技术真正可用、规范需要重塑
  形态的那一刻。

## 结语

如果两年后这个仓库**没那么必要**了——因为底层工具追上来了——那是成功，
不是失败。

在那之前：**高频修改、低频提交**。
