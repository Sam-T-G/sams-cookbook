# Part 9 — Cross-cutting concerns

The concerns that are rules on every recipe rather than a single chapter: accessibility, performance,
security, and the modern 2026 surface. This part is the normative home for each.

## Planned recipes

- **Accessibility as a cross-cutting rule** — Dynamic Type that reflows, VoiceOver labels and traits on a
  custom control, `accessibilityLinkedGroup`, a Claude-driven accessibility audit. Other parts reference
  this rather than re-teaching it.
- **Performance and observability** — `os.Logger` subsystems and signposts, catching unexpected
  `@Observable` re-renders, a centralized `Config` enum, profile-fix-verify.
- **Security** (the normative home for the secrets discipline) — Keychain storage with the right
  accessibility class, App Attest gating the backend relay, the relay contract, what never goes in a tracked
  file. Parts 0, 6, and 8 link here.
- **The modern 2026 surface** — an App Intent for Siri / Shortcuts / Spotlight with golden-path tests, a
  `Chart3D` visualization, an interactive widget and a Live Activity, on-device Translation.

Add a recipe with `/new-recipe 09-cross-cutting <slug>`.
