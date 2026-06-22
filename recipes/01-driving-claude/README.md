# Part 1 — Driving Claude Code to build iOS

The Claude-native foundation every later "Build it with Claude" section assumes. Most of this part's
artifacts already live at the repo root and in `.claude/`: the `CLAUDE.md`, the canonical `SWIFT.md`, the
skills, the agents, and the hooks. The recipes here teach how to build and reason about them.

## Planned recipes

- **The .claude setup and SWIFT.md** — authoring a sub-200-line `CLAUDE.md`, the canonical `SWIFT.md`,
  path-scoped rules vs always-loaded rules, and why we avoid "CRITICAL" / "You MUST" phrasing on Opus 4.8.
- **The verify loop for Swift** — the two-tier loop, the Stop hook that blocks until `swift test` is green,
  and an adversarial code-review subagent scoped to correctness. See `context/verify-loop.md`.
- **Skills as the repeatable-task primitive** — `/new-recipe`, `/swift-build`, `/swift-test`, `/commit`,
  with `allowed-tools` pre-approval and dynamic context injection.
- **Subagents and the single-writer doctrine** — isolated workers, and the tested artifact for the
  "forks do not see SWIFT.md" failure mode. See `context/subagent-doctrine.md`.
- **Explore, plan, implement, commit** — the four-phase loop, the AskUserQuestion to SPEC.md interview, and
  headless Claude in CI.

Add a recipe with `/new-recipe 01-driving-claude <slug>`.
