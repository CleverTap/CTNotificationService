// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CTNotificationService",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "CTNotificationService", targets: ["CTNotificationService"])
    ],
    targets: [
        .target(
            name: "CTNotificationService",
            dependencies: [],
            path: "CTNotificationService",
            exclude: ["CTNotificationService.plist"],
            publicHeadersPath: "include"
        )
    ]
)
