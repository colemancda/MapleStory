//
//  WzArchiveExtraTests.swift
//  MapleStoryFileTests
//
//  Archive header/version error paths and the on-demand accessors
//  (properties, soundData, decodeCanvas).
//

import XCTest
import Foundation
@testable import MapleStoryFile

final class WzArchiveExtraTests: XCTestCase {

    func testInvalidHeaderWhenFileStartTooSmall() {
        var bytes: [UInt8] = Array("PKG1".utf8)
        bytes += [UInt8](repeating: 0, count: 8)   // fileSize
        bytes += [0x08, 0x00, 0x00, 0x00]          // fileStart = 8 (< 17)
        XCTAssertThrowsError(try WzArchive(data: Data(bytes), mapleVersion: .bms)) { error in
            guard case WzArchiveError.invalidHeader = error else { return XCTFail("\(error)") }
        }
    }

    func testVersionDetectionFailed() {
        // Header with fileStart = 17 and an unreachable marker (> 0xFF), version = nil.
        var bytes: [UInt8] = Array("PKG1".utf8)
        bytes += [UInt8](repeating: 0, count: 8)
        bytes += [0x11, 0x00, 0x00, 0x00]          // fileStart = 17
        bytes += [0x00]                            // padding -> offset 17
        bytes += [0x00, 0x01]                      // marker = 0x0100 (unreachable)
        XCTAssertThrowsError(try WzArchive(data: Data(bytes), mapleVersion: .bms, version: nil)) { error in
            guard case WzArchiveError.versionDetectionFailed(let marker) = error else {
                return XCTFail("\(error)")
            }
            XCTAssertEqual(marker, 0x0100)
        }
    }

    func testVersionAutoDetection() throws {
        // Build with version 1 but let the archive brute-force it from the marker.
        let data = WzFixtures.buildArchive(images: [("a.img", WzFixtures.image([]))], version: 1)
        let archive = try WzArchive(data: data, mapleVersion: .bms, version: nil)
        XCTAssertEqual(WzVersion.encryptedVersion(fromHash: archive.versionHash),
                       WzVersion.encryptedVersion(fromHash: WzVersion.hash(forVersion: 1)))
    }

    func testPropertiesUnknownEntryType() throws {
        // An image whose payload does not begin with 0x73.
        let data = WzFixtures.buildArchive(images: [("bad.img", [0x42, 0x00, 0x00])])
        let archive = try WzArchive(data: data, mapleVersion: .bms, version: 1)
        let image = try XCTUnwrap(archive.root["bad.img"])
        XCTAssertThrowsError(try archive.properties(of: image)) { error in
            guard case WzArchiveError.unknownEntryType(0x42) = error else { return XCTFail("\(error)") }
        }
    }

    func testHeaderFields() throws {
        let data = WzFixtures.buildArchive(images: [("a.img", WzFixtures.image([]))], version: 1)
        let archive = try WzArchive(data: data, mapleVersion: .bms, version: 1)
        XCTAssertEqual(archive.header.ident, "PKG1")
        XCTAssertEqual(archive.header.fileStart, 17)
        XCTAssertEqual(archive.header.copyright, "")
        XCTAssertEqual(archive.mapleVersion, .bms)
        XCTAssertEqual(archive.version, 1)
    }

    func testSoundDataBounds() throws {
        let audio: [UInt8] = [0xDE, 0xAD, 0xBE, 0xEF]
        let data = WzFixtures.buildArchive(images: [("a.img", WzFixtures.image([
            WzFixtures.property("clip", WzFixtures.sound(audio: audio, duration: 100)),
        ]))])
        let archive = try WzArchive(data: data, mapleVersion: .bms, version: 1)
        let props = try archive.properties(of: try XCTUnwrap(archive.root["a.img"]))
        let sound = try XCTUnwrap(props["clip"]?.soundValue)
        XCTAssertEqual([UInt8](try XCTUnwrap(archive.soundData(sound))), audio)

        // A zero-length sound yields nil.
        let empty = WzSound(dataOffset: 0, dataLength: 0, durationMilliseconds: 0)
        XCTAssertNil(archive.soundData(empty))
        // An out-of-range sound yields nil.
        let oob = WzSound(dataOffset: 10, dataLength: 1_000_000, durationMilliseconds: 0)
        XCTAssertNil(archive.soundData(oob))
    }

    func testDecodeCanvasOutOfBoundsThrows() throws {
        let archive = try WzArchive(data: WzFixtures.buildArchive(images: [("a.img", WzFixtures.image([]))]),
                                    mapleVersion: .bms, version: 1)
        let bogus = WzCanvas(width: 1, height: 1, format: 2, scale: 0, properties: [],
                             dataOffset: 999_999, dataLength: 16)
        XCTAssertThrowsError(try archive.decodeCanvas(bogus)) { error in
            guard case WzBitmapError.decompressionFailed = error else { return XCTFail("\(error)") }
        }
    }
}
