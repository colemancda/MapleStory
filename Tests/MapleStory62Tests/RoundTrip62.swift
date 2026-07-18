//
//  RoundTrip62.swift
//  Shared helpers and sample values for MapleStory62 packet coverage tests.
//

import Foundation
import XCTest
@testable import MapleStory
@testable import MapleStory62

// MARK: - Round Trip Helpers

/// Encode a Codable packet, decode it back, and assert equality plus opcode.
func assertRoundTrip62<T>(
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
func assertEncodes62<T>(
    _ value: T,
    file: StaticString = #file,
    line: UInt = #line
) -> Data? where T: MapleStoryPacket, T: Encodable {
    do {
        let encoder = MapleStoryEncoder()
        let packet = try encoder.encodePacket(value)
        XCTAssertEqual(packet.opcode, T.opcode, file: file, line: line)
        return packet.data
    } catch {
        XCTFail("Encode failed for \(T.self): \(error)", file: file, line: line)
        return nil
    }
}

/// Build a packet payload (opcode + body) and decode a decode-only packet from it.
@discardableResult
func assertDecodes62<T>(
    _ type: T.Type,
    body: [UInt8],
    file: StaticString = #file,
    line: UInt = #line,
    _ validate: ((T) -> Void)? = nil
) -> T? where T: MapleStoryPacket, T: Decodable {
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

func le16_62(_ value: UInt16) -> [UInt8] {
    [UInt8(truncatingIfNeeded: value), UInt8(truncatingIfNeeded: value >> 8)]
}

func le32_62(_ value: UInt32) -> [UInt8] {
    [
        UInt8(truncatingIfNeeded: value),
        UInt8(truncatingIfNeeded: value >> 8),
        UInt8(truncatingIfNeeded: value >> 16),
        UInt8(truncatingIfNeeded: value >> 24)
    ]
}

func le16s_62(_ value: Int16) -> [UInt8] { le16_62(UInt16(bitPattern: value)) }

/// MapleStory length-prefixed ASCII string (UInt16 little-endian length + bytes).
func mapleString62(_ string: String) -> [UInt8] {
    let bytes = Array(string.utf8)
    return le16_62(UInt16(bytes.count)) + bytes
}

// MARK: - Sample Values

/// A fully populated character for reuse in list / create / warp packets.
func sampleCharacterStats62(id: UInt32 = 14, name: String = "colemancda") -> CharacterListResponse.CharacterStats {
    CharacterListResponse.CharacterStats(
        id: id,
        name: CharacterName(rawValue: name)!,
        gender: .male,
        skinColor: .normal,
        face: 20000,
        hair: 30023,
        value0: 0,
        value1: 0,
        value2: 0,
        level: 10,
        job: .beginner,
        str: 12,
        dex: 8,
        int: 5,
        luk: 4,
        hp: 250,
        maxHp: 250,
        mp: 120,
        maxMp: 120,
        ap: 9,
        sp: 3,
        exp: 12345,
        fame: 7,
        isMarried: 0,
        currentMap: 40000,
        spawnPoint: 2,
        value3: 0
    )
}

func sampleCharacter62(id: UInt32 = 14, name: String = "colemancda") -> CharacterListResponse.Character {
    CharacterListResponse.Character(
        stats: sampleCharacterStats62(id: id, name: name),
        appearance: CharacterListResponse.CharacterAppeareance(
            gender: .male,
            skinColor: .normal,
            face: 20000,
            mega: false,
            hair: 30023,
            equipment: [:],
            maskedEquipment: [:],
            cashWeapon: 0,
            value0: 0,
            value1: 0
        ),
        rank: .enabled(worldRank: 1, rankMove: 2, jobRank: 3, jobRankMove: 4)
    )
}
