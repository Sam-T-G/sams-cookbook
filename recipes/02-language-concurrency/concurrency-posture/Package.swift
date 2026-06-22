// swift-tools-version: 6.2
import PackageDescription

// The concurrency posture, set once at the package level:
// - Swift 6 language mode (strict concurrency is complete in this mode).
// - MainActor as the default isolation, so anything we do not mark lands on the main actor and pure
//   logic opts out explicitly with `nonisolated`. (SE-0466)
// - Warnings as errors, so a data-race warning fails the build instead of rotting.
let postureSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .defaultIsolation(MainActor.self),
    .unsafeFlags(["-warnings-as-errors"]),
]

let package = Package(
    name: "ConcurrencyPosture",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "ConcurrencyPosture", targets: ["ConcurrencyPosture"])
    ],
    targets: [
        .target(
            name: "ConcurrencyPosture",
            swiftSettings: postureSettings
        ),
        // The test target stays nonisolated by default: pure-logic golden vectors run in parallel,
        // and the one main-actor type is exercised by an explicitly @MainActor suite.
        .testTarget(
            name: "ConcurrencyPostureTests",
            dependencies: ["ConcurrencyPosture"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
