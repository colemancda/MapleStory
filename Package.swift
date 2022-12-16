// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "MapleStory",
    products: [
        .library(
            name: "MapleStory",
            targets: ["MapleStory"]),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "MapleStory",
            dependencies: ["CMapleStory"]
        ),
        .target(
            name: "CMapleStory",
            dependencies: []
        ),
        .testTarget(
            name: "MapleStoryTests",
            dependencies: ["MapleStory"]
        ),
    ]
)
