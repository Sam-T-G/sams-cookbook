# Part 5 — Networking

A typed, actor-based networking layer on `URLSession` async/await, mapping to the user's `Networking/` slice
with typed domain errors and `os.Logger`.

## Planned recipes

- **A typed networking layer** — an actor API client, validating `HTTPURLResponse` status into a typed
  domain error, a centralized `JSONDecoder`, `os.Logger` per subsystem, streaming with `bytes(for:)`.
- **Cancellation and parallel fetch** — cancel-previous search-as-you-type, `try Task.checkCancellation()`,
  `withThrowingTaskGroup` with bounded concurrency, SwiftUI `.task` auto-cancel.
- **HTTP caching done right** — `URLCache` configuration, ETag and 304 revalidation, `willCacheResponse`
  filtering, why not to subclass `URLCache`.

The pure routing and decoding logic is logic-runnable; the live client is verified against a test server.
Add a recipe with `/new-recipe 05-networking <slug>`.
