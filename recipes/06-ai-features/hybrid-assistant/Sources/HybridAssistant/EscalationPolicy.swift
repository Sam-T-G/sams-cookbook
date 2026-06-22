/// Which tier serves a turn. On-device is private, offline, and free; cloud is for frontier reasoning.
public nonisolated enum AssistantTier: Sendable, Equatable {
    case onDevice
    case cloud
}

/// The pure routing decision: given the prompt and whether the on-device model is available, decide where to
/// start. This is the most test-worthy part of the assistant, so it is pure and lives apart from the
/// backends and the network. The golden vectors pin it exactly.
public nonisolated struct EscalationPolicy: Sendable {
    public let onDeviceCharacterCeiling: Int
    public let cloudKeywords: [String]

    public init(
        onDeviceCharacterCeiling: Int = Config.onDeviceCharacterCeiling,
        cloudKeywords: [String] = Config.cloudKeywords
    ) {
        self.onDeviceCharacterCeiling = onDeviceCharacterCeiling
        self.cloudKeywords = cloudKeywords
    }

    /// Pick the tier to try first. Long inputs and reasoning-flavored prompts start in the cloud; everything
    /// else stays on device when it is available.
    public func firstTier(for prompt: String, onDeviceAvailable: Bool) -> AssistantTier {
        guard onDeviceAvailable else { return .cloud }
        if prompt.count > onDeviceCharacterCeiling { return .cloud }
        let lowered = prompt.lowercased()
        if cloudKeywords.contains(where: { lowered.contains($0) }) { return .cloud }
        return .onDevice
    }
}
