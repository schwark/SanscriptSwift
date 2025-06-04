// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SanscriptSwift",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SanscriptSwift",
            targets: ["SanscriptSwift"]),
        .executable(
            name: "SanscriptCLI",
            targets: ["SanscriptCLI"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SanscriptSwift",
            dependencies: [],
            resources: [
                .process("Resources")
            ]),
        .executableTarget(
            name: "SanscriptCLI",
            dependencies: ["SanscriptSwift"],
            resources: [
                .process("test_cases.json")
            ]),
        .testTarget(
            name: "SanscriptSwiftTests",
            dependencies: ["SanscriptSwift"]),
    ]
)
