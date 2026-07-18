//
//  BranchCoverageTests.swift
//  Additional branch coverage for decode-only packets and convenience inits.
//

import Foundation
import XCTest
@testable import MapleStory
@testable import MapleStory62

final class BranchCoverageTests: XCTestCase {

    private let uuidString = "550E8400-E29B-41D4-A716-446655440000"

    // MARK: - Convenience inits

    func testConvenienceInits() {
        let e: ClientStartError = "literal error"
        XCTAssertEqual(e.error, "literal error")
        XCTAssertEqual(ServerStatusResponse(.normal), .normal)
        XCTAssertEqual(ServerStatusResponse(.highUsage), .highUsage)
        XCTAssertEqual(ServerStatusResponse(.full), .full)
    }

    // MARK: - NPC shop / talk branches

    func testNPCShopBranches() {
        assertDecodes62(NPCShopRequest.self, body: [1] + le16s_62(2) + le32_62(2000000) + le16s_62(3)) {
            XCTAssertEqual($0.mode, 1)
            XCTAssertEqual($0.itemID, 2000000)
        }
        assertDecodes62(NPCShopRequest.self, body: [9]) {
            XCTAssertEqual($0.mode, 9)
            XCTAssertNil($0.itemID)
        }
        // selection as a single trailing byte
        assertDecodes62(NPCTalkMoreRequest.self, body: [0, 0, 7]) {
            XCTAssertEqual($0.selection, 7)
        }
        // no trailing selection
        assertDecodes62(NPCTalkMoreRequest.self, body: [0, 0]) {
            XCTAssertNil($0.selection)
            XCTAssertNil($0.returnText)
        }
    }

    // MARK: - Storage / Take damage branches

    func testStorageAndDamageBranches() {
        assertDecodes62(StorageRequest.self, body: [5] + le16s_62(1) + le32_62(2000000) + le16s_62(4)) {
            XCTAssertEqual($0.mode, 5)
            XCTAssertEqual($0.itemID, 2000000)
            XCTAssertEqual($0.quantity, 4)
        }
        assertDecodes62(StorageRequest.self, body: [9]) {
            XCTAssertEqual($0.mode, 9)
        }
        // TakeDamage with no monster data (short packet)
        assertDecodes62(TakeDamageRequest.self, body: le32_62(0) + [0xFE, 0] + le32_62(75)) {
            XCTAssertEqual($0.damage, 75)
            XCTAssertEqual($0.monsterIDFrom, 0)
            XCTAssertEqual($0.direction, 0)
        }
    }

    // MARK: - Quest branch (selection without npc)

    func testQuestSelectionBranch() {
        assertDecodes62(QuestActionRequest.self, body: [2] + le16_62(100) + le32_62(5)) {
            XCTAssertEqual($0.action, 2)
            XCTAssertNil($0.npcID)
            XCTAssertEqual($0.selection, 5)
        }
    }

    // MARK: - MoveLife with movement data

    func testMoveLifeWithMovement() {
        let absolute: [UInt8] = [0]              // command 0 -> absolute
            + le16_62(10) + le16_62(20)          // xpos, ypos
            + le16_62(0) + le16_62(0)            // xwobble, ywobble
            + le16_62(0)                         // value0
            + [3]                                // newState
            + le16_62(5)                         // duration
        let body = le32_62(100) + le16_62(1) + [0, 0, 0, 0, 0, 0, 0]
            + le32_62(0) + le16s_62(50) + le16s_62(60) + [1] + absolute
        assertDecodes62(MoveLifeRequest.self, body: body) {
            XCTAssertEqual($0.movements.count, 1)
        }
    }

    // MARK: - Party operation (expel / passLeader via UUID)

    func testPartyOperationUUIDBranches() {
        let uuidBytes = mapleString62(uuidString)
        assertDecodes62(PartyOperationRequest.self, body: [0x05] + uuidBytes) {
            if case .expel = $0 {} else { XCTFail("expected expel") }
        }
        assertDecodes62(PartyOperationRequest.self, body: [0x06] + uuidBytes) {
            if case .passLeader = $0 {} else { XCTFail("expected passLeader") }
        }
    }

    // MARK: - Guild operation branches

    func testGuildOperationBranches() {
        let uuidBytes = mapleString62(uuidString)
        assertDecodes62(GuildOperationRequest.self, body: [0x05] + mapleString62("bob")) {
            XCTAssertEqual($0.type, 5)
            XCTAssertEqual($0.characterName, "bob")
        }
        assertDecodes62(GuildOperationRequest.self, body: [0x06] + le32_62(1234) + uuidBytes) {
            XCTAssertEqual($0.type, 6)
            XCTAssertEqual($0.guildID, 1234)
        }
        assertDecodes62(GuildOperationRequest.self, body: [0x07] + uuidBytes + mapleString62("bob")) {
            XCTAssertEqual($0.type, 7)
            XCTAssertEqual($0.characterName, "bob")
        }
        assertDecodes62(GuildOperationRequest.self, body: [0x0E] + uuidBytes + [3]) {
            XCTAssertEqual($0.type, 0x0E)
            XCTAssertEqual($0.rank, 3)
        }
    }

    // MARK: - Character list (disabled rank + equipment)

    func testCharacterListDisabledRankAndEquipment() {
        let character = CharacterListResponse.Character(
            stats: sampleCharacterStats62(),
            appearance: CharacterListResponse.CharacterAppeareance(
                gender: .male,
                skinColor: .normal,
                face: 20000,
                mega: false,
                hair: 30023,
                equipment: [5: 1040002, 6: 1060002],
                maskedEquipment: [11: 1302000],
                cashWeapon: 0,
                value0: 0,
                value1: 0
            ),
            rank: .disabled
        )
        assertRoundTrip62(CharacterListResponse(characters: [character], maxCharacters: 6))
    }
}
