# A typed networking layer

Wrap `URLSession` in an actor API client that validates the HTTP status into a typed error and decodes
through one centralized decoder, with the whole layer testable behind a transport seam.

**Tier:** logic-runnable. The status validation, error mapping, decoding, and request building all run
through a fake transport with no network, so the golden vectors are deterministic.

## Tags and metadata

- Tags: Networking, Claude-Native-Build, Testing
- Author: Samuel Gerungan
- Built against: Swift 6.3 / Xcode 26.5 / iOS 26 / claude-opus-4-8, on 2026-06-21
- Verified output: [`verify-output/test-run.txt`](verify-output/test-run.txt)

## Pinned versions

See [`versions.lock`](../../../versions.lock). `URLSession` async-await and `os.Logger` are baseline iOS 26.

## Prerequisites

The Swift toolchain. No simulator or device. Read the concurrency-posture recipe first. Around 20 minutes.

## Problem

A networking layer has three jobs that are easy to get wrong: turning a non-2xx response into a real error
instead of decoding garbage, decoding every response the same way (dates and key casing especially), and
being testable without hitting a live server. The third is the one most layers skip, which is why their error
handling is never really exercised.

## Baseline

The naive version calls `URLSession` inline, ignores the status code, and decodes whatever came back:

```swift
// Decodes the body even on a 500, and there is no way to test it without a live server.
let (data, _) = try await URLSession.shared.data(from: url)
let widget = try JSONDecoder().decode(Widget.self, from: data)
```

The shortcoming is that a 404 or 500 returns an error page, which then fails to decode with a confusing
message, and the whole path can only be tested against a real endpoint.

## Modern solution (Swift)

Three moves: a transport seam, status validation, and one decoder.

- [`Transport`](Sources/TypedAPIClient/NetworkingCore.swift) is a one-method protocol. `URLSessionTransport`
  is the real one; tests inject a fake. This is what makes the layer testable.
- [`APIClient`](Sources/TypedAPIClient/APIClient.swift) is an `actor`, because it owns reusable state (the
  transport, the configured decoder, the logger) that concurrent callers share. That is the case SWIFT.md
  reserves an actor for, rather than a lock.
- `fetch` validates the response: a non-HTTP response is `.invalidResponse`, a non-2xx status is
  `.status(code:)`, a transport failure is `.transport`, and a decode failure is `.decoding`. All typed.
- One `JSONDecoder` is configured once (`convertFromSnakeCase`, `.iso8601`) and reused for every call, so
  decoding is consistent across the whole layer.
- `os.Logger` records non-2xx responses per subsystem, never `print`.

## Build it with Claude

The one-liner:

> Build an actor API client over URLSession behind a Transport protocol seam. Validate the HTTP status into
> a typed APIError (invalidResponse, status(code:), transport, decoding), decode through one centralized
> JSONDecoder with convertFromSnakeCase and ISO-8601, and log non-2xx with os.Logger. Golden-vector tests
> with a fake transport for the success decode, 404 and 503 status mapping, malformed-body decoding error,
> and a transport failure. Follow SWIFT.md.

The rules that constrain it: SWIFT.md (actors for shared mutable non-UI state, typed domain errors, value
types, os.Logger not print). The verify loop runs the fake-transport golden vectors; the live fetch against a
real server is a runtime check.

## Verify / tests

```sh
swift build
swift test
```

Seven tests across two suites pass: a snake_case and ISO-8601 decode, 404 and 503 mapped to `.status`, a
malformed body mapped to `.decoding`, a transport failure mapped to `.transport`, and the request builder
producing the right path, method, and query. The captured run is in
[`verify-output/test-run.txt`](verify-output/test-run.txt).

## Pitfalls and trade-offs

- An actor adds an `await` at every call site. That is correct here (shared client state), but a stateless
  client, like the one in the cloud-claude-chat recipe, is better as a `nonisolated struct`. Match the tool
  to whether there is state to protect.
- The transport seam is the cost of testability: one extra protocol. It pays for itself the first time you
  test error handling without a live server.
- A centralized decoder is a single decision point. If one endpoint needs different date handling, that is a
  per-endpoint decoder, not a tweak to the shared one.

## Decision guidance

Use this shape for any app that talks to an HTTP API. Keep the transport behind a protocol so the layer is
testable. Reach for the actor when the client holds reusable state; if it is a pure request builder with no
state, a `nonisolated struct` is lighter.

## Reflection

The decision that mattered was where to put the HTTP-to-error boundary. Validating the status before
decoding, rather than letting a 500's error page fail the decoder, turns a confusing decode error into a
clear `.status(code: 500)` the caller can act on. The forward note is cancellation: a search field wants
cancel-previous semantics, which the cancellation chapter in this part covers on top of this client.

## Next steps and related recipes

- The cancellation and parallel-fetch chapter in this part, which builds on this client.
- The cloud-claude-chat recipe in Part 6, a stateless variant of the same idea for the Claude API.
- Part 7, Testing, for more on the fake-seam pattern these golden vectors use.
