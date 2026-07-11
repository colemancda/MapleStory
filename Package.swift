// swift-tools-version: 6.0
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
            name: "MapleStoryServer",
            targets: ["MapleStoryServer"]
        ),
        .library(
            name: "MapleStory28",
            targets: ["MapleStory28"]
        ),
        .library(
            name: "MapleStory40",
            targets: ["MapleStory40"]
        ),
        .library(
            name: "MapleStory62",
            targets: ["MapleStory62"]
        ),
        .library(
            name: "MapleStory83",
            targets: ["MapleStory83"]
        ),
        .library(
            name: "MapleStoryClient",
            targets: ["MapleStoryClient"]
        ),
        .executable(
            name: "MapleStoryClient83",
            targets: ["MapleStoryClient83"]
        ),
        .executable(
            name: "MapleStoryServer28",
            targets: ["MapleStoryServer28"]
        ),
        .executable(
            name: "MapleStoryServer62",
            targets: ["MapleStoryServer62"]
        ),
        .executable(
            name: "MapleStoryServer83",
            targets: ["MapleStoryServer83"]
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
            url: "https://github.com/apple/swift-binary-parsing.git",
            .upToNextMinor(from: "0.0.2")
        ),
        .package(
            url: "https://github.com/PureSwift/SDL",
            branch: "master"
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
            url: "https://github.com/tmthecoder/Argon2Swift.git",
            branch: "main"
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
                    name: "Collections",
                    package: "swift-collections"
                ),
                .product(
                    name: "CoreModel",
                    package: "CoreModel"
                ),
                .product(
                    name: "BinaryParsing",
                    package: "swift-binary-parsing"
                )
            ]
        ),
        .target(
            name: "MapleStoryServer",
            dependencies: [
                "MapleStory",
                .product(
                    name: "Argon2Swift",
                    package: "Argon2Swift"
                ),
                .product(
                    name: "CoreModel",
                    package: "CoreModel"
                )
            ]
        ),
        .target(
            name: "MapleStoryClient",
            dependencies: [
                "MapleStory",
                .product(
                    name: "SDL3Swift",
                    package: "SDL"
                )
            ]
        ),
        .executableTarget(
            name: "MapleStoryClient83",
            dependencies: [
                "MapleStoryClient",
                "MapleStory83",
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
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
            name: "MapleStoryServer28",
            dependencies: [
                "MapleStory28",
                "MapleStoryServer",
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
        .executableTarget(
            name: "MapleStoryServer62",
            dependencies: [
                "MapleStory62",
                "MapleStoryServer",
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
        .executableTarget(
            name: "MapleStoryServer83",
            dependencies: [
                "MapleStory83",
                "MapleStoryServer",
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
            dependencies: [
                "MapleStory",
                "MapleStoryServer"
            ],
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "MapleStory28Tests",
            dependencies: [
                "MapleStory",
                "MapleStory28"
            ]
        ),
        .testTarget(
            name: "MapleStory62Tests",
            dependencies: [
                "MapleStory",
                "MapleStory62"
            ]
        ),
        .testTarget(
            name: "MapleStory83Tests",
            dependencies: [
                "MapleStory",
                "MapleStory83"
            ]
        ),
        .testTarget(
            name: "MapleStoryClientTests",
            dependencies: [
                "MapleStory",
                "MapleStory83",
                "MapleStoryClient"
            ]
        ),
    ]
)
