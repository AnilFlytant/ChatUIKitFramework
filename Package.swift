// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "ChatUIKitFramework",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ChatUIKitFramework",
            targets: ["ChatUIKitFramework"]
        )
    ],
    targets: [
        .target(
            name: "ChatUIKitFramework",
            dependencies: []
        ),
        .testTarget(
            name: "ChatUIKitFrameworkTests",
            dependencies: ["ChatUIKitFramework"]
        )
    ]
)
