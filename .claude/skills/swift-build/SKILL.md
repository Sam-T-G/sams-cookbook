---
description: Build the current recipe or the whole workspace, with the strict-concurrency settings, and report errors plainly.
user-invocable: true
allowed-tools: Bash(swift build:*)
argument-hint: "[--target <name>] (default: build from the current directory)"
---

# /swift-build

Run `swift build` from the current directory (a recipe folder or the repo root). Strict concurrency is
complete and warnings are errors, so a warning fails the build by design.

Live output:

!`swift build 2>&1 | tail -40`

If the build is red, read the first error (not the last), fix the root cause, and rebuild. Do not silence a
data-race warning with `@unchecked Sendable`; fix the isolation. See `SWIFT.md`.
