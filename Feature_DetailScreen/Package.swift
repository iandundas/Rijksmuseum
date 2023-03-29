// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Feature_DetailScreen",
    platforms: [
        .iOS(.v16) // minimum iOS version required is 16.0
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Feature_DetailScreen",
            targets: ["Feature_DetailScreen"]),
    ],
    dependencies: [
        .package(name: "Shared", path: "../Shared"),
        .package(name: "Transport", path: "../Transport"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Feature_DetailScreen",
            dependencies: [
                .product(name: "Transport", package: "Transport"),
                .product(name: "Shared", package: "Shared"),
            ]),
        .testTarget(
            name: "Feature_DetailScreenTests",
            dependencies: ["Feature_DetailScreen"]),
    ]
)
