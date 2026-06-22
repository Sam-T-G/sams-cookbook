#!/usr/bin/env bash
# Stop hook: do not let the session end while the golden-vector tests are red.
# Runs `swift test` from the repo root. If it fails, emits a block decision so Claude keeps working.
# Set SKIP_TEST_GATE=1 to bypass (useful when only docs changed).
set -uo pipefail

if [ "${SKIP_TEST_GATE:-0}" = "1" ]; then
  exit 0
fi

# Only gate when there is something to test.
if [ ! -f "Package.swift" ]; then
  exit 0
fi

if swift test >/tmp/sams_cookbook_test.log 2>&1; then
  exit 0
fi

tail="$(tail -20 /tmp/sams_cookbook_test.log | tr '"' "'" | tr '\n' ' ')"
printf '{"decision":"block","reason":"swift test is red. Fix it before stopping. Tail: %s"}\n' "$tail"
exit 0
