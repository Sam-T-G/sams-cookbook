/// Typed domain errors for the buffer. Typed because the set is small and exhaustive, which lets a caller
/// switch without a `default` and lets the compiler check every case is handled. (SE-0413)
public nonisolated enum PostureError: Error, CustomStringConvertible, Equatable {
    case emptyBuffer

    public var description: String {
        switch self {
        case .emptyBuffer: "the sample buffer is empty"
        }
    }
}
