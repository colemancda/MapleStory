//
//  WzMapLoaderTests.swift
//  MapleStoryFileTests
//
//  Validates map loading against a real Map.wz (skipped when unavailable).
//

import XCTest
import Foundation
@testable import MapleStoryFile

final class WzMapLoaderTests: XCTestCase {

    private let mapPath = "/Volumes/[C] Windows 11/Nexon/MapleStory62/Map.wz"

    func testLoadHenesysMap() throws {
        guard FileManager.default.fileExists(atPath: mapPath) else { throw XCTSkip("Map.wz not mounted") }
        let data = try Data(contentsOf: URL(fileURLWithPath: mapPath))
        let wz = try WzArchive(data: data, mapleVersion: .gms)
        let loader = WzMapLoader(archive: wz)
        let map = try loader.load(mapID: 100000000)

        print("Henesys: backgrounds=\(map.backgrounds.count) foregrounds=\(map.foregrounds.count) tiles=\(map.tiles.count) objects=\(map.objects.count)")
        print("  bounds L=\(map.left) T=\(map.top) R=\(map.right) B=\(map.bottom)")

        XCTAssertFalse(map.backgrounds.isEmpty)
        XCTAssertFalse(map.tiles.isEmpty)
        XCTAssertFalse(map.objects.isEmpty)
        for sprite in map.tiles + map.objects {
            XCTAssertEqual(sprite.rgba.count, sprite.width * sprite.height * 4)
        }
        for layer in map.backgrounds + map.foregrounds {
            XCTAssertEqual(layer.rgba.count, layer.width * layer.height * 4)
        }

        // Footholds: Henesys has walkable geometry, and there must be ground
        // at (or below) the spawn portal.
        print("  footholds=\(map.footholds.count) spawn=(\(map.spawnX),\(map.spawnY))")
        XCTAssertFalse(map.footholds.isEmpty)
        let ground = map.groundY(atX: Float(map.spawnX), below: Float(map.spawnY), tolerance: 50)
        XCTAssertNotNil(ground, "expected ground under the spawn portal")
        if let ground {
            print("  ground under spawn: y=\(ground)")
            XCTAssertLessThan(abs(ground - Float(map.spawnY)), 100, "spawn portal should sit near its ground")
        }
    }

    func testFootholdGeometry() {
        // A flat segment from (0, 100) to (100, 100) and a slope from (100, 100)
        // to (200, 50).
        let flat = WzFoothold(id: 1, layer: 0, x1: 0, y1: 100, x2: 100, y2: 100, previousID: 0, nextID: 2)
        let slope = WzFoothold(id: 2, layer: 0, x1: 100, y1: 100, x2: 200, y2: 50, previousID: 1, nextID: 0)
        let wall = WzFoothold(id: 3, layer: 0, x1: 200, y1: 50, x2: 200, y2: 150, previousID: 2, nextID: 0)

        XCTAssertEqual(flat.groundY(atX: 50), 100)
        XCTAssertEqual(slope.groundY(atX: 150), 75)
        XCTAssertNil(slope.groundY(atX: 250))
        XCTAssertTrue(wall.isWall)
        XCTAssertNil(wall.groundY(atX: 200))

        let map = WzLoadedMap(id: 0, backgrounds: [], foregrounds: [], tiles: [], objects: [],
                              left: 0, top: 0, right: 200, bottom: 200,
                              spawnX: 0, spawnY: 0, footholds: [flat, slope, wall])
        XCTAssertEqual(map.groundY(atX: 50, below: 0), 100)
        XCTAssertEqual(map.groundY(atX: 150, below: 0), 75)
        // Standing slightly under the ground still finds it within tolerance.
        XCTAssertEqual(map.groundY(atX: 50, below: 110, tolerance: 20), 100)
        // But not without tolerance.
        XCTAssertNil(map.groundY(atX: 50, below: 110))
    }
}
