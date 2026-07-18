//
//  PacketTests.swift
//
//  Tests for Packet, Opcode, EncryptedPacket and encryption round-trips.
//

import Foundation
import XCTest
@testable import MapleStory

// MARK: - Test Types

enum TestOpcode: UInt16, MapleStoryOpcode {
    case ping = 0x000F
    case pong = 0x0010
}

enum TestByteOpcode: UInt8, MapleStoryOpcode {
    case a = 0x01
    case b = 0x02
}

struct TestPacket: MapleStoryPacket, Codable, Equatable {
    static var opcode: TestOpcode { .ping }
    var value: UInt32
    var flag: Bool
    var name: String
}

final class PacketTests: XCTestCase {

    func testOpcodeUInt16Data() {
        XCTAssertEqual(TestOpcode.ping.data, Data([0x0F, 0x00]))
        XCTAssertEqual(TestOpcode(data: Data([0x0F, 0x00])), .ping)
        XCTAssertEqual(TestOpcode(data: Data([0x10, 0x00])), .pong)
        XCTAssertNil(TestOpcode(data: Data([0x0F]))) // too short
        XCTAssertNil(TestOpcode(data: Data([0xFF, 0xFF]))) // unknown
        XCTAssertEqual(TestOpcode(rawValue: 0x000F), .ping)
    }

    func testOpcodeUInt8Data() {
        XCTAssertEqual(TestByteOpcode.a.data, Data([0x01]))
        XCTAssertEqual(TestByteOpcode(data: Data([0x02])), .b)
        XCTAssertNil(TestByteOpcode(data: Data()))
        XCTAssertNil(TestByteOpcode(data: Data([0xEE])))
    }

    func testPacketConstruction() {
        let packet = Packet(opcode: TestOpcode.pong, parameters: Data([0xAA, 0xBB]))
        XCTAssertEqual(packet.opcode, .pong)
        XCTAssertEqual(packet.parameters, Data([0xAA, 0xBB]))
        XCTAssertEqual(packet.parametersSize, 2)
        XCTAssertEqual(Packet<TestOpcode>.minSize, 2)
        XCTAssertEqual(packet.data, Data([0x10, 0x00, 0xAA, 0xBB]))
    }

    func testPacketNoParameters() {
        let packet = Packet(opcode: TestOpcode.ping)
        XCTAssertEqual(packet.parametersSize, 0)
        XCTAssertEqual(packet.parameters, Data())
        XCTAssertTrue(packet.description.contains("ping"))
        XCTAssertEqual(packet.debugDescription, packet.description)
    }

    func testPacketInitFromData() {
        let valid = Packet<TestOpcode>(data: Data([0x0F, 0x00, 0x01]))
        XCTAssertNotNil(valid)
        XCTAssertEqual(valid?.opcode, .ping)

        // too short
        XCTAssertNil(Packet<TestOpcode>(data: Data([0x0F])))
        // invalid opcode
        XCTAssertNil(Packet<TestOpcode>(data: Data([0xEE, 0xEE])))
    }

    func testPacketArrayLiteral() {
        let packet: Packet<TestOpcode> = [0x0F, 0x00, 0x99]
        XCTAssertEqual(packet.opcode, .ping)
        XCTAssertEqual(packet.parameters, Data([0x99]))
    }

    func testPacketEncodeDecode() throws {
        let value = TestPacket(value: 0x12345678, flag: true, name: "hello")
        let encoder = MapleStoryEncoder()
        let decoder = MapleStoryDecoder()
        let packet = try encoder.encodePacket(value)
        XCTAssertEqual(packet.opcode, .ping)
        let decoded = try decoder.decodePacket(TestPacket.self, from: packet.data)
        XCTAssertEqual(decoded, value)
        let decoded2 = try decoder.decode(TestPacket.self, from: packet)
        XCTAssertEqual(decoded2, value)
    }

    func testEncryptDecryptRoundTripWithKey() throws {
        let value = TestPacket(value: 42, flag: false, name: "abc")
        let encoder = MapleStoryEncoder()
        let packet = try encoder.encodePacket(value)
        let nonce = Nonce(rawValue: 0x27568982)
        let encrypted = try packet.encrypt(key: .default, nonce: nonce, version: .v62)
        XCTAssertGreaterThanOrEqual(encrypted.data.count, EncryptedPacket.minSize)
        let decrypted: Packet<TestOpcode> = try encrypted.decrypt(key: .default, nonce: nonce, version: .v62)
        XCTAssertEqual(decrypted.data, packet.data)
    }

    func testEncryptDecryptRoundTripNoKey() throws {
        let value = TestPacket(value: 7, flag: true, name: "xyz")
        let encoder = MapleStoryEncoder()
        let packet = try encoder.encodePacket(value)
        let nonce = Nonce(rawValue: 0x11223344)
        let encrypted = try packet.encrypt(key: nil, nonce: nonce, version: .v83)
        let decrypted: Packet<TestOpcode> = try encrypted.decrypt(key: nil, nonce: nonce, version: .v83)
        XCTAssertEqual(decrypted.data, packet.data)
    }

    func testEncryptedPacketProperties() throws {
        let value = TestPacket(value: 1, flag: false, name: "q")
        let packet = try MapleStoryEncoder().encodePacket(value)
        let nonce = Nonce()
        let encrypted = try packet.encrypt(nonce: nonce, version: .v62)
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.parametersSize, encrypted.data.count - EncryptedPacket.minSize)
        XCTAssertTrue(encrypted.description.contains("EncryptedPacket"))
        XCTAssertEqual(encrypted.debugDescription, encrypted.description)
    }

    func testEncryptedPacketInitFromData() {
        XCTAssertNil(EncryptedPacket(data: Data([0x00, 0x01, 0x02]))) // < minSize
        let valid = EncryptedPacket(data: Data([0x00, 0x01, 0x02, 0x03, 0x04]))
        XCTAssertNotNil(valid)
        XCTAssertEqual(valid?.parametersSize, 1)
    }

    func testEncryptedPacketArrayLiteral() {
        let encrypted: EncryptedPacket = [0x01, 0x02, 0x03, 0x04, 0x05]
        XCTAssertEqual(encrypted.parametersSize, 1)
    }

    func testEncryptedPacketLengthHeader() {
        let iv = Nonce(rawValue: 0x27568982).iv
        let header = EncryptedPacket.header(length: 2, iv: iv, version: .v62)
        XCTAssertEqual(EncryptedPacket.length(header: header), 2)
    }
}
