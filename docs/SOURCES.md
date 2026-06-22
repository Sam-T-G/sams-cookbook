# Sources

Primary sources are the citation of record. Secondary sources are teaching companions. Every recipe cites
the primary source for any API it names and any "new in" claim it makes.

## Primary

- **Claude Code docs** (best practices, skills, subagents, hooks, headless): https://code.claude.com/docs/en/best-practices
  Canonical for every Claude-native rule. The old anthropic.com/engineering URL redirects here.
- **Anthropic, Building Effective Agents**: https://www.anthropic.com/research/building-effective-agents
  The agent doctrine (workflows vs agents, the five patterns) and the tool-design rules.
- **Anthropic, multi-agent research system**: https://www.anthropic.com/engineering/multi-agent-research-system
  The single-writer, no-peer-coordination subagent doctrine and the fan-out cost framing.
- **Anthropic platform docs** (prompting, extended thinking, prompt caching, models): https://platform.claude.com/docs
  The current model rules: claude-opus-4-8 default, adaptive thinking, the effort control, structured
  outputs (assistant prefill is removed on 4.6+).
- **Anthropic Cookbook**: https://github.com/anthropics/claude-cookbooks
  The structural model: recipe anatomy, the capability-tag manifest, and the runnable-and-verified mandate.
- **Anthropic ClaudeForFoundationModels**: https://platform.claude.com/docs/en/cli-sdks-libraries/libraries/apple-foundation-models
  Appendix A only: the iOS 27 LanguageModel-provider path. Flagged beta.
- **Apple Developer Documentation**: https://developer.apple.com/documentation/
  Version-of-record for every API a recipe names.
- **Apple WWDC sessions and guides**: https://developer.apple.com/
  Dated source for every "new in" claim.
- **swift.org** (blog, migration guide, Swift Testing and swift-format repos): https://www.swift.org/blog/
  The language and toolchain baseline.
- **swift-evolution**: https://github.com/swiftlang/swift-evolution
  Rationale of record for the concurrency rules: SE-0461, SE-0466, SE-0413.
- **Apple Swift Testing docs** and the migration-from-XCTest guide: https://developer.apple.com/documentation/testing
- **Tooling primaries**: swift-format, SwiftLint, Tuist, fastlane, Apple Xcode Cloud, NSHipster on URLCache,
  Apple HIG Materials.

## Secondary

- **SwiftAnthropic** (jamesrochabrun): https://github.com/jamesrochabrun/SwiftAnthropic
  Verified at 2.2.2 (2026-04-18); an option for basic chat, streaming, and tool use only. It cannot send
  adaptive thinking, the effort control, or structured outputs, so the cookbook's primary client is a raw
  `URLSession` `/v1/messages` client (see `recipes/06-ai-features/cloud-claude-chat`).
- **Point-Free**: https://github.com/pointfreeco (swift-dependencies and swift-snapshot-testing).
- **MV-over-MVVM and modern-SwiftUI authors**: Ricouard, Hudson, Jabrayilov, Panferova, NimbleHQ, objc.io.
- **Practical concurrency, persistence, tooling authors**: Wals, van der Lee, Sundell, Fatbobman.

> Note: this cookbook was assembled from these sources via primary-source research on 2026-06-21. Recheck
> the dated facts before each release (`docs/currency-protocol.md`).
