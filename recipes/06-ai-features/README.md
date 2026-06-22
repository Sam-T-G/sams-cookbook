# Part 6 — AI features in iOS apps

The headline part, where the iOS-first and Claude-native axes meet the product. AI in two tiers, on-device
Foundation Models and cloud Claude, unified under one API shape.

## Planned recipes

- **On-device with Foundation Models** (device-required) — a summarizer on `SystemLanguageModel.default`,
  guided generation with `@Generable` / `@Guide`, a `Tool` the model can call, the availability switch,
  streaming partial snapshots. Needs eligible hardware with Apple Intelligence enabled; ships a recorded
  transcript.
- **Cloud Claude from Swift** (built, logic-runnable) — `cloud-claude-chat/`. A typed `URLSession` client
  for the Messages API that holds no API key: adaptive thinking, the effort control, and structured outputs
  on `claude-opus-4-8`, with golden vectors over the request shape and response decoding. The spike (SPEC
  §12) settled the client choice: the raw client is primary because `SwiftAnthropic` can't send the newer
  controls. Still to add: a Claude tool defined from Swift, prompt caching, and the mid-conversation system
  note for multi-turn chats.
- **The hybrid on-device + Claude assistant (flagship)** — on-device for quick private turns, escalating to
  cloud Claude for frontier reasoning, with the pure routing logic golden-vector tested and the glue
  verified on device.
- **Agentic iOS apps that call Claude** — the augmented-LLM ladder (one message, then a routing workflow,
  then a tool-use agent loop), escalating only when a test proves the simpler tier insufficient.

Cloud recipes depend on the Swift client locked by the SPEC §12 spike. The shipping path uses
`samples/backend-relay`. Add a recipe with `/new-recipe 06-ai-features <slug>`.
