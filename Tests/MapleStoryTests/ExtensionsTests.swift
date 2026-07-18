//
//  ExtensionsTests.swift
//
//  Tests for internal helper extensions.
//

import Foundation
import XCTest
@testable import MapleStory

final class ExtensionsTests: XCTestCase {

    func testUInt16Bytes() {
        let value: UInt16 = 0x0201
        let bytes = value.bytes
        XCTAssertEqual(bytes.0, 0x01)
        XCTAssertEqual(bytes.1, 0x02)
        XCTAssertEqual(UInt16(bytes: bytes), value)
    }

    func testUInt32Bytes() {
        let value: UInt32 = 0x04030201
        let bytes = value.bytes
        XCTAssertEqual(bytes.0, 0x01)
        XCTAssertEqual(bytes.3, 0x04)
        XCTAssertEqual(UInt32(bytes: bytes), value)
    }

    func testInt32Bytes() {
        let value: Int32 = 0x04030201
        let bytes = value.bytes
        XCTAssertEqual(Int32(bytes: bytes), value)
    }

    func testUInt64Bytes() {
        let value: UInt64 = 0x0102030405060708
        let bytes = value.bytes
        XCTAssertEqual(UInt64(bytes: bytes), value)
    }

    func testToHexadecimalInteger() {
        XCTAssertEqual(UInt8(0x0A).toHexadecimal(), "0A")
        XCTAssertEqual(UInt16(0x00FF).toHexadecimal(), "00FF")
        XCTAssertEqual(UInt32(0xDEADBEEF).toHexadecimal(), "DEADBEEF")
    }

    func testToHexadecimalCollection() {
        let bytes: [UInt8] = [0x01, 0x02, 0xFF]
        XCTAssertEqual(bytes.toHexadecimal(), "0102FF")
        XCTAssertEqual(Data([0xAB, 0xCD]).toHexadecimal(), "ABCD")
    }

    func testHexStringDescription() {
        let bytes: [UInt8] = [0x01, 0x0A]
        XCTAssertEqual(bytes.hexString, "[0x01, 0x0A]")
        XCTAssertEqual([UInt8]().hexString, "[]")
    }

    func testArrayPopFirst() {
        var array = [1, 2, 3]
        XCTAssertEqual(array.popFirst(), 1)
        XCTAssertEqual(array, [2, 3])
        var empty: [Int] = []
        XCTAssertNil(empty.popFirst())
    }

    func testDataSubdataNoCopySmall() {
        // small data stored inline -> copied
        let data = Data([0x01, 0x02, 0x03, 0x04])
        let sub = data.subdataNoCopy(in: 1..<3)
        XCTAssertEqual(sub, Data([0x02, 0x03]))
    }

    func testDataSubdataNoCopyLarge() {
        // large data on heap -> no copy path
        let data = Data((0..<64).map { UInt8($0) })
        let sub = data.subdataNoCopy(in: 10..<20)
        XCTAssertEqual(Array(sub), Array(10..<20).map { UInt8($0) })
    }

    func testDataSuffixNoCopy() {
        let data = Data((0..<64).map { UInt8($0) })
        let suffix = data.suffixNoCopy(from: 60)
        XCTAssertEqual(Array(suffix), [60, 61, 62, 63])
    }

    func testDataConvertible() {
        let value: UInt32 = 0x04030201
        let data = Data(value)
        XCTAssertEqual(Array(data), [0x01, 0x02, 0x03, 0x04])
        XCTAssertEqual(value.dataLength, 4)

        var buffer = Data()
        buffer.append(UInt16(0x0201))
        XCTAssertEqual(Array(buffer), [0x01, 0x02])
    }

    func testCodingKeyPath() {
        struct Key: CodingKey {
            var stringValue: String
            var intValue: Int? { nil }
            init?(stringValue: String) { self.stringValue = stringValue }
            init?(intValue: Int) { nil }
            init(_ s: String) { self.stringValue = s }
        }
        let keys: [CodingKey] = [Key("a"), Key("b"), Key("c")]
        XCTAssertEqual(keys.path, "a.b.c")
        XCTAssertEqual([CodingKey]().path, "")
    }
}
