//
//  MapCommand.swift
//  MapleStoryClient83
//

import Foundation
import ArgumentParser
import MapleStoryClient
import MapleStoryFile

struct MapCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "map",
        abstract: "Load and render a map from a WZ file."
    )

    @Option(name: .long, help: "Path to Map.wz.")
    var wz: String

    @Option(name: .long, help: "Path to Character.wz. If provided, spawns a walking player (arrow keys move; camera follows).")
    var characterWz: String?

    @Option(name: .long, help: "Map ID to render.")
    var id: Int = 100000000

    @Option(name: .long, help: "WZ region: gms, ems, or bms.")
    var region: String = "gms"

    @Option(name: .long, help: "Capture a screenshot to this PNG path and exit.")
    var screenshot: String?

    @Flag(name: .long, help: "Overlay foothold (ground/wall) geometry for debugging.")
    var showFootholds = false

    func run() throws {
        let version: WzMapleVersion
        switch region.lowercased() {
        case "ems": version = .ems
        case "bms": version = .bms
        default: version = .gms
        }

        print("Loading \(wz) ...")
        let data = try Data(contentsOf: URL(fileURLWithPath: wz))
        let archive = try WzArchive(data: data, mapleVersion: version)
        print("Parsed WZ (version \(archive.version)); loading map \(id) ...")
        let loader = WzMapLoader(archive: archive)
        let map = try loader.load(mapID: id)
        print("Map \(id): \(map.backgrounds.count) backgrounds, \(map.tiles.count) tiles, \(map.objects.count) objects")

        var character: WzLoadedCharacter?
        if let characterWz {
            print("Loading \(characterWz) ...")
            let characterData = try Data(contentsOf: URL(fileURLWithPath: characterWz))
            let characterArchive = try WzArchive(data: characterData, mapleVersion: version)
            character = try WzCharacterLoader(archive: characterArchive).load()
            print("Character loaded: \(character?.stand.frames.count ?? 0) stand frames, \(character?.walk.frames.count ?? 0) walk frames")
        }

        let game = try Game(title: "MapleStory Map \(id)", width: 1024, height: 768)
        let scene = MapScene(map: map, character: character)
        scene.showFootholds = showFootholds
        game.setScene(scene)
        if let screenshot {
            game.capturePath = screenshot
            // Enough frames for physics (falling to ground) to settle first.
            game.captureAfterFrames = 30
        }
        try game.run()
        if let screenshot {
            print("Saved screenshot to \(screenshot)")
        }
    }
}
