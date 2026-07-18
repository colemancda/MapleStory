//
//  CoverageTests.swift
//  Additional coverage for MapleStory28 packet types.
//

import Foundation
import XCTest
@testable import MapleStory
@testable import MapleStory28

final class CoverageTests: XCTestCase {

    // MARK: - Ping

    func testPingPacket() {
        let value = PingPacket()
        assertRoundTrip28(value)
        XCTAssertEqual(PingPacket.opcode, .ping)
    }

    // MARK: - Pin Operation Response

    func testPinOperationResponse() {
        for status in PinCodeStatus.allCases {
            let value = PinOperationResponse(status: status)
            assertRoundTrip28(value)
        }
        XCTAssertEqual(PinOperationResponse.opcode, .loginPinOperation)
    }

    // MARK: - Login Response Ban Cases

    func testLoginPermanentBan() {
        let value = LoginResponse.permanentBan
        assertRoundTrip28(value)
    }

    func testLoginTemporaryBan() {
        let value = LoginResponse.temporaryBan(.systemError, .default)
        assertRoundTrip28(value)
    }

    func testLoginSuccessFromUser() {
        let user = sampleUser28()
        let success = LoginResponse.Success(user: user)
        XCTAssertEqual(success.account, user.index)
        XCTAssertEqual(success.username, user.username.rawValue)
        XCTAssertEqual(success.isAdmin, user.isAdmin)
        XCTAssertEqual(success.gender, .male)
        assertRoundTrip28(LoginResponse.success(success))
    }

    func testGenderConversion() {
        XCTAssertEqual(LoginResponse.Success.Gender(MapleStory.Gender.male), .male)
        XCTAssertEqual(LoginResponse.Success.Gender(MapleStory.Gender.female), .female)
        XCTAssertEqual(LoginResponse.Success.Gender(nil), LoginResponse.Success.Gender.none)
    }

    // MARK: - Character List Response Convenience

    func testCharacterListFromDomainCharacter() {
        // rank enabled + equipment populated
        let character = sampleCharacter28(rankEnabled: true, equipment: [5: 1040002, 6: 1060002])
        let listCharacter = CharacterListResponse.Character(character)
        XCTAssertEqual(listCharacter.id, character.index)
        XCTAssertEqual(listCharacter.rank, .enabled(worldRank: 1, rankMove: 2, jobRank: 3, jobRankMove: 4))
        let response = CharacterListResponse(characters: [listCharacter])
        assertRoundTrip28(response)
    }

    func testCharacterListRankDisabled() {
        let character = sampleCharacter28(rankEnabled: false)
        let listCharacter = CharacterListResponse.Character(character)
        XCTAssertEqual(listCharacter.rank, .disabled)
        let response = CharacterListResponse(characters: [listCharacter])
        assertRoundTrip28(response)
    }

    func testCharacterStatsFromDomainCharacter() {
        let character = sampleCharacter28()
        let stats = CharacterListResponse.CharacterStats(character)
        XCTAssertEqual(stats.name, character.name)
        XCTAssertEqual(stats.level, numericCast(character.level))
        XCTAssertEqual(stats.str, character.str)
    }

    func testEquipmentDictionary() {
        let equipment: CharacterListResponse.Equipment = [5: 1040002, 6: 1060002]
        XCTAssertEqual(equipment.dictionary, [5: 1040002, 6: 1060002])
    }

    // MARK: - Server List Response Convenience

    func testServerListFromDomain() {
        let world = sampleWorld28()
        let channel = sampleChannel28()
        let response = ServerListResponse.world(world, channels: [channel])
        XCTAssertEqual(response.id, world.index)
        assertRoundTrip28(response)
    }

    func testServerListChannelFromDomain() {
        let channel = sampleChannel28()
        let listChannel = ServerListResponse.Channel(channel, world: 0)
        XCTAssertEqual(listChannel.name, channel.name)
        XCTAssertEqual(listChannel.load, channel.load)
        XCTAssertEqual(listChannel.world, 0)
    }

    // MARK: - Warp To Map Notification

    func testWarpConvenienceInit() {
        let channel = sampleChannel28()
        let character = sampleCharacter28()
        let notification = WarpToMapNotification(channel: channel, character: character)
        XCTAssertTrue(notification.isConnecting)
        XCTAssertEqual(notification.buddyListSize, 20)
        XCTAssertEqual(notification.character, character.index)
        XCTAssertEqual(notification.stats.name, character.name)
        XCTAssertEqual(notification.value0, 255)
        XCTAssertEqual(notification.value1, 255)
    }

    func testInventoryItemVariants() {
        let inventory: WarpToMapNotification.Inventory = [
            1: WarpToMapNotification.Inventory.Item(
                id: 1040002,
                cashID: nil,
                expireTime: 0,
                stats: .a(.init(upgradeSlots: 7, scrollLevel: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, watk: 0, matk: 0, wdef: 3, mdef: 0, accuracy: 0, avoid: 0, hands: 0, speed: 0, jump: 0, name: "", flag: 0))
            ),
            2: WarpToMapNotification.Inventory.Item(
                id: 2000000,
                cashID: nil,
                expireTime: 100,
                stats: .b(.init(amount: 5, name: "", flag: 0))
            ),
            3: WarpToMapNotification.Inventory.Item(
                id: 5000000,
                cashID: 987654321,
                expireTime: -1,
                stats: .pet(.init(name: "petname", value0: 0, value1: 0, value2: 0, expiration: -1, value3: 0))
            )
        ]
        XCTAssertTrue(inventory[3]!.isCash)
        XCTAssertFalse(inventory[1]!.isCash)
        assertValueRoundTrip28(inventory)
    }

    func testShortArrayWithElements() {
        let skills: WarpToMapNotification.ShortArray<WarpToMapNotification.Skill> = [
            .init(id: 1000, level: 1),
            .init(id: 1001, level: 2)
        ]
        assertValueRoundTrip28(skills)

        let cooldowns: WarpToMapNotification.ShortArray<WarpToMapNotification.Skill.Cooldown> = [
            .init(id: 1000, cooldown: 30)
        ]
        assertValueRoundTrip28(cooldowns)

        XCTAssertEqual(skills.description, [WarpToMapNotification.Skill(id: 1000, level: 1), WarpToMapNotification.Skill(id: 1001, level: 2)].description)
    }

    func testShortArrayEmpty() {
        let skills: WarpToMapNotification.ShortArray<WarpToMapNotification.Skill> = []
        assertValueRoundTrip28(skills)
    }
}
