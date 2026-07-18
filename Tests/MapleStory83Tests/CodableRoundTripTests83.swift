//
//  CodableRoundTripTests83.swift
//  Round-trip coverage for symmetric Codable MapleStory83 packets.
//

import Foundation
import XCTest
@testable import MapleStory
@testable import MapleStory83

final class CodableRoundTripTests83: XCTestCase {

    // MARK: - Login / selection / lobby

    func testLoginLobbyRequests() {
        assertRoundTrip83(AcceptLicenseRequest(value0: 7))
        assertRoundTrip83(AllCharactersRequest())
        assertRoundTrip83(AllCharactersSelectRequest(character: 14, macAddresses: "00-11-22"))
        assertRoundTrip83(AllCharactersWorldSelectedRequest(world: 1))
        assertRoundTrip83(CharacterSelectRequest(character: 14, macAddresses: "mac"))
        assertRoundTrip83(CharInfoRequest(value0: 0, value1: 0, characterID: 14))
        assertRoundTrip83(CheckCashRequest())
        assertRoundTrip83(CheckCharacterNameRequest(name: "Bob"))
        assertRoundTrip83(CheckCharacterNameResponse(name: "Bob", isUsed: true))
        assertRoundTrip83(CheckCharacterNameResponse(name: "Alice", isUsed: false))
        assertRoundTrip83(ClientErrorRequest(error: true, value0: 1, value1: 2))
        assertRoundTrip83(DeleteCharacterRequest(picCode: "000000", character: 14))
        assertRoundTrip83(DeleteCharacterResponse(character: 14, state: 0))
        assertRoundTrip83(EnterCashShopRequest())
        assertRoundTrip83(GuestLoginRequest())
        assertRoundTrip83(PlayerDCRequest())
        assertRoundTrip83(PlayerLoginRequest(character: 14))
        assertRoundTrip83(PlayerUpdateRequest())
        assertRoundTrip83(PingPacket())
        assertRoundTrip83(PongPacket())
        assertRoundTrip83(ReportRequest())
        assertRoundTrip83(ServerListRequest())
        assertRoundTrip83(ServerListRerequest())
        assertRoundTrip83(ServerStatusRequest(world: 0, channel: 0))
        assertRoundTrip83(SetGenderRequest(confirmed: true, gender: .male))
        assertRoundTrip83(SetGenderRequest(confirmed: false, gender: .female))
        assertRoundTrip83(ServerIPResponse(value0: 0, address: .channelServerDefault, character: 14, value1: 0, value2: 0))
    }

    // MARK: - Map / navigation

    func testMapNavigation() {
        assertRoundTrip83(ChangeChannelRequest(channel: 3))
        assertRoundTrip83(ChangeMapRequest(type: 2, targetMap: 100000000, portalName: "portal", value0: 0, value1: 0))
        assertRoundTrip83(ChangeMapSpecialRequest(value0: 0, startwp: "sp", value1: 0, value2: 0))
        assertRoundTrip83(UseDoorRequest(objectID: 5, mode: 0))
        assertRoundTrip83(UseInnerPortalRequest(flag: 0, portalName: "p", targetX: 1, targetY: 2, currentX: 3, currentY: 4))
        assertRoundTrip83(UseReturnScrollRequest(value0: 0, slot: 1, itemID: 2030000))
        assertRoundTrip83(SetFieldNotification(channel: 1, updated1: 0, updated2: 0, mapID: 100000000, spawnPoint: 0, hp: 100, chasing: false, spawnX: 0, spawnY: 0, time: 0))
    }

    // MARK: - Inventory / items

    func testInventoryItems() {
        assertRoundTrip83(ItemMoveRequest(value0: 0, inventoryType: 2, sourceSlot: 1, destinationSlot: 2, quantity: 1))
        assertRoundTrip83(ItemPickupRequest(value0: 0, value1: 0, value2: 0, objectID: 42))
        assertRoundTrip83(MesoDropRequest(value0: 0, amount: 1000))
        assertRoundTrip83(UseItemRequest(value0: 0, slot: 1, itemID: 2000000))
        assertRoundTrip83(UseCatchItemRequest(value0: 0, slot: 1, itemID: 2000000, monsterID: 9300000))
        assertRoundTrip83(UseSkillBookRequest(value0: 0, slot: 1, itemID: 2280000))
        assertRoundTrip83(UseSummonBagRequest(value0: 0, slot: 1, itemID: 2100000))
        assertRoundTrip83(UseUpgradeScrollRequest(value0: 0, slot: 1, destinationSlot: -11, whiteScroll: 0))
    }

    // MARK: - Stats / skills / character

    func testStatsAndSkills() {
        assertRoundTrip83(CancelBuffRequest(skillID: 1001))
        assertRoundTrip83(CancelDebuffRequest())
        assertRoundTrip83(CancelItemEffectRequest(skillID: 2000000))
        assertRoundTrip83(DistributeAPRequest(value0: 0, stat: 64))
        assertRoundTrip83(DistributeSPRequest(value0: 0, skillID: 1001))
        assertRoundTrip83(FaceExpressionRequest(expression: 5))
        assertRoundTrip83(GiveFameRequest(characterID: 14, mode: 1))
        assertRoundTrip83(HealOverTimeRequest(value0: 0, value1: 0, value2: 0, hp: 100, mp: 50, value3: 0))
        assertRoundTrip83(SkillEffectRequest(skillID: 1001, level: 1, flags: 0, speed: 0))
    }

    // MARK: - Combat requests

    func testCombatRequests() {
        assertRoundTrip83(AutoAggroRequest(objectID: 12345))
        assertRoundTrip83(DamageReactorRequest(objectID: 5, characterPosition: 100, stance: 1))
        assertRoundTrip83(DamageSummonRequest(objectID: 5, unkByte: 0, damage: 100, monsterIDFrom: 9300000, stance: 1))
        assertRoundTrip83(MonsterBombRequest(objectID: 5))
        assertRoundTrip83(MonsterCarnivalRequest())
    }

    // MARK: - Pet requests

    func testPetRequests() {
        assertRoundTrip83(PetAutoPotRequest(type: 0, value0: 0, value1: 0, slot: 1, value2: 0, itemID: 2000000))
        assertRoundTrip83(PetChatRequest(petID: 5, value0: 0, value1: 0, message: "meow"))
        assertRoundTrip83(PetCommandRequest(petID: 5, value0: 0, value1: 0, command: 1))
    }

    // MARK: - Party search / social requests

    func testSocialRequests() {
        assertRoundTrip83(PartySearchRegisterRequest())
        assertRoundTrip83(PartySearchStartRequest())
        assertRoundTrip83(PartySearchUpdateRequest())
        assertRoundTrip83(DenyGuildRequest(characterName: "Bob"))
        assertRoundTrip83(DenyPartyRequest(value0: 0, from: "a", to: "b"))
        assertRoundTrip83(GeneralChatRequest(message: "hi", show: true))
        assertRoundTrip83(SpouseChatRequest(recipient: "bob", message: "hi"))
    }

    // MARK: - Chat / whisper / message notifications

    func testChatNotifications() {
        assertRoundTrip83(ChatTextNotification(characterID: 14, isGM: false, message: "hi", show: 1))
        assertRoundTrip83(MultiChatNotification(mode: 1, name: "bob", message: "hi"))
        assertRoundTrip83(WhisperNotification(flag: 0x12, characterName: "bob", channelOrSuccess: 1, fromAdmin: false, message: "hi"))
        assertRoundTrip83(NPCTalkNotification(unknown: 0, npcID: 9000000, messageType: 0, speaker: 0, text: "hello"))
        assertRoundTrip83(NotifyJobChangeNotification(type: 0, jobID: 100, characterName: "bob"))
        assertRoundTrip83(NotifyLevelUpNotification(type: 0, level: 30, characterName: "bob"))
    }

    func testServerMessageNotifications() {
        assertRoundTrip83(ServerMessageNotification.notice(message: "hi"))
        assertRoundTrip83(ServerMessageNotification.popup(message: "hi"))
        assertRoundTrip83(ServerMessageNotification.megaphone(message: "hi"))
        assertRoundTrip83(ServerMessageNotification.superMegaphone(message: "hi", channel: 1, megaEarphone: true))
        assertRoundTrip83(ServerMessageNotification.topScrolling(message: "hi"))
        assertRoundTrip83(ServerMessageNotification.pinkText(message: "hi"))
        assertRoundTrip83(ServerMessageNotification.lightBlueText(message: "hi"))
    }

    // MARK: - Map object notifications

    func testMapObjectNotifications() {
        assertRoundTrip83(ConfirmShopTransactionNotification(code: 0))
        assertRoundTrip83(DestroyHiredMerchantNotification(ownerID: 14))
        assertRoundTrip83(DropItemFromMapObjectNotification(mod: 0, objectID: 5, isMeso: false, itemID: 2000000, ownerID: 14, dropType: 2, x: 10, y: 20, dropperObjectID: 6))
        assertRoundTrip83(OpenNPCShopNotification(shopID: 1, items: [
            OpenNPCShopNotification.ShopItem(itemID: 2000000, price: 100, pitch: 0, unknown1: 0, unknown2: 0, stackSize: 100, buyable: 1)
        ]))
        assertRoundTrip83(RemoveDoorNotification(unknown: 0, ownerID: 14))
        assertRoundTrip83(RemoveDragonNotification(ownerCharacterID: 14))
        assertRoundTrip83(RemoveItemFromMapNotification(animation: 2, objectID: 5, characterID: 14, petSlot: 1))
        assertRoundTrip83(RemoveMistNotification(objectID: 5))
        assertRoundTrip83(RemoveNPCNotification(objectID: 5))
        assertRoundTrip83(RemovePlayerFromMapNotification(characterID: 14))
        assertRoundTrip83(RemoveSummonNotification(ownerCharacterID: 14, summonObjectID: 5, animationType: 4))
        assertRoundTrip83(SpawnDoorNotification(launched: false, ownerID: 14, x: 10, y: 20))
        assertRoundTrip83(SpawnDragonNotification(ownerCharacterID: 14, x: 10, unknown1: 0, y: 20, unknown2: 0, stance: 0, unknown3: 0, jobID: 2200))
        assertRoundTrip83(SpawnHiredMerchantNotification(ownerID: 14, itemID: 5030000, x: 10, y: 20, unknown: 0, ownerName: "bob", unknown2: 0, objectID: 5, description: "shop", itemIDMod: 0))
        assertRoundTrip83(SpawnMistNotification(objectID: 5, mistType: 0, ownerID: 14, skillID: 1000, skillLevel: 1, skillDelay: 0, left: 0, top: 0, right: 100, bottom: 100, unknown: 0))
        assertRoundTrip83(SpawnNPCNotification(objectID: 5, npcID: 9000000, x: 10, cy: 20, facingRight: true, fh: 1, rx0: 0, rx1: 100, miniMap: 1))
        assertRoundTrip83(SpawnNPCRequestControllerNotification(mode: 1, objectID: 5, npcID: 9000000, x: 10, cy: 20, facingRight: true, fh: 1, rx0: 0, rx1: 100, miniMap: true))
        assertRoundTrip83(SpawnPortalNotification(townID: 100000000, targetID: 200000000, x: 10, y: 20))
        assertRoundTrip83(SpawnSummonNotification(ownerCharacterID: 14, summonObjectID: 5, skillID: 3000, unknown: 0, skillLevel: 1, x: 10, y: 20, stance: 0, unknown2: 0, movementType: 1, canAttack: true, isNotAnimated: false))
    }

    // MARK: - Reactor notifications

    func testReactorNotifications() {
        assertRoundTrip83(ReactorDestroyNotification(objectID: 5, state: 1, x: 10, y: 20))
        assertRoundTrip83(ReactorHitNotification(objectID: 5, state: 1, x: 10, y: 20, stance: 0, unknown: 0, frameDelay: 5))
        assertRoundTrip83(ReactorSpawnNotification(objectID: 5, reactorID: 200, state: 0, x: 10, y: 20, unknown: 0, unknown2: 0))
    }

    // MARK: - Combat / stat notifications

    func testCombatNotifications() {
        assertRoundTrip83(DamageMonsterNotification(objectID: 5, unknown: 0, damage: 100, currentHP: 50, maxHP: 100))
        assertRoundTrip83(DamagePlayerNotification(characterID: 14, skill: -1, unknown: 5, damage: 100, monsterIDFrom: 9300000, direction: 1))
        assertRoundTrip83(FacialExpressionNotification(characterID: 14, expression: 3))
        assertRoundTrip83(ShowComboNotification(count: 5))
        assertRoundTrip83(ShowForeignEffectNotification(characterID: 14, effect: 1))
        assertRoundTrip83(ShowMonsterHPNotification(objectID: 5, remainingHPPercent: 50))
        assertRoundTrip83(ShowScrollEffectNotification(characterID: 14, success: true, curse: false, legendarySpirit: false, whiteScroll: false))
        assertRoundTrip83(SkillCooldownNotification(skillID: 1001, time: 30))
        assertRoundTrip83(SummonAttackNotification(characterID: 14, summonObjectID: 5, charLevel: 1, direction: 0, targets: [
            SummonAttackNotification.Target(monsterObjectID: 6, unknown: 0, damage: 100)
        ]))
        assertRoundTrip83(UpdatePartyMemberHPNotification(characterID: 14, currentHP: 100, maxHP: 250))
        assertRoundTrip83(UpdateQuestInfoNotification(questID: 100, state: .started, progress: "x"))
    }

    // MARK: - Attack notifications (optional skill / targets)

    func testAttackNotifications() {
        let closeTargets = [
            CloseRangeAttackNotification.AttackTarget(monsterObjectID: 5, unknown: 0, damageLines: [100, 200])
        ]
        assertRoundTrip83(CloseRangeAttackNotification(
            characterID: 14, numAttackedAndDamage: 0x11, unknown: 0, skillLevel: 1,
            skillID: 1101004, display: 0, direction: 0, stance: 5, speed: 0, unknown2: 0,
            projectile: 0, targets: closeTargets
        ))
        let magicTargets = [
            MagicAttackNotification.AttackTarget(monsterObjectID: 5, unknown: 0, damageLines: [100])
        ]
        assertRoundTrip83(MagicAttackNotification(
            characterID: 14, numAttackedAndDamage: 0x11, unknown: 0, skillLevel: 1,
            skillID: 2001005, display: 0, direction: 0, stance: 5, speed: 0, unknown2: 0,
            projectile: 0, targets: magicTargets, charge: 1
        ))
        let rangedTargets = [
            RangedAttackNotification.AttackTarget(monsterObjectID: 5, unknown: 0, damageLines: [100])
        ]
        assertRoundTrip83(RangedAttackNotification(
            characterID: 14, numAttackedAndDamage: 0x11, unknown: 0, skillLevel: 1,
            skillID: 3101003, display: 0, direction: 0, stance: 5, speed: 0, unknown2: 0,
            projectile: 2070000, targets: rangedTargets, unknown3: 0
        ))
    }

    // MARK: - Movement notifications / requests

    func testMovementPackets() {
        let movements = [sampleMovement83()]
        assertRoundTrip83(MoveDragonNotification(ownerCharacterID: 14, startX: 10, startY: 20, movements: movements))
        assertRoundTrip83(MoveMonsterNotification(
            objectID: 5, unknown: 0, skillPossible: false, skill: 0, skillID: 0,
            skillLevel: 0, pOption: 0, startX: 10, startY: 20, movements: movements
        ))
        assertRoundTrip83(MoveMonsterResponseNotification(objectID: 5, moveID: 1, useSkills: false, currentMP: 0, skillID: 0, skillLevel: 0))
        assertRoundTrip83(MovePetNotification(characterID: 14, slot: 0, petID: 5, movementData: movements))
        assertRoundTrip83(MovePlayerNotification(characterID: 14, unknown: 0, movements: movements))
        assertRoundTrip83(MovePlayerRequest(value0: 0, value1: 0, movements: movements, value2: 0, value3: 0, value4: 0))
        assertRoundTrip83(MoveSummonNotification(characterID: 14, summonObjectID: 5, startX: 10, startY: 20, movements: movements))
    }

    // MARK: - Misc Codable packets

    func testMiscCodable() {
        assertRoundTrip83(PinOperationResponse(status: .success))
        assertRoundTrip83(PinOperationResponse(status: .register))
        assertRoundTrip83(PetChatNotification(characterID: 14, slot: 0, unknown: 0, text: "meow"))
    }

    func testBBSOperationRequestRoundTrip() {
        assertRoundTrip83(BBSOperationRequest.new(notice: true, title: "t", body: "b", icon: 3))
        assertRoundTrip83(BBSOperationRequest.edit(id: 5, notice: false, title: "t2", body: "b2", icon: 1))
        assertRoundTrip83(BBSOperationRequest.delete(id: 5))
        assertRoundTrip83(BBSOperationRequest.list(id: 5))
        assertRoundTrip83(BBSOperationRequest.listReply(id: 5))
        assertRoundTrip83(BBSOperationRequest.reply(id: 5, body: "reply"))
        assertRoundTrip83(BBSOperationRequest.deleteReply(id: 5, reply: 9))
    }

    // MARK: - Movement variants for Movement enum coverage

    func testMovementVariants() {
        let variants: [Movement] = [
            .absolute(Movement.Absolute(command: 0, xpos: 1, ypos: 2, xwobble: 0, ywobble: 0, value0: 0, newState: 1, duration: 1)),
            .relative(Movement.Relative(command: 1, xmod: 3, ymod: 4, newState: 2, duration: 1)),
            .teleport(Movement.Teleport(command: 3, xpos: 5, ypos: 6, xwobble: 0, ywobble: 0, newState: 3)),
            .changeEquipment(Movement.ChangeEquipment(command: 10, wui: 7)),
            .chair(Movement.Chair(command: 11, xpos: 8, ypos: 9, value0: 0, newState: 4, duration: 2)),
            .jumpDown(Movement.JumpDown(command: 15, xpos: 10, ypos: 11, xwobble: 0, ywobble: 0, value0: 0, fh: 5, newState: 5, duration: 3))
        ]
        assertRoundTrip83(MovePlayerNotification(characterID: 14, unknown: 0, movements: variants))
        // exercise finalPosition helper
        XCTAssertNotNil(variants.finalPosition)
    }
}
