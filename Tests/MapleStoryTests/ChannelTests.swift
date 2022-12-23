//
//  ChannelTests.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

import Foundation
import XCTest
@testable import MapleStory

final class ChannelTests: XCTestCase {
    
    func testPlayerLogin() throws {
        
        let encryptedData = Data([0xF1, 0x10, 0x18, 0x4A, 0xC2, 0x3E, 0xDC, 0x17])
        let packetData = Data([0x14, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00])
        let nonce: Nonce = 0xA4AD08D2
        
        let packet = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(packet.data, packetData)
        
        let value = PlayerLoginRequest(client: 1)
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
    }
    
    func testServerMessageNotificationTopScrolling() throws {
        
        let encryptedData = Data([0xB9, 0xBF, 0xBF, 0xBF, 0xCF, 0x8E, 0x16, 0xC6, 0x1D, 0x79])
        let packetData = Data([0x41, 0x00, 0x04, 0x01, 0x00, 0x00])
        let nonce: Nonce = 0x52307840
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = ServerMessageNotification(
            type: .topScrolling,
            isServer: true,
            message: "",
            channel: nil,
            megaEarphone: nil
        )
        
        XCTAssertEncode(value, packet)
        XCTAssertEqual(packet.opcode, 0x0041)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.data, encryptedData)
    }
    
    func testNPCActionRequest() throws {
        
        let encryptedData = Data([0xD6, 0x90, 0xF0, 0x82, 0x73, 0xB6, 0x8C, 0x57])
        let packetData = Data([0xA6, 0x00, 0x65, 0x00, 0x00, 0x00, 0xFF, 0x00])
        let nonce: Nonce = 0xDF53AC5C
        
        let packet = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(packet.opcode, 0x00A6)
        XCTAssertEqual(packet.data, packetData)
        
        let value = NPCActionRequest.talk(0x65, 0xFF)
        XCTAssertDecode(value, packet)
    }
    
    func testNPCActionResponse() throws {
        
        let packetData = Data([0xC5, 0x00, 0x65, 0x00, 0x00, 0x00, 0xFF, 0x00])
        let encryptedData = Data([0xD5, 0xD2, 0xDD, 0xD2, 0xDA, 0x01, 0x35, 0x32, 0x4E, 0x5C, 0x3D, 0xD7])
        let nonce: Nonce = 0xE7F7142D
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = NPCActionResponse.talk(0x65, 0xFF)
        XCTAssertEncode(value, packet)
        XCTAssertEqual(packet.opcode, 0x00C5)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.data, encryptedData)
    }
    
    func testHealOverTimeRequest() throws {
        
        let encryptedData = Data([0xCD, 0x64, 0x48, 0xB0, 0x98, 0x20, 0x37, 0xCE, 0x0D, 0xC0, 0x73])
        let packetData = Data([0x51, 0x00, 0x00, 0x14, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00])
        let nonce: Nonce = 0x2E3748D7
        
        let packet = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        let value = HealOverTimeRequest(value0: 0, value1: 0x14, value2: 0, hp: 0, mp: 3, value3: 0)
        XCTAssertDecode(value, packet)
        XCTAssertEncode(value, packet)
        XCTAssertEqual(packet.opcode, 0x0051)
        XCTAssertEqual(packet.data, packetData)
    }
    
    func testWarpToMap() throws {
        
        let encryptedData = Data([0x5E, 0x14, 0xBB, 0x15, 0xB3, 0xE5, 0xB3, 0xFC, 0xCA, 0x3C, 0x45, 0xEE, 0x80, 0x12, 0x09, 0x45, 0x87, 0x98, 0xE7, 0x73, 0x30, 0xAB, 0x83, 0x98, 0xB8, 0xE3, 0x86, 0xBC, 0x71, 0xE3, 0x3F, 0x92, 0x01, 0x37, 0x5E, 0x90, 0x16, 0xA8, 0x7F, 0x7D, 0xB1, 0x59, 0xF5, 0xE7, 0x16, 0xC4, 0x04, 0xAC, 0xAF, 0x8D, 0x4E, 0x62, 0x8D, 0x25, 0x19, 0xB4, 0xE0, 0x06, 0x3F, 0x8C, 0xBD, 0x8F, 0x65, 0x96, 0x08, 0xEF, 0xC6, 0x04, 0xC4, 0x18, 0x22, 0x65, 0x22, 0xF2, 0x80, 0x54, 0xE3, 0x03, 0x0C, 0x73, 0x19, 0xD6, 0xDE, 0x7D, 0x1D, 0xC5, 0x1A, 0x37, 0x55, 0x32, 0x1D, 0x7A, 0x64, 0xE2, 0x2F, 0xB5, 0x82, 0x38, 0x79, 0x96, 0x64, 0x9C, 0x87, 0xF6, 0xE9, 0x62, 0x29, 0xBA, 0x73, 0xDC, 0xE3, 0xC3, 0xC7, 0x9D, 0x19, 0xCE, 0x8A, 0xCF, 0xF0, 0x16, 0x9A, 0xB6, 0xBF, 0x31, 0x16, 0x89, 0xAB, 0xFB, 0xDC, 0x09, 0x3C, 0x09, 0xD1, 0x04, 0x45, 0x9E, 0x24, 0xD0, 0x01, 0x76, 0xB0, 0x05, 0x21, 0x92, 0x89, 0xD2, 0xD1, 0x04, 0x60, 0xA9, 0xDD, 0xA5, 0xA3, 0x0F, 0x9B, 0xB7, 0x53, 0xBE, 0x59, 0x2D, 0xF1, 0x88, 0xFA, 0x65, 0x42, 0x9B, 0x92, 0xBE, 0x67, 0x79, 0xFE, 0xA4, 0x81, 0xBA, 0xBF, 0xDD, 0x9A, 0xB6, 0x40, 0xC5, 0x01, 0x2C, 0xFE, 0x1F, 0x3B, 0xA2, 0x1E, 0x48, 0x50, 0xFD, 0xDC, 0xD4, 0x5C, 0x8A, 0xE8, 0x20, 0xBA, 0x06, 0xDF, 0x1F, 0xBA, 0xC4, 0xD3, 0x74, 0xCD, 0x44, 0x78, 0xC7, 0xF5, 0xFA, 0x9E, 0x16, 0xA2, 0x7B, 0x15, 0x5A, 0x42, 0xBD, 0x6B, 0x01, 0x5A, 0xB6, 0xD8, 0xF5, 0x94, 0x03, 0xDF, 0x76, 0x55, 0x1C, 0x64, 0xB7, 0xE4, 0x8E, 0x67, 0xB1, 0x81, 0x2F, 0x80, 0x40, 0x78, 0x06, 0x2B, 0xEF, 0xF3, 0x14, 0x98, 0xBF, 0x53, 0x06, 0xFE, 0xB2, 0x39, 0xC4, 0x4F, 0x11, 0x86, 0x3A, 0x6A, 0x81, 0x5B, 0x98, 0x3C, 0x98, 0x5E, 0x3D, 0x1A, 0x67, 0x79, 0xBA, 0xED, 0x36, 0xC7, 0xB9, 0x0C, 0xBC, 0x9B, 0x49, 0x0F, 0x06, 0x77, 0xBB, 0xC9, 0x78, 0xAC, 0x26, 0x49, 0x04, 0x09, 0x9B, 0xFE, 0xAD, 0xA9, 0xE8, 0x40, 0xEE, 0xEF, 0xCB, 0xDD, 0xC6, 0x82, 0xC3, 0xD8, 0x55, 0x2F, 0x81, 0x07, 0x6D, 0xE3, 0x50, 0x16, 0x7C, 0x92, 0xB9, 0xC9, 0xEA, 0xBB, 0xA1, 0xB4, 0x30, 0x22, 0x37, 0xEE, 0xC7, 0x19, 0x90, 0x29, 0x55, 0x47, 0xD0, 0x65, 0x62, 0xF6, 0x67, 0xE5, 0x55, 0xE5, 0x9F, 0x8A, 0x05, 0x05, 0x40, 0x59, 0xBA, 0x6D, 0x41, 0xE2, 0xE5, 0x9B, 0x56, 0xE4, 0x3E, 0x1E, 0x9C, 0x53, 0xC1, 0x98, 0xD2, 0xD9, 0x51, 0x0F, 0xC2, 0x79, 0x7C, 0x3A, 0x5D, 0x77, 0x7A, 0x23, 0x81, 0xB3, 0x36, 0xF2, 0xB0, 0x31, 0x03, 0x35, 0xD4, 0xFD, 0xAC, 0xCB, 0xC2, 0xAA, 0x95, 0xAD, 0x00, 0xDA, 0x21, 0xD4, 0xDF, 0x84, 0x9D, 0x46, 0xF1, 0x8D, 0x08, 0x31, 0x81, 0x19, 0x17, 0x19, 0xC3, 0x55, 0x05, 0x4A, 0x17, 0xAE, 0x1C, 0xC7, 0x1A, 0x1A, 0x32, 0x79, 0x56, 0xD3, 0xCB, 0xD7, 0x56, 0xA0, 0x12, 0x69, 0x87, 0x9E, 0x3E, 0x04, 0x9C, 0x52, 0xDC, 0xB8, 0xEA, 0x51, 0x94, 0xA6, 0x15, 0x62, 0x23, 0xD1, 0x94, 0x0A, 0x76, 0x6B, 0x8D, 0x67, 0x66, 0x5C, 0xAE, 0xB7, 0xE5, 0x45, 0x19, 0xC4, 0x33, 0x6E, 0x42, 0x3A, 0x79, 0x3B, 0x95, 0x9A, 0xAA, 0x82, 0x72, 0x39, 0xE4, 0x35, 0x60, 0x95, 0x94, 0xBF, 0x0E, 0x41, 0x8C, 0xBA, 0x20, 0xCE, 0xEE, 0xFD, 0x55, 0x90, 0x1A, 0x78, 0x4D, 0x97, 0x84, 0xF2, 0x32, 0x9F, 0x4A, 0x0F])
        
        let packetData = Data([0x5C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0xCB, 0x30, 0xFD, 0x8E, 0xF8, 0x17, 0xD7, 0x13, 0xCD, 0xC5, 0xAD, 0x78, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0E, 0x00, 0x00, 0x00, 0x63, 0x6F, 0x6C, 0x65, 0x6D, 0x61, 0x6E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x4E, 0x00, 0x00, 0x4E, 0x75, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x07, 0x00, 0x06, 0x00, 0x04, 0x00, 0x08, 0x00, 0x32, 0x00, 0x32, 0x00, 0x05, 0x00, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x14, 0x00, 0x00, 0x00, 0x00, 0x64, 0x64, 0x64, 0x64, 0x64, 0x05, 0x01, 0x82, 0xDE, 0x0F, 0x00, 0x00, 0x00, 0x80, 0x05, 0xBB, 0x46, 0xE6, 0x17, 0x02, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x01, 0xA2, 0x2C, 0x10, 0x00, 0x00, 0x00, 0x80, 0x05, 0xBB, 0x46, 0xE6, 0x17, 0x02, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x01, 0x81, 0x5B, 0x10, 0x00, 0x00, 0x00, 0x80, 0x05, 0xBB, 0x46, 0xE6, 0x17, 0x02, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0B, 0x01, 0xF0, 0xDD, 0x13, 0x00, 0x00, 0x00, 0x80, 0x05, 0xBB, 0x46, 0xE6, 0x17, 0x02, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0xE9, 0x7D, 0x3F, 0x00, 0x00, 0x00, 0x80, 0x05, 0xBB, 0x46, 0xE6, 0x17, 0x02, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x61, 0x74, 0x10, 0x1F, 0x16, 0xD9, 0x01])
        
        let nonce: Nonce = 0xE5699FEB
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        //let value =
        //XCTAssertEncode(value, packet)
        XCTAssertEqual(packet.opcode, 0x005C)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.data, encryptedData)
    }
    
    func testSpawnNPC() throws {
        
        let packetData = Data([0xC2, 0x00, 0x64, 0x00, 0x00, 0x00, 0x34, 0x08, 0x00, 0x00, 0x5B, 0xFF, 0x35, 0x00, 0x01, 0x0B, 0x00, 0x2B, 0xFF, 0x8D, 0xFF, 0x01])
        let encryptedData = Data([0xA5, 0x05, 0xB3, 0x05, 0x5D, 0x4C, 0xA6, 0x72, 0xD6, 0xBE, 0xCF, 0xD1, 0x1E, 0xDF, 0xA3, 0x9F, 0x2B, 0xC5, 0x11, 0x49, 0xDB, 0x89, 0xF0, 0xE3, 0x2E, 0x62])
        let nonce: Nonce = 0xA35464FA
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = SpawnNPCNotification(
            objectId: 100,
            id: 2100,
            x: 65371,
            cy: 53,
            f: true,
            fh: 11,
            rx0: 65323,
            rx1: 65421,
            value0: 1
        )
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(packet.opcode, 0xC2)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.data, encryptedData)
    }
    
    func testSpawnNPCRequestController() throws {
        
        let packetData = Data([0xC4, 0x00, 0x01, 0x64, 0x00, 0x00, 0x00, 0x34, 0x08, 0x00, 0x00, 0x5B, 0xFF, 0x35, 0x00, 0x01, 0x0B, 0x00, 0x2B, 0xFF, 0x8D, 0xFF, 0x01])
        let encryptedData = Data([0x65, 0xF8, 0x72, 0xF8, 0xF5, 0xAD, 0x70, 0x80, 0x27, 0xBE, 0x70, 0xA5, 0x8D, 0x09, 0x76, 0x2F, 0x9F, 0x58, 0x84, 0x07, 0x67, 0x4F, 0xAE, 0xEE, 0x95, 0x04, 0xEF])
        let nonce: Nonce = 0x0AEBA407
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = SpawnNPCRequestControllerNotification(
            value0: 1,
            objectId: 100,
            id: 2100,
            x: 65371,
            cy: 53,
            f: true,
            fh: 11,
            rx0: 65323,
            rx1: 65421,
            minimap: true
        )
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(packet.opcode, 0xC4)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.data, encryptedData)
    }
    
    func testNPCTalkRequest() throws {
        
        let encryptedData = Data([0x77, 0x90, 0x12, 0x3A, 0x9F, 0x7D, 0x90, 0xAE, 0x8C, 0xD6])
        let packetData = Data([0x36, 0x00, 0x64, 0x00, 0x00, 0x00, 0xF7, 0xFF, 0x35, 0x00])
        let nonce: Nonce = 0x7FB47235
        
        let packet = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        let value = NPCTalkRequest(objectID: 0x64, value0: 0x0035FFF7)
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(packet.opcode, 0x0036)
        XCTAssertEqual(packet.data, packetData)
    }
    
    func testNPCTalkNotification() throws {
        
        let encryptedData = Data([0xFD, 0x40, 0x58, 0x40, 0xAD, 0x31, 0xCA, 0x1A, 0x52, 0x65, 0x2E, 0xF8, 0x1F, 0xA9, 0x35, 0x41, 0xE7, 0x33, 0x89, 0xFF, 0x28, 0x0C, 0x2D, 0x6B, 0xD1, 0x94, 0x15, 0x2A, 0xFF, 0x5F, 0x90, 0xA6, 0xF9, 0x23, 0xC1, 0x55, 0x2E, 0xDA, 0x97, 0x92, 0xE8, 0x80, 0x21, 0x3F, 0x80, 0x86, 0xA0, 0xCF, 0x3A, 0xC2, 0x60, 0xA2, 0x02, 0x5D, 0x4C, 0xF7, 0xBE, 0xB6, 0x71, 0x2A, 0x9C, 0x72, 0xE5, 0x36, 0x93, 0x77, 0x7C, 0x49, 0x88, 0x3E, 0x0E, 0x88, 0x7E, 0x2B, 0x37, 0xEF, 0x3A, 0x45, 0xD3, 0x1A, 0xB6, 0x2D, 0xAC, 0xD6, 0x3E, 0xC3, 0x11, 0x0F, 0xCF, 0xFC, 0xC1, 0xD6, 0x4E, 0xD2, 0x0E, 0x18, 0xD4, 0xCE, 0x31, 0x5D, 0x40, 0x04, 0x92, 0x28, 0x6E, 0xDB, 0x53, 0xE2, 0x82, 0xAD, 0xFA, 0x25, 0xDE, 0x77, 0x86, 0x9D, 0xAD, 0x30, 0x72, 0x4E, 0x9C, 0x57, 0xAF, 0x5E, 0x22, 0x5E, 0xD9, 0xA9, 0xA1, 0x4E, 0xA8, 0x92, 0xC4, 0x15, 0x69, 0xE0, 0xA5, 0x18, 0x75, 0x42, 0xCF, 0xFD, 0x7B, 0x57, 0x44, 0x67, 0x8F, 0xD6, 0xDC, 0xAA, 0xD2, 0xF4, 0x34, 0x64, 0x81, 0xF9, 0x26, 0x39, 0x8A, 0x70, 0x27, 0x7D, 0xF6, 0xF1, 0x81, 0xCD, 0x0A, 0x36, 0x4F])
        
        let packetData = Data([0xED, 0x00, 0x04, 0x34, 0x08, 0x00, 0x00, 0x04, 0x9B, 0x00, 0x23, 0x62, 0x57, 0x65, 0x6C, 0x63, 0x6F, 0x6D, 0x65, 0x20, 0x74, 0x6F, 0x20, 0x4D, 0x61, 0x70, 0x6C, 0x65, 0x53, 0x74, 0x6F, 0x72, 0x79, 0x2E, 0x20, 0x57, 0x68, 0x61, 0x74, 0x20, 0x6A, 0x6F, 0x62, 0x20, 0x64, 0x6F, 0x20, 0x79, 0x6F, 0x75, 0x20, 0x77, 0x69, 0x73, 0x68, 0x20, 0x74, 0x6F, 0x20, 0x62, 0x65, 0x3F, 0x23, 0x6B, 0x20, 0x0D, 0x0A, 0x23, 0x4C, 0x30, 0x23, 0x42, 0x65, 0x67, 0x69, 0x6E, 0x6E, 0x65, 0x72, 0x23, 0x6C, 0x20, 0x0D, 0x0A, 0x20, 0x23, 0x4C, 0x31, 0x23, 0x57, 0x61, 0x72, 0x72, 0x69, 0x6F, 0x72, 0x23, 0x6C, 0x20, 0x0D, 0x0A, 0x20, 0x23, 0x4C, 0x32, 0x23, 0x4D, 0x61, 0x67, 0x69, 0x63, 0x69, 0x61, 0x6E, 0x23, 0x6B, 0x23, 0x6C, 0x20, 0x0D, 0x0A, 0x20, 0x23, 0x4C, 0x33, 0x23, 0x42, 0x6F, 0x77, 0x6D, 0x61, 0x6E, 0x23, 0x6C, 0x20, 0x0D, 0x0A, 0x20, 0x23, 0x4C, 0x34, 0x23, 0x54, 0x68, 0x69, 0x65, 0x66, 0x23, 0x6C, 0x20, 0x0D, 0x0A, 0x20, 0x23, 0x4C, 0x35, 0x23, 0x50, 0x69, 0x72, 0x61, 0x74, 0x65, 0x23, 0x6C])
        
        let nonce: Nonce = 0xD4EA3CBF
        
        guard let encrypedPacket = Packet.Encrypted(data: encryptedData) else {
            XCTFail()
            return
        }
        
        let packet = try encrypedPacket.decrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        let value = NPCTalkNotification.simple(
            npc: 2100,
            message: "#bWelcome to MapleStory. What job do you wish to be?#k \r\n#L0#Beginner#l \r\n #L1#Warrior#l \r\n #L2#Magician#k#l \r\n #L3#Bowman#l \r\n #L4#Thief#l \r\n #L5#Pirate#l"
        )
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(packet.opcode, 0xED)
        XCTAssertEqual(packet.data, packetData)
    }
    
    func testEmptyBuddyList() throws {
        
        let packetData = Data([0x3C, 0x00, 0x07, 0x00])
        let encryptedData = Data([0x62, 0xE3, 0x66, 0xE3, 0xF0, 0x9B, 0xC2, 0x2E])
        let nonce: Nonce = 0x9D83A31C
        
        guard let encrypedPacket = Packet.Encrypted(data: encryptedData) else {
            XCTFail()
            return
        }
        
        let packet = try encrypedPacket.decrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        let value = BuddyListNotification.update([])
        
        XCTAssertEncode(value, packet)
        XCTAssertEqual(packet.opcode, 0x3C)
        XCTAssertEqual(packet.data, packetData)
    }
    
    func testShowNotesEmpty() throws {
        
        let packetData = Data([0x26, 0x00, 0x02, 0x00])
        let encryptedData = Data([0x0D, 0x1A, 0x09, 0x1A, 0x44, 0xF8, 0xA6, 0x27])
        
        let nonce: Nonce = 0xEF49CCE5
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = ShowNotesNotification(value0: 2, notes: [])
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(packet.opcode, 0x0026)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.data, encryptedData)
    }
    
    func testPlayerHint() throws {
        
        let packetData = Data([0xA9, 0x00, 0x25, 0x00, 0x59, 0x6F, 0x75, 0x20, 0x63, 0x61, 0x6E, 0x20, 0x6D, 0x6F, 0x76, 0x65, 0x20, 0x62, 0x79, 0x20, 0x75, 0x73, 0x69, 0x6E, 0x67, 0x20, 0x74, 0x68, 0x65, 0x20, 0x61, 0x72, 0x72, 0x6F, 0x77, 0x20, 0x6B, 0x65, 0x79, 0x73, 0x2E, 0xFA, 0x00, 0x05, 0x00, 0x01])
        
        let encryptedData = Data([0x91, 0x74, 0xBF, 0x74, 0xE4, 0x4E, 0x97, 0x0E, 0x79, 0x29, 0xEB, 0x8C, 0x5F, 0x80, 0xA0, 0xAB, 0xC2, 0x4C, 0xCA, 0x8E, 0x9C, 0x6D, 0x17, 0xAD, 0x96, 0xC9, 0x81, 0x2C, 0x92, 0x9C, 0x44, 0x3A, 0x38, 0x99, 0xAD, 0xB7, 0x1E, 0xAB, 0x73, 0xE5, 0x7E, 0x06, 0x94, 0xB4, 0x77, 0xD3, 0xEE, 0x93, 0x38, 0x1F])
        
        let nonce: Nonce = 0x4A07508B
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = PlayerHintNotification(hint: "You can move by using the arrow keys.", width: 250, height: 5)
        
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(packet.opcode, 0x00A9)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.data, encryptedData)
    }
    
    func testKeyMap() {
        
        /*
         MaplePacketEncoder will write encrypted 07 01 00 00 00 00 00 00 00 00 00 00 00 04 0A 00 00 00 04 0C 00 00 00 04 0D 00 00 00 04 12 00 00 00 04 18 00 00 00 04 15 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 04 08 00 00 00 04 05 00 00 00 04 00 00 00 00 04 04 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 04 01 00 00 00 00 00 00 00 00 04 13 00 00 00 04 0E 00 00 00 04 0F 00 00 00 00 00 00 00 00 05 34 00 00 00 00 00 00 00 00 04 02 00 00 00 00 00 00 00 00 00 00 00 00 00 04 11 00 00 00 04 0B 00 00 00 00 00 00 00 00 04 03 00 00 00 04 14 00 00 00 00 00 00 00 00 04 10 00 00 00 04 17 00 00 00 00 00 00 00 00 04 09 00 00 00 05 32 00 00 00 05 33 00 00 00 04 06 00 00 00 00 00 00 00 00 04 16 00 00 00 00 00 00 00 00 04 07 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 05 35 00 00 00 05 36 00 00 00 00 00 00 00 00 06 64 00 00 00 06 65 00 00 00 06 66 00 00 00 06 67 00 00 00 06 68 00 00 00 06 69 00 00 00 06 6A 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
         MaplePacketEncoder header 35 8A F0 8B
         MaplePacketEncoder custom encrypted 14 53 08 78 80 03 00 82 A3 16 A9 A4 BE 02 80 77 38 CE EC A2 F2 1F 87 85 9F 86 3C A7 41 46 5B 29 09 B3 E0 FD 7C 27 5B 7F 1E E0 56 44 9A FF 4F 8C 42 D8 E6 1E F4 5E 1D 1C D3 DF E9 3D 77 4A 81 15 76 7F F9 20 84 7D 9E 52 36 47 D5 85 ED 3D 67 E1 9C 32 B4 E3 61 9D 75 D3 BC D0 F3 09 EC 8B A0 2B 18 E0 45 B0 2B 32 BF FA D2 9F 1B 01 55 28 47 25 BA 60 A6 CE 66 26 B1 7F 44 A6 6F B8 3B 6B AA 50 5A 3A EF 85 35 01 0B 61 AA 43 A8 FA 16 A8 FD D3 74 FD 95 2B 0A 0E A5 C2 E7 11 73 81 9F 93 6E 8D 65 BC 3B 89 BF 3C AB 2B B3 31 FC 45 34 7A 46 E1 73 31 B3 10 42 B4 19 19 BA 0C 7D 40 BA 4D 80 7D 37 6E 9B 37 A4 E3 86 D7 8F BC C2 16 D3 AA BC 56 08 55 DB DD 03 52 ED 18 50 E1 E2 40 DE 8C A6 34 87 A6 F5 67 AE DE 19 B5 25 EB C1 1F D5 B5 C3 59 C7 CD 87 73 C1 50 74 BD ED 86 3A 74 47 76 68 9E 9B EF 45 C7 BC 87 86 6E 77 7D F5 47 35 05 C8 9E 93 12 21 53 E2 26 DC 50 E2 AF F7 2C 9F 03 D1 FC F2 50 1F 28 54 F8 9A 67 A5 29 6C 17 77 4F 69 48 80 A8 40 E0 71 30 1D 67 0D 6A C2 D6 68 83 E3 25 A1 88 44 D5 11 F7 6A 66 A9 E6 10 31 0D 82 22 29 4E CB C2 42 1D 76 77 11 6F D7 C2 DB 3D 41 5F 22 B6 C0 D6 B4 80 5B 74 4F 49 FF 68 31 40 F5 9C ED D8 3F D3 8E 26 45 5A B9 32 D3 D1 B3 BE 43 79 25 DE 66 4C 3D 5B F0 08 9C 0B F6 B4 7C E9 98 26 6E A0 38 A0 05 98 6A ED 7B D1 E0 FE 81 31 99 DD 08 7C 60 22 F6 9C 22 94 76 FD 5E E2 E9 82 73 C4 F5 DB D4 C3 34 9E 21 0A 37 24 33 24 44 4E C5 09 8A 3A FC EE 54 69
         MapleAESOFB.crypt() input: 14 53 08 78 80 03 00 82 A3 16 A9 A4 BE 02 80 77 38 CE EC A2 F2 1F 87 85 9F 86 3C A7 41 46 5B 29 09 B3 E0 FD 7C 27 5B 7F 1E E0 56 44 9A FF 4F 8C 42 D8 E6 1E F4 5E 1D 1C D3 DF E9 3D 77 4A 81 15 76 7F F9 20 84 7D 9E 52 36 47 D5 85 ED 3D 67 E1 9C 32 B4 E3 61 9D 75 D3 BC D0 F3 09 EC 8B A0 2B 18 E0 45 B0 2B 32 BF FA D2 9F 1B 01 55 28 47 25 BA 60 A6 CE 66 26 B1 7F 44 A6 6F B8 3B 6B AA 50 5A 3A EF 85 35 01 0B 61 AA 43 A8 FA 16 A8 FD D3 74 FD 95 2B 0A 0E A5 C2 E7 11 73 81 9F 93 6E 8D 65 BC 3B 89 BF 3C AB 2B B3 31 FC 45 34 7A 46 E1 73 31 B3 10 42 B4 19 19 BA 0C 7D 40 BA 4D 80 7D 37 6E 9B 37 A4 E3 86 D7 8F BC C2 16 D3 AA BC 56 08 55 DB DD 03 52 ED 18 50 E1 E2 40 DE 8C A6 34 87 A6 F5 67 AE DE 19 B5 25 EB C1 1F D5 B5 C3 59 C7 CD 87 73 C1 50 74 BD ED 86 3A 74 47 76 68 9E 9B EF 45 C7 BC 87 86 6E 77 7D F5 47 35 05 C8 9E 93 12 21 53 E2 26 DC 50 E2 AF F7 2C 9F 03 D1 FC F2 50 1F 28 54 F8 9A 67 A5 29 6C 17 77 4F 69 48 80 A8 40 E0 71 30 1D 67 0D 6A C2 D6 68 83 E3 25 A1 88 44 D5 11 F7 6A 66 A9 E6 10 31 0D 82 22 29 4E CB C2 42 1D 76 77 11 6F D7 C2 DB 3D 41 5F 22 B6 C0 D6 B4 80 5B 74 4F 49 FF 68 31 40 F5 9C ED D8 3F D3 8E 26 45 5A B9 32 D3 D1 B3 BE 43 79 25 DE 66 4C 3D 5B F0 08 9C 0B F6 B4 7C E9 98 26 6E A0 38 A0 05 98 6A ED 7B D1 E0 FE 81 31 99 DD 08 7C 60 22 F6 9C 22 94 76 FD 5E E2 E9 82 73 C4 F5 DB D4 C3 34 9E 21 0A 37 24 33 24 44 4E C5 09 8A 3A FC EE 54 69
         MapleAESOFB.crypt() iv: BE A6 F4 75
         MapleAESOFB.crypt() output: 0A 76 19 91 9B CD 8F 16 44 CE A0 27 7C 8C 86 9D 0A 86 50 33 28 C7 36 89 5B 40 C8 67 BD E8 06 A8 57 4A DE F6 85 AD 74 EA 27 FD 96 48 27 72 AD 70 3B 56 4C 86 78 9B 9E FB A2 C0 D7 D9 90 4C CB 6D 03 1E EB A2 77 CD 76 2C D4 A6 6D 79 DE 15 D7 51 8A 74 74 3B AF E6 76 36 E7 66 9A 0D 7A 2A ED BF 79 F8 9F FE E6 C1 79 85 94 58 B6 2A 3D 1D 44 80 8A 0B C5 6A AA 79 E7 DA CE 9D 84 02 53 B9 86 66 6B 8F CE FF 8F 6C 42 81 BF D6 21 4F C2 AF BD EC 80 B4 FB 82 80 60 CF F0 C8 AA C1 B6 1D DB 17 42 9E 69 7D 48 7C 7C 61 9A FC 5B CC CD EC AE 29 0A FB EF 8F B9 5C 1A D2 53 6F D3 09 95 67 9B 7D D9 81 A0 98 8B 28 E0 EF 74 33 5F 40 CB 8F 5A B0 DD 4E 47 F1 CA D2 C8 E9 56 02 2C 30 F3 1B DC E9 9E 41 D4 EF 73 5B 32 51 9E F1 C4 D7 8C 9B DE 6E 8D 38 A8 F4 B3 96 DB 13 9D F3 75 19 FE 31 44 95 0F 74 B8 78 3B A6 43 BB 6D D7 87 F0 68 CE 7C FE 25 0F 82 68 35 EB 2A 51 8E 1C E7 6D AF AA 16 95 FD 6F 63 AE 5E 63 A8 A2 BB 6C 29 66 51 7A 71 C0 45 02 C1 2C 08 A7 C3 9F 70 9D 87 A4 A6 B6 25 68 80 7B 2D D8 F0 E5 42 EE F5 E3 15 08 E4 8A 9F EC 11 3A 8F E2 1A BC C3 20 53 7B 30 73 78 DE C7 96 EB 64 C8 56 81 17 AD 1C 8E E0 13 26 8E 34 8E C8 FF 1B 1B E1 58 40 70 F8 FE E7 F2 69 99 9D 5C C4 35 7F 7F 94 20 01 A0 25 65 EC DF 89 83 A4 38 56 94 E9 E4 15 5A BD 29 97 36 FC B7 73 A6 C8 BD BC F7 2B 7F B0 80 8B AB 0C 4A C1 A0 D2 91 78 70 5C D0 96 6C B7 9F 1F D2 5F 2C 37 C6 23 5D D6 21 F3 54 92 D4 0F 4A CE
         MaplePacketEncoder AES encrypted 0A 76 19 91 9B CD 8F 16 44 CE A0 27 7C 8C 86 9D 0A 86 50 33 28 C7 36 89 5B 40 C8 67 BD E8 06 A8 57 4A DE F6 85 AD 74 EA 27 FD 96 48 27 72 AD 70 3B 56 4C 86 78 9B 9E FB A2 C0 D7 D9 90 4C CB 6D 03 1E EB A2 77 CD 76 2C D4 A6 6D 79 DE 15 D7 51 8A 74 74 3B AF E6 76 36 E7 66 9A 0D 7A 2A ED BF 79 F8 9F FE E6 C1 79 85 94 58 B6 2A 3D 1D 44 80 8A 0B C5 6A AA 79 E7 DA CE 9D 84 02 53 B9 86 66 6B 8F CE FF 8F 6C 42 81 BF D6 21 4F C2 AF BD EC 80 B4 FB 82 80 60 CF F0 C8 AA C1 B6 1D DB 17 42 9E 69 7D 48 7C 7C 61 9A FC 5B CC CD EC AE 29 0A FB EF 8F B9 5C 1A D2 53 6F D3 09 95 67 9B 7D D9 81 A0 98 8B 28 E0 EF 74 33 5F 40 CB 8F 5A B0 DD 4E 47 F1 CA D2 C8 E9 56 02 2C 30 F3 1B DC E9 9E 41 D4 EF 73 5B 32 51 9E F1 C4 D7 8C 9B DE 6E 8D 38 A8 F4 B3 96 DB 13 9D F3 75 19 FE 31 44 95 0F 74 B8 78 3B A6 43 BB 6D D7 87 F0 68 CE 7C FE 25 0F 82 68 35 EB 2A 51 8E 1C E7 6D AF AA 16 95 FD 6F 63 AE 5E 63 A8 A2 BB 6C 29 66 51 7A 71 C0 45 02 C1 2C 08 A7 C3 9F 70 9D 87 A4 A6 B6 25 68 80 7B 2D D8 F0 E5 42 EE F5 E3 15 08 E4 8A 9F EC 11 3A 8F E2 1A BC C3 20 53 7B 30 73 78 DE C7 96 EB 64 C8 56 81 17 AD 1C 8E E0 13 26 8E 34 8E C8 FF 1B 1B E1 58 40 70 F8 FE E7 F2 69 99 9D 5C C4 35 7F 7F 94 20 01 A0 25 65 EC DF 89 83 A4 38 56 94 E9 E4 15 5A BD 29 97 36 FC B7 73 A6 C8 BD BC F7 2B 7F B0 80 8B AB 0C 4A C1 A0 D2 91 78 70 5C D0 96 6C B7 9F 1F D2 5F 2C 37 C6 23 5D D6 21 F3 54 92 D4 0F 4A CE
         MaplePacketEncoder output 35 8A F0 8B 0A 76 19 91 9B CD 8F 16 44 CE A0 27 7C 8C 86 9D 0A 86 50 33 28 C7 36 89 5B 40 C8 67 BD E8 06 A8 57 4A DE F6 85 AD 74 EA 27 FD 96 48 27 72 AD 70 3B 56 4C 86 78 9B 9E FB A2 C0 D7 D9 90 4C CB 6D 03 1E EB A2 77 CD 76 2C D4 A6 6D 79 DE 15 D7 51 8A 74 74 3B AF E6 76 36 E7 66 9A 0D 7A 2A ED BF 79 F8 9F FE E6 C1 79 85 94 58 B6 2A 3D 1D 44 80 8A 0B C5 6A AA 79 E7 DA CE 9D 84 02 53 B9 86 66 6B 8F CE FF 8F 6C 42 81 BF D6 21 4F C2 AF BD EC 80 B4 FB 82 80 60 CF F0 C8 AA C1 B6 1D DB 17 42 9E 69 7D 48 7C 7C 61 9A FC 5B CC CD EC AE 29 0A FB EF 8F B9 5C 1A D2 53 6F D3 09 95 67 9B 7D D9 81 A0 98 8B 28 E0 EF 74 33 5F 40 CB 8F 5A B0 DD 4E 47 F1 CA D2 C8 E9 56 02 2C 30 F3 1B DC E9 9E 41 D4 EF 73 5B 32 51 9E F1 C4 D7 8C 9B DE 6E 8D 38 A8 F4 B3 96 DB 13 9D F3 75 19 FE 31 44 95 0F 74 B8 78 3B A6 43 BB 6D D7 87 F0 68 CE 7C FE 25 0F 82 68 35 EB 2A 51 8E 1C E7 6D AF AA 16 95 FD 6F 63 AE 5E 63 A8 A2 BB 6C 29 66 51 7A 71 C0 45 02 C1 2C 08 A7 C3 9F 70 9D 87 A4 A6 B6 25 68 80 7B 2D D8 F0 E5 42 EE F5 E3 15 08 E4 8A 9F EC 11 3A 8F E2 1A BC C3 20 53 7B 30 73 78 DE C7 96 EB 64 C8 56 81 17 AD 1C 8E E0 13 26 8E 34 8E C8 FF 1B 1B E1 58 40 70 F8 FE E7 F2 69 99 9D 5C C4 35 7F 7F 94 20 01 A0 25 65 EC DF 89 83 A4 38 56 94 E9 E4 15 5A BD 29 97 36 FC B7 73 A6 C8 BD BC F7 2B 7F B0 80 8B AB 0C 4A C1 A0 D2 91 78 70 5C D0 96 6C B7 9F 1F D2 5F 2C 37 C6 23 5D D6 21 F3 54 92 D4 0F 4A CE
         */
    }
    
    func testPlayerUpdate() {
        
        /*
         MaplePacketDecoder encrypted packet D9 E5
         Recieve IV 0A 65 35 B0
         MapleAESOFB.crypt() input: D9 E5
         MapleAESOFB.crypt() iv: 0A 65 35 B0
         MapleAESOFB.crypt() output: 54 56
         MaplePacketDecoder AES decrypted packet 54 56
         MaplePacketDecoder custom decrypted packet C0 00
         Incoming packet 0x00C0
         */
    }
    
    func testMovePlayer() {
        
        /*
         MaplePacketDecoder encrypted packet 8C 08 25 73 B4 3D 89 76 61 15 F3 2B F6 C9 2E C3 C8 59 7F 5B 5B B2 87 77 3D F3 37 D0 67 B2 D9 D6 C4 ED DA 97 DB 07 D2 08 C5 EA 43 9D 3B DB 18 0F 31 BB 36 A3 AD 73 D8 0C 6C ED 53 A7 E1 EC E1 C9 55 6C F0 75
         Recieve IV 9A 3B C4 2B
         MapleAESOFB.crypt() input: 8C 08 25 73 B4 3D 89 76 61 15 F3 2B F6 C9 2E C3 C8 59 7F 5B 5B B2 87 77 3D F3 37 D0 67 B2 D9 D6 C4 ED DA 97 DB 07 D2 08 C5 EA 43 9D 3B DB 18 0F 31 BB 36 A3 AD 73 D8 0C 6C ED 53 A7 E1 EC E1 C9 55 6C F0 75
         MapleAESOFB.crypt() iv: 9A 3B C4 2B
         MapleAESOFB.crypt() output: 69 A4 B7 CE D3 F0 00 45 A7 77 60 13 F3 1E BD C0 31 21 57 30 25 53 D8 7F A3 D0 C3 51 81 66 99 A9 87 89 F5 38 49 E3 D2 72 89 CE 66 2A 6F 52 3E 09 42 E2 B9 96 FB E5 47 A8 6F 1C 05 81 E9 4C 5C F1 0E 58 DC B4
         MaplePacketDecoder AES decrypted packet 69 A4 B7 CE D3 F0 00 45 A7 77 60 13 F3 1E BD C0 31 21 57 30 25 53 D8 7F A3 D0 C3 51 81 66 99 A9 87 89 F5 38 49 E3 D2 72 89 CE 66 2A 6F 52 3E 09 42 E2 B9 96 FB E5 47 A8 6F 1C 05 81 E9 4C 5C F1 0E 58 DC B4
         MaplePacketDecoder custom decrypted packet 26 00 01 6C 00 1F 00 03 00 6C 00 2D 00 00 00 F0 00 00 00 06 78 00 00 6C 00 35 00 00 00 00 00 00 00 06 1A 00 00 6C 00 35 00 00 00 00 00 0B 00 04 6C 01 11 00 00 00 00 00 00 00 00 00 6C 00 1F 00 6C 00 35 00
         Incoming packet 0x0026
         */
    }
    
    func testChangeMapSpecial() {
        
        /*
         MaplePacketDecoder encrypted packet 42 69 01 92 BA E8 07 DA 91 2A 3B B9 9F 36 62 61 EC 03
         Recieve IV DA F1 55 F7
         MapleAESOFB.crypt() input: 42 69 01 92 BA E8 07 DA 91 2A 3B B9 9F 36 62 61 EC 03
         MapleAESOFB.crypt() iv: DA F1 55 F7
         MapleAESOFB.crypt() output: 91 E5 06 B8 A2 44 9B 82 D8 17 DA FE 50 96 79 CD 71 B8
         MaplePacketDecoder AES decrypted packet 91 E5 06 B8 A2 44 9B 82 D8 17 DA FE 50 96 79 CD 71 B8
         MaplePacketDecoder custom decrypted packet 5C 00 01 09 00 74 75 74 6F 72 69 61 6C 30 6C 00 35 00
         Incoming packet 0x005C
         */
        
        
    }
}
