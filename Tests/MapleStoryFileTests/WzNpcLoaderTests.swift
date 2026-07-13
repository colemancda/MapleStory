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

    private let npcPath = "/Volumes/[C] Windows 11/Nexon/MapleStory62/Npc.wz"

    func testLoadHenesysNpcs() throws {
        guard FileManager.default.fileExists(atPath: npcPath) else { throw XCTSkip("Npc.wz not mounted") }
        let data = try Data(contentsOf: URL(fileURLWithPath: npcPath))
        let wz = try WzArchive(data: data, mapleVersion: .gms)
        let loader = WzNpcLoader(archive: wz)

        // Maya, a Henesys fixture.
        let frames = try loader.loadStandFrames(npcID: 1012000)
        print("NPC 1012000 stand frames: \(frames.count)")
        XCTAssertFalse(frames.isEmpty)
        for frame in frames {
            XCTAssertEqual(frame.rgba.count, frame.width * frame.height * 4)
            XCTAssertGreaterThan(frame.delayMilliseconds, 0)
        }
    }
}
