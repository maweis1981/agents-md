# Agent 团队

> 规范前 19 节默认"一个 Agent 一次干一件事"。现实已经走到：真实团队
> 同时跑 10-50+ 个 Agent。这一章讲怎么做。
> English: [`agent-teams.md`](./agent-teams.md)

单 Agent 纪律（1-19 节）仍然正确 —— 它描述的是一个独立贡献者。
**同时跑多个 Agent** 时会出现单 Agent 规则不覆盖的新失败模式：
Agent 互相覆盖工作树、两个 Agent 在重叠任务上产出相矛盾的结果、
Agent 给自己打分、没有机制刹住就一直烧钱。

本章把业界正在收敛的编排模式固化下来（Lauren Tan / Cursor 2.0 /
Grok Build / Claude Code worktrees）。

## 硬性规则

1. **每次多 Agent 运行必须有三个明确角色**：Chief of Staff、
   Executor(s)、Judge(s)。**禁止扁平的"N 个平权 Agent 共享文件"。**
2. **每个 Executor 在自己隔离的工作区运行** —— 默认 `git worktree`，
   需要时用容器或远程 VM。**禁止共享工作目录。**
3. **Judge 用的模型家族必须和被判 Executor 不同**；eval 成本允许时
   优先跨厂商。
4. **Rubric 必须在 Executor 开跑**之前**写好**，不能事后补。
5. **Chief of Staff 不写代码**。只做规划、分派、监控、聚合。
6. **Chief of Staff 必须有硬性预算上限**（token / 美元 / 墙钟时间）。
   超限 → 整个 fleet 停下，上报。
7. **每个 Agent 动作都要落日志**（prompt / 工具 / 成本 / 决定）。
   见 [`observability.zh-CN.md`](./observability.zh-CN.md) §17.4。
8. **人类 review 在聚合结果上**，不是每个 Executor PR 上。Judge 是
   让体量能上去的那一层；人类 review 是 meta-gate。

## 5 层自验证栈

每个 Agent 团队产出必须依次通过：

```
1. 本地理智检查   lint / type-check / 语法
2. 隔离单测       Executor 在自己 worktree 里跑
3. 集成 / eval    跨组件行为
4. 跨模型 Judge   不同厂商模型照 rubric 打分
5. 人类 meta-gate 对聚合集合的一次签字
```

任一层失败都退给 Executor。连续 4 次 Judge 驳回 → Chief of Staff
重新规划（可能重新拆分任务，或升级给人）。

单 Agent 用 1-3 + 5。团队用全 5 层。

## Chief of Staff 模式

职责：

- 读任务，生成 `plan.yaml`（或等价物），包含子任务 / rubric /
  Executor 画像 / Judge 模型。
- 为每个子任务拉起一个 Executor + 一个 Judge。
- 监控状态、成本、时间。
- 把被接受的 Executor 输出聚合成**一个连贯的 patch set**。
- Judge 驳回级联或 Executor 超时时重新规划。
- 向人类上报最终结果（成功 / 部分完成 / 已停）。

禁止：

- 直接写 / 改代码。
- 没生成 rubric 就批准自己的 plan。
- 让多个 Executor 共用 worktree。

## Executor 模式

职责：

- 从 Chief of Staff 拿到子任务描述 + rubric。
- 在自己的 worktree 里工作。
- 提交 patch + 自述（做了什么、哪里不确定）。
- 超预算时**干净退出**，不要 busy-wait。

禁止：

- 访问别的 Executor 的 worktree。
- 批准自己的输出。
- 修改 rubric。

## Judge 模式

职责：

- 接收 rubric + Executor 输出。**只有这两样。** 不给任务 prompt、
  不给 plan 上下文、不给 Executor 自述。**上下文偏见是 LLM-as-judge
  失败的主因。**
- 照 rubric 打分，输出 pass/fail + 分数 + 理由。
- 和被判 Executor 独立。

**两票仲裁**（两个不同厂商 Judge）在"分歧好解决"时胜过单一强 Judge。

禁止：

- 改 Executor 输出。
- 和被判 Executor 同一个模型家族。
- Judge 自己之前的输出。

## Worktree 生命周期

```bash
# Chief of Staff 拉起 Executor e42
git worktree add .worktrees/e42 -b ai/exec-e42

# Executor 在 .worktrees/e42 里自由写
# ... 在 ai/exec-e42 上按需 commit ...

# Chief of Staff 收取 patch
git -C .worktrees/e42 format-patch main --stdout > out/e42.patch

# Judge 接受 → apply 到聚合分支
# Judge 驳回 → 重 prompt Executor 或丢弃

# 拆台
git worktree remove .worktrees/e42
git branch -D ai/exec-e42
```

Executor 分支（`ai/exec-e42`）**可丢弃**。合到 `main` 只通过 Chief
of Staff 聚合后的那一个 PR —— 这个 PR 仍然按
[`pull-request.zh-CN.md`](./pull-request.zh-CN.md) 走
（一个 feature、squash merge、默认草稿）。

## 什么时候**不**该用 Agent 团队

编排开销不小。单 Executor 跑赢团队的条件至少**满足三条**：

- 任务天然可并行（子任务互相独立）。
- 每个子任务至少 10 分钟 Agent 工作量。
- Rubric 开工前就能写出来。
- 人类没法有意义地单独 review 每个子任务。
- 聚合成本有上限（预算 cap）。

如果是 5 分钟单文件改动，跑一个 Agent 就完事。**编排比工作本身还大。**

## 和其他章节的交互

- **[`pull-request.zh-CN.md`](./pull-request.zh-CN.md)** ——
  Chief of Staff 聚合输出仍然是一个 PR / 一个 feature / squash merge。
  Executor **不**自己开 PR 到 `main`。
- **[`agent-behavior.zh-CN.md`](./agent-behavior.zh-CN.md)** ——
  Cap retries at 3 作用在每个 Executor；Chief of Staff 在 fleet 层
  强制。rule-baking flywheel (§9.7) 把静态规则喂给 Judge。
- **[`evals.zh-CN.md`](./evals.zh-CN.md)** —— 跨模型 Judge 规范在
  §17.3；本章的 Judge 角色实现它。
- **[`observability.zh-CN.md`](./observability.zh-CN.md)** ——
  fleet 里每个 Agent 都 trace；Chief of Staff 汇总成本 + 延迟。
- **[`secrets.zh-CN.md`](./secrets.zh-CN.md)** —— 每个 worktree
  继承同一份 env；**绝不**给每个 Executor 复制一份 secret。
- **[`github-issues-projects.zh-CN.md`](./github-issues-projects.zh-CN.md)**
  —— Chief of Staff 更新 Issue 状态；Executor 不直接改 Project 字段。

## 反模式

- **扁平多 Agent** ——"N 个 Agent 改同一个文件，谁赢算谁的"。
  **必然数据丢失 + 静默冲突**。
- **自己判自己** —— Executor 和 Judge 同模型家族。模型本身的盲点
  会被双倍放大成假阳性。
- **事后写 rubric** —— 看了 Executor 输出再写 rubric，rubric
  描述成功，而不是定义成功。
- **无预算 Chief of Staff** —— 没硬 cap 的编排器几分钟烧光额度。
- **Executor 自己开 PR 到 `main`** —— 破坏聚合，淹没 review 面。
- **Judge 看全量任务上下文** —— 偏向"Executor 产出的就是任务要的"。

## 最小可用实现

想今天在一个任务上试试，不想上整套编排框架：

1. 任务 prompt 里让 Agent 先写一个 `plan.md` 列子任务，再写代码。
2. 每个子任务 `git worktree add` 一个新分支。
3. 同一个 Agent（不同 session）在每个 worktree 里跑，**只给**子任务
   描述 + rubric。
4. 第三个 session 用**不同模型**，只贴 patch + rubric，要
   pass/fail + 理由。
5. 接受的 patch apply 到一个聚合分支。开一个 PR。

这是**手工版**，重点是形状。工具（Cursor 2.0 worktree 模式、pstack、
Claude Code `/agents`）自动化的是同一个形状。

## 参考

- Lauren Tan 的 `pstack`（前 Cursor，现 SpaceX/xAI）—— 本模式
  最常被引用的开源实现（MIT）。
- [Cursor 2.0 parallel agents](https://cursor.com/) —— worktree
  隔离作为产品功能。
- [`agent-behavior.zh-CN.md`](./agent-behavior.zh-CN.md) §9.7 ——
  rule-baking flywheel 把检查沉淀给 Judge。
- [`evals.zh-CN.md`](./evals.zh-CN.md) §跨模型 Judge —— Judge 侧约定。
