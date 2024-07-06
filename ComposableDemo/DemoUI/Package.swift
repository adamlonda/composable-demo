// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "DemoUI",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "DemoUI",
            targets: ["DemoUI"]
        ),
    ],
    dependencies: [
        .package(name: "DemoModels", path: "../DemoModels"),
        .package(name: "DemoReducers", path: "../DemoReducers"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.10.4"),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.55.1")
    ],
    targets: [
        .target(
            name: "DemoUI",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "DemoModels", package: "DemoModels"),
                .product(name: "DemoReducers", package: "DemoReducers")
            ],
            resources: [.process("Media.xcassets")],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
        )
    ]
)
