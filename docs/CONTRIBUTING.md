# Contributing

## Adding a recipe

1. Run `/new-recipe <part-dir> <recipe-slug>` in Claude Code. It scaffolds the package, a Swift Testing
   stub, the README from `docs/recipe-template.md`, the `prompts/` and `verify-output/` folders, and a
   `recipes.yaml` entry.
2. Build the recipe following `SWIFT.md`. Keep pure logic in a target that runs `swift test` headlessly.
3. Fill every template section. The "Build it with Claude" section is required, because the book is
   Claude-native; show the prompt and the verify loop, not just the code.
4. Capture real `swift test` (and, for simulator or device recipes, real on-device) output into
   `verify-output/`. Do not paraphrase results.
5. Set the runnability tier honestly in `recipes.yaml`: logic-runnable, simulator-required, or
   device-required. CI runs `swift test` for logic-runnable recipes and compile-checks the rest.

## The gates every recipe must pass

- `scripts/test_all.sh` is green (logic-runnable recipes pass `swift test`; others compile).
- `scripts/check_manifest.sh` is green (`recipes.yaml` and the `recipes/` tree agree exactly).
- `swift format lint --strict` is clean, and SwiftLint passes.
- Prose follows the house voice (`context/voice-guide.md`). The `/draft-recipe-prose` skill enforces it.

## Standalone, always

A recipe never depends on another recipe's code. Cross-references in "Decision guidance" and "Next steps"
are prose links only. There is no shared library and no composed demo app.

## Keeping the Obsidian mirror in sync

The repo is the single source of truth. When mirroring to the vault, copy from the repo; never edit the
mirror and back-port.

## Currency

Version facts live in `versions.lock`, not in prose. Before a release, run the recheck in
`docs/currency-protocol.md`.
