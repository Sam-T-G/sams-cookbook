# Sam's Cookbook

A modern, Claude-native iOS development cookbook.

**iOS is what you learn. Claude is how you build.** Every recipe teaches a real, current iOS technique and
shows how to drive Claude Code to build it, with runnable code and tests. The iOS content leads; the
Claude workflow is woven into each recipe, not bolted on as a separate book.

This is not a tutorial you read once. It is a set of standalone, buildable recipes you clone, run, and
adapt, each pinned to a verified-current toolchain and each carrying the prompt and rules that produced it.

## The pinned baseline

Swift 6.3, Xcode 26.5, iOS 26 deployment floor. Verified against primary sources on 2026-06-21. Every
version fact lives in [`versions.lock`](versions.lock); the prose references that file rather than
restating build numbers, so the currency story has one auditable source. Pre-release work (iOS 27,
Xcode 27, Swift 6.4) is quarantined in [`appendix/A-ios27-frontier`](appendix/A-ios27-frontier) so no core
recipe depends on beta APIs.

## How to run a recipe

Every recipe is its own Swift package. To build and test one:

```sh
cd recipes/02-language-concurrency/concurrency-posture
swift build
swift test
```

To build and test every recipe from the repo root:

```sh
scripts/test_all.sh
```

Each recipe is its own standalone package, so there is no single root `Package.swift` (nested packages
conflict). The aggregate runner walks every recipe package and builds and tests the logic-runnable ones.

## Runnability tiers

"Fully runnable" is true, but not uniformly. A pure-logic recipe runs `swift test` on any host; a recipe
that uses on-device AI needs eligible hardware. Each recipe declares its tier at the top and in
[`recipes.yaml`](recipes.yaml).

| Tier | Needs | Verified by | In CI |
|---|---|---|---|
| **logic-runnable** | Any host with the Swift toolchain | `swift build` + `swift test` (golden vectors) | Green |
| **simulator-required** | The iOS 26 simulator | `xcodebuild test`, or headless behavioral and accessibility assertions | Green on a macOS runner |
| **device-required** | Eligible hardware with Apple Intelligence enabled, or signing-gated features | Hand-run on device, transcript retained in `verify-output/` | Compile-only smoke build, with a "requires device" banner |

All Foundation Models (on-device AI) recipes are device-required and cannot pass headless CI. They ship a
recorded transcript instead.

## How the book is organized

- **Part 1: Driving Claude Code to build iOS** (`recipes/01-driving-claude`): the `.claude/` setup, the
  canonical `SWIFT.md`, the verify loop, skills, and subagents that every recipe assumes.
- **Part 2: Modern Swift language and concurrency** (`recipes/02-language-concurrency`): the Swift 6.3
  baseline, plus a migration on-ramp from the older Combine and `ObservableObject` shape.
- **Part 3: SwiftUI and app architecture** (`recipes/03-swiftui-architecture`).
- **Part 4: Persistence with SwiftData** (`recipes/04-persistence-swiftdata`).
- **Part 5: Networking** (`recipes/05-networking`).
- **Part 6: AI features in iOS apps** (`recipes/06-ai-features`): on-device Foundation Models, cloud
  Claude from Swift, and a hybrid assistant that escalates from one to the other. The headline part.
- **Part 7: Testing** (`recipes/07-testing`).
- **Part 8: Tooling and CI/CD** (`recipes/08-tooling-ci`).
- **Part 9: Cross-cutting concerns** (`recipes/09-cross-cutting`): accessibility, performance, security,
  and the modern 2026 surface.
- **Appendices** (`appendix/`): the iOS 27 frontier, and contributing plus the currency protocol.

The full plan, including the information architecture and the open spikes, is in [`SPEC.md`](SPEC.md).

## The recipe anatomy

Every recipe follows the same section order: a one-line promise, pinned versions, the problem, a baseline,
the modern Swift solution, **Build it with Claude** (the prompt, the `SWIFT.md` rules, the verify loop),
verify and tests, pitfalls, decision guidance, and a short reflection. The template is in
[`docs/recipe-template.md`](docs/recipe-template.md).

## Building with Claude

This repo ships its `.claude/` directory on purpose, because the Claude-native setup is the teaching
subject. [`CLAUDE.md`](CLAUDE.md) and [`SWIFT.md`](SWIFT.md) are the contract Claude follows; the skills in
`.claude/skills/` (`/new-recipe`, `/swift-build`, `/swift-test`, `/commit`) are the repeatable tasks; and a
Stop hook blocks until `swift test` is green. Open the repo in Claude Code and run `/new-recipe` to scaffold
your own.

**Using this cookbook to build a different app?** If you are an agent (or a developer with one) mining this
repo as a reference while building iOS code elsewhere, read [`docs/AGENT-GUIDE.md`](docs/AGENT-GUIDE.md). It
covers what to read first, a task-to-recipe index, what to copy, and how to verify the result.

## License

MIT. See [`LICENSE`](LICENSE).
