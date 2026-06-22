# Part 5: Networking

A typed, actor-based networking layer on `URLSession` async/await, mapping to the user's `Networking/` slice
with typed domain errors and `os.Logger`.

## Planned recipes

- **A typed networking layer** (built, logic-runnable): `typed-api-client/`. An actor API client over
  `URLSession` behind a `Transport` seam: validates `HTTPURLResponse` status into a typed domain error,
  decodes through one centralized `JSONDecoder` (snake_case + ISO-8601), logs non-2xx with `os.Logger`.
  Seven golden vectors. Still to add: streaming a response with `bytes(for:)`.
- **Cancellation and parallel fetch**: cancel-previous search-as-you-type, `try Task.checkCancellation()`,
  `withThrowingTaskGroup` with bounded concurrency, SwiftUI `.task` auto-cancel.
- **HTTP caching done right**: `URLCache` configuration, ETag and 304 revalidation, `willCacheResponse`
  filtering, why not to subclass `URLCache`.

The pure routing and decoding logic is logic-runnable; the live client is verified against a test server.
Add a recipe with `/new-recipe 05-networking <slug>`.
