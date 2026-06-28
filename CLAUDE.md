# CLAUDE.md: Sam's Cookbook

A modern, Claude-native iOS development cookbook. iOS is what you learn; Claude is how you build.
Every recipe teaches a real iOS technique and shows how to drive Claude Code to build it, with
runnable code and tests.

## Snapshot

- Language: Swift. Pinned baseline in `versions.lock` (Swift 6.3, Xcode 26.5, iOS 26 floor).
- Layout: standalone recipe packages under `recipes/`. Each recipe is its own buildable package with no
  dependency on any other recipe. There is no single root `Package.swift` (nested packages conflict); an
  aggregate `scripts/test_all.sh` builds and tests them all.
- Owner: Samuel Gerungan. Public repo, MIT licensed.
- The full plan is in `SPEC.md`. Read it before large changes.

## How to build and run

- Build and test everything: `scripts/test_all.sh`.
- Build or test one recipe: `cd recipes/<part>/<recipe>` then `swift build` / `swift test`.
- App and on-device recipes need Xcode 26.5 and the iOS 26 simulator or a device. See the runnability
  tiers in `README.md` for what runs where.

## Working rules

- Swift is governed by `SWIFT.md` (imported below). Follow it for every Swift edit.
- Recipes are fully standalone. Do not add a dependency from one recipe target to another.
- Pure logic is extracted so it can be tested headlessly. Framework glue is verified on a simulator or
  device and its output is captured in the recipe's `verify-output/`.
- Every version fact comes from `versions.lock`. Do not restate build numbers in prose; reference the lock.
- Confirm before destructive git operations. Match the surrounding code style.
- This repo ships its `.claude/` directory on purpose, because the Claude-native setup is the teaching
  subject. That is specific to this cookbook and is not the default for other repos.

## Verify loop

Claude runs its own check on its output: `swift build` plus `swift test` for pure-logic golden vectors,
and a simulator or device build for framework glue. A Stop hook blocks until `swift test` is green
(`.claude/settings.json`). Capture real output as evidence; do not paraphrase it.

## Context map (read on demand)

- `context/concurrency-posture.md`: the Swift 6 concurrency baseline the whole book assumes.
- `context/verify-loop.md`: the two-tier check and the hooks that gate it.
- `context/subagent-doctrine.md`: when to fan out, and why forks do not see this file.
- `context/voice-guide.md`: the house writing voice for all prose.
- `docs/recipe-template.md`: the fixed section order every recipe follows.
- `docs/currency-protocol.md`: how version facts stay auditable.
- `docs/AGENT-GUIDE.md`: for an agent mining this repo as a reference to build a different iOS app.

## Imports

@SWIFT.md

## Working with AI here

This cookbook teaches Claude-native iOS, so the working method is part of the subject. The verify loop above is the mechanism; the principle behind it is that verification is the craft. Generation is cheap and judgment is scarce, so review every line a recipe's agent ships, be skeptical of clever-looking code, and confirm imports resolve to real packages before trusting a build.

- Each recipe's golden vectors and `verify-output/` are the contract: they say what "correct" means and check it, which is what lets the Stop hook gate on green tests instead of vibes.
- Agents nail the well-specified body of a recipe; the last 20% (edge cases, error handling, the framework-glue integration points) is where attention earns its keep. Write that into the recipe so the lesson shows the judgment, not just the happy path.
