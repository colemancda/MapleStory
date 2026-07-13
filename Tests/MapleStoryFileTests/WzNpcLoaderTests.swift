//
//  WzNpcLoaderTests.swift
//  MapleStoryFileTests
//
//  Validates NPC loading against a real Npc.wz (skipped when unavailable).
//

import XCTest
import Foundation
@testable import MapleStoryFile

final class WzNpcLoaderTests: XCTestCase {

    private let base = "/Volumes/[C] Windows 11/Nexon/MapleStory62"

    func testLoadHenesysNpcs() throws {
        let npcPath = "\(base)/Npc.wz"
        guard FileManager.default.fileExists(atPath: npcPath) else { throw XCTSkip("Npc.wz not mounted") }
        let data = try Data(contentsOf: URL(fileURLWithPath: npcPath))
        let wz = try WzArchive(data: data, mapleVersion: .gms)
        let loader = WzLifeSpriteLoader(archive: wz)

        // Maya, a Henesys fixture.
        let frames = try loader.loadStandFrames(id: 1012000)
        print("NPC 1012000 stand frames: \(frames.count)")
        XCTAssertFalse(frames.isEmpty)
        for frame in frames {
            XCTAssertEqual(frame.rgba.count, frame.width * frame.height * 4)
            XCTAssertGreaterThan(frame.delayMilliseconds, 0)
        }
    }

    func testLoadMobSprites() throws {
        let mobPath = "\(base)/Mob.wz"
        guard FileManager.default.fileExists(atPath: mobPath) else { throw XCTSkip("Mob.wz not mounted") }
        let data = try Data(contentsOf: URL(fileURLWithPath: mobPath))
        let wz = try WzArchive(data: data, mapleVersion: .gms)
        let loader = WzLifeSpriteLoader(archive: wz)

        // Blue Snail (0100101), a Henesys Hunting Ground I spawn.
        let frames = try loader.loadStandFrames(id: 100101)
        print("Mob 0100101 stand frames: \(frames.count)")
        XCTAssertFalse(frames.isEmpty)
        for frame in frames {
            XCTAssertEqual(frame.rgba.count, frame.width * frame.height * 4)
        }
    }
}
