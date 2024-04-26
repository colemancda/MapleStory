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
            url: "https://github.com/apple/swift-collections.git",
            from: "1.1.0"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.2.0"
        ),
        .package(
            url: "https://github.com/krzyzanowskim/CryptoSwift.git",
            from: "1.6.0"
        ),
        .package(
            url: "https://github.com/ekscrypto/SwiftEmailValidator.git",
            from: "1.0.4"
        )
    ],
    targets: [
        .target(
            name: "MapleStory",
            dependencies: [
                "CMapleStory",
                "CryptoSwift",
                "Socket",
                "SwiftEmailValidator",
                .product(
                    name: "Collections",
                    package: "swift-collections"
                ),
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
        .executableTarget(
            name: "MapleStoryServer62",
            dependencies: [
                "MapleStory62",
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
                .product(
                    name: "MongoDBModel",
                    package: "CoreModel-MongoDB"
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
        .testTarget(
            name: "MapleStory62Tests",
            dependencies: [
                "MapleStory",
                "MapleStory62"
            ]
        ),
    ]
)
