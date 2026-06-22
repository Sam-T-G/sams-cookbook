# The prompt that builds this recipe

Small enough for the explore, plan, implement, commit loop without a separate SPEC.md. Paste the one-liner
into Claude Code with `SWIFT.md` loaded, and with the legacy store already present.

## One-liner

> Migrate this ObservableObject + Combine store to @Observable plus an actor, following SWIFT.md. Keep the
> public behavior identical: same capacity, same rolling average, same starting value. Move the mutable
> array into an actor, make ingest async, and replace @Published with a plain var on an @Observable model.
> Write a parity test that runs the same input sequence through the old and new stores and asserts the
> averages match at every step, plus exact-average and eviction tests on the new store. Run `swift build`
> then `swift test` and do not stop until both are green.

## What constrains it

- `SWIFT.md`: `@Observable` only, an actor for shared mutable state, no `DispatchQueue`, typed boundaries.
- The verify loop: the parity test is the judge. Write it first so the rewrite has to earn its green.

## Sequencing tip

Keep the legacy type until the parity test passes, then delete it in the real codebase. Here both types stay
so the test has something to compare against.
