//
//  EncodeNotificationTests.swift
//  Encode-path coverage for server->client notification packets.
//

import Foundation
import XCTest
@testable import MapleStory
@testable import MapleStory62

final class EncodeNotificationTests: XCTestCase {

    // MARK: - Login / List (encode-only enums)

    func testLoginAndListResponses() {
        assertEncodes62(LoginResponse.success(username: "admin"))
        assertEncodes62(LoginResponse.failure(reason: .invalidPassword))
        assertEncodes62(LoginResponse.failure(reason: .alreadyLoggedIn))
        assertEncodes62(ServerListResponse.world(.init(
            id: 0, name: " World 0", flags: 2, eventMessage: "", rateModifier: 100,
            eventXP: 0, rateModifier2: 100, dropRate: 0, value0: 0,
            channels: [ServerListResponse.Channel(name: " World 0-1", load: 0, value0: 1, id: 0)],
            value1: 0
        )))
        assertEncodes62(ServerListResponse.end)
    }

    // MARK: - Inventory

    func testModifyInventoryItem() {
        let item = InventoryItem(itemId: 2000000, slot: 3, quantity: 5)
        assertEncodes62(ModifyInventoryItemNotification.add(item: item, inventoryType: .use))
        assertEncodes62(ModifyInventoryItemNotification.update(item: item, inventoryType: .use, quantity: 10))
        assertEncodes62(ModifyInventoryItemNotification.move(item: item, fromSlot: 3, toSlot: 4, inventoryType: .use))
        assertEncodes62(ModifyInventoryItemNotification.remove(inventoryType: .use, slot: 3, itemId: 2000000))
        let equipItem = InventoryItem(
            itemId: 1302000, slot: -11, quantity: 1,
            equip: EquipData(slot: -11, str: 5, dex: 3, weaponAttack: 17, owner: "owner")
        )
        assertEncodes62(ModifyInventoryItemNotification.add(item: equipItem, inventoryType: .equip))
    }

    // MARK: - NPC / Chat

    func testNPCAndChat() {
        assertEncodes62(NPCActionResponse.talk(0x65, 0xFF))
        assertEncodes62(NPCActionResponse.move(Data([1, 2, 3, 4])))
        assertEncodes62(MultichatNotification(mode: 0, name: "bob", message: "hi"))
        assertEncodes62(SpousechatNotification(sender: "bob", message: "hi"))
        assertEncodes62(ChalkboardNotification.open(characterID: 14, message: "sale"))
        assertEncodes62(ChalkboardNotification.close(characterID: 14))
    }

    // MARK: - Buddy / Fame

    func testBuddyAndFame() {
        assertEncodes62(BuddyListNotification.update([
            BuddyListNotification.Buddy(id: 1, name: CharacterName(rawValue: "bob")!, value0: 0, channel: 1)
        ]))
        assertEncodes62(BuddyListRequestNotification(characterID: 2, characterName: CharacterName(rawValue: "alice")!))
        assertEncodes62(FameResponseNotification.success(targetName: CharacterName(rawValue: "bob")!, mode: 1, newFame: 10))
        assertEncodes62(FameResponseNotification.error(3))
        assertEncodes62(FameResponseNotification.received(fromName: CharacterName(rawValue: "alice")!, mode: 1))
    }

    // MARK: - Monster / Reactor

    func testMonsterAndReactor() {
        assertEncodes62(DamageMonsterNotification(objectID: 5, damageType: 0, damage: 100))
        assertEncodes62(KillMonsterNotification(objectID: 5, animation: 1))
        assertEncodes62(CatchMonsterNotification(mobID: 9304000, itemID: 2270000, success: 1))
        assertEncodes62(ShowMonsterHPNotification(objectID: 5, remainingHPPercent: 50))
        assertEncodes62(ShowMagnetNotification(mobID: 5, success: 1))
        assertEncodes62(SpawnMonsterNotification(mob: sampleMob62()))
        assertEncodes62(SpawnMonsterControl(control: 2, mob: sampleMob62()))
        assertEncodes62(MoveMonsterNotification(
            objectID: 5, skillByte: 0, skill: 0, skillID: 0, skillLevel: 0, skillParam: 0,
            startX: 100, startY: 200, movements: [
                .absolute(.init(command: 0, xpos: 1, ypos: 2, xwobble: 0, ywobble: 0, value0: 0, newState: 0, duration: 1))
            ]
        ))
        assertEncodes62(MoveMonsterResponse(objectID: 5, moveID: 1, useSkill: false, mp: 0, skillID: 0, skillLevel: 0))
        assertEncodes62(ReactorDestroyNotification(objectID: 5, state: 1, x: 10, y: 20))
        assertEncodes62(ReactorHitNotification(objectID: 5, state: 1, x: 10, y: 20, stance: 0, frameDelay: 5))
        assertEncodes62(ReactorSpawnNotification(objectID: 5, reactorID: 200, state: 0, x: 10, y: 20))
    }

    // MARK: - Map objects

    func testMapObjects() {
        assertEncodes62(SpawnDoorNotification(inTown: false, objectID: 5, x: 10, y: 20))
        assertEncodes62(RemoveDoorNotification(inTown: false, objectID: 5))
        assertEncodes62(SpawnMistNotification(objectID: 5, ownerCharacterID: 14, skillID: 1000, level: 1, x1: 0, y1: 0, x2: 100, y2: 100))
        assertEncodes62(RemoveMistNotification(objectID: 5))
        assertEncodes62(SpawnPortalNotification(townID: 100000000, targetID: 200000000))
        assertEncodes62(SpawnPortalNotification(townID: 100000000, targetID: 200000000, positionX: 10, positionY: 20))
        assertEncodes62(ChangeChannelNotification(responseCode: 1, address: [8, 31, 99, 141], port: 8585))
        assertEncodes62(BoatEffectNotification(effect: 1))
        assertEncodes62(EnableTvNotification(value0: 0, value1: 0))
        assertEncodes62(CancelTvSmegaNotification())
    }

    // MARK: - Pet

    func testPetNotifications() {
        assertEncodes62(PetChatNotification(characterID: 14, slot: 0, unknown: 0, text: "meow"))
        assertEncodes62(PetCommandNotification(characterID: 14, slot: 0, isFoodCommand: false, command: 1, success: true))
        assertEncodes62(PetCommandNotification(characterID: 14, slot: 0, isFoodCommand: true, command: 1, success: true))
        assertEncodes62(PetNameChangeNotification(characterID: 14, newName: "Fido"))
        assertEncodes62(MovePetNotification(characterID: 14, slot: 0, petID: 5000000, movementData: [0, 1, 2]))
        assertEncodes62(SpawnPetNotification(characterID: 14, slot: 0, remove: true))
        assertEncodes62(SpawnPetNotification(
            characterID: 14, slot: 0, remove: false, hunger: false, itemID: 5000000,
            name: "Fido", uniqueID: 1, positionX: 10, positionY: 20, stance: 0, foothold: 5
        ))
    }

    // MARK: - Buffs / Stats / Skills

    func testBuffAndStats() {
        assertEncodes62(CancelSkillEffectNotification(characterID: 14, skillID: 1000))
        assertEncodes62(SummonSkillNotification(characterID: 14, summonSkillID: 3000, newStance: 1))
        assertEncodes62(DamageSummonNotification(characterID: 14, summonSkillID: 3000, unknownByte: 0, damage: 100, monsterIDFrom: 5))
        assertEncodes62(FacialExpressionNotification(characterID: 14, expression: 1))
        assertEncodes62(CooldownNotification(skillID: 1000, duration: 30))
        assertEncodes62(UpdateMountNotification(characterID: 14, level: 1, experience: 0, tiredness: 0, leveledUp: false))
        assertEncodes62(UpdatePartyMemberHPNotification(characterID: 14, currentHP: 100, maxHP: 250))
        assertEncodes62(UpdateStatsNotification.enableActions)
        assertEncodes62(UpdateStatsNotification.hp(100))
        assertEncodes62(UpdateStatsNotification.hpMp(100, 50))
        assertEncodes62(UpdateStatsNotification(
            announce: true, stats: [.level, .exp], skin: nil, face: nil, hair: nil,
            level: 20, job: .beginner, str: nil, dex: nil, int: nil, luk: nil,
            hp: nil, maxHp: nil, mp: nil, maxMp: nil, ap: nil, sp: nil, exp: 1000, fame: nil, meso: nil
        ))
        assertEncodes62(ShowEquipEffectNotification())
    }

    // MARK: - Monster Carnival / Ariant / Events

    func testEventNotifications() {
        assertEncodes62(MonsterCarnivalDiedNotification(team: 0, name: "bob", lostCP: 5))
        assertEncodes62(MonsterCarnivalObtainedCpNotification(currentCP: 10, totalCP: 20))
        assertEncodes62(MonsterCarnivalPartyCpNotification(team: 0, currentCP: 30, totalCP: 60))
        assertEncodes62(MonsterCarnivalStartNotification(team: 0))
        assertEncodes62(MonsterCarnivalSummonNotification(tab: 0, number: 1, name: "mob"))
        assertEncodes62(AriantPqStartNotification.empty)
        assertEncodes62(AriantPqStartNotification.ranking(name: "bob", score: 100))
        assertEncodes62(AriantScoreboardNotification())
        assertEncodes62(ClockNotification.countdown(seconds: 60))
        assertEncodes62(ClockNotification.time(hour: 12, minute: 30, second: 0))
        assertEncodes62(ZakumShrineNotification(mode: 0, timeLeft: 300))
    }

    // MARK: - BBS

    func testBBSResponses() {
        let thread = BBSThread(localID: 1, posterCharacterID: 14, title: "t", timestamp: 1000, icon: 0, replyCount: 1, body: "body", notice: false)
        let reply = BBSReply(id: 1, threadID: 1, posterCharacterID: 14, body: "r", timestamp: 2000)
        assertEncodes62(BBSOperationResponse.threadList(notice: thread, threads: [thread], totalCount: 1, start: 0))
        assertEncodes62(BBSOperationResponse.threadList(notice: nil, threads: [], totalCount: 0, start: 0))
        assertEncodes62(BBSOperationResponse.showThread(localID: 1, thread: thread, replies: [reply]))
    }
}

// MARK: - Helpers

func sampleMob62() -> MobSpawnData {
    MobSpawnData(objectID: 100, mobID: 100100, x: 500, y: 300, foothold: 10, rx0: 400, rx1: 600, facing: 1)
}
