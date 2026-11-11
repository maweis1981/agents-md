# Agent 行为约束

> 对 AI Agent 自身可执行行为的约束，与平台无关。
> English: [`agent-behavior.md`](./agent-behavior.md)

## 1. 先搜索再生成

写新代码前，Agent 必须在代码库里搜索是否已有：

- 同样功能的实现
- API / route / handler
- React / Vue / Svelte component
- hook / composable
- utility
- type / interface / schema
- prompt template

若有近似匹配，**扩展它**而不是再写一个平行版本。

Agent 需要**外部**信息时 —— vendor 的 design token、SDK 形状、配置
schema —— 同样的规则往外推一层：**先看 vendor 有没有暴露机器可读 Markdown
端点**（比如 Vercel 的 [`/design.md`](https://vercel.com/design.md)
和 [`/design.dark.md`](https://vercel.com/design.dark.md)，或者
`llms.txt` 风格的端点），**再考虑抓 HTML 或凭感觉写**。
见 [`machine-readable-docs.zh-CN.md`](./machine-readable-docs.zh-CN.md)。

为什么：AI Agent 有极强的"生成"偏好。不约束就会永久放大维护面。
重复的 `useDebounce`、`Button`、`formatDate`、auth schema —— 每一个都会
拖累团队几年。

## 2. 优先修改已有文件

禁止：能改一个文件解决的问题，却生成一堆新文件。

明确禁止的反模式：

- 在 `utils/foo.ts` 旁边新建 `utils/foo-v2.ts`。
- 在 `Button.tsx` 旁边新建 `ButtonNew.tsx`。
- 新建 `schema-new.prisma` "为了不破坏旧的"。

需要替换就替换，需要拆分就拆分。但**"叠加式重复"是被禁止的**。

## 3. 限制 Retry

工具 / 测试 / 构建 / 部署失败时：

- 默认最多 **3 次** retry。
- 每次 retry 必须带一个**新假设**，不能"再跑一遍同样的东西"。
- 超过上限，Agent **必须**：
  - 输出清晰的失败原因。
  - 停下。
  - 请求人工介入。

无限修复循环是被禁止的。Agent "卡住"时，循环不是 bug，**循环本身就是 bug**。

## 4. 禁止持续 polling

禁止：

```js
while (true) {
  const status = await checkTask(taskId)
  if (status === 'done') break
  await sleep(1000)
}
```

为什么：Agent 是短生命周期 worker，polling 循环会占住资源、占住 DB 连接、
吃掉 API 配额，serverless 上还在烧钱。

推荐替代：

- **Webhook**：任务完成时反向通知 Agent。
- **Queue**：Agent 取下一个任务，不要"等着这一个"。
- **事件订阅**：Agent 注册兴趣，平台叫醒它。

如果运行时强制 polling（有些平台不暴露 webhook），用大间隔（≥ 30s）+
指数退避 + 总等待时间硬上限。

## 5. 禁止静默失败

Agent 放弃任务时必须明说。禁止：

- 因为 prompt 期望成功就返回"成功"。
- 在 PR 描述里把没做完的事写成做完了。
- 把 TODO 标成完成来终止循环。

完不成，就说**完不成、以及为什么**。

## 6. Rule-baking flywheel（规则沉淀飞轮）

你的 Agent（或 Agent 团队 ——
见 [`agent-teams.zh-CN.md`](./agent-teams.zh-CN.md)）检测到反复出现
的失败时，正确做法**不是**写更长的 prompt，而是**把失败转化为无需
LLM 调用就能跑的 check**。

循环：

```
Judge / 人类第二次抓到同一个错
        ↓
能用静态检查抓吗？
   能 → 加到 scripts/lint-*.sh
   不能 ↓
能用 eval case 抓吗？
   能 → 加到 evals/<name>/dataset.jsonl
   不能 ↓
加一个专职 Reviewer skill：skills/review-<topic>/SKILL.md
```

为什么是这个升级顺序：

- 静态 lint 毫秒级跑完、零成本、不 flaky。
- Eval case 在 CI 里跑，抓非静态回归，几分钱。
- Reviewer skill 每个 PR 跑一次，抓前两层抓不到的，代价是一次 LLM
  调用。

**只活在 system prompt 里的规则是最弱的强制形式** —— Agent 看得到，
Agent 有时就是无视它，你没任何记录。**把规则从 prompt 里烘出去**，
沉到下面几层。

### 该沉淀的信号

- 同一个 reviewer 评论连续出现在 3 个 PR → lint。
- 同一个 eval 回归跨多个 prompt 版本 → dataset case。
- session 日志里反复出现"Agent 不知道 X" → Reviewer skill。
- 人类在 Slack 里反复说同一句话给 Agent → 静态 check。

### **不**该沉淀的

- 一次性情境指导（"本季度优先用 X 模式"）。沉淀会变的政策只会增加阻力。
- 多租户共享规范里只适用于一个项目的偏好。
- 没法表达成假阳性率 <10% 的确定性 check 的东西。

### Flywheel 的目的

Agent 变聪明靠的是**减少自由度**，不是更长 prompt。每条规则烘到
prompt 之下，下一次 Agent 运行就少一个可能做错的东西。
**规范就是 prompt 自身没有的长期记忆。**

## 7. 生成 CI / DB / infra 代码时也要遵守规范

Agent 自身写的：

- GitHub Actions workflow → 必须遵守 [`ci-cd.zh-CN.md`](./ci-cd.zh-CN.md)。
- migration 文件 → 必须遵守 [`database.zh-CN.md`](./database.zh-CN.md)。
- 分支 / commit / PR → 遵守
  [`branching.zh-CN.md`](./branching.zh-CN.md)、
  [`commits.zh-CN.md`](./commits.zh-CN.md)、
  [`pull-request.zh-CN.md`](./pull-request.zh-CN.md)。

**规范同样适用于 Agent *生成* 的代码，不只是 Agent 自己的行为。**
