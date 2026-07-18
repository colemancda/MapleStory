//
//  ExtraCoverageTests83.swift
//  Fills coverage gaps: missed packets, convenience inits, and error branches.
//

import Foundation
import XCTest
@testable import MapleStory
@testable import MapleStory83

final class ExtraCoverageTests83: XCTestCase {

    // MARK: - Previously-missed Codable packets

    func testMissedCodablePackets() {
        assertRoundTrip83(DamageSummonNotification(characterID: 14, summonObjectID: 5, unknown: 0, damage: 100, monsterIDFrom: 9300000, unknown2: 0))
        assertRoundTrip83(KillMonsterNotification(objectID: 5, animation: 1))
        assertRoundTrip83(KillMonsterNotification(objectID: 5, animation: 2, animation2: 1))
    }

    // MARK: - SummonAttackNotification convenience init

    func testSummonAttackConvenienceInit() {
        assertRoundTrip83(SummonAttackNotification(characterID: 14, objectID: 5, numAttacked: 2))
    }

    // MARK: - CreateCharacterRequest job mapping

    func testCreateCharacterRequestJobMapping() {
        assertRoundTrip83(CreateCharacterRequest(
            name: "hero", job: .knights, face: 20000, hair: 30000, hairColor: 0,
            skinColor: 0, top: 1040002, bottom: 1060002, shoes: 1072005, weapon: 1302000, gender: .male
        ))
        // exercise the nested Job enum and the Job(initial:) mapping for all cases
        XCTAssertEqual(CreateCharacterRequest.Job.allCases.count, 3)
        XCTAssertEqual(Job(initial: .adventurer), .beginner)
        XCTAssertEqual(Job(initial: .knights), .noblesse)
        XCTAssertEqual(Job(initial: .legend), .legend)
    }

    // MARK: - ClientStartError string literal

    func testClientStartErrorLiteral() {
        let error: ClientStartError = "literal error"
        XCTAssertEqual(error.error, "literal error")
        XCTAssertEqual(ClientStartError(error: "abc").error, "abc")
    }

    // MARK: - ServerStatusResponse from Channel.Status

    func testServerStatusResponseFromChannelStatus() {
        XCTAssertEqual(ServerStatusResponse(.normal), .normal)
        XCTAssertEqual(ServerStatusResponse(.highUsage), .highUsage)
        XCTAssertEqual(ServerStatusResponse(.full), .full)
        assertRoundTrip83(ServerStatusResponse.highUsage)
        assertRoundTrip83(ServerStatusResponse.full)
    }

    // MARK: - Encode error branches

    func testSpawnPetNotificationMissingMetadataThrows() {
        let encoder = MapleStoryEncoder()
        // remove == false but no pet metadata -> must throw
        XCTAssertThrowsError(try encoder.encodePacket(SpawnPetNotification(characterID: 14, slot: 0, remove: false)))
    }

    // MARK: - Public convenience initializers

    func testPublicInitializers() {
        assertRoundTrip83(LoginRequest(username: "admin", password: "secret", hardwareID: 0x12345678))
        assertRoundTrip83(LoginRequest(username: "guest", password: ""))
        assertRoundTrip83(CharacterListRequest(world: 0, channel: 0))
        assertRoundTrip83(CharacterListRequest(world: 1, channel: 2))
    }

    // MARK: - LoginResponse ban / permanent-ban paths

    func testLoginResponseBanVariants() {
        assertRoundTrip83(LoginResponse.permanentBan)
        assertRoundTrip83(LoginResponse.temporaryBan(.invalidUsername, .default))
        assertRoundTrip83(LoginResponse.failure(.invalidPassword))
        assertRoundTrip83(LoginResponse.failure(.notRegistered))
    }
}
