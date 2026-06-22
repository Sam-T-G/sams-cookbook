#!/usr/bin/env bash
# Build and test every recipe package. Logic-runnable recipes run `swift test`; simulator- and
# device-required recipes are compile-checked only here (their real verification is on a simulator or a
# device, recorded in each recipe's verify-output/). The tier is read from recipes.yaml.
set -uo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

fail=0
found=0

while IFS= read -r pkg; do
  dir="$(dirname "$pkg")"
  found=$((found + 1))
  rel="${dir#"$root"/}"

  # Look up this recipe's tier in the manifest (default to logic-runnable if not found).
  tier="$(grep -A5 -F "\"$rel\"" recipes.yaml | sed -nE 's/.*tier:[[:space:]]*"([^"]*)".*/\1/p' | head -1)"
  tier="${tier:-logic-runnable}"

  echo "== $rel  (tier: $tier) =="
  if [ "$tier" = "logic-runnable" ]; then
    ( cd "$dir" && swift test ) || { echo "FAILED: $rel"; fail=1; }
  else
    ( cd "$dir" && swift build ) || { echo "COMPILE FAILED: $rel"; fail=1; }
    echo "  (tier $tier: compile-only here; verify on simulator/device, see verify-output/)"
  fi
done < <(find recipes samples -name Package.swift 2>/dev/null | sort)

echo
echo "Checked $found package(s)."
[ "$fail" -eq 0 ] && echo "All green." || echo "Some packages failed."
exit "$fail"
