//
//  EntityTests.swift
//
//  Tests for persisted entity model types.
//

import Foundation
import XCTest
@testable import MapleStory

final class EntityTests: XCTestCase {

    // MARK: - World

    func testWorld() throws {
        var world = World(version: .v62)
        XCTAssertEqual(world.name, World.Name.scania.rawValue)
        XCTAssertEqual(world.region, .global)
        XCTAssertEqual(world.ribbon, .normal)
        XCTAssertEqual(world.rateModifier, 0x64)
        XCTAssertTrue(world.isEnabled)

        // newCharacter increments the index
        XCTAssertNil(world.lastCharacter)
        XCTAssertEqual(world.newCharacter(), 1)
        XCTAssertEqual(world.newCharacter(), 2)
        XCTAssertEqual(world.lastCharacter, 2)

        XCTAssertFalse(World.attributes.isEmpty)
        XCTAssertFalse(World.relationships.isEmpty)
        XCTAssertJSONRoundTrip(world)
    }

    // MARK: - Channel

    func testChannel() throws {
        let channel = Channel(index: 0, world: UUID(), name: "Channel 1")
        XCTAssertEqual(channel.index, 0)
        XCTAssertEqual(channel.name, "Channel 1")
        XCTAssertEqual(channel.status, .normal)
        XCTAssertEqual(channel.load, 0)
        XCTAssertEqual(channel.address, .channelServerDefault)
        XCTAssertFalse(Channel.attributes.isEmpty)
        XCTAssertFalse(Channel.relationships.isEmpty)
        XCTAssertJSONRoundTrip(channel)
    }

    // MARK: - Session

    func testSession() throws {
        let session = Session(
            channel: UUID(),
            character: UUID(),
            sendNonce: Nonce(rawValue: 1),
            recieveNonce: Nonce(rawValue: 2),
            address: "127.0.0.1"
        )
        XCTAssertEqual(session.address, "127.0.0.1")
        XCTAssertEqual(session.sendNonce.rawValue, 1)
        XCTAssertNil(session.loginTime)
        XCTAssertFalse(Session.attributes.isEmpty)
        XCTAssertFalse(Session.relationships.isEmpty)
        XCTAssertJSONRoundTrip(session)
    }

    // MARK: - User

    func testUser() throws {
        let user = User(index: 1, username: Username(rawValue: "colemancda")!)
        XCTAssertEqual(user.username.rawValue, "colemancda")
        XCTAssertEqual(user.birthday, .mapleGlobalRelease)
        XCTAssertFalse(user.isAdmin)
        XCTAssertFalse(user.isGuest)
        XCTAssertFalse(user.termsAccepted)
        XCTAssertTrue(user.characters.isEmpty)
        XCTAssertFalse(User.attributes.isEmpty)
        XCTAssertFalse(User.relationships.isEmpty)
        XCTAssertJSONRoundTrip(user)
    }

    // MARK: - Storage

    func testStorage() throws {
        var storage = Storage(userID: UUID())
        XCTAssertEqual(storage.slots, 0)
        XCTAssertEqual(storage.maxSlots, 16)
        XCTAssertTrue(storage.hasSpace)
        XCTAssertFalse(storage.isFull)

        storage.items[1] = InventoryItem(itemId: 2000002, slot: 1)
        XCTAssertEqual(storage.slots, 1)

        storage.maxSlots = 1
        XCTAssertTrue(storage.isFull)
        XCTAssertFalse(storage.hasSpace)

        XCTAssertFalse(Storage.attributes.isEmpty)
        XCTAssertFalse(Storage.relationships.isEmpty)
        XCTAssertJSONRoundTrip(storage)
    }

    // MARK: - Buddy

    func testBuddy() throws {
        let buddy = Buddy(character: UUID(), buddyID: 5)
        XCTAssertEqual(buddy.buddyID, 5)
        XCTAssertTrue(buddy.pending)
        XCTAssertFalse(Buddy.attributes.isEmpty)
        XCTAssertTrue(Buddy.relationships.isEmpty)
        XCTAssertJSONRoundTrip(buddy)
    }

    // MARK: - SkillMacro

    func testSkillMacro() throws {
        let macro = SkillMacro(character: UUID(), slot: 0, name: "Combo")
        XCTAssertEqual(macro.slot, 0)
        XCTAssertEqual(macro.name, "Combo")

        let macro2 = SkillMacro(
            character: UUID(), slot: 1, name: "Combo2",
            shout: 1, skill1: 1000, skill2: 1001, skill3: 1002
        )
        XCTAssertEqual(macro2.skill1, 1000)
        XCTAssertEqual(macro2.shout, 1)

        XCTAssertFalse(SkillMacro.attributes.isEmpty)
        XCTAssertFalse(SkillMacro.relationships.isEmpty)
        XCTAssertJSONRoundTrip(macro)
    }

    // MARK: - CharacterSkill

    func testCharacterSkill() throws {
        let skill = CharacterSkill(characterID: UUID(), skillID: 1000, level: 5, masteryLevel: 10)
        XCTAssertEqual(skill.skillID, 1000)
        XCTAssertEqual(skill.level, 5)
        XCTAssertEqual(skill.masteryLevel, 10)
        XCTAssertFalse(CharacterSkill.attributes.isEmpty)
        XCTAssertTrue(CharacterSkill.relationships.isEmpty)
        XCTAssertJSONRoundTrip(skill)
    }

    // MARK: - FameLog

    func testFameLog() throws {
        let log = FameLog(characterID: UUID(), characterIDTo: UUID())
        XCTAssertNotEqual(log.characterID, log.characterIDTo)
        XCTAssertFalse(FameLog.attributes.isEmpty)
        XCTAssertTrue(FameLog.relationships.isEmpty)
        XCTAssertJSONRoundTrip(log)
    }

    // MARK: - GuildEntity

    func testGuildEntity() throws {
        let guild = GuildEntity(guildID: 1000, name: "Legends", leaderID: UUID(), notice: "Welcome")
        XCTAssertEqual(guild.guildID, 1000)
        XCTAssertEqual(guild.capacity, 30)
        XCTAssertEqual(guild.notice, "Welcome")
        _ = GuildEntity.entityName
        XCTAssertFalse(GuildEntity.attributes.isEmpty)
        XCTAssertFalse(GuildEntity.relationships.isEmpty)
        XCTAssertJSONRoundTrip(guild)
    }

    func testGuildMemberEntity() throws {
        let member = GuildMemberEntity(
            guild: UUID(),
            characterID: UUID(),
            characterName: "Member",
            rank: .jrMaster,
            online: true
        )
        XCTAssertEqual(member.rank, .jrMaster)
        XCTAssertTrue(member.online)
        _ = GuildMemberEntity.entityName
        XCTAssertFalse(GuildMemberEntity.attributes.isEmpty)
        XCTAssertFalse(GuildMemberEntity.relationships.isEmpty)
        XCTAssertJSONRoundTrip(member)
    }

    // MARK: - PartyEntity

    func testPartyEntity() throws {
        let party = PartyEntity(partyID: 2000, leaderID: UUID())
        XCTAssertEqual(party.partyID, 2000)
        _ = PartyEntity.entityName
        XCTAssertFalse(PartyEntity.attributes.isEmpty)
        XCTAssertFalse(PartyEntity.relationships.isEmpty)
        XCTAssertJSONRoundTrip(party)
    }

    func testPartyMemberEntity() throws {
        let member = PartyMemberEntity(
            party: UUID(),
            characterID: UUID(),
            characterName: "Member",
            job: .warrior,
            level: 30,
            channel: 1,
            map: .henesys
        )
        XCTAssertEqual(member.job, .warrior)
        XCTAssertEqual(member.level, 30)
        _ = PartyMemberEntity.entityName
        XCTAssertFalse(PartyMemberEntity.attributes.isEmpty)
        XCTAssertFalse(PartyMemberEntity.relationships.isEmpty)

        // conversion
        let partyMember = member.toPartyMember()
        XCTAssertEqual(partyMember.characterID, member.characterID)
        XCTAssertEqual(partyMember.job, .warrior)
        XCTAssertEqual(partyMember.map, .henesys)

        XCTAssertJSONRoundTrip(member)
    }
}
