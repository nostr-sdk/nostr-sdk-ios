let package = Package(
    name: "NostrSDKDemo",
    dependencies: [
        .package(path: "../")
    ],
    targets: [
        .target(
            name: "NostrSDKDemo",
            dependencies: ["NostrSDK"])
    ]
)
