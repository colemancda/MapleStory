//
//  WzMapStructTests.swift
//  MapleStoryFileTests
//
//  The pure value types in WzMapLoader: footholds, ground queries, minimap
//  transform, ladders, portals, and life placements.
//

import XCTest
@testable import MapleStoryFile

final class WzMapStructTests: XCTestCase {

    func testFootholdGroundYAndWall() {
        let flat = WzFoothold(id: 1, layer: 0, x1: 0, y1: 100, x2: 100, y2: 100, previousID: 0, nextID: 0)
        XCTAssertFalse(flat.isWall)
        XCTAssertEqual(flat.groundY(atX: 50), 100)
        XCTAssertNil(flat.groundY(atX: 150))        // outside span

        let slope = WzFoothold(id: 2, layer: 0, x1: 0, y1: 0, x2: 100, y2: 100, previousID: 0, nextID: 0)
        XCTAssertEqual(slope.groundY(atX: 25), 25)

        let wall = WzFoothold(id: 3, layer: 0, x1: 50, y1: 0, x2: 50, y2: 100, previousID: 0, nextID: 0)
        XCTAssertTrue(wall.isWall)
        XCTAssertNil(wall.groundY(atX: 50))
    }

    func testLoadedMapGroundSelection() {
        // Two overlapping footholds at x=50: choose the higher (smaller y) at or
        // below the query point.
        let high = WzFoothold(id: 1, layer: 0, x1: 0, y1: 100, x2: 100, y2: 100, previousID: 0, nextID: 0)
        let low = WzFoothold(id: 2, layer: 0, x1: 0, y1: 200, x2: 100, y2: 200, previousID: 0, nextID: 0)
        let map = WzLoadedMap(id: 1, backgrounds: [], foregrounds: [], tiles: [], objects: [],
                              left: 0, top: 0, right: 100, bottom: 200, spawnX: 0, spawnY: 0,
                              footholds: [low, high], life: [], portals: [], ladders: [], bgm: nil)

        let ground = map.ground(atX: 50, below: 50)
        XCTAssertEqual(ground?.y, 100)
        XCTAssertEqual(ground?.foothold.id, 1)
        XCTAssertEqual(map.groundY(atX: 50, below: 50), 100)

        // Nothing below the query point.
        XCTAssertNil(map.groundY(atX: 50, below: 300))
        // Tolerance lets a point slightly under the ground still find it.
        XCTAssertEqual(map.groundY(atX: 50, below: 110, tolerance: 20), 100)
        // No ground at an x with no footholds.
        XCTAssertNil(map.groundY(atX: 500, below: 0))
    }

    func testMinimapTransform() {
        let minimap = WzMapMinimap(rgba: [], width: 10, height: 10, centerX: 100, centerY: 50, mag: 2)
        // scale = 1 << 2 = 4; point = (world + center) / scale.
        let p = minimap.point(worldX: 300, worldY: 150)
        XCTAssertEqual(p.x, (300 + 100) / 4)
        XCTAssertEqual(p.y, (150 + 50) / 4)
    }

    func testLadderContains() {
        let ladder = WzMapLadder(x: 50, y1: 0, y2: 100, isLadder: true, usableFromTop: true, layer: 0)
        XCTAssertTrue(ladder.contains(x: 52, y: 50))         // within x-tolerance and y-span
        XCTAssertFalse(ladder.contains(x: 80, y: 50))        // too far horizontally
        XCTAssertFalse(ladder.contains(x: 50, y: -10))       // above the top
        XCTAssertTrue(ladder.contains(x: 50, y: 104))        // just past bottom (+5 slack)
        XCTAssertFalse(ladder.contains(x: 50, y: 120))       // well below
    }

    func testPortalUsableAndVisible() {
        let spawn = WzMapPortal(id: 0, name: "sp", type: 0, x: 0, y: 0, targetMap: 999_999_999, targetName: "")
        XCTAssertFalse(spawn.isUsable)      // type 0 spawn point
        XCTAssertFalse(spawn.isVisible)

        let visible = WzMapPortal(id: 1, name: "east00", type: 2, x: 0, y: 0, targetMap: 100010000, targetName: "west00")
        XCTAssertTrue(visible.isUsable)
        XCTAssertTrue(visible.isVisible)

        let hidden = WzMapPortal(id: 2, name: "in00", type: 1, x: 0, y: 0, targetMap: 200000000, targetName: "out00")
        XCTAssertTrue(hidden.isUsable)      // type 1 still transports
        XCTAssertFalse(hidden.isVisible)    // but no swirl

        let dead = WzMapPortal(id: 3, name: "tp", type: 2, x: 0, y: 0, targetMap: 999_999_999, targetName: "")
        XCTAssertFalse(dead.isUsable)       // no destination
    }

    func testLifeAndSpriteStructs() {
        let life = WzMapLife(type: "m", id: 100101, x: 10, y: 20, footholdID: 3, flipped: true,
                             hidden: false, patrolMinX: -50, patrolMaxX: 50)
        XCTAssertEqual(life.type, "m")
        XCTAssertEqual(life.patrolMinX, -50)

        let frame = WzSpriteFrame(rgba: [1, 2, 3, 4], width: 1, height: 1,
                                  originX: 0, originY: 0, delayMilliseconds: 100)
        let sprite = WzMapSprite(rgba: frame.rgba, width: 1, height: 1, x: 5, y: 6,
                                 originX: 0, originY: 0, layer: 2, z: 3, flipped: false, frames: [frame])
        XCTAssertEqual(sprite.layer, 2)
        XCTAssertEqual(sprite.frames.count, 1)

        let background = WzMapBackground(rgba: [], width: 4, height: 4, x: 0, y: 0, originX: 0, originY: 0,
                                         rx: 50, ry: 25, cx: 0, cy: 0, horizontalTile: true, verticalTile: false,
                                         isForeground: false, opacity: 0.5, flipped: false, frames: [frame])
        XCTAssertEqual(background.rx, 50)
        XCTAssertTrue(background.horizontalTile)
        XCTAssertEqual(background.opacity, 0.5)
    }
}
