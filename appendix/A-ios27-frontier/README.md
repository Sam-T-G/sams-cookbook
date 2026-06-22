# Appendix A: The iOS 27 frontier (forward-looking)

Every iOS 27 / Xcode 27 / Swift 6.4 feature is quarantined here so no core recipe depends on a pre-release
API. Each entry is dated "current as of June 2026 (WWDC26 beta)" and marked not-yet-GM. At iOS 27 GM these
promote into the core parts (see `docs/currency-protocol.md`).

## Entries

- **ClaudeForFoundationModels and third-party LLM providers**: the iOS 27 `LanguageModel` provider that lets
  a Claude provider drive a `LanguageModelSession` with the same respond / stream / guided-generation / tool
  API, turning the hybrid flagship's escalation into a one-line model swap. Includes the feature-gap table
  (no prompt-caching control, no Batch or Files, no token counting through the provider) that says when to
  reach past it to the raw `URLSession` Messages-API client (`recipes/06-ai-features/cloud-claude-chat`)
  instead. (source: platform.claude.com Apple Foundation Models docs)
- **SwiftData and SwiftUI on iOS 27**: `ResultsObserver`, history-driven offline sync, sectioned queries,
  composite predicates; the SwiftUI Document API and AsyncImage HTTP caching. All beta.
- **Toolchain frontier**: Swift 6.4, Xcode 27 XCTest and Swift Testing interoperability modes (require
  `swift-tools-version: 6.4+`), Instruments 27. All pre-release as of 2026-06-21.

> Note: the local dev machine for this repo currently runs the Swift 6.4 / Xcode 27 beta line. That is fine
> for building 6.x packages, but the published baseline stays on the Swift 6.3 / Xcode 26.5 / iOS 26 GM line
> so every recipe builds against a released toolchain.
