//
//  MapSceneTests.swift
//  MapleStoryClientTests
//
//  GL-free MapScene behavior: input handling and portal entry (textures are
//  only created on first render, which these tests never trigger).
//

import XCTest
@testable import MapleStoryFile
@testable import MapleStoryClient

final class MapSceneTests: XCTestCase {

    private func makeMap(portals: [WzMapPortal]) -> WzLoadedMap {
        let ground = WzFoothold(id: 1, layer: 0, x1: -500, y1: 100, x2: 500, y2: 100, previousID: 0, nextID: 0)
        return WzLoadedMap(id: 1, backgrounds: [], foregrounds: [], tiles: [], objects: [],
                           left: -500, top: -500, right: 500, bottom: 500,
                           spawnX: 0, spawnY: 100, footholds: [ground], life: [],
                           portals: portals, ladders: [], bgm: nil)
    }

    func testUpArrowEntersOverlappingPortal() {
        let portal = WzMapPortal(name: "east00", type: 2, x: 10, y: 100,
                                 targetMap: 100010000, targetName: "west00")
        let scene = MapScene(map: makeMap(portals: [portal]), playerStart: (0, 100))

        var entered: WzMapPortal?
        scene.onEnterPortal = { entered = $0 }
        scene.handle(.control(.up))

        XCTAssertEqual(entered?.targetMap, 100010000)
        XCTAssertEqual(entered?.targetName, "west00")
    }

    func testLadderClimbing() {
        let ground = WzFoothold(id: 1, layer: 0, x1: -500, y1: 150, x2: 500, y2: 150, previousID: 0, nextID: 0)
        let upper = WzFoothold(id: 2, layer: 0, x1: -500, y1: 50, x2: 500, y2: 50, previousID: 0, nextID: 0)
        let ladder = WzMapLadder(x: 10, y1: 50, y2: 150, isLadder: true, usableFromTop: true, layer: 0)
        let map = WzLoadedMap(id: 1, backgrounds: [], foregrounds: [], tiles: [], objects: [],
                              left: -500, top: -500, right: 500, bottom: 500,
                              spawnX: 10, spawnY: 150, footholds: [ground, upper], life: [],
                              portals: [], ladders: [ladder], bgm: nil)
        let empty = WzCharacterAnimation(frames: [])
        let character = WzLoadedCharacter(stand: empty, walk: empty, jump: empty, ladder: empty, rope: empty, attack: empty, prone: empty)
        let scene = MapScene(map: map, character: character, playerStart: (10, 150))

        // Settle on the ground, then grab the ladder.
        scene.update(deltaTime: 0.016)
        XCTAssertFalse(scene.isPlayerClimbing)
        scene.handle(.control(.up))
        XCTAssertTrue(scene.isPlayerClimbing)

        // Climbing up moves the player without gravity.
        scene.updateInput(held: [.up])
        scene.update(deltaTime: 0.5)
        XCTAssertTrue(scene.isPlayerClimbing)
        XCTAssertLessThan(scene.playerPosition.y, 150)

        // Reaching the top detaches and lands on the upper platform.
        for _ in 0 ..< 20 { scene.update(deltaTime: 0.1) }
        XCTAssertFalse(scene.isPlayerClimbing)
        scene.updateInput(held: [])
        for _ in 0 ..< 10 { scene.update(deltaTime: 0.05) }
        XCTAssertEqual(scene.playerPosition.y, 50, accuracy: 1)
    }

    func testMobRespawnsAtSpawnPointAfterDelay() {
        let scene = MapScene(map: makeMap(portals: []), playerStart: (0, 100))
        scene.mobRespawnDelay = 5
        // Speed 0 so the respawned mob stays at its spawn point for the assert.
        var mob = MapScene.MobEntity(
            x: 250, y: 100, decisionTimer: 1, speed: 0,
            minX: -400, maxX: 400, layer: 0, name: "Test",
            stand: nil, move: nil, hit: nil, die: nil,
            hp: 0, maxHP: 10, spawnX: 100, spawnY: 100
        )
        mob.state = .dying
        mob.stateTimer = 0.1
        scene.mobs = [mob]

        // deltaTime is clamped to 0.05s per tick, so advance in steps.
        func advance(seconds: Double) {
            for _ in 0 ..< Int(seconds / 0.05) { scene.update(deltaTime: 0.05) }
        }

        // Death animation finishes -> dead, waiting to respawn.
        advance(seconds: 0.2)
        XCTAssertEqual(scene.mobs[0].state, .dead)
        XCTAssertFalse(scene.mobs[0].isAlive)

        // Not yet: still dead mid-delay.
        advance(seconds: 3)
        XCTAssertEqual(scene.mobs[0].state, .dead)

        // Delay elapses -> alive again at its spawn point with full HP.
        advance(seconds: 3)
        XCTAssertEqual(scene.mobs[0].state, .patrol)
        XCTAssertEqual(scene.mobs[0].hp, 10)
        XCTAssertEqual(scene.mobs[0].x, 100)
        XCTAssertEqual(scene.mobs[0].y, 100)
    }

    func testUpArrowIgnoresDistantAndSpawnPortals() {
        let distant = WzMapPortal(name: "far", type: 2, x: 400, y: 100,
                                  targetMap: 100010000, targetName: "west00")
        let spawn = WzMapPortal(name: "sp", type: 0, x: 0, y: 100,
                                targetMap: 999_999_999, targetName: "")
        let scene = MapScene(map: makeMap(portals: [distant, spawn]), playerStart: (0, 100))

        var entered: WzMapPortal?
        scene.onEnterPortal = { entered = $0 }
        scene.handle(.control(.up))

        XCTAssertNil(entered)
    }
}
