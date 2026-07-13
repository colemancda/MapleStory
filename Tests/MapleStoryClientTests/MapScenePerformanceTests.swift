//
//  MapScenePerformanceTests.swift
//  MapleStoryClientTests
//
//  Measures the per-frame simulation cost (physics, mob AI, damage numbers)
//  without any GL work: textures only build on first render, which these
//  tests never trigger. Each `measure` block runs 10 simulated seconds at
//  60 Hz (600 ticks), so a reported time of e.g. 0.010s means the whole
//  simulation costs ~16µs per frame - far below the 16.6ms frame budget.
//

import XCTest
@testable import MapleStoryFile
@testable import MapleStoryClient

final class MapScenePerformanceTests: XCTestCase {

    private let ticks = 600           // 10 simulated seconds
    private let dt = 1.0 / 60.0       // at 60 Hz

    /// A map shaped like a real hunting ground: many short chained footholds.
    private func makeMap(footholdCount: Int) -> WzLoadedMap {
        var footholds: [WzFoothold] = []
        footholds.reserveCapacity(footholdCount)
        let segmentWidth = 60
        for index in 0 ..< footholdCount {
            let x1 = -3000 + index * segmentWidth
            // Gentle height variation so the ground solver does real work.
            let y1 = 100 + (index % 5) * 8
            let y2 = 100 + ((index + 1) % 5) * 8
            footholds.append(WzFoothold(
                id: index + 1, layer: index % 8,
                x1: x1, y1: y1,
                x2: x1 + segmentWidth, y2: y2,
                previousID: index, nextID: index + 2
            ))
        }
        return WzLoadedMap(id: 1, backgrounds: [], foregrounds: [], tiles: [], objects: [],
                           left: -3000, top: -1000, right: 3000, bottom: 1000,
                           spawnX: 0, spawnY: 100, footholds: footholds, life: [],
                           portals: [], ladders: [], bgm: nil)
    }

    private func makeMobs(count: Int, map: WzLoadedMap) -> [MapScene.MobEntity] {
        (0 ..< count).map { index in
            let x = Float(-2500 + index * 40)
            return MapScene.MobEntity(
                x: x, y: 100,
                facingRight: index % 2 == 0, walking: true,
                decisionTimer: Double(index % 7) * 0.5 + 0.5,
                speed: 100,
                minX: x - 150, maxX: x + 150,
                layer: index % 8,
                name: "Mob \(index)",
                stand: nil, move: nil, hit: nil, die: nil,
                hp: 15, maxHP: 15
            )
        }
    }

    private func makeCharacter() -> WzLoadedCharacter {
        let empty = WzCharacterAnimation(frames: [])
        return WzLoadedCharacter(stand: empty, walk: empty, jump: empty,
                                 ladder: empty, rope: empty, attack: empty, prone: empty)
    }

    /// Full simulation at hunting-ground scale: 300 footholds, 100 patrolling
    /// mobs, plus the player walking (physics + ground solving every tick).
    func testFullSimulationPerformance() {
        let map = makeMap(footholdCount: 300)
        let scene = MapScene(map: map, character: makeCharacter(), playerStart: (0, 100))
        scene.mobs = makeMobs(count: 100, map: map)
        scene.debugHeldKeys = [.right]
        // Warm up: settle physics before measuring.
        for _ in 0 ..< 10 { scene.update(deltaTime: dt) }

        measure {
            for _ in 0 ..< ticks { scene.update(deltaTime: dt) }
        }
        XCTAssertEqual(scene.mobs.count, 100, "no mob should die without combat")
    }

    /// Mob AI alone: each patrolling mob solves the ground under its next
    /// step every tick, which scans the foothold list - the simulation's
    /// main O(mobs x footholds) cost.
    func testMobPatrolPerformance() {
        let map = makeMap(footholdCount: 300)
        let scene = MapScene(map: map, playerStart: (0, 100))
        scene.mobs = makeMobs(count: 100, map: map)

        measure {
            for _ in 0 ..< ticks { scene.update(deltaTime: dt) }
        }
    }

    /// Player physics alone on a large map (walking, gravity, landing).
    func testPlayerPhysicsPerformance() {
        let map = makeMap(footholdCount: 300)
        let scene = MapScene(map: map, character: makeCharacter(), playerStart: (0, 100))
        scene.debugHeldKeys = [.right]
        for _ in 0 ..< 10 { scene.update(deltaTime: dt) }

        measure {
            for _ in 0 ..< ticks { scene.update(deltaTime: dt) }
        }
    }

    /// Damage numbers under heavy combat: a burst of 50 numbers spawned every
    /// simulated second, aging and expiring throughout.
    func testDamageNumberChurnPerformance() {
        let map = makeMap(footholdCount: 50)
        let scene = MapScene(map: map, character: makeCharacter(), playerStart: (0, 100))

        measure {
            for tick in 0 ..< ticks {
                if tick % 60 == 0 {
                    for burst in 0 ..< 50 {
                        scene.spawnDamageNumber(burst, x: Float(burst) * 10, y: 0)
                    }
                }
                scene.update(deltaTime: dt)
            }
        }
    }

    /// The foothold ground solver itself, isolated: the query every mob (and
    /// the player) issues once per tick.
    func testGroundLookupPerformance() {
        let map = makeMap(footholdCount: 300)

        measure {
            var found = 0
            for i in 0 ..< 60_000 {
                let x = Float(-2900 + (i % 5800))
                if map.ground(atX: x, below: 0, tolerance: 300) != nil { found += 1 }
            }
            XCTAssertGreaterThan(found, 0)
        }
    }
}
