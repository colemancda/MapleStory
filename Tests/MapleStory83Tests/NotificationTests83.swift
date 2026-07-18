//
//  NotificationTests83.swift
//  Encode-path coverage for server->client notification packets.
//

import Foundation
import XCTest
@testable import MapleStory
@testable import MapleStory83

final class NotificationTests83: XCTestCase {

    // MARK: - Buff / skill notifications

    func testBuffSkillNotifications() {
        assertEncodes83(CancelBuffNotification(skillID: 1001))
        assertEncodes83(CancelSkillEffectNotification(characterID: 14, skillID: 1001))
        assertEncodes83(GiveBuffNotification(skillID: 1001, level: 1, duration: 30, buffStats: 0x40))
        assertEncodes83(SkillEffectNotification(characterID: 14, skillID: 1001, level: 1, flags: 0, speed: 0))
        assertEncodes83(ShowQuestCompletionNotification(questID: 100))
        assertEncodes83(UseSkillBookNotification(characterID: 14, skillID: 1001, maxLevel: 20, canUse: true, success: true))
    }

    // MARK: - Monster notifications

    func testMonsterNotifications() {
        assertEncodes83(CatchMonsterNotification(mobID: 9304000, itemID: 2270000, success: 1))
        assertEncodes83(SpawnMonsterNotification(mob: sampleMobSpawnData83()))
        assertEncodes83(SpawnMonsterControl(control: 2, mob: sampleMobSpawnData83()))
        assertEncodes83(SpawnMonsterControl(control: 0, mob: sampleMobSpawnData83()))
    }

    // MARK: - Channel / chat notifications

    func testChannelChatNotifications() {
        assertEncodes83(ChangeChannelNotification(responseCode: 1, address: [8, 31, 99, 141], port: 8585))
        assertEncodes83(SpouseChatNotification(sender: "bob", message: "hi"))
    }

    // MARK: - Pet notifications

    func testPetNotifications() {
        assertEncodes83(PetCommandNotification(characterID: 14, slot: 0, isFoodCommand: false, command: 1, success: true))
        assertEncodes83(PetCommandNotification(characterID: 14, slot: 0, isFoodCommand: true, command: 1, success: true))
        assertEncodes83(SpawnPetNotification(characterID: 14, slot: 0, remove: true))
        assertEncodes83(SpawnPetNotification(characterID: 14, slot: 0, remove: true, hunger: true))
        assertEncodes83(SpawnPetNotification(
            characterID: 14, slot: 0, remove: false, hunger: false, itemID: 5000000,
            name: "Fido", uniqueID: 1, positionX: 10, positionY: 20, stance: 0, foothold: 5
        ))
    }

    // MARK: - Buddy notifications

    func testBuddyNotifications() {
        assertEncodes83(BuddyListNotification.update([
            BuddyListNotification.Buddy(id: 1, name: "bob", value0: 0, channel: 1)
        ]))
        assertEncodes83(BuddyListMessageNotification(messageType: 11))
        assertEncodes83(BuddyListMessageNotification.buddyListFull)
        assertEncodes83(BuddyListMessageNotification.otherBuddyListFull)
        assertEncodes83(BuddyListMessageNotification.alreadyOnList)
        assertEncodes83(BuddyListMessageNotification.characterNotFound)
    }

    // MARK: - Party / guild notifications

    func testPartyGuildNotifications() {
        assertEncodes83(PartyOperationNotification(operation: .create, partyID: 1234, members: [samplePartyMember83()]))
        assertEncodes83(PartyOperationNotification(operation: .leave))
        assertEncodes83(PartyOperationNotification(operation: .disband, partyID: 1234))
        assertEncodes83(GuildOperationNotification(operation: .create, guildID: 4321))
        assertEncodes83(GuildOperationNotification(operation: .disband))
        assertEncodes83(GuildOperationNotification(operation: .rank, guildID: 4321))
    }

    // MARK: - Stats notification

    func testStatsNotification() {
        assertEncodes83(UpdateStatsNotification.enableActions)
        assertEncodes83(UpdateStatsNotification.hp(100))
        assertEncodes83(UpdateStatsNotification.hpMp(100, 50))
        assertEncodes83(UpdateStatsNotification(
            announce: true, stats: [.level, .exp, .job], skin: nil, face: nil, hair: nil,
            level: 20, job: .beginner, str: nil, dex: nil, int: nil, luk: nil,
            hp: nil, maxHp: nil, mp: nil, maxMp: nil, ap: nil, sp: nil, exp: 1000, fame: nil, meso: nil
        ))
        assertEncodes83(UpdateStatsNotification(
            announce: false, stats: [.skin, .face, .hair, .str, .dex, .int, .luk, .maxHP, .maxMP, .availableAP, .availableSP, .fame, .meso],
            skin: 1, face: 20000, hair: 30000, level: nil, job: nil,
            str: 12, dex: 8, int: 5, luk: 4, hp: nil, maxHp: 250, mp: nil, maxMp: 120,
            ap: 5, sp: 3, exp: nil, fame: 7, meso: 99999
        ))
    }

    // MARK: - BBS notification

    func testBBSNotification() {
        let thread = BBSThread(localID: 1, posterCharacterID: 14, title: "t", timestamp: 1000, icon: 0, replyCount: 1, body: "body", notice: false)
        let reply = BBSReply(id: 1, threadID: 1, posterCharacterID: 14, body: "r", timestamp: 2000)
        assertEncodes83(BBSOperationResponse.threadList(notice: thread, threads: [thread], totalCount: 1, start: 0))
        assertEncodes83(BBSOperationResponse.threadList(notice: nil, threads: [], totalCount: 0, start: 0))
        assertEncodes83(BBSOperationResponse.showThread(localID: 1, thread: thread, replies: [reply]))
    }

    // MARK: - Fame notification (round-trip with optionals present)

    func testFameNotification() {
        // success has all optionals populated, so it round-trips symmetrically
        assertRoundTrip83(FameResponseNotification.success(targetName: "bob", mode: 1, newFame: 10))
        // error / bare-status forms leave optionals nil, so only exercise the encode path
        assertEncodes83(FameResponseNotification.error(3))
        assertEncodes83(FameResponseNotification(status: 5))
    }
}
