//
//  CodableTests.swift
//
//  Round-trip tests exercising MapleStoryEncoder / MapleStoryDecoder paths.
//

import Foundation
import XCTest
@testable import MapleStory

private struct Nested: Codable, Equatable {
    var x: UInt8
    var y: UInt8
}

private struct AllTypes: Codable, Equatable {
    var flag: Bool
    var i8: Int8
    var i16: Int16
    var i32: Int32
    var i64: Int64
    var i: Int
    var u8: UInt8
    var u16: UInt16
    var u32: UInt32
    var u64: UInt64
    var u: UInt
    var f: Float
    var d: Double
    var text: String
    var blob: Data
    var list: [UInt16]
    var nested: Nested
    var present: UInt32?
}

final class CodableTests: XCTestCase {

    func testAllTypesRoundTrip() throws {
        let value = AllTypes(
            flag: true,
            i8: -5, i16: -300, i32: -70000, i64: -5_000_000_000,
            i: 12345,
            u8: 200, u16: 40000, u32: 3_000_000_000, u64: 9_000_000_000_000,
            u: 54321,
            f: 3.5, d: 2.718281828,
            text: "MapleStory",
            blob: Data([0xDE, 0xAD, 0xBE, 0xEF]),
            list: [1, 2, 3, 4, 5],
            nested: Nested(x: 1, y: 2),
            present: 42
        )
        XCTAssertMapleRoundTrip(value)
    }

    func testEmptyStringAndBlob() throws {
        let value = AllTypes(
            flag: false,
            i8: 0, i16: 0, i32: 0, i64: 0, i: 0,
            u8: 0, u16: 0, u32: 0, u64: 0, u: 0,
            f: 0, d: 0,
            text: "",
            blob: Data(),
            list: [],
            nested: Nested(x: 0, y: 0),
            present: 0
        )
        XCTAssertMapleRoundTrip(value)
    }

    func testTopLevelArray() throws {
        let encoder = MapleStoryEncoder()
        let decoder = MapleStoryDecoder()
        let value: [UInt32] = [10, 20, 30]
        let data = try encoder.encode(value)
        let decoded = try decoder.decode([UInt32].self, from: data)
        XCTAssertEqual(decoded, value)
    }

    func testEnumSingleValueRoundTrip() throws {
        // Enums with raw values encode through a single value container.
        for gender in Gender.allCases {
            XCTAssertMapleRoundTrip(gender)
        }
        for skin in SkinColor.allCases {
            XCTAssertMapleRoundTrip(skin)
        }
        for status in ServerMessageType.allCases {
            XCTAssertMapleRoundTrip(status)
        }
        for job in Job.allCases {
            XCTAssertMapleRoundTrip(job)
        }
    }

    func testRawRepresentableStructRoundTrip() throws {
        XCTAssertMapleRoundTrip(Version.v62)
        XCTAssertMapleRoundTrip(Region.global)
        XCTAssertMapleRoundTrip(Experience(rawValue: 123456))
        XCTAssertMapleRoundTrip(Hair.buzz(.black))
        XCTAssertMapleRoundTrip(Item.ID.whitePotion)
        XCTAssertMapleRoundTrip(Map.ID.henesys)
    }

    func testKeyBindingRoundTrip() throws {
        XCTAssertMapleRoundTrip(KeyBinding(type: 4, action: 1000))
    }

    func testLoggingClosures() throws {
        var encoder = MapleStoryEncoder()
        var decoder = MapleStoryDecoder()
        var logs: [String] = []
        encoder.log = { logs.append($0) }
        decoder.log = { logs.append($0) }
        let value = Nested(x: 9, y: 8)
        let data = try encoder.encode(value)
        let decoded = try decoder.decode(Nested.self, from: data)
        XCTAssertEqual(decoded, value)
        XCTAssertFalse(logs.isEmpty)
    }

    func testDecodeInvalidStringThrows() {
        let decoder = MapleStoryDecoder()
        // Length prefix claims 10 bytes but data is short.
        let data = Data([0x0A, 0x00, 0x41])
        XCTAssertThrowsError(try decoder.decode(StringWrapper.self, from: data))
    }

    func testTopLevelPrimitives() throws {
        let encoder = MapleStoryEncoder()
        let decoder = MapleStoryDecoder()
        func roundTrip<T: Codable & Equatable>(_ value: T) throws {
            let data = try encoder.encode(value)
            let decoded = try decoder.decode(T.self, from: data)
            XCTAssertEqual(decoded, value)
        }
        try roundTrip(true)
        try roundTrip(false)
        try roundTrip(Int8(-12))
        try roundTrip(Int16(-1234))
        try roundTrip(Int32(-123456))
        try roundTrip(Int64(-1_234_567_890))
        try roundTrip(Int(999))
        try roundTrip(UInt8(240))
        try roundTrip(UInt16(60000))
        try roundTrip(UInt32(4_000_000_000))
        try roundTrip(UInt64(18_000_000_000_000))
        try roundTrip(UInt(888))
        try roundTrip(Float(1.5))
        try roundTrip(Double(3.14159))
        try roundTrip("hello world")
    }

    func testTopLevelPrimitiveArrays() throws {
        let encoder = MapleStoryEncoder()
        let decoder = MapleStoryDecoder()
        func roundTrip<T: Codable & Equatable>(_ value: [T]) throws {
            let data = try encoder.encode(value)
            let decoded = try decoder.decode([T].self, from: data)
            XCTAssertEqual(decoded, value)
        }
        try roundTrip([Int8(-1), Int8(2), Int8(-3)])
        try roundTrip([UInt8(1), UInt8(2)])
        try roundTrip([Int16(-100), Int16(200)])
        try roundTrip([UInt32(10), UInt32(20), UInt32(30)])
        try roundTrip([Int64(-5), Int64(5)])
        try roundTrip(["a", "bb", "ccc"])
        try roundTrip([Float(1.5), Float(2.5)])
        try roundTrip([Double(1.5), Double(2.5)])
        try roundTrip([true, false, true])
    }

    func testUserInfo() throws {
        var encoder = MapleStoryEncoder()
        encoder.userInfo[CodingUserInfoKey(rawValue: "test")!] = "value"
        var decoder = MapleStoryDecoder()
        decoder.userInfo[CodingUserInfoKey(rawValue: "test")!] = "value"
        let value = Nested(x: 1, y: 2)
        let data = try encoder.encode(value)
        let decoded = try decoder.decode(Nested.self, from: data)
        XCTAssertEqual(decoded, value)
    }
}

private struct StringWrapper: Codable, Equatable {
    var text: String
}

// MARK: - Custom container coverage

private struct Wrapped: Codable, Equatable {
    var a: UInt16
    var b: UInt16
}

private struct CustomCodable: MapleStoryCodable, Equatable {

    var flag: Bool
    var i8: Int8
    var u8: UInt8
    var bigU16: UInt16
    var littleI32: Int32
    var i16: Int16
    var i64: Int64
    var u64: UInt64
    var f: Float
    var d: Double
    var fixed: String
    var charName: CharacterName
    var ascii: String
    var blob: Data
    var nested: Wrapped
    var items: [UInt16]

    enum FieldKey: String, CodingKey {
        case nested
        case items
    }

    func encode(to container: MapleStoryEncodingContainer) throws {
        _ = container.codingPath
        try container.encode(flag)
        try container.encode(i8)
        try container.encode(u8)
        try container.encode(bigU16, isLittleEndian: false)
        try container.encode(littleI32, isLittleEndian: true)
        try container.encode(i16, isLittleEndian: true)
        try container.encode(i64, isLittleEndian: true)
        try container.encode(u64, isLittleEndian: true)
        try container.encode(f, isLittleEndian: true)
        try container.encode(d, isLittleEndian: true)
        try container.encode(fixed, fixedLength: 6)
        try container.encode(charName)          // FixedLengthString overload
        try container.encode(ascii)             // maple ascii (length-prefixed)
        try container.encode(blob)              // raw bytes
        try container.encode(nested, forKey: FieldKey.nested)
        try container.encode(UInt8(items.count))
        try container.encodeArray(items, forKey: FieldKey.items)
        _ = container.count
    }

    init(from container: MapleStoryDecodingContainer) throws {
        _ = container.remainingBytes
        _ = try container.peek(1) { (data: Data) -> UInt8 in data.first ?? 0 }
        _ = try container.peek(1) { (data: Data) -> UInt8? in data.first }
        flag = try container.decode(Bool.self)
        i8 = try container.decode(Int8.self)
        _ = container.peek() // does not advance
        u8 = try container.decode(UInt8.self)
        bigU16 = try container.decode(UInt16.self, isLittleEndian: false)
        littleI32 = try container.decode(Int32.self, isLittleEndian: true)
        i16 = try container.decode(Int16.self, isLittleEndian: true)
        i64 = try container.decode(Int64.self, isLittleEndian: true)
        u64 = try container.decode(UInt64.self, isLittleEndian: true)
        f = try container.decode(Float.self, isLittleEndian: true)
        d = try container.decode(Double.self, isLittleEndian: true)
        fixed = try container.decode(length: 6, map: { (data: Data) -> String? in
            let trimmed = Array(data.reversed().drop(while: { $0 == 0 }).reversed())
            return String(bytes: trimmed, encoding: .ascii)
        })
        charName = try container.decode(CharacterName.self)
        let asciiLength = try container.decode(UInt16.self, isLittleEndian: true)
        ascii = try container.decode(length: Int(asciiLength), map: { (data: Data) -> String in
            String(data: data, encoding: .ascii) ?? ""
        })
        blob = try container.decode(Data.self, length: 4)
        nested = try container.decode(Wrapped.self, forKey: FieldKey.nested)
        let count = try container.decode(UInt8.self)
        items = try container.decode(UInt16.self, forKey: FieldKey.items, count: Int(count))
    }

    init(
        flag: Bool, i8: Int8, u8: UInt8, bigU16: UInt16, littleI32: Int32,
        i16: Int16, i64: Int64, u64: UInt64, f: Float, d: Double,
        fixed: String, charName: CharacterName, ascii: String,
        blob: Data, nested: Wrapped, items: [UInt16]
    ) {
        self.flag = flag; self.i8 = i8; self.u8 = u8; self.bigU16 = bigU16
        self.littleI32 = littleI32; self.i16 = i16; self.i64 = i64; self.u64 = u64
        self.f = f; self.d = d; self.fixed = fixed; self.charName = charName
        self.ascii = ascii; self.blob = blob
        self.nested = nested; self.items = items
    }
}

extension CodableTests {

    func testCustomContainerRoundTrip() throws {
        let value = CustomCodable(
            flag: true,
            i8: -8,
            u8: 250,
            bigU16: 0xABCD,
            littleI32: -123456,
            i16: -30000,
            i64: -9_000_000_000,
            u64: 18_000_000_000,
            f: 1.25,
            d: 6.28,
            fixed: "Abc",
            charName: "Coleman",
            ascii: "maple story",
            blob: Data([0x01, 0x02, 0x03, 0x04]),
            nested: Wrapped(a: 100, b: 200),
            items: [11, 22, 33]
        )
        let encoder = MapleStoryEncoder()
        let decoder = MapleStoryDecoder()
        let data = try encoder.encode(value)
        let decoded = try decoder.decode(CustomCodable.self, from: data)
        XCTAssertEqual(decoded, value)
    }

    func testCustomContainerEmptyArray() throws {
        let value = CustomCodable(
            flag: false, i8: 0, u8: 0, bigU16: 0, littleI32: 0,
            i16: 0, i64: 0, u64: 0, f: 0, d: 0,
            fixed: "Full66", charName: "A", ascii: "",
            blob: Data([0, 0, 0, 0]),
            nested: Wrapped(a: 0, b: 0), items: []
        )
        let data = try MapleStoryEncoder().encode(value)
        let decoded = try MapleStoryDecoder().decode(CustomCodable.self, from: data)
        XCTAssertEqual(decoded, value)
    }
}
