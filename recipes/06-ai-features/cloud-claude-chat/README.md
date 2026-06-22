# Cloud Claude from Swift

Call the Claude Messages API from Swift with the current request shape (adaptive thinking, the effort
control, structured outputs), built on a typed `URLSession` client that holds no API key.

**Tier:** logic-runnable for the request-building and response-decoding logic (golden vectors run on any
host). The live `send` call is device-required: it needs the backend relay and a real network, so it is
verified on device, not in CI.

## Tags and metadata

- Tags: AI-Cloud, Networking, Claude-Native-Build, Testing
- Author: Samuel Gerungan
- Built against: Swift 6.3 / Xcode 26.5 / iOS 26 / claude-opus-4-8, on 2026-06-21
- Verified output: [`verify-output/test-run.txt`](verify-output/test-run.txt)

## Pinned versions

See [`versions.lock`](../../../versions.lock). The Claude request shape is pinned there too:
`claude-opus-4-8`, adaptive thinking, the effort control, structured outputs, and no `budget_tokens` or
assistant prefill. Verified against the Claude API reference on 2026-06-21.

## Prerequisites

The Swift toolchain for the tests. A running backend relay (see `samples/backend-relay`) and a device for
the live call. Read the concurrency-posture recipe first. Around 25 minutes.

## Problem

We want Claude in an iOS app, with the current API surface, and without ever shipping the API key. Two
traps make this harder than it looks. The community Swift client (`SwiftAnthropic`) is in maintenance mode
and only emits the deprecated `budget_tokens` thinking shape, which `claude-opus-4-8` rejects with a 400.
And the obvious shortcut, putting the key in the app and calling Anthropic directly, leaks the key to
anyone who unzips the app.

## Baseline

Reaching for `SwiftAnthropic` and calling Anthropic directly looks like the quick path:

```swift
// Two problems: the thinking shape 400s on opus-4-8, and the key ships in the binary.
let service = AnthropicServiceFactory.service(apiKey: Secrets.anthropicAPIKey)  // key in the app
let params = MessageParameter(
    model: .other("claude-opus-4-8"),
    thinking: .init(type: .enabled, budgetTokens: 4000)  // rejected on 4.6+
)
```

The shortcoming is concrete: the request fails on the current model, and the key is extractable from the
shipped app.

## Modern solution (Swift)

A small hand-rolled client, which also happens to be the user's own Citrus Squad idiom. It encodes the
exact wire shape the model accepts and points at the relay, not at Anthropic.

- [`ClaudeRequest`](Sources/CloudClaude/ClaudeAPI.swift) encodes `model`, `max_tokens`, `messages`,
  `thinking: {type: "adaptive"}`, and `output_config` (the effort control, and a JSON Schema for structured
  output). It cannot express `budget_tokens`, `temperature`, or a prefill, so it cannot send what the model
  rejects.
- [`ClaudeResponse`](Sources/CloudClaude/ClaudeAPI.swift) decodes the content blocks and exposes the joined
  `text`, with `stopReason` so a caller checks for `"refusal"` before trusting the text.
- [`ClaudeClient`](Sources/CloudClaude/ClaudeClient.swift) is a stateless `nonisolated struct` (an actor
  would add isolation with nothing to protect). `makeRequest` is pure and testable; `send` does the call and
  maps every failure to a typed `ClaudeError`. There is no API key in the client; the relay adds it.

## Build it with Claude

The one-liner that builds this recipe:

> Build a typed URLSession client for the Claude Messages API targeting a backend relay (no API key in the
> client). Encode claude-opus-4-8 with adaptive thinking, the effort control under output_config, and
> structured outputs via output_config.format. Decode the response and expose joined text plus stop_reason.
> Golden-vector tests that assert the encoded body has the right fields and omits temperature, budget_tokens,
> and prefill. Follow SWIFT.md.

The rules that constrain it: the Claude API shape in [`SWIFT.md`](../../../SWIFT.md) (claude-opus-4-8,
adaptive thinking, effort, structured outputs, no key in the binary) and the typed-networking idiom (typed
domain errors, value types, no key in the client). The verify loop tests the request encoding and the
response decoding without the network; the live call is verified on device against the relay.

## Verify / tests

```sh
swift build
swift test
```

Eight tests across three suites pass: the encoded request has the modern shape and omits the rejected
parameters, structured output encodes as a JSON Schema, the client sets the right path and headers, and the
response decoder concatenates text and surfaces a refusal. The captured run is in
[`verify-output/test-run.txt`](verify-output/test-run.txt). The live `send` is verified on device against a
running relay; that transcript is not in CI.

## Pitfalls and trade-offs

- A hand-rolled client means you own the request shape. That is the point here, because it is the only way to
  send adaptive thinking, the effort control, and structured outputs today, but it does mean tracking the API
  via `versions.lock` and the currency protocol.
- Always check `stopReason == "refusal"` before reading `text`; a refusal carries empty content. Reading
  `content[0]` blind will crash on a refused request.
- The relay is required for shipping. The dev-only alternative (a key in a gitignored xcconfig, calling
  Anthropic directly from the simulator) is fine for a spike but never ships.

## Decision guidance

Use this raw client for any recipe that needs the newest controls (adaptive thinking, effort, structured
outputs). `SwiftAnthropic` is a reasonable choice only for basic chat, streaming, and tool use where you do
not need those controls and want less code; its `Model.other("claude-opus-4-8")` works, but its thinking
shape does not. When in doubt, prefer the raw client; it matches the house typed-networking idiom anyway.

## Reflection

The surprise was that the "obvious" dependency is the wrong default: `SwiftAnthropic` looks complete until
you need adaptive thinking on the current model, at which point it 400s and there is no parameter to set. A
spike confirmed it before any recipe locked, which is exactly what the section-12 spikes in the spec are for.
The forward note is streaming: this recipe returns the whole message, and a chat UI wants the token stream,
which the hybrid-assistant recipe covers.

## Next steps and related recipes

- The hybrid on-device + Claude assistant in this part, which routes between the on-device model and this
  client and streams the result.
- Part 5, Networking, for the cancellation and parallel-fetch patterns this client builds on.
- Part 9, Security, for the backend relay and App Attest that make the no-key-in-binary rule real.
