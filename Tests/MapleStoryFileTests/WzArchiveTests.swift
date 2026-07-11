//
//  WzArchiveTests.swift
//  MapleStoryFileTests
//

import XCTest
@testable import MapleStoryFile

final class WzArchiveTests: XCTestCase {

    /// Encode a 4-byte entry offset the way ``WzReader/readOffset()`` decodes it.
    private func encodeOffset(_ desired: UInt32, at position: Int, fileStart: UInt32, hash: UInt32) -> [UInt8] {
        var x = (UInt32(truncatingIfNeeded: position) &- fileStart) ^ 0xFFFF_FFFF
        x = x &* hash
        x = x &- 0x581C_3F6D
        x = WzVersion.rotateLeft(x, x & 0x1F)
        let encrypted = x ^ (desired &- (fileStart &* 2))
        return [
            UInt8(encrypted & 0xFF),
            UInt8((encrypted >> 8) & 0xFF),
            UInt8((encrypted >> 16) & 0xFF),
            UInt8((encrypted >> 24) & 0xFF),
        ]
    }

    /// Build a minimal single-image WZ archive (BMS / zero key) and parse it.
    func testParsesSyntheticArchive() throws {
        let version = 1
        let hash = WzVersion.hash(forVersion: version)          // 50
        let fileStart: UInt32 = 17

        var bytes: [UInt8] = []
        bytes += Array("PKG1".utf8)                              // 0..3  ident
        bytes += [UInt8](repeating: 0, count: 8)                // 4..11 fileSize
        bytes += [0x11, 0x00, 0x00, 0x00]                       // 12..15 fileStart = 17
        bytes += [0x00]                                          // 16 padding (copyright is empty)
        // 17..18 encrypted-version marker (unused since we pass version explicitly)
        let marker = WzVersion.encryptedVersion(fromHash: hash)
        bytes += [UInt8(marker & 0xFF), UInt8((marker >> 8) & 0xFF)]
        // 19.. root directory
        bytes += [0x01]                                          // entryCount = 1
        bytes += [0x04]                                          // type = image
        bytes += [0xFF, 0xCB]                                    // name "a": flag -1, 'a'^0xAA
        bytes += [0x00]                                          // size = 0
        bytes += [0x00]                                          // checksum = 0
        let offsetPosition = bytes.count                         // where the offset field starts
        let desiredOffset: UInt32 = 40
        bytes += encodeOffset(desiredOffset, at: offsetPosition, fileStart: fileStart, hash: hash)

        let archive = try WzArchive(data: Data(bytes), mapleVersion: .bms, version: version)

        XCTAssertEqual(archive.header.ident, "PKG1")
        XCTAssertEqual(archive.header.fileStart, 17)
        XCTAssertEqual(archive.version, 1)
        XCTAssertEqual(archive.root.subdirectories.count, 0)
        XCTAssertEqual(archive.root.images.count, 1)
        XCTAssertEqual(archive.root.images.first?.name, "a")
        XCTAssertEqual(archive.root.images.first?.offset, desiredOffset)
        XCTAssertNotNil(archive.root["a"])
    }
}
