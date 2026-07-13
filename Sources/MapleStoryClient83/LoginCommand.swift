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
            // The login backdrop is a static scene: its layers all use
            // rx/ry -100 and the login band occupies world y -600...0 (the
            // world-select art sits below). Pin the layers to the screen and
            // center the band on the camera origin.
            func pinned(_ layers: [WzMapBackground]) -> [WzMapBackground] {
                layers.map { layer in
                    var pinnedLayer = layer
                    pinnedLayer.rx = 0
                    pinnedLayer.ry = 0
                    pinnedLayer.y += 300
                    return pinnedLayer
                }
            }
            let loginMap = WzLoadedMap(
                id: 0, backgrounds: pinned(backgrounds), foregrounds: pinned(foregrounds),
                tiles: [], objects: [],
                left: -512, top: -1500, right: 512, bottom: 1500,
                spawnX: 0, spawnY: 0, footholds: [], life: [],
                portals: [], ladders: [], bgm: loginProps.string("info/bgm")
            )
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

        return LoginAssets(
            background: background,
            frame: try uiLoader.sprite(image: "Login.img", path: "Common/frame"),
            logo: try uiLoader.sprite(image: "Login.img", path: "Title/MSTitle"),
            buttonNormal: try uiLoader.sprite(image: "Login.img", path: "Title/BtLogin/normal"),
            buttonPressed: try uiLoader.sprite(image: "Login.img", path: "Title/BtLogin/pressed")
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
