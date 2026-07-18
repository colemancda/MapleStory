//
//  WzMapLoaderSyntheticTests.swift
//  MapleStoryFileTests
//
//  Drives WzMapLoader end-to-end over a synthetic Map.wz-shaped archive (backs,
//  tiles, objects, footholds, life, portals, ladders, minimap) built in memory.
//

import XCTest
import Foundation
@testable import MapleStoryFile

final class WzMapLoaderSyntheticTests: XCTestCase {

    private func pixel(_ b: UInt8) -> [UInt8] { [b, b, b, 0xFF] }

    private func canvas(_ b: UInt8, extra: [[UInt8]] = []) -> [UInt8] {
        WzFixtures.canvas(width: 1, height: 1, format: 2, rawPixels: pixel(b),
                          properties: [WzFixtures.property("origin", WzFixtures.vector(x: 0, y: 0)),
                                       WzFixtures.property("delay", WzFixtures.int32(100))] + extra)
    }

    private func node(_ pairs: [(String, [UInt8])]) -> [UInt8] {
        WzFixtures.sub(pairs.map { WzFixtures.property($0.0, $0.1) })
    }

    /// A full Henesys-shaped map plus its referenced sprite images.
    private func mapArchive() -> Data {
        let mapImage = WzFixtures.image([
            WzFixtures.property("info", node([
                ("VRLeft", WzFixtures.int32(-100)), ("VRTop", WzFixtures.int32(-200)),
                ("VRRight", WzFixtures.int32(300)), ("VRBottom", WzFixtures.int32(400)),
                ("bgm", WzFixtures.string("Bgm00/FloralLife")),
            ])),
            // Backgrounds: one static back, one animated foreground.
            WzFixtures.property("back", node([
                ("0", node([
                    ("bS", WzFixtures.string("grassySoil")), ("no", WzFixtures.int32(0)),
                    ("x", WzFixtures.int32(0)), ("y", WzFixtures.int32(0)),
                    ("ani", WzFixtures.int32(0)), ("type", WzFixtures.int32(1)),
                    ("rx", WzFixtures.int32(-50)), ("ry", WzFixtures.int32(0)),
                    ("front", WzFixtures.int32(0)), ("a", WzFixtures.int32(255)),
                ])),
                ("1", node([
                    ("bS", WzFixtures.string("grassySoil")), ("no", WzFixtures.int32(0)),
                    ("ani", WzFixtures.int32(1)), ("front", WzFixtures.int32(1)),
                    ("a", WzFixtures.int32(128)),
                ])),
            ])),
            // Layer 0: one tile + one animated object.
            WzFixtures.property("0", node([
                ("info", node([("tS", WzFixtures.string("grassySoil"))])),
                ("tile", node([
                    ("0", node([("u", WzFixtures.string("bsc")), ("no", WzFixtures.int32(0)),
                                ("x", WzFixtures.int32(10)), ("y", WzFixtures.int32(20))])),
                ])),
                ("obj", node([
                    ("0", node([("oS", WzFixtures.string("guide")), ("l0", WzFixtures.string("grave")),
                                ("l1", WzFixtures.string("0")), ("l2", WzFixtures.string("0")),
                                ("x", WzFixtures.int32(30)), ("y", WzFixtures.int32(40)),
                                ("z", WzFixtures.int32(5)), ("f", WzFixtures.int32(1))])),
                ])),
            ])),
            // Footholds: layer 0 / group 1 / segment 1.
            WzFixtures.property("foothold", node([
                ("0", node([("1", node([
                    ("1", node([("x1", WzFixtures.int32(-100)), ("y1", WzFixtures.int32(100)),
                                ("x2", WzFixtures.int32(100)), ("y2", WzFixtures.int32(100)),
                                ("prev", WzFixtures.int32(0)), ("next", WzFixtures.int32(0))])),
                ]))])),
            ])),
            WzFixtures.property("life", node([
                ("0", node([("type", WzFixtures.string("n")), ("id", WzFixtures.string("1012000")),
                            ("x", WzFixtures.int32(0)), ("cy", WzFixtures.int32(100)),
                            ("fh", WzFixtures.int32(1)), ("f", WzFixtures.int32(0)),
                            ("hide", WzFixtures.int32(0)), ("rx0", WzFixtures.int32(-20)),
                            ("rx1", WzFixtures.int32(20))])),
            ])),
            WzFixtures.property("portal", node([
                ("0", node([("pn", WzFixtures.string("sp")), ("pt", WzFixtures.int32(0)),
                            ("x", WzFixtures.int32(0)), ("y", WzFixtures.int32(100)),
                            ("tm", WzFixtures.int32(999_999_999)), ("tn", WzFixtures.string(""))])),
                ("1", node([("pn", WzFixtures.string("east00")), ("pt", WzFixtures.int32(2)),
                            ("x", WzFixtures.int32(90)), ("y", WzFixtures.int32(100)),
                            ("tm", WzFixtures.int32(100_010_000)), ("tn", WzFixtures.string("west00"))])),
            ])),
            WzFixtures.property("ladderRope", node([
                ("0", node([("x", WzFixtures.int32(50)), ("y1", WzFixtures.int32(100)),
                            ("y2", WzFixtures.int32(0)), ("l", WzFixtures.int32(1)),
                            ("uf", WzFixtures.int32(1)), ("page", WzFixtures.int32(0))])),
            ])),
            WzFixtures.property("miniMap", node([
                ("canvas", canvas(200)),
                ("centerX", WzFixtures.int32(100)), ("centerY", WzFixtures.int32(50)),
                ("mag", WzFixtures.int32(1)),
            ])),
        ])

        let backImg = WzFixtures.image([
            WzFixtures.property("back", node([("0", canvas(50))])),
            WzFixtures.property("ani", node([("0", node([("0", canvas(60)), ("1", canvas(70))]))])),
        ])
        let tileImg = WzFixtures.image([
            WzFixtures.property("bsc", node([("0", canvas(80, extra: [WzFixtures.property("z", WzFixtures.int32(7))]))])),
        ])
        let objImg = WzFixtures.image([
            WzFixtures.property("grave", node([("0", node([("0", node([("0", canvas(90)), ("1", canvas(95))]))]))])),
        ])
        let helperImg = WzFixtures.image([
            WzFixtures.property("portal", node([("game", node([("pv", node([("0", canvas(11)), ("1", canvas(12))]))]))])),
        ])

        return WzFixtures.buildArchiveTree([
            .directory(name: "Map", children: [
                .directory(name: "Map1", children: [.image(name: "100000000.img", payload: mapImage)]),
            ]),
            .directory(name: "Back", children: [.image(name: "grassySoil.img", payload: backImg)]),
            .directory(name: "Tile", children: [.image(name: "grassySoil.img", payload: tileImg)]),
            .directory(name: "Obj", children: [.image(name: "guide.img", payload: objImg)]),
            .image(name: "MapHelper.img", payload: helperImg),
        ])
    }

    func testLoadFullMap() throws {
        let archive = try WzArchive(data: mapArchive(), mapleVersion: .bms, version: 1)
        let loader = WzMapLoader(archive: archive)
        let map = try loader.load(mapID: 100_000_000)

        // Bounds come from the VR info fields.
        XCTAssertEqual(map.left, -100)
        XCTAssertEqual(map.top, -200)
        XCTAssertEqual(map.right, 300)
        XCTAssertEqual(map.bottom, 400)
        XCTAssertEqual(map.bgm, "Bgm00/FloralLife")

        // Backgrounds: one back, one animated foreground (front == 1).
        XCTAssertEqual(map.backgrounds.count, 1)
        XCTAssertEqual(map.foregrounds.count, 1)
        XCTAssertEqual(map.backgrounds[0].rx, -50)
        XCTAssertTrue(map.backgrounds[0].horizontalTile)     // type 1
        XCTAssertEqual(map.foregrounds[0].frames.count, 2)   // ani background
        XCTAssertEqual(map.foregrounds[0].opacity, 128.0 / 255.0, accuracy: 0.001)

        // One tile (static) and one animated object.
        XCTAssertEqual(map.tiles.count, 1)
        XCTAssertEqual(map.objects.count, 1)
        XCTAssertEqual(map.tiles[0].z, 7)                    // tile z from the canvas
        XCTAssertEqual(map.tiles[0].x, 10)
        XCTAssertEqual(map.objects[0].z, 5)                  // object z from the placement
        XCTAssertTrue(map.objects[0].flipped)
        XCTAssertEqual(map.objects[0].frames.count, 2)       // animated

        // Footholds / life / portals / ladders.
        XCTAssertEqual(map.footholds.count, 1)
        XCTAssertEqual(map.footholds[0].id, 1)
        XCTAssertEqual(map.life.count, 1)
        XCTAssertEqual(map.life[0].id, 1012000)
        XCTAssertEqual(map.life[0].patrolMinX, -20)
        XCTAssertEqual(map.portals.count, 2)
        let east = try XCTUnwrap(map.portals.first { $0.name == "east00" })
        XCTAssertEqual(east.targetMap, 100_010_000)
        XCTAssertEqual(east.targetName, "west00")
        XCTAssertTrue(east.isVisible)
        XCTAssertEqual(map.ladders.count, 1)
        XCTAssertEqual(map.ladders[0].y1, 0)                 // normalized top < bottom
        XCTAssertEqual(map.ladders[0].y2, 100)

        // Spawn = first portal ("sp").
        XCTAssertEqual(map.spawnX, 0)
        XCTAssertEqual(map.spawnY, 100)

        // Minimap decoded.
        let minimap = try XCTUnwrap(map.minimap)
        XCTAssertEqual(minimap.width, 1)
        XCTAssertEqual(minimap.centerX, 100)
        XCTAssertEqual(minimap.mag, 1)
    }

    func testLoadBackgroundsDirectly() throws {
        let archive = try WzArchive(data: mapArchive(), mapleVersion: .bms, version: 1)
        let loader = WzMapLoader(archive: archive)
        let props = try archive.properties(of: try XCTUnwrap(archive.root["Map/Map1/100000000.img"]))
        let (backgrounds, foregrounds) = try loader.loadBackgrounds(from: props)
        XCTAssertEqual(backgrounds.count, 1)
        XCTAssertEqual(foregrounds.count, 1)
    }

    func testLoadPortalAnimation() throws {
        let archive = try WzArchive(data: mapArchive(), mapleVersion: .bms, version: 1)
        let loader = WzMapLoader(archive: archive)
        let frames = try loader.loadPortalAnimation()
        XCTAssertEqual(frames.count, 2)
        XCTAssertEqual(frames[0].rgba, [11, 11, 11, 0xFF])
    }

    func testLoadMissingMapThrows() throws {
        let archive = try WzArchive(data: mapArchive(), mapleVersion: .bms, version: 1)
        let loader = WzMapLoader(archive: archive)
        XCTAssertThrowsError(try loader.load(mapID: 900_000_000)) { error in
            guard case WzArchiveError.invalidHeader = error else { return XCTFail("\(error)") }
        }
    }
}
