# Prompt 即代码

> Prompt 是生产代码，按生产代码对待。
> English: [`prompts.md`](./prompts.md)

进入产品的 prompt 是二进制的一部分：控制 LLM 输出、每次调用花钱、改错会
炸 —— 和任何生产代码路径一模一样。

## 硬性规则

1. **Prompt 进版本控制**，不放 Notion，不在 Agent 记忆里。
2. **一次 prompt 改动 = 一个 PR**，按代码同等 review。
3. **改 prompt 必须带 eval 结果**（见 [`evals.zh-CN.md`](./evals.zh-CN.md)）。
   **没 eval 不合并**。
4. **语义版本号**：按 prompt 单独打版本，下游代码按版本 pin。
5. **超过 10 行的 prompt 不准 inline**：放到 `prompts/<name>.md` import。

## 推荐目录

```
prompts/
├── extract_invoice.md        # prompt 正文（自然语言）
├── extract_invoice.meta.json # 版本、owner、eval suite
├── classify_intent.md
├── classify_intent.meta.json
└── README.md                 # 索引 + 约定
```

`prompts/<name>.meta.json` 示例：

```json
{
  "name": "extract_invoice",
  "version": "1.4.0",
  "owner": "@finance-team",
  "model_default": "claude-opus-4-7",
  "eval_suite": "evals/extract_invoice/",
  "deprecates": ["1.3.x"],
  "input_schema": "schemas/invoice_input.json",
  "output_schema": "schemas/invoice_output.json"
}
```

## Prompt 的语义版本

和软件 semver 同形：

| Bump | 何时 |
| --- | --- |
| **MAJOR** | 输出 schema 变化，下游必须适配。 |
| **MINOR** | 新增行为，旧输入仍输出兼容结果。 |
| **PATCH** | 措辞调整，eval 测得输出可计量等价。 |

下游 pin：

```ts
import { loadPrompt } from "@/prompts";
const prompt = loadPrompt("extract_invoice", "^1.4.0");
```

新增 minor 不会破坏调用方。

## Review 规则

Prompt PR 必须：

- [ ] 只动一个 prompt + 它的 `meta.json`。
- [ ] 按 semver bump 版本。
- [ ] PR 描述里贴 eval 输出（通过/失败 + 关键指标）。
- [ ] 注明专门调过哪个 model。**专调一个 model 的 prompt 换 model 会退化。**

Prompt PR 不应：

- 把使用该 prompt 的代码改动一起带进来（除非是 MAJOR 升级且必须改调用点）。
- 因为"只是 typo"而跳过 eval —— 已发表研究里很多"trivial 改动"
  让输出可测量地退化。

## A/B 变体

风险大的 prompt 改动用 flag 上灰度，部分流量并跑两版：

```ts
const prompt = featureFlag("invoice_prompt_v2", request.userId)
  ? loadPrompt("extract_invoice", "2.0.0")
  : loadPrompt("extract_invoice", "1.4.0");
```

按生产 eval 分数决定推全还是回退，**别凭直觉**。

## 反模式

- **inline 原地改 prompt** —— 不可逆、无历史。
- **TypeScript 字符串里写 10 行以上 prompt** —— 没高亮、diff 不可读、无独立 review。
- **`f"..."` / 模板字符串把用户输入直接拼进 system prompt** —— prompt
  injection 等着发生。
- **"只是 typo 跳过 eval"** —— 见上。

## Prompt Injection 缓解

进入 prompt 的用户输入必须：

1. **分隔标记清晰**（XML tag、`<<<>>>` 之类），让模型能区分用户内容和指令。
2. **过滤明显注入特征**（"ignore previous instructions"），至少日志留痕。
3. **输出做 schema 校验**：LLM 输出不符合输出 schema 就 reject 重试，
   不要直接透传。

## 参考

- [`evals.zh-CN.md`](./evals.zh-CN.md) —— 每次 prompt 改动都要产生
  eval 结果。
- [`observability.zh-CN.md`](./observability.zh-CN.md) —— prompt 在
  生产跑时要记什么日志。
- [`agent-behavior.zh-CN.md`](./agent-behavior.zh-CN.md) §1 ——
  写新 prompt 前先搜旧的，复用为先。
