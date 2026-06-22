// swift-tools-version: 6.2
import PackageDescription

// The routing and escalation logic is pure and runs headlessly. The on-device backend uses the Foundation
// Models framework and is verified on a device, not in CI; it compiles here behind canImport.
let posture: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .defaultIsolation(MainActor.self),
    .unsafeFlags(["-warnings-as-errors"]),
]

let package = Package(
    name: "HybridAssistant",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "HybridAssistant", targets: ["HybridAssistant"])
    ],
    targets: [
        .target(name: "HybridAssistant", swiftSettings: posture),
        .testTarget(
            name: "HybridAssistantTests",
            dependencies: ["HybridAssistant"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
