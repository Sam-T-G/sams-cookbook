#!/usr/bin/env bash
# Assert recipes.yaml and the recipes/ tree agree exactly.
# A recipe directory is any folder under recipes/<part>/<slug>/ that contains a README.md.
# Every such directory must have a matching `path:` entry in recipes.yaml, and every `path:` in
# recipes.yaml must point at a real directory.
set -uo pipefail

manifest="recipes.yaml"
fail=0

# 1. Every recipe directory on disk has a manifest entry.
while IFS= read -r readme; do
  dir="$(dirname "$readme")"
  if ! grep -qE "path:[[:space:]]*\"$dir\"" "$manifest"; then
    echo "MISSING from recipes.yaml: $dir"
    fail=1
  fi
done < <(find recipes -mindepth 3 -maxdepth 3 -name README.md 2>/dev/null)

# 2. Every manifest path points at a real directory.
while IFS= read -r path; do
  [ -z "$path" ] && continue
  if [ ! -d "$path" ]; then
    echo "STALE in recipes.yaml (no such directory): $path"
    fail=1
  fi
done < <(grep -E '^[[:space:]]*path:' "$manifest" | sed -E 's/.*path:[[:space:]]*"([^"]*)".*/\1/')

if [ "$fail" -eq 0 ]; then
  echo "recipes.yaml and recipes/ are consistent."
fi
exit "$fail"
