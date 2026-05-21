# Monorepo

> 一个仓库里有多个 package / app 时，规范如何适用。
> English: [`monorepo.md`](./monorepo.md)

`STANDARDS.md` 里大多数规则在 monorepo 下原样适用。下面只讲不一样的部分。

## 分支命名

变更只影响一个 package 时，加 scope 前缀：

```
ai/<package>/<feature>
```

示例：

```
ai/web/auth-system
ai/api/memory-agent
ai/shared-ui/button-variants
```

若一个 feature 确实跨多个 package，可以省略 scope，在 PR 描述里列出受影响
package：

```
ai/cross-pkg-billing
```

但要诚实 ——「跨 package」的分支大多其实是两件事，应当拆开。

## 一个 PR 一个 feature，跨 package 也是如此

合理需要同时改 `apps/web` + `packages/sdk` + `prisma/` 的 feature 就是
**一个**。不要因为动了三个目录就拆三个 PR ——
**只有每一部分都独立可上线时才拆**。

monorepo 下更常见的错是**拆得太碎**：三个 PR 必须按顺序合并，reviewer
要在脑子里重新拼装变更。

## CI：只构建变了的东西

monorepo 在 AI 编辑下最大的成本陷阱是**每次 push 都全量构建**。
组合下列措施：

### 每个 workflow 加 path filter

```yaml
on:
  pull_request:
    paths:
      - 'apps/web/**'
      - 'packages/shared-ui/**'
      - 'pnpm-lock.yaml'
```

一个 workflow 对应一个逻辑变更范围。改文档的 PR 不应该构建 API 容器。

### Turborepo / Nx 的 affected 检测

Turborepo：

```yaml
- run: pnpm turbo run lint test build --filter='...[origin/main]'
```

`--filter='...[origin/main]'` 只对自 `main` 以来输入变化的 package 跑。
Nx 同理：`nx affected --target=...`。

### Concurrency group 按范围

不要让所有 PR 共享一个 concurrency group。按分支拆：

```yaml
concurrency:
  group: ci-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

## 数据库迁移

monorepo 下 migration 特别容易出错，因为多个 package 可能写同一个 DB。
经验法则：

- **一个数据库一个 canonical migration owner**，通常是顶层
  `prisma/` 或 `db/` package。
- **其他 package 只消费生成出来的 client**，不跑 migration。
- 只有 migration owner package 的 CI 才对 staging 跑 migration。
- 改 schema 的 PR **必须**修改 migration owner package。
  只改 app 就意味着没改 schema；改了 schema，migration package 必然出现在 diff 里。

这样「这个 PR 改了 DB 吗」就是一行 `git diff --stat` 就能看出。

## Skill 安装位置

Claude Code Skill 可以装在三个范围：

| 范围 | 位置 | 何时用 |
| --- | --- | --- |
| 仓库全局 | monorepo 根的 `.claude/skills/` | 所有 package 都适用的 Skill（git workflow、commit）。 |
| Package 范围 | `apps/<x>/.claude/skills/` | 栈相关的 Skill（例如 API package 里专门的 Drizzle Skill）。 |
| 用户范围 | `~/.claude/skills/` | 个人补充，不进仓库。 |

多数团队的 `agents-md` Skill 都放在 monorepo 根。

## CLAUDE.md / AGENTS.md 放哪

monorepo 里在**仓库根**放一份全局规则，**每个 package 可选**再放一份
（package 自己的 build / test / 注意事项）。

根文件要显式写："另见 `apps/<x>/CLAUDE.md` 获取 package 细节"。

## 僵尸 package 巡检

monorepo 下死代码会堆积。加一个周期性检查（`workflow_dispatch` 或月度
cron），标记 6 个月没改动的 package。AI Agent 特别容易从死代码里复制范式，
保持树干干净对所有人有好处。

## monorepo 下**不**变的规则

- 所有 commit 规则。
- 所有 push 规则。
- Squash merge 规则。
- "Agent 永不 push `main`" 规则。
- "Migration direct，Runtime pooled" 规则。
- "禁止无限 polling" 规则。

如果说有什么变化，就是 monorepo 下这些规则**更重要**了 —— 一次错误 commit
的爆炸半径更大。
