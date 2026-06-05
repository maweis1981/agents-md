# AI 驱动团队的 DORA 指标

> 跟踪同样的四个指标 —— 但按 AI 节奏诚实地重定义其中两个。
> English: [`dora.md`](./dora.md)

DORA 四指标（部署频率、变更前置时间、变更失败率、平均恢复时间）原本是给
人类主导团队定义的。AI 驱动的开发会让其中两个**字面意义失真**。四个都要
跟，但用下面的修正定义。

## 四指标的 AI 修正版

| 指标 | 经典定义 | AI 修正定义 | 为什么 |
| --- | --- | --- | --- |
| **部署频率** | 团队多久部署一次生产。 | `main` 多久部署一次生产。 | Agent push 频率不进 `main` 就没意义。规范本来就强制"仅 main 上生产"。 |
| **变更前置时间** | 第一次 commit 到部署的时间。 | PR 打开到部署的时间。 | `ai/` 分支上的第一次 commit 太早，不是有意义的起点。**PR 打开**才是"准备上生产"的信号。 |
| **变更失败率** | 部署导致故障 / 回滚的占比。 | 同 —— 但**分开**统计 AI 作者 PR 和人类作者 PR。 | 如果 AI 的失败率是人类的 3 倍，你就知道该在哪儿投入 review。 |
| **平均恢复时间 (MTTR)** | 从故障到恢复的时间。 | 同。 | 不变 —— 故障不关心代码谁写的。 |

## 另外两个值得一起跟的指标

不属于 DORA，但直接反映 AI 团队健康度：

| 指标 | 告诉你什么 |
| --- | --- |
| **PR 垃圾 commit 比** | squash 前包含禁用 message（`wip` / `fix` 等）的 PR 占比。高 = Agent commit 太勤。 |
| **首推 eval 通过率** | 改 prompt 的 PR 在不调阈值时 eval 直接通过的占比。低 = prompt 上线时未充分验证。 |

## 起步目标区间（不是教条）

基于公开 DORA 报告分档，按 AI 场景轻度调整：

| 档位 | 部署频率 | 前置时间 | CFR | MTTR |
| --- | --- | --- | --- | --- |
| Elite | 每天多次 | < 1 小时 | 0–15% | < 1 小时 |
| High | 日–周 | 1 天–1 周 | 16–30% | < 1 天 |
| Medium | 周–月 | 1 周–1 月 | 16–30% | < 1 周 |
| Low | < 每月 | > 1 月 | > 30% | > 1 周 |

AI 驱动团队**通常**在部署频率和前置时间上提升，**但变更失败率会退化**
——除非规范被严格落地。**显式跟 CFR 是早期预警**。

## 怎么算

便宜的开始 —— 哪怕 Elite 团队也是从电子表格起步，不是 dashboard：

```sql
-- 部署频率
SELECT DATE_TRUNC('week', deployed_at) AS week, COUNT(*) AS deploys
FROM deployments
WHERE environment = 'production' AND status = 'success'
GROUP BY 1;

-- 前置时间
SELECT
  AVG(EXTRACT(EPOCH FROM (deployed_at - pr_opened_at))/3600) AS avg_hours
FROM deployments
JOIN prs USING (commit_sha)
WHERE deployed_at >= NOW() - INTERVAL '30 days';

-- 变更失败率
SELECT
  100.0 * SUM(CASE WHEN caused_incident THEN 1 ELSE 0 END) / COUNT(*) AS cfr_pct
FROM deployments
WHERE deployed_at >= NOW() - INTERVAL '30 days';
```

在表格里盯一个季度，**再**搭 dashboard。

## 数字用来做什么

- **每周快速过**四个指标。每指标 3-4 个数据点足够看到趋势。
- **每月深挖** —— 把 AI 作者和人类作者两条线分开，看差距是否扩大。
- **每季度调目标** —— 两季度稳定 Elite 就抬杠；倒退就找瓶颈。

## 反模式

- **单点优化一个指标**：提升部署频率靠上线坏代码，会毁掉其他三个。
- **把 AI 作者的失败藏在汇总里**：诚实用 label / 分支前缀拆开。
- **MTTR < 1 小时当作韧性证明**：可能只是你被 page 得很多。

## 参考

- [Google 的 DORA 研究](https://dora.dev/)
- [`pull-request.zh-CN.md`](./pull-request.zh-CN.md) —— PR 打开
  作为前置时间起点。
- [`observability.zh-CN.md`](./observability.zh-CN.md) ——
  事故 / 恢复时间戳的来源。
- [`evals.zh-CN.md`](./evals.zh-CN.md) —— Eval 通过率是 AI 专属的
  可靠性视角。
