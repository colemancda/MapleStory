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

    @Option(name: .long, help: "Path to Character.wz. If provided, spawns a walking player (arrow keys move; camera follows; up enters portals).")
    var characterWz: String?

    @Option(name: .long, help: "Path to Npc.wz. If provided, renders the map's NPCs.")
    var npcWz: String?

    @Option(name: .long, help: "Path to Mob.wz. If provided, renders the map's mob spawns.")
    var mobWz: String?

    @Option(name: .long, help: "Path to String.wz. If provided, shows NPC/mob name tags.")
    var stringWz: String?

    @Option(name: .long, help: "Map ID to render.")
    var id: Int = 100000000

    @Option(name: .long, help: "WZ region: gms, ems, or bms.")
    var region: String = "gms"

    @Option(name: .long, help: "Capture a screenshot to this PNG path and exit.")
    var screenshot: String?

    @Flag(name: .long, help: "Overlay foothold (ground/wall) geometry for debugging.")
    var showFootholds = false

    @Option(name: .long, help: "Player start X (defaults to the map's spawn portal).")
    var startX: Int?

    @Option(name: .long, help: "Player start Y (defaults to the map's spawn portal).")
    var startY: Int?

    @Option(name: .long, help: "Frames to render before capturing the screenshot.")
    var captureFrames: Int = 30

    func run() throws {
        let version: WzMapleVersion
        switch region.lowercased() {
        case "ems": version = .ems
        case "bms": version = .bms
        default: version = .gms
        }

        print("Loading \(wz) ...")
        let mapArchive = try WzArchive(data: try Data(contentsOf: URL(fileURLWithPath: wz)), mapleVersion: version)
        print("Parsed WZ (version \(mapArchive.version))")

        var character: WzLoadedCharacter?
        if let characterWz {
            print("Loading \(characterWz) ...")
            let characterArchive = try WzArchive(data: try Data(contentsOf: URL(fileURLWithPath: characterWz)), mapleVersion: version)
            character = try WzCharacterLoader(archive: characterArchive).load()
        }
        var npcLoader: WzLifeSpriteLoader?
        if let npcWz {
            print("Loading \(npcWz) ...")
            npcLoader = WzLifeSpriteLoader(archive: try WzArchive(data: try Data(contentsOf: URL(fileURLWithPath: npcWz)), mapleVersion: version))
        }
        var mobLoader: WzLifeSpriteLoader?
        if let mobWz {
            print("Loading \(mobWz) ...")
            mobLoader = WzLifeSpriteLoader(archive: try WzArchive(data: try Data(contentsOf: URL(fileURLWithPath: mobWz)), mapleVersion: version))
        }
        var stringLoader: WzStringLoader?
        if let stringWz {
            print("Loading \(stringWz) ...")
            stringLoader = WzStringLoader(archive: try WzArchive(data: try Data(contentsOf: URL(fileURLWithPath: stringWz)), mapleVersion: version))
        }

        let game = try Game(title: "MapleStory", width: 1024, height: 768)
        let environment = MapEnvironment(
            mapLoader: WzMapLoader(archive: mapArchive),
            character: character,
            npcLoader: npcLoader,
            mobLoader: mobLoader,
            stringLoader: stringLoader,
            showFootholds: showFootholds,
            game: game
        )

        var playerStart: (x: Int, y: Int)?
        if let startX, let startY { playerStart = (startX, startY) }
        let scene = try environment.makeScene(mapID: id, playerStart: playerStart)
        game.setScene(scene)
        if let screenshot {
            game.capturePath = screenshot
            // Default gives physics (falling to ground) time to settle first.
            game.captureAfterFrames = captureFrames
        }
        try game.run()
        if let screenshot {
            print("Saved screenshot to \(screenshot)")
        }
    }
}

/// Keeps the WZ archives/loaders alive across map transitions and builds a
/// scene per map, wiring portal entry to load the target map.
final class MapEnvironment {

    private let mapLoader: WzMapLoader
    private let character: WzLoadedCharacter?
    private let npcLoader: WzLifeSpriteLoader?
    private let mobLoader: WzLifeSpriteLoader?
    private let stringLoader: WzStringLoader?
    private let showFootholds: Bool
    private weak var game: Game?
    private lazy var portalFrames: [WzSpriteFrame] = (try? mapLoader.loadPortalAnimation()) ?? []

    init(
        mapLoader: WzMapLoader,
        character: WzLoadedCharacter?,
        npcLoader: WzLifeSpriteLoader?,
        mobLoader: WzLifeSpriteLoader?,
        stringLoader: WzStringLoader?,
        showFootholds: Bool,
        game: Game
    ) {
        self.mapLoader = mapLoader
        self.character = character
        self.npcLoader = npcLoader
        self.mobLoader = mobLoader
        self.stringLoader = stringLoader
        self.showFootholds = showFootholds
        self.game = game
    }

    func makeScene(mapID: Int, spawnPortal: String? = nil, playerStart: (x: Int, y: Int)? = nil) throws -> MapScene {
        let map = try mapLoader.load(mapID: mapID)
        print("Map \(mapID): \(map.backgrounds.count) backgrounds, \(map.tiles.count) tiles, \(map.objects.count) objects, \(map.portals.count) portals")

        var lifeSprites: [(life: WzMapLife, frames: [WzSpriteFrame], name: String?)] = []
        appendLife(type: "n", loader: npcLoader, map: map, into: &lifeSprites)
        appendLife(type: "m", loader: mobLoader, map: map, into: &lifeSprites)

        // Spawn at the named arrival portal when transitioning.
        var start = playerStart
        if start == nil, let spawnPortal,
           let arrival = map.portals.first(where: { $0.name == spawnPortal }) {
            start = (arrival.x, arrival.y)
        }

        let scene = MapScene(map: map, character: character, lifeSprites: lifeSprites,
                             portalFrames: portalFrames, playerStart: start)
        scene.showFootholds = showFootholds
        scene.onEnterPortal = { [weak self] portal in
            self?.transition(through: portal)
        }
        return scene
    }

    private func transition(through portal: WzMapPortal) {
        print("Entering portal \(portal.name) -> map \(portal.targetMap) (\(portal.targetName))")
        do {
            let scene = try makeScene(mapID: portal.targetMap, spawnPortal: portal.targetName)
            game?.setScene(scene)
        } catch {
            print("Failed to load map \(portal.targetMap): \(error)")
        }
    }

    private func appendLife(
        type: String,
        loader: WzLifeSpriteLoader?,
        map: WzLoadedMap,
        into lifeSprites: inout [(life: WzMapLife, frames: [WzSpriteFrame], name: String?)]
    ) {
        guard let loader else { return }
        var frameCache: [Int: [WzSpriteFrame]] = [:]
        var count = 0
        for life in map.life where life.type == type && life.hidden == false {
            let frames: [WzSpriteFrame]
            if let cached = frameCache[life.id] {
                frames = cached
            } else {
                frames = (try? loader.loadStandFrames(id: life.id)) ?? []
                frameCache[life.id] = frames
            }
            if frames.isEmpty == false {
                let name = type == "n" ? stringLoader?.npcName(id: life.id) : stringLoader?.mobName(id: life.id)
                lifeSprites.append((life, frames, name))
                count += 1
            }
        }
        let total = map.life.filter { $0.type == type }.count
        if total > 0 {
            print("\(type == "n" ? "NPCs" : "Mobs") loaded: \(count) of \(total)")
        }
    }
}
