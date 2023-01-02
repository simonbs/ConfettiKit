// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConfettiKit",
    platforms: [.iOS(.v15), .macCatalyst(.v15)],
    products: [
        .library(name: "ConfettiKit", targets: ["ConfettiKit"]),
    ],
    targets: [
        .target(name: "ConfettiKit", dependencies: [])
    ]
)
