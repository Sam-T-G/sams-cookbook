# Using this cookbook to build an iOS app: a guide for agents

You are an agent (Claude Code or similar) building an iOS app in some other repository. This cookbook is your
reference library: a set of standalone, tested recipes for modern iOS, each paired with the prompt and rules
that produce it. This guide tells you how to navigate it, what to copy, and how to verify the result.

It assumes the cookbook lives somewhere you can read (cloned locally, or browsed on GitHub at
`Sam-T-G/sams-cookbook`). You are not editing the cookbook; you are mining it to build a different app.

## 1. Read these first (the contract)

Before writing any Swift for the app, read these files from the cookbook root and carry their rules into the
app you are building:

- `SWIFT.md`: the non-negotiable Swift rules: Swift 6 strict concurrency, `@Observable` over
  `ObservableObject` for new code, actors for shared mutable non-UI state, typed domain errors, value types,
  `os.Logger` not `print`, and no API key in the app binary. This is the single most important file.
- `versions.lock`: the pinned toolchain and the Claude request shape. Use these versions and this request
  shape; do not invent your own.
- `CLAUDE.md`: how the cookbook itself is run, including the verify-loop discipline you should mirror.
- `docs/recipe-template.md`: the shape of a recipe, so you know where to find each piece.
- `context/voice-guide.md`: the writing voice, if you generate any prose (READMEs, comments, PR text).

If you only read one, read `SWIFT.md`.

## 2. The mental model

The cookbook is organized into parts (`recipes/01-...` through `recipes/09-...`) and each part holds recipes.
Every recipe is a self-contained Swift package with the same anatomy: a `README.md` (problem, modern
solution, a "Build it with Claude" section, verify steps, pitfalls), a `Sources/` with the real code, a
`Tests/` with golden vectors, and a `verify-output/test-run.txt` with the captured passing run.

Two properties matter for you:

- **Recipes are standalone.** No recipe imports another. So you copy a pattern into the app and adapt it; you
  do not add the cookbook as a dependency.
- **Recipes declare a runnability tier** (in `recipes.yaml`): `logic-runnable` (pure logic, testable on any
  host), `simulator-required`, or `device-required`. The tier tells you how far you can verify a pattern
  without a simulator or a real device.

## 3. How to apply a recipe to your app

1. **Find the recipe.** Use the task index in section 4, or read `recipes.yaml` and the part READMEs.
2. **Read the recipe README end to end.** The "Modern solution (Swift)" section names the files and types;
   the "Build it with Claude" section gives you the prompt and the rules that constrain it; the "Pitfalls"
   section is the list of mistakes to avoid.
3. **Copy the pattern, do not copy blindly.** Lift the relevant types from the recipe's `Sources/` into your
   app, rename them to your domain, and keep the structure (the actor boundary, the typed error, the
   protocol seam). The recipe's tests show you what behavior to preserve.
4. **Bring the tests with you.** Recreate the golden vectors for your adapted code. If the recipe tests a
   pure decision with a fake seam, do the same in your app; that is what makes the pattern verifiable.
5. **Run the verify loop** (section 6). Do not report the feature done until it is green.

## 4. Task to recipe index

Match what you are building to the recipe that already solves it. "Built" recipes have working code and
tests; "planned" entries name the recipe to come and the pattern to follow from a built one.

| You are building... | Go to | What to copy |
|---|---|---|
| The project's concurrency baseline (the first thing in any new package) | `recipes/02-language-concurrency/concurrency-posture` (built) | The `Package.swift` posture block (`swiftLanguageMode(.v6)` + `defaultIsolation(MainActor.self)` + warnings-as-errors), an `actor` for shared state, `nonisolated` pure logic, typed errors |
| Moving old `ObservableObject` / Combine code to `@Observable` | `recipes/02-language-concurrency/migration-from-combine` (built) | The before/after pair and the parity test that proves the rewrite preserves behavior |
| A networking layer that calls an HTTP API | `recipes/05-networking/typed-api-client` (built) | The `actor` client, the `Transport` protocol seam, status-to-typed-error validation, the centralized decoder |
| Calling Claude (the cloud LLM) from the app | `recipes/06-ai-features/cloud-claude-chat` (built) | The `ClaudeRequest` / `ClaudeResponse` types and the keyless client that targets a backend relay |
| An on-device + cloud AI feature with fallback | `recipes/06-ai-features/hybrid-assistant` (built) | The `LanguageBackend` protocol seam, the pure `EscalationPolicy`, and the orchestrator that escalates on recoverable failures |
| SwiftUI screens and app architecture | `recipes/03-swiftui-architecture` (planned) | Follow the MV-not-MVVM and vertical-slice conventions in `SWIFT.md` and the part README until the recipe lands |
| Local persistence | `recipes/04-persistence-swiftdata` (planned) | Follow the SwiftData conventions in the part README; use the actor-for-background-writes pattern from the concurrency recipe |
| Tests for any of the above | `recipes/07-testing` (planned) | The golden-vector + fake-seam pattern used in every built recipe's `Tests/` is the template |
| Shipping the Claude key safely | `samples/backend-relay` + `recipes/09-cross-cutting` (relay built, security recipe planned) | The relay (edge function with App Attest) and the no-key-in-binary rule from `SWIFT.md` |

When a recipe is planned, the conventions in `SWIFT.md` and the part README still apply; build to them.

## 5. The conventions to carry into the app

These come from `SWIFT.md` and are the difference between code that matches this cookbook and code that does
not. Apply them to every Swift file you write in the app:

- Swift 6 language mode, strict concurrency complete, warnings as errors. Set `MainActor` default isolation
  in `Package.swift`; mark pure logic `nonisolated`.
- `@Observable`, never `ObservableObject` or `@Published`, for new code.
- An `actor` for shared mutable non-UI state. A stateless helper is a `nonisolated struct`, not an actor.
- Typed domain errors (`enum`, `Error`, `CustomStringConvertible`), thrown with `throws(E)` where the set is
  small and exhaustive.
- Value types by default. `os.Logger` per subsystem, not `print`. Magic numbers in one `Config` enum.
- Accessibility on every control (Dynamic Type, VoiceOver labels).
- No Anthropic or third-party API key in the app binary. Dev keys come from a gitignored xcconfig; shipping
  calls go through the backend relay.
- For Claude calls, use the request shape in `versions.lock`: `claude-opus-4-8`, adaptive thinking, the
  effort control under `output_config`, structured outputs via `output_config.format`, and never
  `budget_tokens`, `temperature`, or assistant prefill.

## 6. The verify loop

Mirror the cookbook's discipline. Give the app a check you can run, and run it on your own output:

- For pure logic, write golden-vector tests with Swift Testing and run `swift test`. This runs on any host.
- For framework glue (anything that needs UIKit/SwiftUI runtime, a simulator, or a device), build and run on
  the iOS simulator, or on a device for device-required features (on-device Foundation Models needs eligible
  hardware with Apple Intelligence enabled).
- Capture the real output as evidence. Do not claim a feature works without a run that shows it.

The runnability tier of the recipe you copied tells you which of these applies.

## 7. Staying current

The cookbook pins versions in `versions.lock` and treats the iOS 27 / Xcode 27 / Swift 6.4 frontier as
appendix-only (`appendix/A-ios27-frontier`). When you build the app:

- Use the pinned baseline (Swift 6.3, Xcode 26.5, iOS 26) unless the app has a stated reason to differ.
- Do not pull a pattern from `appendix/A-ios27-frontier` into shipping code; those depend on pre-release
  APIs. They are there so you know what is coming, not to build on today.
- If a version fact looks stale, check `docs/currency-protocol.md` for how the cookbook rechecks it.

## 8. Anti-patterns (do not do these)

- Do not add an Anthropic API key to the app target. Route through the relay.
- Do not use `ObservableObject` / `@Published` for new code. Use `@Observable`.
- Do not reach for an `actor` when there is no shared mutable state; use a `nonisolated struct`.
- Do not silence a data-race warning with `@unchecked Sendable`; fix the isolation.
- Do not use `DispatchQueue` or `Timer` in app logic; use a `Task` with a clock.
- Do not send `budget_tokens`, `temperature`, or an assistant prefill to `claude-opus-4-8`; they 400.
- Do not depend on `SwiftAnthropic` for adaptive thinking, the effort control, or structured outputs; it
  cannot send them. Use the raw client from the cloud-claude-chat recipe.
- Do not copy a recipe's code without its tests.

## 9. A worked example

Task: the app needs a feature that summarizes text on-device for speed and privacy, and falls back to cloud
Claude for long or complex inputs.

1. Read `SWIFT.md` and `versions.lock`.
2. Open `recipes/06-ai-features/hybrid-assistant`. Read the README, then `Sources/HybridAssistant/`.
3. Copy into the app: the `LanguageBackend` protocol, the `EscalationPolicy`, the `HybridAssistant`
   orchestrator, and the `BackendError` type. Rename to your domain if needed.
4. For the cloud tier, open `recipes/06-ai-features/cloud-claude-chat`, copy the `ClaudeClient` /
   `ClaudeRequest` / `ClaudeResponse` types, and wrap the client to conform to `LanguageBackend` (the hybrid
   README shows the wrapper).
5. For the on-device tier, copy the `OnDeviceBackend` (Foundation Models) and keep its `#if
   canImport(FoundationModels)` guard and its error mapping.
6. Recreate the golden vectors: the routing decisions and the escalation behavior, driven by fake backends.
   Run `swift test`. That covers the logic without a device.
7. Verify the live two-tier flow on a device against a running backend relay, and capture the transcript.
8. Confirm: no API key in the binary, `@Observable` for any model the UI holds, typed errors throughout.

That is the loop for any feature: read the rules, find the recipe, copy the pattern with its tests, verify at
the right tier.
