---
description: Constraints for every Swift file in the cookbook. Applied on edits to Swift sources.
paths: ["**/*.swift"]
---

When editing Swift in this repo, follow `SWIFT.md` at the repo root. The load-bearing points:

- Swift 6 language mode, strict concurrency complete, warnings as errors.
- `MainActor` default isolation; actors for shared mutable non-UI state; `@MainActor` for UI.
- `@Observable`, never `ObservableObject` or `@Published`, for new code.
- `Task` plus a clock for timing, never `Timer`; no `DispatchQueue` in app logic.
- Value types by default; typed domain errors (`enum`, `Error`, `CustomStringConvertible`).
- `os.Logger` per subsystem, never `print`; centralized `Config` enum for magic numbers.
- No API key in the app binary; dev keys come from a gitignored `Secrets.xcconfig`.
- Keep pure logic separate from framework glue so it can be tested headlessly.

Full text and the source for each rule: `SWIFT.md`.
