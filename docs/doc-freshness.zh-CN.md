# 文档新鲜度

> "下个 PR 再补文档" 是文档变错的根源。
> English: [`doc-freshness.md`](./doc-freshness.md)

AI Agent 特别擅长写代码但不更新相关文档。本章规则强制让文档更新
**在同一个 PR 里发生**。

## 硬性规则

1. **改了文档化区域的代码必须同 PR 改文档**，**不是**"下一个 PR"。
2. **文档进 diff，或在 PR 描述里解释为何无需文档变化**。reviewer 把关。
3. **文档和代码通过 path 绑定**，不靠感觉。CI 在"被追踪代码路径变了
   但对应文档路径没变"时 fail。
4. **过期文档直接删**，不保留作为"历史好奇心"。

## 把代码路径绑到文档路径

在仓库根用一个配置文件定义耦合：

```yaml
# .doc-coupling.yml
couples:
  - code: app/api/billing/**
    docs: docs/billing.md
    severity: error

  - code: prompts/**
    docs:
      - prompts/README.md
      - docs/prompts.md
    severity: error

  - code: prisma/schema.prisma
    docs:
      - docs/database.md
      - docs/schema-changelog.md
    severity: warn

  - code: lib/auth/**
    docs: docs/auth.md
    severity: error
```

一段小脚本读 PR 改动的文件 + 这份配置，在 `severity: error` 的
couple 里"代码改了但文档没改（或反过来）"时 fail。

脚本骨架，接到你的 `lint` workflow：

```bash
#!/usr/bin/env bash
# scripts/check-doc-freshness.sh
changed=$(git diff --name-only "origin/${BASE:-main}"..HEAD)
yq '.couples[]' .doc-coupling.yml | while read -r couple; do
  code_glob=$(yq '.code' <<<"$couple")
  doc_paths=$(yq '.docs[]?, .docs?' <<<"$couple")
  severity=$(yq '.severity // "error"' <<<"$couple")
  # ... 把 changed 与 code_glob / doc_paths 对照
done
```

（按你的 YAML 工具适配，重点是**要有这个 check**，不在具体代码。）

## 该耦合什么

新鲜度检查的代价是误报率。**只**耦合满足这些的路径：

- 文档对未来开发者有实质帮助。
- 代码路径每月以上的变化频率。
- 一份错文档会误导下次读它的 AI Agent。

不要把所有文件都耦合，**挑承重墙**。

## 过期文档：删

如果一份文档描述的东西在代码里已不存在：

- 删掉。
- **不要**"留着当上下文"或"标 deprecated 永远不动"。
- 错误文档比没文档更糟，因为 Agent 和人都会相信它。

每季度扫一次可接受，每年扫太稀。

## 不严格耦合时的新鲜度信号

哪怕不写 `.doc-coupling.yml`，也能浮出过期：

- **修改时间差**：12 个月没动的文档对应过去 1 个月动过的代码 ——
  多半已过期。
- **引用腐烂**：文档里提到的文件/函数/路由已不存在 —— 链接/符号 check fail。
- **入链孤儿**：没任何文档引用的文档，多半读者也走不到 —— 决定保留前调查。

按工具栈接其中之一。**就算只做季度人工 review，也好过没有**。

## 当规则和开发者打架

确实会有"文档更新独立成工作"的 PR（比如向新范式迁移，文档放在专门跟进 PR）。
这种情况：

- 开 tracking issue。
- 在当前 PR 描述里引用该 issue。
- 把"那个 issue 关掉"列为下一个 minor release 的卡点。

**例外允许，隐形不允许**。

## 参考

- [`agent-behavior.zh-CN.md`](./agent-behavior.zh-CN.md) §1 ——
  先搜再生成（搜的过程经常浮出过期文档）。
- [`codeowners.zh-CN.md`](./codeowners.zh-CN.md) —— 文档 owner 应在
  CODEOWNERS 里，耦合改动时会被 ping 到。
