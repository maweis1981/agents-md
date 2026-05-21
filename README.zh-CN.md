# agents-md

> **Vibe Coding 时代的 AI-Native 开发规范**
>
> 一份中英双语的规范 + 可安装 Skill 包，约束 Claude Code、Cursor、
> Codex / OpenAI Agents、Devin、Windsurf 等 AI Agent 如何提交代码、
> 管理分支、跑 CI/CD、处理数据库迁移、以及上生产。

[简体中文](./README.zh-CN.md) ・ [English](./README.md)

---

## 为什么有这个项目

AI Agent 生成代码的速度，远远超出了 Git 被设计时所考虑的人类节奏。
把 Agent 直接接到 Git 上，几乎必然出现：

- GitHub API 限流
- GitHub Actions 账单爆炸
- Commit history 一片 `fix` / `wip` / `update` / `asdf`
- 生产环境 deploy storm
- 短生命周期的 Agent 常驻数据库连接
- Migration 走 pooled connection，把 schema 写炸

`agents-md` 是 **AI 编程时代与传统 Git 工作流之间的兼容层**。
它把团队需要的规则固化下来，让 AI 在 *本地* 高速迭代的同时，
*系统层面* 仍然保持低震荡、生产可控。

## 仓库结构

| 路径 | 用途 |
| --- | --- |
| [`STANDARDS.zh-CN.md`](./STANDARDS.zh-CN.md) / [`STANDARDS.md`](./STANDARDS.md) | 完整单文件规范，建议先读。 |
| [`docs/`](./docs/) | 中英双语分章节文档（人类可读）。 |
| [`skills/`](./skills/) | 可安装的 Claude Code **Skill** 包。 |
| [`templates/`](./templates/) | 可直接拷贝的 `CLAUDE.md`、`AGENTS.md`、GitHub Actions、settings 模板。 |
| [`CLAUDE.md`](./CLAUDE.md) | Claude Code 自动读取的入口。 |
| [`AGENTS.md`](./AGENTS.md) | Codex / OpenAI Agents / Cursor 自动读取的入口。 |

## 快速安装

### 方式 A —— 整套规范直接落到项目里

```bash
# 在你的项目根目录
curl -L https://raw.githubusercontent.com/maweis1981/agents-md/main/templates/CLAUDE.md   -o CLAUDE.md
curl -L https://raw.githubusercontent.com/maweis1981/agents-md/main/templates/AGENTS.md   -o AGENTS.md
```

两个入口文件会引用 `STANDARDS.md`，并包含 Agent 必须遵守的最小规则集。

### 方式 B —— 只安装单个 Skill（Claude Code，superpower 风格）

```bash
# 项目级 skill
mkdir -p .claude/skills
cp -r path/to/agents-md/skills/ai-native-git-workflow .claude/skills/
```

Claude Code 在命中 Skill 触发条件时（见每个 `SKILL.md` 的 YAML
frontmatter）会自动加载。

### 方式 C —— 整库作为 submodule

```bash
git submodule add https://github.com/maweis1981/agents-md docs/agents-md
```

> **URL 稳定性提示**：上面的 `curl` 指向 `main`。如果想要可复现的安装，
> 把 `main` 换成 tag（例如 `v0.1.0`），免得本仓后续演化导致你的依赖漂移。

### 方式 D —— 在 CI 里强制规则

本仓 [`scripts/`](./scripts/) 下提供了小巧的 bash lint 脚本，
检查 Conventional Commits、分支命名、中英对称、内部链接。
拷到你项目的 `scripts/`，仿照
[`.github/workflows/lint.yml`](./.github/workflows/lint.yml) 接到 CI 即可。
配套的 [`templates/.commitlintrc.json`](./templates/.commitlintrc.json)
让已经在用 Husky + `@commitlint/cli` 的项目可以一键启用相同规则集。

## 十条核心规则速览

1. **AI 可以高频修改 —— 但必须低频提交。**
2. **Agent 永远不能直接 push `main`。** 一律走 `ai/<feature>` 分支。
3. **一个 PR 一个功能。** 合并使用 **squash**，禁用 merge-commit。
4. **禁止 `on: push` 触发全量部署。** 用 `pull_request` 或 `workflow_dispatch`。
5. **生产部署只能来自 `main`。** Agent 分支只能 preview / staging。
6. **Migration 必须走 direct connection。** Runtime 才用 pooled connection。
7. **聚合 schema 变更。** 不允许「一次 prompt 一次 migration」。
8. **生成之前先搜索。** 复用已有 component / util / schema / prompt。
9. **禁止无限 retry。** 设置上限、抛出失败、请求人工介入。
10. **事件驱动，禁止 polling。** 默认 scale-to-zero。

完整规则、动机与示例见 [`STANDARDS.zh-CN.md`](./STANDARDS.zh-CN.md)。

## 状态

`v0.1.0` —— 创始版本。规范本身已可投入使用，破坏性变更仅会发生在
major 版本。

## 贡献

欢迎 PR、翻译、新增 Skill 包，详见 [`CONTRIBUTING.zh-CN.md`](./CONTRIBUTING.zh-CN.md)。
所有贡献者请遵守 [Code of Conduct](./CODE_OF_CONDUCT.md)。

## License

[MIT](./LICENSE)。随便用、随便 fork、随便上线。

---

> *Git 本身不是为 AI Agent 协作设计的。在更好的工具出现之前，这套规范就是桥。*
