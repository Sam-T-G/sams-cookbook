import Foundation

/// Central config for the Claude calls. The model id and the request shape are verified against the Claude
/// API reference (June 2026): claude-opus-4-8 takes adaptive thinking, the effort control nested in
/// output_config, and structured outputs via output_config.format. It rejects temperature, budget_tokens,
/// and assistant prefill, so this client never sends them.
public nonisolated enum Config {
    public static let model = "claude-opus-4-8"
    public static let maxTokens = 4096
    public static let effort = "high"  // low | medium | high | xhigh | max
    public static let anthropicVersion = "2023-06-01"
}

/// Typed domain errors for a Claude call. Small and exhaustive, so a caller can switch without a default.
public nonisolated enum ClaudeError: Error, CustomStringConvertible, Equatable {
    case encoding(String)
    case transport(String)
    case http(status: Int)
    case decoding(String)

    public var description: String {
        switch self {
        case .encoding(let detail): "could not encode the request: \(detail)"
        case .transport(let detail): "the request did not reach the relay: \(detail)"
        case .http(let status): "the relay returned HTTP \(status)"
        case .decoding(let detail): "could not decode the response: \(detail)"
        }
    }
}

/// A minimal JSON value, just enough to carry a JSON Schema for structured outputs. Encodable so it drops
/// straight into the request body.
public nonisolated enum JSONValue: Encodable, Sendable, Equatable {
    case string(String)
    case number(Double)
    case integer(Int)
    case bool(Bool)
    case array([JSONValue])
    case object([String: JSONValue])
    case null

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .number(let value): try container.encode(value)
        case .integer(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        case .object(let value): try container.encode(value)
        case .null: try container.encodeNil()
        }
    }
}

/// The subset of the Anthropic Messages API request this cookbook uses. It encodes to the exact wire shape
/// claude-opus-4-8 expects. Defaults match the house posture: adaptive thinking on, effort high.
public nonisolated struct ClaudeRequest: Encodable, Sendable {
    public var model: String
    public var maxTokens: Int
    public var messages: [Message]
    public var system: String?
    public var thinking: Thinking?
    public var outputConfig: OutputConfig?

    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case messages
        case system
        case thinking
        case outputConfig = "output_config"
    }

    /// A single conversation turn. `role` is "user", "assistant", or "system" (the last only as a
    /// mid-conversation operator note on Opus 4.8). Content is plain text here; the API also accepts content
    /// arrays, which a later recipe covers.
    public struct Message: Encodable, Sendable, Equatable {
        public var role: String
        public var content: String

        public init(role: String, content: String) {
            self.role = role
            self.content = content
        }
    }

    /// Adaptive thinking. `budget_tokens` is gone on 4.6+; this struct cannot express it, by design.
    public struct Thinking: Encodable, Sendable {
        public var type: String
        public var display: String?

        public init(type: String = "adaptive", display: String? = nil) {
            self.type = type
            self.display = display
        }
    }

    /// Output controls. `effort` is the depth knob; `format` carries a JSON Schema for structured output.
    public struct OutputConfig: Encodable, Sendable {
        public var effort: String?
        public var format: Format?

        public init(effort: String? = nil, format: Format? = nil) {
            self.effort = effort
            self.format = format
        }

        public struct Format: Encodable, Sendable {
            public var type: String
            public var schema: JSONValue

            public init(type: String = "json_schema", schema: JSONValue) {
                self.type = type
                self.schema = schema
            }
        }
    }

    public init(
        model: String = Config.model,
        maxTokens: Int = Config.maxTokens,
        messages: [Message],
        system: String? = nil,
        thinking: Thinking? = Thinking(),
        outputConfig: OutputConfig? = OutputConfig(effort: Config.effort)
    ) {
        self.model = model
        self.maxTokens = maxTokens
        self.messages = messages
        self.system = system
        self.thinking = thinking
        self.outputConfig = outputConfig
    }
}

/// The part of the Messages API response a chat UI needs. Decodes the content blocks and exposes the joined
/// text. Always check `stopReason` before trusting `text`: a "refusal" carries empty content.
public nonisolated struct ClaudeResponse: Decodable, Sendable, Equatable {
    public let id: String
    public let model: String
    public let role: String
    public let stopReason: String?
    public let content: [ContentBlock]

    enum CodingKeys: String, CodingKey {
        case id, model, role, content
        case stopReason = "stop_reason"
    }

    public struct ContentBlock: Decodable, Sendable, Equatable {
        public let type: String
        public let text: String?
    }

    /// The concatenated text of every text block, which is the usual thing to show a user.
    public var text: String {
        content.filter { $0.type == "text" }.compactMap(\.text).joined()
    }
}
