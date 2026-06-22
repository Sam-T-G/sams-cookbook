# The prompt that builds this recipe

This recipe is small enough for the explore, plan, implement, commit loop without a separate SPEC.md. The
one-liner is below. Paste it into Claude Code with `SWIFT.md` loaded.

## One-liner

> Build a logic-runnable recipe that sets MainActor default isolation, strict concurrency complete, and
> warnings as errors in Package.swift. Add a `nonisolated` pure-geometry enum (angle normalization and
> shortest signed delta), an `actor` ring buffer of Sendable readings with a typed-error `average()`, and a
> main-actor coordinator that bridges to the actor with await. Write Swift Testing golden vectors for the
> geometry (parameterized) and the buffer (exact average, eviction, empty-throws). Follow SWIFT.md. Run
> `swift build` then `swift test` and do not stop until both are green.

## What constrains it

- `SWIFT.md` at the repo root: actors for shared mutable non-UI state, `nonisolated` for pure logic, typed
  domain errors, value types by default, no `DispatchQueue`, no `Timer`.
- The verify loop: `swift build` then `swift test`. The Stop hook in `.claude/settings.json` blocks a stop
  while tests are red.

## What to expect Claude to get wrong the first time

A public initializer whose default argument references an internal `Config` fails to build. The fix is to
make `Config` and its constant public. The captured run in `verify-output/test-run.txt` shows the green
result after that fix.
