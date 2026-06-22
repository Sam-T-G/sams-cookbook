import Combine

/// The pre-modern shape, the one a lot of real code (including the WAND probe) actually starts from: an
/// `ObservableObject` with `@Published` state and a plain array, mutated synchronously on whatever thread
/// the caller happens to be on.
///
/// It works in a single-threaded view, but two things age it. Nothing stops a background caller from racing
/// the array, and SwiftUI pays the Combine `objectWillChange` cost on every single change. This target
/// builds in the Swift 5 language mode, because that is the world this code came from.
public final class LegacyReadingStore: ObservableObject {
    @Published public private(set) var average: Double = 0

    private var readings: [Double] = []
    private let capacity: Int

    public init(capacity: Int = 8) {
        self.capacity = capacity
    }

    public func ingest(_ value: Double) {
        readings.append(value)
        if readings.count > capacity {
            readings.removeFirst(readings.count - capacity)
        }
        average = readings.isEmpty ? 0 : readings.reduce(0, +) / Double(readings.count)
    }
}
