// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "CTNotificationService",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "CTNotificationService",
            targets: ["CTNotificationService"])
    ],
    targets: [
        .target(
            name: "CTNotificationService",
            path: "CTNotificationService",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath("."),
            ],
            linkerSettings: [
                .linkedFramework("UserNotifications"),
                .linkedFramework("UIKit")
            ]
        )
    ]
)
