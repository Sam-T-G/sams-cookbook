import Testing

@testable import HybridAssistant

/// A fake backend so the routing and escalation logic can be tested with no device and no network. It either
/// returns a fixed reply or throws a fixed error.
struct StubBackend: LanguageBackend {
    var reply: String = "stub"
    var error: BackendError?

    func respond(to prompt: String) async throws(BackendError) -> String {
        if let error { throw error }
        return reply
    }
}

@Suite struct EscalationPolicyTests {
    let policy = EscalationPolicy()

    @Test func shortLocalPromptStaysOnDevice() {
        #expect(policy.firstTier(for: "What time is it?", onDeviceAvailable: true) == .onDevice)
    }

    @Test func longPromptGoesToCloud() {
        let long = String(repeating: "a", count: 700)
        #expect(policy.firstTier(for: long, onDeviceAvailable: true) == .cloud)
    }

    @Test func reasoningKeywordGoesToCloud() {
        let prompt = "Prove that the square root of 2 is irrational"
        #expect(policy.firstTier(for: prompt, onDeviceAvailable: true) == .cloud)
    }

    @Test func unavailableOnDeviceForcesCloud() {
        #expect(policy.firstTier(for: "hi", onDeviceAvailable: false) == .cloud)
    }
}

@Suite struct HybridAssistantTests {
    @Test func staysOnDeviceForASimplePrompt() async throws {
        let assistant = HybridAssistant(
            onDevice: StubBackend(reply: "local answer"),
            cloud: StubBackend(reply: "cloud answer")
        )
        let reply = try await assistant.reply(to: "hi")
        #expect(reply.servedBy == .onDevice)
        #expect(reply.escalated == false)
        #expect(reply.text == "local answer")
    }

    @Test func escalatesWhenOnDeviceIsRateLimited() async throws {
        let assistant = HybridAssistant(
            onDevice: StubBackend(error: .rateLimited),
            cloud: StubBackend(reply: "cloud answer")
        )
        let reply = try await assistant.reply(to: "hi")
        #expect(reply.servedBy == .cloud)
        #expect(reply.escalated)
        #expect(reply.text == "cloud answer")
    }

    @Test func escalatesWhenContextIsExceeded() async throws {
        let assistant = HybridAssistant(
            onDevice: StubBackend(error: .contextExceeded),
            cloud: StubBackend(reply: "cloud answer")
        )
        #expect(try await assistant.reply(to: "hi").servedBy == .cloud)
    }

    @Test func escalatesWhenOnDeviceIsUnavailable() async throws {
        let assistant = HybridAssistant(
            onDevice: StubBackend(error: .unavailable),
            cloud: StubBackend(reply: "cloud answer")
        )
        #expect(try await assistant.reply(to: "hi").escalated)
    }

    @Test func transportFailureDoesNotEscalate() async {
        let assistant = HybridAssistant(
            onDevice: StubBackend(error: .transport("boom")),
            cloud: StubBackend(reply: "cloud answer")
        )
        await #expect(throws: BackendError.transport("boom")) {
            _ = try await assistant.reply(to: "hi")
        }
    }

    @Test func longPromptRoutesStraightToCloudWithoutTouchingOnDevice() async throws {
        let assistant = HybridAssistant(
            onDevice: StubBackend(error: .transport("should not be called")),
            cloud: StubBackend(reply: "cloud answer")
        )
        let reply = try await assistant.reply(to: String(repeating: "x", count: 700))
        #expect(reply.servedBy == .cloud)
        // Routed by the policy, not escalated after a failure.
        #expect(reply.escalated == false)
    }
}
