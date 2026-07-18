//
//  CryptoExtraTests.swift
//
//  Additional tests for Nonce and Key.
//

import Foundation
import XCTest
@testable import MapleStory

final class CryptoExtraTests: XCTestCase {

    func testNonceLiteralAndRawValue() {
        let nonce: Nonce = 0xDEADBEEF
        XCTAssertEqual(nonce.rawValue, 0xDEADBEEF)
        XCTAssertEqual(Nonce(rawValue: 0x01020304).rawValue, 0x01020304)
    }

    func testNonceDescription() {
        let nonce = Nonce(rawValue: 0x27568982)
        XCTAssertEqual(nonce.description, "0x27568982")
        XCTAssertEqual(nonce.debugDescription, "0x27568982")
    }

    func testNonceRandomInit() {
        // Just ensure it does not crash and produces a value.
        let nonce = Nonce()
        _ = nonce.rawValue
    }

    func testNonceIV() {
        let iv = Nonce(rawValue: 0x27568982).iv
        // IV is the 4-byte big-endian value repeated 4 times = 16 bytes
        XCTAssertEqual(iv.count, 16)
        XCTAssertEqual(Array(iv.prefix(4)), [0x27, 0x56, 0x89, 0x82])
        XCTAssertEqual(Array(iv.suffix(4)), [0x27, 0x56, 0x89, 0x82])
    }

    func testNonceCodableRoundTrip() throws {
        let nonce = Nonce(rawValue: 0x12345678)
        let encoder = MapleStoryEncoder()
        let decoder = MapleStoryDecoder()
        let data = try encoder.encode(nonce)
        XCTAssertEqual(data.count, 4)
        // encoded big-endian
        XCTAssertEqual(Array(data), [0x12, 0x34, 0x56, 0x78])
        let decoded = try decoder.decode(Nonce.self, from: data)
        XCTAssertEqual(decoded, nonce)
    }

    func testKeyDefault() {
        let key = Key.default
        XCTAssertEqual(key.data.count, 32)
        XCTAssertEqual(key, .default)
        XCTAssertEqual(key.hashValue, Key.default.hashValue)
    }

    func testKeyDescription() {
        let key = Key.default
        XCTAssertFalse(key.description.isEmpty)
        XCTAssertEqual(key.debugDescription, key.description)
        // hex string, 64 chars for 32 bytes
        XCTAssertEqual(key.description.count, 64)
    }

    func testKeyCodable() throws {
        let key = Key.default
        let data = try JSONEncoder().encode(key)
        let decoded = try JSONDecoder().decode(Key.self, from: data)
        XCTAssertEqual(decoded, key)
    }
}
