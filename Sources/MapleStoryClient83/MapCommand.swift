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

    @Option(name: .long, help: "Path to Base.wz (for the character layer z-order). Recommended with --character-wz.")
    var baseWz: String?

    @Option(name: .long, help: "Hair item id (0 = none).")
    var hair: Int = 30030
    @Option(name: .long, help: "Coat item id (0 = none).")
    var coat: Int = 1040002
    @Option(name: .long, help: "Pants item id (0 = none).")
    var pants: Int = 1060002
    @Option(name: .long, help: "Shoes item id (0 = none).")
    var shoes: Int = 1072001
    @Option(name: .long, help: "Cap item id (0 = none).")
    var cap: Int = 0
    @Option(name: .long, help: "Weapon item id (0 = none).")
    var weapon: Int = 0

    @Option(name: .long, help: "Path to Npc.wz. If provided, renders the map's NPCs.")
    var npcWz: String?

    @Option(name: .long, help: "Path to Mob.wz. If provided, renders the map's mob spawns.")
    var mobWz: String?

    @Option(name: .long, help: "Path to String.wz. If provided, shows NPC/mob name tags.")
    var stringWz: String?

    @Option(name: .long, help: "Path to Sound.wz. If provided, plays each map's background music.")
    var soundWz: String?

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

    @Option(name: .long, help: "Debug: continuously hold a direction (left/right/up/down).")
    var walk: String?

    @Flag(name: .long, help: "Debug: continuously attack (for capturing combat).")
    var attack: Bool = false

    @Flag(name: .long, help: "Show a frames-per-second counter in the corner.")
    var showFps: Bool = false

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
            var zmap = WzZmap(order: [:])
            if let baseWz {
                let baseArchive = try WzArchive(data: try Data(contentsOf: URL(fileURLWithPath: baseWz)), mapleVersion: version)
                zmap = try WzZmap.load(from: baseArchive)
            }
            var equipment: [WzEquipItem] = []
            if hair != 0 { equipment.append(WzEquipItem(category: "Hair", id: hair)) }
            if coat != 0 { equipment.append(WzEquipItem(category: "Coat", id: coat)) }
            if pants != 0 { equipment.append(WzEquipItem(category: "Pants", id: pants)) }
            if shoes != 0 { equipment.append(WzEquipItem(category: "Shoes", id: shoes)) }
            if cap != 0 { equipment.append(WzEquipItem(category: "Cap", id: cap)) }
            if weapon != 0 { equipment.append(WzEquipItem(category: "Weapon", id: weapon)) }
            character = try WzCharacterLoader(archive: characterArchive, zmap: zmap).load(equipment: equipment)
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
        var soundArchive: WzArchive?
        if let soundWz {
            print("Loading \(soundWz) ...")
            soundArchive = try WzArchive(data: try Data(contentsOf: URL(fileURLWithPath: soundWz)), mapleVersion: version)
        }

        let game = try Game(title: "MapleStory", width: 1024, height: 768)
        game.showFPS = showFps
        let environment = MapEnvironment(
            mapLoader: WzMapLoader(archive: mapArchive),
            character: character,
            npcLoader: npcLoader,
            mobLoader: mobLoader,
            stringLoader: stringLoader,
            soundArchive: soundArchive,
            showFootholds: showFootholds,
            game: game
        )

        var playerStart: (x: Int, y: Int)?
        if let startX, let startY { playerStart = (startX, startY) }
        let scene = try environment.makeScene(mapID: id, playerStart: playerStart)
        switch walk?.lowercased() {
        case "left": scene.debugHeldKeys = [.left]
        case "right": scene.debugHeldKeys = [.right]
        case "up": scene.debugHeldKeys = [.up]
        case "down": scene.debugHeldKeys = [.down]
        default: break
        }
        scene.debugAttack = attack
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
    private let soundArchive: WzArchive?
    private let audioPlayer = AudioPlayer()
    private let showFootholds: Bool
    private weak var game: Game?
    private lazy var portalFrames: [WzSpriteFrame] = (try? mapLoader.loadPortalAnimation()) ?? []

    init(
        mapLoader: WzMapLoader,
        character: WzLoadedCharacter?,
        npcLoader: WzLifeSpriteLoader?,
        mobLoader: WzLifeSpriteLoader?,
        stringLoader: WzStringLoader?,
        soundArchive: WzArchive?,
        showFootholds: Bool,
        game: Game
    ) {
        self.mapLoader = mapLoader
        self.character = character
        self.npcLoader = npcLoader
        self.mobLoader = mobLoader
        self.stringLoader = stringLoader
        self.soundArchive = soundArchive
        self.showFootholds = showFootholds
        self.game = game
    }

    func makeScene(mapID: Int, spawnPortal: String? = nil, playerStart: (x: Int, y: Int)? = nil) throws -> MapScene {
        let map = try mapLoader.load(mapID: mapID)
        print("Map \(mapID): \(map.backgrounds.count) backgrounds, \(map.tiles.count) tiles, \(map.objects.count) objects, \(map.portals.count) portals")

        var lifeSprites: [WzLifeSprite] = []
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
        playBackgroundMusic(for: map)
        return scene
    }

    /// Play the map's BGM (info/bgm = "{image}/{track}" in Sound.wz).
    private func playBackgroundMusic(for map: WzLoadedMap) {
        guard let soundArchive, let bgm = map.bgm else { return }
        let components = bgm.split(separator: "/").map(String.init)
        guard components.count == 2,
              let image = soundArchive.root["\(components[0]).img"],
              let props = try? soundArchive.properties(of: image),
              let sound = props[components[1]]?.soundValue,
              let data = soundArchive.soundData(sound) else {
            print("BGM \(bgm) not found")
            return
        }
        print("Playing BGM \(bgm) (\(sound.durationMilliseconds / 1000)s loop)")
        audioPlayer.playMusic(data, track: bgm)
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
        into lifeSprites: inout [WzLifeSprite]
    ) {
        guard let loader else { return }
        struct Loaded { var stand: [WzSpriteFrame]; var move: [WzSpriteFrame]; var hit: [WzSpriteFrame]; var die: [WzSpriteFrame]; var speed: Int; var maxHP: Int; var touchDamage: Int }
        var cache: [Int: Loaded] = [:]
        var count = 0
        for life in map.life where life.type == type && life.hidden == false {
            let loaded: Loaded
            if let cached = cache[life.id] {
                loaded = cached
            } else {
                let stand = (try? loader.loadStandFrames(id: life.id)) ?? []
                let isMob = type == "m"
                let move = isMob ? ((try? loader.loadFrames(action: "move", id: life.id)) ?? []) : []
                let hit = isMob ? ((try? loader.loadFrames(action: "hit1", id: life.id)) ?? []) : []
                let die = isMob ? ((try? loader.loadFrames(action: "die1", id: life.id)) ?? []) : []
                loaded = Loaded(stand: stand, move: move, hit: hit, die: die,
                                speed: loader.speedPercent(id: life.id),
                                maxHP: isMob ? loader.maxHP(id: life.id) : 1,
                                touchDamage: isMob ? loader.touchDamage(id: life.id) : 0)
                cache[life.id] = loaded
            }
            if loaded.stand.isEmpty == false || loaded.move.isEmpty == false {
                let name = type == "n" ? stringLoader?.npcName(id: life.id) : stringLoader?.mobName(id: life.id)
                lifeSprites.append(WzLifeSprite(life: life, standFrames: loaded.stand,
                                                moveFrames: loaded.move, hitFrames: loaded.hit,
                                                dieFrames: loaded.die, name: name,
                                                speedPercent: loaded.speed, maxHP: loaded.maxHP,
                                                touchDamage: loaded.touchDamage))
                count += 1
            }
        }
        let total = map.life.filter { $0.type == type }.count
        if total > 0 {
            print("\(type == "n" ? "NPCs" : "Mobs") loaded: \(count) of \(total)")
        }
    }
}
