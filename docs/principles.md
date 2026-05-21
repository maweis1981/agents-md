# Core Principles

> The three principles every later chapter falls out of.
> 中文：[`principles.zh-CN.md`](./principles.zh-CN.md)

## Principle 1 — Agents may modify frequently. Systems may not commit frequently.

The single most important rule. Everything else is a consequence.

- *Modification* (edit a file, run a tool, regenerate a function) is
  local. It is cheap and reversible.
- *Commit / push / merge / deploy / migrate* is system-wide. It is
  expensive, observable, and not always reversible.

An AI agent's natural cadence sits on the wrong axis: it wants to
commit at the speed it modifies. The agent must be slowed at exactly
the boundary between local activity and system-visible state.

## Principle 2 — A commit is a stable snapshot, not a thought process.

A useful commit answers: *"what is the system, in a coherent state,
after this change?"*

It does not answer: *"what was the agent thinking at minute 14 of its
session?"*

The corollary: commit messages describe the *resulting capability*
("complete onboarding workflow"), not the *journey* ("fix typo, retry,
fix import, retry, fix padding").

## Principle 3 — Reuse before generation.

Before producing a new component, util, schema, or prompt, an agent
must search for an existing one. Default behavior should be:

1. Find existing implementation.
2. If close enough, extend it.
3. If genuinely missing, then create.

Why: AI agents have an extreme bias toward generation. Without this
rule, every prompt produces a near-duplicate of something that already
exists, multiplying maintenance surface forever.

## How the rest of the spec connects

- Branching, push, PR rules are the *enforcement* of Principle 1.
- Commit message rules are the *enforcement* of Principle 2.
- Agent-behavior rules are the *enforcement* of Principle 3.

If you only remember three rules from this entire repository, remember
these three.
