//
//  WzValueTypeTests.swift
//  MapleStoryFileTests
//
//  Small value types: maple-version IVs, crypto constants, version-hash math,
//  and the lazily-grown keystream.
//

import XCTest
@testable import MapleStoryFile

final class WzValueTypeTests: XCTestCase {

    // MARK: - WzMapleVersion

    func testInitializationVectors() {
        XCTAssertEqual(WzMapleVersion.gms.initializationVector, [0x4D, 0x23, 0xC7, 0x2B])
        XCTAssertEqual(WzMapleVersion.ems.initializationVector, [0xB9, 0x7D, 0x63, 0xE9])
        XCTAssertEqual(WzMapleVersion.bms.initializationVector, [0, 0, 0, 0])
        XCTAssertEqual(WzMapleVersion.custom([1, 2, 3, 4]).initializationVector, [1, 2, 3, 4])
    }

    func testMapleVersionEquatable() {
        XCTAssertEqual(WzMapleVersion.gms, .gms)
        XCTAssertNotEqual(WzMapleVersion.gms, .ems)
        XCTAssertEqual(WzMapleVersion.custom([1, 2, 3, 4]), .custom([1, 2, 3, 4]))
        XCTAssertNotEqual(WzMapleVersion.custom([1, 2, 3, 4]), .custom([4, 3, 2, 1]))
    }

    func testCryptoConstants() {
        XCTAssertEqual(WzCrypto.offsetConstant, 0x581C_3F6D)
        XCTAssertEqual(WzCrypto.aesUserKey.count, 32)
    }

    // MARK: - WzVersion

    func testHashAndEncryptedVersion() {
        // "1" -> 0*32 + 49 + 1 = 50
        XCTAssertEqual(WzVersion.hash(forVersion: 1), 50)
        // Round-trip through detect.
        let hash = WzVersion.hash(forVersion: 255)
        let marker = WzVersion.encryptedVersion(fromHash: hash)
        XCTAssertEqual(WzVersion.encryptedVersion(fromHash: WzVersion.detect(encryptedVersion: marker)!.hash), marker)
    }

    func testDetectReturnsNilForImpossibleMarker() {
        // encryptedVersion always folds down to a single byte (<= 0xFF), so any
        // marker above 0xFF is unreachable.
        XCTAssertNil(WzVersion.detect(encryptedVersion: 0x0100, in: 1...1000))
    }

    func testRotateLeftEdges() {
        XCTAssertEqual(WzVersion.rotateLeft(0x1234_5678, 0), 0x1234_5678) // n == 0
        XCTAssertEqual(WzVersion.rotateLeft(0x1234_5678, 32), 0x1234_5678) // n & 31 == 0
        XCTAssertEqual(WzVersion.rotateLeft(0x0000_00FF, 8), 0x0000_FF00)
    }

    // MARK: - WzMutableKey

    func testKeyGrowsAcrossBatchBoundary() throws {
        let key = try WzMutableKey(iv: WzMapleVersion.gms.initializationVector)
        // First read forces a 4096-byte batch; reading well past it forces another.
        let a = key[10]
        let b = key[5000]      // triggers a second batch, chained from the first
        let c = key[8000]
        XCTAssertEqual(key[10], a, "already-computed bytes stay stable")
        // A non-zero IV must yield a non-trivial keystream.
        XCTAssertTrue([a, b, c].contains { $0 != 0 })
    }

    func testEnsureIsIdempotent() throws {
        let key = try WzMutableKey(iv: WzMapleVersion.gms.initializationVector)
        key.ensure(size: 32)
        let snapshot = (0 ..< 32).map { key[$0] }
        key.ensure(size: 16)   // smaller: no-op
        key.ensure(size: 32)
        XCTAssertEqual((0 ..< 32).map { key[$0] }, snapshot)
    }

    func testEmsKeystreamIsNonZero() throws {
        let key = try WzMutableKey(iv: WzMapleVersion.ems.initializationVector)
        XCTAssertTrue((0 ..< 32).contains { key[$0] != 0 })
    }

    func testZeroIVLargeIndexIsZero() throws {
        let key = try WzMutableKey(iv: WzMapleVersion.bms.initializationVector)
        XCTAssertEqual(key[9000], 0)
    }

    func testCustomIVKeystreamDiffersFromGMS() throws {
        let custom = try WzMutableKey(iv: [0x01, 0x02, 0x03, 0x04])
        let gms = try WzMutableKey(iv: WzMapleVersion.gms.initializationVector)
        let a = (0 ..< 32).map { custom[$0] }
        let b = (0 ..< 32).map { gms[$0] }
        XCTAssertNotEqual(a, b)
        XCTAssertTrue(a.contains { $0 != 0 })
    }
}
