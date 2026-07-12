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

        for frame in character.stand.frames {
            XCTAssertNotNil(frame.body, "expected a body part in every stand frame")
            XCTAssertNotNil(frame.arm, "expected an arm part in every stand frame")
            XCTAssertNotNil(frame.head, "expected a head part in every stand frame")
            XCTAssertNotNil(frame.face, "expected a face part in every stand frame")
        }

        let frame0 = character.stand.frames[0]
        let body = try XCTUnwrap(frame0.body)
        let arm = try XCTUnwrap(frame0.arm)
        let head = try XCTUnwrap(frame0.head)
        let face = try XCTUnwrap(frame0.face)

        print("body \(body.width)x\(body.height) origin=(\(body.originX),\(body.originY)) points=\(body.mapPoints)")
        print("arm \(arm.width)x\(arm.height) origin=(\(arm.originX),\(arm.originY)) points=\(arm.mapPoints)")
        print("head \(head.width)x\(head.height) origin=(\(head.originX),\(head.originY)) points=\(head.mapPoints)")
        print("face \(face.width)x\(face.height) origin=(\(face.originX),\(face.originY)) points=\(face.mapPoints)")

        XCTAssertEqual(body.rgba.count, body.width * body.height * 4)
        XCTAssertEqual(head.rgba.count, head.width * head.height * 4)
        XCTAssertNotNil(body.mapPoints["navel"])
        XCTAssertNotNil(body.mapPoints["neck"])
        XCTAssertNotNil(arm.mapPoints["navel"])
        XCTAssertNotNil(head.mapPoints["neck"])
        XCTAssertNotNil(face.mapPoints["brow"])
    }
}
