#!/usr/bin/env bash
# Verify that every English doc has a Chinese counterpart and vice versa.
#
# Usage:
#   scripts/check-bilingual.sh            # checks docs/ by default
#   scripts/check-bilingual.sh <dir>...   # check the given directories
#
# A pair is `<name>.md` ↔ `<name>.zh-CN.md`. README.md / SKILL.md /
# CHANGELOG.md and other repo-meta files are not required to be bilingual
# (those that are paired are listed explicitly below).

set -euo pipefail

dirs=("${@:-docs}")
violations=0

# Files outside docs/ that ARE required to be bilingual.
explicit_pairs=(
  "./README.md"
  "./STANDARDS.md"
  "./CONTRIBUTING.md"
)

check_pair() {
  local en="$1"
  local zh="${en%.md}.zh-CN.md"
  if [ ! -f "$zh" ]; then
    printf '✗ missing Chinese: %s (expected %s)\n' "$en" "$zh"
    violations=$((violations+1))
  fi
}

check_orphan() {
  local zh="$1"
  local en="${zh%.zh-CN.md}.md"
  if [ ! -f "$en" ]; then
    printf '✗ orphan Chinese (no English counterpart): %s\n' "$zh"
    violations=$((violations+1))
  fi
}

for d in "${dirs[@]}"; do
  while IFS= read -r f; do
    base=$(basename "$f")
    # Skip the index README.md inside a docs/ directory.
    [ "$base" = "README.md" ] && continue
    check_pair "$f"
  done < <(find "$d" -type f -name '*.md' ! -name '*.zh-CN.md')

  while IFS= read -r f; do
    check_orphan "$f"
  done < <(find "$d" -type f -name '*.zh-CN.md')
done

for f in "${explicit_pairs[@]}"; do
  [ -f "$f" ] && check_pair "$f"
done

if [ "$violations" -gt 0 ]; then
  printf '\n%d bilingual violation(s).\n' "$violations" >&2
  exit 1
fi
echo "✓ all bilingual pairs present"
