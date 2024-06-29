// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "DemoReducers",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "DemoReducers",
            targets: ["DemoReducers"]
        ),
    ],
    dependencies: [
        .package(name: "DemoModels", path: "../DemoModels"),
        .package(name: "DemoStorage", path: "../DemoStorage"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.10.4"),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.55.1")
    ],
    targets: [
        .target(
            name: "DemoReducers",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "DemoModels", package: "DemoModels"),
                .product(name: "DemoStorage", package: "DemoStorage")
            ],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
        ),
        .testTarget(
            name: "DemoReducersTests",
            dependencies: ["DemoReducers"]
        ),
    ]
)
