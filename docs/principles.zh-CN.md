# 核心原则

> 后续所有章节都是这三条原则的衍生。
> English: [`principles.md`](./principles.md)

## 原则 1 —— AI 可以频繁修改，系统不能频繁提交。

最重要的一条。其余的都是它的推论。

- *修改*（改文件、跑工具、重写函数）是本地的，便宜、可逆。
- *commit / push / merge / deploy / migrate* 是跨系统的，昂贵、可观测，
  而且不一定可逆。

AI Agent 的天然节奏踩错了轴：它想以修改的速度提交。
我们要在「本地活动」与「系统可见状态」的边界上**显式刹车**。

## 原则 2 —— Commit 是稳定快照，不是思考过程。

一次有效的 commit 回答的是：**"在这次变更之后，系统处于哪个稳定状态？"**

它不回答：**"Agent 在第 14 分钟在想什么？"**

推论：commit message 描述**结果能力**（"complete onboarding workflow"），
而不是**过程**（"fix typo, retry, fix import, retry, fix padding"）。

## 原则 3 —— 先复用，再生成。

写新组件、util、schema、prompt 之前，Agent 必须先搜索是否已有同类实现。
默认行为应该是：

1. 找到已有实现；
2. 如果差不多，扩展它；
3. 真正没有，再创建。

为什么：AI Agent 天生偏向 "生成"。没有这条规则，每个 prompt 都会产生
和已有东西高度相似的近似复制品，永久放大维护面。

## 与其他章节的关系

- 分支、push、PR 规则 —— 强制执行原则 1。
- Commit message 规则 —— 强制执行原则 2。
- Agent 行为规则 —— 强制执行原则 3。

如果整个仓库只能记住三条，就记这三条。
