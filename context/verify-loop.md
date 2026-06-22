# The verify loop

Anthropic's headline Claude Code practice is to give the model a check it can run on its own output. For iOS
that is a two-tier loop, gated deterministically by a hook so it is guaranteed, not advisory.
(source: code.claude.com/docs)

## Two tiers

1. **Pure-logic golden vectors.** `swift build` then `swift test` in the recipe. Runs on any host, in
   parallel, no simulator. This is the tier that proves the logic is correct and is green in CI.
2. **Framework glue on a simulator or device.** `xcodebuild test` on the iOS 26 simulator, or hand-running on
   a device for device-required recipes (all Foundation Models recipes). The proof is a recorded transcript
   in the recipe's `verify-output/`, because CI cannot run it.

Which tier a recipe lands in is its runnability tier, declared in `recipes.yaml` and surfaced in the README.

## The gates

- A **Stop hook** (`scripts/stop_gate.sh`, wired in `.claude/settings.json`) blocks the session from ending
  while `swift test` is red. The docs treat `CLAUDE.md` as advisory and hooks as guaranteed, so the
  must-always-happen check lives in a hook, not in prose.
- A **PostToolUse hook** (`scripts/format_swift.sh`) formats Swift right after Claude edits it, so formatting
  never becomes a review topic.

## Evidence, not paraphrase

Capture the real `swift test` output (and real device transcripts) into `verify-output/`. A recipe that says
"tests pass" without the captured run has not earned the claim. The concurrency-posture recipe's
`verify-output/test-run.txt` is the reference shape.
