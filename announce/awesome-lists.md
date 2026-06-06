# Awesome-list PRs

> One-line entries to PR into each target. Open one PR per list
> per week (rate-limited so as not to look spammy). Each list has
> different conventions — read its CONTRIBUTING before submitting.

## Target lists, by priority

| List | Repo | Section to PR into | Why |
| --- | --- | --- | --- |
| awesome-claude-code | `hesreallyhim/awesome-claude-code` | "Resources" / "Conventions" | Direct keyword match. Highest expected conversion. |
| awesome-cursorrules | `PatrickJS/awesome-cursorrules` | "Resources" or "Rules" | Cursor users overlap heavily with the audience. |
| awesome-ai-coding | `Hannibal046/Awesome-LLM` (`/coding` section) or any of the several other lists | "Methodology" / "Best practices" | LLM-coding audience. |
| awesome-llmops | `tensorchord/Awesome-LLMOps` | "Standards" / "Best practices" | Platform-engineering crossover for the eval / observability chapters. |
| awesome-devops | `wmariuss/awesome-devops` | "Best practices" / "Methodology" | The CI/CD and branching parts apply outside AI too. |
| awesome-backstage | search "awesome backstage" — there are several | "Resources" / "Integrations" | The `docs/idp-integration.md` chapter is the hook. |
| awesome-internal-developer-platform | search "awesome IDP" | "Standards" / "Methodology" | Same audience as backstage above. |
| awesome-developer-tools | various | varies | Lower priority — too generic. |

## The line to PR

Use this exact line (or trim a clause to fit the list's style):

```
- [agents-md](https://github.com/maweis1981/agents-md) - Bilingual (EN / 中文) spec for how AI agents should commit, branch, run CI/CD, handle DB migrations, and ship to production. Ships with Claude Code Skill packages, drop-in templates, and bash lint scripts.
```

Shorter variant for tighter list conventions:

```
- [agents-md](https://github.com/maweis1981/agents-md) - AI-native dev standards. Bilingual. Skill packages + templates + CI lint scripts.
```

Even shorter:

```
- [agents-md](https://github.com/maweis1981/agents-md) - AI-native dev standards for the Claude Code / Cursor / Codex era.
```

## Per-list PR template

Title:

```
Add agents-md to <section name>
```

Body:

```
Hi! Submitting [agents-md](https://github.com/maweis1981/agents-md)
to the <section name> section.

It's a bilingual (English + 简体中文) specification for AI-native
development workflows — covering Git/GitHub, CI/CD, DB migrations,
prompts as code, evals, observability, and IDP integration. MIT
licensed, no commercial interest.

I've read CONTRIBUTING.md and the entry follows the existing
formatting (one-line description, alphabetical ordering by name
in the section).

Happy to adjust wording or section placement if it's a better
fit elsewhere — thanks for maintaining this list!
```

## Tactical notes

- **Read CONTRIBUTING.md** of each list before submitting. Some
  require specific section ordering, specific punctuation, no
  trailing periods, etc.
- **Alphabetize correctly** — `agents-md` starts with "a", goes
  near the top. Don't insert in the middle just to be visible.
- **Don't submit to a list you wouldn't recommend yourself**.
  Maintainers reject obvious self-promotion to "everything tangentially
  related" lists.
- **One PR per week per maintainer.** Submitting 5 PRs to the same
  user's lists on the same day reads as spam.
- **If rejected**, accept gracefully, ask politely for the reason,
  fix and resubmit only if the reason was about wording — not if
  the maintainer said "not a fit."
- **Track which lists accepted** in a private note. Some lists
  have higher star-conversion than others; this informs the next
  release's promotion.

## Other surfaces

Not awesome-lists exactly, but similar long-tail value:

- **GitHub's own "agents-md" topic page** (https://github.com/topics/agents-md)
  — this exists if you've tagged the topic and is searchable.
- **OpenAI Cookbook** — has a `community` directory that accepts
  external contributions. The `docs/prompts.md` chapter is on-topic.
- **LangChain docs** — community contributions accepted for
  patterns / methodology references.
- **Backstage TechDocs examples gallery** — if `docs/idp-integration.md`
  proves out as an example, propose it as a community example.
