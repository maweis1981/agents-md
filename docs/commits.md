# Commits

> Commit frequency, granularity, and message format for AI-driven work.
> 中文：[`commits.zh-CN.md`](./commits.zh-CN.md)

## What a commit is

A commit is a **stable snapshot** of the system. It is what someone
who pulled this exact SHA would see as a coherent, reasonable state.

It is **not** a frame of the agent's thinking. It is **not** a
checkpoint of an unfinished attempt.

## Frequency

- Forbidden: committing on every file modification.
- Forbidden: committing on every prompt iteration.
- Recommended: **one commit per stable, coherent feature**.

If a feature legitimately needs two commits (e.g. "schema migration"
+ "code that uses the new schema"), make each commit independently
coherent. Each commit must be something you'd be comfortable rolling
back to.

## Granularity

### Good

- `feat: complete onboarding workflow`
- `feat: implement ai memory system`
- `feat: implement vector search pipeline`
- `refactor: simplify auth middleware`

### Bad

- `fix typo`
- `fix padding`
- `update prompt`
- `change color`
- `fix import`

If your last five commits could be rolled into one and the result
would be *more* understandable, the commits were too small.

## Message format

Conventional Commits, plain and English:

```
type: short imperative summary
```

`type` ∈ {`feat`, `fix`, `refactor`, `docs`, `chore`, `test`, `perf`,
`build`, `ci`}.

Optional scope:

```
type(scope): summary
docs(zh-CN): align database section
fix(auth): handle expired refresh token
```

Optional body — wrap at ~72 columns, explain *why* if not obvious from
the summary:

```
feat: implement vector search pipeline

We index embeddings in pgvector with HNSW and query through
Prisma. Queries that previously took ~500ms now run in ~30ms.
```

### Hard ban list

These messages are never acceptable:

```
update
fix
changes
wip
tmp
asdf
.
test
new
```

Most of them mean "I committed too early".

## Co-authorship and provenance

If a commit was authored or co-authored by an AI agent, it's good
practice (but not mandatory by this spec) to record it:

```
feat: complete onboarding workflow

Co-Authored-By: Claude <noreply@anthropic.com>
```

Some projects choose to *omit* AI co-authorship from public history.
Both choices are valid; pick one and apply it consistently. This
repository does not encode a preference.

## Practical tips

- Set the agent's "commit" tool/command to be **manual only**. No
  auto-commit on save, no auto-commit on tool success.
- When you do commit, look at `git status` and `git diff --staged`
  yourself. If you can't explain the diff in one sentence, the diff
  is too big.
- Use `git stash` and local feature branches for intermediate states.
  The remote does not need them.
