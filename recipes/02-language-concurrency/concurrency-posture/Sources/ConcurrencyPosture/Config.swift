/// Central home for the recipe's tunable constants. Every magic number lives here, tied to a reason, so
/// the rest of the code reads as intent and a reviewer has one place to audit limits.
///
/// Marked `nonisolated` because the package default isolation is `MainActor`, and these constants are read
/// from the buffer actor and from tests, off the main actor.
public nonisolated enum Config {
    /// How many readings the rolling buffer keeps. Small on purpose: this is a teaching example.
    public static let bufferCapacity = 8
}
