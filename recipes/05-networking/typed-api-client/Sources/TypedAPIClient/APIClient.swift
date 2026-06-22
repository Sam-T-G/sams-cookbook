import Foundation
import os

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// A typed API client. It is an `actor` because it owns shared, reusable state (the transport, the
/// configured decoder, the logger) that concurrent callers touch, which is exactly when SWIFT.md says to
/// reach for an actor rather than a lock. Status validation maps non-2xx responses to a typed error, and one
/// centralized decoder handles snake_case and ISO-8601 dates for every call.
public actor APIClient {
    private let baseURL: URL
    private let transport: any Transport
    private let decoder: JSONDecoder
    private let logger = Logger(subsystem: "cookbook.networking", category: "APIClient")

    public init(baseURL: URL, transport: any Transport = URLSessionTransport()) {
        self.baseURL = baseURL
        self.transport = transport

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    /// Fetch and decode a value. Every failure becomes a typed `APIError`: a non-HTTP response, a non-2xx
    /// status, a transport failure, or a decode failure.
    public func fetch<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws(APIError) -> T {
        let request = Self.makeRequest(baseURL: baseURL, endpoint: endpoint)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await transport.send(request)
        } catch {
            throw .transport(String(describing: error))
        }

        guard let http = response as? HTTPURLResponse else {
            throw .invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            logger.warning("non-2xx \(http.statusCode) for \(endpoint.path, privacy: .public)")
            throw .status(code: http.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw .decoding(String(describing: error))
        }
    }

    /// Build the request. Pure and static, so a golden vector can assert the path, method, and query without
    /// constructing a client.
    nonisolated static func makeRequest(baseURL: URL, endpoint: Endpoint) -> URLRequest {
        let url = baseURL.appending(path: endpoint.path)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if !endpoint.queryItems.isEmpty {
            components?.queryItems = endpoint.queryItems
        }
        var request = URLRequest(url: components?.url ?? url)
        request.httpMethod = endpoint.method
        return request
    }
}
