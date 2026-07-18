//
//  RoundTrip28.swift
//  Shared helpers and sample values for MapleStory28 packet coverage tests.
//

import Foundation
import XCTest
@testable import MapleStory
@testable import MapleStory28

// MARK: - Round Trip Helpers

/// Encode a Codable packet, decode it back, and assert equality plus opcode.
func assertRoundTrip28<T>(
    _ value: T,
    file: StaticString = #file,
    line: UInt = #line
) where T: MapleStoryPacket, T: Codable, T: Equatable {
    do {
        var encoder = MapleStoryEncoder()
        encoder.log = { print("Encoder:", $0) }
        var decoder = MapleStoryDecoder()
        decoder.log = { print("Decoder:", $0) }
        let packet = try encoder.encodePacket(value)
        XCTAssertFalse(packet.data.isEmpty, "Encoded packet is empty", file: file, line: line)
        XCTAssertEqual(packet.opcode, T.opcode, file: file, line: line)
        let decoded = try decoder.decodePacket(T.self, from: packet.data)
        XCTAssertEqual(decoded, value, file: file, line: line)
    } catch {
        XCTFail("Round trip failed for \(T.self): \(error)", file: file, line: line)
    }
}

/// Encode a Codable value (not a full packet), decode it back, and assert equality.
func assertValueRoundTrip28<T>(
    _ value: T,
    file: StaticString = #file,
    line: UInt = #line
) where T: Codable, T: Equatable {
    do {
        var encoder = MapleStoryEncoder()
        encoder.log = { print("Encoder:", $0) }
        var decoder = MapleStoryDecoder()
        decoder.log = { print("Decoder:", $0) }
        let data = try encoder.encode(value)
        XCTAssertFalse(data.isEmpty, "Encoded value is empty", file: file, line: line)
        let decoded = try decoder.decode(T.self, from: data)
        XCTAssertEqual(decoded, value, file: file, line: line)
    } catch {
        XCTFail("Value round trip failed for \(T.self): \(error)", file: file, line: line)
    }
}

// MARK: - Sample Domain Fixtures

func sampleCharacter28(
    rankEnabled: Bool = true,
    equipment: MapleStory.Character.Equipment = [:]
) -> MapleStory.Character {
    MapleStory.Character(
        id: UUID(),
        index: 1,
        user: UUID(),
        world: UUID(),
        name: "colemancda1",
        gender: .male,
        skinColor: .normal,
        face: 20000,
        level: 1,
        job: .beginner,
        equipment: equipment,
        isRankEnabled: rankEnabled,
        worldRank: 1,
        rankMove: 2,
        jobRank: 3,
        jobRankMove: 4
    )
}

func sampleChannel28() -> MapleStory.Channel {
    MapleStory.Channel(
        index: 0,
        world: UUID(),
        name: "Scania - Channel 1",
        load: 0
    )
}

func sampleWorld28() -> MapleStory.World {
    MapleStory.World(
        index: 0,
        name: "Scania",
        version: .v28,
        ribbon: .normal,
        eventMessage: "",
        eventXP: 0
    )
}

func sampleUser28() -> MapleStory.User {
    MapleStory.User(
        index: 1,
        username: Username(rawValue: "colemancda")!,
        gender: .male,
        isAdmin: true
    )
}
