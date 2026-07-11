//
//  WzPropertyTests.swift
//  MapleStoryFileTests
//

import XCTest
@testable import MapleStoryFile

final class WzPropertyTests: XCTestCase {

    func testParsesIntAndStringProperties() throws {
        // A 2-entry property list under a zero (BMS) keystream:
        //   count=2
        //   name "n" (0x00 inline, WZ string -1 'n'^0xAA=0xC4), int type 0x03, value 7
        //   name "s" (0x00 inline, WZ string -1 's'^0xAA=0xD9), string type 0x08,
        //     value "hi" (0x00 inline, WZ string -2, 'h'^0xAA=0xC2, 'i'^0xAB=0xC2)
        let bytes: [UInt8] = [
            0x02,
            0x00, 0xFF, 0xC4,
            0x03,
            0x07,
            0x00, 0xFF, 0xD9,
            0x08,
            0x00, 0xFE, 0xC2, 0xC2,
        ]
        let key = try WzMutableKey(iv: WzMapleVersion.bms.initializationVector)
        let reader = WzReader(data: bytes, key: key)

        let properties = try WzProperty.parseList(reader: reader, base: 0)

        XCTAssertEqual(properties.count, 2)

        XCTAssertEqual(properties[0].name, "n")
        guard case let .int32(value) = properties[0].value else {
            return XCTFail("expected int32, got \(properties[0].value)")
        }
        XCTAssertEqual(value, 7)

        XCTAssertEqual(properties[1].name, "s")
        guard case let .string(text) = properties[1].value else {
            return XCTFail("expected string, got \(properties[1].value)")
        }
        XCTAssertEqual(text, "hi")
    }
}
