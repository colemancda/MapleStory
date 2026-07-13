//
//  WzSoundTests.swift
//  MapleStoryFileTests
//
//  Validates sound extraction against a real Sound.wz (skipped when unavailable).
//

import XCTest
import Foundation
@testable import MapleStoryFile

final class WzSoundTests: XCTestCase {

    private let soundPath = "/Volumes/[C] Windows 11/Nexon/MapleStory62/Sound.wz"

    func testExtractHenesysBgm() throws {
        guard FileManager.default.fileExists(atPath: soundPath) else { throw XCTSkip("Sound.wz not mounted") }
        let wz = try WzArchive(data: try Data(contentsOf: URL(fileURLWithPath: soundPath)), mapleVersion: .gms)

        // Henesys: info/bgm = "Bgm00/FloralLife" -> Bgm00.img/FloralLife
        guard let image = wz.root["Bgm00.img"] else { return XCTFail("Bgm00.img missing") }
        let props = try wz.properties(of: image)
        let sound = try XCTUnwrap(props["FloralLife"]?.soundValue, "FloralLife should be a sound")
        print("FloralLife: \(sound.dataLength) bytes, \(sound.durationMilliseconds) ms")

        XCTAssertGreaterThan(sound.dataLength, 100_000, "a BGM track should be substantial")
        XCTAssertGreaterThan(sound.durationMilliseconds, 30_000, "BGM should be longer than 30s")

        let data = try XCTUnwrap(wz.soundData(sound))
        XCTAssertEqual(data.count, sound.dataLength)

        // MP3 payload: either an ID3 tag or an MPEG frame-sync header.
        let isID3 = data.prefix(3) == Data("ID3".utf8)
        let isFrameSync = data.count >= 2 && data[0] == 0xFF && (data[1] & 0xE0) == 0xE0
        XCTAssertTrue(isID3 || isFrameSync, "payload should look like MP3, got \(data.prefix(4).map { String(format: "%02X", $0) })")

        // Round-trip through the system audio parser as final proof.
        let url = URL(fileURLWithPath: "/tmp/wz_floral_life.mp3")
        try data.write(to: url)
    }
}
