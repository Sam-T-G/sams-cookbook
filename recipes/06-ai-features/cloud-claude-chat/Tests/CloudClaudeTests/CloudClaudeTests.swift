import Foundation
import Testing

@testable import CloudClaude

@Suite struct RequestEncodingTests {
    /// Encode the request, then read it back as a dictionary so assertions are order-independent.
    func bodyDict(_ request: ClaudeRequest) throws -> [String: Any] {
        let data = try JSONEncoder().encode(request)
        let object = try JSONSerialization.jsonObject(with: data)
        return try #require(object as? [String: Any])
    }

    @Test func encodesTheModernRequestShape() throws {
        let dict = try bodyDict(ClaudeRequest(messages: [.init(role: "user", content: "Hi")]))
        #expect(dict["model"] as? String == "claude-opus-4-8")
        #expect(dict["max_tokens"] as? Int == 4096)

        let thinking = try #require(dict["thinking"] as? [String: Any])
        #expect(thinking["type"] as? String == "adaptive")

        let output = try #require(dict["output_config"] as? [String: Any])
        #expect(output["effort"] as? String == "high")
    }

    @Test func omitsParametersTheModelRejects() throws {
        let dict = try bodyDict(ClaudeRequest(messages: [.init(role: "user", content: "Hi")]))
        #expect(dict["temperature"] == nil)
        #expect(dict["top_p"] == nil)
        #expect(dict["budget_tokens"] == nil)

        let thinking = try #require(dict["thinking"] as? [String: Any])
        #expect(thinking["budget_tokens"] == nil)
    }

    @Test func structuredOutputEncodesAsAJSONSchema() throws {
        let schema = JSONValue.object([
            "type": .string("object"),
            "properties": .object(["name": .object(["type": .string("string")])]),
            "required": .array([.string("name")]),
            "additionalProperties": .bool(false),
        ])
        let request = ClaudeRequest(
            messages: [.init(role: "user", content: "Extract the name")],
            outputConfig: .init(effort: "high", format: .init(schema: schema))
        )

        let dict = try bodyDict(request)
        let output = try #require(dict["output_config"] as? [String: Any])
        let format = try #require(output["format"] as? [String: Any])
        #expect(format["type"] as? String == "json_schema")
        #expect(format["schema"] is [String: Any])
    }

    @Test func omitsSystemWhenNotSet() throws {
        let dict = try bodyDict(ClaudeRequest(messages: [.init(role: "user", content: "Hi")]))
        #expect(dict["system"] == nil)
    }
}

@Suite struct ClientRequestTests {
    @Test func makeRequestSetsPathMethodAndHeaders() throws {
        let baseURL = try #require(URL(string: "https://relay.example.com"))
        let client = ClaudeClient(baseURL: baseURL)
        let body = ClaudeRequest(messages: [.init(role: "user", content: "Hi")])
        let request = try client.makeRequest(body)

        #expect(request.httpMethod == "POST")
        #expect(request.url?.absoluteString == "https://relay.example.com/v1/messages")
        #expect(request.value(forHTTPHeaderField: "anthropic-version") == "2023-06-01")
        #expect(request.value(forHTTPHeaderField: "content-type") == "application/json")
        #expect(request.httpBody?.isEmpty == false)
    }
}

@Suite struct ResponseDecodingTests {
    @Test func decodesAndConcatenatesText() throws {
        let json = """
            {"id":"msg_1","model":"claude-opus-4-8","role":"assistant","stop_reason":"end_turn",
             "content":[{"type":"text","text":"Hello, "},{"type":"text","text":"world."}]}
            """
        let response = try JSONDecoder().decode(ClaudeResponse.self, from: Data(json.utf8))
        #expect(response.text == "Hello, world.")
        #expect(response.stopReason == "end_turn")
    }

    @Test func refusalCarriesEmptyText() throws {
        let json = """
            {"id":"msg_2","model":"claude-opus-4-8","role":"assistant",
             "stop_reason":"refusal","content":[]}
            """
        let response = try JSONDecoder().decode(ClaudeResponse.self, from: Data(json.utf8))
        #expect(response.stopReason == "refusal")
        #expect(response.text.isEmpty)
    }

    @Test func errorDescriptionsAreHuman() {
        #expect(ClaudeError.http(status: 429).description.contains("429"))
        #expect(ClaudeError.transport("offline").description.contains("offline"))
    }
}
