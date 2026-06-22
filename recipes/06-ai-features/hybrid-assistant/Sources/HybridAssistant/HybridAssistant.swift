/// One reply, plus which tier produced it and whether the assistant had to escalate to get it. The metadata
/// is what a UI shows ("answered on device") and what the tests assert on.
public nonisolated struct AssistantReply: Sendable, Equatable {
    public let text: String
    public let servedBy: AssistantTier
    public let escalated: Bool
}

/// Routes a prompt between an on-device backend and a cloud backend. It starts at the tier the policy picks,
/// and escalates on-device to cloud when the on-device tier is unavailable, rate limited, or out of context.
/// A transport failure is not recoverable by switching tiers, so it propagates.
///
/// The backends are injected as `LanguageBackend` values, which is what makes the whole thing testable: the
/// golden vectors drive it with fake backends and assert the routing and escalation, with no device and no
/// network.
public nonisolated struct HybridAssistant: Sendable {
    private let onDevice: any LanguageBackend
    private let cloud: any LanguageBackend
    private let policy: EscalationPolicy
    private let onDeviceAvailable: Bool

    public init(
        onDevice: any LanguageBackend,
        cloud: any LanguageBackend,
        policy: EscalationPolicy = EscalationPolicy(),
        onDeviceAvailable: Bool = true
    ) {
        self.onDevice = onDevice
        self.cloud = cloud
        self.policy = policy
        self.onDeviceAvailable = onDeviceAvailable
    }

    public func reply(to prompt: String) async throws(BackendError) -> AssistantReply {
        switch policy.firstTier(for: prompt, onDeviceAvailable: onDeviceAvailable) {
        case .cloud:
            let text = try await cloud.respond(to: prompt)
            return AssistantReply(text: text, servedBy: .cloud, escalated: false)

        case .onDevice:
            do {
                let text = try await onDevice.respond(to: prompt)
                return AssistantReply(text: text, servedBy: .onDevice, escalated: false)
            } catch let error {
                switch error {
                case .unavailable, .rateLimited, .contextExceeded:
                    let text = try await cloud.respond(to: prompt)
                    return AssistantReply(text: text, servedBy: .cloud, escalated: true)
                case .transport:
                    throw error
                }
            }
        }
    }
}
