# The prompt that builds this recipe

Paste into Claude Code with `SWIFT.md` loaded. The Claude API shape is the load-bearing part; get it from
`versions.lock` and the claude-api reference, not from memory.

## One-liner

> Build a typed URLSession client for the Claude Messages API that targets a backend relay and holds no API
> key. Encode claude-opus-4-8 with adaptive thinking (`thinking: {type: "adaptive"}`), the effort control
> under `output_config`, and structured outputs via `output_config.format`. Decode the response into a value
> type that exposes joined text and `stop_reason`. Write golden-vector tests that assert the encoded body has
> the right fields and omits `temperature`, `budget_tokens`, and any assistant prefill. Follow SWIFT.md. Run
> `swift build` then `swift test` until green.

## What constrains it

- `SWIFT.md`: claude-opus-4-8, adaptive thinking, effort, structured outputs, typed domain errors, value
  types, and no API key in the binary.
- The verified API shape: `output_config.effort` (not top-level), `output_config.format` for structured
  output, no `budget_tokens` / `temperature` / prefill on 4.6+.
- The verify loop: golden vectors on request encoding and response decoding; the live call is on device.

## What to watch

The client is stateless, so it is a `nonisolated struct`, not an actor. Reach for an actor only when there is
shared mutable state. Encoding test assertions read the body back as a dictionary so key order does not
matter.
