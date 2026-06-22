# Sam's Cookbook — Specification

A modern, Claude-native iOS development cookbook. Every recipe teaches a real iOS technique and shows how to drive Claude Code to build it, with runnable code and tests.

- **Status:** Draft spec, ready for review. Nothing scaffolded yet beyond this file.
- **Slug / repo:** `sams-cookbook` (display title "Sam's Cookbook"). Standalone public repo, planned remote `Sam-T-G/sams-cookbook`, mirrored to the Obsidian vault.
- **Pinned baseline:** Swift 6.3, Xcode 26.5, iOS 26 deployment floor. Verified against primary sources on 2026-06-21.
- **Author voice:** house style applies to this file too (we-voice, no em dashes, sources cited).

This spec was assembled from primary-source research across Anthropic's Claude cookbook and Claude Code docs, Apple developer documentation, swift.org, and the most respected community iOS resources, then run through an adversarial completeness review. The bibliography is in section 14.

---

## 1. Thesis and scope

The book has one axis: **iOS is what you learn, Claude is how you build.**

Modern iOS recipes are the subject. Each recipe also carries a "Build it with Claude" section that shows the prompt, the `SWIFT.md` rules that constrain Claude, the explore/plan/implement/commit flow for larger work, and the verify loop Claude runs on its own output. The Claude-native half is woven into every recipe, not stapled on as a separate book.

**In scope:** the current stable Swift, SwiftUI, and iOS surface (concurrency, state, persistence, networking, on-device and cloud AI, testing, tooling, CI/CD, accessibility, performance, security), each as a buildable target with tests, plus the Claude Code workflow that produces it.

**Out of scope:** UIKit-first development (referenced only where a SwiftUI bridge needs it), Objective-C, macOS/visionOS/watchOS as primary targets (noted where an API is shared), and anything gated on pre-release OS versions, which lives in a clearly dated appendix.

**Who it is for:** an engineer who already programs with Claude Code and wants a single, current, runnable reference for building real iOS apps the modern way.

---

## 2. Locked decisions

These came from the scoping interview and are fixed for v1.

| Decision | Choice | Consequence |
|---|---|---|
| Primary axis | iOS-first, Claude-native | Every recipe has a "Build it with Claude" section; iOS content leads. |
| Recipe format | Fully runnable | Every recipe is a buildable SPM/Xcode target with tests, subject to the runnability tiers in section 5. |
| Repo home | Top-level public repo | `~/Documents/repositories/sams-cookbook`, remote `Sam-T-G/sams-cookbook`, vault-mirrored. |
| `.claude/` visibility | Shipped in-repo | Deliberate exception to the solo-repo zero-trace convention, because the Claude-native setup is the teaching subject (see section 8). |
| Recipe independence | Fully standalone | Each recipe is its own target with its own `Package.swift` and no dependency on any other recipe. Cross-references are prose links only. No composed demo app. |
| License | MIT | Matches the starter packs; public and shareable. |
| Shipping AI calls | Backend edge relay | The app never holds the API key. A stateless edge function (Cloudflare Workers reference, all-Swift server alternative) verifies App Attest, injects the key server-side, and streams the response. See sections 9 and 12 and `samples/backend-relay/`. |
| First recipe | Concurrency posture (Part 2) | Logic-runnable, so it exercises the full pipeline (template, `/new-recipe`, verify loop, golden vectors, CI) and proves the format before the device-required AI flagship. |

---

## 3. Tech baseline

The baseline is the verified-stable June 2026 line. It matches the modern idiom already shipping in the user's Citrus Squad project (see section 4).

| Layer | Pinned | Notes |
|---|---|---|
| Swift | **6.3** (released 2026-03-24) | Swift 6 language mode, `SWIFT_STRICT_CONCURRENCY=complete`, warnings as errors. Adopts the Approachable Concurrency posture from 6.2 in full (default `MainActor` isolation via SE-0466, `nonisolated(nonsending)` and `@concurrent` via SE-0461, the `Observations` async sequence). |
| Xcode | **26.5** (build 17F42, 2026-05-11) | GM toolchain carrying Swift 6.3 and Swift Testing in-toolchain. 26.6 is in RC; not pinned. |
| iOS | **26** (deployment floor 26.0; shipping consumer OS 26.5.1, 2026-06-01) | Supports Liquid Glass, modern `@Observable`, on-device Foundation Models, `Chart3D`, Translation. |

**Core frameworks the cookbook standardizes on**

- SwiftUI as the only UI layer (Liquid Glass via `glassEffect` / `GlassEffectContainer`, `NavigationStack` routing).
- Observation framework / `@Observable` as the mandated state model. `ObservableObject` and `@Published` are banned for new code.
- Swift Concurrency: actors for shared mutable non-UI state, `@MainActor` for UI, deliberate `Sendable` boundaries, `Task` plus a clock for timing. No `DispatchQueue` in app logic, no `Timer`.
- SwiftData for persistence (`@ModelActor` for background writes, `VersionedSchema` migrations), with an honest Core Data coexistence boundary.
- Foundation / `URLSession` async-await for a typed networking layer, `Codable` with a centralized decoder.
- Swift Testing (`@Test` / `@Suite` / `#expect` / `#require`, parameterized golden-vector tests). XCTest only for XCUI automation and performance measure blocks.
- Foundation Models framework for on-device AI (`SystemLanguageModel.default`, `LanguageModelSession`, `@Generable` / `@Guide`, the `Tool` protocol).
- The Anthropic Claude Messages API for cloud AI, via a Swift client to be locked by the spike in section 12.
- `os.Logger` per subsystem. `print` is banned in app logic.
- Swift Charts (including `Chart3D` / `SurfacePlot`), WidgetKit and App Intents, StoreKit 2, Translation, and the Accessibility APIs.

**Why this baseline.** It is the current GM line, so every recipe builds today against a released toolchain, which the fully-runnable mandate requires. It is also exactly the modern idiom the user already ships: strict concurrency complete with warnings as errors, `@Observable` over `ObservableObject`, actors for shared non-UI state and `@MainActor` for UI, value types with typed domain errors, golden-vector tests for pure logic, centralized config enums, `os.Logger` per subsystem, and gitignored xcconfig secrets. The pre-release frontier (iOS 27, Xcode 27, Swift 6.4) is quarantined in Appendix A so the book reads as current without depending on beta APIs.

All volatile version facts live in one machine-checkable file, `versions.lock` (section 11). Prose references that file rather than restating build numbers, so the currency story has one source of truth.

---

## 4. Provenance and the idiom

The cookbook's idiom is not invented. It is the idiom already shipping in the user's Citrus Squad project: Swift 6 with strict concurrency complete, `@Observable`, actors for shared non-UI state, `@MainActor` UI, vertical feature slices (`Routing/`, `Sensors/`, `Networking/`), value types with typed domain errors, golden-vector Swift Testing, centralized config enums, `os.Logger`, and XcodeGen project generation. That code is the proof the idiom is real and buildable.

The honest part: the user's other iOS project, the WAND phone probe, is the opposite shape. It is a deliberately simple throwaway harness on Swift 5 and iOS 16 using Combine, `ObservableObject` / `@Published`, `DispatchQueue` hops, and `Date`-based timing. It is where a lot of real iOS code actually starts.

So the cookbook does two things instead of pretending everyone already lives in the modern idiom:

1. It teaches the modern idiom as the default, grounded in the Citrus Squad shape.
2. It ships a first-class **migration on-ramp** (Part 2) that takes a real legacy slice (the WAND shape: `ObservableObject` + Combine + `.main`-queue closures + `Date` timer on Swift 5 / iOS 16) and walks it to `@Observable` + actor + `Task`-clock under strict concurrency complete. This is the reader's true starting point, so it earns more than a single bullet.

---

## 5. Runnability tiers

"Fully runnable" is true, but not uniformly. A pure-logic recipe runs `swift test` on any host; a Foundation Models recipe needs an eligible device with Apple Intelligence enabled and cannot run in headless CI. Pretending otherwise would be dishonest, so the tier is a repo-level contract, declared per recipe in `recipes.yaml` and summarized in the README.

| Tier | What it needs | Verified by | CI |
|---|---|---|---|
| **logic-runnable** | Any host with the Swift toolchain | `swift build` + `swift test` (golden vectors) | Green in GitHub Actions |
| **simulator-required** | iOS 26 simulator | `xcodebuild test` on a macOS runner, or behavioral / accessibility assertions | Green on a macOS runner with a pinned simulator |
| **device-required** | Eligible hardware, Apple Intelligence enabled (all Foundation Models recipes), or signing-gated features | Hand-run on device, with a recorded transcript retained in `verify-output/` | Compile-only smoke build in CI, with a clearly labeled "requires device" banner |

Rules that follow from this:

- Pure logic is always extracted so it can sit in a logic-runnable target. The escalation decision in the hybrid AI flagship, the routing in the networking layer, and the bearing geometry are all pure functions with golden-vector tests, even when the surrounding glue is device-required.
- Visual recipes (Liquid Glass, navigation, accessibility) prefer behavioral and accessibility assertions that run headlessly (Dynamic Type reflow, VoiceOver label presence) over pixel snapshots that rot across simulators and OS versions. If a snapshot test stays, its simulator is pinned in `versions.lock` and a snapshot break is treated as a currency event, not a silent failure.
- Every recipe states its tier at the top. The README carries the full matrix so the "clone, build, test" promise is scoped truthfully.

---

## 6. The recipe anatomy

Every recipe is a directory with a `README.md` that follows this fixed section order, plus its own `Package.swift`, `Sources/`, `Tests/`, `prompts/`, and `verify-output/`. The order is the iOS analogue of the Anthropic cookbook's recipe structure.

Recipes are fully standalone. Each is its own buildable target with no dependency on any other recipe, so a reader can clone the repo and build a single recipe in isolation. The "Decision guidance" and "Next steps" sections cross-link to related recipes as prose only, never as a code dependency. There is no composed demo app that several recipes feed into.

1. **Title and one-line promise** — the concrete iOS pain solved, quantified where possible.
2. **Tags and metadata** — capability tags, author, runnability tier, and "built against Swift 6.3 / Xcode 26.5 / iOS 26 / `claude-opus-4-8` on DATE."
3. **Pinned versions** — exact Swift / Xcode / iOS, Claude model, and library versions, with a dated "current as of" note and source links (drawn from `versions.lock`).
4. **Prerequisites** — skills assumed, simulator vs device, time estimate, prior recipes.
5. **Problem** — the modern iOS pain, with a measurable baseline where one exists.
6. **Baseline** — the naive or pre-modern approach, runnable, with its measured shortcoming.
7. **Modern solution (Swift)** — the idiomatic Swift 6 implementation, each layer individually buildable.
8. **Build it with Claude** — the one-liner prompt; the `SWIFT.md` / `CLAUDE.md` rules that constrain Claude; the explore/plan/implement/commit flow, or the AskUserQuestion to `SPEC.md` interview for larger work; the verify loop Claude runs.
9. **Verify / tests** — the Swift Testing golden-vector target for pure logic and the on-device check for framework glue, with real captured output retained in `verify-output/`.
10. **Pitfalls and trade-offs** — concurrency footguns, device-vs-simulator differences, cost and latency, candid limitations.
11. **Decision guidance** — when to use this approach versus the alternatives.
12. **Reflection** — a difficulty encountered plus a forward note.
13. **Next steps and related recipes.**

Content balance per recipe targets roughly 30% explanation, 50% runnable code, 15% results and captured output, 5% caveats.

---

## 7. Information architecture

Twelve parts. Parts 1 through 9 are recipe-bearing and map one-to-one onto `recipes/01-…` through `recipes/09-…`. Part 0 lives in `README.md` and `docs/`. Appendices A and B live in `appendix/`.

### Part 0 — How this cookbook works
*Orientation. Lives in README and docs, not a recipes directory.*
- The thesis and the recipe anatomy: the fixed template, the content balance, the currency contract.
- The runnable workspace: the top-level `Package.swift`, app-vs-logic targets, gitignored secrets, the `recipes.yaml` manifest.
- The documentation voice: the house style as a sourced rule set, shipped as a skill so Claude obeys it when drafting prose.

### Part 1 — Driving Claude Code to build iOS  (`recipes/01-driving-claude/`)
*The Claude-native foundation every later "Build it with Claude" section assumes.*
- **The `.claude` setup and `SWIFT.md`:** a sub-200-line `CLAUDE.md` that links context docs on demand; the canonical `SWIFT.md` (section 8); path-scoped rules versus always-loaded rules and the token trade-off; baking in the agentic-coding prompt blocks; why we avoid "CRITICAL" / "You MUST" phrasing on Opus 4.8.
- **The verify loop for Swift:** the two-tier loop (golden vectors plus on-device build); a Stop hook that blocks until `swift test` is green; an adversarial code-review subagent scoped to correctness, not style; capturing real test output as evidence.
- **Skills as the repeatable-task primitive:** `/new-recipe` scaffolds a buildable target plus a test stub and a manifest entry; `/swift-build` and `/swift-test` pre-approve safe commands via `allowed-tools`; dynamic context injection inlines live build output; `/commit` and `/draft-recipe-prose` are side-effecting and set `disable-model-invocation: true`. When a skill, when a hook, when a rule.
- **Subagents and the single-writer doctrine:** subagents as isolated research and review workers, never coordinating peers; why `Explore` and `Plan` forks skip `CLAUDE.md` / `SWIFT.md` and how to fix it with a tested artifact (section 12); the fan-out token cost; avoiding over-spawning on Opus 4.8.
- **Explore, plan, implement, commit:** the four-phase loop on a real feature; the AskUserQuestion to `SPEC.md` interview, then a fresh execution session; provide-specific-context prompting with before/after pairs; headless and CI via `claude -p`.

### Part 2 — Modern Swift language and concurrency  (`recipes/02-language-concurrency/`)
*The language baseline the whole book assumes, plus the migration on-ramp.*
- **The concurrency posture:** `MainActor` default isolation, strict concurrency complete, warnings as errors, with the exact `Package.swift` `SwiftSetting` snippet; reading a data-race error and fixing it the modern way.
- **Actors, Sendable, and offloading:** an actor for shared mutable non-UI state; `@concurrent` versus `nonisolated(nonsending)`; the `@MainActor.assumeIsolated` delegate bridge; deliberate `Sendable` boundaries; `Task` plus a clock, never `Timer`.
- **`@Observable` end to end:** an `@Observable` model observed by a SwiftUI view; streaming changes with the `Observations` async sequence; driving a background task off the same model.
- **Typed errors and value semantics:** a typed domain error (`enum`, `Error`, `CustomStringConvertible`); `throws(E)` versus untyped throws; value types by default; a small attached macro tested via `assertMacroExpansion`.
- **The migration on-ramp (from the WAND shape):** take a real `ObservableObject` + Combine + `.main`-closure + `Date`-timer slice on Swift 5 / iOS 16 and walk it to `@Observable` + actor + `Task`-clock under strict concurrency complete. This is the reader's actual starting point.

### Part 3 — SwiftUI and app architecture  (`recipes/03-swiftui-architecture/`)
- **MV architecture and vertical slices:** MV over MVVM (`@Observable` models in `@State`, `@Bindable` bindings, `@Environment` for shared instances), with an honest "when MVVM still earns its keep" sidebar; the vertical-slice local-SPM workspace with inward-only dependencies over a `Core` package.
- **Dependency injection and the clock:** Point-Free `swift-dependencies` as one idiom (live / preview / test values, a controllable clock, the Swift Testing trait), alongside the house plain-Swift value-type default.
- **Navigation and state:** type-safe `NavigationStack` routing in a `Routing/` slice; view identity and the view tree as the mental model that prevents bugs; who owns `@State`, `@Bindable`, `@Environment`; deep links into a `NavigationPath`.
- **Liquid Glass and accessibility:** Liquid Glass on the navigation layer only, content kept opaque; honoring Reduce Transparency and Increase Contrast; a distinctive theme that avoids templated defaults; the iOS 26.1 menu-in-container pitfall.

### Part 4 — Persistence and data with SwiftData  (`recipes/04-persistence-swiftdata/`)
- **Modeling with SwiftData:** a `@Model` graph with relationships; class inheritance and is-type predicates; `#Index` / `#Unique` / `#Expression`; an in-memory `ModelContainer` for golden-vector query tests.
- **Background writes the Swift 6 way:** a `@ModelActor` importer taking `Sendable` inputs, passing `PersistentIdentifier` across actors, never letting `ModelContext` or `@Model` escape, compiling clean under strict concurrency complete.
- **Migrations without data loss:** `VersionedSchema` plus `SchemaMigrationPlan` (lightweight and custom stages); `propertiesToFetch` to bound memory; a migration test that asserts no data is lost.
- **When not SwiftData:** the Core Data coexistence checklist; the iOS 17 floor as the decision boundary; the `@Attribute(.codable)` escape hatch and its caveats; choosing SwiftData versus Core Data versus a SQLite library.

### Part 5 — Networking  (`recipes/05-networking/`)
- **A typed networking layer:** an actor API client over `URLSession` async-await; validating `HTTPURLResponse` status into a typed domain error; a centralized `JSONDecoder`; `os.Logger` per subsystem; streaming a response with `bytes(for:)`.
- **Cancellation and parallel fetch:** cancel-previous search-as-you-type; honoring cancellation with `try Task.checkCancellation()`; `withThrowingTaskGroup` with bounded concurrency; SwiftUI `.task` auto-cancel.
- **HTTP caching done right:** configuring `URLCache`; ETag and 304 conditional revalidation; filtering with `willCacheResponse`; why not to subclass `URLCache`.

### Part 6 — AI features in iOS apps  (`recipes/06-ai-features/`)
*The headline part, where the two axes meet the product.*
- **On-device with Foundation Models:** a summarizer on the on-device model; guided generation with `@Generable` and `@Guide`; a `Tool` the model can call; the availability switch (device not eligible, not enabled, not ready); streaming as cumulative partial snapshots. (device-required tier)
- **Cloud Claude from Swift:** a chat call via the locked Swift client; adaptive thinking and the effort control; defining a Claude tool from Swift with consolidated, namespaced, semantic fields; structured output decoded into a `Codable` type; the hard rule that no API key ships in the binary; prompt caching with a stable system prefix; a mid-conversation system note for multi-turn chats.
- **The hybrid on-device + Claude assistant (flagship):** on-device for quick private turns, escalating to cloud Claude for frontier reasoning, with the pure routing logic unit-tested as golden vectors and the framework glue verified on device; handling `rateLimited` and `contextSizeExceeded`; a forward note on the one-line provider swap in Appendix A.
- **Agentic iOS apps that call Claude:** the augmented-LLM ladder recast for iOS (one message, then a routing workflow, then a real tool-use agent loop), each a runnable target, escalating only when a test proves the simpler tier insufficient.

### Part 7 — Testing  (`recipes/07-testing/`)
- **Swift Testing fundamentals:** `@Test` / `@Suite` / `#expect` / `#require`; `init` / `deinit` replacing `setUp` / `tearDown`; traits; the two XCTest-only escape hatches.
- **Golden-vector tests for pure logic:** parameterized cases with `@Test(arguments: zip(...))`; when to add `.serialized`; testing a typed error with `#expect(throws:)`; exit tests for precondition logic and why not on an iOS device.
- **Snapshot and UI testing:** view snapshots with a recording trait and `perceptualPrecision`; pinning a simulator for determinism; the XCUI automation escape hatch; preferring behavioral assertions for visual recipes (see section 5).

### Part 8 — Tooling and CI/CD  (`recipes/08-tooling-ci/`)
- **Build and project generation:** the workspace `Package.swift`; `swift build` then `swift test` as the terminal-native verify loop; XcodeGen `Project.yml` for app recipes; Tuist as the scale-up modular-caching option.
- **Format, lint, and hooks:** `swift-format` with `--language-mode 6` and a committed config; SwiftLint via the build-tool plugin; a PostToolUse hook that formats after every edit; a hook that blocks edits to generated output.
- **Continuous integration:** a GitHub Actions workflow (`xcodebuild test` with an xcresult artifact, no code signing for unit tests, an Xcode-version matrix, a pinned runner); a model-currency CI gate; Xcode Cloud as the Apple-native alternative; headless Claude in CI for read-only analysis.
- **Release to TestFlight and the App Store:** `fastlane` authenticated via an App Store Connect API key kept out of tracked files; external tester groups and the 90-day build expiry; a StoreKit 2 async purchase flow.

### Part 9 — Cross-cutting concerns  (`recipes/09-cross-cutting/`)
- **Accessibility as a cross-cutting rule:** Dynamic Type that reflows; VoiceOver labels, hints, and traits on a custom control; `accessibilityLinkedGroup` for a reading view; an accessibility audit pass driven by Claude. (Part 9 is the canonical, normative treatment; Part 3 references it rather than re-teaching it.)
- **Performance and observability:** `os.Logger` subsystems and signposts; catching unexpected `@Observable` re-renders; a centralized `Config` enum; profile, fix, verify.
- **Security (normative home for the secrets discipline):** Keychain storage with the right accessibility class; App Attest gating a backend relay; the backend-relay contract for Claude API calls; what never goes in a tracked file. Parts 0, 6, and 8 link here rather than restating it.
- **The modern 2026 surface:** an App Intent powering Siri, Shortcuts, and Spotlight, with golden-path tests; a `Chart3D` / `SurfacePlot` visualization; an App-Intent-driven interactive widget and a Live Activity; on-device Translation with `translationTask`.

### Appendix A — The iOS 27 frontier (forward-looking)  (`appendix/A-ios27-frontier/`)
Every iOS 27 / Xcode 27 / Swift 6.4 beta feature is quarantined here, each entry dated "current as of June 2026 (WWDC26 beta)" and marked not-yet-GM, so no core recipe depends on pre-release APIs.
- The third-party Claude language-model provider for Foundation Models (the one-line model swap that turns the hybrid flagship's escalation into a provider change), with the feature-gap table that says when to reach past it to the Messages-API client instead.
- iOS 27 SwiftData (`ResultsObserver`, history-driven offline sync, sectioned queries, composite predicates) and SwiftUI (the Document API, AsyncImage HTTP caching).
- The toolchain frontier: Swift 6.4, Xcode 27 test-interoperability modes, Instruments 27.

### Appendix B — Contributing and the currency protocol  (`appendix/B-contributing/`)
- Adding a recipe: the `/new-recipe` scaffold, the `recipes.yaml` schema and tag set, dated-and-attributed authority, the pre-commit and CI gates, keeping the Obsidian mirror in sync from one source of truth.
- The currency recheck protocol: the version-fact checklist, the open questions to resolve before publishing, and the documented promotion event for moving an Appendix A feature into a core recipe at iOS 27 GA.

---

## 8. The Claude-native layer

This is what makes the book Claude-native rather than a normal cookbook with a chatbot bolted on. For this public cookbook the `.claude/` directory is shipped in-repo, a deliberate exception to the solo-repo zero-trace convention, because the setup is the teaching subject.

**The repo-root `CLAUDE.md`** stays under 200 lines and links context docs on demand. It imports the canonical `SWIFT.md` and points at the verify loop, the skills, and the subagent doctrine.

**The canonical `SWIFT.md`** encodes the locked idiom as constraints Claude must obey. It is imported from `CLAUDE.md` (or applied as a path-scoped rule on `**/*.swift`). Proposed content:

```
# SWIFT.md — how Claude writes Swift in this repo

Concurrency
- Swift 6 language mode, strict concurrency complete, warnings as errors.
- MainActor default isolation. UI and app state are isolated; pure-logic test targets are nonisolated.
- Actors for shared mutable non-UI state. @MainActor for UI.
- Offload deliberately with @concurrent; inherit caller isolation with nonisolated(nonsending).
- Sendable boundaries are deliberate. No @unchecked Sendable without a one-sentence justification.
- Timing uses a Task with a clock. No Timer. No DispatchQueue in app logic.
- Bridge delegate callbacks with MainActor.assumeIsolated after extracting Sendable values.

State and types
- @Observable from the Observation framework. Never ObservableObject or @Published for new code.
- Value types by default. Reach for class or actor only for reference identity or isolation.
- Typed domain errors: enum, Error, CustomStringConvertible.

Logging and config
- os.Logger per subsystem. Never print in app logic.
- Magic numbers live in one centralized Config enum, each tied to a source.

UI
- Accessibility on every control: Dynamic Type and VoiceOver labels. Color is never the only signal.

Secrets
- No Anthropic or third-party API key in the app binary. Dev keys come from a gitignored xcconfig.
  Shipping calls go through the backend relay (see security recipe).

How to work here
- Investigate before answering. Read the relevant files first.
- Do not over-engineer. The simplest change that satisfies the test wins.
- Do not hardcode to the tests. Solve the general case.
- Clean up temporary files you create.
- Phrasing note for maintainers: this file avoids CRITICAL and You MUST, because Opus 4.8 over-triggers
  on emphatic phrasing. State the rule plainly once.
```

**Skills** are the repeatable-task primitive. `/new-recipe` scaffolds a buildable target plus a Swift Testing stub and a `recipes.yaml` entry; `/swift-build` and `/swift-test` pre-approve safe commands via `allowed-tools` and inline live output through dynamic context injection; `/commit` and `/draft-recipe-prose` are side-effecting and set `disable-model-invocation: true`. Slash commands still work but skills are the preferred form.

**Subagents** are isolated single-writer research and review workers, never coordinating peers. A research subagent maps an unfamiliar Swift module; an adversarial code-review subagent sees only the diff and correctness criteria. The book ships a concrete `swift-researcher` agent that inlines the `SWIFT.md` constraints, because `Explore` and `Plan` forks do not load `CLAUDE.md` on their own, and a recipe that proves the difference with captured evidence (section 12).

**Hooks** hold the must-always-happen hygiene, since the docs treat `CLAUDE.md` as advisory and hooks as guaranteed: a PostToolUse hook formats and lints after every edit, and a Stop hook blocks until `swift test` is green.

**The per-recipe prompt** follows explore, plan, implement, commit, opens with a one-liner plus the `SWIFT.md` excerpt that constrains the build, uses provide-specific-context prompting, and ends with the verify loop. Claude code samples standardize on `claude-opus-4-8` with adaptive thinking and the effort control, structured outputs rather than assistant prefill, and no `budget_tokens`, per the project's claude-api reference. The exact parameter surface of the chosen Swift client is confirmed by the spike in section 12 before any cloud recipe locks.

**The verify loop** is the throughline: a two-tier check Claude runs on its own output, `swift build` plus `swift test` for pure-logic golden vectors and an on-device or simulator build for framework glue, gated deterministically by the Stop hook.

The canonical Claude Code source cited throughout is `code.claude.com/docs`, so the house cite-a-source rule holds.

---

## 9. Toolchain

- Swift 6.3 toolchain via Xcode 26.5 (strict concurrency complete, `MainActor` default isolation, warnings as errors).
- Swift Package Manager: each recipe is its own standalone package; an aggregate `scripts/test_all.sh` builds and tests every recipe package, and `swift build` then `swift test` inside a recipe is the canonical verify loop. A single root `Package.swift` is intentionally avoided, since nested packages conflict.
- Swift Testing (in-toolchain) as the framework of record. XCTest only for XCUI automation and performance measure blocks.
- `swift-snapshot-testing` in test targets for view snapshots, pinned to a fixed simulator with `perceptualPrecision`, used sparingly per section 5.
- `swift-format` (in-toolchain, committed config, `--language-mode 6`) as the formatter of record.
- SwiftLint via the SimplyDanny build-tool plugin with a committed `.swiftlint.yml`.
- XcodeGen `Project.yml` for app recipes; Tuist as the scale-up modular-caching option; a gitignored `Secrets.xcconfig` for local dev secrets.
- Point-Free `swift-dependencies` for DI and a controllable clock, integrated with Swift Testing traits.
- The locked Swift client for cloud Claude calls (section 12), or a raw-`URLSession` `/v1/messages` path that also demonstrates the typed-networking idiom.
- pre-commit hooks plus Claude Code hooks for deterministic local enforcement.
- GitHub Actions on a pinned macOS runner as default CI; Xcode Cloud documented as the Apple-native alternative.
- `fastlane` authenticated via an App Store Connect API key kept out of tracked files.

---

## 10. Repository structure

```
sams-cookbook/
├── README.md                      # thesis, how to run, the runnability matrix, currency contract
├── SPEC.md                        # this file
├── LICENSE                        # MIT
├── CLAUDE.md                      # under 200 lines, links context/ on demand, imports SWIFT.md
├── SWIFT.md                       # canonical Swift 6 constraint rules for Claude
├── scripts/                       # test_all.sh (aggregate runner), check_manifest.sh, format/Stop hooks
├── versions.lock                  # single source of truth for every pinned version + Claude model id
├── recipes.yaml                   # machine-readable manifest (title/path/tags/author/date/tier/desc)
├── .swift-format                  # committed formatter config (--language-mode 6)
├── .swiftlint.yml                 # committed lint config
├── .pre-commit-config.yaml
├── .gitignore                     # excludes Secrets.xcconfig, build artifacts
├── Secrets.example.xcconfig       # template; the real file is gitignored
├── .claude/
│   ├── settings.json              # hooks: PostToolUse format+lint, Stop gate on swift test
│   ├── skills/
│   │   ├── new-recipe/SKILL.md
│   │   ├── swift-build/SKILL.md
│   │   ├── swift-test/SKILL.md
│   │   ├── commit/SKILL.md         # disable-model-invocation: true
│   │   └── draft-recipe-prose/SKILL.md
│   ├── agents/
│   │   ├── swift-researcher.md     # isolated read-only module mapping, inlines SWIFT.md
│   │   └── code-reviewer.md        # adversarial, diff + correctness criteria only
│   └── rules/
│       └── swift.md                # paths: ['**/*.swift'] constraint rule
├── context/                       # on-demand docs linked from CLAUDE.md
│   ├── concurrency-posture.md
│   ├── subagent-doctrine.md
│   ├── verify-loop.md
│   └── voice-guide.md
├── docs/
│   ├── recipe-template.md
│   ├── CONTRIBUTING.md
│   ├── SOURCES.md
│   └── currency-protocol.md
├── recipes/
│   ├── 01-driving-claude/
│   ├── 02-language-concurrency/
│   │   └── concurrency-posture/
│   │       ├── README.md          # the recipe (template sections)
│   │       ├── Package.swift
│   │       ├── Sources/
│   │       │   ├── Routing/        # vertical slices, never Models/ Views/ Services/
│   │       │   ├── Sensors/
│   │       │   └── Networking/
│   │       ├── Tests/             # Swift Testing golden vectors
│   │       ├── prompts/           # the Claude one-liner + SPEC.md
│   │       └── verify-output/     # retained real test logs / device transcripts
│   ├── 03-swiftui-architecture/
│   ├── 04-persistence-swiftdata/
│   ├── 05-networking/
│   ├── 06-ai-features/
│   │   ├── on-device-summarizer/   # device-required
│   │   ├── cloud-claude-chat/
│   │   └── hybrid-assistant/       # flagship
│   ├── 07-testing/
│   ├── 08-tooling-ci/
│   └── 09-cross-cutting/
├── samples/
│   └── backend-relay/              # minimal runnable edge proxy (Cloudflare Worker) + App Attest verify
├── appendix/
│   ├── A-ios27-frontier/
│   └── B-contributing/
└── .github/
    └── workflows/
        ├── ci.yml                  # xcodebuild test, xcresult artifact, no signing, Xcode matrix
        ├── manifest-check.yml      # recipes.yaml <-> recipes/ consistency gate
        └── model-currency.yml      # claude -p, checks versions.lock against current model ids
```

---

## 11. Manifest and currency protocol

**`recipes.yaml`** is the machine-readable manifest. Each entry carries title, path, capability tags, author (inline, so there is no separate authors registry to drift), date, runnability tier, and a one-to-three sentence description. The capability tag set: Concurrency, Observation, Sensors, Networking, Persistence, Accessibility, Testing, Claude-Native-Build, AI-OnDevice, AI-Cloud, Migration, Tooling.

**A manifest consistency gate** (`manifest-check.yml`) asserts that every directory under `recipes/` has exactly one `recipes.yaml` entry and the reverse, so manual edits cannot silently drift from the filesystem. The `/new-recipe` skill writes both sides, but the gate is what enforces them.

**`versions.lock`** is the single source of truth for every pinned version: Swift, Xcode, the iOS deployment floor, the test simulator, every library version, and the Claude model id. Prose references it instead of restating build numbers. The `model-currency.yml` gate checks the locked model id against the current model list and flags drift.

**The promotion event.** When iOS 27 reaches GM, the Appendix A entries promote into Parts 4, 6, and 7, and the appendix shrinks. This is a documented release step in Appendix B, not an ad-hoc edit, so the "most modern" thesis stays auditable across OS cycles.

---

## 12. Open risks and required spikes before lock

These came out of the adversarial review and must be resolved before the affected recipes are written.

1. **Swift client for the Claude Messages API (high).** There is no official Anthropic Swift SDK. The de-facto community client is `SwiftAnthropic`, whose README model ids are stale. Before any cloud-Claude recipe locks, a spike confirms the current version exposes the `claude-opus-4-8` model string, adaptive thinking, the effort control, and structured outputs, with no `budget_tokens` or prefill. If it falls short, the runnable fallback is a raw-`URLSession` `/v1/messages` client, which also demonstrates the typed-networking idiom. The spike records the exact version and the JSON it emits.

2. **Backend relay (decided, ship it).** The "no key in the binary, relay for shipping" rule ships as a real runnable artifact under `samples/backend-relay/`. The reference implementation is a stateless edge function (a Cloudflare Worker), chosen because it is the industry-standard, lowest-ops, best-scaling way to proxy an LLM API key: it scales horizontally with no servers to manage, holds the Anthropic key in a server-side secret, verifies an Apple App Attest assertion so only genuine instances of the app can spend the key, streams the Server-Sent-Events response straight through, and enforces per-device rate limits. An all-Swift server (Hummingbird or Vapor) is documented as an equivalent alternative for teams that want to stay in one language. The only remaining spike here is verifying the App Attest attest-then-assert handshake end to end against a real device, since that step is device-required and cannot be exercised in CI.

3. **Explore / Plan forks and `SWIFT.md` (medium).** The highest-frequency Claude-native failure mode is a subagent generating Swift that violates strict concurrency because it never saw `SWIFT.md`. The fix ships as a tested artifact: the `swift-researcher` agent that inlines the constraints, plus a recipe that shows compliant versus non-compliant output with and without the inlined rules, with evidence in `verify-output/`.

4. **Foundation Models on CI (resolved by tiering).** Foundation Models recipes are device-required and cannot run in headless CI. Section 5 makes this a repo-level contract; these recipes ship a recorded transcript and a "requires device" banner.

5. **Snapshot-test brittleness (resolved by tiering).** Visual recipes prefer behavioral and accessibility assertions over pixel snapshots. Any retained snapshot pins its simulator in `versions.lock`.

---

## 13. House voice

This applies to every `README.md`, recipe, and doc, and to this spec. The rules are shipped as the `/draft-recipe-prose` skill so Claude obeys them.

- We-voice by default. "I" only for a personal judgment in a reflection.
- No em dashes. Restructure, use a comma or semicolon or parentheses, or split the sentence.
- No AI-tell vocabulary: delve, leverage, showcase, robust, seamless, tapestry, at its core, navigate the complexities, in essence, it is worth noting.
- Straight quotes, not curly.
- Captions are one to three sentences.
- A reflection carries a difficulty encountered plus a forward note.
- Every rule cites a published source.
- Write like a sharp teammate, not a consultant. Plain headers beat clever ones.

---

## 14. Sources

Primary sources are the citation of record; secondary sources are teaching companions.

**Primary**
- Claude Code docs (best practices, skills, subagents, hooks, headless): `https://code.claude.com/docs/en/best-practices`. Canonical for every Claude-native rule.
- Anthropic, Building Effective Agents: `https://www.anthropic.com/research/building-effective-agents`. The agent doctrine and tool-design rules.
- Anthropic, How we built our multi-agent research system: `https://www.anthropic.com/engineering/multi-agent-research-system`. The single-writer subagent doctrine.
- Anthropic prompting and model docs: `https://platform.claude.com/docs`. Current model rules (`claude-opus-4-8`, adaptive thinking, effort, structured outputs).
- Anthropic Cookbook: `https://github.com/anthropics/claude-cookbooks`. The structural model for recipe anatomy, the manifest, and the runnable-and-verified mandate.
- Anthropic ClaudeForFoundationModels: `https://platform.claude.com/docs/en/cli-sdks-libraries/libraries/apple-foundation-models`. Appendix A provider path (iOS 27 beta).
- Apple Developer Documentation: `https://developer.apple.com/documentation/`. Version-of-record for every API a recipe names.
- Apple WWDC sessions and guides: `https://developer.apple.com/wwdc26/`. Dated source for every "new in" claim.
- swift.org (blog, migration guide, Swift Testing and swift-format repos): `https://www.swift.org/blog/`. The language and toolchain baseline.
- swift-evolution: `https://github.com/swiftlang/swift-evolution`. Rationale of record for the concurrency rules (SE-0461, SE-0466, SE-0413).
- Apple Swift Testing docs and the migration-from-XCTest guide: `https://developer.apple.com/documentation/testing`.
- Tooling primaries: `swift-format`, SwiftLint, Tuist, fastlane, Xcode Cloud, NSHipster on `URLCache`, Apple HIG Materials.

**Secondary**
- `SwiftAnthropic` (jamesrochabrun): `https://github.com/jamesrochabrun/SwiftAnthropic`. The de-facto Messages-API client, pending the section 12 spike.
- Point-Free: `https://github.com/pointfreeco`. `swift-dependencies` and `swift-snapshot-testing`.
- MV-over-MVVM and modern-SwiftUI authors (Ricouard, Hudson, Jabrayilov, Panferova, NimbleHQ, objc.io).
- Practical concurrency, persistence, and tooling authors (Wals, van der Lee, Sundell, Fatbobman).

---

## 15. Build roadmap

A suggested order that front-loads the load-bearing pieces and proves the format early.

1. **Foundation:** scaffold the repo (this structure), write `CLAUDE.md`, `SWIFT.md`, `versions.lock`, the README with the runnability matrix, and the `.claude/` skills and hooks.
2. **Spikes:** resolve the section 12 risks, the Swift Claude client first, since Part 6 depends on it.
3. **Prove the format:** build one logic-runnable recipe end to end in Part 2 (the concurrency posture) so the template, the `/new-recipe` skill, the verify loop, and CI are all exercised on a real example.
4. **Migration on-ramp:** the WAND-to-modern recipe in Part 2, since it is the reader's true entry point.
5. **Vertical depth:** Parts 3 through 9, with the Part 6 AI flagship as the marquee recipe.
6. **Appendices and currency:** Appendix A frontier notes, Appendix B contributing and currency protocol, and the promotion-event documentation.

---

## 16. Decisions resolved

All four open decisions are now locked into this spec.

- **Backend relay:** ship it as a runnable sample. Reference is a stateless edge function (Cloudflare Worker) with App Attest verification and server-side key injection, the industry-standard production pattern, with an all-Swift server as the documented alternative (section 12, item 2).
- **Recipe independence:** every recipe is fully standalone, its own target with no cross-recipe code dependency. No composed demo app (sections 2 and 6).
- **License:** MIT, matching the starter packs (section 2).
- **First recipe after scaffolding:** the concurrency-posture recipe in Part 2. It is logic-runnable, so it proves the whole pipeline end to end (the template, the `/new-recipe` skill, the verify loop, golden vectors, and CI) on a low-risk example before the device-required AI flagship (sections 2 and 15).

The only items left before writing code are the two build-time spikes in section 12 that are verifications, not choices: confirming the Swift client exposes the current Claude API surface, and confirming the App Attest handshake on a real device.
