# GitHub Issues 与 Projects 工作流实施计划

> **给 Claude：** 必须使用 `superpowers:executing-plans` 子技能逐项实施本计划。

**目标：** 增加一套公开、双语、平台中立的标准，指导 AI 代理与人工团队使用 GitHub Issues 和 Projects 管理开发工作。

**架构：** 以 `STANDARDS.md` 和 `STANDARDS.zh-CN.md` 为权威文件，在 `docs/` 下发布同等内容的独立双语章节，并在代理入口模板中加入简明的强制指引。更新导航与变更日志，不引入运行时工具。

**技术栈：** Markdown、基于 Shell 的双语对称性检查、基于 Shell 的内部链接检查、Git。

---

### 任务 1：增加独立的英文工作流章节

**文件：** 创建 `docs/github-issues-projects.md`。

1. 起草规范结构：范围、记录系统、仓库归属、跨仓库工作、字段、生命周期、Definition of Ready、Definition of Done、WIP、迭代、自动化、代理权限和检查清单。
2. 一致使用 RFC 风格的 MUST / MUST NOT 措辞。
3. 仅使用 `service-api`、`web-client`、`ios-client`、`android-client` 等中立仓库名作为示例。
4. 确认 Pull Request 规则引用现有标准，不重复定义分支、提交或合并策略。
5. 提交：`docs: add GitHub Issues and Projects workflow`。

### 任务 2：增加中文对应章节

**文件：** 创建 `docs/github-issues-projects.zh-CN.md`。

1. 完整翻译章节，保持章节顺序、示例、表格、规则强度和链接一致，并采用自然中文。
2. 对比生命周期、权限边界和检查清单的语义对称性。
3. 运行 `./scripts/check-bilingual.sh`，预期新双语文件对及现有文件均通过。
4. 提交：`docs(zh-CN): add GitHub Issues and Projects workflow`。

### 任务 3：集成权威的单文件标准

**文件：** 修改 `STANDARDS.md` 和 `STANDARDS.zh-CN.md`。

1. 以新的顺序编号追加英文规范章节，保留全部强制生命周期与代理权限规则，并链接独立章节获取扩展示例。
2. 在中文标准中加入强度和结构等价的章节。
3. 使用 `rg -n '^## |^### ' STANDARDS.md STANDARDS.zh-CN.md` 检查编号及双语对应关系。
4. 提交：`docs: standardize issue and project tracking`。

### 任务 4：在代理入口执行规则

**文件：** 修改 `AGENTS.md`、`CLAUDE.md`、`templates/AGENTS.md`、`templates/CLAUDE.md`。

1. 添加简短的追踪规则：实质性工作前必须有 Issue；明确仓库归属；跨仓库使用子 Issue；关联 Pull Request；准确更新状态；新的计划承诺需人工批准。
2. 根文件链接权威标准和独立章节；模板链接其既有的标准路径，不复制完整章节。
3. 比较代理入口，确认仅存在有意的代理专属措辞差异。
4. 提交：`docs: enforce issue tracking in agent entry points`。

### 任务 5：更新导航与发布说明

**文件：** 修改 `docs/README.md`、`README.md`、`README.zh-CN.md`、`CHANGELOG.md`。

1. 在文档导航中加入新的双语章节。
2. 在双语仓库概览中简要提及工作流覆盖范围，避免重复规范正文。
3. 在 Unreleased 下记录双语章节、权威规则及代理入口约束。
4. 提交：`docs: link issue and project workflow guidance`。

### 任务 6：验证完整文档集

1. 运行 `./scripts/check-bilingual.sh`，预期通过。
2. 运行 `./scripts/check-links.sh`，预期通过。
3. 在新增规范内容中搜索 `hanakoi|mira-gift-hq|maweis1981`，预期无匹配。
4. 运行 `git diff main...HEAD --check` 和 `git diff main...HEAD --stat`，预期无空白错误且仅修改文档、计划和导航文件。
5. 仅在有验证修复时提交：`docs: fix workflow documentation validation`。

### 任务 7：发布以供评审

1. 运行 `git status --short` 和 `git log --oneline main..HEAD`，确认工作区干净且提交逻辑清晰。
2. 推送 `ai/github-projects-workflow` 分支，不修改 `main`。
3. 创建 Draft Pull Request，概述公共工作流标准、双语验证结果以及示例的平台中立性。
