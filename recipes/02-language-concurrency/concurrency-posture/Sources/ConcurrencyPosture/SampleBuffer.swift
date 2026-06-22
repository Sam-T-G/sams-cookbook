/// Shared mutable non-UI state: a rolling buffer of recent readings. It is an `actor`, not a
/// lock-guarded class, so the compiler proves there are no data races. Inputs are `Sendable` value types,
/// so nothing non-Sendable ever crosses the boundary.
public actor SampleBuffer {
    private var readings: [Reading] = []
    private let capacity: Int

    public init(capacity: Int = Config.bufferCapacity) {
        self.capacity = capacity
    }

    public var count: Int { readings.count }

    /// Append a reading, evicting the oldest when full. The actor is the only writer, so ordering is total
    /// and there is no torn read.
    public func append(_ reading: Reading) {
        readings.append(reading)
        if readings.count > capacity {
            readings.removeFirst(readings.count - capacity)
        }
    }

    public func latest() -> Reading? { readings.last }

    /// The mean of the buffered values. Throws a typed error rather than returning a misleading 0 for an
    /// empty buffer, so the caller has to decide what an empty window means.
    public func average() throws(PostureError) -> Double {
        guard !readings.isEmpty else { throw .emptyBuffer }
        let total = readings.reduce(0) { $0 + $1.value }
        return total / Double(readings.count)
    }
}
