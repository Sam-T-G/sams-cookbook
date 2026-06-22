# SWIFT.md: how Claude writes Swift in this repo

This file is the contract for every line of Swift in the cookbook. It is imported from `CLAUDE.md`
and also applied as a path-scoped rule on `**/*.swift` (see `.claude/rules/swift.md`). When Claude
writes or edits Swift here, these rules hold. Each rule states a published source so it is auditable,
not folklore. Pinned versions live in `versions.lock`.

## Concurrency

- Swift 6 language mode, strict concurrency complete, warnings as errors. (SE-0337, swift.org migration guide)
- `MainActor` default isolation for app and UI targets; pure-logic targets stay `nonisolated`. Set it in
  `Package.swift` via `SwiftSetting.defaultIsolation(MainActor.self)`. (SE-0466)
- Actors for shared mutable non-UI state. `@MainActor` for UI.
- Offload deliberately with `@concurrent`; inherit the caller's isolation with `nonisolated(nonsending)`.
  Do not reflexively escape `MainActor`. (SE-0461)
- `Sendable` boundaries are deliberate. No `@unchecked Sendable` without a one-sentence justification.
- Timing uses a `Task` with a clock. No `Timer`. No `DispatchQueue` in app logic.
- Bridge non-Sendable delegate callbacks by reading the Sendable values in the `nonisolated` delegate,
  then hopping with `MainActor.assumeIsolated`. (Apple concurrency docs)

## State and types

- `@Observable` from the Observation framework. Never `ObservableObject` or `@Published` for new code.
  (Apple Observation docs)
- Value types by default: `struct` for models, events, and data. Reach for `class` or `actor` only for
  reference identity or isolation.
- Typed domain errors: `enum`, `Error`, `CustomStringConvertible`. Use `throws(E)` for a fixed exhaustive
  error set; untyped `throws` otherwise. (SE-0413)

## Logging and config

- `os.Logger` per subsystem. Never `print` in app logic.
- Magic numbers live in one centralized `Config` enum, each value tied to a source or a measured reason.

## UI

- Accessibility on every control: Dynamic Type and VoiceOver labels. Color is never the only signal.
  (Apple Human Interface Guidelines)
- Liquid Glass on the navigation layer only; keep content opaque. Honor Reduce Transparency and Increase
  Contrast. (Apple HIG Materials)

## Secrets

- No Anthropic or third-party API key in the app binary. Dev keys come from a gitignored `Secrets.xcconfig`.
  Shipping calls go through the backend relay (see `recipes/09-cross-cutting` and `samples/backend-relay`).

## Claude API usage (when a recipe calls Claude)

- Default model `claude-opus-4-8`, adaptive thinking, the effort control (not `budget_tokens`).
- Structured outputs, not assistant prefill (prefill is removed on 4.6+).
- See `versions.lock` for the pinned model id and `recipes/06-ai-features` for the patterns.

## How to work here

- Investigate before answering. Read the relevant files first.
- Do not over-engineer. The simplest change that satisfies the test wins.
- Do not hardcode to the tests. Solve the general case.
- Clean up temporary files you create.
- Keep pure logic separate from framework glue so it can sit in a logic-runnable target with golden-vector
  tests (see the runnability tiers in `README.md`).

> Phrasing note for maintainers: this file avoids "CRITICAL" and "You MUST", because Opus 4.8 over-triggers
> on emphatic phrasing. State each rule plainly once. (code.claude.com/docs)
