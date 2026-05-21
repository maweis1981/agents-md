#!/usr/bin/env bash
# Verify that every relative Markdown link in the repo resolves.
#
# Usage:
#   scripts/check-links.sh           # checks repo root
#   scripts/check-links.sh <dir>...  # checks the given directories
#
# Only relative links to .md files are checked. External URLs and
# non-markdown link targets are ignored.

set -euo pipefail

dirs=("${@:-.}")
violations=0
total=0

for d in "${dirs[@]}"; do
  while IFS= read -r src; do
    while IFS= read -r raw; do
      [ -z "$raw" ] && continue
      # Strip ](...) wrapper and optional #anchor.
      link=$(printf '%s' "$raw" | sed -E 's|^\]\(([^)#]+)(#[^)]*)?\)$|\1|')
      total=$((total+1))
      target_dir=$(dirname "$src")
      target=$(cd "$target_dir" 2>/dev/null && readlink -f "$link" 2>/dev/null || true)
      if [ -z "$target" ] || [ ! -f "$target" ]; then
        printf '✗ %s → %s\n' "$src" "$link"
        violations=$((violations+1))
      fi
    done < <(grep -oE '\]\(\.[^)#]+\.md[^)]*\)' "$src" 2>/dev/null || true)
  done < <(find "$d" -type f -name '*.md' -not -path './.git/*')
done

if [ "$violations" -gt 0 ]; then
  printf '\nChecked %d relative .md link(s); %d broken.\n' "$total" "$violations" >&2
  exit 1
fi
printf '✓ checked %d relative .md link(s); all resolve.\n' "$total"
