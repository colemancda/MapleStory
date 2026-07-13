//
//  LoginCommand.swift
//  MapleStoryClient83
//

import Foundation
import ArgumentParser
import MapleStory
import MapleStoryClient
import MapleStoryFile

struct LoginCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "login",
        abstract: "Connect to a login server and show the login screen."
    )

    @Option(name: .shortAndLong, help: "Login server host to connect to.")
    var host: String = "127.0.0.1"

    @Option(name: .shortAndLong, help: "Login server port.")
    var port: UInt16 = 8484

    @Flag(name: .shortAndLong, help: "Log network traffic to stdout.")
    var verbose = false

    @Option(name: .long, help: "Capture a screenshot to this PNG path and exit.")
    var screenshot: String?

    @Option(name: .long, help: "Frames to render before capturing the screenshot.")
    var captureFrames: Int = 10

    @Option(name: .long, help: "Directory containing the game's .wz files. Enables the original login screen (UI.wz + Map.wz) and real map rendering after login.")
    var wz: String?

    @Option(name: .long, help: "WZ region: GMS, EMS or BMS.")
    var region: String = "GMS"

    @Option(name: .long, help: "Debug: skip the server and enter this map id directly, exercising the same hand-off as a real SetField warp.")
    var simulateField: Int?

    @Option(name: .long, help: "Debug: start on a phase (world/char) with sample data, without a server.")
    var phase: String?

    func run() throws {
        guard let destination = MapleStoryAddress(address: host, port: port) else {
            throw ValidationError("Invalid server address \(host):\(port)")
        }
        let configuration = ClientConfiguration(destination: destination)
        let game = try Game(title: "MapleStory v83", width: 1024, height: 768)
        let audioPlayer = AudioPlayer()
        let assets = wz.map { WzAssets(directory: $0, region: region) }
        let environment = try assets.flatMap { try makeMapEnvironment(assets: $0, game: game, audioPlayer: audioPlayer) }
        let scene = LoginScene(configuration: configuration, verbose: verbose)
        scene.assets = try assets.flatMap { try makeLoginAssets(assets: $0, audioPlayer: audioPlayer) }
        if let environment {
            let enterField: @Sendable (Int, Int) -> Void = { [weak game] mapID, _ in
                do {
                    let mapScene = try environment.makeScene(mapID: mapID)
                    game?.enqueueScene(mapScene)
                } catch {
                    print("Failed to load map \(mapID): \(error)")
                }
            }
            scene.onEnterField = enterField
            if let simulateField {
                // Fire the warp from a background task exactly like a network
                // handler would.
                Task.detached {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    enterField(simulateField, 0)
                }
            }
        }
        switch phase?.lowercased() {
        case "world":
            for world in ["Scania", "Bera", "Broa", "Windia"] { scene.model.addWorld(world) }
            scene.model.setPhase(.worldSelect)
        case "char":
            scene.model.setCharacters([(1, "Coleman"), (2, "MapleFan"), (3, "Slime")])
            scene.model.setPhase(.characterSelect)
        default:
            break
        }
        game.setScene(scene)
        scene.start()
        if let screenshot {
            game.capturePath = screenshot
            game.captureAfterFrames = captureFrames
        }
        try game.run()
        if let screenshot {
            print("Saved screenshot to \(screenshot)")
        }
    }

    /// Load the original login-screen art from UI.wz (+ Map.wz for the backdrop,
    /// Sound.wz for the title BGM).
    private func makeLoginAssets(assets: WzAssets, audioPlayer: AudioPlayer) throws -> LoginAssets? {
        guard let uiArchive = try assets.archive("UI") else { return nil }
        let uiLoader = WzUILoader(archive: uiArchive)

        // The login backdrop is a real map (UI.wz/MapLogin.img) whose sprites
        // live in Map.wz/Back/login.img.
        var background: MapScene?
        if let mapArchive = try assets.archive("Map"),
           let loginProps = try uiLoader.properties(image: "MapLogin.img") {
            let mapLoader = WzMapLoader(archive: mapArchive)
            let (backgrounds, foregrounds) = try mapLoader.loadBackgrounds(from: loginProps)
            let loginMap = WzLoadedMap(
                id: 0, backgrounds: backgrounds, foregrounds: foregrounds,
                tiles: [], objects: [],
                left: -512, top: -1500, right: 512, bottom: 1500,
                spawnX: 0, spawnY: 0, footholds: [], life: [],
                portals: [], ladders: [], bgm: loginProps.string("info/bgm")
            )
            // The scene camera is driven by LoginScene, which scrolls between
            // the login band (world y -600...0) and the world-select band
            // (y 0...600) like the original client.
            background = MapScene(map: loginMap)

            // Title BGM (info/bgm = "BgmUI/Title" -> Sound.wz/BgmUI.img/Title).
            if let soundArchive = try assets.archive("Sound"), let bgm = loginMap.bgm {
                let parts = bgm.split(separator: "/").map(String.init)
                if parts.count == 2,
                   let image = soundArchive.root["\(parts[0]).img"],
                   let props = try? soundArchive.properties(of: image),
                   let sound = props[parts[1]]?.soundValue,
                   let data = soundArchive.soundData(sound) {
                    audioPlayer.playMusic(data, track: bgm)
                }
            }
        }

        // World tower buttons + logos: numbered entries until one is missing.
        var worldButtonNormal: [WzSpriteFrame] = []
        var worldButtonPressed: [WzSpriteFrame] = []
        var worldLogos: [WzSpriteFrame] = []
        var worldIndex = 0
        while let normal = try uiLoader.sprite(image: "Login.img", path: "WorldSelect/BtWorld/\(worldIndex)/normal") {
            worldButtonNormal.append(normal)
            if let pressed = try uiLoader.sprite(image: "Login.img", path: "WorldSelect/BtWorld/\(worldIndex)/pressed") {
                worldButtonPressed.append(pressed)
            }
            if let logo = try uiLoader.sprite(image: "Login.img", path: "WorldSelect/world/\(worldIndex)") {
                worldLogos.append(logo)
            }
            worldIndex += 1
        }

        return LoginAssets(
            background: background,
            frame: try uiLoader.sprite(image: "Login.img", path: "Common/frame"),
            logo: try uiLoader.sprite(image: "Login.img", path: "Title/MSTitle"),
            buttonNormal: try uiLoader.sprite(image: "Login.img", path: "Title/BtLogin/normal"),
            buttonPressed: try uiLoader.sprite(image: "Login.img", path: "Title/BtLogin/pressed"),
            worldScroll: try uiLoader.frames(image: "Login.img", path: "WorldSelect/scroll/0").last,
            worldButtonNormal: worldButtonNormal,
            worldButtonPressed: worldButtonPressed,
            worldLogos: worldLogos,
            channelBoard: try uiLoader.sprite(image: "Login.img", path: "WorldSelect/chBackgrn"),
            channelButtons: try (0 ..< 20).compactMap { try uiLoader.sprite(image: "Login.img", path: "WorldSelect/channel/\($0)/normal") },
            goWorldButton: try uiLoader.sprite(image: "Login.img", path: "WorldSelect/BtGoworld/normal"),
            charInfoCard: try uiLoader.sprite(image: "Login.img", path: "CharSelect/charInfo"),
            selectButton: try uiLoader.sprite(image: "Login.img", path: "CharSelect/BtSelect/normal"),
            newCharButton: try uiLoader.sprite(image: "Login.img", path: "CharSelect/BtNew/normal"),
            deleteCharButton: try uiLoader.sprite(image: "Login.img", path: "CharSelect/BtDelete/normal")
        )
    }

    /// Build the WZ-backed map environment for the post-login hand-off.
    private func makeMapEnvironment(assets: WzAssets, game: Game, audioPlayer: AudioPlayer) throws -> MapEnvironment? {
        guard let mapArchive = try assets.archive("Map") else { return nil }

        var character: WzLoadedCharacter?
        if let characterArchive = try assets.archive("Character") {
            var zmap = WzZmap(order: [:])
            if let baseArchive = try assets.archive("Base") {
                zmap = try WzZmap.load(from: baseArchive)
            }
            // Default starter look; server-driven appearance comes later.
            let equipment = [
                WzEquipItem(category: "Hair", id: 30030),
                WzEquipItem(category: "Coat", id: 1040002),
                WzEquipItem(category: "Pants", id: 1060002),
                WzEquipItem(category: "Shoes", id: 1072001),
            ]
            character = try WzCharacterLoader(archive: characterArchive, zmap: zmap).load(equipment: equipment)
        }
        return MapEnvironment(
            mapLoader: WzMapLoader(archive: mapArchive),
            character: character,
            npcLoader: try assets.archive("Npc").map { WzLifeSpriteLoader(archive: $0) },
            mobLoader: try assets.archive("Mob").map { WzLifeSpriteLoader(archive: $0) },
            stringLoader: try assets.archive("String").map { WzStringLoader(archive: $0) },
            soundArchive: try assets.archive("Sound"),
            showFootholds: false,
            game: game,
            audioPlayer: audioPlayer
        )
    }
}
