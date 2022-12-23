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
        
        let value = ServerMessageNotification.topScrolling(message: "")
        
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(value.type, .topScrolling)
        XCTAssertEqual(packet.opcode, 0x0041)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.data, encryptedData)
    }
    
    func testServerMessagePinkText() throws {
        
        let packetData = Data([0x41, 0x00, 0x05, 0x54, 0x00, 0x5B, 0x54, 0x69, 0x70, 0x5D, 0x20, 0x3A, 0x20, 0x54, 0x68, 0x65, 0x20, 0x73, 0x75, 0x6D, 0x20, 0x6F, 0x66, 0x20, 0x74, 0x68, 0x65, 0x20, 0x62, 0x61, 0x73, 0x65, 0x2D, 0x31, 0x30, 0x20, 0x6C, 0x6F, 0x67, 0x61, 0x72, 0x69, 0x74, 0x68, 0x6D, 0x73, 0x20, 0x6F, 0x66, 0x20, 0x74, 0x68, 0x65, 0x20, 0x64, 0x69, 0x76, 0x69, 0x73, 0x6F, 0x72, 0x73, 0x20, 0x6F, 0x66, 0x20, 0x31, 0x30, 0x5E, 0x6E, 0x20, 0x69, 0x73, 0x20, 0x37, 0x39, 0x32, 0x2E, 0x20, 0x57, 0x68, 0x61, 0x74, 0x20, 0x69, 0x73, 0x20, 0x6E, 0x3F])
        
        let encryptedData = Data([0xA5, 0x68, 0xFC, 0x68, 0x63, 0x9F, 0x59, 0x32, 0x8B, 0x5B, 0xFB, 0xC6, 0x51, 0xB2, 0x29, 0x98, 0xEC, 0x6E, 0xEE, 0x8A, 0xD7, 0xB1, 0x43, 0x2B, 0xB4, 0x90, 0x5B, 0x25, 0xE2, 0x01, 0xA6, 0xF8, 0x07, 0x0F, 0x2D, 0x8B, 0x69, 0xE1, 0x9E, 0x6A, 0xE3, 0x2C, 0x7C, 0xD1, 0xE0, 0x7A, 0xCF, 0x15, 0xF8, 0x09, 0x2C, 0xEE, 0xBC, 0xDC, 0x69, 0x0E, 0xE7, 0x14, 0x71, 0x43, 0x56, 0x6E, 0x1A, 0x78, 0x78, 0xDA, 0x15, 0xF3, 0xB1, 0xED, 0x37, 0x03, 0x39, 0xAF, 0x86, 0xFF, 0xB8, 0x80, 0xFB, 0xD2, 0x55, 0xD4, 0xCE, 0xEA, 0xCC, 0x48, 0x03, 0x35, 0x9D, 0x2F, 0x3E, 0xED, 0x4F])
        
        let nonce: Nonce = 0xB8986497
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let message = "[Tip] : The sum of the base-10 logarithms of the divisors of 10^n is 792. What is n?"
        let value = ServerMessageNotification.pinkText(message: message)
        
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(value.type, .pinkText)
        XCTAssertEqual(value.message, message)
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
        
        let packet = Packet(Data([0x5C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x6A, 0x7A, 0xEB, 0x6B, 0xF8, 0x17, 0xD7, 0x13, 0xCD, 0xC5, 0xAD, 0x78, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0E, 0x00, 0x00, 0x00, 0x63, 0x6F, 0x6C, 0x65, 0x6D, 0x61, 0x6E, 0x63, 0x64, 0x61, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x4E, 0x00, 0x00, 0x47, 0x75, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x04, 0x00, 0x06, 0x00, 0x09, 0x00, 0x06, 0x00, 0x32, 0x00, 0x32, 0x00, 0x05, 0x00, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x14, 0x00, 0x00, 0x00, 0x00, 0x64, 0x64, 0x64, 0x64, 0x64, 0x05, 0x01, 0x82, 0xDE, 0x0F, 0x00, 0x00, 0x00, 0x80, 0x05, 0xBB, 0x46, 0xE6, 0x17, 0x02, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x01, 0xA2, 0x2C, 0x10, 0x00, 0x00, 0x00, 0x80, 0x05, 0xBB, 0x46, 0xE6, 0x17, 0x02, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x01, 0x85, 0x5B, 0x10, 0x00, 0x00, 0x00, 0x80, 0x05, 0xBB, 0x46, 0xE6, 0x17, 0x02, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0B, 0x01, 0xF0, 0xDD, 0x13, 0x00, 0x00, 0x00, 0x80, 0x05, 0xBB, 0x46, 0xE6, 0x17, 0x02, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0xE9, 0x7D, 0x3F, 0x00, 0x00, 0x00, 0x80, 0x05, 0xBB, 0x46, 0xE6, 0x17, 0x02, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0xFF, 0xC9, 0x9A, 0x3B, 0x00, 0x00, 0x00, 0x00, 0x80, 0x59, 0xC3, 0x5B, 0x89, 0x16, 0xD9, 0x01]))
        
        //let value =
        //XCTAssertEncode(value, packet)
        XCTAssertEqual(packet.opcode, 0x005C)
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
    
    func testNPCTalkNotificationSimple() throws {
        
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
    
    func testNPCTalkNotificationSimple2() {
        
        let packetData = Data([0xED, 0x00, 0x04, 0xF0, 0x55, 0x00, 0x00, 0x04, 0x18, 0x01, 0x57, 0x68, 0x61, 0x74, 0x20, 0x64, 0x6F, 0x20, 0x79, 0x6F, 0x75, 0x20, 0x77, 0x61, 0x6E, 0x74, 0x20, 0x6D, 0x65, 0x20, 0x74, 0x6F, 0x20, 0x64, 0x6F, 0x20, 0x66, 0x6F, 0x72, 0x20, 0x79, 0x6F, 0x75, 0x3F, 0x20, 0x08, 0x0D, 0x0A, 0x23, 0x4C, 0x30, 0x23, 0x54, 0x72, 0x61, 0x76, 0x65, 0x6C, 0x20, 0x74, 0x6F, 0x20, 0x54, 0x6F, 0x77, 0x6E, 0x73, 0x20, 0x6F, 0x72, 0x20, 0x46, 0x69, 0x67, 0x68, 0x74, 0x20, 0x42, 0x6F, 0x73, 0x73, 0x65, 0x73, 0x0A, 0x23, 0x6C, 0x0D, 0x0A, 0x23, 0x4C, 0x31, 0x23, 0x4A, 0x6F, 0x62, 0x20, 0x41, 0x64, 0x76, 0x61, 0x6E, 0x63, 0x65, 0x0A, 0x23, 0x6C, 0x0D, 0x0A, 0x23, 0x4C, 0x32, 0x23, 0x52, 0x65, 0x73, 0x65, 0x74, 0x20, 0x53, 0x74, 0x61, 0x74, 0x73, 0x0A, 0x23, 0x6C, 0x0D, 0x0A, 0x23, 0x4C, 0x33, 0x23, 0x43, 0x68, 0x61, 0x6E, 0x67, 0x65, 0x20, 0x4D, 0x75, 0x73, 0x69, 0x63, 0x23, 0x6C, 0x0D, 0x0A, 0x23, 0x4C, 0x34, 0x23, 0x42, 0x75, 0x79, 0x20, 0x4E, 0x58, 0x23, 0x6C, 0x0D, 0x0A, 0x23, 0x4C, 0x35, 0x23, 0x45, 0x78, 0x63, 0x68, 0x61, 0x6E, 0x67, 0x65, 0x20, 0x4D, 0x65, 0x73, 0x6F, 0x73, 0x20, 0x66, 0x6F, 0x72, 0x20, 0x49, 0x74, 0x65, 0x6D, 0x73, 0x23, 0x6C, 0x0D, 0x0A, 0x23, 0x4C, 0x36, 0x23, 0x47, 0x65, 0x74, 0x20, 0x42, 0x75, 0x66, 0x66, 0x73, 0x23, 0x6C, 0x0D, 0x0A, 0x23, 0x4C, 0x37, 0x23, 0x47, 0x6F, 0x20, 0x54, 0x6F, 0x20, 0x50, 0x76, 0x50, 0x23, 0x6C, 0x0D, 0x0A, 0x23, 0x4C, 0x38, 0x23, 0x44, 0x6F, 0x6E, 0x61, 0x74, 0x69, 0x6F, 0x6E, 0x20, 0x50, 0x6F, 0x69, 0x6E, 0x74, 0x20, 0x4E, 0x50, 0x43, 0x23, 0x6C, 0x0D, 0x0A, 0x23, 0x4C, 0x39, 0x23, 0x50, 0x69, 0x72, 0x61, 0x74, 0x65, 0x20, 0x53, 0x68, 0x6F, 0x70, 0x23, 0x6C, 0x0D, 0x0A, 0x23, 0x4C, 0x31, 0x30, 0x23, 0x4B, 0x61, 0x72, 0x6D, 0x61, 0x20, 0x53, 0x68, 0x6F, 0x70, 0x23, 0x6C])
        
        let packet = Packet(packetData)
        
        let value = NPCTalkNotification.simple(
            npc: 22000,
            message: "What do you want me to do for you? \u{08}\r\n#L0#Travel to Towns or Fight Bosses\n#l\r\n#L1#Job Advance\n#l\r\n#L2#Reset Stats\n#l\r\n#L3#Change Music#l\r\n#L4#Buy NX#l\r\n#L5#Exchange Mesos for Items#l\r\n#L6#Get Buffs#l\r\n#L7#Go To PvP#l\r\n#L8#Donation Point NPC#l\r\n#L9#Pirate Shop#l\r\n#L10#Karma Shop#l"
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
    
    func testBuddyList() throws {
        
        let packet = Packet(Data([0x3C, 0x00, 0x07, 0x01, 0x01, 0x00, 0x00, 0x00, 0x41, 0x64, 0x6D, 0x69, 0x6E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFE, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00]))
        
        let value = BuddyListNotification.update([
            BuddyListNotification.Buddy(
                id: 1,
                name: "Admin",
                value0: 0,
                channel: -2
            )
        ])
        
        XCTAssertEncode(value, packet)
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
    
    func testKeyMap() throws {
        
        let packetData = Data([0x07, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x0A, 0x00, 0x00, 0x00, 0x04, 0x0C, 0x00, 0x00, 0x00, 0x04, 0x0D, 0x00, 0x00, 0x00, 0x04, 0x12, 0x00, 0x00, 0x00, 0x04, 0x18, 0x00, 0x00, 0x00, 0x04, 0x15, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x08, 0x00, 0x00, 0x00, 0x04, 0x05, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x04, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x13, 0x00, 0x00, 0x00, 0x04, 0x0E, 0x00, 0x00, 0x00, 0x04, 0x0F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x34, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x11, 0x00, 0x00, 0x00, 0x04, 0x0B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x03, 0x00, 0x00, 0x00, 0x04, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x10, 0x00, 0x00, 0x00, 0x04, 0x17, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x09, 0x00, 0x00, 0x00, 0x05, 0x32, 0x00, 0x00, 0x00, 0x05, 0x33, 0x00, 0x00, 0x00, 0x04, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x35, 0x00, 0x00, 0x00, 0x05, 0x36, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x64, 0x00, 0x00, 0x00, 0x06, 0x65, 0x00, 0x00, 0x00, 0x06, 0x66, 0x00, 0x00, 0x00, 0x06, 0x67, 0x00, 0x00, 0x00, 0x06, 0x68, 0x00, 0x00, 0x00, 0x06, 0x69, 0x00, 0x00, 0x00, 0x06, 0x6A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        
        let encryptedData = Data([0x35, 0x8A, 0xF0, 0x8B, 0x0A, 0x76, 0x19, 0x91, 0x9B, 0xCD, 0x8F, 0x16, 0x44, 0xCE, 0xA0, 0x27, 0x7C, 0x8C, 0x86, 0x9D, 0x0A, 0x86, 0x50, 0x33, 0x28, 0xC7, 0x36, 0x89, 0x5B, 0x40, 0xC8, 0x67, 0xBD, 0xE8, 0x06, 0xA8, 0x57, 0x4A, 0xDE, 0xF6, 0x85, 0xAD, 0x74, 0xEA, 0x27, 0xFD, 0x96, 0x48, 0x27, 0x72, 0xAD, 0x70, 0x3B, 0x56, 0x4C, 0x86, 0x78, 0x9B, 0x9E, 0xFB, 0xA2, 0xC0, 0xD7, 0xD9, 0x90, 0x4C, 0xCB, 0x6D, 0x03, 0x1E, 0xEB, 0xA2, 0x77, 0xCD, 0x76, 0x2C, 0xD4, 0xA6, 0x6D, 0x79, 0xDE, 0x15, 0xD7, 0x51, 0x8A, 0x74, 0x74, 0x3B, 0xAF, 0xE6, 0x76, 0x36, 0xE7, 0x66, 0x9A, 0x0D, 0x7A, 0x2A, 0xED, 0xBF, 0x79, 0xF8, 0x9F, 0xFE, 0xE6, 0xC1, 0x79, 0x85, 0x94, 0x58, 0xB6, 0x2A, 0x3D, 0x1D, 0x44, 0x80, 0x8A, 0x0B, 0xC5, 0x6A, 0xAA, 0x79, 0xE7, 0xDA, 0xCE, 0x9D, 0x84, 0x02, 0x53, 0xB9, 0x86, 0x66, 0x6B, 0x8F, 0xCE, 0xFF, 0x8F, 0x6C, 0x42, 0x81, 0xBF, 0xD6, 0x21, 0x4F, 0xC2, 0xAF, 0xBD, 0xEC, 0x80, 0xB4, 0xFB, 0x82, 0x80, 0x60, 0xCF, 0xF0, 0xC8, 0xAA, 0xC1, 0xB6, 0x1D, 0xDB, 0x17, 0x42, 0x9E, 0x69, 0x7D, 0x48, 0x7C, 0x7C, 0x61, 0x9A, 0xFC, 0x5B, 0xCC, 0xCD, 0xEC, 0xAE, 0x29, 0x0A, 0xFB, 0xEF, 0x8F, 0xB9, 0x5C, 0x1A, 0xD2, 0x53, 0x6F, 0xD3, 0x09, 0x95, 0x67, 0x9B, 0x7D, 0xD9, 0x81, 0xA0, 0x98, 0x8B, 0x28, 0xE0, 0xEF, 0x74, 0x33, 0x5F, 0x40, 0xCB, 0x8F, 0x5A, 0xB0, 0xDD, 0x4E, 0x47, 0xF1, 0xCA, 0xD2, 0xC8, 0xE9, 0x56, 0x02, 0x2C, 0x30, 0xF3, 0x1B, 0xDC, 0xE9, 0x9E, 0x41, 0xD4, 0xEF, 0x73, 0x5B, 0x32, 0x51, 0x9E, 0xF1, 0xC4, 0xD7, 0x8C, 0x9B, 0xDE, 0x6E, 0x8D, 0x38, 0xA8, 0xF4, 0xB3, 0x96, 0xDB, 0x13, 0x9D, 0xF3, 0x75, 0x19, 0xFE, 0x31, 0x44, 0x95, 0x0F, 0x74, 0xB8, 0x78, 0x3B, 0xA6, 0x43, 0xBB, 0x6D, 0xD7, 0x87, 0xF0, 0x68, 0xCE, 0x7C, 0xFE, 0x25, 0x0F, 0x82, 0x68, 0x35, 0xEB, 0x2A, 0x51, 0x8E, 0x1C, 0xE7, 0x6D, 0xAF, 0xAA, 0x16, 0x95, 0xFD, 0x6F, 0x63, 0xAE, 0x5E, 0x63, 0xA8, 0xA2, 0xBB, 0x6C, 0x29, 0x66, 0x51, 0x7A, 0x71, 0xC0, 0x45, 0x02, 0xC1, 0x2C, 0x08, 0xA7, 0xC3, 0x9F, 0x70, 0x9D, 0x87, 0xA4, 0xA6, 0xB6, 0x25, 0x68, 0x80, 0x7B, 0x2D, 0xD8, 0xF0, 0xE5, 0x42, 0xEE, 0xF5, 0xE3, 0x15, 0x08, 0xE4, 0x8A, 0x9F, 0xEC, 0x11, 0x3A, 0x8F, 0xE2, 0x1A, 0xBC, 0xC3, 0x20, 0x53, 0x7B, 0x30, 0x73, 0x78, 0xDE, 0xC7, 0x96, 0xEB, 0x64, 0xC8, 0x56, 0x81, 0x17, 0xAD, 0x1C, 0x8E, 0xE0, 0x13, 0x26, 0x8E, 0x34, 0x8E, 0xC8, 0xFF, 0x1B, 0x1B, 0xE1, 0x58, 0x40, 0x70, 0xF8, 0xFE, 0xE7, 0xF2, 0x69, 0x99, 0x9D, 0x5C, 0xC4, 0x35, 0x7F, 0x7F, 0x94, 0x20, 0x01, 0xA0, 0x25, 0x65, 0xEC, 0xDF, 0x89, 0x83, 0xA4, 0x38, 0x56, 0x94, 0xE9, 0xE4, 0x15, 0x5A, 0xBD, 0x29, 0x97, 0x36, 0xFC, 0xB7, 0x73, 0xA6, 0xC8, 0xBD, 0xBC, 0xF7, 0x2B, 0x7F, 0xB0, 0x80, 0x8B, 0xAB, 0x0C, 0x4A, 0xC1, 0xA0, 0xD2, 0x91, 0x78, 0x70, 0x5C, 0xD0, 0x96, 0x6C, 0xB7, 0x9F, 0x1F, 0xD2, 0x5F, 0x2C, 0x37, 0xC6, 0x23, 0x5D, 0xD6, 0x21, 0xF3, 0x54, 0x92, 0xD4, 0x0F, 0x4A, 0xCE])
        
        let nonce: Nonce = 0xBEA6F475
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = KeyMapNotification(keyMap: [17: KeyBinding(type: 4, action: 5), 35: KeyBinding(type: 4, action: 11), 40: KeyBinding(type: 4, action: 16), 5: KeyBinding(type: 4, action: 18), 64: KeyBinding(type: 6, action: 105), 19: KeyBinding(type: 4, action: 4), 29: KeyBinding(type: 5, action: 52), 34: KeyBinding(type: 4, action: 17), 50: KeyBinding(type: 4, action: 7), 61: KeyBinding(type: 6, action: 102), 18: KeyBinding(type: 4, action: 0), 57: KeyBinding(type: 5, action: 54), 56: KeyBinding(type: 5, action: 53), 60: KeyBinding(type: 6, action: 101), 6: KeyBinding(type: 4, action: 24), 25: KeyBinding(type: 4, action: 19), 31: KeyBinding(type: 4, action: 2), 45: KeyBinding(type: 5, action: 51), 26: KeyBinding(type: 4, action: 14), 3: KeyBinding(type: 4, action: 12), 65: KeyBinding(type: 6, action: 106), 7: KeyBinding(type: 4, action: 21), 63: KeyBinding(type: 6, action: 104), 27: KeyBinding(type: 4, action: 15), 2: KeyBinding(type: 4, action: 10), 62: KeyBinding(type: 6, action: 103), 4: KeyBinding(type: 4, action: 13), 23: KeyBinding(type: 4, action: 1), 59: KeyBinding(type: 6, action: 100), 16: KeyBinding(type: 4, action: 8), 48: KeyBinding(type: 4, action: 22), 41: KeyBinding(type: 4, action: 23), 46: KeyBinding(type: 4, action: 6), 43: KeyBinding(type: 4, action: 9), 38: KeyBinding(type: 4, action: 20), 44: KeyBinding(type: 5, action: 50), 37: KeyBinding(type: 4, action: 3)])
        
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(packet.opcode, 0x107)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.data, encryptedData)
    }
    
    func testPlayerUpdate() throws {
        
        let encryptedData = Data([0xD9, 0xE5])
        let packetData = Data([0xC0, 0x00])
        let nonce: Nonce = 0x0A6535B0
        
        let packet = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        let value = PlayerUpdateRequest()
        
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(packet.opcode, 0x00C0)
        XCTAssertEqual(packet.data, packetData)
    }
    
    func testMovePlayer() throws {
        
        let encryptedData = Data([0x8C, 0x08, 0x25, 0x73, 0xB4, 0x3D, 0x89, 0x76, 0x61, 0x15, 0xF3, 0x2B, 0xF6, 0xC9, 0x2E, 0xC3, 0xC8, 0x59, 0x7F, 0x5B, 0x5B, 0xB2, 0x87, 0x77, 0x3D, 0xF3, 0x37, 0xD0, 0x67, 0xB2, 0xD9, 0xD6, 0xC4, 0xED, 0xDA, 0x97, 0xDB, 0x07, 0xD2, 0x08, 0xC5, 0xEA, 0x43, 0x9D, 0x3B, 0xDB, 0x18, 0x0F, 0x31, 0xBB, 0x36, 0xA3, 0xAD, 0x73, 0xD8, 0x0C, 0x6C, 0xED, 0x53, 0xA7, 0xE1, 0xEC, 0xE1, 0xC9, 0x55, 0x6C, 0xF0, 0x75])
        
        let packetData = Data([0x26, 0x00, 0x01, 0x6C, 0x00, 0x1F, 0x00, 0x03, 0x00, 0x6C, 0x00, 0x2D, 0x00, 0x00, 0x00, 0xF0, 0x00, 0x00, 0x00, 0x06, 0x78, 0x00, 0x00, 0x6C, 0x00, 0x35, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x1A, 0x00, 0x00, 0x6C, 0x00, 0x35, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0B, 0x00, 0x04, 0x6C, 0x01, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x6C, 0x00, 0x1F, 0x00, 0x6C, 0x00, 0x35, 0x00])
        
        let nonce: Nonce = 0x9A3BC42B
        
        let packet = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        let value = MovePlayerRequest(
            value0: 1,
            value1: 2031724,
            movements: [
                .absolute(Movement.Absolute(command: 0, xpos: 108, ypos: 45, xwobble: 0, ywobble: 240, value0: 0, newState: 6, duration: 120)),
                .absolute(Movement.Absolute(command: 0, xpos: 108, ypos: 53, xwobble: 0, ywobble: 0, value0: 0, newState: 6, duration: 26)),
                .absolute(Movement.Absolute(command: 0, xpos: 108, ypos: 53, xwobble: 0, ywobble: 0, value0: 11, newState: 4, duration: 364))
            ],
            value2: 0x11,
            value3: 30399430635814912,
            value4: 0x35
        )
        
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(packet.opcode, 0x0026)
        XCTAssertEqual(packet.data, packetData)
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
    
    func testBBSOperationRequest() throws {
        
        
    }
    
    func testBBSOperationResponse() throws {
        
        let packetData = Data([0x38, 0x00, 0x04, 0x01, 0x0A, 0x00, 0x00, 0x00])
        let encryptedData = Data([0x99, 0x26, 0x4E, 0x82, 0x5D, 0xC3, 0xC0, 0xF3])
        let nonce: Nonce = 0x4A21C6BB
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
                
        //XCTAssertEncode(value, packet)
        //XCTAssertDecode(value, packet)
        XCTAssertEqual(packet.opcode, 0x38)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.parameters, encryptedData)
    }
    
    func testUpdateStats() throws {
        
        let packetData = Data([0x1C, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x9E, 0x67])
        let encryptedData = Data([0xBD, 0xB7, 0xB4, 0xB7, 0x09, 0x21, 0xDD, 0x98, 0xFC, 0x9B, 0x0A, 0x42, 0x51])
        let nonce: Nonce = 0x2B6C7C48
        
        let encryptedPacket = Packet.Encrypted(encryptedData)
        let packet = Packet(packetData)
        let decrypted = try encryptedPacket.decrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(decrypted, packet)
        XCTAssertEqual(try packet.encrypt(key: .default, nonce: nonce, version: .v62), encryptedPacket)
    }
    
    func testGeneralChatRequest() throws {
        
        let encryptedData = Data([0x2A, 0xD6, 0x78, 0xF3, 0x67, 0x9A, 0xA7, 0x35])
        let packetData = Data([0x2E, 0x00, 0x03, 0x00, 0x68, 0x65, 0x79, 0x00])
        let nonce: Nonce = 0x9842CEA1
        
        let packet = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        let value = GeneralChatRequest(
            message: "hey",
            show: false
        )
        
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(packet.opcode, 0x002E)
        XCTAssertEqual(packet.data, packetData)
    }
    
    func testGeneralChatNotification() {
        
        
    }
}
