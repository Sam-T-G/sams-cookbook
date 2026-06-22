# The concurrency posture

The Swift 6 concurrency baseline the whole cookbook assumes. The short version is in `SWIFT.md`; this is the
why, with sources. The working recipe is `recipes/02-language-concurrency/concurrency-posture`.

## What we set, and where

In each package's `Package.swift`:

- `.swiftLanguageMode(.v6)` so strict concurrency is complete, not a warning-only opt-in.
- `.defaultIsolation(MainActor.self)` so the default isolation is the main actor. Anything we do not
  annotate is main-actor isolated, which makes UI-facing code safe by default with no annotation to forget.
  (SE-0466, requires `swift-tools-version: 6.2`)
- `-warnings-as-errors` so a data-race warning, a deprecation, or an unused value fails the build instead of
  becoming yellow noise that hides the one warning that matters.

## The three moves

1. **Pure logic opts out with `nonisolated`.** Geometry, parsing, formatting, and value types have no main-
   actor surface, so they are `nonisolated` and callable from anywhere without an await. This is what keeps
   them in a logic-runnable target with golden-vector tests.
2. **Shared mutable non-UI state is an `actor`.** Not a lock, not a serial queue. The actor is the single
   writer, so the compiler proves there are no data races and ordering is total. Inputs are `Sendable` value
   types, so nothing non-Sendable crosses the boundary.
3. **UI and coordinators stay on the main actor (the default) and reach actors with `await`.** The await is
   the compiler making the hop visible, not friction. Offload deliberately with `@concurrent`; inherit the
   caller's isolation with `nonisolated(nonsending)`. (SE-0461) Never reflexively escape the main actor.

## Bridging delegates

CoreLocation and CoreMotion deliver callbacks on a thread, with non-Sendable objects. Read the Sendable
values (the Doubles) in the `nonisolated` delegate method, then hop with `MainActor.assumeIsolated`. Do not
carry the non-Sendable object across the boundary. (Apple concurrency docs)

## Timing

Use a `Task` with a clock, never `Timer`, and never `DispatchQueue` in app logic. A heartbeat is
`Task { while !Task.isCancelled { try await Task.sleep(for: .milliseconds(n)); ... } }`. A controllable clock
(Part 3's dependency-injection recipe) makes timing testable.
