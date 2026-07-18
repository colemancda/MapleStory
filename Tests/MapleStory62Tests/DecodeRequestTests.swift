//
//  DecodeRequestTests.swift
//  Decode-path coverage for client->server request packets.
//

import Foundation
import XCTest
@testable import MapleStory
@testable import MapleStory62

final class DecodeRequestTests: XCTestCase {

    // MARK: - Character selection

    func testSelectionRequests() {
        assertDecodes62(AllCharactersSelectRequest.self, body: le32_62(14) + [0]) {
            XCTAssertEqual($0.character, 14)
            XCTAssertEqual($0.world, 0)
        }
        assertDecodes62(CharacterSelectRequest.self, body: le32_62(14) + mapleString62("00-00-00")) {
            XCTAssertEqual($0.character, 14)
            XCTAssertEqual($0.macAddresses, "00-00-00")
        }
    }

    // MARK: - Buddy list

    func testBuddyListModify() {
        assertDecodes62(BuddyListModifyRequest.self, body: [1] + mapleString62("bob")) {
            XCTAssertEqual($0, .add(name: "bob"))
        }
        assertDecodes62(BuddyListModifyRequest.self, body: [2] + le32_62(99)) {
            XCTAssertEqual($0, .accept(characterID: 99))
        }
        assertDecodes62(BuddyListModifyRequest.self, body: [3] + le32_62(99)) {
            XCTAssertEqual($0, .remove(characterID: 99))
        }
    }

    // MARK: - Cash shop

    func testCashShopRequests() {
        assertDecodes62(BuyCSItemRequest.self, body: [0, 2, 0, 0, 0] + le32_62(0xABCD)) {
            XCTAssertEqual($0.way, 2)
            XCTAssertEqual($0.snCS, 0xABCD)
        }
        assertDecodes62(CouponCodeRequest.self, body: le16_62(0) + mapleString62("HAPPY")) {
            XCTAssertEqual($0.code, "HAPPY")
        }
    }

    // MARK: - Keymap

    func testChangeKeymap() {
        let body = le32_62(0) + le32_62(1) + le32_62(65) + [4] + le32_62(10)
        assertDecodes62(ChangeKeymapRequest.self, body: body) {
            XCTAssertEqual($0.bindings.count, 1)
            XCTAssertEqual($0.bindings.first?.key, 65)
            XCTAssertEqual($0.bindings.first?.type, 4)
            XCTAssertEqual($0.bindings.first?.action, 10)
        }
    }

    // MARK: - Attacks

    func testAttackRequests() {
        let attackBody = [0, 0x11] + le32_62(1101004) + [0, 5] + le32_62(200) + le32_62(999)
        assertDecodes62(CloseRangeAttackRequest.self, body: attackBody) {
            XCTAssertEqual($0.skillID, 1101004)
            XCTAssertEqual($0.stance, 5)
            XCTAssertEqual($0.targets[200], [999])
            XCTAssertEqual($0.numTargets, 1)
            XCTAssertEqual($0.numDamagePerTarget, 1)
        }
        assertDecodes62(MagicAttackRequest.self, body: attackBody) {
            XCTAssertEqual($0.skillID, 1101004)
            XCTAssertEqual($0.targets[200], [999])
        }
        assertDecodes62(RangedAttackRequest.self, body: attackBody) {
            XCTAssertEqual($0.skillID, 1101004)
            XCTAssertEqual($0.targets[200], [999])
        }
        assertDecodes62(SummonAttackRequest.self, body: le32_62(0) + le32_62(50) + [1]) {
            XCTAssertEqual($0.objectID, 50)
            XCTAssertEqual($0.numAttacked, 1)
        }
        assertDecodes62(SpecialMoveRequest.self, body: le16s_62(10) + le16s_62(20) + le32_62(1121001) + [30]) {
            XCTAssertEqual($0.oldX, 10)
            XCTAssertEqual($0.oldY, 20)
            XCTAssertEqual($0.skillID, 1121001)
            XCTAssertEqual($0.skillLevel, 30)
        }
        assertDecodes62(TakeDamageRequest.self, body: le32_62(0) + [0xFE, 0] + le32_62(150) + le32_62(9300000) + le32_62(50) + [1]) {
            XCTAssertEqual($0.damage, 150)
            XCTAssertEqual($0.monsterIDFrom, 9300000)
            XCTAssertEqual($0.monsterOID, 50)
            XCTAssertEqual($0.direction, 1)
        }
    }

    // MARK: - Movement (mob / pet / summon)

    func testMovementRequests() {
        let moveLife = le32_62(100) + le16_62(1) + [0, 0, 0, 0, 0, 0, 0] + le32_62(0) + le16s_62(50) + le16s_62(60) + [0]
        assertDecodes62(MoveLifeRequest.self, body: moveLife) {
            XCTAssertEqual($0.objectID, 100)
            XCTAssertEqual($0.moveID, 1)
            XCTAssertEqual($0.startX, 50)
            XCTAssertEqual($0.startY, 60)
            XCTAssertTrue($0.movements.isEmpty)
        }
        assertDecodes62(MovePetRequest.self, body: le32_62(5000000) + le32_62(0) + le16s_62(10) + le16s_62(20)) {
            XCTAssertEqual($0.petID, 5000000)
            XCTAssertEqual($0.startX, 10)
            XCTAssertEqual($0.startY, 20)
        }
        assertDecodes62(MoveSummonRequest.self, body: le32_62(7) + le16s_62(10) + le16s_62(20)) {
            XCTAssertEqual($0.objectID, 7)
            XCTAssertEqual($0.startX, 10)
            XCTAssertEqual($0.startY, 20)
        }
        assertDecodes62(SpawnPetRequest.self, body: le32_62(0) + [1, 0, 1]) {
            XCTAssertEqual($0.slot, 1)
            XCTAssertEqual($0.isLead, 1)
        }
        assertDecodes62(PetLootRequest.self, body: le32_62(5000000) + [UInt8](repeating: 0, count: 13) + le32_62(42)) {
            XCTAssertEqual($0.petID, 5000000)
            XCTAssertEqual($0.objectID, 42)
        }
    }

    // MARK: - NPC / Shop

    func testNPCShopRequests() {
        assertDecodes62(NPCShopRequest.self, body: [0] + le16s_62(1) + le32_62(2000000) + le16s_62(5)) {
            XCTAssertEqual($0.mode, 0)
            XCTAssertEqual($0.itemID, 2000000)
            XCTAssertEqual($0.quantity, 5)
        }
        assertDecodes62(NPCShopRequest.self, body: [2] + le16s_62(3)) {
            XCTAssertEqual($0.mode, 2)
            XCTAssertEqual($0.slot, 3)
        }
        assertDecodes62(NPCTalkMoreRequest.self, body: [2, 1] + mapleString62("hello")) {
            XCTAssertEqual($0.lastMessageType, 2)
            XCTAssertEqual($0.returnText, "hello")
        }
        assertDecodes62(NPCTalkMoreRequest.self, body: [0, 1] + le32_62(3)) {
            XCTAssertEqual($0.selection, 3)
        }
        assertDecodes62(NPCActionRequest.self, body: le32_62(0x65) + le16_62(0xFF)) {
            XCTAssertEqual($0, .talk(0x65, 0xFF))
        }
    }

    // MARK: - Storage / Duey / Note

    func testStorageAndDuey() {
        assertDecodes62(StorageRequest.self, body: [7] + le32_62(5000)) {
            XCTAssertEqual($0.mode, 7)
            XCTAssertEqual($0.meso, 5000)
        }
        assertDecodes62(StorageRequest.self, body: [4, 2, 3]) {
            XCTAssertEqual($0.mode, 4)
            XCTAssertEqual($0.inventoryType, 2)
            XCTAssertEqual($0.slot, 3)
        }
        assertDecodes62(DueyActionRequest.self, body: [2, 2, 1, 0] + le16s_62(3) + le32_62(1000) + mapleString62("bob")) {
            XCTAssertEqual($0.type, 2)
            XCTAssertEqual($0.recipientName, "bob")
            XCTAssertEqual($0.mesos, 1000)
        }
        assertDecodes62(DueyActionRequest.self, body: [0]) {
            XCTAssertEqual($0.type, 0)
            XCTAssertNil($0.recipientName)
        }
        assertDecodes62(NoteActionRequest.self, body: [1, 1, 0, 62] + le32_62(77) + [0]) {
            XCTAssertEqual($0.action, 1)
            XCTAssertEqual($0.noteIDs, [77])
        }
    }

    // MARK: - Chat / Whisper

    func testChatRequests() {
        assertDecodes62(PartyChatRequest.self, body: [1, 1] + le32_62(14) + mapleString62("hi")) {
            XCTAssertEqual($0.type, 1)
            XCTAssertEqual($0.recipients, [14])
            XCTAssertEqual($0.message, "hi")
        }
        assertDecodes62(WhisperRequest.self, body: [6] + mapleString62("bob") + mapleString62("hey")) {
            XCTAssertEqual($0.mode, 6)
            XCTAssertEqual($0.target, "bob")
            XCTAssertEqual($0.message, "hey")
        }
        assertDecodes62(WhisperRequest.self, body: [5] + mapleString62("bob")) {
            XCTAssertEqual($0.mode, 5)
            XCTAssertNil($0.message)
        }
        assertDecodes62(MessengerRequest.self, body: [0]) { XCTAssertEqual($0.mode, 0) }
        assertDecodes62(MTSOperationRequest.self, body: [1]) { XCTAssertEqual($0.operation, 1) }
        assertDecodes62(RingActionRequest.self, body: [0]) { XCTAssertEqual($0.mode, 0) }
    }

    // MARK: - Party / Guild operations

    func testPartyGuildRequests() {
        assertDecodes62(PartyOperationRequest.self, body: [0x01]) { XCTAssertEqual($0, .create) }
        assertDecodes62(PartyOperationRequest.self, body: [0x02]) { XCTAssertEqual($0, .leave) }
        assertDecodes62(PartyOperationRequest.self, body: [0x03] + le32_62(1234)) { XCTAssertEqual($0, .accept(partyID: 1234)) }
        assertDecodes62(PartyOperationRequest.self, body: [0x04] + mapleString62("bob")) { XCTAssertEqual($0, .invite(characterName: "bob")) }
        assertDecodes62(PartyOperationRequest.self, body: [0x07]) { XCTAssertEqual($0, .disband) }
        assertDecodes62(GuildOperationRequest.self, body: [0x02] + mapleString62("MyGuild")) {
            XCTAssertEqual($0.type, 2)
            XCTAssertEqual($0.guildName, "MyGuild")
        }
        assertDecodes62(GuildOperationRequest.self, body: [0xFF]) {
            XCTAssertEqual($0.type, 0xFF)
            XCTAssertNil($0.guildName)
        }
    }

    // MARK: - Quest / Trock

    func testQuestAndTrock() {
        assertDecodes62(QuestActionRequest.self, body: [1] + le16_62(100) + le32_62(9000000) + le32_62(0)) {
            XCTAssertEqual($0.action, 1)
            XCTAssertEqual($0.questID, 100)
            XCTAssertEqual($0.npcID, 9000000)
        }
        assertDecodes62(QuestActionRequest.self, body: [3] + le16_62(100)) {
            XCTAssertEqual($0.action, 3)
            XCTAssertNil($0.npcID)
        }
        assertDecodes62(TrockAddMapRequest.self, body: [3, 0] + le32_62(104040000)) {
            XCTAssertEqual($0.mode, 3)
            XCTAssertEqual($0.mapID, 104040000)
        }
        assertDecodes62(TrockAddMapRequest.self, body: [1, 0]) {
            XCTAssertEqual($0.mode, 1)
            XCTAssertNil($0.mapID)
        }
    }

    // MARK: - Player shop / trade / minigame

    func testPlayerShopRequests() {
        assertDecodes62(PlayerShopRequest.self, body: [0x00, 3]) { XCTAssertEqual($0, .createTrade) }
        assertDecodes62(PlayerShopRequest.self, body: [0x00, 4] + mapleString62("shop")) { XCTAssertEqual($0, .createShop(description: "shop")) }
        assertDecodes62(PlayerShopRequest.self, body: [0x00, 1] + mapleString62("omok") + [0, 2]) { XCTAssertEqual($0, .createOmok(description: "omok", pieceType: 2)) }
        assertDecodes62(PlayerShopRequest.self, body: [0x00, 2] + mapleString62("card") + [0, 1]) { XCTAssertEqual($0, .createMatchCard(description: "card", pieceType: 1)) }
        assertDecodes62(PlayerShopRequest.self, body: [0x02] + le32_62(99)) { XCTAssertEqual($0, .invite(targetID: 99)) }
        assertDecodes62(PlayerShopRequest.self, body: [0x03]) { XCTAssertEqual($0, .decline) }
        assertDecodes62(PlayerShopRequest.self, body: [0x04] + le32_62(77)) { XCTAssertEqual($0, .visit(objectID: 77)) }
        assertDecodes62(PlayerShopRequest.self, body: [0x06] + mapleString62("hi")) { XCTAssertEqual($0, .chat(message: "hi")) }
        assertDecodes62(PlayerShopRequest.self, body: [0x0A]) { XCTAssertEqual($0, .exit) }
        assertDecodes62(PlayerShopRequest.self, body: [0x0B]) { XCTAssertEqual($0, .open) }
        assertDecodes62(PlayerShopRequest.self, body: [0x0F] + le32_62(500)) { XCTAssertEqual($0, .setMeso(amount: 500)) }
        assertDecodes62(PlayerShopRequest.self, body: [0x10]) { XCTAssertEqual($0, .confirm) }
        assertDecodes62(PlayerShopRequest.self, body: [0x0E, 2] + le16s_62(1) + le16s_62(3) + [4]) { XCTAssertEqual($0, .setItems(inventoryType: 2, slot: 1, quantity: 3, targetSlot: 4)) }
        assertDecodes62(PlayerShopRequest.self, body: [0x13, 2, 1] + le16s_62(2) + le16s_62(3) + le32_62(100)) { XCTAssertEqual($0, .addItem(inventoryType: 2, slot: 1, bundles: 2, perBundle: 3, price: 100)) }
        assertDecodes62(PlayerShopRequest.self, body: [0x14, 1] + le16s_62(2)) { XCTAssertEqual($0, .buy(slot: 1, quantity: 2)) }
        assertDecodes62(PlayerShopRequest.self, body: [0x18] + le16s_62(4)) { XCTAssertEqual($0, .removeItem(slot: 4)) }
        assertDecodes62(PlayerShopRequest.self, body: [0x2C]) { XCTAssertEqual($0, .ready) }
        assertDecodes62(PlayerShopRequest.self, body: [0x2D]) { XCTAssertEqual($0, .unready) }
        assertDecodes62(PlayerShopRequest.self, body: [0x2E]) { XCTAssertEqual($0, .exitAfterGame) }
        assertDecodes62(PlayerShopRequest.self, body: [0x2F]) { XCTAssertEqual($0, .cancelExit) }
        assertDecodes62(PlayerShopRequest.self, body: [0x30]) { XCTAssertEqual($0, .start) }
        assertDecodes62(PlayerShopRequest.self, body: [0x31]) { XCTAssertEqual($0, .skip) }
        assertDecodes62(PlayerShopRequest.self, body: [0x32] + le32_62(1) + le32_62(2) + [3]) { XCTAssertEqual($0, .moveOmok(x: 1, y: 2, pieceType: 3)) }
        assertDecodes62(PlayerShopRequest.self, body: [0x33]) { XCTAssertEqual($0, .requestTie) }
        assertDecodes62(PlayerShopRequest.self, body: [0x34, 1]) { XCTAssertEqual($0, .answerTie(type: 1)) }
        assertDecodes62(PlayerShopRequest.self, body: [0x35]) { XCTAssertEqual($0, .giveUp) }
        assertDecodes62(PlayerShopRequest.self, body: [0x3E, 1, 2]) { XCTAssertEqual($0, .selectCard(turn: 1, slot: 2)) }
    }

    // MARK: - Skill macro

    func testSkillMacroDecode() {
        let body = [UInt8(1)] + mapleString62("Macro") + [1] + le32_62(1101004) + le32_62(1101005) + le32_62(0)
        assertDecodes62(SkillMacroRequest.self, body: body) {
            XCTAssertEqual($0.macros.count, 1)
            XCTAssertEqual($0.macros.first?.name, "Macro")
            XCTAssertEqual($0.macros.first?.shout, 1)
        }
    }
}
