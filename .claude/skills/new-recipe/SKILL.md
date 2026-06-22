---
description: Scaffold a new standalone recipe (a buildable SPM target, a Swift Testing stub, the README from the template, and a recipes.yaml entry).
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash(mkdir:*), Bash(swift build:*), Bash(swift test:*)
argument-hint: "<part-dir> <recipe-slug> (e.g. 05-networking typed-api-client)"
---

# /new-recipe

Scaffold a new recipe under `recipes/<part-dir>/<recipe-slug>/`. A recipe is fully standalone: its own
Swift package, with no dependency on any other recipe.

## Steps

1. Read `docs/recipe-template.md`, `SWIFT.md`, and `versions.lock` first.
2. Create the directory and these files:
   - `Package.swift` — `swift-tools-version` and the strict-concurrency settings from `versions.lock`.
     Logic recipes are pure SPM; app recipes add an XcodeGen `Project.yml` and are marked simulator- or
     device-required.
   - `Sources/<PascalCaseName>/` — vertical feature slices (`Routing/`, `Sensors/`, `Networking/`), never
     horizontal `Models/`, `Views/`, `Services/`.
   - `Tests/<PascalCaseName>Tests/` — a Swift Testing stub (`@Test`, `#expect`).
   - `README.md` — every section from `docs/recipe-template.md`, in order, with the tier and pinned
     versions filled in.
   - `prompts/` — the one-liner prompt that builds this recipe, plus a `SPEC.md` if the work is large.
   - `verify-output/` — left empty; real captured build and test output lands here.
3. Add one entry to `recipes.yaml` (title, path, part, tier, tags, author, built_against, date,
   description). Do not invent a tier; pick logic-runnable, simulator-required, or device-required.
4. Run `swift build` then `swift test` and confirm the stub is green before handing back.

## Constraints

- Follow `SWIFT.md` for all Swift. Do not add a dependency from this recipe to another recipe.
- Keep pure logic in a target that runs `swift test` headlessly. If the recipe needs a simulator or a
  device, say so in the README banner and put the proof in `verify-output/`.
