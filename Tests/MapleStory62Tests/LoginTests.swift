//
//  LoginTests.swift
//  
//
//  Created by Alsey Coleman Miller on 12/21/22.
//

import Foundation
import XCTest
@testable import MapleStory
@testable import MapleStory62

final class LoginTests: XCTestCase {
    
    func testHello() throws {
        
        let packet: Packet = [0x0D, 0x00, 0x3E, 0x00, 0x00, 0x00, 0x46, 0x72, 0x7A, 0x18, 0x52, 0x30, 0x78, 0x14, 0x08]
        
        let value = HelloPacket(
            recieveNonce: 0x46727A18,
            sendNonce: 0x52307814,
            region: .global
        )
        
        XCTAssertEqual(value.version, .v62)
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
    }
    
    func testPing() throws {
        
        let encryptedData = Data([0x48, 0x7D, 0x4A, 0x7D, 0x01, 0x5C])
        let encryptedParameters = Data([0x01, 0x5C])
        let packetData = Data([0x11, 0x00])
        let nonce: Nonce = 0x27568982
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = PingPacket()
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.data.suffix(2), encryptedParameters)
        XCTAssertEqual(encrypted.parametersSize, 2)
        XCTAssertEqual(encrypted.parameters, encryptedParameters)
        XCTAssertEqual(encrypted.header, UInt32(bigEndian: 0x487D4A7D))
        XCTAssertEqual(encrypted.data, encryptedData)
        
        let decrypted = try encrypted.decrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(decrypted, packet)
    }
    
    func testPong() throws {
        
        let encryptedData = Data([0x05, 0x28])
        let packetData = Data([0x18, 0x00])
        let nonce: Nonce = 0x56CFECDD
                
        let packet = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(packet.data, packetData)
        
        let value = PongPacket()
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
    }
    
    func testGuestLoginRequest() throws {
        
        let encryptedData = Data([0xC9, 0x12, 0xA9, 0x11])
        let packetData = Data([0x02, 0x00, 0x00, 0x00])
        let nonce: Nonce = 0x46727AE0
        
        let packet = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(packet.data, packetData)
        
        let value = GuestLoginRequest()
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
    }
    
    func testLoginRequest() throws {
        
        let encryptedData = Data([0x41, 0xB4, 0x8A, 0x04, 0x55, 0x9A, 0xDE, 0x80, 0xD0, 0x58, 0x2C, 0x44, 0x64, 0x27, 0xA1, 0x22, 0x1A, 0x84, 0x14, 0x0F, 0xE5, 0xEE, 0xB7, 0xEC, 0x67, 0xA4, 0x68, 0x60, 0x15, 0x8A, 0x6F, 0xDF, 0xDA, 0x52, 0xFC, 0x04, 0x1F, 0xAF, 0x25, 0x7C, 0x62, 0x82, 0x5C])
        
        let decryptedData = Data([0x01, 0x00, 0x05, 0x00, 0x61, 0x64, 0x6D, 0x69, 0x6E, 0x05, 0x00, 0x61, 0x64, 0x6D, 0x69, 0x6E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xDB, 0x97, 0xC5, 0xBE, 0x00, 0x00, 0x00, 0x00, 0x85, 0xC6, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        
        let nonce: Nonce = 0x46727AB3
        
        let packet = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v62
        )
                
        let value = LoginRequest(
            username: "admin",
            password: "admin",
            value0: 0x00,
            value1: 0x00,
            hardwareID: 3200620507,
            value2: 0x00,
            value3: 50821,
            value4: 0x00,
            value5: 0x02,
            value6: 0x00,
            value7: 0x00
        )
        
        XCTAssertEqual(packet.opcode, LoginRequest.opcode)
        XCTAssertEqual(packet.data, decryptedData)
        XCTAssertEqual(packet, Packet(decryptedData))
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
    }
    
    func testSuccessLoginResponse() throws {
        
        let encryptedData = Data([0xB9, 0x27, 0x95, 0x27, 0x4A, 0xBB, 0xC5, 0xDD, 0xDC, 0xD4, 0x08, 0xBE, 0x55, 0xFD, 0x75, 0xF0, 0xCC, 0x74, 0x50, 0x95, 0xE2, 0xB2, 0x9D, 0xCD, 0x22, 0x53, 0xF6, 0x5E, 0xF7, 0xD6, 0x44, 0xE3, 0x93, 0x2F, 0xD3, 0xA5, 0x16, 0xAD, 0x6C, 0xFE, 0x3F, 0x55, 0xC5, 0x38, 0xBD, 0xED, 0x46, 0x50])
        
        let packetData = Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x6A, 0x01, 0x00, 0x00, 0x00, 0x4E, 0x05, 0x00, 0x61, 0x64, 0x6D, 0x69, 0x6E, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xDC, 0x3D, 0x0B, 0x28, 0x64, 0xC5, 0x01, 0x08, 0x00, 0x00, 0x00])
        
        let nonce: Nonce = 0x523078D8
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = LoginResponse.success(username: "admin")
        XCTAssertEqual(packet.opcode, type(of: value).opcode)
        XCTAssertEncode(value, packet)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.data, encryptedData)
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.parametersSize, 44)
        XCTAssertEqual(encrypted.header, UInt32(bigEndian: 0xB9279527))
    }
    
    func testPinOperationRequest() throws {
        
        let packetData = Data([0x09, 0x00, 0x01, 0x01, 0xFF, 0x6A, 0x01, 0x00, 0x00, 0x00])
        
        let encryptedData = Data([0xAE, 0xD7, 0xB7, 0x85, 0xD7, 0x56, 0x9A, 0xBE, 0x5E, 0x1A])
        
        let nonce: Nonce = 0x53964806
        
        let packet = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        let value = PinOperationRequest(value0: 1, value1: 1)
        XCTAssertEqual(packet, Packet(packetData))
        XCTAssertEqual(packet.opcode, type(of: value).opcode)
        XCTAssertDecode(value, packet)
    }
    
    func testPinOperationResponse() throws {
        
        let encryptedData = Data([0x30, 0x16, 0x33, 0x16, 0xF5, 0xE4, 0x8F])
        
        let packetData = Data([0x06, 0x00, 0x00])
        
        let nonce: Nonce = 0x8AC3F1E9
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = PinOperationResponse.success
        XCTAssertEqual(packet.opcode, type(of: value).opcode)
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.data, encryptedData)
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.parametersSize, 3)
        XCTAssertEqual(encrypted.header, UInt32(bigEndian: 0x30163316))
    }
    
    func testServerListResponse() throws {
        
        let packetData = Data([0x0A, 0x00, 0x00, 0x08, 0x00, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64, 0x20, 0x30, 0x02, 0x00, 0x00, 0x64, 0x00, 0x64, 0x00, 0x00, 0x02, 0x0A, 0x00, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64, 0x20, 0x30, 0x2D, 0x31, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x0A, 0x00, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64, 0x20, 0x30, 0x2D, 0x32, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00])
        
        let encryptedData = Data([0x17, 0xCB, 0x29, 0xCB, 0x00, 0x0D, 0x49, 0x3D, 0x99, 0xDC, 0xBF, 0xB3, 0xFD, 0x73, 0xEE, 0x54, 0xE9, 0x69, 0x4D, 0x9F, 0x49, 0xFA, 0xC9, 0xDC, 0x67, 0x23, 0xA4, 0x8E, 0xE5, 0x02, 0x7F, 0x5D, 0x01, 0xE3, 0x5C, 0xB8, 0xE9, 0xC1, 0x28, 0x7B, 0xE1, 0x36, 0xB6, 0x55, 0x7A, 0x15, 0xBC, 0x97, 0xE4, 0xA0, 0xF1, 0x35, 0x09, 0x5B, 0xAF, 0x84, 0xC7, 0x8D, 0x90, 0x98, 0x41, 0xCF, 0xAC, 0xDF, 0x76, 0x07])
        
        let nonce: Nonce = 0x4001D634
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = ServerListResponse.world(.init(
            id: 0,
            name: " World 0",
            flags: 0x02,
            eventMessage: "",
            rateModifier: 0x64,
            eventXP: 0x00,
            rateModifier2: 0x64,
            dropRate: 0x00,
            value0: 0x00,
            channels: [
                ServerListResponse.Channel(
                    name: " World 0-1",
                    load: 0,
                    value0: 0x01,
                    id: 0
                ),
                ServerListResponse.Channel(
                    name: " World 0-2",
                    load: 0,
                    value0: 0x01,
                    id: 1
                )
            ],
            value1: 0x00
        ))
        
        XCTAssertEncode(value, packet)
        XCTAssertEqual(packet.opcode, ServerListResponse.opcode)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.data, encryptedData)
    }
    
    func testEndServerList() throws {
        
        let packetData = Data([0x0A, 0x00, 0xFF])
        let encryptedData = Data([0xCE, 0x3C, 0xCD, 0x3C, 0x0D, 0x00, 0x6A])
        let nonce: Nonce = 0x9C290FC3
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = ServerListResponse.end
        
        XCTAssertEncode(value, packet)
        XCTAssertEqual(packet.opcode, ServerListResponse.opcode)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.data, encryptedData)
    }
    
    func testCharacterListResponse() throws {
        
        let packetData = Data([0x0B, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x41, 0x64, 0x6D, 0x69, 0x6E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x4E, 0x00, 0x00, 0x4E, 0x75, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFE, 0x00, 0x02, 0xFF, 0x7F, 0xFF, 0x7F, 0xFF, 0x7F, 0xFF, 0x7F, 0x30, 0x75, 0x30, 0x75, 0x6A, 0x67, 0x30, 0x75, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x19, 0x34, 0x00, 0x00, 0x00, 0x00, 0x80, 0x7F, 0x3D, 0x36, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x4E, 0x00, 0x00, 0x01, 0x4E, 0x75, 0x00, 0x00, 0x05, 0x82, 0xDE, 0x0F, 0x00, 0x06, 0xA2, 0x2C, 0x10, 0x00, 0x09, 0xD9, 0xD0, 0x10, 0x00, 0x01, 0x75, 0x4B, 0x0F, 0x00, 0x07, 0x81, 0x5B, 0x10, 0x00, 0x0B, 0x27, 0x9D, 0x16, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00])
        
        let encryptedData = Data([0x60, 0x59, 0xD1, 0x59, 0x7A, 0xBC, 0x1A, 0x42, 0x35, 0x1E, 0x17, 0x21, 0xF0, 0xBC, 0x27, 0x85, 0x75, 0x39, 0x8A, 0x00, 0xDF, 0xFA, 0xC7, 0x78, 0x98, 0xEB, 0xA8, 0xC4, 0xE1, 0x89, 0xB4, 0x3B, 0x70, 0xFD, 0xFC, 0xEC, 0x82, 0xB0, 0xC4, 0x06, 0x6C, 0x2D, 0xDF, 0x8A, 0x16, 0x40, 0x15, 0xBE, 0x76, 0xD2, 0x4B, 0xF8, 0x41, 0xB7, 0x13, 0xE9, 0xE2, 0x55, 0x23, 0x7B, 0xC2, 0x7D, 0x2A, 0xE5, 0xDB, 0xFC, 0x77, 0x1F, 0xA0, 0x0F, 0xB7, 0x2C, 0xCE, 0x3E, 0x86, 0x9B, 0xA4, 0x4A, 0xCC, 0x07, 0x38, 0xF3, 0x41, 0xF3, 0xAD, 0x35, 0xF5, 0x3C, 0xF3, 0x65, 0x36, 0x91, 0x11, 0x59, 0xDE, 0xCE, 0xC4, 0x5E, 0xAD, 0x5A, 0x58, 0x3A, 0x9B, 0xA6, 0x2A, 0x06, 0x2A, 0xF9, 0xC8, 0x70, 0x25, 0xA6, 0x66, 0xD4, 0x58, 0x89, 0x4E, 0xE6, 0x52, 0xBE, 0x72, 0x40, 0xCA, 0xC7, 0x74, 0x0D, 0x80, 0x36, 0x5D, 0x56, 0x2E, 0xE6, 0x86, 0xC0, 0x50, 0xF1, 0x9F, 0x70, 0x02, 0x03, 0xCF, 0xA5, 0xC7, 0xA3, 0xE0, 0xA6, 0x2B, 0x67, 0xB5, 0xAA, 0x8A, 0x4C, 0x5F, 0x00, 0xAD, 0xB3, 0xB3, 0x23, 0x5B, 0xDD, 0x29, 0x0B, 0x09, 0xCE, 0x71, 0x33, 0x02, 0x2D, 0x19, 0x5D, 0xA3, 0x8F, 0xB3, 0x65, 0x67, 0xB7, 0x7E, 0xB6, 0xF7, 0xE9, 0xBD])
        
        let nonce: Nonce = 0x0C5EA1A6
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = CharacterListResponse(
            characters: [
                MapleStory62.CharacterListResponse.Character(
                    stats: MapleStory62.CharacterListResponse.CharacterStats(
                        id: 1,
                        name: "Admin",
                        gender: .male,
                        skinColor: .normal,
                        face: 20000,
                        hair: 30030,
                        value0: 0,
                        value1: 0,
                        value2: 0,
                        level: 254,
                        job: .buccaneer,
                        str: 32767,
                        dex: 32767,
                        int: 32767,
                        luk: 32767,
                        hp: 30000,
                        maxHp: 30000,
                        mp: 26474,
                        maxMp: 30000,
                        ap: 0,
                        sp: 0,
                        exp: 0,
                        fame: 13337,
                        isMarried: 0,
                        currentMap: 910000000,
                        spawnPoint: 1,
                        value3: 0
                    ),
                    appearance: MapleStory62.CharacterListResponse.CharacterAppeareance(
                        gender: .male,
                        skinColor: .normal,
                        face: 20000,
                        mega: true,
                        hair: 30030,
                        equipment: [5: 0x82DE0F00, 6: 0xA22C1000, 9: 0xD9D01000, 1: 0x754B0F00, 7: 0x815B1000, 11: 0x279D1600],
                        maskedEquipment: [:],
                        cashWeapon: 0,
                        value0: 0,
                        value1: 0
                    ),
                    rank: MapleStory62.CharacterListResponse.Rank(
                        worldRank: 1,
                        rankMove: 0,
                        jobRank: 1,
                        jobRankMove: 0
                    )
                )
            ],
            maxCharacters: 6
        )
        
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(packet.opcode, CharacterListResponse.opcode)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.data, encryptedData)
    }
    
    func testAllCharactersInfo() throws {
        
        let packetData = Data([0x08, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x41, 0x64, 0x6D, 0x69, 0x6E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x4E, 0x00, 0x00, 0x4E, 0x75, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFE, 0x00, 0x02, 0xFF, 0x7F, 0xFF, 0x7F, 0xFF, 0x7F, 0xFF, 0x7F, 0x30, 0x75, 0x30, 0x75, 0x6A, 0x67, 0x30, 0x75, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x19, 0x34, 0x00, 0x00, 0x00, 0x00, 0x80, 0x7F, 0x3D, 0x36, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x4E, 0x00, 0x00, 0x01, 0x4E, 0x75, 0x00, 0x00, 0x05, 0x82, 0xDE, 0x0F, 0x00, 0x06, 0xA2, 0x2C, 0x10, 0x00, 0x09, 0xD9, 0xD0, 0x10, 0x00, 0x01, 0x75, 0x4B, 0x0F, 0x00, 0x07, 0x81, 0x5B, 0x10, 0x00, 0x0B, 0x27, 0x9D, 0x16, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        
        let encryptedData = Data([0x2A, 0x47, 0x84, 0x47, 0xC5, 0x93, 0xF9, 0xDB, 0x27, 0x75, 0x29, 0x30, 0xDB, 0xA1, 0x78, 0x6C, 0x98, 0x39, 0x4B, 0x93, 0xC0, 0xE9, 0x28, 0x60, 0xCF, 0x53, 0xC2, 0x99, 0x5F, 0x20, 0xD9, 0x11, 0x85, 0x4A, 0xD4, 0x8B, 0x81, 0xA8, 0x6E, 0x67, 0xB3, 0x33, 0x96, 0xE0, 0x5F, 0x3F, 0x9A, 0x66, 0x41, 0xCB, 0x86, 0x4A, 0x4B, 0x33, 0xF4, 0x2E, 0x2E, 0xE7, 0x99, 0xF2, 0xA7, 0xC9, 0x31, 0xE1, 0xFB, 0x45, 0x86, 0x34, 0x2E, 0x56, 0x69, 0x45, 0x4E, 0x31, 0x4D, 0x64, 0xDA, 0x00, 0x4A, 0x53, 0x86, 0x26, 0xD9, 0x31, 0x50, 0xAB, 0x0F, 0xDA, 0xFA, 0xB9, 0x5A, 0x5F, 0x35, 0xAE, 0x1A, 0x04, 0x42, 0x65, 0x93, 0x24, 0x00, 0xD5, 0xDF, 0xDF, 0x22, 0x43, 0x8A, 0x3A, 0xF8, 0x69, 0x7B, 0xE1, 0xD9, 0x69, 0x2B, 0x61, 0x0A, 0xDE, 0x34, 0x66, 0x01, 0x82, 0x86, 0x0F, 0xEE, 0x0A, 0xDC, 0x1E, 0x27, 0xC0, 0x23, 0xE0, 0x18, 0xA4, 0x5E, 0x05, 0xD9, 0xCA, 0x2F, 0x8A, 0x73, 0x46, 0x9A, 0xF7, 0x53, 0xA9, 0x89, 0x70, 0x5A, 0x02, 0x5E, 0x67, 0xE7, 0xE6, 0x89, 0x15, 0x78, 0x7A, 0x5F, 0x4F, 0x31, 0x05, 0x36, 0x82, 0x18, 0xE3, 0x5C, 0xAE, 0xF7, 0x7D, 0x58, 0xC5, 0x91, 0x23, 0x43, 0xDE, 0x90, 0xF7])
        
        let nonce: Nonce = 0x79B9EBB8
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = AllCharactersResponse.characters(world: 0, characters: [
            MapleStory62.CharacterListResponse.Character(
                stats: MapleStory62.CharacterListResponse.CharacterStats(
                    id: 1,
                    name: "Admin",
                    gender: .male,
                    skinColor: .normal,
                    face: 20000,
                    hair: 30030,
                    value0: 0,
                    value1: 0,
                    value2: 0,
                    level: 254,
                    job: .buccaneer,
                    str: 32767,
                    dex: 32767,
                    int: 32767,
                    luk: 32767,
                    hp: 30000,
                    maxHp: 30000,
                    mp: 26474,
                    maxMp: 30000,
                    ap: 0,
                    sp: 0,
                    exp: 0,
                    fame: 13337,
                    isMarried: 0,
                    currentMap: 910000000,
                    spawnPoint: 1,
                    value3: 0
                ),
                appearance: MapleStory62.CharacterListResponse.CharacterAppeareance(
                    gender: .male,
                    skinColor: .normal,
                    face: 20000,
                    mega: true,
                    hair: 30030,
                    equipment: [5: 0x82DE0F00, 6: 0xA22C1000, 9: 0xD9D01000, 1: 0x754B0F00, 7: 0x815B1000, 11: 0x279D1600],
                    maskedEquipment: [:],
                    cashWeapon: 0,
                    value0: 0,
                    value1: 0
                ),
                rank: MapleStory62.CharacterListResponse.Rank(
                    worldRank: 1,
                    rankMove: 0,
                    jobRank: 1,
                    jobRankMove: 0
                )
            )
        ])
        
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(packet.opcode, type(of: value).opcode)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.data, encryptedData)
    }
    
    func testAllCharactersCount() throws {
        
        let packetData = Data([0x08, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00])
        let encryptedData = Data([0x05, 0xF2, 0x0E, 0xF2, 0xE2, 0x29, 0x45, 0x34, 0xB6, 0x76, 0xC7, 0xD2, 0x18, 0xE4, 0xCF])
        let nonce: Nonce = 0x9786C40D
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = AllCharactersResponse.count(characters: 1, value0: 3)
        
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(packet.opcode, type(of: value).opcode)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.data, encryptedData)
    }
    
    func testUnknownRequest() throws {
        
        /*
         MaplePacketDecoder encrypted packet 11 C2 86 FB 91 E1 39 D9 05 01 A3
         Recieve IV 25 C1 21 63
         MapleAESOFB.crypt() input: 11 C2 86 FB 91 E1 39 D9 05 01 A3
         MapleAESOFB.crypt() iv: 25 C1 21 63
         MapleAESOFB.crypt() output: D2 D7 4E 76 8E C5 E9 98 72 91 15
         MaplePacketDecoder AES decrypted packet D2 D7 4E 76 8E C5 E9 98 72 91 15
         MaplePacketDecoder custom decrypted packet 1A 00 01 7D 5B D5 EE 00 00 00 00
         Incoming packet 0x001A
         */
        
        let encryptedData = Data([0x11, 0xC2, 0x86, 0xFB, 0x91, 0xE1, 0x39, 0xD9, 0x05, 0x01, 0xA3])
        let packetData = Data([0x1A, 0x00, 0x01, 0x7D, 0x5B, 0xD5, 0xEE, 0x00, 0x00, 0x00, 0x00])
        let nonce: Nonce = 0x25C12163
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let decrypted = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        //XCTAssertDecode(value, packet)
        XCTAssertEqual(decrypted, packet)
        XCTAssertEqual(packet.opcode, 0x001A)
    }
    
    func testAllCharactersSelectRequest() throws {
        
        let packetData = Data([0x0E, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00, 0x30, 0x30, 0x2D, 0x31, 0x43, 0x2D, 0x34, 0x32, 0x2D, 0x34, 0x38, 0x2D, 0x30, 0x37, 0x2D, 0x32, 0x39, 0x15, 0x00, 0x42, 0x43, 0x39, 0x41, 0x37, 0x38, 0x35, 0x36, 0x33, 0x34, 0x31, 0x32, 0x5F, 0x44, 0x42, 0x39, 0x37, 0x43, 0x35, 0x42, 0x45])
        let encryptedData = Data([0xE9, 0x46, 0xD1, 0xA0, 0x6F, 0xE7, 0xE5, 0x54, 0xAF, 0x6C, 0x9C, 0x45, 0x55, 0x8B, 0xDB, 0x3F, 0x7B, 0xCD, 0x1D, 0xEB, 0x4C, 0xB1, 0xB4, 0x82, 0x19, 0xE4, 0x1A, 0x36, 0x8F, 0x08, 0xE6, 0x24, 0x9F, 0xCF, 0x34, 0xFC, 0xF6, 0x1B, 0xB6, 0x43, 0xA8, 0x0A, 0x6F, 0x27, 0x4C, 0x77, 0x9E, 0x5E, 0x82, 0x42, 0x40, 0x8F])
        let nonce: Nonce = 0x2EB61FE4
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let decrypted = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        let value = AllCharactersSelectRequest(
            character: 1,
            macAddresses: ""
        )
        
        XCTAssertDecode(value, packet)
        XCTAssertEqual(decrypted, packet)
        XCTAssertEqual(packet.opcode, type(of: value).opcode)
    }
    
    func testServerIPResponse() throws {
        
        let packetData = Data([0x0C, 0x00, 0x00, 0x00, 0xAC, 0x11, 0x00, 0x03, 0x97, 0x1D, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        let encryptedData = Data([0x40, 0x87, 0x53, 0x87, 0x51, 0x66, 0xE7, 0xBF, 0x46, 0xCA, 0xEB, 0xB5, 0xCA, 0xC2, 0xD2, 0x4D, 0xCD, 0xA0, 0x25, 0x60, 0xB2, 0xD9, 0x3C])
        let nonce: Nonce = 0x96278178
        
        let value = ServerIPResponse(
            value0: 0,
            address: MapleStoryAddress(rawValue: "172.17.0.3:7575")!,
            character: 1,
            value1: 0,
            value2: 0
        )
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(packet.opcode, type(of: value).opcode)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.data, encryptedData)
    }
    
    func testCharacterSelectRequest() throws {
        
        let encryptedData = Data([0xAD, 0xEC, 0x71, 0x21, 0x63, 0xEE, 0xD9, 0xB0, 0x70, 0xDB, 0x38, 0xC3, 0xBC, 0x33, 0x7A, 0xA8, 0x1E, 0x47, 0xD8, 0x3B, 0x1F, 0xBD, 0x5E, 0x56, 0xC5, 0x71, 0xDD, 0xEB, 0x02, 0x5C, 0xE8, 0x2C, 0x68, 0x57, 0xBB, 0xF3, 0xD9, 0xF5, 0x5D, 0xE0, 0x1F, 0xB0, 0x76, 0x5F, 0xB3, 0x5F, 0x41, 0x67])
        let packetData = Data([0x13, 0x00, 0x01, 0x00, 0x00, 0x00, 0x11, 0x00, 0x30, 0x30, 0x2D, 0x31, 0x43, 0x2D, 0x34, 0x32, 0x2D, 0x34, 0x38, 0x2D, 0x30, 0x37, 0x2D, 0x32, 0x39, 0x15, 0x00, 0x42, 0x43, 0x39, 0x41, 0x37, 0x38, 0x35, 0x36, 0x33, 0x34, 0x31, 0x32, 0x5F, 0x44, 0x42, 0x39, 0x37, 0x43, 0x35, 0x42, 0x45])
        let nonce: Nonce = 0xD1D3B2FA
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let decrypted = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        let value = CharacterSelectRequest(
            character: 1,
            macAddresses: "00-1C-42-48-07-29"
        )
        
        XCTAssertDecode(value, packet)
        XCTAssertEqual(decrypted, packet)
        XCTAssertEqual(packet.opcode, 0x13)
    }
    
    func testCheckNameRequest() throws {
        
        let encryptedData = Data([0x2F, 0x56, 0x73, 0xD8, 0xCA, 0xBE, 0x52, 0x36])
        let packetData = Data([0x15, 0x00, 0x04, 0x00, 0x63, 0x64, 0x61, 0x31])
        let nonce: Nonce = 0xA7599238
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let decrypted = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        let value = CheckNameRequest(name: "cda1")
        
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(decrypted, packet)
        XCTAssertEqual(packet.opcode, 0x0015)
    }
    
    func testCheckNameResponse() throws {
        
        let packetData = Data([0x0D, 0x00, 0x04, 0x00, 0x63, 0x64, 0x61, 0x31, 0x00])
        let encryptedData = Data([0x27, 0x79, 0x2E, 0x79, 0xE4, 0xF8, 0xC7, 0xC2, 0x9C, 0x9B, 0xA7, 0xFE, 0xDF])
        let nonce: Nonce = 0x2122E686
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = CheckNameResponse(name: "cda1", isUsed: false)
        
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(packet.opcode, type(of: value).opcode)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.data, encryptedData)
    }
    
    func testCreateCharacterRequest() throws {
        
        let packetData = Data([0x16, 0x00, 0x04, 0x00, 0x63, 0x64, 0x61, 0x31, 0x20, 0x4E, 0x00, 0x00, 0x4E, 0x75, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x82, 0xDE, 0x0F, 0x00, 0xA2, 0x2C, 0x10, 0x00, 0x81, 0x5B, 0x10, 0x00, 0xF0, 0xDD, 0x13, 0x00, 0x00, 0x06, 0x09, 0x05, 0x05])
        
        let encryptedData = Data([0x1C, 0x44, 0x4B, 0xA6, 0xA4, 0x23, 0x2F, 0x8B, 0x12, 0x06, 0x1C, 0xD9, 0x34, 0x71, 0xCF, 0x13, 0x3F, 0x24, 0xAF, 0x21, 0xE7, 0x5B, 0x24, 0x74, 0xC0, 0xB2, 0xCB, 0x1F, 0x7C, 0xC1, 0xDF, 0x81, 0xBB, 0x7C, 0x18, 0x85, 0x33, 0x96, 0x30, 0xD9, 0xEE, 0x68, 0xF5, 0xF0, 0x40])
        
        let nonce: Nonce = 0x0B96E186
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let decrypted = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        let value = CreateCharacterRequest(
            name: "cda1",
            face: 20000,
            hair: 30030,
            hairColor: 0,
            skinColor: 0,
            top: 1040002,
            bottom: 1060002,
            shoes: 1072001,
            weapon: 1302000,
            gender: .male,
            str: 6,
            dex: 9,
            int: 5,
            luk: 5
        )
        
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(decrypted, packet)
        XCTAssertEqual(packet.opcode, 0x16)
    }
    
    func testCreateCharacterResponse() throws {
        
        let packetData = Data([0x0E, 0x00, 0x00, 0x0F, 0x00, 0x00, 0x00, 0x63, 0x64, 0x61, 0x31, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x4E, 0x00, 0x00, 0x4E, 0x75, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x06, 0x00, 0x09, 0x00, 0x05, 0x00, 0x05, 0x00, 0x32, 0x00, 0x32, 0x00, 0x05, 0x00, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x4E, 0x00, 0x00, 0x01, 0x4E, 0x75, 0x00, 0x00, 0x05, 0x82, 0xDE, 0x0F, 0x00, 0x06, 0xA2, 0x2C, 0x10, 0x00, 0x07, 0x81, 0x5B, 0x10, 0x00, 0x0B, 0xF0, 0xDD, 0x13, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        
        let encryptedData = Data([0xC9, 0x4D, 0x6B, 0x4D, 0x5A, 0x20, 0x2A, 0x47, 0x5E, 0xF6, 0x0A, 0xAC, 0x8F, 0x20, 0x01, 0x20, 0x87, 0xBB, 0xCC, 0xCD, 0xDA, 0x2C, 0x40, 0xE1, 0xAB, 0xF6, 0x6A, 0x94, 0xE4, 0x51, 0x09, 0xB5, 0x6B, 0x35, 0x9E, 0xFC, 0xFD, 0x12, 0x03, 0x75, 0x30, 0x54, 0x56, 0x0E, 0xB1, 0xE3, 0x68, 0xF8, 0xD4, 0xAD, 0xA0, 0xF6, 0xBA, 0x5D, 0x43, 0x64, 0x18, 0xB0, 0x0C, 0x9B, 0xB9, 0x27, 0x1D, 0xE7, 0xD1, 0x1A, 0x02, 0xB7, 0x1B, 0x9D, 0xAD, 0x9A, 0x16, 0xA7, 0xE2, 0x86, 0x03, 0x51, 0x3E, 0xCC, 0x89, 0x90, 0x73, 0xA1, 0x12, 0x98, 0x29, 0x16, 0xB0, 0x29, 0xEE, 0x3D, 0x90, 0xB0, 0x68, 0x4F, 0x76, 0x87, 0x50, 0x45, 0x1B, 0x4A, 0xA0, 0x34, 0xEF, 0xB1, 0x60, 0x93, 0x2B, 0xB5, 0x61, 0xC4, 0xBE, 0x7E, 0xC1, 0x3E, 0x7A, 0x2A, 0x8F, 0x83, 0x66, 0xA8, 0x8F, 0x01, 0x33, 0x69, 0x7C, 0x55, 0xF5, 0x81, 0xBD, 0xF9, 0x81, 0xCF, 0xEF, 0x7C, 0x95, 0xF5, 0x86, 0xA5, 0x2C, 0xEB, 0xCF, 0xDC, 0xF2, 0x3F, 0xDB, 0x9F, 0xCA, 0x31, 0xA4, 0x3C, 0x97, 0xF5, 0x7E, 0x83, 0x80, 0x1A, 0xE0, 0xE8, 0xF3, 0x0B, 0x06, 0x6F, 0x20, 0xB4])
        
        let nonce: Nonce = 0xCFA908B2
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = CreateCharacterResponse(
            error: false,
            character: MapleStory62.CharacterListResponse.Character(
                stats: MapleStory62.CharacterListResponse.CharacterStats(
                    id: 15,
                    name: "cda1",
                    gender: .male,
                    skinColor: .normal,
                    face: 20000,
                    hair: .buzz(.black),
                    value0: 0,
                    value1: 0,
                    value2: 0,
                    level: 1,
                    job: .beginner,
                    str: 6,
                    dex: 9,
                    int: 5,
                    luk: 5,
                    hp: 50,
                    maxHp: 50,
                    mp: 5,
                    maxMp: 5,
                    ap: 0,
                    sp: 0,
                    exp: 0,
                    fame: 0,
                    isMarried: 0,
                    currentMap: 0,
                    spawnPoint: 0,
                    value3: 0
                ),
                appearance: MapleStory62.CharacterListResponse.CharacterAppeareance(
                    gender: .male,
                    skinColor: .normal,
                    face: 20000,
                    mega: true,
                    hair: 30030,
                    equipment: [5: 0x82DE0F00, 6: 0xA22C1000, 7: 0x815B1000, 11: 0xF0DD1300],
                    maskedEquipment: [:],
                    cashWeapon: 0,
                    value0: 0,
                    value1: 0
                ),
                rank: MapleStory62.CharacterListResponse.Rank(
                    worldRank: 0,
                    rankMove: 0,
                    jobRank: 0,
                    jobRankMove: 0
                )
            )
        )
        
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(packet.opcode, 0x0E)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.data, encryptedData)
    }
    
    func testDeleteCharacterRequest() throws {
        
        let encryptedData = Data([0xF5, 0x76, 0xB4, 0x51, 0xE5, 0xA1, 0x98, 0xCE, 0x62, 0x9A])
        let packetData = Data([0x17, 0x00, 0xAC, 0xBD, 0x9A, 0x00, 0x10, 0x00, 0x00, 0x00])
        let nonce: Nonce = 0xB43E8634
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let decrypted = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        let value = DeleteCharacterRequest(
            date: 10141100,
            character: 16
        )
        
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(decrypted, packet)
        XCTAssertEqual(packet.opcode, 0x0017)
    }
    
    func testDeleteCharacterResponse() throws {
        
        let packetData = Data([0x0F, 0x00, 0x10, 0x00, 0x00, 0x00, 0x12])
        let encryptedData = Data([0x50, 0x90, 0x57, 0x90, 0x0B, 0x83, 0xF6, 0x3A, 0x41, 0x9A, 0xF7])
        let nonce: Nonce = 0x6709916F
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = DeleteCharacterResponse(
            character: 16,
            state: 18
        )
        
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
        XCTAssertEqual(packet.opcode, 0x0F)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.data, encryptedData)
    }
}
