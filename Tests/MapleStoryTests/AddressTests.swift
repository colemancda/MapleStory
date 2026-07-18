//
//  AddressTests.swift
//
//  Tests for MapleStoryAddress parsing and encoding.
//

import Foundation
import XCTest
@testable import MapleStory

final class AddressTests: XCTestCase {

    func testInitAddressPort() {
        let address = MapleStoryAddress(address: "127.0.0.1", port: 8484)
        XCTAssertNotNil(address)
        XCTAssertEqual(address?.address, "127.0.0.1")
        XCTAssertEqual(address?.port, 8484)
    }

    func testInvalidAddress() {
        XCTAssertNil(MapleStoryAddress(address: "not-an-ip", port: 80))
        XCTAssertNil(MapleStoryAddress(address: "999.999.999.999", port: 80))
    }

    func testRawValue() {
        let address = MapleStoryAddress(address: "10.0.0.5", port: 7575)!
        XCTAssertEqual(address.rawValue, "10.0.0.5:7575")
        XCTAssertEqual(address.description, "10.0.0.5:7575")
        XCTAssertEqual(address.debugDescription, "10.0.0.5:7575")
    }

    func testRawValueInit() {
        let address = MapleStoryAddress(rawValue: "192.168.1.1:8080")
        XCTAssertNotNil(address)
        XCTAssertEqual(address?.address, "192.168.1.1")
        XCTAssertEqual(address?.port, 8080)
    }

    func testRawValueInitInvalid() {
        XCTAssertNil(MapleStoryAddress(rawValue: "192.168.1.1"))          // no port
        XCTAssertNil(MapleStoryAddress(rawValue: "192.168.1.1:abc"))      // bad port
        XCTAssertNil(MapleStoryAddress(rawValue: "bad:8080"))            // bad ip
        XCTAssertNil(MapleStoryAddress(rawValue: "1.2.3.4:5:6"))         // too many parts
    }

    func testDefaults() {
        XCTAssertEqual(MapleStoryAddress.loginServerDefault.port, 8484)
        XCTAssertEqual(MapleStoryAddress.channelServerDefault.port, 7575)
        XCTAssertEqual(MapleStoryAddress.loginServerDefault.address, "127.0.0.1")
    }

    func testEquatableHashable() {
        let a = MapleStoryAddress(rawValue: "10.0.0.1:80")!
        let b = MapleStoryAddress(rawValue: "10.0.0.1:80")!
        let c = MapleStoryAddress(rawValue: "10.0.0.2:80")!
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
        XCTAssertEqual(a.hashValue, b.hashValue)
    }

    func testJSONCodable() throws {
        let address = MapleStoryAddress(rawValue: "8.8.8.8:53")!
        XCTAssertJSONRoundTrip(address)
    }

    func testMapleStoryCodable() throws {
        let address = MapleStoryAddress(rawValue: "1.2.3.4:1234")!
        let encoder = MapleStoryEncoder()
        let decoder = MapleStoryDecoder()
        let data = try encoder.encode(address)
        // 4 bytes ip + 2 bytes port
        XCTAssertEqual(data.count, 6)
        let decoded = try decoder.decode(MapleStoryAddress.self, from: data)
        XCTAssertEqual(decoded, address)
    }
}
