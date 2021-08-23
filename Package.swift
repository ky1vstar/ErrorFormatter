// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "ErrorFormatter",
    platforms: [
        .iOS(.v9),
        .tvOS(.v9),
        .watchOS(.v2),
        .macOS(.v10_10)
    ],
    products: [
        .library(
            name: "ErrorFormatter",
            targets: ["ErrorFormatter"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ErrorFormatter",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "ErrorFormatterTests",
            dependencies: ["ErrorFormatter"],
            path: "Tests"
        ),
    ]
)
