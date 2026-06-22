import Observation

/// The migrated shape: an `@Observable` model with no Combine and no `@Published`, holding only the derived
/// value the view shows, backed by an `actor` that owns the mutable buffer.
///
/// The model is on the main actor (the package default), so the view reads `average` with no ceremony.
/// `ingest` is async because it hops to the actor; that await is the compiler making the boundary visible,
/// which is exactly the safety the legacy version lacked. SwiftUI observes only the properties a view reads,
/// rather than paying a blanket `objectWillChange` on every change.
@Observable
public final class ModernReadingStore {
    public private(set) var average: Double = 0

    private let buffer: ReadingBuffer

    public init(capacity: Int = 8) {
        self.buffer = ReadingBuffer(capacity: capacity)
    }

    public func ingest(_ value: Double) async {
        average = await buffer.appendAndAverage(value)
    }
}
