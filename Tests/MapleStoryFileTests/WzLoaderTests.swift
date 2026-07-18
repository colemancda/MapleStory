//
//  WzLoaderTests.swift
//  MapleStoryFileTests
//
//  The higher-level loaders (zmap, String.wz names, UI sprites, life sprites)
//  driven by synthetic in-memory archives.
//

import XCTest
import Foundation
@testable import MapleStoryFile

// MARK: - Zmap

final class WzZmapTests: XCTestCase {

    func testLoadFromArchive() throws {
        let data = WzFixtures.buildArchive(images: [("zmap.img", WzFixtures.image([
            WzFixtures.property("body", WzFixtures.null()),
            WzFixtures.property("hair", WzFixtures.null()),
            WzFixtures.property("cap", WzFixtures.null()),
        ]))])
        let archive = try WzArchive(data: data, mapleVersion: .bms, version: 1)
        let zmap = try WzZmap.load(from: archive)

        XCTAssertEqual(zmap.order["body"], 0)
        XCTAssertEqual(zmap.order["hair"], 1)
        XCTAssertEqual(zmap.order["cap"], 2)
        // Later entries have higher priority (drawn further back).
        XCTAssertGreaterThan(zmap.priority(of: "cap"), zmap.priority(of: "body"))
        // Unknown layers sort to the very back.
        XCTAssertEqual(zmap.priority(of: "nonexistent"), Int.max)
    }

    func testLoadMissingZmapReturnsEmpty() throws {
        let data = WzFixtures.buildArchive(images: [("other.img", WzFixtures.image([]))])
        let archive = try WzArchive(data: data, mapleVersion: .bms, version: 1)
        let zmap = try WzZmap.load(from: archive)
        XCTAssertTrue(zmap.order.isEmpty)
    }

    func testDirectInit() {
        let zmap = WzZmap(order: ["a": 0, "b": 5])
        XCTAssertEqual(zmap.priority(of: "b"), 5)
        XCTAssertEqual(zmap.priority(of: "a"), 0)
    }
}

// MARK: - String.wz names

final class WzStringLoaderTests: XCTestCase {

    private func archive() throws -> WzArchive {
        let npc = WzFixtures.image([
            WzFixtures.property("1012000", WzFixtures.sub([
                WzFixtures.property("name", WzFixtures.string("Regular Cab")),
            ])),
        ])
        let mob = WzFixtures.image([
            WzFixtures.property("100101", WzFixtures.sub([
                WzFixtures.property("name", WzFixtures.string("Blue Snail")),
            ])),
        ])
        return try WzArchive(data: WzFixtures.buildArchive(images: [("Npc.img", npc), ("Mob.img", mob)]),
                             mapleVersion: .bms, version: 1)
    }

    func testNpcAndMobNames() throws {
        let loader = WzStringLoader(archive: try archive())
        XCTAssertEqual(loader.npcName(id: 1012000), "Regular Cab")
        XCTAssertEqual(loader.mobName(id: 100101), "Blue Snail")
        // Cached second read yields the same value.
        XCTAssertEqual(loader.npcName(id: 1012000), "Regular Cab")
    }

    func testMissingIdAndImage() throws {
        let loader = WzStringLoader(archive: try archive())
        XCTAssertNil(loader.npcName(id: 999999))
        // No Map.img in this archive -> mobName still works, but a made-up loader
        // over an archive lacking the image returns nil.
        let empty = try WzArchive(data: WzFixtures.buildArchive(images: [("x.img", WzFixtures.image([]))]),
                                  mapleVersion: .bms, version: 1)
        XCTAssertNil(WzStringLoader(archive: empty).npcName(id: 1012000))
    }
}

// MARK: - UI sprites

final class WzUILoaderTests: XCTestCase {

    private func pixel(_ b: UInt8) -> [UInt8] { [b, b, b, 0xFF] }   // 1x1 BGRA8888

    private func archive() throws -> WzArchive {
        let logo = WzFixtures.canvas(width: 1, height: 1, format: 2, rawPixels: pixel(10),
                                     properties: [WzFixtures.property("origin", WzFixtures.vector(x: 2, y: 3)),
                                                  WzFixtures.property("delay", WzFixtures.int32(120))])
        let anim = WzFixtures.sub([
            WzFixtures.property("0", WzFixtures.canvas(width: 1, height: 1, format: 2, rawPixels: pixel(20))),
            WzFixtures.property("1", WzFixtures.canvas(width: 1, height: 1, format: 2, rawPixels: pixel(30))),
        ])
        // An alias canvas that delegates its pixels to "logo" via _inlink.
        let alias = WzFixtures.canvasEmpty(properties: [
            WzFixtures.property("_inlink", WzFixtures.string("logo")),
        ])
        let img = WzFixtures.image([
            WzFixtures.property("logo", logo),
            WzFixtures.property("btn", anim),
            WzFixtures.property("alias", alias),
        ])
        return try WzArchive(data: WzFixtures.buildArchive(images: [("Login.img", img)]),
                             mapleVersion: .bms, version: 1)
    }

    func testSpriteDecodesCanvas() throws {
        let loader = WzUILoader(archive: try archive())
        let sprite = try XCTUnwrap(loader.sprite(image: "Login.img", path: "logo"))
        XCTAssertEqual(sprite.width, 1)
        XCTAssertEqual(sprite.originX, 2)
        XCTAssertEqual(sprite.originY, 3)
        XCTAssertEqual(sprite.delayMilliseconds, 120)
        XCTAssertEqual(sprite.rgba.count, 4)
    }

    func testSpriteFromAnimationContainerUsesFirstFrame() throws {
        let loader = WzUILoader(archive: try archive())
        let sprite = try XCTUnwrap(loader.sprite(image: "Login.img", path: "btn"))
        XCTAssertEqual(sprite.rgba, [20, 20, 20, 0xFF])
    }

    func testFramesDecodesEveryFrame() throws {
        let loader = WzUILoader(archive: try archive())
        let frames = try loader.frames(image: "Login.img", path: "btn")
        XCTAssertEqual(frames.count, 2)
        XCTAssertEqual(frames[0].rgba, [20, 20, 20, 0xFF])
        XCTAssertEqual(frames[1].rgba, [30, 30, 30, 0xFF])
    }

    func testInlinkDelegation() throws {
        let loader = WzUILoader(archive: try archive())
        // The alias has no pixels of its own; it must resolve to logo's bitmap.
        let sprite = try XCTUnwrap(loader.sprite(image: "Login.img", path: "alias"))
        XCTAssertEqual(sprite.rgba, [10, 10, 10, 0xFF])
    }

    func testMissingImageAndPath() throws {
        let loader = WzUILoader(archive: try archive())
        XCTAssertNil(try loader.properties(image: "Nope.img"))
        XCTAssertNil(try loader.sprite(image: "Login.img", path: "missing"))
        XCTAssertTrue(try loader.frames(image: "Login.img", path: "missing").isEmpty)
        // Cached properties on a second call.
        XCTAssertNotNil(try loader.properties(image: "Login.img"))
    }
}

// MARK: - Life sprites (NPCs / mobs)

final class WzLifeSpriteLoaderTests: XCTestCase {

    private func pixel(_ b: UInt8) -> [UInt8] { [b, b, b, 0xFF] }

    private func standCanvas(_ b: UInt8) -> [UInt8] {
        WzFixtures.canvas(width: 1, height: 1, format: 2, rawPixels: pixel(b),
                          properties: [WzFixtures.property("origin", WzFixtures.vector(x: 1, y: 1)),
                                       WzFixtures.property("delay", WzFixtures.int32(150))])
    }

    private func archive() throws -> WzArchive {
        // 0000100.img: a full mob with info + a 2-frame stand animation.
        let mob = WzFixtures.image([
            WzFixtures.property("info", WzFixtures.sub([
                WzFixtures.property("speed", WzFixtures.int32(-50)),
                WzFixtures.property("maxHP", WzFixtures.int32(1000)),
                WzFixtures.property("PADamage", WzFixtures.int32(5)),
            ])),
            WzFixtures.property("stand", WzFixtures.sub([
                WzFixtures.property("0", standCanvas(11)),
                WzFixtures.property("1", standCanvas(22)),
            ])),
        ])
        // 0000200.img: an alias that links to 100.
        let alias = WzFixtures.image([
            WzFixtures.property("info", WzFixtures.sub([
                WzFixtures.property("link", WzFixtures.string("100")),
            ])),
        ])
        return try WzArchive(data: WzFixtures.buildArchive(images: [
            ("0000100.img", mob), ("0000200.img", alias),
        ]), mapleVersion: .bms, version: 1)
    }

    func testLoadStandFrames() throws {
        let loader = WzLifeSpriteLoader(archive: try archive())
        let frames = try loader.loadStandFrames(id: 100)
        XCTAssertEqual(frames.count, 2)
        XCTAssertEqual(frames[0].rgba, [11, 11, 11, 0xFF])
        XCTAssertEqual(frames[0].originX, 1)
        XCTAssertEqual(frames[0].delayMilliseconds, 150)
        XCTAssertEqual(frames[1].rgba, [22, 22, 22, 0xFF])
    }

    func testInfoAccessors() throws {
        let loader = WzLifeSpriteLoader(archive: try archive())
        XCTAssertEqual(loader.speedPercent(id: 100), -50)
        XCTAssertEqual(loader.maxHP(id: 100), 1000)
        XCTAssertEqual(loader.touchDamage(id: 100), 5)
    }

    func testLinkResolution() throws {
        let loader = WzLifeSpriteLoader(archive: try archive())
        // 200 links to 100, so it inherits 100's stand animation.
        let frames = try loader.loadStandFrames(id: 200)
        XCTAssertEqual(frames.count, 2)
        XCTAssertEqual(frames[0].rgba, [11, 11, 11, 0xFF])
    }

    func testMissingIdDefaults() throws {
        let loader = WzLifeSpriteLoader(archive: try archive())
        XCTAssertTrue(try loader.loadStandFrames(id: 999).isEmpty)
        XCTAssertEqual(loader.speedPercent(id: 999), 0)
        XCTAssertEqual(loader.maxHP(id: 999), 1)      // clamped to at least 1
        XCTAssertEqual(loader.touchDamage(id: 999), 0)
        XCTAssertTrue(try loader.loadFrames(action: "walk", id: 100).isEmpty)  // no such action
    }

    func testWzLifeSpriteInit() {
        let life = WzMapLife(type: "m", id: 100, x: 0, y: 0, footholdID: 0, flipped: false,
                             hidden: false, patrolMinX: nil, patrolMaxX: nil)
        let sprite = WzLifeSprite(life: life, standFrames: [])
        XCTAssertEqual(sprite.maxHP, 1)
        XCTAssertEqual(sprite.speedPercent, 0)
        XCTAssertEqual(sprite.touchDamage, 0)
        XCTAssertTrue(sprite.moveFrames.isEmpty)
    }
}
