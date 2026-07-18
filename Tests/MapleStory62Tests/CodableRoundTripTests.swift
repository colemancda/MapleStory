//
//  CodableRoundTripTests.swift
//  Round-trip (encode + decode) coverage for Codable MapleStory62 packets.
//

import Foundation
import XCTest
@testable import MapleStory
@testable import MapleStory62

final class CodableRoundTripTests: XCTestCase {

    // MARK: - Login / Account

    func testAccountPackets() {
        assertRoundTrip62(AcceptLicenseRequest(value0: 1))
        assertRoundTrip62(AllCharactersRequest())
        assertRoundTrip62(AllCharactersWorldSelectedRequest(world: 0))
        assertRoundTrip62(GuestLoginRequest())
        assertRoundTrip62(PinOperationRequest(value0: 1, value1: 1))
        assertRoundTrip62(PinOperationResponse.success)
        assertRoundTrip62(PinOperationResponse.register)
        assertRoundTrip62(PinOperationResponse.enterPin)
        assertRoundTrip62(PlayerDCRequest())
        assertRoundTrip62(PlayerUpdateRequest())
        assertRoundTrip62(RelogRequest())
        assertRoundTrip62(RelogResponse())
        assertRoundTrip62(ReportRequest())
        assertRoundTrip62(EnterCashShopRequest())
        assertRoundTrip62(EnterMTSRequest())
        assertRoundTrip62(TouchingCSRequest())
        assertRoundTrip62(SetGenderRequest(confirmed: true, gender: .female))
        assertRoundTrip62(ServerStatusRequest(world: 0, channel: 1))
        assertRoundTrip62(ServerStatusResponse.normal)
        assertRoundTrip62(ServerStatusResponse.highUsage)
        assertRoundTrip62(ServerStatusResponse.full)
        assertRoundTrip62(ClientErrorRequest(error: true, value0: 100, value1: 0))
        assertRoundTrip62(ClientStartError(error: "boom"))
        assertRoundTrip62(ServerIPResponse(
            address: MapleStoryAddress(address: "8.31.99.141", port: 8484)!,
            character: 14
        ))
    }

    // MARK: - Character List / Creation

    func testCharacterPackets() {
        assertRoundTrip62(CharacterListRequest(world: 0, channel: 0))
        assertRoundTrip62(CharacterListResponse(characters: [sampleCharacter62()], maxCharacters: 6))
        assertRoundTrip62(CreateCharacterRequest(
            name: "Hero", face: 20000, hair: 30000, hairColor: 0, skinColor: 0,
            top: 1040002, bottom: 1060002, shoes: 1072001, weapon: 1302000,
            gender: .male, str: 12, dex: 5, int: 4, luk: 4
        ))
        assertRoundTrip62(CreateCharacterResponse(error: false, character: sampleCharacter62()))
        assertRoundTrip62(CheckCharacterNameRequest(name: "Hero"))
        assertRoundTrip62(CheckCharacterNameResponse(name: "Hero", isUsed: true))
        assertRoundTrip62(DeleteCharacterRequest(date: 20240504, character: 14))
        assertRoundTrip62(DeleteCharacterResponse(character: 14, state: 0))
        assertRoundTrip62(AllCharactersResponse.count(3))
        assertRoundTrip62(AllCharactersResponse.characters(world: 0, characters: [sampleCharacter62()]))
    }

    // MARK: - Movement

    func testMovementPackets() {
        let movements: [Movement] = [
            .absolute(.init(command: 0, xpos: 100, ypos: 200, xwobble: 0, ywobble: 0, value0: 0, newState: 3, duration: 10)),
            .relative(.init(command: 1, xmod: 5, ymod: 6, newState: 2, duration: 8)),
            .teleport(.init(command: 3, xpos: 50, ypos: 60, xwobble: 0, ywobble: 0, newState: 1)),
            .chair(.init(command: 11, xpos: 12, ypos: 13, value0: 0, newState: 0, duration: 4)),
            .jumpDown(.init(command: 15, xpos: 1, ypos: 2, xwobble: 3, ywobble: 4, value0: 0, fh: 9, newState: 1, duration: 2)),
            .changeEquipment(.init(command: 10, wui: 5))
        ]
        assertRoundTrip62(MovePlayerNotification(characterID: 14, movements: movements))
        assertRoundTrip62(MovePlayerRequest(value0: 0, value1: 0, movements: movements, value2: 0, value3: 0, value4: 0))
        // final position helper
        let pos = movements.finalPosition
        XCTAssertNotNil(pos)
    }

    // MARK: - Inventory / Item

    func testItemPackets() {
        assertRoundTrip62(ItemMoveRequest(value0: 0, inventoryType: 2, sourceSlot: 1, destinationSlot: -5, quantity: 1))
        assertRoundTrip62(ItemPickupRequest(value0: 0, value1: 0, value2: 0, objectID: 42))
        assertRoundTrip62(ItemSortRequest(value0: 0, inventoryType: .use))
        assertRoundTrip62(MesoDropRequest(value0: 0, amount: 1000))
        assertRoundTrip62(UseItemRequest(value0: 0, slot: 3, itemID: 2000000))
        assertRoundTrip62(UseItemEffectRequest(itemID: 5000000))
        assertRoundTrip62(UseCashItemRequest(mode: 1, value0: 0, itemID: 5010000))
        assertRoundTrip62(UseCatchItemRequest(value0: 0, slot: 2, itemID: 2270000, monsterID: 9304000))
        assertRoundTrip62(UseChairRequest(itemID: 3010000))
        assertRoundTrip62(UseDoorRequest(objectID: 1, mode: 0))
        assertRoundTrip62(UseMountFoodRequest(value0: 0, slot: 1, itemID: 2260000))
        assertRoundTrip62(UseReturnScrollRequest(value0: 0, slot: 4, itemID: 2030000))
        assertRoundTrip62(UseSkillBookRequest(value0: 0, slot: 5, itemID: 2280000))
        assertRoundTrip62(UseSkillBookNotification(skillID: 1000, currentLevel: 1, masteryLevel: 20, success: true))
        assertRoundTrip62(UseSummonBagRequest(value0: 0, slot: 6, itemID: 2101000))
        assertRoundTrip62(UseUpgradeScrollRequest(value0: 0, slot: 7, destinationSlot: -1, whiteScroll: 0))
        assertRoundTrip62(RemoveItemFromMapNotification(animation: 1, objectID: 99))
        assertRoundTrip62(DropItemFromMapobjectNotification(
            source: 0, objectID: 12, itemID: 2000000, quantity: 3,
            ownerID: 14, ownerType: 0, x: 100, y: 200, timestamp: 123456
        ))
        assertRoundTrip62(ConfirmShopTransactionNotification(mode: 0, slot: 1, itemID: 2000000, quantity: 5))
        assertRoundTrip62(OpenNPCShopNotification(npcID: 9000000, items: [
            ShopItemEntry(itemID: 2000000, price: 100, stock: 0),
            ShopItemEntry(itemID: 2000001, price: 200, stock: 50)
        ]))
        assertRoundTrip62(OpenStorageNotification(
            npcID: 1002005, mesos: 5000, slots: 2, maxSlots: 16,
            items: [StorageItemEntry(slot: 0, itemID: 2000000, quantity: 10)]
        ))
    }

    // MARK: - Combat / Skills

    func testCombatPackets() {
        assertRoundTrip62(CancelBuffNotification(skillID: 1101006))
        assertRoundTrip62(CancelBuffRequest(skillID: 1101006))
        assertRoundTrip62(CancelItemEffectRequest(skillID: 2000000))
        assertRoundTrip62(CancelDebuffRequest())
        assertRoundTrip62(GiveBuffNotification(skillID: 1101006, level: 10, duration: 200, buffStats: 0x40))
        assertRoundTrip62(SkillEffectNotification(characterID: 14, skillID: 1101006, level: 10, flags: 0, speed: 0))
        assertRoundTrip62(SkillEffectRequest(skillID: 1101006, level: 10, flags: 0, speed: 0))
        assertRoundTrip62(DamageReactorRequest(objectID: 5, characterPosition: 100, stance: 0))
        assertRoundTrip62(DamageSummonRequest(value0: 0, unkByte: 0, damage: 500, monsterIDFrom: 9, stance: 1))
        assertRoundTrip62(SummonAttackNotification(characterID: 14, objectID: 20, numAttacked: 1))
        assertRoundTrip62(MonsterBombRequest(objectID: 33))
        assertRoundTrip62(AutoAggroRequest(objectID: 44))
        assertRoundTrip62(HealOverTimeRequest(value0: 0, value1: 0x14, value2: 0, hp: 0, mp: 3, value3: 0))
        assertRoundTrip62(DistributeAPRequest(value0: 0, stat: 64))
        assertRoundTrip62(DistributeSPRequest(value0: 0, skillID: 1000001))
        assertRoundTrip62(KeyMapNotification(keyMap: [
            2: KeyBinding(type: 4, action: 10),
            25: KeyBinding(type: 5, action: 51)
        ]))
    }

    // MARK: - Map / Movement Requests

    func testMapPackets() {
        assertRoundTrip62(ChangeChannelRequest(channel: 2))
        assertRoundTrip62(ChangeMapRequest(type: 2, targetMap: 0x3B9AC9FF, portalName: "west00", value0: 0, value1: 0))
        assertRoundTrip62(ChangeMapSpecialRequest(value0: 0, startwp: "sp", value1: 0, value2: 0))
        assertRoundTrip62(UseInnerPortalRequest(flag: 0, portalName: "p1", targetX: 10, targetY: 20, currentX: 30, currentY: 40))
        assertRoundTrip62(SpawnNPCNotification(objectId: 100, id: 2100, x: 65371, cy: 53, f: true, fh: 11, rx0: 65323, rx1: 65421, value0: 1))
        assertRoundTrip62(SpawnNPCRequestControllerNotification(value0: 1, objectId: 100, id: 2100, x: 65371, cy: 53, f: true, fh: 11, rx0: 65323, rx1: 65421, minimap: true))
        assertRoundTrip62(PlayerHintNotification(hint: "hello", width: 100, height: 50))
        assertRoundTrip62(ShowChairNotification(characterID: 14, itemID: 3010000))
        assertRoundTrip62(CancelChairNotification(characterID: 14))
        assertRoundTrip62(CancelChairRequest(id: -1))
        assertRoundTrip62(CloseChalkboardRequest())
    }

    // MARK: - NPC / Chat

    func testNPCAndChatPackets() {
        assertRoundTrip62(NPCTalkRequest(objectID: 100, value0: 0))
        assertRoundTrip62(NPCTalkNotification.dialog(npc: 2100, message: "hi", buttons: [.next, .previous]))
        assertRoundTrip62(NPCTalkNotification.confirmation(npc: 2100, message: "yes?"))
        assertRoundTrip62(NPCTalkNotification.getText(npc: 2100, message: "enter"))
        assertRoundTrip62(NPCTalkNotification.number(npc: 2100, message: "n", default: 1, min: 0, max: 10))
        assertRoundTrip62(NPCTalkNotification.simple(npc: 2100, message: "s"))
        assertRoundTrip62(NPCTalkNotification.styles(npc: 2100, message: "st", styles: [1, 2, 3]))
        assertRoundTrip62(NPCTalkNotification.accept(npc: 2100, message: "a"))
        assertRoundTrip62(GeneralChatRequest(message: "hello world", show: true))
        assertRoundTrip62(ChatTextNotification(characterID: 14, isAdmin: false, message: "hi", show: true))
        assertRoundTrip62(SpouseChatRequest(recipient: "wife", message: "love"))
        assertRoundTrip62(WhisperNotification(sender: "bob", message: "hey"))
        assertRoundTrip62(ServerMessageNotification.notice(message: "notice"))
        assertRoundTrip62(ServerMessageNotification.popup(message: "popup"))
        assertRoundTrip62(ServerMessageNotification.megaphone(message: "mega"))
        assertRoundTrip62(ServerMessageNotification.superMegaphone(message: "sm", channel: 1, megaEarphone: true))
        assertRoundTrip62(ServerMessageNotification.topScrolling(message: "top"))
        assertRoundTrip62(ServerMessageNotification.pinkText(message: "pink"))
        assertRoundTrip62(ServerMessageNotification.lightBlueText(message: "blue"))
    }

    // MARK: - Pet

    func testPetPackets() {
        assertRoundTrip62(PetChatRequest(petID: 5000000, value0: 0, value1: 0, message: "meow"))
        assertRoundTrip62(PetCommandRequest(petID: 5000000, value0: 0, value1: 0, command: 1))
        assertRoundTrip62(PetFoodRequest(value0: 0, value1: 0, itemID: 2120000))
        assertRoundTrip62(PetTalkRequest())
        assertRoundTrip62(PetAutoPotRequest(type: 1, value0: 0, value1: 0, slot: 2, value2: 0, itemID: 2000000))
    }

    // MARK: - Party / Guild

    func testPartyGuildPackets() {
        assertRoundTrip62(PartySearchRegisterRequest())
        assertRoundTrip62(PartySearchStartRequest())
        assertRoundTrip62(PartyOperationNotification(operation: .create, partyID: 12345, members: []))
        assertRoundTrip62(PartyOperationNotification(operation: .disband, partyID: 999, members: []))
        assertRoundTrip62(GuildOperationNotification(operation: .create, guildID: 5678))
        assertRoundTrip62(GuildOperationNotification(operation: .disband, guildID: 1))
    }

    // MARK: - Quest / Misc

    func testMiscPackets() {
        assertRoundTrip62(FaceExpressionRequest(emote: 5))
        assertRoundTrip62(GiveFameRequest(characterID: 14, mode: 1))
        assertRoundTrip62(MapleTVRequest(message: "tv", value0: 0, value1: 0))
        assertRoundTrip62(ShowItemEffectNotification(characterID: 14, itemID: 5000000))
        assertRoundTrip62(ShowScrollEffectNotification(characterID: 14, result: .success, position: -1))
        assertRoundTrip62(ShowScrollEffectNotification(characterID: 14, result: .failure, position: -1))
        assertRoundTrip62(ShowScrollEffectNotification(characterID: 14, result: .destroyed, position: -1))
        assertRoundTrip62(ShowQuestCompletionNotification(questID: 100, selection: 0, expReward: 1000, mesoReward: 500, items: [2000000: 1]))
        assertRoundTrip62(UpdateQuestInfoNotification(questID: 100, state: .started, progress: "000"))
        assertRoundTrip62(DenyGuildRequest(value0: 0, from: "bob"))
        assertRoundTrip62(DenyPartyRequest(value0: 0, from: "bob", to: "alice"))
        let timestamp = Date(timeIntervalSince1970: 1_600_000_000)
        assertRoundTrip62(ShowNotesNotification(value0: 2, notes: [
            .init(id: 1, from: "bob", message: "hi", timestamp: timestamp, value0: 0)
        ]))
        assertRoundTrip62(WarpToMapNotification.characterInfo(.init(
            channel: 0, random0: 1, random1: 2, random2: 3,
            stats: sampleCharacterStats62(), buddyListSize: 20, meso: 13,
            equipSlots: 100, useSlots: 100, setupSlots: 100, etcSlots: 100, cashSlots: 100
        )))
    }

    // MARK: - BBS

    func testBBSRequestPackets() {
        assertRoundTrip62(BBSOperationRequest.new(notice: true, title: "t", body: "b", icon: 0))
        assertRoundTrip62(BBSOperationRequest.edit(id: 5, notice: false, title: "t2", body: "b2", icon: 1))
        assertRoundTrip62(BBSOperationRequest.delete(id: 5))
        assertRoundTrip62(BBSOperationRequest.list(id: 0))
        assertRoundTrip62(BBSOperationRequest.listReply(id: 0))
        assertRoundTrip62(BBSOperationRequest.reply(id: 5, body: "reply"))
        assertRoundTrip62(BBSOperationRequest.deleteReply(id: 5, reply: 2))
    }
}
