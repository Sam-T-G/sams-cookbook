# Part 2 — Modern Swift language and concurrency

The Swift 6.3 language baseline the whole book assumes, plus the migration on-ramp from the older Combine
and `ObservableObject` shape that most existing code actually starts from.

## Recipes

- **The concurrency posture** (built, logic-runnable) — `concurrency-posture/`. MainActor default isolation,
  strict concurrency complete, warnings as errors, an actor for shared state, typed errors, golden vectors.
  This is the first recipe and the proof of the whole pipeline.
- **Actors, Sendable, and offloading** (planned) — `@concurrent` vs `nonisolated(nonsending)`, the
  `@MainActor.assumeIsolated` delegate bridge, `Task` plus a clock.
- **@Observable end to end** (planned) — an `@Observable` model observed by SwiftUI and driven by a
  background task via the `Observations` async sequence.
- **Typed errors and value semantics** (planned) — `throws(E)` vs untyped throws, a small attached macro.
- **Migrating from Combine and ObservableObject** (built, logic-runnable) — `migration-from-combine/`.
  Walks a real `ObservableObject` + Combine store to `@Observable` plus an actor, with a parity test that
  proves the rewrite preserves behavior step for step. The on-ramp from where most code actually starts.

Add a recipe with `/new-recipe 02-language-concurrency <slug>`.
