/// The tunable knobs for routing. Magic numbers live here, tied to a reason, so a reviewer has one place to
/// audit them.
public nonisolated enum Config {
    /// Inputs longer than this go straight to the cloud; the on-device model is tuned for short, local tasks.
    public static let onDeviceCharacterCeiling = 600

    /// Prompts containing any of these markers ask for frontier reasoning, so they start in the cloud.
    public static let cloudKeywords = [
        "prove", "analyze deeply", "step by step", "research", "design a",
    ]

    /// The cloud model the cloud backend targets. Pinned in versions.lock.
    public static let cloudModel = "claude-opus-4-8"
}
