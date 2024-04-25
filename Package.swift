// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MapleStory",
    platforms: [
        .macOS("13.0")
    ],
    products: [
        .library(
            name: "MapleStory",
            targets: ["MapleStory"]
        ),
        .library(
            name: "MapleStory28",
            targets: ["MapleStory"]
        ),
        .library(
            name: "MapleStory40",
            targets: ["MapleStory"]
        ),
        .library(
            name: "MapleStory62",
            targets: ["MapleStory"]
        ),
        .library(
            name: "MapleStory83",
            targets: ["MapleStory"]
        ),
        .executable(
            name: "MapleStoryLoginServer",
            targets: ["MapleStoryLoginServer"]
        ),
        .executable(
            name: "MapleStoryServer62",
            targets: ["MapleStoryServer62"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/PureSwift/Socket",
            branch: "main"
        ),
        .package(
            url: "https://github.com/PureSwift/CoreModel",
            branch: "master"
        ),
        .package(
            url: "https://github.com/PureSwift/CoreModel-MongoDB",
            branch: "master"
        ),
        .package(
            url: "https://github.com/krzyzanowskim/CryptoSwift.git",
            .upToNextMajor(from: "1.6.0")
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.2.0"
        ),
        .package(
            url: "https://github.com/mongodb/mongo-swift-driver",
            .upToNextMajor(from: "1.3.1")
        )
    ],
    targets: [
        .target(
            name: "MapleStory",
            dependencies: [
                "CMapleStory",
                "CryptoSwift",
                "Socket",
                .product(
                    name: "CoreModel",
                    package: "CoreModel"
                )
            ]
        ),
        .target(
            name: "MapleStory28",
            dependencies: [
                "MapleStory"
            ]
        ),
        .target(
            name: "MapleStory40",
            dependencies: [
                "MapleStory"
            ]
        ),
        .target(
            name: "MapleStory62",
            dependencies: [
                "MapleStory"
            ]
        ),
        .target(
            name: "MapleStory83",
            dependencies: [
                "MapleStory"
            ]
        ),
        .executableTarget(
            name: "MapleStoryLoginServer",
            dependencies: [
                "MapleStory",
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
                .product(
                    name: "MongoSwift",
                    package: "mongo-swift-driver"
                )
            ],
            swiftSettings: [
              // Enable better optimizations when building in Release configuration. Despite the use of
              // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
              // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
              .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .executableTarget(
            name: "MapleStoryServer62",
            dependencies: [
                "MapleStory62",
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
                .product(
                    name: "MongoSwift",
                    package: "mongo-swift-driver"
                )
            ],
            swiftSettings: [
              // Enable better optimizations when building in Release configuration. Despite the use of
              // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
              // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
              .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(
            name: "CMapleStory"
        ),
        .testTarget(
            name: "MapleStoryTests",
            dependencies: ["MapleStory"]
        ),
    ]
)
