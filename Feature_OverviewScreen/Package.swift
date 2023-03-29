// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Feature_OverviewScreen",
    platforms: [
        .iOS(.v16) // minimum iOS version required is 16.0
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Feature_OverviewScreen",
            targets: ["Feature_OverviewScreen"]),
    ],
    dependencies: [
        .package(name: "Shared", path: "../Shared"),
        .package(name: "TransportCore", path: "../TransportCore"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
        .package(url: "https://github.com/Quick/Nimble", from: "11.2.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Feature_OverviewScreen",
            dependencies: [
                .product(name: "TransportCore", package: "TransportCore"),
                .product(name: "Shared", package: "Shared"),
                .product(name: "Kingfisher", package: "Kingfisher"),
            ]),
        .testTarget(
            name: "Feature_OverviewScreenTests",
            dependencies: [
                "Feature_OverviewScreen",
                .product(name: "Nimble", package: "Nimble")
            ]),
    ]
)
