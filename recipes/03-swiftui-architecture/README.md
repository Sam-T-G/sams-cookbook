# Part 3 — SwiftUI and app architecture

Modern SwiftUI on the iOS 26 surface, with the MV (not MVVM) house architecture and vertical-slice
modularization.

## Planned recipes

- **MV architecture and vertical slices** — `@Observable` models in `@State`, `@Bindable` bindings,
  `@Environment` for shared instances; a vertical feature slice as a local package; an honest
  "when MVVM still earns its keep" sidebar.
- **Dependency injection and the clock** — Point-Free `swift-dependencies` as one idiom alongside the house
  plain-Swift value-type default; a controllable clock for deterministic timing tests.
- **Navigation and state** — type-safe `NavigationStack` routing, view identity and the view tree, who owns
  `@State` / `@Bindable` / `@Environment`, deep links.
- **Liquid Glass and accessibility** — Liquid Glass on the navigation layer only; honoring Reduce
  Transparency and Increase Contrast; Dynamic Type and VoiceOver on every control.

Most recipes here are simulator-required. Add one with `/new-recipe 03-swiftui-architecture <slug>`.
