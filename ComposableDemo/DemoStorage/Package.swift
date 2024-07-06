// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "DemoStorage",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "DemoStorage",
            targets: ["DemoStorage"]
        ),
    ],
    dependencies: [
        .package(name: "DemoModels", path: "../DemoModels"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.10.4"),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.55.1")
    ],
    targets: [
        .target(
            name: "DemoStorage",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "DemoModels", package: "DemoModels")
            ],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
        )
    ]
)
