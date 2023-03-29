// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "App",
    platforms: [
        .iOS(.v16) // minimum iOS version required is 16.0
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "App",
            targets: ["App"]),
    ],
    dependencies: [
        .package(name: "Shared", path: "../Shared"),
        .package(name: "Feature_OverviewScreen", path: "../Feature_OverviewScreen"),
        .package(name: "Feature_DetailScreen", path: "../Feature_DetailScreen"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "App",
            dependencies: [
                .product(name: "Shared", package: "Shared"),
                .product(name: "Feature_OverviewScreen", package: "Feature_OverviewScreen"),
                .product(name: "Feature_DetailScreen", package: "Feature_DetailScreen"),
            ]),
        .testTarget(
            name: "AppTests",
            dependencies: ["App"]),
    ]
)
