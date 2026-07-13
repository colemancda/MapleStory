//
//  WzCryptoTests.swift
//  MapleStoryFileTests
//

import XCTest
@testable import MapleStoryFile

final class WzCryptoTests: XCTestCase {

    // MARK: - Version hash

    func testVersionHash() {
        // "83" -> 0*32+56+1=57 -> 57*32+51+1=1876
        XCTAssertEqual(WzVersion.hash(forVersion: 83), 1876)
        // 0x0754 folded against 0xFF -> 0xAC
        XCTAssertEqual(WzVersion.encryptedVersion(fromHash: 1876), 0xAC)
    }

    func testVersionDetectRoundTrips() {
        let hash = WzVersion.hash(forVersion: 95)
        let marker = WzVersion.encryptedVersion(fromHash: hash)
        let detected = WzVersion.detect(encryptedVersion: marker, in: 1...200)
        XCTAssertNotNil(detected)
        // detect may land on an earlier collision, but its hash must match the marker.
        XCTAssertEqual(WzVersion.encryptedVersion(fromHash: detected!.hash), marker)
    }

    func testRotateLeft() {
        XCTAssertEqual(WzVersion.rotateLeft(0x0000_0001, 4), 0x0000_0010)
        XCTAssertEqual(WzVersion.rotateLeft(0x8000_0000, 1), 0x0000_0001)
    }

    // MARK: - Keystream

    func testZeroIVProducesZeroKeystream() throws {
        let key = try WzMutableKey(iv: WzMapleVersion.bms.initializationVector)
        for index in [0, 15, 16, 100, 4095] {
            XCTAssertEqual(key[index], 0)
        }
    }

    func testGMSKeystreamIsNonZeroAndDeterministic() throws {
        let a = try WzMutableKey(iv: WzMapleVersion.gms.initializationVector)
        let b = try WzMutableKey(iv: WzMapleVersion.gms.initializationVector)
        // Deterministic across instances.
        for index in [0, 1, 15, 16, 31] {
            XCTAssertEqual(a[index], b[index])
        }
        // Not all zero (the whole point of a non-zero IV).
        let anyNonZero = (0 ..< 32).contains { a[$0] != 0 }
        XCTAssertTrue(anyNonZero)
    }
}
