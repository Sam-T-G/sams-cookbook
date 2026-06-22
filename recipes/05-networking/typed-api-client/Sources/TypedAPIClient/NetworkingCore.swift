import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// Typed domain errors for a request. Small and exhaustive, so a caller switches without a default and the
/// compiler checks every case is handled.
public nonisolated enum APIError: Error, CustomStringConvertible, Equatable {
    case invalidResponse
    case status(code: Int)
    case decoding(String)
    case transport(String)

    public var description: String {
        switch self {
        case .invalidResponse: "the server did not return an HTTP response"
        case .status(let code): "the server returned HTTP \(code)"
        case .decoding(let detail): "could not decode the response: \(detail)"
        case .transport(let detail): "the request failed to send: \(detail)"
        }
    }
}

/// The network seam. The real client uses `URLSessionTransport`; tests inject a fake so the status
/// validation, error mapping, and decoding can be exercised with no network and no flakiness.
public protocol Transport: Sendable {
    func send(_ request: URLRequest) async throws -> (Data, URLResponse)
}

/// The production transport: a thin wrapper over `URLSession`.
public nonisolated struct URLSessionTransport: Transport {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}

/// A request descriptor. Keeping it a value type means the request shape is data, easy to build and easy to
/// assert on in a golden vector.
public nonisolated struct Endpoint: Sendable {
    public var path: String
    public var method: String
    public var queryItems: [URLQueryItem]

    public init(path: String, method: String = "GET", queryItems: [URLQueryItem] = []) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
    }
}
