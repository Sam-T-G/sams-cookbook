import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// A small client for the Claude Messages API, pointed at your backend relay rather than at Anthropic
/// directly. There is no API key here on purpose: the relay holds it server side and adds it at egress
/// (see recipes/09-cross-cutting and samples/backend-relay). The client is a stateless value type, so it is
/// a `nonisolated struct`, not an actor. Reach for an actor only when there is shared mutable state to
/// protect; this has none.
public nonisolated struct ClaudeClient: Sendable {
    public var baseURL: URL
    public var apiVersion: String
    private let session: URLSession

    public init(
        baseURL: URL,
        apiVersion: String = Config.anthropicVersion,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.apiVersion = apiVersion
        self.session = session
    }

    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()

    /// Build the `URLRequest` for a Messages call. Pure and testable: no network happens here, so a golden
    /// vector can assert the exact body and headers we send.
    public func makeRequest(_ body: ClaudeRequest) throws -> URLRequest {
        var request = URLRequest(url: baseURL.appending(path: "v1/messages"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(apiVersion, forHTTPHeaderField: "anthropic-version")
        request.httpBody = try Self.encoder.encode(body)
        return request
    }

    /// Send the request and decode the response. This is the one part that needs the network and the relay,
    /// so it is verified on device, not in CI. Every failure maps to a typed `ClaudeError`.
    public func send(_ body: ClaudeRequest) async throws(ClaudeError) -> ClaudeResponse {
        let request: URLRequest
        do {
            request = try makeRequest(body)
        } catch {
            throw .encoding(String(describing: error))
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw .transport(String(describing: error))
        }

        guard let http = response as? HTTPURLResponse else {
            throw .transport("the response was not HTTP")
        }
        guard (200..<300).contains(http.statusCode) else {
            throw .http(status: http.statusCode)
        }

        do {
            return try Self.decoder.decode(ClaudeResponse.self, from: data)
        } catch {
            throw .decoding(String(describing: error))
        }
    }
}
