# The concurrency posture

Set MainActor default isolation, strict concurrency complete, and warnings as errors once, at the package
level, so every later recipe inherits a data-race-free baseline instead of re-arguing it per file.

**Tier:** logic-runnable (runs `swift test` on any host with the Swift toolchain).

## Tags and metadata

- Tags: Concurrency, Claude-Native-Build, Testing
- Author: Samuel Gerungan
- Built against: Swift 6.3 / Xcode 26.5 / iOS 26 / claude-opus-4-8, on 2026-06-21
- Verified output: [`verify-output/test-run.txt`](verify-output/test-run.txt)

## Pinned versions

See [`versions.lock`](../../../versions.lock). This recipe uses `swift-tools-version: 6.2` so the package
can set `SwiftSetting.defaultIsolation(MainActor.self)`, and the Swift 6 language mode so strict concurrency
is complete. It builds on the pinned Swift 6.3 toolchain and on newer toolchains.

## Prerequisites

The Swift toolchain. No simulator or device. Around 15 minutes. No prior recipe required; this is the
baseline the rest of the book assumes.

## Problem

Swift 6 can prove your code is free of data races at compile time, but only if you commit to it. Left at the
defaults, a new module compiles in a looser mode, concurrency warnings pile up as yellow noise, and the one
that matters hides among them until it ships as a crash. We want the compiler working for us from the first
file, with a posture that is set once and inherited everywhere, not negotiated per type.

## Baseline

The pre-modern habit is a class with shared mutable state, guarded by a lock or a serial queue, and the hope
that every caller remembers the rule:

```swift
final class SampleBuffer {
    private var readings: [Reading] = []
    private let queue = DispatchQueue(label: "buffer")
    func append(_ r: Reading) { queue.async { self.readings.append(r) } }
    func average() -> Double { queue.sync { /* ... */ } }  // easy to deadlock, easy to forget
}
```

The shortcoming is that nothing checks the rule. A single direct access to `readings` from the wrong thread
is a data race the compiler never sees, and the `queue.sync` inside a `queue.async` is a deadlock waiting
for the wrong call order.

## Modern solution (Swift)

Set the posture in `Package.swift` so it is inherited, not repeated:

```swift
let postureSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .defaultIsolation(MainActor.self),
    .unsafeFlags(["-warnings-as-errors"]),
]
```

With `MainActor` as the default isolation, anything we do not annotate lands on the main actor, so UI-facing
types are safe by default and there is no annotation to forget. Pure logic opts out explicitly with
`nonisolated`, and shared mutable non-UI state moves into an `actor`, which the compiler proves is race-free.

- `Bearing` is pure geometry, marked `nonisolated`, callable from anywhere without an await
  ([`Bearing.swift`](Sources/ConcurrencyPosture/Bearing.swift)).
- `SampleBuffer` is an `actor`; it is the only writer, so ordering is total and there is no torn read
  ([`SampleBuffer.swift`](Sources/ConcurrencyPosture/SampleBuffer.swift)). Its `average()` uses
  `throws(PostureError)`, a typed error, because the failure set is small and exhaustive.
- `PostureCoordinator` is on the main actor because we did not opt out; it reaches the actor through `await`,
  which is the compiler making the hop visible rather than friction
  ([`PostureCoordinator.swift`](Sources/ConcurrencyPosture/PostureCoordinator.swift)).
- `Reading`, `Config`, and `PostureError` are `nonisolated` value types, so they cross the actor boundary
  without ceremony.

## Build it with Claude

The one-liner prompt that scaffolds this recipe:

> Build a logic-runnable recipe that sets MainActor default isolation, strict concurrency complete, and
> warnings as errors in Package.swift. Add a `nonisolated` pure-geometry enum, an `actor` ring buffer of
> Sendable readings with a typed-error `average()`, and a main-actor coordinator that bridges to the actor
> with await. Golden-vector tests for the geometry and the buffer. Follow SWIFT.md.

The rules from [`SWIFT.md`](../../../SWIFT.md) that constrain the result: actors for shared mutable non-UI
state, `@MainActor` (here, the package default) for UI, `nonisolated` for pure logic, typed domain errors,
value types by default, and no `DispatchQueue`. The verify loop Claude runs on its own output: `swift build`
then `swift test`, with the Stop hook refusing to end while tests are red. When Claude first wrote the
`Config` enum it left it internal, and the build failed because a public initializer's default argument
cannot reference an internal symbol; the fix was to make `Config` public, which the captured output records.

## Verify / tests

```sh
swift build
swift test
```

Seven tests across three suites pass: parameterized golden vectors for angle normalization, exact-average
and eviction checks on the actor, a typed-error assertion for the empty buffer, and the main-actor
coordinator bridging into the actor. The full captured run is in
[`verify-output/test-run.txt`](verify-output/test-run.txt).

## Pitfalls and trade-offs

- `-warnings-as-errors` means a deprecation or an unused value fails the build. That is the point, but it
  does make a toolchain bump occasionally noisy; treat that noise as a currency-protocol event, not a reason
  to drop the flag.
- `defaultIsolation(MainActor.self)` needs `swift-tools-version: 6.2` or newer. On an older package manifest
  the setting does not exist and you fall back to annotating `@MainActor` by hand.
- Marking a pure type `nonisolated` is a deliberate choice, not a default. Forgetting it on a value type that
  an actor constructs produces a clear isolation error, which is the compiler steering you, not blocking you.

## Decision guidance

Use this posture for any new package. Prefer an `actor` over a lock or a serial queue for shared mutable
state; reach for `@MainActor` (or the package default) for anything a view touches; mark pure logic
`nonisolated` so it stays testable headlessly. Drop `defaultIsolation(MainActor.self)` only for a pure-logic
library that has no main-actor surface at all, where the default would add awaits with no safety gain.

## Reflection

The piece that bit was the visibility rule on default arguments: the posture compiled, the actor compiled,
but a public initializer reaching for an internal constant did not, and the error pointed at the call site
rather than the constant. The fix was small once read closely. Going forward, the migration on-ramp recipe
in this part takes the opposite starting point, a real Combine and `ObservableObject` slice, and walks it
into this posture, which is where most existing code actually begins.

## Next steps and related recipes

- The migration on-ramp in this part (from the Combine and `ObservableObject` shape).
- Part 5, Networking, for the actor pattern applied to a live `URLSession` client with cancellation.
- Part 7, Testing, for more on parameterized golden vectors and typed-error assertions.
