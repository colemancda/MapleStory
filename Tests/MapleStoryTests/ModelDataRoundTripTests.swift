//
//  ModelDataRoundTripTests.swift
//
//  Round-trip tests for the CoreModel `Entity` conformances (encode() /
//  init(from:)) added during the CoreModel API migration. Each entity is
//  encoded to `ModelData` and decoded back, then asserted equal to the
//  original. Every one of these entities persists all of its stored
//  properties, so a plain `XCTAssertEqual` round-trip is valid for all of them.
//

import Foundation
import XCTest
import CoreModel
@testable import MapleStory

final class ModelDataRoundTripTests: XCTestCase {

    // Fixed timestamps so `Date`-typed attributes compare deterministically.
    private static let rtDate1 = Date(timeIntervalSinceReferenceDate: 1_000_000)
    private static let rtDate2 = Date(timeIntervalSinceReferenceDate: 2_500_000)

    // Generic round-trip helper: encode, sanity-check the entity name, decode,
    // and assert the decoded value equals the original.
    private func assertRoundTrip<T>(
        _ value: T,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws where T: Entity, T: Equatable {
        let model = try value.encode()
        XCTAssertEqual(model.entity, T.entityName, "encoded entity name mismatch", file: file, line: line)
        XCTAssertEqual(model.id, ObjectID(value.id), "encoded id mismatch", file: file, line: line)
        let decoded = try T(from: model)
        XCTAssertEqual(decoded, value, file: file, line: line)
    }

    // MARK: - World

    func testWorldRoundTrip() throws {
        let world = World(
            id: UUID(),
            index: 3,
            name: "Bera",
            region: .global,
            version: .v62,
            isEnabled: true,
            ribbon: .event,
            eventMessage: "2x EXP",
            rateModifier: 0x64,
            eventXP: 2,
            dropRate: 1,
            channels: [UUID(), UUID()],
            characters: [UUID()],
            lastCharacter: 7
        )
        try assertRoundTrip(world)
    }

    // MARK: - Buddy

    func testBuddyRoundTrip() throws {
        let buddy = Buddy(character: UUID(), buddyID: 42, pending: false)
        try assertRoundTrip(buddy)
    }

    // MARK: - Channel

    func testChannelRoundTrip() throws {
        let channel = Channel(
            index: 2,
            world: UUID(),
            name: "Channel 3",
            address: .channelServerDefault,
            load: 123,
            status: .normal,
            sessions: [UUID(), UUID()]
        )
        try assertRoundTrip(channel)
    }

    // MARK: - Character

    func testCharacterRoundTrip() throws {
        let character = Character(
            id: UUID(),
            index: 5,
            user: UUID(),
            world: UUID(),
            session: UUID(),
            created: Self.rtDate1,
            name: "Hero",
            gender: .female,
            skinColor: .normal,
            face: 20_000,
            hair: .buzz(.black),
            level: 30,
            job: .warrior,
            str: 25, dex: 12, int: 8, luk: 6,
            hp: 500, maxHp: 500, mp: 120, maxMp: 120,
            ap: 3, sp: 5,
            exp: 12_345,
            fame: 10,
            meso: 99_999,
            isMarried: false,
            currentMap: .henesys,
            spawnPoint: 2,
            isMega: true,
            cashWeapon: 1_702_000,
            equipment: [:],
            maskedEquipment: [:],
            isRankEnabled: true,
            worldRank: 100,
            rankMove: 5,
            jobRank: 42,
            jobRankMove: 1,
            buddyCapacity: 30
        )
        try assertRoundTrip(character)
    }

    // MARK: - CharacterSkill

    func testCharacterSkillRoundTrip() throws {
        let skill = CharacterSkill(characterID: UUID(), skillID: 1000, level: 5, masteryLevel: 10)
        try assertRoundTrip(skill)
    }

    // MARK: - Configuration.ElementEntity

    func testConfigurationElementEntityRoundTrip() throws {
        let element = Configuration.ElementEntity(id: .loginExpiration, value: .init(integer: 30))
        try assertRoundTrip(element)
        XCTAssertEqual(Configuration.ElementEntity.entityName, "Configuration")
    }

    // MARK: - FameLog

    func testFameLogRoundTrip() throws {
        let log = FameLog(characterID: UUID(), characterIDTo: UUID(), timestamp: Self.rtDate1)
        try assertRoundTrip(log)
    }

    // MARK: - GuildEntity

    func testGuildEntityRoundTrip() throws {
        let guild = GuildEntity(
            guildID: 1000,
            name: "Legends",
            leaderID: UUID(),
            capacity: 30,
            points: 500,
            logoBackground: 1,
            logoBackgroundColor: 2,
            logo: 3,
            logoColor: 4,
            notice: "Welcome"
        )
        try assertRoundTrip(guild)
        XCTAssertEqual(GuildEntity.entityName, "Guild")
    }

    // MARK: - GuildMemberEntity

    func testGuildMemberEntityRoundTrip() throws {
        let member = GuildMemberEntity(
            guild: UUID(),
            characterID: UUID(),
            characterName: "Member",
            rank: .jrMaster,
            online: true,
            joinedAt: Self.rtDate2
        )
        try assertRoundTrip(member)
        XCTAssertEqual(GuildMemberEntity.entityName, "GuildMember")
    }

    // MARK: - PartyEntity

    func testPartyEntityRoundTrip() throws {
        let party = PartyEntity(partyID: 2000, leaderID: UUID(), createdAt: Self.rtDate1)
        try assertRoundTrip(party)
        XCTAssertEqual(PartyEntity.entityName, "Party")
    }

    // MARK: - PartyMemberEntity

    func testPartyMemberEntityRoundTrip() throws {
        let member = PartyMemberEntity(
            party: UUID(),
            characterID: UUID(),
            characterName: "Member",
            job: .warrior,
            level: 30,
            channel: 1,
            map: .henesys,
            status: .online
        )
        try assertRoundTrip(member)
        XCTAssertEqual(PartyMemberEntity.entityName, "PartyMember")
    }

    // MARK: - Session

    func testSessionRoundTrip() throws {
        let session = Session(
            channel: UUID(),
            character: UUID(),
            requestTime: Self.rtDate1,
            loginTime: Self.rtDate2,
            sendNonce: Nonce(rawValue: 1),
            recieveNonce: Nonce(rawValue: 2),
            address: "127.0.0.1"
        )
        try assertRoundTrip(session)
    }

    // MARK: - SkillMacro

    func testSkillMacroRoundTrip() throws {
        let macro = SkillMacro(
            id: UUID(),
            character: UUID(),
            slot: 1,
            name: "Combo",
            shout: 1,
            skill1: 1000,
            skill2: 1001,
            skill3: 1002
        )
        try assertRoundTrip(macro)
    }

    // MARK: - Storage

    func testStorageRoundTrip() throws {
        var storage = Storage(userID: UUID(), mesos: 5_000, maxSlots: 16)
        storage.items[1] = InventoryItem(itemId: 2_000_002, slot: 1)
        try assertRoundTrip(storage)
    }

    // MARK: - User

    func testUserRoundTrip() throws {
        var user = User(
            index: 1,
            username: Username(rawValue: "colemancda")!,
            password: Data([0x01, 0x02, 0x03]),
            created: Self.rtDate1,
            gender: .male,
            ipAddress: "10.0.0.1",
            pinCode: "1234",
            picCode: "5678",
            birthday: .mapleGlobalRelease,
            email: "test@example.com",
            termsAccepted: true,
            isAdmin: false,
            isGuest: false,
            characters: [UUID(), UUID()]
        )
        // `storage` is a persisted to-one relationship; set it explicitly so the
        // non-default value also exercises the relationship encode/decode path.
        user.storage = UUID()
        try assertRoundTrip(user)
    }

    // MARK: - Invalid entity guard

    func testInvalidEntityThrows() throws {
        let wrong = ModelData(entity: "NotARealEntity", id: ObjectID(UUID()))
        XCTAssertThrowsError(try World(from: wrong)) { error in
            guard case CoreModelError.invalidEntity = error else {
                XCTFail("Expected CoreModelError.invalidEntity, got \(error)")
                return
            }
        }
        XCTAssertThrowsError(try User(from: wrong)) { error in
            guard case CoreModelError.invalidEntity = error else {
                XCTFail("Expected CoreModelError.invalidEntity, got \(error)")
                return
            }
        }
    }
}
