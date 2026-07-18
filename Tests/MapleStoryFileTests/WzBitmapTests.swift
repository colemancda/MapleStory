//
//  WzBitmapTests.swift
//  MapleStoryFileTests
//
//  Bitmap decoding: decoded-size math, all supported pixel formats, the ListWz
//  chunked (dechunked) payload path, and error handling.
//

import XCTest
@testable import MapleStoryFile

final class WzBitmapTests: XCTestCase {

    private func zeroKey() throws -> WzMutableKey {
        try WzMutableKey(iv: WzMapleVersion.bms.initializationVector)
    }

    private func canvas(width: Int, height: Int, format: Int) -> WzCanvas {
        WzCanvas(width: width, height: height, format: format, scale: 0,
                 properties: [], dataOffset: 0, dataLength: 0)
    }

    // MARK: - decodedSize

    func testDecodedSize() throws {
        XCTAssertEqual(try WzBitmap.decodedSize(format: 1, width: 4, height: 3), 24)   // BGRA4444
        XCTAssertEqual(try WzBitmap.decodedSize(format: 2, width: 4, height: 3), 48)   // BGRA8888
        XCTAssertEqual(try WzBitmap.decodedSize(format: 257, width: 4, height: 3), 24) // ARGB1555
        XCTAssertEqual(try WzBitmap.decodedSize(format: 513, width: 4, height: 3), 24) // RGB565
    }

    func testDecodedSizeUnsupportedThrows() {
        XCTAssertThrowsError(try WzBitmap.decodedSize(format: 999, width: 1, height: 1)) { error in
            guard case WzBitmapError.unsupportedFormat(999) = error else {
                return XCTFail("expected unsupportedFormat, got \(error)")
            }
        }
    }

    // MARK: - Formats

    func testDecodeBGRA8888() throws {
        let raw: [UInt8] = [1, 2, 3, 4]   // B,G,R,A for one pixel
        let bitmap = try WzBitmap.decode(canvas: canvas(width: 1, height: 1, format: 2),
                                         compressed: WzFixtures.zlibStored(raw), key: try zeroKey())
        XCTAssertEqual(bitmap.rgba, [3, 2, 1, 4])
    }

    func testDecodeBGRA4444() throws {
        // lo = 0x21 -> B = expand4(1)=0x11, G = expand4(2)=0x22
        // hi = 0x43 -> R = expand4(3)=0x33, A = expand4(4)=0x44
        let raw: [UInt8] = [0x21, 0x43]
        let bitmap = try WzBitmap.decode(canvas: canvas(width: 1, height: 1, format: 1),
                                         compressed: WzFixtures.zlibStored(raw), key: try zeroKey())
        XCTAssertEqual(bitmap.rgba, [0x33, 0x22, 0x11, 0x44])
    }

    func testDecodeRGB565() throws {
        // value 0xFFFF -> full red/green/blue, opaque.
        let raw: [UInt8] = [0xFF, 0xFF]
        let bitmap = try WzBitmap.decode(canvas: canvas(width: 1, height: 1, format: 513),
                                         compressed: WzFixtures.zlibStored(raw), key: try zeroKey())
        XCTAssertEqual(bitmap.rgba, [255, 255, 255, 255])
    }

    func testDecodeARGB1555() throws {
        // value 0x0000 -> all channels zero, alpha bit 0 -> transparent.
        let transparent = try WzBitmap.decode(canvas: canvas(width: 1, height: 1, format: 257),
                                              compressed: WzFixtures.zlibStored([0x00, 0x00]), key: try zeroKey())
        XCTAssertEqual(transparent.rgba, [0, 0, 0, 0])
        // value 0x8000 -> alpha bit set -> opaque black.
        let opaque = try WzBitmap.decode(canvas: canvas(width: 1, height: 1, format: 257),
                                         compressed: WzFixtures.zlibStored([0x00, 0x80]), key: try zeroKey())
        XCTAssertEqual(opaque.rgba, [0, 0, 0, 255])
    }

    // MARK: - Dechunk (ListWz)

    func testDecodeDechunkedPayload() throws {
        // A non-standard-zlib payload: [Int32 length][XOR bytes]. Under the zero
        // key XOR is identity, so the chunk body is the zlib stream verbatim.
        let raw: [UInt8] = [9, 8, 7, 6]
        let zlib = WzFixtures.zlibStored(raw)
        let chunked = WzFixtures.int32LE(Int32(zlib.count)) + zlib
        XCTAssertNotEqual(chunked[0], 0x78, "must not look like a standard zlib header")
        let bitmap = try WzBitmap.decode(canvas: canvas(width: 1, height: 1, format: 2),
                                         compressed: chunked, key: try zeroKey())
        XCTAssertEqual(bitmap.rgba, [7, 8, 9, 6])
    }

    // MARK: - Errors

    func testDecodeTooShortThrows() throws {
        XCTAssertThrowsError(try WzBitmap.decode(canvas: canvas(width: 1, height: 1, format: 2),
                                                 compressed: [0x78], key: try zeroKey())) { error in
            guard case WzBitmapError.decompressionFailed = error else {
                return XCTFail("expected decompressionFailed, got \(error)")
            }
        }
    }

    func testDecodeUnsupportedFormatThrows() throws {
        XCTAssertThrowsError(try WzBitmap.decode(canvas: canvas(width: 1, height: 1, format: 42),
                                                 compressed: WzFixtures.zlibStored([0, 0, 0, 0]), key: try zeroKey())) { error in
            guard case WzBitmapError.unsupportedFormat(42) = error else {
                return XCTFail("expected unsupportedFormat, got \(error)")
            }
        }
    }

    func testDecodeTruncatedPixelsThrows() throws {
        // Format 2 needs 4 bytes for a 1x1 image; supply only 2 so inflate falls short.
        XCTAssertThrowsError(try WzBitmap.decode(canvas: canvas(width: 1, height: 1, format: 2),
                                                 compressed: WzFixtures.zlibStored([1, 2]), key: try zeroKey())) { error in
            guard case WzBitmapError.decompressionFailed = error else {
                return XCTFail("expected decompressionFailed, got \(error)")
            }
        }
    }
}
