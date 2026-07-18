//
//  WzReaderExtraTests.swift
//  MapleStoryFileTests
//
//  Primitive decoding, cursor management, compressed longs, Unicode/ASCII string
//  variants, string blocks (inline + back-reference), and out-of-bounds errors.
//

import XCTest
@testable import MapleStoryFile

final class WzReaderExtraTests: XCTestCase {

    private func reader(_ bytes: [UInt8]) throws -> WzReader {
        WzReader(data: bytes, key: try WzMutableKey(iv: WzMapleVersion.bms.initializationVector))
    }

    func testSignedPrimitives() throws {
        let r = try reader([0xFF, 0xFE, 0xFF])
        XCTAssertEqual(try r.readInt8(), -1)
        XCTAssertEqual(try r.readInt16(), -2)
    }

    func testInt32AndInt64() throws {
        let r = try reader(WzFixtures.int32LE(-2) + WzFixtures.int64LE(-3))
        XCTAssertEqual(try r.readInt32(), -2)
        XCTAssertEqual(try r.readInt64(), -3)
    }

    func testUInt64AndFloatAndDouble() throws {
        let r = try reader(WzFixtures.int64LE(Int64(bitPattern: 0x1122_3344_5566_7788))
                           + WzFixtures.floatLE(1.5) + WzFixtures.doubleLE(-2.25))
        XCTAssertEqual(try r.readUInt64(), 0x1122_3344_5566_7788)
        XCTAssertEqual(try r.readFloat(), 1.5)
        XCTAssertEqual(try r.readDouble(), -2.25)
    }

    func testRawString() throws {
        let r = try reader(Array("PKG1extra".utf8))
        XCTAssertEqual(try r.readRawString(length: 4), "PKG1")
        XCTAssertEqual(r.position, 4)
        XCTAssertThrowsError(try r.readRawString(length: 100)) { error in
            guard case WzReaderError.outOfBounds = error else { return XCTFail("\(error)") }
        }
    }

    func testCompressedLong() throws {
        XCTAssertEqual(try reader([0x07]).readCompressedLong(), 7)
        XCTAssertEqual(try reader([UInt8(bitPattern: -9)]).readCompressedLong(), -9)
        let big = try reader([0x80] + WzFixtures.int64LE(9_000_000_000))
        XCTAssertEqual(try big.readCompressedLong(), 9_000_000_000)
    }

    func testCompressedIntEscape() throws {
        let r = try reader([0x80] + WzFixtures.int32LE(-100_000))
        XCTAssertEqual(try r.readCompressedInt(), -100_000)
    }

    func testUnicodeWzString() throws {
        // Positive flag -> Unicode. Build "Hi" under the zero keystream:
        // char ^= 0xAAAA (mask, incrementing); key contributes nothing.
        let scalars: [UInt16] = Array("Hi".utf16)
        var bytes: [UInt8] = [0x02]     // flag = +2 (length)
        var mask: UInt16 = 0xAAAA
        for unit in scalars {
            let enc = unit ^ mask
            bytes += [UInt8(enc & 0xFF), UInt8((enc >> 8) & 0xFF)]
            mask = mask &+ 1
        }
        XCTAssertEqual(try reader(bytes).readWzString(), "Hi")
    }

    func testUnicodeWzStringWithLengthEscape() throws {
        // Positive flag == Int8.max -> length is a following Int32.
        let text = "ABCDEFG"   // 7 chars, still small but forces the Int32 length path
        let scalars: [UInt16] = Array(text.utf16)
        var bytes: [UInt8] = [0x7F] + WzFixtures.int32LE(Int32(scalars.count))
        var mask: UInt16 = 0xAAAA
        for unit in scalars {
            let enc = unit ^ mask
            bytes += [UInt8(enc & 0xFF), UInt8((enc >> 8) & 0xFF)]
            mask = mask &+ 1
        }
        XCTAssertEqual(try reader(bytes).readWzString(), text)
    }

    func testAsciiWzStringWithLengthEscape() throws {
        // Negative flag == Int8.min -> length is a following Int32.
        let text = "abcd"
        var bytes: [UInt8] = [0x80] + WzFixtures.int32LE(Int32(text.utf8.count))
        var mask: UInt8 = 0xAA
        for byte in text.utf8 {
            bytes.append(byte ^ mask)
            mask = mask &+ 1
        }
        XCTAssertEqual(try reader(bytes).readWzString(), text)
    }

    func testStringBlockInlineAndInvalid() throws {
        // 0x00 inline.
        XCTAssertEqual(try reader(WzFixtures.stringBlock("hey")).readStringBlock(base: 0), "hey")
        // 0x73 inline (alternate tag).
        XCTAssertEqual(try reader([0x73] + WzFixtures.wzString("yo")).readStringBlock(base: 0), "yo")
        // Unknown tag throws.
        XCTAssertThrowsError(try reader([0x55, 0x00]).readStringBlock(base: 0)) { error in
            guard case WzReaderError.invalidStringBlock(0x55) = error else { return XCTFail("\(error)") }
        }
    }

    func testStringBlockBackReference() throws {
        // Layout: [tag 0x01][Int32 offset] ... [wzString at base+offset].
        let target = WzFixtures.wzString("shared")
        let offset = 6
        var bytes: [UInt8] = [0x01] + WzFixtures.int32LE(Int32(offset))
        while bytes.count < offset { bytes.append(0) }
        bytes += target
        let r = try reader(bytes)
        XCTAssertEqual(try r.readStringBlock(base: 0), "shared")
        // Cursor is restored to just after the offset field (position 5).
        XCTAssertEqual(r.position, 5)
    }

    func testCursorHelpers() throws {
        let r = try reader([0, 1, 2, 3, 4, 5])
        XCTAssertEqual(r.remaining, 6)
        r.seek(to: 2)
        XCTAssertEqual(r.position, 2)
        r.skip(2)
        XCTAssertEqual(r.position, 4)
        XCTAssertEqual(r.remaining, 2)
    }

    func testReadPastEndThrows() throws {
        let r = try reader([0x01])
        _ = try r.readUInt8()
        XCTAssertThrowsError(try r.readUInt8()) { error in
            guard case WzReaderError.outOfBounds = error else { return XCTFail("\(error)") }
        }
    }
}
