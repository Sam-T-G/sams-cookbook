# Subagent doctrine

When to fan out work to subagents, and the one failure mode that bites hardest in a Swift repo.

## Single writer, isolated workers

Subagents are isolated research and review workers, never coordinating peers. One writer owns the edit;
subagents return summaries. This follows Anthropic's multi-agent writeup and Cognition's single-writer
doctrine. Fan-out costs roughly an order of magnitude more tokens than a single agent, so it earns its keep
only for genuinely parallel, independent work (mapping several unfamiliar modules, reviewing a large diff
from several angles), not for a single-file edit. (source: anthropic.com/engineering/multi-agent-research-system)

## The failure mode: forks do not see SWIFT.md

`agent: Explore` and `agent: Plan` forks do not load `CLAUDE.md` or `SWIFT.md` on their own. A research or
review fork that has never read the constraints will happily describe or propose Swift that violates strict
concurrency, uses `ObservableObject`, or reaches for a `Timer`. This is the highest-frequency Claude-native
mistake in this repo.

The fix is to pass the constraints in the agent body. The two shipped agents do this:

- `.claude/agents/swift-researcher.md` inlines the load-bearing `SWIFT.md` rules so a read-only mapping fork
  judges code against them.
- `.claude/agents/code-reviewer.md` inlines the same rules as a review checklist and defaults to skepticism.

When you write a new fork-based skill or agent, inline the relevant `SWIFT.md` rules in its body. Do not
assume the fork inherited them. A planned recipe in Part 1 proves this with captured before-and-after output
(a fork producing compliant vs non-compliant Swift, with and without the inlined rules).

## On Opus 4.8 specifically

Opus 4.8 tends to over-spawn subagents and over-trigger on emphatic phrasing. Default to direct work for
single-file edits, and state rules plainly once rather than shouting them. (source: code.claude.com/docs)
