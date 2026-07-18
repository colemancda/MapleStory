//
//  FixedLengthStringTests.swift
//
//  Tests for FixedLengthString conformance via CharacterName.
//

import Foundation
import XCTest
@testable import MapleStory

final class FixedLengthStringTests: XCTestCase {

    func testValidate() {
        XCTAssertTrue(CharacterName.validate("Fred"))
        XCTAssertTrue(CharacterName.validate("")) // empty is <= length
        XCTAssertTrue(CharacterName.validate("1234567890123")) // exactly 13
        XCTAssertFalse(CharacterName.validate("12345678901234")) // 14 > 13
    }

    func testInitAndProperties() {
        let name = CharacterName(rawValue: "Fred")
        XCTAssertNotNil(name)
        XCTAssertEqual(name?.rawValue, "Fred")
        XCTAssertEqual(name?.description, "Fred")
        XCTAssertFalse(name!.isEmpty)
        XCTAssertNil(CharacterName(rawValue: "TooLongCharacterName"))
    }

    func testStringLiteral() {
        let name: CharacterName = "Hero"
        XCTAssertEqual(name.rawValue, "Hero")
    }

    func testComparable() {
        let a: CharacterName = "Aaa"
        let b: CharacterName = "Bbb"
        XCTAssertTrue(a < b)
        XCTAssertTrue(b > a)
        XCTAssertFalse(a > b)
    }

    func testMapleStoryEncodingRoundTrip() throws {
        let name: CharacterName = "Coleman"
        let encoder = MapleStoryEncoder()
        let decoder = MapleStoryDecoder()
        let data = try encoder.encode(name)
        // fixed length 13 bytes
        XCTAssertEqual(data.count, 13)
        // trailing bytes should be zero padding
        XCTAssertEqual(data.suffix(6), Data(repeating: 0, count: 6))
        let decoded = try decoder.decode(CharacterName.self, from: data)
        XCTAssertEqual(decoded, name)
    }

    func testMapleStoryEncodingFullLength() throws {
        let name: CharacterName = "1234567890123" // exactly 13
        let encoder = MapleStoryEncoder()
        let decoder = MapleStoryDecoder()
        let data = try encoder.encode(name)
        XCTAssertEqual(data.count, 13)
        let decoded = try decoder.decode(CharacterName.self, from: data)
        XCTAssertEqual(decoded, name)
    }

    func testRemovePadding() {
        let padded = Data([0x41, 0x42, 0x43, 0x00, 0x00])
        let stripped = CharacterName.removePadding(padded)
        XCTAssertEqual(stripped, Data([0x41, 0x42, 0x43]))

        let noPadding = Data([0x41, 0x42, 0x43])
        XCTAssertEqual(CharacterName.removePadding(noPadding), noPadding)
    }

    func testCodableRoundTrip() throws {
        let name: CharacterName = "Player1"
        XCTAssertJSONRoundTrip(name)
    }
}
