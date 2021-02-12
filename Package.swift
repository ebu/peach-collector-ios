// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PeachCollector",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "PeachCollector",
            type: .static,
            targets: ["PeachCollector"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "PeachCollector",
            dependencies: [],
            path: "Sources/",
            exclude: ["PeachCollector/Resources/Info.plist",],
            resources: [.process("Resources")],
            publicHeadersPath: "PeachCollector"),
        .testTarget(
            name: "PeachCollectorTests",
            dependencies: ["PeachCollector"],
            path: "Tests",
            exclude: ["Info.plist",]
            ),
    ]
)
