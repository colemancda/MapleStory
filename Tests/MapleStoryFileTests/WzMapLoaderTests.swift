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
    }
}
