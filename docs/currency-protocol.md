# Currency protocol

The book's value is that it is current and auditable. Volatile facts live in one place (`versions.lock`),
and prose references that file rather than restating build numbers. Recheck this list before each release.

## Recheck checklist

- Swift, Xcode, and iOS GM versions and dates (swift.org, developer.apple.com/news/releases).
- The Claude default model id and the thinking/effort/output API shape (platform.claude.com models docs).
- The `SwiftAnthropic` version and whether it exposes the current model id, adaptive thinking, the effort
  control, and structured outputs. If it has fallen behind, switch the affected recipes to the raw
  `URLSession` `/v1/messages` fallback or a pinned fork (see SPEC §12).
- The on-device Foundation Models API surface (`SystemLanguageModel`, `LanguageModelSession`, `@Generable`).
- The pinned test simulator, if any snapshot test depends on it.

## The iOS 27 promotion event

When iOS 27 reaches GM:

1. Move the Appendix A entries (ClaudeForFoundationModels provider path, iOS 27 SwiftData and SwiftUI APIs)
   into Parts 4, 6, and 7 as core recipes.
2. Update `versions.lock`: promote the frontier versions to the baseline, and move the old baseline notes to
   a "minimum supported" line.
3. Shrink Appendix A to whatever the next beta cycle introduces.
4. Re-run the full recheck checklist above.

This is a documented release step, not an ad-hoc edit, so the "most modern" claim stays honest across OS
cycles.

## Open questions to resolve before publishing

- The two build-time spikes in SPEC §12: the `SwiftAnthropic` API-surface check, and the App Attest
  attest-then-assert handshake on a real device.
- Whether any snapshot tests survive, or whether visual recipes verify entirely through behavioral and
  accessibility assertions.
