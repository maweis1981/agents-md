---
name: ai-native-database
description: Use when editing database schema, generating migrations, or configuring DB connection strings — enforces direct-connection migrations, pooled-connection runtime, aggregated schema changes, and Neon-style branch usage. TRIGGER on changes to prisma/, drizzle/, migrations/, schema.*, or DATABASE_URL config.
---

# AI-Native Database

Apply this skill whenever you touch schema, migrations, or database
connection configuration. Bad DB hygiene from agents is the fastest
way to break production.

## Hard rules

1. **Migrations run on a DIRECT connection.** Never through a pooled
   one.
2. **App runtime uses a pooled connection.** Especially serverless /
   edge runtimes.
3. **Aggregate schema changes.** No "one migration per prompt".
4. **Database branches (e.g. Neon) are not Git branches.** Don't try
   to "merge" them.
5. **Never `DROP TABLE` / `DROP COLUMN` without an explicit deprecation
   window.**

## Connection config

```dotenv
# Runtime — pooled (PgBouncer / Neon pooled endpoint)
DATABASE_URL=postgres://user:pwd@pooler.host/db?pgbouncer=true

# Migrations — direct
DIRECT_URL=postgres://user:pwd@direct.host/db
```

### Prisma

```prisma
datasource db {
  provider  = "postgresql"
  url       = env("DATABASE_URL")   // pooled, runtime
  directUrl = env("DIRECT_URL")     // direct, migrations
}
```

### Drizzle

- Migrator: connect with the direct URL.
- App client: connect with the pooled URL.

## Why direct for migrations

Pooled connections in transaction mode break:

- `CREATE INDEX CONCURRENTLY`
- Advisory locks
- Session-scoped settings
- Transactional DDL when consecutive statements get different
  backend connections.

## Migration discipline

Before generating a migration, ask:

1. Can these schema changes be **batched** with other in-flight
   changes? If yes, batch.
2. Is each step **reversible**, or is rollback documented?
3. Does any step lock a hot table for an unbounded time? If yes,
   prefer a concurrent / online variant.
4. Is the app deploy that needs the new schema **gated** on the
   migration completing?

## Forbidden patterns

- Running `prisma migrate dev` after every schema edit during agent
  exploration. Stage the changes locally, migrate once.
- Pointing migrations at the pooled URL because "it works in
  development".
- Holding a long-lived DB connection from a serverless function.
- Treating a Neon branch as a Git-mergeable workspace.

## Allowed patterns

- One DB branch per PR / preview deploy, torn down on close.
- "Import branch becomes production": swap `DATABASE_URL` to the new
  branch and decommission the old one.
- Background workers connecting via the pool, not directly.

## Migration safety checklist

- [ ] Migration tested against a Neon branch / staging DB.
- [ ] Reversible (or rollback documented).
- [ ] No unbounded locks.
- [ ] App deploy gated on migration completion.
- [ ] Old schema only dropped *after* the app version that needed it
      is fully decommissioned.

## Reference

`docs/database.md` in the agents-md repo for the full rationale.
