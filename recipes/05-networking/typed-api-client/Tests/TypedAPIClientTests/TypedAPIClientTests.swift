import Foundation
import Testing

@testable import TypedAPIClient

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// A fake transport so the client's validation, error mapping, and decoding run with no network. It returns
/// a fixed body and status, or throws a fixed error.
struct FakeTransport: Transport {
    var data: Data = Data()
    var statusCode: Int = 200
    var failWith: Error?

    func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        if let failWith { throw failWith }
        let url = request.url ?? URL(filePath: "/")
        guard
            let response = HTTPURLResponse(
                url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        else {
            throw APIError.invalidResponse
        }
        return (data, response)
    }
}

struct Widget: Codable, Equatable, Sendable {
    let id: Int
    let displayName: String
    let createdAt: Date
}

@Suite struct APIClientTests {
    func client(_ transport: FakeTransport) throws -> APIClient {
        let base = try #require(URL(string: "https://api.example.com"))
        return APIClient(baseURL: base, transport: transport)
    }

    @Test func decodesSnakeCaseAndISO8601() async throws {
        let json = #"{"id":7,"display_name":"Sprocket","created_at":"2026-06-21T00:00:00Z"}"#
        let transport = FakeTransport(data: Data(json.utf8), statusCode: 200)
        let widget: Widget = try await client(transport).fetch(Endpoint(path: "widgets/7"))
        #expect(widget.id == 7)
        #expect(widget.displayName == "Sprocket")
    }

    @Test func mapsNotFoundToStatusError() async throws {
        let transport = FakeTransport(statusCode: 404)
        let target = try client(transport)
        await #expect(throws: APIError.status(code: 404)) {
            let _: Widget = try await target.fetch(Endpoint(path: "widgets/0"))
        }
    }

    @Test func mapsServerErrorToStatusError() async throws {
        let transport = FakeTransport(statusCode: 503)
        let target = try client(transport)
        await #expect(throws: APIError.status(code: 503)) {
            let _: Widget = try await target.fetch(Endpoint(path: "x"))
        }
    }

    @Test func malformedBodyBecomesDecodingError() async throws {
        let transport = FakeTransport(data: Data("not json".utf8), statusCode: 200)
        let target = try client(transport)
        do {
            let _: Widget = try await target.fetch(Endpoint(path: "x"))
            Issue.record("expected a decoding error")
        } catch {
            guard case .decoding = error else {
                Issue.record("expected .decoding, got \(error)")
                return
            }
        }
    }

    @Test func transportFailureBecomesTransportError() async throws {
        let transport = FakeTransport(failWith: URLError(.notConnectedToInternet))
        let target = try client(transport)
        do {
            let _: Widget = try await target.fetch(Endpoint(path: "x"))
            Issue.record("expected a transport error")
        } catch {
            guard case .transport = error else {
                Issue.record("expected .transport, got \(error)")
                return
            }
        }
    }
}

@Suite struct RequestBuildingTests {
    @Test func buildsPathMethodAndQuery() throws {
        let base = try #require(URL(string: "https://api.example.com"))
        let endpoint = Endpoint(
            path: "search",
            queryItems: [URLQueryItem(name: "q", value: "sprocket")]
        )
        let request = APIClient.makeRequest(baseURL: base, endpoint: endpoint)
        #expect(request.httpMethod == "GET")
        #expect(request.url?.absoluteString == "https://api.example.com/search?q=sprocket")
    }

    @Test func errorDescriptionsAreHuman() {
        #expect(APIError.status(code: 404).description.contains("404"))
        #expect(APIError.invalidResponse.description.contains("HTTP"))
    }
}
