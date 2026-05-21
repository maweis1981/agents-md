# 项目概览

> 一页纸了解 `agents-md`。
> English: [`overview.md`](./overview.md)

## 问题

现代 AI 编程 Agent —— Claude Code、Cursor、Codex / OpenAI Agents、
Devin、Windsurf —— 每小时能产出几百次代码变更。
Git、GitHub、CI/CD pipeline、托管数据库，本来都是按**人类**节奏
（每个开发者每天几次 commit）设计的。

直接把 Agent 接到这套基础设施上，几乎必然出现：

- **限流风暴**：GitHub API 被打到上限，Agent 任务中断。
- **账单爆炸**：每次 push 都触发 build，staging 被反复唤起几百次。
- **历史不可读**：`fix` / `wip` / `update` / `tmp` 重复几十次，
  review 根本看不下去。
- **Deploy storm**：每次保存都重新部署生产。
- **数据库损伤**：schema migration 走 pooled connection，上线即炸。
- **常驻 Agent**：长循环把 scale-to-zero 数据库连接长期占住，
  成本模型完全崩溃。

## 立场

> **AI 可以高频修改，系统必须低频提交状态。**

一次 *commit* 应该是系统的一个稳定快照，而不是 Agent 思考过程的一帧。
Agent 的高频活动留在本地；跨系统事件（push / merge / deploy / migrate）
保持低频。

## `agents-md` 提供什么

1. **中英双语规范** (`STANDARDS.zh-CN.md` / `STANDARDS.md`)，覆盖十个主题：
   分支、commit、push、PR、CI/CD、数据库、Agent 行为、Serverless、技术栈、
   GitHub 设置。

2. **分章节文档**（`docs/`），适合喜欢按章节阅读、按链接引用的团队。

3. **可安装的 Claude Code Skill**（`skills/`），采用 superpower 风格的
   `SKILL.md` + YAML frontmatter，vibe coding 工具可以按需加载
   （比如只装 commit 纪律的 Skill、只装 CI/CD 的 Skill）。

4. **可直接落库的模板**（`templates/`）：想要整套规范的项目，
   把 `CLAUDE.md`、`AGENTS.md`、GitHub Actions workflow 模板拷过去就完事。

## 谁会用

- 用 "vibe coding" 工作流、AI Agent 真在动 Git 仓库的团队。
- 想给 AI 贡献者（和人类贡献者）一份基准规则的开源 maintainer。
- 在做 AI-native CI/CD、DB migration、分支系统的工具作者。

## 不是什么

- 不规定你用哪个 AI Agent，技术栈中立。
- 不是构建系统，唯一产物就是 Markdown。
- 不是运行时强制执行工具：你自己在 CI / branch protection 里实施这些规则，
  本仓只负责给出规则。

## 下一步

- [`outlook.zh-CN.md`](./outlook.zh-CN.md) —— AI-Native 开发的未来方向。
- [`../STANDARDS.zh-CN.md`](../STANDARDS.zh-CN.md) —— 完整单文件规范。
- 本目录下分主题文档。
- [`../skills/`](../skills/) —— 可安装 Skill 包。
- [`../templates/`](../templates/) —— 可直接落库的模板。
