# Serverless 与 AI Infra

> 本规范默认的运行时姿态。
> English: [`serverless.md`](./serverless.md)

## 默认姿态：事件驱动 + scale-to-zero

本规范假定（并推荐）的基础设施是：

- 负载由**事件触发**（消息、webhook、队列条目、cron），不是常驻进程。
- 闲时**计算 scale to zero**。
- 闲时**数据库 scale to zero**。
- API endpoint **无状态**且**短生命周期**。

这套姿态正好匹配 AI 驱动开发的经济模型：**突发、长时间空闲、偶尔变热**。
常驻基础设施会在等下一个 prompt 时持续烧钱。

## 规则

### 1. AI Workflow 优先事件驱动

允许的触发源：

- 队列消息（SQS、Cloud Tasks 等）
- Webhook（GitHub、Stripe、自己的应用）
- Cron / 定时事件
- 产品里的用户行为

禁止：

- 常驻 Agent —— `while (true) { ... }` 永远跑。
- 长 polling 循环占住 scale-to-zero 服务的连接。

如果**必须**跑常驻 worker，显式记录理由，并把它和 scale-to-zero 部分隔离。

### 2. 数据库必须支持 scale-to-zero

推荐：Neon / Turso / PlanetScale 或等价产品。

Scale-to-zero DB 的定义：

- 没查询时计算休眠。
- 有查询时几秒内恢复。
- 仅在活跃时计费。

常驻 Postgres / MySQL 集群对高流量应用是 OK 的，但对原型和 AI 侧项目，
它是「为什么没用户每月也烧 200 美金」的最大单一原因。

### 3. API 无状态

- 短连接，请求 → 响应 → 关闭。
- 不依赖"同进程服务下一个请求"的内存缓存。
- 请求 handler 不持长生命周期 DB 连接，走 pool。

### 4. 后台工作走队列

不要在 HTTP handler 里 `setInterval`。不要在请求里 fire-and-forget。
把工作 enqueue、返回响应、由 worker 处理。

运行时没有队列，就用托管的（SQS、Cloud Tasks、Inngest、QStash 等）。

## 诚实面对 Tradeoff

Scale-to-zero 不是免费午餐：

- **冷启动**：空闲后第一个请求会多 100ms–2s 延迟，用户面应用要权衡。
- **连接池预热**：第一次 DB 查询同样有延迟。
- **某些库不适合 serverless**：依赖长进程或内存状态的库会出错。

延迟敏感时，给*关键路径*留一个 warm 实例，其他走 scale-to-zero。
**别把 scale-to-zero 当宗教。**

## 推荐组件

- **计算**：Vercel Functions / Cloudflare Workers / AWS Lambda /
  Google Cloud Run。
- **DB**：Neon / Turso / PlanetScale / Supabase（用 pooled endpoint）。
- **队列**：Inngest / QStash / AWS SQS / GCP Cloud Tasks。
- **向量**：pgvector（Neon 内置）/ Turbopuffer / Pinecone（迫不得已）。
- **Auth**：托管方案（Clerk / Auth.js / Supabase auth）。

以上是**推荐**，不是强制。选符合团队的等价物即可。
