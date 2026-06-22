# Machine-Readable Vendor Docs

> Vendors are starting to publish their docs as Markdown at
> well-known URLs so AI agents can fetch them directly. Treat these
> as canonical references; produce your own when you're the vendor.
> 中文：[`machine-readable-docs.zh-CN.md`](./machine-readable-docs.zh-CN.md)

A small but durable convention is emerging: instead of (or alongside)
their human-facing docs site, a vendor exposes a Markdown file at a
predictable URL — `/llms.txt`, `/design.md`, `/api.md`, etc. AI
agents fetch the Markdown directly, no scraping, no HTML parsing,
no rate limits from the docs CDN.

This chapter codifies the convention as it applies to:

1. **Consuming**: when your agent needs vendor information, fetch
   the machine-readable URL first.
2. **Producing**: when your project is the vendor, expose your own
   docs the same way.

Most readers of this repo will do both.

## Live examples

- **Vercel Geist** — Vercel publishes its complete design system as
  Markdown:
  - <https://vercel.com/design.md> — light theme tokens + guidance
  - <https://vercel.com/design.dark.md> — dark theme variant

  A page renders the human-readable design system; the `.md`
  endpoints expose the same data as tokens + prose for AI agents
  building UI against Geist.

- **`llms.txt` proposal** — Jeremy Howard's draft convention for
  vendors to expose a `/llms.txt` index plus per-topic `.md` files.
  Adopted by a growing list of doc sites; not yet a formal standard
  but converging.

- **This repo** — `STANDARDS.md`, `CLAUDE.md`, `AGENTS.md`, the
  per-chapter `docs/*.md` and `skills/*/SKILL.md` are themselves
  machine-readable docs at predictable paths. We eat our own dogfood.

## Consumer rules

When an agent needs vendor information (design tokens, API surface,
config schema, glossary), it must:

1. **Check for a machine-readable doc first.** Try the obvious URLs:
   - `<vendor-site>/llms.txt`
   - `<vendor-site>/design.md` / `design.dark.md`
   - `<vendor-site>/<topic>.md`
   - `<docs-site>/llms-full.txt`

2. **Pin to a version when possible.** Vendors update these. Pin
   via tag, commit SHA, or `Last-Modified` header so your agent's
   output is reproducible.

3. **Cache aggressively.** Treat these like build inputs. Don't
   re-fetch on every prompt.

4. **Fall back to HTML scraping only as a last resort.** Scraping
   docs sites is fragile, slow, and rude (CDN load). Prefer the
   `.md` endpoint even when it has less detail.

5. **Never rely on machine-readable docs for security-sensitive
   facts** (auth flows, rate-limit values, etc.). Confirm against
   the human-facing docs and the API itself.

## Producer rules

If your project ships SDK, design tokens, configuration schema, or
methodology that AI agents will consume:

1. **Expose a `.md` endpoint** at a predictable URL. Two patterns
   work:
   - **Per-topic**: `/design.md`, `/api.md`, `/config-schema.md`.
     Easy to author, easy to cache, easy to version.
   - **Index + topics** (per the `llms.txt` proposal): `/llms.txt`
     listing the topics; each topic at its own `.md`.

2. **Keep the `.md` and the human-rendered version in sync.** Same
   source ideally. Drift is worse than no `.md` at all.

3. **Pin version explicitly** at the top of every `.md`:

   ```
   # Geist Design System: Overview
   version: 2.4.0
   updated: 2026-06-01
   ```

   Agents that pin against your `.md` can revalidate cheaply.

4. **Don't ship secrets, internal-only paths, or breaking changes
   without warning.** A `.md` URL is at least as public as your
   docs site, often more (because agents will cache and republish).

5. **Include a `User-Agent` allowlist if needed**, but don't gate
   access. The whole point is friction-free fetching.

6. **Version the URL itself**, not just the content. Once
   `/design.md` represents v2, host the v1 schema at
   `/v1/design.md`. Older agent pins shouldn't break.

## Where this fits in the spec

- The "search before generating" rule
  ([`agent-behavior.md`](./agent-behavior.md) §1) is what makes
  consuming machine-readable docs natural. Before generating UI
  styles, search the vendor's `.md` endpoint *first*.
- The "doc freshness" rule ([`doc-freshness.md`](./doc-freshness.md))
  applies double-strength when your `.md` is being consumed by AI:
  drift between code and `.md` becomes systematic agent error.
- `CLAUDE.md` and `AGENTS.md` at your repo root are themselves
  machine-readable docs. Treat them as a contract with the agents
  reading them — versioned, kept fresh, no secrets.

## Anti-patterns

- **Scraping HTML when a `.md` exists.** Wastes bandwidth, rate-limits
  the docs CDN, embarrasses the agent author.
- **Exposing tokens / secrets / internal URLs in the `.md`.** Agents
  will cache and republish.
- **A `.md` that disagrees with the human docs.** Pick one source
  of truth.
- **Returning HTML from the `.md` URL** because your CDN auto-detects
  `text/html` accept headers. Force `text/markdown` or `text/plain`.
- **Static `.md` from six months ago, never updated.** Worse than
  no `.md`. Agents will trust outdated tokens / endpoints.

## Going beyond Vercel's pattern

The `llms.txt` style allows a single index file plus per-topic docs.
For a large project, this is better than one giant Markdown blob:

```
/llms.txt           # index, one line per available topic
/api.md             # full API surface
/design.md          # design tokens + usage
/design.dark.md     # dark theme variant
/migrations.md      # current migration paths
/sdk/python.md      # SDK-specific docs
/sdk/javascript.md
```

`llms.txt` itself is a YAML-ish or plain-text index agents can
discover the rest from. See the draft spec for current shape.

## Reference

- Vercel Geist: <https://vercel.com/design> · machine-readable at
  <https://vercel.com/design.md> and <https://vercel.com/design.dark.md>
- llms.txt proposal: <https://llmstxt.org/>
- [`agent-behavior.md`](./agent-behavior.md) — the consumer side
  (search before generating).
- [`doc-freshness.md`](./doc-freshness.md) — keeping your `.md`
  endpoints in sync with the code they describe.
- [`prompts.md`](./prompts.md) — prompts as versioned content; the
  `.md` endpoint pattern works for prompts too.
