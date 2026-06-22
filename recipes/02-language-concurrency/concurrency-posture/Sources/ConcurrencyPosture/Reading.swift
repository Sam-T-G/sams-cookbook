/// One sensor sample. A value type that crosses the actor boundary into the buffer, so it is `Sendable`
/// and `nonisolated`. Nothing here touches the main actor, so we opt out of the package default.
public nonisolated struct Reading: Sendable, Equatable {
    public let value: Double
    public let timestamp: Double

    public init(value: Double, timestamp: Double) {
        self.value = value
        self.timestamp = timestamp
    }
}
