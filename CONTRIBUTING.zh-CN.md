# 贡献指南

感谢考虑给 **agents-md** 提 PR。
这是一个纯文档仓库，定义的就是 AI 驱动贡献应当如何进行 ——
所以我们以身作则。

English: [`CONTRIBUTING.md`](./CONTRIBUTING.md)

## 我们接受什么

- **错别字 / 措辞修订** —— 永远欢迎。
- **翻译** —— 新增语言版本，或改进现有的中英两版。
- **新增 Skill** —— `skills/` 下，单触发、聚焦的 Skill 包。
- **新增模板** —— `templates/` 下，给下游项目用的可拷贝文件
  （其他 CI 平台、其他 Agent、其他语言）。
- **规范澄清** —— 改变语义的规则请先开 issue / discussion 讨论。
- **Bug 报告** —— 失效链接、错误示例、章节之间的矛盾。

## 暂不接受

- 新增本仓没有的顶层目录。
- 构建工具链（`package.json` / `pnpm-lock.yaml` 等）。纯 Markdown 就是构建。
- 把源码示例打包进本仓。未来可能开 `examples/` 单独仓，但不在这里。

## 如何贡献（本仓内部）

本仓自身也受它所定义的规范约束：

1. **分支**：Agent 驱动用 `ai/<feature>`；人类驱动用你团队的常用前缀。
2. **修改**：本地多轮迭代，不要每次保存就 push。
3. **Commit**：Conventional Commits —— `docs:` / `feat:` / `fix:` /
   `refactor:`。一个 coherent 的变更一次 commit。
4. **中英同步**：`docs/<topic>.md` 的任何语义变化必须同步到
   `docs/<topic>.zh-CN.md`，反之亦然。无法翻译时加 `TODO(i18n)` 并在
   PR 描述里指出。
5. **PR**：默认开 **draft**，ready 之后再请求 review。一个 PR 一个 feature。
6. **Merge**：squash merge 进 `main`。仓库设置强制如此。

## 一个好的 PR 长什么样

- 一个目的，一句话能说清。
- 改一节内容 / 一个 skill，而不是三件事一起改。
- 中英两版保持同步。
- 改名或移动文件后，相关交叉链接已更新。
- 新增示例时，自己以 Agent 身份重读一遍。

## 提问题

用 GitHub Discussions / Issues。
动手前 30 秒发一句"我想做 X，怎么看？"，能避免之后大段 rebase。

## 行为准则

所有参与受 [Code of Conduct](./CODE_OF_CONDUCT.md) 约束。
