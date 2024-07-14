// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NostrSDK",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "NostrSDK",
            targets: ["NostrSDK"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.0.0"),
        .package(url: "https://github.com/GigaBitcoin/secp256k1.swift", from: "0.12.2"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.8.1")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.1.2"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "NostrSDK",
            dependencies: [
                .product(name: "secp256k1", package: "secp256k1.swift"),
                "CryptoSwift",
                .product(name: "OrderedCollections", package: "swift-collections")
            ]
        ),
        .testTarget(
            name: "NostrSDKTests",
            dependencies: ["NostrSDK"],
            resources: [.copy("Fixtures")]
        )
    ]
)
