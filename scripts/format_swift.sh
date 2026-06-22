#!/usr/bin/env bash
# PostToolUse hook: format a Swift file right after Claude edits it.
# Reads the hook JSON from stdin, pulls out the edited file path, and formats it in place if it is Swift.
# Never blocks: any parsing failure or formatter hiccup exits 0 so normal flow continues.
set -uo pipefail

payload="$(cat)"

# Extract the first "file_path" value without requiring jq.
file="$(printf '%s' "$payload" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"

case "$file" in
  *.swift)
    if [ -f "$file" ] && command -v swift >/dev/null 2>&1; then
      swift format --in-place "$file" >/dev/null 2>&1 || true
    fi
    ;;
esac

exit 0
