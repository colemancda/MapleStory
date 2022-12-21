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
                )
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
