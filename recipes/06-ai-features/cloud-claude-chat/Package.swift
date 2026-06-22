// swift-tools-version: 6.2
import PackageDescription

// Same posture as the concurrency-posture recipe. The Claude request-building and response-decoding logic
// is pure and runs headlessly; only the live `send` call needs the network (and the backend relay).
let posture: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .defaultIsolation(MainActor.self),
    .unsafeFlags(["-warnings-as-errors"]),
]

let package = Package(
    name: "CloudClaude",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "CloudClaude", targets: ["CloudClaude"])
    ],
    targets: [
        .target(name: "CloudClaude", swiftSettings: posture),
        .testTarget(
            name: "CloudClaudeTests",
            dependencies: ["CloudClaude"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
