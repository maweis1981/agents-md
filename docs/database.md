# Database

> Rules for AI-driven schema changes, migrations, and connections.
> Targets Neon / PostgreSQL but most rules apply to any managed DB.
> 中文：[`database.zh-CN.md`](./database.zh-CN.md)

## Hard rules

1. **Migrations run on a direct connection.** Never through a pooled
   connection.
2. **App runtime uses a pooled connection.** Especially serverless /
   edge runtimes.
3. **No "one migration per prompt".** Aggregate schema changes, then
   migrate once.
4. **Don't conflate database branches with Git branches.**
5. **Don't try to "merge" a DB branch into another.** Swap the
   `DATABASE_URL` instead.

## Why direct connections for migrations

Pooled connections (PgBouncer in transaction mode, Neon's pooled
endpoint, RDS proxy, etc.) rewrite the protocol in ways that break
migrations:

- They don't reliably support `CREATE INDEX CONCURRENTLY`, advisory
  locks, or session-scoped settings.
- They can route consecutive statements to different backend
  connections, breaking transactional DDL.

Migrations should connect directly to the database:

```
# .env
DATABASE_URL=postgres://...?pgbouncer=true  # runtime, pooled
DIRECT_URL=postgres://...                   # migrations, direct
```

Prisma and Drizzle both support this split. Use it.

## Why pooled for runtime

Serverless / edge functions can spin up thousands of concurrent
invocations. Each one opening a fresh direct DB connection will
exhaust the connection limit immediately. Pooled connections share
backends across invocations and are the only sane choice for
short-lived runtime.

## Aggregating migrations

Forbidden flow:

```
prompt 1 → schema change → migration
prompt 2 → schema change → migration
prompt 3 → schema change → migration
...
```

Recommended flow:

```
prompt 1..N → schema changes accumulate locally
            → review the aggregated migration
            → migrate once
```

A migration is a contract with production. Treat it with the same
respect as a `main` commit.

## Neon branches are not Git branches

Neon (and similar scale-to-zero Postgres) lets you "branch" the
database, which means *a point-in-time copy-on-write fork of the DB*.

This is **not** a Git branch:

- It cannot be merged back.
- It does not have a diff in the Git sense.
- It exists to give a feature branch / preview deploy / test run its
  own database, isolated from production data.

Patterns that work:

- **One DB branch per PR / preview deploy.** Tear down on close.
- **Import branch → production.** When the schema/data is ready,
  swap `DATABASE_URL` to point at the new branch. Done.

Patterns that do not work:

- "Merge" two DB branches.
- Use a DB branch as a long-lived feature workspace then expect Git
  to reconcile it.

## Migration safety checklist

Before any migration lands on production:

- [ ] The migration has been verified on a Neon branch (or staging DB).
- [ ] The migration is reversible, or the rollback path is documented.
- [ ] No `DROP TABLE` / `DROP COLUMN` without an explicit deprecation
      window.
- [ ] Index changes use `CREATE INDEX CONCURRENTLY` (and therefore run
      via direct connection).
- [ ] The app deploy that *needs* the new schema is gated on the
      migration completing.
- [ ] The app deploy that *no longer needs* the old schema has fully
      rolled out before the old schema is dropped.

## DB tooling notes

- **Prisma**: use `DATABASE_URL` (pooled) + `directUrl` (direct).
- **Drizzle**: use the migrator with a direct URL; the app with a pooled
  client.
- **Neon**: use the pooled endpoint for runtime, the direct endpoint
  for migrations.
