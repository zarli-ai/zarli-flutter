// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "zarli_flutter",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "zarli_flutter",
            targets: ["zarli_flutter"]
        )
    ],
    dependencies: [
        // Zarli iOS SDK dependency
        .package(url: "https://github.com/zarli-ai/zarli-ios-sdk.git", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "zarli_flutter",
            dependencies: [
                .product(name: "ZarliAdapterAdMob", package: "zarli-ios-sdk")
            ],
            path: ".",
            sources: ["Classes"],
            publicHeadersPath: "Classes"
        )
    ]
)
