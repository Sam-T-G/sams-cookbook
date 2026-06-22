# The hybrid on-device + Claude assistant (flagship)

Answer quick, private turns on the device's Foundation Models model and escalate to cloud Claude for
frontier reasoning, with the routing decision proven by golden vectors and the on-device glue verified on a
device. This is the iOS-first, Claude-native thesis made literal in one recipe.

**Tier:** logic-runnable for the routing and escalation logic (the golden vectors run on any host with fake
backends). The real on-device backend uses Apple's Foundation Models framework, which is device-required: it
needs eligible hardware with Apple Intelligence enabled and is verified on a device, not in CI.

## Tags and metadata

- Tags: AI-OnDevice, AI-Cloud, Claude-Native-Build, Testing
- Author: Samuel Gerungan
- Built against: Swift 6.3 / Xcode 26.5 / iOS 26 / claude-opus-4-8, on 2026-06-21
- Verified output: [`verify-output/test-run.txt`](verify-output/test-run.txt)

## Pinned versions

See [`versions.lock`](../../../versions.lock). On-device uses the Foundation Models framework (iOS 26+); the
cloud tier uses the raw Claude client from the cloud-claude-chat recipe. The Foundation Models API and the
Claude request shape were verified against primary sources on 2026-06-21.

## Prerequisites

The Swift toolchain for the tests. An eligible device with Apple Intelligence enabled for the on-device half,
and a running backend relay for the cloud half. Read the cloud-claude-chat recipe first. Around 35 minutes.

## Problem

The on-device model is private, offline, and free, but small: it is tuned for short, local tasks, not
frontier reasoning. Cloud Claude is the opposite. A good assistant uses each where it fits, and the part that
is easy to get wrong is the decision: when to stay local, when to escalate, and what to do when the local
model is unavailable, rate limited, or handed an input larger than its context window. That decision is also
the part hardest to verify on a device, so it has to be testable on its own.

## Baseline

The naive version hard-codes one tier, or branches inline inside the view with no way to test the branching:

```swift
// Untestable: the routing is tangled into the call site, and on-device failure just surfaces an error.
let text = useCloud ? try await cloud.send(prompt) : try await onDevice.respond(to: prompt)
```

The shortcoming is that the routing rules and the fallback behavior cannot be exercised without a device and
a network, so they are never really tested.

## Modern solution (Swift)

Separate the decision from the backends. The pure routing logic and the orchestrator are testable with fakes;
the real backends are thin adapters.

- [`EscalationPolicy`](Sources/HybridAssistant/EscalationPolicy.swift) is the pure decision: short, local
  prompts stay on device; long or reasoning-flavored prompts start in the cloud; if on-device is
  unavailable, everything goes to the cloud.
- [`LanguageBackend`](Sources/HybridAssistant/LanguageBackend.swift) is the seam: a `respond(to:)` with a
  typed `BackendError`. Both tiers conform, so the assistant routes between them without knowing which is
  which.
- [`HybridAssistant`](Sources/HybridAssistant/HybridAssistant.swift) starts at the policy's tier and
  escalates on-device to cloud on `.unavailable`, `.rateLimited`, or `.contextExceeded`. A `.transport`
  failure is not something a different tier can fix, so it propagates.
- [`OnDeviceBackend`](Sources/HybridAssistant/OnDeviceBackend.swift) is the real Foundation Models glue
  (device-required), behind `#if canImport(FoundationModels)`.

### The on-device backend (device-required)

The compiled `OnDeviceBackend` checks availability and calls the model, mapping the two recoverable
generation errors so the assistant escalates to the cloud on them:

```swift
} catch let error as LanguageModelSession.GenerationError {
    switch error {
    case .exceededContextWindowSize: throw .contextExceeded  // escalates to cloud
    case .rateLimited: throw .rateLimited                    // escalates to cloud
    default: throw .transport(String(describing: error))
    }
}
```

This builds clean for the iOS 26 deployment target. On a newer SDK the editor may flag
`GenerationError` as deprecated, but the iOS 26 target build does not, so it stays inside the strict
warnings-as-errors posture.

### The cloud backend (wraps the cloud-claude-chat client)

Recipes are standalone, so copy the small `ClaudeClient` from cloud-claude-chat into this target and wrap it
to conform to `LanguageBackend`:

```swift
struct CloudBackend: LanguageBackend {
    let client: ClaudeClient
    func respond(to prompt: String) async throws(BackendError) -> String {
        do {
            let response = try await client.send(
                ClaudeRequest(messages: [.init(role: "user", content: prompt)])
            )
            guard response.stopReason != "refusal" else { throw BackendError.unavailable }
            return response.text
        } catch let error as ClaudeError {
            switch error {
            case .http(429): throw .rateLimited
            default: throw .transport(error.description)
            }
        }
    }
}
```

### Assembling it

This presumes the copied-in `CloudBackend` / `ClaudeClient` from above and an on-device build (the
`OnDeviceBackend` is behind `#if canImport(FoundationModels)`), so it is construction guidance, not code that
compiles against the package as checked in.

```swift
let assistant = HybridAssistant(
    onDevice: OnDeviceBackend(),
    cloud: CloudBackend(client: ClaudeClient(baseURL: relayURL)),
    onDeviceAvailable: SystemLanguageModel.default.availability == .available
)
let reply = try await assistant.reply(to: userPrompt)   // reply.servedBy, reply.escalated, reply.text
```

## Build it with Claude

The one-liner:

> Build a hybrid assistant that routes between an on-device Foundation Models backend and a cloud Claude
> backend behind a shared LanguageBackend protocol. A pure EscalationPolicy decides the first tier (short and
> local stays on device; long or reasoning prompts go to cloud; unavailable on-device forces cloud). The
> orchestrator escalates on-device to cloud on unavailable, rate-limited, or context-exceeded, and propagates
> transport failures. Golden-vector tests for the policy and the escalation, using fake backends. Follow
> SWIFT.md.

The rules that constrain it: `SWIFT.md` (typed domain errors, value types, the Claude request shape, no key
in the binary) plus the runnability tiers (the device-required backend ships verified-on-device, the logic is
golden-vector tested). The verify loop runs the policy and orchestration tests headlessly; the live two-tier
flow is verified on device.

## Verify / tests

```sh
swift build
swift test
```

Ten tests across two suites pass: the policy routes short/long/keyword/unavailable cases correctly, and the
orchestrator stays on device, escalates on each recoverable failure, propagates transport failures, and
routes long prompts straight to the cloud without escalating. The captured run is in
[`verify-output/test-run.txt`](verify-output/test-run.txt). The live on-device and cloud calls are verified on
a device against a running relay; that transcript is not in CI.

## Pitfalls and trade-offs

- Escalation costs a round trip: an on-device failure means the user waits for the local attempt and then the
  cloud call. The policy keeps that rare by routing reasoning-flavored prompts straight to the cloud.
- The on-device model's error mapping is the one place this recipe is SDK-version sensitive (see the
  device-required note above). The escalation behavior it feeds is fully tested regardless.
- `onDeviceAvailable` is read once at construction here for clarity; a long-lived assistant should re-check
  it, because Apple Intelligence can be toggled or the model can finish downloading while the app runs.

## Decision guidance

Use the hybrid shape whenever an app has both a privacy-and-latency reason to stay local and a quality reason
to reach the cloud. If every task needs frontier reasoning, skip the on-device tier and use the cloud client
directly. If every task is short and local, skip the cloud tier. The seam is the `LanguageBackend` protocol;
keep new backends behind it so the routing stays testable.

## Reflection

The interesting decision was which failures escalate. Treating a transport error as escalatable was tempting,
but it usually means the network is down, which the cloud tier cannot fix either, so escalating would just
double the wait before the same failure. Restricting escalation to `.unavailable`, `.rateLimited`, and
`.contextExceeded` made the orchestrator both simpler and correct, and the golden vectors pin it. The forward
note is the one-line provider swap in Appendix A: on iOS 27, the on-device session can be driven by a Claude
provider, which turns this escalation into a model-config change.

## Next steps and related recipes

- The cloud-claude-chat recipe, whose client the cloud tier wraps.
- Appendix A, for the iOS 27 ClaudeForFoundationModels provider that makes the escalation a one-line swap.
- Part 7, Testing, for more on the fake-backend pattern these golden vectors use.
