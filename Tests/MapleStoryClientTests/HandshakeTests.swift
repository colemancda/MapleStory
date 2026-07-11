//
//  HandshakeTests.swift
//  MapleStoryClientTests
//

import XCTest
import MapleStory
import MapleStory83
@testable import MapleStoryClient

// The app declares this conformance in the MapleStoryClient83 executable target,
// which tests can't import; re-declare it here to exercise the same code path.
extension MapleStory83.HelloPacket: HandshakePacket {}

final class HandshakeTests: XCTestCase {

    /// The v83 `HelloPacket` round-trips through the encoder/decoder and exposes
    /// the handshake fields the client uses to seed its ciphers.
    func testHelloPacketDecodesAsHandshake() throws {
        let hello = MapleStory83.HelloPacket(
            recieveNonce: 0x1122_3344,
            sendNonce: 0x5566_7788,
            region: .global
        )

        let data = try MapleStoryEncoder().encode(hello)
        let decoded = try MapleStoryDecoder().decode(MapleStory83.HelloPacket.self, from: data)

        XCTAssertEqual(decoded.version, .v83)
        XCTAssertEqual(decoded.region, .global)
        XCTAssertEqual(decoded.recieveNonce, 0x1122_3344)
        XCTAssertEqual(decoded.sendNonce, 0x5566_7788)
    }

    /// Accessing the same values through the `HandshakePacket` protocol (the way
    /// `MapleStoryClient` consumes them) yields identical results.
    func testHandshakeProtocolWitness() throws {
        let hello = MapleStory83.HelloPacket(
            recieveNonce: 0x0A0B_0C0D,
            sendNonce: 0x0102_0304,
            region: .global
        )
        let data = try MapleStoryEncoder().encode(hello)
        let handshake: any HandshakePacket = try MapleStoryDecoder().decode(MapleStory83.HelloPacket.self, from: data)

        // The client maps the server's send cipher to its own receive cipher.
        XCTAssertEqual(handshake.sendNonce, 0x0102_0304)
        XCTAssertEqual(handshake.recieveNonce, 0x0A0B_0C0D)
        XCTAssertEqual(handshake.version, .v83)
    }
}
