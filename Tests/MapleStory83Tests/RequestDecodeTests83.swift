//
//  RequestDecodeTests83.swift
//  Decode-path coverage for client->server request packets.
//

import Foundation
import XCTest
@testable import MapleStory
@testable import MapleStory83

final class RequestDecodeTests83: XCTestCase {

    // MARK: - Cash shop / coupon

    func testCashShopRequests() {
        assertDecodes83(CashShopOperationRequest.self, body: [0, 2, 0, 0, 0] + le32_83(0xABCD)) {
            XCTAssertEqual($0.way, 2)
            XCTAssertEqual($0.snCS, 0xABCD)
        }
        assertDecodes83(CouponCodeRequest.self, body: le16_83(0) + mapleString83("HAPPY")) {
            XCTAssertEqual($0.code, "HAPPY")
        }
    }

    // MARK: - Buddy list

    func testBuddyListModify() {
        assertDecodes83(BuddyListModifyRequest.self, body: [1] + mapleString83("bob")) {
            XCTAssertEqual($0, .add(name: "bob"))
        }
        assertDecodes83(BuddyListModifyRequest.self, body: [2] + le32_83(99)) {
            XCTAssertEqual($0, .accept(characterID: 99))
        }
        assertDecodes83(BuddyListModifyRequest.self, body: [3] + le32_83(99)) {
            XCTAssertEqual($0, .remove(characterID: 99))
        }
    }

    // MARK: - Keymap

    func testChangeKeymap() {
        let body = le32_83(0) + le32_83(1) + le32_83(65) + [4] + le32_83(10)
        assertDecodes83(ChangeKeymapRequest.self, body: body) {
            XCTAssertEqual($0.bindings.count, 1)
            XCTAssertEqual($0.bindings.first?.key, 65)
            XCTAssertEqual($0.bindings.first?.type, 4)
            XCTAssertEqual($0.bindings.first?.action, 10)
        }
    }

    // MARK: - Simple single-byte mode requests

    func testSimpleModeRequests() {
        assertDecodes83(MTSOperationRequest.self, body: [3]) { XCTAssertEqual($0.mode, 3) }
        assertDecodes83(MessengerRequest.self, body: [0]) { XCTAssertEqual($0.mode, 0) }
        assertDecodes83(RingActionRequest.self, body: [1]) { XCTAssertEqual($0.mode, 1) }
    }

    // MARK: - Movement (mob / pet / summon)

    func testMovementRequests() {
        let moveLife = le32_83(100) + le16_83(1) + [0, 0, 0, 0, 0, 0, 0] + le32_83(0) + le16s_83(50) + le16s_83(60) + [0]
        assertDecodes83(MoveLifeRequest.self, body: moveLife) {
            XCTAssertEqual($0.objectID, 100)
            XCTAssertEqual($0.moveID, 1)
            XCTAssertEqual($0.startX, 50)
            XCTAssertEqual($0.startY, 60)
            XCTAssertTrue($0.movements.isEmpty)
        }
        // MoveLife with a single absolute movement
        let absolute: [UInt8] = [0]
            + le16_83(10) + le16_83(20)
            + le16_83(0) + le16_83(0)
            + le16_83(0)
            + [3]
            + le16_83(5)
        let moveLifeWithMovement = le32_83(100) + le16_83(1) + [0, 0, 0, 0, 0, 0, 0]
            + le32_83(0) + le16s_83(50) + le16s_83(60) + [1] + absolute
        assertDecodes83(MoveLifeRequest.self, body: moveLifeWithMovement) {
            XCTAssertEqual($0.movements.count, 1)
        }
        assertDecodes83(MovePetRequest.self, body: le32_83(5000000) + le32_83(0) + le16s_83(10) + le16s_83(20)) {
            XCTAssertEqual($0.petID, 5000000)
            XCTAssertEqual($0.startX, 10)
            XCTAssertEqual($0.startY, 20)
        }
        assertDecodes83(MoveSummonRequest.self, body: le32_83(7) + le16s_83(10) + le16s_83(20)) {
            XCTAssertEqual($0.objectID, 7)
            XCTAssertEqual($0.startX, 10)
            XCTAssertEqual($0.startY, 20)
        }
        assertDecodes83(SpawnPetRequest.self, body: le32_83(0) + [1, 0, 1]) {
            XCTAssertEqual($0.slot, 1)
            XCTAssertEqual($0.isLead, 1)
        }
        assertDecodes83(PetLootRequest.self, body: le32_83(5000000) + [UInt8](repeating: 0, count: 13) + le32_83(42)) {
            XCTAssertEqual($0.petID, 5000000)
            XCTAssertEqual($0.objectID, 42)
        }
    }

    // MARK: - Attacks

    func testAttackRequests() {
        assertDecodes83(SummonAttackRequest.self, body: le32_83(0) + le32_83(50) + [1]) {
            XCTAssertEqual($0.objectID, 50)
            XCTAssertEqual($0.numAttacked, 1)
        }
        assertDecodes83(SpecialMoveRequest.self, body: le16s_83(10) + le16s_83(20) + le32_83(1121001) + [30]) {
            XCTAssertEqual($0.oldX, 10)
            XCTAssertEqual($0.oldY, 20)
            XCTAssertEqual($0.skillID, 1121001)
            XCTAssertEqual($0.skillLevel, 30)
        }
        assertDecodes83(TakeDamageRequest.self, body: le32_83(0) + [0xFE, 0] + le32_83(150) + le32_83(9300000) + le32_83(50) + [1]) {
            XCTAssertEqual($0.damage, 150)
            XCTAssertEqual($0.monsterIDFrom, 9300000)
            XCTAssertEqual($0.monsterOID, 50)
            XCTAssertEqual($0.direction, 1)
        }
        // TakeDamage with no monster data (short packet)
        assertDecodes83(TakeDamageRequest.self, body: le32_83(0) + [0xFE, 0] + le32_83(75)) {
            XCTAssertEqual($0.damage, 75)
            XCTAssertEqual($0.monsterIDFrom, 0)
            XCTAssertEqual($0.direction, 0)
        }
    }

    // MARK: - Note / skill macro

    func testNoteAndMacro() {
        assertDecodes83(NoteActionRequest.self, body: [1, 1, 0, 62] + le32_83(77) + [0]) {
            XCTAssertEqual($0.action, 1)
            XCTAssertEqual($0.noteIDs, [77])
        }
        let macroBody = [UInt8(1)] + mapleString83("Macro") + [1] + le32_83(1101004) + le32_83(1101005) + le32_83(0)
        assertDecodes83(SkillMacroRequest.self, body: macroBody) {
            XCTAssertEqual($0.macros.count, 1)
            XCTAssertEqual($0.macros.first?.name, "Macro")
            XCTAssertEqual($0.macros.first?.shout, 1)
        }
    }

    // MARK: - Whisper

    func testWhisperRequests() {
        assertDecodes83(WhisperRequest.self, body: [6] + mapleString83("bob") + mapleString83("hey")) {
            XCTAssertEqual($0.mode, 6)
            XCTAssertEqual($0.target, "bob")
            XCTAssertEqual($0.message, "hey")
        }
        assertDecodes83(WhisperRequest.self, body: [5] + mapleString83("bob")) {
            XCTAssertEqual($0.mode, 5)
            XCTAssertNil($0.message)
        }
    }

    // MARK: - Quest / trock

    func testQuestAndTrock() {
        assertDecodes83(QuestActionRequest.self, body: [1] + le16_83(100) + le32_83(9000000) + le32_83(0)) {
            XCTAssertEqual($0.action, 1)
            XCTAssertEqual($0.questID, 100)
            XCTAssertEqual($0.npcID, 9000000)
        }
        assertDecodes83(QuestActionRequest.self, body: [3] + le16_83(100)) {
            XCTAssertEqual($0.action, 3)
            XCTAssertNil($0.npcID)
        }
        assertDecodes83(QuestActionRequest.self, body: [2] + le16_83(100) + le32_83(5)) {
            XCTAssertEqual($0.action, 2)
            XCTAssertNil($0.npcID)
            XCTAssertEqual($0.selection, 5)
        }
        assertDecodes83(TrockAddMapRequest.self, body: [0, 0] + le32_83(104040000)) {
            XCTAssertEqual($0.type, 0)
            XCTAssertEqual($0.mapID, 104040000)
        }
        assertDecodes83(TrockAddMapRequest.self, body: [1, 1]) {
            XCTAssertEqual($0.type, 1)
            XCTAssertTrue($0.isVIP)
            XCTAssertNil($0.mapID)
        }
    }

    // MARK: - Pin operation

    func testPinOperationRequest() {
        assertDecodes83(PinOperationRequest.self, body: [1, 1] + mapleString83("1234")) {
            XCTAssertEqual($0.value0, 1)
            XCTAssertEqual($0.value1, 1)
            XCTAssertEqual($0.pinCode, "1234")
        }
        assertDecodes83(PinOperationRequest.self, body: [0]) {
            XCTAssertEqual($0.value0, 0)
            XCTAssertNil($0.value1)
            XCTAssertNil($0.pinCode)
        }
    }

    // MARK: - Party operations

    func testPartyOperations() {
        assertDecodes83(PartyOperationRequest.self, body: [0x01]) { XCTAssertEqual($0, .create) }
        assertDecodes83(PartyOperationRequest.self, body: [0x02]) { XCTAssertEqual($0, .leave) }
        assertDecodes83(PartyOperationRequest.self, body: [0x03] + le32_83(1234)) { XCTAssertEqual($0, .accept(partyID: 1234)) }
        assertDecodes83(PartyOperationRequest.self, body: [0x04] + mapleString83("bob")) { XCTAssertEqual($0, .invite(characterName: "bob")) }
        assertDecodes83(PartyOperationRequest.self, body: [0x07]) { XCTAssertEqual($0, .disband) }
        assertDecodes83(PartyOperationRequest.self, body: [0x05] + mapleString83(sampleUUIDString83)) {
            if case .expel = $0 {} else { XCTFail("expected expel") }
        }
        assertDecodes83(PartyOperationRequest.self, body: [0x06] + mapleString83(sampleUUIDString83)) {
            if case .passLeader = $0 {} else { XCTFail("expected passLeader") }
        }
    }

    // MARK: - Guild operations

    func testGuildOperations() {
        assertDecodes83(GuildOperationRequest.self, body: [0x02] + mapleString83("MyGuild")) {
            XCTAssertEqual($0.type, 2)
            XCTAssertEqual($0.guildName, "MyGuild")
        }
        assertDecodes83(GuildOperationRequest.self, body: [0x05] + mapleString83("bob")) {
            XCTAssertEqual($0.type, 5)
            XCTAssertEqual($0.characterName, "bob")
        }
        assertDecodes83(GuildOperationRequest.self, body: [0x10] + mapleString83("notice text")) {
            XCTAssertEqual($0.type, 0x10)
            XCTAssertEqual($0.notice, "notice text")
        }
        assertDecodes83(GuildOperationRequest.self, body: [0x06] + le32_83(1234) + mapleString83(sampleUUIDString83)) {
            XCTAssertEqual($0.type, 6)
            XCTAssertEqual($0.guildID, 1234)
        }
        assertDecodes83(GuildOperationRequest.self, body: [0x07] + mapleString83(sampleUUIDString83) + mapleString83("bob")) {
            XCTAssertEqual($0.type, 7)
            XCTAssertEqual($0.characterName, "bob")
        }
        assertDecodes83(GuildOperationRequest.self, body: [0x0E] + mapleString83(sampleUUIDString83) + [3]) {
            XCTAssertEqual($0.type, 0x0E)
            XCTAssertEqual($0.rank, 3)
        }
        assertDecodes83(GuildOperationRequest.self, body: [0xFF]) {
            XCTAssertEqual($0.type, 0xFF)
            XCTAssertNil($0.guildName)
        }
    }
}
