//
//  WzCharacterLoaderSyntheticTests.swift
//  MapleStoryFileTests
//
//  Drives WzCharacterLoader (body/head/face + equipment, UOL & _inlink
//  resolution, anchor inference, zmap sorting, hair hiding) over a synthetic
//  Character.wz-shaped archive built in memory.
//

import XCTest
import Foundation
@testable import MapleStoryFile

final class WzCharacterLoaderSyntheticTests: XCTestCase {

    private func pixel(_ b: UInt8) -> [UInt8] { [b, b, b, 0xFF] }
    private func sub(_ pairs: [(String, [UInt8])]) -> [UInt8] {
        WzFixtures.sub(pairs.map { WzFixtures.property($0.0, $0.1) })
    }

    /// A part canvas carrying `z` and named anchor points.
    private func part(_ b: UInt8, z: String, maps: [(String, Int32, Int32)] = []) -> [UInt8] {
        var props: [[UInt8]] = [
            WzFixtures.property("origin", WzFixtures.vector(x: 0, y: 0)),
            WzFixtures.property("z", WzFixtures.string(z)),
        ]
        if maps.isEmpty == false {
            props.append(WzFixtures.property("map", WzFixtures.sub(maps.map {
                WzFixtures.property($0.0, WzFixtures.vector(x: $0.1, y: $0.2))
            })))
        }
        return WzFixtures.canvas(width: 1, height: 1, format: 2, rawPixels: pixel(b), properties: props)
    }

    /// A pixel-less part that delegates its bitmap via `_inlink`.
    private func inlinkPart(z: String, inlink: String) -> [UInt8] {
        WzFixtures.canvasEmpty(properties: [
            WzFixtures.property("z", WzFixtures.string(z)),
            WzFixtures.property("_inlink", WzFixtures.string(inlink)),
        ])
    }

    private func archive() -> Data {
        // Body: stand1 (1 frame) + walk1 (2 frames). Frames carry delay/face ints
        // (which are not canvases) alongside body/arm canvases.
        let body = WzFixtures.image([
            WzFixtures.property("stand1", sub([
                ("0", sub([
                    ("delay", WzFixtures.int32(120)),
                    ("face", WzFixtures.int32(1)),
                    ("body", part(1, z: "body", maps: [("navel", 5, 5), ("neck", 3, 1)])),
                    ("arm", part(2, z: "arm", maps: [("navel", 4, 4), ("hand", 9, 9)])),
                ])),
            ])),
            WzFixtures.property("walk1", sub([
                ("0", sub([("body", part(1, z: "body", maps: [("navel", 5, 5)]))])),
                ("1", sub([("body", part(1, z: "body", maps: [("navel", 5, 5)])),
                           ("face", WzFixtures.int32(0))])),   // face hidden this frame
            ])),
        ])

        // Head: the frame's "head" is a UOL back to front/head (exercises resolve).
        let head = WzFixtures.image([
            WzFixtures.property("front", sub([("head", part(3, z: "head", maps: [("neck", 2, 2)]))])),
            WzFixtures.property("stand1", sub([
                ("0", sub([("head", WzFixtures.uol("../../front/./head"))])),
            ])),
            WzFixtures.property("walk1", sub([
                ("0", sub([("head", WzFixtures.uol("../../front/head"))])),
                ("1", sub([("head", WzFixtures.uol("../../front/head"))])),
            ])),
        ])

        let face = WzFixtures.image([
            WzFixtures.property("default", sub([("face", part(4, z: "face", maps: [("brow", 1, 1)]))])),
        ])

        let coat = WzFixtures.image([
            WzFixtures.property("stand1", sub([
                ("0", sub([
                    ("mailChest", part(6, z: "mailChest", maps: [("navel", 5, 5)])),
                    ("mail", inlinkPart(z: "mail", inlink: "stand1/0/mailChest")),
                ])),
            ])),
        ])
        let pants = WzFixtures.image([
            WzFixtures.property("stand1", sub([("0", sub([("pants", part(7, z: "pants"))]))])),
        ])
        let hair = WzFixtures.image([
            WzFixtures.property("stand1", sub([("0", sub([("hair", part(8, z: "hair", maps: [("brow", 1, 1)]))]))])),
        ])
        let cap = WzFixtures.image([
            WzFixtures.property("info", sub([("vslot", WzFixtures.string("CpH5H1"))])),
            WzFixtures.property("stand1", sub([("0", sub([("cap", part(9, z: "cap"))]))])),
        ])
        let weapon = WzFixtures.image([
            WzFixtures.property("stand1", sub([("0", sub([("weapon", part(10, z: "weapon", maps: [("hand", 9, 9)]))]))])),
        ])

        return WzFixtures.buildArchiveTree([
            .image(name: "00002000.img", payload: body),
            .image(name: "00012000.img", payload: head),
            .directory(name: "Face", children: [.image(name: "00020000.img", payload: face)]),
            .directory(name: "Coat", children: [.image(name: "01040002.img", payload: coat)]),
            .directory(name: "Pants", children: [.image(name: "01060002.img", payload: pants)]),
            .directory(name: "Hair", children: [.image(name: "00030030.img", payload: hair)]),
            .directory(name: "Cap", children: [.image(name: "01002005.img", payload: cap)]),
            .directory(name: "Weapon", children: [.image(name: "01302000.img", payload: weapon)]),
        ])
    }

    private func loadedArchive() throws -> WzArchive {
        try WzArchive(data: archive(), mapleVersion: .bms, version: 1)
    }

    private func zmap() -> WzZmap {
        WzZmap(order: [
            "weapon": 0, "cap": 1, "hair": 2, "face": 3, "head": 4,
            "arm": 5, "mailChest": 6, "mail": 7, "pants": 8, "body": 30,
        ])
    }

    // MARK: - Tests

    func testLoadDefaultCharacter() throws {
        let loader = WzCharacterLoader(archive: try loadedArchive())
        let character = try loader.load(skin: 0, faceID: 20000)

        XCTAssertEqual(character.stand.frames.count, 1)
        XCTAssertEqual(character.walk.frames.count, 2)
        // Actions with no body node yield empty animations.
        XCTAssertTrue(character.jump.frames.isEmpty)
        XCTAssertTrue(character.attack.frames.isEmpty)
        XCTAssertTrue(character.prone.frames.isEmpty)

        let frame0 = character.stand.frames[0]
        XCTAssertEqual(frame0.delayMilliseconds, 120)
        func part(_ z: String) -> WzCharacterPart? { frame0.parts.first { $0.zLayer == z } }

        let bodyPart = try XCTUnwrap(part("body"))
        XCTAssertEqual(bodyPart.anchor, .root)
        XCTAssertEqual(bodyPart.point("navel").x, 5)
        XCTAssertEqual(bodyPart.point("missing").x, 0)       // default point
        XCTAssertEqual(bodyPart.point("missing").y, 0)

        XCTAssertEqual(try XCTUnwrap(part("arm")).anchor, .navel)  // navel wins over hand
        XCTAssertEqual(try XCTUnwrap(part("head")).anchor, .neck)  // resolved via UOL
        XCTAssertEqual(try XCTUnwrap(part("face")).anchor, .brow)

        // walk1 frame 1 hides the face (face flag == 0).
        let walk1 = character.walk.frames[1]
        XCTAssertFalse(walk1.parts.contains { $0.zLayer == "face" })
    }

    func testLoadStandOnly() throws {
        let loader = WzCharacterLoader(archive: try loadedArchive())
        let stand = try loader.loadStand()
        XCTAssertEqual(stand.frames.count, 1)
        XCTAssertTrue(stand.frames[0].parts.contains { $0.zLayer == "body" })
    }

    func testEquipmentAndZSort() throws {
        let loader = WzCharacterLoader(archive: try loadedArchive(), zmap: zmap())
        let character = try loader.load(skin: 0, faceID: 20000, equipment: [
            WzEquipItem(category: "Coat", id: 1040002),
            WzEquipItem(category: "Pants", id: 1060002),
            WzEquipItem(category: "Hair", id: 30030),
        ])
        let frame0 = character.stand.frames[0]
        let layers = Set(frame0.parts.map(\.zLayer))
        XCTAssertTrue(layers.contains("mailChest"))
        XCTAssertTrue(layers.contains("pants"))
        XCTAssertTrue(layers.contains("hair"))

        // Parts are z-sorted back-to-front by zmap priority.
        let priorities = frame0.parts.map { zmap().priority(of: $0.zLayer) }
        XCTAssertEqual(priorities, priorities.sorted(by: >))
        // Body (highest zmap index) draws first.
        XCTAssertEqual(frame0.parts.first?.zLayer, "body")

        // The _inlink "mail" part resolved to a real bitmap.
        XCTAssertTrue(frame0.parts.contains { $0.zLayer == "mailChest" })
    }

    func testHelmetHidesHair() throws {
        let loader = WzCharacterLoader(archive: try loadedArchive(), zmap: zmap())
        let character = try loader.load(skin: 0, faceID: 20000, equipment: [
            WzEquipItem(category: "Hair", id: 30030),
            WzEquipItem(category: "Cap", id: 1002005),   // vslot contains "H1"
        ])
        let layers = character.stand.frames[0].parts.map(\.zLayer)
        XCTAssertTrue(layers.contains("cap"))
        XCTAssertFalse(layers.contains { $0.lowercased().contains("hair") })
    }

    func testWeaponAnchorsToHand() throws {
        let loader = WzCharacterLoader(archive: try loadedArchive(), zmap: zmap())
        let character = try loader.load(skin: 0, faceID: 20000, equipment: [
            WzEquipItem(category: "Weapon", id: 1302000),
        ])
        let weapon = try XCTUnwrap(character.stand.frames[0].parts.first { $0.zLayer == "weapon" })
        XCTAssertEqual(weapon.anchor, .hand)   // hand map, no navel
    }

    func testMissingBodyThrows() throws {
        let loader = WzCharacterLoader(archive: try loadedArchive())
        XCTAssertThrowsError(try loader.load(skin: 99)) { error in
            guard case WzArchiveError.invalidHeader = error else { return XCTFail("\(error)") }
        }
    }

    func testEquipItemFromItemID() {
        XCTAssertEqual(WzEquipItem(itemID: 1002005)?.category, "Cap")
        XCTAssertEqual(WzEquipItem(itemID: 1012000)?.category, "Accessory")
        XCTAssertEqual(WzEquipItem(itemID: 1040002)?.category, "Coat")
        XCTAssertEqual(WzEquipItem(itemID: 1050000)?.category, "Longcoat")
        XCTAssertEqual(WzEquipItem(itemID: 1060002)?.category, "Pants")
        XCTAssertEqual(WzEquipItem(itemID: 1072001)?.category, "Shoes")
        XCTAssertEqual(WzEquipItem(itemID: 1082000)?.category, "Glove")
        XCTAssertEqual(WzEquipItem(itemID: 1092000)?.category, "Shield")
        XCTAssertEqual(WzEquipItem(itemID: 1102000)?.category, "Cape")
        XCTAssertEqual(WzEquipItem(itemID: 1302000)?.category, "Weapon")
        // A type without character sprites returns nil.
        XCTAssertNil(WzEquipItem(itemID: 2000000))
        // imagePath formatting.
        XCTAssertEqual(WzEquipItem(category: "Coat", id: 1040002).imagePath, "Coat/01040002.img")
    }
}
