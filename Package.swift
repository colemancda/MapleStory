// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "MapleStory",
    platforms: [
        .macOS("13.0")
    ],
    products: [
        .executable(
            name: "MapleStoryServer",
            targets: ["MapleStoryServer"]
        ),
        .library(
            name: "MapleStory",
            targets: ["MapleStory"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/PureSwift/Socket",
            branch: "main"
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
                "Socket",
                "CryptoSwift",
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                )
            ]
        ),
        .executableTarget(
            name: "MapleStoryServer",
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
        .target(
            name: "CMapleStory"
        ),
        .testTarget(
            name: "MapleStoryTests",
            dependencies: ["MapleStory"]
        ),
    ]
)
