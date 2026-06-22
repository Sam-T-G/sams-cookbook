# The prompt that builds this recipe

This one is large enough for the AskUserQuestion to SPEC.md interview, then a fresh session, but the core is
captured by the one-liner. Paste into Claude Code with `SWIFT.md` loaded.

## One-liner

> Build a hybrid assistant that routes between an on-device Foundation Models backend and a cloud Claude
> backend behind a shared LanguageBackend protocol (respond(to:) with a typed BackendError). A pure
> EscalationPolicy picks the first tier: short and local stays on device; long inputs and reasoning-flavored
> prompts go to the cloud; an unavailable on-device model forces the cloud. The orchestrator escalates
> on-device to cloud on unavailable, rateLimited, or contextExceeded, and propagates transport failures.
> Write golden-vector tests for the policy and the escalation using fake backends, no device and no network.
> Follow SWIFT.md. Run `swift build` then `swift test` until green.

## What constrains it

- `SWIFT.md`: typed domain errors, value types, the Claude request shape, no API key in the binary.
- The runnability tiers: the on-device backend is device-required (verified on a device); the routing and
  escalation logic is logic-runnable and golden-vector tested with fakes.
- The verified Foundation Models API: `SystemLanguageModel.default.availability`, `LanguageModelSession`,
  `session.respond(to:).content`, and `LanguageModelSession.GenerationError` for the precise error mapping.

## What to watch

Only `.unavailable`, `.rateLimited`, and `.contextExceeded` escalate; `.transport` propagates, because a
different tier cannot fix a dead network. Inject the backends as protocol values so the orchestrator is
testable with fakes. The on-device error mapping is the one SDK-version-sensitive spot (see the README).
