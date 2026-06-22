# Migrating from Combine and ObservableObject

Take a real `ObservableObject` + Combine view model and walk it to `@Observable` plus an `actor`, with a
parity test that proves the rewrite preserves behavior step for step. This is the starting point most
existing iOS code is actually at.

**Tier:** logic-runnable (runs `swift test` on any host with the Swift toolchain).

## Tags and metadata

- Tags: Concurrency, Observation, Migration, Claude-Native-Build, Testing
- Author: Samuel Gerungan
- Built against: Swift 6.3 / Xcode 26.5 / iOS 26 / claude-opus-4-8, on 2026-06-21
- Verified output: [`verify-output/test-run.txt`](verify-output/test-run.txt)

## Pinned versions

See [`versions.lock`](../../../versions.lock). The package holds two targets: `LegacyFeed` builds in the
Swift 5 language mode (the world the old code came from), and `ModernFeed` builds in the full posture
from the concurrency-posture recipe (Swift 6 mode, MainActor default isolation, warnings as errors).

## Prerequisites

The Swift toolchain. No simulator or device. Around 20 minutes. Read the concurrency-posture recipe first;
this one assumes that posture as the destination.

## Problem

Most iOS code did not start in the modern idiom. It started with `ObservableObject`, `@Published`, and a
plain array mutated on whatever thread called in. That shape works in a single-threaded view, so there is
rarely a crash to force the issue, which is exactly why it lingers. We want a repeatable way to move it to
`@Observable` and an `actor` without changing what the feature does, and a test that proves we did not.

## Baseline

[`LegacyReadingStore`](Sources/LegacyFeed/LegacyReadingStore.swift) is the legacy shape: an
`ObservableObject` with `@Published private(set) var average` and a private array, mutated synchronously in
`ingest`. Two things age it. Nothing stops a background caller from racing the array, and SwiftUI pays the
Combine `objectWillChange` cost on every change rather than tracking the one property a view reads.

## Modern solution (Swift)

The migration is two moves:

1. Move the mutable state out of the view model and into an `actor`
   ([`ReadingBuffer`](Sources/ModernFeed/ReadingBuffer.swift)). The actor is the only writer, so concurrent
   ingest is race-free with no lock and no `DispatchQueue`.
2. Replace `ObservableObject` and `@Published` with `@Observable`
   ([`ModernReadingStore`](Sources/ModernFeed/ModernReadingStore.swift)). The model keeps only the derived
   value the view shows; `ingest` becomes `async` because it hops to the actor, and that await is the
   compiler making the boundary visible.

The mapping is mechanical, which is what makes it a safe migration: `ObservableObject` to `@Observable`,
`@Published var` to a plain `var`, the shared array to an `actor`, synchronous mutation to an `await`.

## Build it with Claude

The one-liner that drives the migration:

> Migrate this ObservableObject + Combine store to @Observable plus an actor, following SWIFT.md. Keep the
> public behavior identical. Add a parity test that runs the same input sequence through the old and new
> stores and asserts the averages match at every step.

The `SWIFT.md` rules that constrain it: `@Observable` only (no `ObservableObject` or `@Published` in new
code), an actor for shared mutable state, no `DispatchQueue`, value types and typed boundaries. The verify
loop is the parity test: `swift build` then `swift test`, with the Stop hook refusing to end while red. The
parity test is the safety rail, so write it first and let it judge the rewrite.

## Verify / tests

```sh
swift build
swift test
```

Four tests across two suites pass: a step-for-step parity check between the legacy and modern stores, a
both-start-at-zero check, and exact-average and eviction checks on the modern store. The captured run is in
[`verify-output/test-run.txt`](verify-output/test-run.txt).

## Pitfalls and trade-offs

- `ingest` becomes `async`. Call sites change, and a SwiftUI caller uses `.task` or a `Task`. That ripple is
  the cost of moving shared state behind an actor, and it is usually small.
- Keeping both stores in one package is a teaching device. In a real migration you replace the legacy type,
  you do not ship both. The parity test is the bridge: keep the old type until the test is green, then delete
  it.
- `@Observable` tracks per-property reads, so a view that read the whole object before may now update less
  often. That is a win, but watch for a view that relied on the blanket `objectWillChange`.

## Decision guidance

Use this whenever you touch an `ObservableObject` for a real change. Do not rewrite the whole app at once;
migrate a slice, prove parity, delete the legacy type, move on. If a type has no shared mutable state, the
migration is just `ObservableObject` to `@Observable` with no actor, which is even simpler.

## Reflection

The interesting part was deciding what the parity test should compare. Comparing only the final average
would have passed even if the intermediate states diverged, so the test asserts at every step, which is what
makes it a real safety rail rather than a rubber stamp. The forward note is cancellation: once `ingest` is
async, a fast input stream wants cancel-previous semantics, which the networking recipes in Part 5 cover.

## Next steps and related recipes

- The concurrency-posture recipe in this part, which defines the destination posture.
- Part 3, MV architecture, for how the migrated `@Observable` model is held in a view with `@State` and
  `@Environment`.
- Part 5, Networking, for cancellation once ingestion is asynchronous.
