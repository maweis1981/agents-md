# 数据库规范

> AI 驱动的 schema 变更、migration 与连接规则。
> 面向 Neon / PostgreSQL，多数规则适用于任意托管数据库。
> English: [`database.md`](./database.md)

## 硬性规则

1. **Migration 必须走 direct connection**，不允许 pooled。
2. **应用 runtime 用 pooled connection**，尤其是 serverless / edge。
3. **不允许"一次 prompt 一次 migration"**：先聚合 schema 变更，
   再统一 migrate。
4. **不要把数据库分支和 Git 分支混为一谈。**
5. **不要试图把一个 DB branch "merge" 到另一个**，直接切 `DATABASE_URL`。

## 为什么 Migration 必须 direct connection

Pooled connection（事务模式的 PgBouncer / Neon pooled endpoint /
RDS proxy 等）重写协议时会破坏 migration：

- 它们对 `CREATE INDEX CONCURRENTLY`、advisory lock、session 级 setting
  的支持不可靠。
- 它们会把相邻语句路由到不同后端连接，破坏事务型 DDL。

migration 必须直连数据库：

```
# .env
DATABASE_URL=postgres://...?pgbouncer=true  # runtime，pooled
DIRECT_URL=postgres://...                   # migration，direct
```

Prisma 和 Drizzle 都支持这种拆分，使用它。

## 为什么 Runtime 必须 pooled

Serverless / edge 函数能在瞬间拉起几千个并发实例。每个都开一个新的直连，
连接数立刻打满。Pooled 共享后端连接，是短生命周期 runtime 的唯一理智选择。

## 聚合 Migration

禁止：

```
prompt 1 → schema 变更 → migration
prompt 2 → schema 变更 → migration
prompt 3 → schema 变更 → migration
...
```

推荐：

```
prompt 1..N → schema 变更累积在本地
            → review 聚合后的 migration
            → 一次 migrate
```

Migration 是和生产环境之间的契约，按 `main` commit 的标准对待。

## Neon Branch 不是 Git Branch

Neon（以及同类 scale-to-zero Postgres）支持"分支"数据库，
本质是**时间点的 copy-on-write 数据库副本**。

它**不是** Git 分支：

- 不能合回去。
- 不存在 Git 意义上的 diff。
- 存在的意义是给一个 feature branch / preview deploy / 测试运行
  一份独立的数据库，与生产数据隔离。

可行的用法：

- **一个 PR / preview 部署一个 DB branch**，关闭时销毁。
- **Import branch → production**：schema/数据准备好后，把
  `DATABASE_URL` 切到新 branch，结束。

不可行的用法：

- "Merge" 两个 DB branch。
- 把 DB branch 当成长生命周期的 feature 工作区，再指望 Git 帮你调和它。

## Migration 安全 checklist

任何 migration 上生产之前：

- [ ] 已经在 Neon branch（或 staging DB）上验证。
- [ ] migration 可逆，或回滚路径已显式记录。
- [ ] 没有未经过弃用期的 `DROP TABLE` / `DROP COLUMN`。
- [ ] 索引变更用 `CREATE INDEX CONCURRENTLY`（因此必须走 direct connection）。
- [ ] *依赖新 schema 的*应用 deploy 在 migration 完成后才放行。
- [ ] *不再需要旧 schema 的*应用 deploy 全量上线后，才能 drop 旧 schema。

## 工具说明

- **Prisma**：`DATABASE_URL`（pooled）+ `directUrl`（direct）。
- **Drizzle**：migrator 用 direct URL，应用用 pooled client。
- **Neon**：runtime 用 pooled endpoint，migration 用 direct endpoint。
