//
//  RoundTrip83.swift
//  Shared helpers and sample values for MapleStory83 packet coverage tests.
//

import Foundation
import XCTest
@testable import MapleStory
@testable import MapleStory83

// MARK: - Round Trip Helpers

/// Encode a Codable packet, decode it back, and assert equality plus opcode.
func assertRoundTrip83<T>(
    _ value: T,
    file: StaticString = #file,
    line: UInt = #line
) where T: MapleStoryPacket, T: Codable, T: Equatable {
    do {
        let encoder = MapleStoryEncoder()
        let decoder = MapleStoryDecoder()
        let packet = try encoder.encodePacket(value)
        XCTAssertFalse(packet.data.isEmpty, "Encoded packet is empty", file: file, line: line)
        XCTAssertEqual(packet.opcode, T.opcode, file: file, line: line)
        let decoded = try decoder.decodePacket(T.self, from: packet.data)
        XCTAssertEqual(decoded, value, file: file, line: line)
    } catch {
        XCTFail("Round trip failed for \(T.self): \(error)", file: file, line: line)
    }
}

/// Encode an encode-only packet and assert the opcode and non-empty payload.
@discardableResult
func assertEncodes83<T>(
    _ value: T,
    file: StaticString = #file,
    line: UInt = #line
) -> Data? where T: MapleStoryPacket, T: Encodable {
    do {
        let encoder = MapleStoryEncoder()
        let packet = try encoder.encodePacket(value)
        XCTAssertEqual(packet.opcode, T.opcode, file: file, line: line)
        XCTAssertFalse(packet.data.isEmpty, "Encoded packet is empty", file: file, line: line)
        return packet.data
    } catch {
        XCTFail("Encode failed for \(T.self): \(error)", file: file, line: line)
        return nil
    }
}

/// Build a packet payload (opcode + body) and decode a decode-only packet from it.
@discardableResult
func assertDecodes83<T>(
    _ type: T.Type,
    body: [UInt8],
    file: StaticString = #file,
    line: UInt = #line,
    _ validate: ((T) -> Void)? = nil
) -> T? where T: MapleStoryPacket, T: Decodable, T.Opcode: RawRepresentable, T.Opcode.RawValue == UInt16 {
    do {
        let decoder = MapleStoryDecoder()
        var data = Data()
        let opcode = T.opcode.rawValue
        data.append(UInt8(truncatingIfNeeded: opcode))
        data.append(UInt8(truncatingIfNeeded: opcode >> 8))
        data.append(contentsOf: body)
        let value = try decoder.decodePacket(T.self, from: data)
        validate?(value)
        return value
    } catch {
        XCTFail("Decode failed for \(T.self): \(error)", file: file, line: line)
        return nil
    }
}

// MARK: - Byte Builders

func le16_83(_ value: UInt16) -> [UInt8] {
    [UInt8(truncatingIfNeeded: value), UInt8(truncatingIfNeeded: value >> 8)]
}

func le32_83(_ value: UInt32) -> [UInt8] {
    [
        UInt8(truncatingIfNeeded: value),
        UInt8(truncatingIfNeeded: value >> 8),
        UInt8(truncatingIfNeeded: value >> 16),
        UInt8(truncatingIfNeeded: value >> 24)
    ]
}

func le16s_83(_ value: Int16) -> [UInt8] { le16_83(UInt16(bitPattern: value)) }

/// MapleStory length-prefixed ASCII string (UInt16 little-endian length + bytes).
func mapleString83(_ string: String) -> [UInt8] {
    let bytes = Array(string.utf8)
    return le16_83(UInt16(bytes.count)) + bytes
}

// MARK: - Sample Values

func sampleMovement83() -> Movement {
    .absolute(
        Movement.Absolute(
            command: 0,
            xpos: 10,
            ypos: 20,
            xwobble: 0,
            ywobble: 0,
            value0: 0,
            newState: 3,
            duration: 5
        )
    )
}

func sampleMobSpawnData83() -> MobSpawnData {
    MobSpawnData(
        objectID: 100,
        mobID: 100100,
        x: 500,
        y: 300,
        foothold: 10,
        rx0: 400,
        rx1: 600,
        facing: 1
    )
}

func samplePartyMember83(channel: UInt8 = 1) -> PartyMember {
    PartyMember(
        characterID: UUID(),
        characterName: "coleman",
        job: .beginner,
        level: 10,
        channel: channel,
        map: 40000,
        status: .online
    )
}

/// A valid UUID string for decoding `Character.ID` values.
let sampleUUIDString83 = "550E8400-E29B-41D4-A716-446655440000"
