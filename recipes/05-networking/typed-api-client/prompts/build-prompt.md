# The prompt that builds this recipe

Paste into Claude Code with `SWIFT.md` loaded.

## One-liner

> Build an actor API client over URLSession behind a Transport protocol seam. Validate the HTTP status into
> a typed APIError (invalidResponse, status(code:), transport, decoding), decode through one centralized
> JSONDecoder configured with convertFromSnakeCase and ISO-8601, and log non-2xx responses with os.Logger.
> Make request building a pure static function so it is testable on its own. Write golden-vector tests with a
> fake transport: a success decode, 404 and 503 mapped to status errors, a malformed body mapped to a
> decoding error, and a transport failure mapped to a transport error. Follow SWIFT.md. Run `swift build`
> then `swift test` until green.

## What constrains it

- `SWIFT.md`: actors for shared mutable non-UI state, typed domain errors, value types, os.Logger not print.
- The verify loop: fake-transport golden vectors run headlessly; the live fetch is a runtime check.

## What to watch

Validate the status before decoding, or a 500's error page fails the decoder with a confusing message
instead of a clean `.status(code:)`. The transport seam is what makes the error handling testable without a
live server. The actor is justified by the shared decoder/transport/logger state; a stateless client would
be a `nonisolated struct` instead.
