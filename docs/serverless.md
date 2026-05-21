# Serverless & AI Infra

> The runtime posture this spec assumes.
> 中文：[`serverless.zh-CN.md`](./serverless.zh-CN.md)

## Default posture: event-driven, scale-to-zero

The spec assumes — and recommends — an infrastructure where:

- Workloads are **triggered by events** (messages, webhooks, queue
  items, cron), not by always-on processes.
- Compute **scales to zero** when idle.
- Databases **scale to zero** when idle.
- API endpoints are **stateless** and **short-lived**.

This posture matches the economics of AI-driven development: highly
bursty, often idle, occasionally hot. Always-on infrastructure burns
money waiting for the next prompt.

## Rules

### 1. AI workflows are event-driven first

Allowed triggers:

- Messages on a queue (SQS, Cloud Tasks, etc.)
- Webhooks (GitHub, Stripe, your own app)
- Cron / scheduled events
- User actions in the product

Forbidden:

- Resident agents — `while (true) { ... }` style loops running forever.
- Long-polling loops holding connections to scale-to-zero services.

If you *must* run a persistent worker, document why explicitly and
isolate it from the scale-to-zero parts of the stack.

### 2. Databases must support scale-to-zero

Recommended: Neon, Turso, PlanetScale, or equivalent.

A scale-to-zero DB is one that:

- Hibernates compute when no queries arrive.
- Resumes within seconds when a query does arrive.
- Bills compute only while active.

Always-on Postgres / MySQL clusters are fine for high-traffic apps,
but for prototypes and AI-side-projects they are the single biggest
source of "why is my bill $200/mo with no users".

### 3. APIs are stateless

- Short connections, request → response → close.
- No persistent in-memory caches that assume the same process serves
  the next request.
- No long-lived DB connections from request handlers — use the pool.

### 4. Background work goes through a queue

Don't `setInterval` from an HTTP handler. Don't fire-and-forget
promises from inside a request. Enqueue work, return the response,
let a worker process it.

If your runtime doesn't have a queue, use a managed one (SQS, Cloud
Tasks, Inngest, QStash, etc.).

## Tradeoffs to be honest about

Scale-to-zero isn't free:

- **Cold starts** add 100ms–2s of latency on the first request after
  idle. For user-facing apps, this matters.
- **Connection pool warmup** can add similar latency on the first DB
  query.
- **Some libraries don't behave well in serverless** — anything that
  assumes a long-lived process or in-memory state will misbehave.

When latency matters, keep a warmed instance running for the
*latency-critical* path, and use scale-to-zero for everything else.
Don't make scale-to-zero a religion.

## Recommended building blocks

- **Compute**: Vercel Functions, Cloudflare Workers, AWS Lambda,
  Google Cloud Run.
- **DB**: Neon, Turso, PlanetScale, Supabase (with pooled endpoint).
- **Queues**: Inngest, QStash, AWS SQS, GCP Cloud Tasks.
- **Vector**: pgvector (in Neon), Turbopuffer, Pinecone (if you must).
- **Auth**: managed providers (Clerk, Auth.js, Supabase auth).

This is a *recommendation*, not a requirement. Pick equivalents that
fit your team.
