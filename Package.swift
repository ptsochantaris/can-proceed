// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "CanProceed",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "CanProceed",
            targets: ["CanProceed"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ptsochantaris/lista", branch: "main")
    ],
    targets: [
        .target(
            name: "CanProceed",
            dependencies: [.product(name: "Lista", package: "lista")]
        ),
        .testTarget(
            name: "CanProceedTests",
            dependencies: ["CanProceed"]
        )
    ]
)
