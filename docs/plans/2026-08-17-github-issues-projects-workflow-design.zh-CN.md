# GitHub Issues 与 Projects 工作流——设计

## 目的

为使用 GitHub Issues 和 Projects 作为开发记录系统的 AI 代理与人工团队，增加一套公开、平台中立的标准。该标准必须同时适用于单仓库和多仓库项目，并且不得依赖任何特定组织、产品、平台或团队。

## 受众与范围

规则适用于 AI 编码代理、维护者以及人机协作团队，覆盖 Issue 归属、跨仓库工作、Backlog 与看板流转、迭代、结构化元数据、Pull Request 关联、自动化，以及代理与人工之间的权限边界。

标准区分：

- **MUST / MUST NOT**：可追溯性与代理安全行为所必需的规则。
- **SHOULD / MAY**：团队可根据规模和交付模式调整的建议。

## 规范模型

Issue 是工作的权威记录；Project 是基于 Issue 的视图与计划元数据；Pull Request 是实施证据。信息必须只有一个权威位置，不得在标签、字段、Issue 正文和独立看板之间重复维护。

推荐的基础流程是：

```text
Backlog -> Ready -> In Progress -> In Review -> Done
```

团队可以重命名状态，但必须保留等价语义以及明确的进入和退出条件。

推荐的结构化字段包括 Status、Priority、Size 或 Estimate、Iteration、Area，以及仅在确有截止日期时使用的 Target date。

## 代理规则

代理在进行实质性代码工作前必须查找或创建 Issue，将 Issue 放在主要代码变更所属的仓库中；跨仓库工作必须使用父 Issue 和各仓库专属的子 Issue，不得创建未关联的重复 Issue。

代理只能开始 Ready 状态的工作，必须设置负责人并将活动工作移至 In Progress，必须把 Pull Request 关联到 Issue；在验收标准满足且所需合并完成前，不得将工作标记为 Done。阻塞关系必须使用明确的 Issue 依赖关系表达。

未经授权，代理不得通过修改 Priority、Iteration、Target date、范围或验收标准来作出新的产品承诺。若这些值缺失或互相矛盾，代理必须将决策提交给人工处理。

## 文档结构

该功能将分四层集成：

1. 在 `STANDARDS.md` 与 `STANDARDS.zh-CN.md` 中提供完整双语章节。
2. 在 `docs/` 下提供独立的双语章节文件。
3. 在根目录及可分发的代理入口文件中提供简明的强制规则。
4. 更新双语 README 与变更日志，提升可发现性。

英文和中文文档必须保持语义等价，并通过仓库的双语对称性和内部链接检查。

## 操作指引

章节将定义：

- Definition of Ready 与 Definition of Done。
- Status、Priority、Size/Estimate、Iteration、Area、标签、里程碑和日期各自的含义。
- 跨仓库父 Issue 与子 Issue 模式。
- WIP 限制与评审时效建议。
- Backlog 梳理、迭代计划、日常流转与回顾。
- 推荐的内置自动化，但不强制规定确切字段名称。
- 代理在开始、更新、阻塞、评审和完成工作时的检查清单。

示例必须使用 `service-api`、`web-client`、`ios-client` 和 `android-client` 等中立名称。

## 验证

运行仓库的双语对称性与内部链接检查。检查所有强制性措辞，确保其不与现有分支、提交、Pull Request 和代理行为规则冲突。确认所有示例均不包含特定组织或产品标识。
