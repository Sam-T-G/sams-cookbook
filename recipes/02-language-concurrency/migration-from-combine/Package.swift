// swift-tools-version: 6.2
import PackageDescription

// This recipe holds two targets on purpose: the legacy shape and the migrated shape, so a parity test can
// prove the migration preserves behavior.
//
// LegacyFeed builds in the Swift 5 language mode with relaxed concurrency, because that is the world the
// ObservableObject + Combine code actually came from. ModernFeed builds in the full posture (Swift 6 mode,
// MainActor default isolation, warnings as errors), the same one set in the concurrency-posture recipe.
let modernPosture: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .defaultIsolation(MainActor.self),
    .unsafeFlags(["-warnings-as-errors"]),
]

let package = Package(
    name: "MigrationFromCombine",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "LegacyFeed", targets: ["LegacyFeed"]),
        .library(name: "ModernFeed", targets: ["ModernFeed"]),
    ],
    targets: [
        .target(
            name: "LegacyFeed",
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "ModernFeed",
            swiftSettings: modernPosture
        ),
        .testTarget(
            name: "MigrationOnrampTests",
            dependencies: ["LegacyFeed", "ModernFeed"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
