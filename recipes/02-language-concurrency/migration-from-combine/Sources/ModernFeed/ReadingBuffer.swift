/// The mutable state, moved out of the view model and into an `actor`. The actor is the only writer, so
/// concurrent ingest from any task is race-free by construction, with no lock and no `DispatchQueue`. It is
/// the same shape as the buffer in the concurrency-posture recipe.
actor ReadingBuffer {
    private var readings: [Double] = []
    private let capacity: Int

    init(capacity: Int) {
        self.capacity = capacity
    }

    /// Append a value, evict beyond capacity, and return the new average in one hop, so the caller makes a
    /// single await rather than two round trips to the actor.
    func appendAndAverage(_ value: Double) -> Double {
        readings.append(value)
        if readings.count > capacity {
            readings.removeFirst(readings.count - capacity)
        }
        return readings.isEmpty ? 0 : readings.reduce(0, +) / Double(readings.count)
    }
}
