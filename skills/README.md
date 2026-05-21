# Skills

Installable Claude Code **Skill** packages for the AI-native
development standard. Each skill is a directory containing a
`SKILL.md` with YAML frontmatter; this is the same shape as
[Anthropic's superpower skills](https://github.com/anthropics/skills).

A vibe-coding tool (Claude Code, and any tool that follows the same
convention) will autoload a skill when the conditions in its
`description` are met.

## Available skills

| Skill | Loads when… |
| --- | --- |
| [`ai-native-git-workflow`](./ai-native-git-workflow/) | An agent is about to branch, commit, push, or open a PR. |
| [`ai-native-commits`](./ai-native-commits/) | An agent is about to write a commit message. |
| [`ai-native-ci-cd`](./ai-native-ci-cd/) | An agent is editing GitHub Actions or any CI workflow file. |
| [`ai-native-database`](./ai-native-database/) | An agent is editing schema, migrations, or DB connection code. |
| [`ai-native-agent-behavior`](./ai-native-agent-behavior/) | Any time the agent is about to generate new code. |

## Install

### Project-scoped (recommended)

Copy the skill directory into your project's `.claude/skills/`:

```bash
mkdir -p .claude/skills
cp -r path/to/agents-md/skills/ai-native-git-workflow .claude/skills/
```

### User-scoped (Claude Code)

```bash
mkdir -p ~/.claude/skills
cp -r path/to/agents-md/skills/ai-native-git-workflow ~/.claude/skills/
```

### Install all of them

```bash
cp -r path/to/agents-md/skills/* .claude/skills/
```

## Skill format

Every skill is a directory:

```
skills/<skill-name>/
└── SKILL.md
```

`SKILL.md` begins with YAML frontmatter:

```yaml
---
name: <skill-name>
description: One sentence: when this skill should activate.
---
```

…followed by the rules and procedures the skill encodes. The
description is what the host tool uses to decide whether to load the
skill in a given turn, so keep it specific and trigger-oriented.

## Authoring a new skill

1. Pick a *focused* trigger. If you find yourself writing "and also …"
   in the description, split into two skills.
2. Keep the body action-oriented. Skills are read by an agent at
   action time; they are not prose documentation.
3. Cross-reference the relevant `docs/` chapter for the human-readable
   long form.
4. Add it to the table above.
