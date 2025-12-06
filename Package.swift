// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSCleaner",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "iOSCleanerCore",
            targets: ["iOSCleanerCore"]),
    ],
    dependencies: [
        // No external dependencies to keep it simple and open source
    ],
    targets: [
        .target(
            name: "iOSCleanerCore",
            dependencies: [],
            path: "Sources/iOSCleaner",
            exclude: ["Views", "App"],
            sources: ["StorageAnalyzer.swift", "DuplicateDetector.swift", "CacheCleaner.swift", "iOSCleaner.swift"]),
        .testTarget(
            name: "iOSCleanerTests",
            dependencies: ["iOSCleanerCore"]),
    ]
)
