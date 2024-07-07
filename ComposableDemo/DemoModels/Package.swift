// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "DemoModels",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "DemoModels",
            targets: ["DemoModels", "DemoModelMocks"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.0.1"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.55.1")
    ],
    targets: [
        .target(
            name: "DemoModels",
            dependencies: [
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                .product(name: "Tagged", package: "swift-tagged")
            ],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
        ),
        .target(
            name: "DemoModelMocks",
            dependencies: ["DemoModels"],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
        )
    ]
)
