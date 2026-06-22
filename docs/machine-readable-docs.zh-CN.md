# 机器可读的 Vendor 文档

> 厂商开始在固定 URL 上以 Markdown 暴露自家文档，让 AI Agent 直接 fetch。
> 把这些当作权威引用来用；自己是厂商时，把自己的文档也这么暴露出来。
> English: [`machine-readable-docs.md`](./machine-readable-docs.md)

一个小而坚固的约定正在形成：厂商除了人类用的文档站，**额外**在一个可
预测的 URL 上暴露一份 Markdown —— `/llms.txt`、`/design.md`、`/api.md`
之类。AI Agent 直接拉 Markdown，不抓 HTML，不解析 DOM，不被 CDN 限流。

本章规定这个约定在两个方向上的用法：

1. **消费**：Agent 需要 vendor 信息时，**优先** fetch 机器可读 URL。
2. **生产**：你自己是 vendor / 维护者时，按同样方式暴露自己的文档。

本仓多数读者会同时做这两件事。

## 已经在线的例子

- **Vercel Geist** —— Vercel 完整设计系统的 Markdown 端点：
  - <https://vercel.com/design.md> —— light theme tokens + 指引
  - <https://vercel.com/design.dark.md> —— dark theme 变体

  访问 `/design` 是人类可读的设计系统页；同样的内容在 `.md` 端点上
  以 token + 散文形式给 AI Agent 直接消费。

- **`llms.txt` 提案** —— Jeremy Howard 提出的约定：厂商在 `/llms.txt`
  暴露索引，分主题各自 `.md`。越来越多文档站采纳，**尚未成为正式标准
  但正在收敛**。

- **本仓自己** —— `STANDARDS.md`、`CLAUDE.md`、`AGENTS.md`、
  分章节的 `docs/*.md`、`skills/*/SKILL.md`，本身就是放在可预测路径
  上的机器可读文档。**我们吃自己的狗粮**。

## 消费侧规则

Agent 需要 vendor 信息（design token、API 形状、配置 schema、术语表）
时必须：

1. **先找机器可读端点**。试这些常见 URL：
   - `<vendor-site>/llms.txt`
   - `<vendor-site>/design.md` / `design.dark.md`
   - `<vendor-site>/<topic>.md`
   - `<docs-site>/llms-full.txt`

2. **能 pin 版本就 pin**。厂商会更新，**按 tag / commit SHA /
   `Last-Modified` 头 pin 住**，让你 Agent 的输出可复现。

3. **激进缓存**。把这些当 build input 对待，不要每次 prompt 都 re-fetch。

4. **HTML 抓取只作最后手段**。抓文档站脆、慢、不礼貌（CDN 受压）。
   **即使 `.md` 端点信息略少，也优先用它。**

5. **安全敏感的事实别只信机器可读文档**（auth 流程、限流值等）。
   要和人类文档 + 真实 API 交叉验证。

## 生产侧规则

如果你的项目交付 SDK、设计 token、配置 schema、或者 AI Agent 会消费的
方法论：

1. **在可预测 URL 上暴露 `.md` 端点**。两种模式都有效：
   - **按主题分**：`/design.md`、`/api.md`、`/config-schema.md`。
     好写、好缓存、好打版本。
   - **索引 + 主题**（按 `llms.txt` 提案）：`/llms.txt` 列主题，
     每个主题各自 `.md`。

2. **`.md` 和人类版保持同步**。**最好同一份源头**。drift 比没有 `.md`
   更糟。

3. **每份 `.md` 顶部显式 pin 版本**：

   ```
   # Geist Design System: Overview
   version: 2.4.0
   updated: 2026-06-01
   ```

   按你 `.md` pin 的 Agent 可以便宜地重新校验。

4. **不要随便塞 secret、内部路径、或破坏性变更**。`.md` URL 至少和
   你文档站一样公开，**通常更公开**（Agent 会缓存并转发）。

5. **如有需要可加 User-Agent 白名单**，但**别加门槛**。这个模式的全部
   意义就是**零摩擦 fetch**。

6. **给 URL 本身打版本**，不只是内容。`/design.md` 升到 v2 时，把 v1
   的 schema 放到 `/v1/design.md`，旧 pin 不会崩。

## 在规范里的位置

- "搜索后生成" 规则（[`agent-behavior.zh-CN.md`](./agent-behavior.zh-CN.md)
  §1）天然让"消费机器可读文档"成为下意识动作。**写 UI 样式之前先 fetch
  vendor 的 `.md` 端点**。
- "文档新鲜度" 规则（[`doc-freshness.zh-CN.md`](./doc-freshness.zh-CN.md)）
  在你的 `.md` 被 AI 消费时**强度加倍**：代码和 `.md` 的 drift 会变成
  系统性的 Agent 错误。
- 你仓库根的 `CLAUDE.md` 和 `AGENTS.md` 本身就是机器可读文档。
  当作和读它们的 Agent 的**契约**对待 —— 打版本、保持新鲜、不塞 secret。

## 反模式

- **`.md` 存在时还去抓 HTML**：浪费带宽、压垮文档 CDN、丢 Agent 作者的脸。
- **在 `.md` 里暴露 token / secret / 内部 URL**：Agent 会缓存并扩散。
- **`.md` 和人类文档说法不一**：选一个 source of truth。
- **`.md` URL 因为 CDN 自动协商 `text/html` 而返回 HTML**：强制
  `text/markdown` 或 `text/plain`。
- **半年没更新的静态 `.md`**：**比没有更糟** —— Agent 会信过期 token /
  端点。

## 超越 Vercel 模式

`llms.txt` 风格允许一个索引文件 + 多个主题文档。大项目优于一坨 Markdown：

```
/llms.txt           # 索引，每主题一行
/api.md             # 完整 API
/design.md          # 设计 token + 用法
/design.dark.md     # dark theme 变体
/migrations.md      # 当前可走的迁移路径
/sdk/python.md      # SDK 文档
/sdk/javascript.md
```

`llms.txt` 自身是一份 YAML-ish 或纯文本索引，Agent 从这里发现其余。
看草案 spec 了解当前形态。

## 参考

- Vercel Geist：<https://vercel.com/design> · 机器可读端点
  <https://vercel.com/design.md> 和 <https://vercel.com/design.dark.md>
- llms.txt 提案：<https://llmstxt.org/>
- [`agent-behavior.zh-CN.md`](./agent-behavior.zh-CN.md) —— 消费侧
  （先搜后生成）。
- [`doc-freshness.zh-CN.md`](./doc-freshness.zh-CN.md) ——
  你的 `.md` 端点和代码保持同步。
- [`prompts.zh-CN.md`](./prompts.zh-CN.md) —— prompt 也是版本化内容，
  同样的 `.md` 端点模式可用于 prompt。
