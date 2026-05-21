#!/usr/bin/env bash
# Validate a branch name against the agents-md branching rules.
#
# Usage:
#   scripts/lint-branch-name.sh                # checks current HEAD branch
#   scripts/lint-branch-name.sh <branch-name>  # checks the given name
#
# Allowed shapes:
#   main
#   ai/<feature>
#   ai/<type>/<feature>      e.g. ai/feat/auth, ai/fix/websocket
#
# Human contributors are not required to use ai/, but this lint is meant
# to be wired into CI for AI-driven branches and to catch obvious problems
# (uppercase, spaces, "and"-joined names, etc.).

set -euo pipefail

branch="${1:-$(git rev-parse --abbrev-ref HEAD)}"

# Always allow protected branches.
case "$branch" in
  main|master|develop|HEAD)
    printf '✓ %s — protected branch, no check\n' "$branch"
    exit 0
    ;;
esac

# Allow tooling-managed branches (e.g. dependabot, renovate, claude on web).
case "$branch" in
  dependabot/*|renovate/*|claude/*)
    printf '✓ %s — tool-managed branch, accepted\n' "$branch"
    exit 0
    ;;
esac

# Enforce ai/<feature> shape for agent branches.
if ! printf '%s' "$branch" | grep -Eq '^ai/[a-z0-9]+([-/][a-z0-9]+)*$'; then
  cat >&2 <<EOF
✗ "$branch" does not match the ai/<feature> convention.

Allowed:
  ai/auth-system
  ai/memory-agent
  ai/feat/landing-redesign
  ai/fix/websocket-reconnect

Disallowed:
  - Uppercase letters
  - Spaces or underscores
  - "and"-joined multi-feature names

See docs/branching.md.
EOF
  exit 1
fi

# Soft warning: avoid joiners that usually mean "two features in one branch".
if printf '%s' "$branch" | grep -Eq '(-and-|-plus-|-with-)'; then
  printf '⚠ %s — name contains "-and-"/"-plus-"/"-with-"; likely two features.\n' "$branch" >&2
  printf '  See docs/branching.md §3.\n' >&2
fi

printf '✓ %s\n' "$branch"
