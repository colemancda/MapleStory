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
        
        //let encryptedPacket: EncryptedPacket = [36, 105, 245, 183, 228, 8]
        let packet: Packet<ClientOpcode> = [0x0C, 0x01, 0x00, 0x00, 0x00, 0x00]
        //let nonce = Nonce(rawValue: UInt32(bigEndian: UInt32(bytes: (35, 47, 85, 23))))
        
        let value = PlayerLoginRequest(character: 1)
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        //XCTAssertEncrypt(value, encryptedPacket, key: nil, nonce: nonce, version: .v28)
    }
    
    func testWarpToMap() {
        
        //let encryptedPacket: EncryptedPacket = [182, 4, 57, 5, 222, 131, 200, 44, 93, 229, 212, 218, 176, 153, 64, 193, 128, 166, 231, 158, 170, 187, 118, 195, 67, 9, 223, 42, 148, 152, 60, 214, 188, 76, 99, 13, 237, 246, 96, 104, 182, 44, 19, 183, 151, 179, 84, 49, 246, 40, 69, 113, 156, 11, 243, 28, 43, 172, 148, 50, 96, 174, 166, 49, 193, 185, 86, 191, 151, 228, 130, 136, 154, 147, 113, 143, 41, 172, 98, 187, 198, 46, 191, 246, 65, 147, 194, 63, 195, 38, 21, 82, 226, 138, 57, 6, 28, 188, 102, 179, 38, 83, 86, 12, 146, 249, 157, 75, 6, 2, 99, 190, 89, 146, 29, 128, 244, 66, 92, 38, 69, 33, 218, 31, 71, 206, 235, 85, 30, 7, 253, 4, 155, 119, 142, 5, 93, 29, 134, 214, 13, 214, 76, 42, 54, 170, 255, 100, 143, 66, 234, 90, 195, 133, 73, 10, 162, 159, 43, 105, 1, 55, 250, 253, 65, 80, 145, 213, 1, 157, 82, 96, 209, 233, 214, 106, 33, 138, 116, 33, 198, 214, 184, 219, 1, 22, 215, 70, 61, 248, 159, 202, 156, 217, 166, 251, 100, 131, 110, 55, 142, 40, 91, 55, 62, 188, 240, 219, 41, 60, 122, 9, 130, 117, 81, 42, 66, 128, 87, 97, 29, 233, 67, 33, 255, 216, 20, 118, 228, 35, 26, 216, 135, 97, 229, 224, 183, 145, 190, 225, 187, 121, 219, 111, 246, 100, 117, 145, 249, 69, 3, 118, 101, 226, 65, 7, 205, 116, 119, 112, 183, 95, 67, 157, 154, 22, 83, 13, 29, 110, 51, 35, 20, 243, 171, 13, 157, 230, 237, 145, 191, 41, 76, 30, 140, 88, 60, 117, 14, 70, 69, 10, 168, 87, 104, 45, 191, 125, 149, 179, 131, 41, 25, 106, 211, 196, 0, 227, 22, 143, 0, 61, 161, 130, 136, 162, 114, 101, 237, 134, 121, 33, 114, 122, 205, 238, 99, 142, 208, 104, 75, 176, 36, 34, 42, 39, 149, 181, 222, 10, 96, 91, 64, 71, 134, 67, 119, 115, 115, 209, 105, 225, 22, 195, 154, 180, 96, 141, 9, 117, 0, 102, 138, 61, 40, 243, 64, 187, 192, 205, 46, 251, 177, 113, 67, 206, 250, 13, 207, 227, 74, 181, 116, 170, 74, 23, 192, 247, 104, 18, 108, 174, 40, 12, 196, 120, 187, 160, 2, 25, 175, 202, 249]
        
        let packet: Packet<ServerOpcode> = [54, 0, 0, 0, 0, 0, 1, 98, 213, 130, 76, 98, 213, 130, 76, 98, 213, 130, 76, 98, 213, 130, 76, 255, 255, 1, 0, 0, 0, 99, 111, 108, 101, 109, 97, 110, 99, 100, 97, 49, 0, 0, 0, 0, 32, 78, 0, 0, 78, 117, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 7, 0, 4, 0, 6, 0, 8, 0, 100, 0, 100, 0, 50, 0, 50, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 32, 32, 32, 32, 32, 5, 1, 130, 222, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 1, 162, 44, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 1, 129, 91, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 1, 240, 221, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 237, 7, 0, 0, 208, 7, 0, 0, 232, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 35, 231, 52, 102, 0, 0, 0, 0]
        
        //let nonce = Nonce(rawValue: UInt32(bigEndian: UInt32(bytes: (19, 204, 85, 251))))
        
        let value = WarpToMapNotification(channel: 0, characterPortalCounter: 0, isConnecting: true, randomBytesA: 1283642722, randomBytesB: 1283642722, randomBytesC: 1283642722, randomBytesD: 1283642722, value0: 255, value1: 255, character: 1, stats: MapleStory28.CharacterListResponse.CharacterStats(name: "colemancda1", gender: MapleStory.Gender.male, skinColor: MapleStory.SkinColor.normal, face: 20000, hair: 30030, petCash: 0, level: 1, job: MapleStory.Job.beginner, str: 7, dex: 4, int: 6, luk: 8, hp: 100, maxHp: 100, mp: 50, maxMp: 50, ap: 0, sp: 0, exp: 0, fame: 0, currentMap: 0, spawnPoint: 0), buddyListSize: 20, mesos: 0, equipSlotSize: 32, useSlotSize: 32, setupSlotSize: 32, etcSlotSize: 32, cashSlotSize: 32, equip: [5: MapleStory28.WarpToMapNotification.Inventory.Item(id: 1040002, cashID: nil, expireTime: 0, stats: MapleStory28.WarpToMapNotification.Inventory.Item.ItemStats.a(MapleStory28.WarpToMapNotification.Inventory.Item.ItemStats.A(upgradeSlots: 7, scrollLevel: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, watk: 0, matk: 0, wdef: 3, mdef: 0, accuracy: 0, avoid: 0, hands: 0, speed: 0, jump: 0, name: "", flag: 0))), 6: MapleStory28.WarpToMapNotification.Inventory.Item(id: 1060002, cashID: nil, expireTime: 0, stats: MapleStory28.WarpToMapNotification.Inventory.Item.ItemStats.a(MapleStory28.WarpToMapNotification.Inventory.Item.ItemStats.A(upgradeSlots: 7, scrollLevel: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, watk: 0, matk: 0, wdef: 2, mdef: 0, accuracy: 0, avoid: 0, hands: 0, speed: 0, jump: 0, name: "", flag: 0))), 7: MapleStory28.WarpToMapNotification.Inventory.Item(id: 1072001, cashID: nil, expireTime: 0, stats: MapleStory28.WarpToMapNotification.Inventory.Item.ItemStats.a(MapleStory28.WarpToMapNotification.Inventory.Item.ItemStats.A(upgradeSlots: 5, scrollLevel: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, watk: 0, matk: 0, wdef: 2, mdef: 0, accuracy: 0, avoid: 0, hands: 0, speed: 0, jump: 0, name: "", flag: 0))), 11: MapleStory28.WarpToMapNotification.Inventory.Item(id: 1302000, cashID: nil, expireTime: 0, stats: MapleStory28.WarpToMapNotification.Inventory.Item.ItemStats.a(MapleStory28.WarpToMapNotification.Inventory.Item.ItemStats.A(upgradeSlots: 7, scrollLevel: 0, str: 0, dex: 0, int: 0, luk: 0, hp: 0, mp: 0, watk: 17, matk: 0, wdef: 0, mdef: 17, accuracy: 0, avoid: 0, hands: 0, speed: 0, jump: 0, name: "", flag: 0)))])
        
        XCTAssertDecode(value, packet)
        XCTAssertEncode(value, .init(packet.data.prefix(309)))
        //XCTAssertEncrypt(value, encryptedPacket, key: nil, nonce: nonce, version: .v28)
    }
}
