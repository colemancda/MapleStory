//
//  WzCharacterLoaderTests.swift
//  MapleStoryFileTests
//
//  Validates character loading against a real Character.wz (skipped when
//  unavailable).
//

import XCTest
import Foundation
@testable import MapleStoryFile

final class WzCharacterLoaderTests: XCTestCase {

    private let charPath = "/Volumes/[C] Windows 11/Nexon/MapleStory62/Character.wz"

    func testLoadDefaultCharacter() throws {
        guard FileManager.default.fileExists(atPath: charPath) else { throw XCTSkip("Character.wz not mounted") }
        let data = try Data(contentsOf: URL(fileURLWithPath: charPath))
        let wz = try WzArchive(data: data, mapleVersion: .gms)
        let loader = WzCharacterLoader(archive: wz)
        let character = try loader.load(skin: 0, faceID: 20000)

        print("stand1 frames: \(character.stand.frames.count); walk1 frames: \(character.walk.frames.count)")
        XCTAssertFalse(character.stand.frames.isEmpty)
        XCTAssertFalse(character.walk.frames.isEmpty)

        func part(_ frame: WzCharacterFrame, zLayer: String) -> WzCharacterPart? {
            frame.parts.first { $0.zLayer == zLayer }
        }
        for frame in character.stand.frames {
            XCTAssertNotNil(part(frame, zLayer: "body"), "expected a body part in every stand frame")
            XCTAssertNotNil(part(frame, zLayer: "arm"), "expected an arm part in every stand frame")
            XCTAssertNotNil(part(frame, zLayer: "head"), "expected a head part in every stand frame")
            XCTAssertNotNil(part(frame, zLayer: "face"), "expected a face part in every stand frame")
        }

        let frame0 = character.stand.frames[0]
        let body = try XCTUnwrap(part(frame0, zLayer: "body"))
        let arm = try XCTUnwrap(part(frame0, zLayer: "arm"))
        let head = try XCTUnwrap(part(frame0, zLayer: "head"))
        let face = try XCTUnwrap(part(frame0, zLayer: "face"))

        print("body \(body.width)x\(body.height) origin=(\(body.originX),\(body.originY)) points=\(body.mapPoints)")
        print("head \(head.width)x\(head.height) points=\(head.mapPoints)")

        XCTAssertEqual(body.rgba.count, body.width * body.height * 4)
        XCTAssertEqual(head.rgba.count, head.width * head.height * 4)
        XCTAssertEqual(body.anchor, .root)
        XCTAssertEqual(head.anchor, .neck)
        XCTAssertEqual(face.anchor, .brow)
        XCTAssertNotNil(body.mapPoints["navel"])
        XCTAssertNotNil(body.mapPoints["neck"])
        XCTAssertNotNil(arm.mapPoints["navel"])
        XCTAssertNotNil(head.mapPoints["neck"])
        XCTAssertNotNil(face.mapPoints["brow"])

        // Parts must be z-sorted back-to-front: body behind, hair/face in front.
        let bodyIndex = try XCTUnwrap(frame0.parts.firstIndex { $0.zLayer == "body" })
        let faceIndex = try XCTUnwrap(frame0.parts.firstIndex { $0.zLayer == "face" })
        XCTAssertLessThan(bodyIndex, faceIndex, "body should draw before (behind) the face")
    }

    func testLoadCharacterWithEquipment() throws {
        guard FileManager.default.fileExists(atPath: charPath) else { throw XCTSkip("Character.wz not mounted") }
        let basePath = "/Volumes/[C] Windows 11/Nexon/MapleStory62/Base.wz"
        guard FileManager.default.fileExists(atPath: basePath) else { throw XCTSkip("Base.wz not mounted") }

        let wz = try WzArchive(data: try Data(contentsOf: URL(fileURLWithPath: charPath)), mapleVersion: .gms)
        let baseWz = try WzArchive(data: try Data(contentsOf: URL(fileURLWithPath: basePath)), mapleVersion: .gms)
        let zmap = try WzZmap.load(from: baseWz)
        XCTAssertGreaterThan(zmap.order.count, 100)
        XCTAssertNotNil(zmap.order["body"])
        // Body draws behind hair (higher zmap index).
        XCTAssertGreaterThan(zmap.priority(of: "body"), zmap.priority(of: "hair"))

        let loader = WzCharacterLoader(archive: wz, zmap: zmap)
        let equipment = [
            WzEquipItem(category: "Coat", id: 1040002),
            WzEquipItem(category: "Pants", id: 1060002),
            WzEquipItem(category: "Shoes", id: 1072001),
            WzEquipItem(category: "Hair", id: 30030),
        ]
        let character = try loader.load(equipment: equipment)
        let frame0 = character.stand.frames[0]
        let layers = Set(frame0.parts.map(\.zLayer))
        print("equipped stand1/0 layers: \(frame0.parts.map(\.zLayer))")
        XCTAssertTrue(layers.contains("pants"))
        XCTAssertTrue(layers.contains("shoes"))
        XCTAssertTrue(layers.contains("hair"))
        XCTAssertTrue(layers.contains("mailChest") || layers.contains("mail"))

        // Parts stay sorted back-to-front by zmap priority.
        let priorities = frame0.parts.map { zmap.priority(of: $0.zLayer) }
        XCTAssertEqual(priorities, priorities.sorted(by: >), "parts should be z-sorted back-to-front")
    }
}
