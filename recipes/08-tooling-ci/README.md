# Part 8 — Tooling and CI/CD

The build, lint, format, and CI stack that makes the cookbook runnable, plus the headless Claude Code path.

## Planned recipes

- **Build and project generation** — the per-recipe package, the `scripts/test_all.sh` aggregate runner,
  XcodeGen `Project.yml` for app recipes, Tuist as the scale-up option.
- **Format, lint, and hooks** — `swift-format` with `--language-mode 6` and a committed config, SwiftLint via
  the build-tool plugin, the PostToolUse format hook, a hook that blocks edits to generated output.
- **Continuous integration** — the GitHub Actions workflow (`xcodebuild test`, xcresult artifact, no signing
  for unit tests, an Xcode matrix), the model-currency gate, Xcode Cloud, headless Claude in CI.
- **Release to TestFlight and the App Store** — `fastlane` with an App Store Connect API key kept out of
  tracked files, external tester groups and the 90-day build expiry, a StoreKit 2 async purchase flow.

The repo's own CI workflow definitions and `scripts/` are the working examples this part explains. The
workflows currently sit in `ci/github-workflows/` and move to `.github/workflows/` to activate; see that
folder's README for why and how. Add a recipe with `/new-recipe 08-tooling-ci <slug>`.
