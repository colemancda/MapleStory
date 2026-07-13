//
//  WzReaderTests.swift
//  MapleStoryFileTests
//

import XCTest
@testable import MapleStoryFile

final class WzReaderTests: XCTestCase {

    private func reader(_ bytes: [UInt8], version: WzMapleVersion = .bms) throws -> WzReader {
        let key = try WzMutableKey(iv: version.initializationVector)
        return WzReader(data: bytes, key: key)
    }

    func testLittleEndianPrimitives() throws {
        let r = try reader([0x01, 0x00, 0x00, 0x00, 0x34, 0x12])
        XCTAssertEqual(try r.readUInt32(), 1)
        XCTAssertEqual(try r.readUInt16(), 0x1234)
    }

    func testCompressedInt() throws {
        // Small value in one byte.
        XCTAssertEqual(try reader([0x05]).readCompressedInt(), 5)
        // Negative small value.
        XCTAssertEqual(try reader([UInt8(bitPattern: -5)]).readCompressedInt(), -5)
        // Escape byte (-128) then full Int32 = 1000 (0x000003E8).
        let big = try reader([0x80, 0xE8, 0x03, 0x00, 0x00])
        XCTAssertEqual(try big.readCompressedInt(), 1000)
    }

    func testDecodeAsciiWzString() throws {
        // "OK" under a zero (BMS) keystream:
        //   flag = -2 (0xFE); 'O'^0xAA=0xE5; 'K'^0xAB=0xE0
        let r = try reader([0xFE, 0xE5, 0xE0])
        XCTAssertEqual(try r.readWzString(), "OK")
    }

    func testEmptyWzString() throws {
        XCTAssertEqual(try reader([0x00]).readWzString(), "")
    }
}
