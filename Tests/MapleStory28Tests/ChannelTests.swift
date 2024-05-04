//
//  ChannelTests.swift
//
//
//  Created by Alsey Coleman Miller on 5/3/24.
//

import Foundation
import XCTest
@testable import MapleStory
@testable import MapleStory28

final class ChannelTests: XCTestCase {
    
    func testPlayerLoginRequest() {
        
        let packet: Packet<ClientOpcode> = [0x0C, 0x01, 0x00, 0x00, 0x00, 0x00]
        
        let value = PlayerLoginRequest(character: 1)
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
    }
    
    func testWarpToMap() {
        
        let packet: Packet<ServerOpcode> = [54, 0, 0, 0, 0, 0, 1, 98, 213, 130, 76, 98, 213, 130, 76, 98, 213, 130, 76, 98, 213, 130, 76, 255, 255, 1, 0, 0, 0, 99, 111, 108, 101, 109, 97, 110, 99, 100, 97, 49, 0, 0, 0, 0, 32, 78, 0, 0, 78, 117, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 7, 0, 4, 0, 6, 0, 8, 0, 100, 0, 100, 0, 50, 0, 50, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 32, 32, 32, 32, 32, 5, 1, 130, 222, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 1, 162, 44, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 1, 129, 91, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 1, 240, 221, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 237, 7, 0, 0, 208, 7, 0, 0, 232, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 35, 231, 52, 102, 0, 0, 0, 0]
                
        let value = WarpToMapNotification(channel: 0, characterPortalCounter: 0, isConnecting: true, randomBytesA: 1283642722, randomBytesB: 1283642722, randomBytesC: 1283642722, randomBytesD: 1283642722, value0: 255, value1: 255, character: 1, stats: MapleStory28.CharacterListResponse.CharacterStats(name: "colemancda1", gender: MapleStory.Gender.male, skinColor: MapleStory.SkinColor.normal, face: 20000, hair: 30030, petCash: 0, level: 1, job: MapleStory.Job.beginner, str: 7, dex: 4, int: 6, luk: 8, hp: 100, maxHp: 100, mp: 50, maxMp: 50, ap: 0, sp: 0, exp: 0, fame: 0, currentMap: 0, spawnPoint: 0), buddyListSize: 20, mesos: 0, equipSlotSize: 32, useSlotSize: 32, setupSlotSize: 32, etcSlotSize: 32, cashSlotSize: 32, equip: [5: MapleStory28.WarpToMapNotification.Inventory.Item(id: 1040002, cashID: nil, expireTime: 0, stats: MapleStory28.WarpToMapNotification.Inventory.Item.ItemStats.a(MapleStory28.WarpToMapNotification.Inventory.Item.ItemStats.A(upgradeSlots: 7, scrollLevel: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, watk: 0, matk: 0, wdef: 3, mdef: 0, accuracy: 0, avoid: 0, hands: 0, speed: 0, jump: 0, name: "", flag: 0))), 6: MapleStory28.WarpToMapNotification.Inventory.Item(id: 1060002, cashID: nil, expireTime: 0, stats: MapleStory28.WarpToMapNotification.Inventory.Item.ItemStats.a(MapleStory28.WarpToMapNotification.Inventory.Item.ItemStats.A(upgradeSlots: 7, scrollLevel: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, watk: 0, matk: 0, wdef: 2, mdef: 0, accuracy: 0, avoid: 0, hands: 0, speed: 0, jump: 0, name: "", flag: 0))), 7: MapleStory28.WarpToMapNotification.Inventory.Item(id: 1072001, cashID: nil, expireTime: 0, stats: MapleStory28.WarpToMapNotification.Inventory.Item.ItemStats.a(MapleStory28.WarpToMapNotification.Inventory.Item.ItemStats.A(upgradeSlots: 5, scrollLevel: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, watk: 0, matk: 0, wdef: 2, mdef: 0, accuracy: 0, avoid: 0, hands: 0, speed: 0, jump: 0, name: "", flag: 0))), 11: MapleStory28.WarpToMapNotification.Inventory.Item(id: 1302000, cashID: nil, expireTime: 0, stats: MapleStory28.WarpToMapNotification.Inventory.Item.ItemStats.a(MapleStory28.WarpToMapNotification.Inventory.Item.ItemStats.A(upgradeSlots: 7, scrollLevel: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, watk: 17, matk: 0, wdef: 0, mdef: 17, accuracy: 0, avoid: 0, hands: 0, speed: 0, jump: 0, name: "", flag: 0)))], cashEquip: [:], equipInventory: [:], useInventory: [:], setUpInventory: [:], etcInventory: [:], cashInventory: [:], skills: [], skillCooldown: [], questCount: 3, value2: 2029, value3: 0, value4: 2000, value5: 0, value6: 1000, value7: 0, completedQuestCount: 0, value8: 0, value9: 0, value10: 0, value11: 0, value12: 0, value13: 0, value14: 0, timestamp: Date(timeIntervalSince1970: TimeInterval(1714743075)))
        
        XCTAssertDecode(value, packet)
        XCTAssertEncode(value, packet)
        XCTAssertEqual(packet.data.count, 399)
    }
    
    func testPlayerMovementWarpRequest() {
        
        let packet: Packet<ClientOpcode> = [0x1A, 0x00, 0xA5, 0xFF, 0xAB, 0x00, 0x03, 0x00, 0xA5, 0xFF, 0x05, 0x01, 0x00, 0x00, 0x58, 0x02, 0x00, 0x00, 0x06, 0x2C, 0x01, 0x00, 0xA5, 0xFF, 0x13, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x16, 0x00, 0x00, 0xA5, 0xFF, 0x13, 0x01, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x04, 0xBC, 0x00, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        
        let value = MovePlayerRequest(
            portalCount: 0,
            x: 65445,
            y: 171,
            movements: [
            .absolute(MapleStory28.Movement.Absolute(command: 0, xpos: 65445, ypos: 261, xwobble: 0, ywobble: 600, value0: 0, newState: 6, duration: 300)),
            .absolute(MapleStory28.Movement.Absolute(command: 0, xpos: 65445, ypos: 275, xwobble: 0, ywobble: 0, value0: 0, newState: 6, duration: 22)),
            .absolute(MapleStory28.Movement.Absolute(command: 0, xpos: 65445, ypos: 275, xwobble: 0, ywobble: 0, value0: 16, newState: 4, duration: 188))
            ], 
            value0: 17,
            value1: 0
        )
        
        XCTAssertDecode(value, packet)
        XCTAssertEncode(value, packet)
    }
    
    func testPlayerMovementRight() {
        
        let packet: Packet<ClientOpcode> = [0x1A, 0x00, 0xB8, 0xFF, 0x13, 0x01, 0x03, 0x00, 0xBC, 0xFF, 0x13, 0x01, 0x7D, 0x00, 0x00, 0x00, 0x12, 0x00, 0x02, 0x1E, 0x00, 0x00, 0xC6, 0xFF, 0x13, 0x01, 0x05, 0x00, 0x00, 0x00, 0x12, 0x00, 0x04, 0x96, 0x00, 0x00, 0xC6, 0xFF, 0x13, 0x01, 0x00, 0x00, 0x00, 0x00, 0x12, 0x00, 0x04, 0x4A, 0x01, 0x11, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        
        let value = MovePlayerRequest(
            portalCount: 0,
            x: 65464, 
            y: 275,
            movements: [
                .absolute(MapleStory28.Movement.Absolute(command: 0, xpos: 65468, ypos: 275, xwobble: 125, ywobble: 0, value0: 18, newState: 2, duration: 30)),
                .absolute(MapleStory28.Movement.Absolute(command: 0, xpos: 65478, ypos: 275, xwobble: 5, ywobble: 0, value0: 18, newState: 4, duration: 150)),
                .absolute(MapleStory28.Movement.Absolute(command: 0, xpos: 65478, ypos: 275, xwobble: 0, ywobble: 0, value0: 18, newState: 4, duration: 330))],
            value0: 1041,
            value1: 0
        )
        
        XCTAssertDecode(value, packet)
        XCTAssertEncode(value, packet)
    }
}
