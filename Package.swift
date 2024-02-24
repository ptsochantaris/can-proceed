// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "CanProceed",
    platforms: [
        .macOS(.v13),
        .iOS(.v14),
        .watchOS(.v7)
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
