# Recipe template

Every recipe's `README.md` follows this section order. Copy it, fill it in, delete the guidance in
parentheses. The `/new-recipe` skill scaffolds this for you. Content balance per recipe targets roughly 30%
explanation, 50% runnable code, 15% results and captured output, 5% caveats.

---

# <Title>

<One-line promise: the concrete iOS pain solved, quantified where possible.>

**Tier:** <logic-runnable | simulator-required | device-required> (<one phrase on what it needs>).

## Tags and metadata

- Tags: <capability tags from recipes.yaml>
- Author: <name>
- Built against: Swift X / Xcode Y / iOS Z / claude-opus-4-8, on <DATE>
- Verified output: `verify-output/<file>`

## Pinned versions

(Reference `versions.lock`. State only what is specific to this recipe, e.g. a library version or a
tools-version requirement.)

## Prerequisites

(Skills assumed, simulator vs device, time estimate, prior recipes.)

## Problem

(The modern iOS pain, with a measurable baseline where one exists.)

## Baseline

(The naive or pre-modern approach, runnable, with its measured shortcoming.)

## Modern solution (Swift)

(The idiomatic Swift 6 implementation, each layer individually buildable. Link to the source files.)

## Build it with Claude

(The one-liner prompt; the `SWIFT.md` rules that constrain it; the explore/plan/implement/commit flow, or
the AskUserQuestion to SPEC.md interview for larger work; the verify loop Claude runs. Note what Claude
tends to get wrong the first time.)

## Verify / tests

(The commands, what passes, and a link to the captured output in `verify-output/`.)

## Pitfalls and trade-offs

(Concurrency footguns, device-vs-simulator differences, cost and latency, candid limitations.)

## Decision guidance

(When to use this approach versus the alternatives.)

## Reflection

(Three to five sentences. A difficulty encountered plus a forward note. Prose, not bullets.)

## Next steps and related recipes

(Prose links only; never a code dependency on another recipe.)
