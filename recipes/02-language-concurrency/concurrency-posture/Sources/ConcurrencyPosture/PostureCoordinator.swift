/// A main-actor coordinator, the kind of type a SwiftUI view would hold. It is on the main actor because
/// the package sets `MainActor` as the default isolation and we did not opt out, so there is no annotation
/// to forget. It reaches into the buffer actor with `await`, which is the only way to touch shared state.
/// That await is not friction; it is the compiler making the actor hop visible.
public final class PostureCoordinator {
    private let buffer: SampleBuffer

    public init(buffer: SampleBuffer = SampleBuffer()) {
        self.buffer = buffer
    }

    /// Record a sample. The body hops to the actor; the coordinator itself never holds the mutable state.
    public func record(_ value: Double, at timestamp: Double) async {
        await buffer.append(Reading(value: value, timestamp: timestamp))
    }

    /// The current smoothed value, or nil when the window is empty. We translate the buffer's typed error
    /// into an optional here, because at the UI layer an empty window is a display state, not a failure.
    public func smoothedAverage() async -> Double? {
        try? await buffer.average()
    }
}
