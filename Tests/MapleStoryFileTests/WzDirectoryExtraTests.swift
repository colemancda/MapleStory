//
//  WzDirectoryExtraTests.swift
//  MapleStoryFileTests
//
//  Directory-tree parsing: subdirectory recursion, nested path lookup, and the
//  entry-count / entry-type error paths.
//

import XCTest
import Foundation
@testable import MapleStoryFile

final class WzDirectoryExtraTests: XCTestCase {

    private let versionHash = WzVersion.hash(forVersion: 1)
    private let fileStart: UInt32 = 17

    /// Header (17 bytes) + version marker, ready for a root directory body.
    private func headerAndMarker() -> [UInt8] {
        var header: [UInt8] = Array("PKG1".utf8)
        header += [UInt8](repeating: 0, count: 8)
        header += [0x11, 0x00, 0x00, 0x00]
        header += [0x00]
        let marker = WzVersion.encryptedVersion(fromHash: versionHash)
        header += [UInt8(marker & 0xFF), UInt8((marker >> 8) & 0xFF)]
        return header
    }

    private func offset(_ desired: Int, fieldStart: Int) -> [UInt8] {
        WzFixtures.encodeOffset(UInt32(desired), at: fieldStart, fileStart: fileStart, hash: versionHash)
    }

    // A root directory holding one subdirectory that holds one image.
    private func archiveWithSubdirectory() throws -> WzArchive {
        var bytes = headerAndMarker()
        // Root directory: 1 entry (a subdirectory).
        bytes += WzFixtures.compressedInt(1)
        bytes += [0x03]                                   // EntryType.directory
        bytes += WzFixtures.wzString("sub")
        bytes += WzFixtures.compressedInt(0)              // size
        bytes += WzFixtures.compressedInt(0)              // checksum
        let dirOffsetField = bytes.count
        bytes += [0, 0, 0, 0]                             // subdir offset placeholder

        // Subdirectory listing.
        let subOffset = bytes.count
        bytes += WzFixtures.compressedInt(1)
        bytes += [0x04]                                   // EntryType.image
        bytes += WzFixtures.wzString("leaf.img")
        bytes += WzFixtures.compressedInt(0)
        bytes += WzFixtures.compressedInt(0)
        let imgOffsetField = bytes.count
        bytes += [0, 0, 0, 0]                             // image offset placeholder

        // Image payload.
        let imgOffset = bytes.count
        bytes += WzFixtures.image([WzFixtures.property("v", WzFixtures.int32(5))])

        // Patch offsets.
        let dirEnc = offset(subOffset, fieldStart: dirOffsetField)
        for i in 0 ..< 4 { bytes[dirOffsetField + i] = dirEnc[i] }
        let imgEnc = offset(imgOffset, fieldStart: imgOffsetField)
        for i in 0 ..< 4 { bytes[imgOffsetField + i] = imgEnc[i] }

        return try WzArchive(data: Data(bytes), mapleVersion: .bms, version: 1)
    }

    func testSubdirectoryRecursionAndPathLookup() throws {
        let archive = try archiveWithSubdirectory()
        XCTAssertEqual(archive.root.subdirectories.count, 1)
        XCTAssertEqual(archive.root.subdirectories.first?.name, "sub")
        XCTAssertEqual(archive.root.subdirectories.first?.images.count, 1)

        // Nested subscript path.
        let image = try XCTUnwrap(archive.root["sub/leaf.img"])
        XCTAssertEqual(image.name, "leaf.img")
        let props = try archive.properties(of: image)
        XCTAssertEqual(props.int("v"), 5)

        // Missing paths.
        XCTAssertNil(archive.root["sub/missing.img"])
        XCTAssertNil(archive.root["nope/leaf.img"])
        XCTAssertNil(archive.root[""])
    }

    func testInvalidEntryCount() {
        var bytes = headerAndMarker()
        bytes += WzFixtures.compressedInt(-1)   // negative entry count
        XCTAssertThrowsError(try WzArchive(data: Data(bytes), mapleVersion: .bms, version: 1)) { error in
            guard case WzArchiveError.invalidEntryCount(-1) = error else { return XCTFail("\(error)") }
        }
    }

    func testUnknownEntryType() {
        var bytes = headerAndMarker()
        bytes += WzFixtures.compressedInt(1)
        bytes += [0x09]                          // not a valid EntryType
        XCTAssertThrowsError(try WzArchive(data: Data(bytes), mapleVersion: .bms, version: 1)) { error in
            guard case WzArchiveError.unknownEntryType(0x09) = error else { return XCTFail("\(error)") }
        }
    }

    func testDirectSubscript() throws {
        let archive = try WzArchive(
            data: WzFixtures.buildArchive(images: [("one.img", WzFixtures.image([])),
                                                   ("two.img", WzFixtures.image([]))]),
            mapleVersion: .bms, version: 1)
        XCTAssertEqual(archive.root.images.count, 2)
        XCTAssertNotNil(archive.root["one.img"])
        XCTAssertNotNil(archive.root["two.img"])
        XCTAssertNil(archive.root["three.img"])
    }
}
