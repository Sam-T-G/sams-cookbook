# Appendix B: Contributing and the currency protocol

The contributing guide and the currency protocol live in `docs/`, so this appendix is a pointer plus the
release-time checklist that ties them together.

- How to add a recipe, the `recipes.yaml` schema, and the gates every recipe passes: `docs/CONTRIBUTING.md`.
- The version-fact recheck list and the iOS 27 GM promotion event: `docs/currency-protocol.md`.
- The recipe template: `docs/recipe-template.md`.
- The source bibliography: `docs/SOURCES.md`.

## Release checklist

1. `scripts/test_all.sh` green; `scripts/check_manifest.sh` green.
2. Run the recheck list in `docs/currency-protocol.md`; update `versions.lock` if anything moved.
3. If iOS 27 has reached GM, run the promotion event (move Appendix A entries into the core parts).
4. Confirm no tracked secrets and no AI-trace in commit messages.
5. Sync the Obsidian mirror from the repo (the repo is the source of truth).
