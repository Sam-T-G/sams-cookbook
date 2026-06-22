/// A text-in, text-out language backend. Both the on-device model and the cloud Claude client conform, so
/// the assistant can route between them without caring which is which.
public protocol LanguageBackend: Sendable {
    func respond(to prompt: String) async throws(BackendError) -> String
}

/// Typed failures a backend can report. The first three drive escalation from on-device to cloud; a
/// transport failure is not something a different tier can fix, so it propagates.
public nonisolated enum BackendError: Error, CustomStringConvertible, Equatable {
    case unavailable
    case rateLimited
    case contextExceeded
    case transport(String)

    public var description: String {
        switch self {
        case .unavailable: "the backend is unavailable on this device"
        case .rateLimited: "the backend is rate limited"
        case .contextExceeded: "the input is larger than the backend's context window"
        case .transport(let detail): "the backend call failed: \(detail)"
        }
    }
}
