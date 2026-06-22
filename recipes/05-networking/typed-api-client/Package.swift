// swift-tools-version: 6.2
import PackageDescription

// The status validation, error mapping, decoding, and request building are pure and run headlessly through
// a Transport seam. Only the URLSessionTransport touches the network.
let posture: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .defaultIsolation(MainActor.self),
    .unsafeFlags(["-warnings-as-errors"]),
]

let package = Package(
    name: "TypedAPIClient",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "TypedAPIClient", targets: ["TypedAPIClient"])
    ],
    targets: [
        .target(name: "TypedAPIClient", swiftSettings: posture),
        .testTarget(
            name: "TypedAPIClientTests",
            dependencies: ["TypedAPIClient"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
