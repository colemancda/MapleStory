//
//  LoginTests.swift
//
//
//  Created by Alsey Coleman Miller on 4/29/24.
//

import Foundation
import XCTest
@testable import MapleStory
@testable import MapleStory83

final class LoginTests: XCTestCase {
    
    func testHello() throws {
        
        let packet: Packet<ServerOpcode> = [0x0E, 0x00, 0x53, 0x00, 0x01, 0x00, 0x31, 0x68, 0x91, 0x09, 0x81, 0x42, 0x0F, 0x90, 0x9B, 0x08]
        
        let value = HelloPacket(
            recieveNonce: 0x68910981,
            sendNonce: 0x420F909B,
            region: .global
        )
        
        XCTAssertEqual(value.version, .v83)
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
    }
    
    func testLoginRequest() throws {
        
        let encryptedData = Data([0x3E, 0xB2, 0xFA, 0xB6, 0xA2, 0x9F, 0x36, 0xF1, 0x90, 0x33, 0x86, 0x72, 0xD7, 0x72, 0x7C, 0xDC, 0x0F, 0x56, 0xA7, 0x7B, 0x6C, 0xAB, 0xC2, 0x4C, 0x3A, 0x5A, 0x7F, 0x62, 0xA8, 0x3C, 0xE7, 0x94, 0xCB, 0xFD, 0x1D, 0xAF, 0xC7, 0x19, 0xC8, 0x07, 0xA9, 0xA3, 0x0E])
        
        let decryptedData = Data([0x01, 0x00, 0x05, 0x00, 0x61, 0x64, 0x6D, 0x69, 0x6E, 0x05, 0x00, 0x61, 0x64, 0x6D, 0x69, 0x6E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x83, 0x6E, 0x5B, 0x02, 0x00, 0x00, 0x00, 0x00, 0x8F, 0xA7, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        
        let nonce: Nonce = 0x8D330976
        
        let packet = try Packet<ClientOpcode>.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v83
        )
                
        let value = LoginRequest(
            username: "admin",
            password: "admin",
            value0: 0,
            value1: 0,
            hardwareID: 0x025B6E83
        )
        
        XCTAssertEqual(packet.opcode, LoginRequest.opcode)
        XCTAssertEqual(packet.data, decryptedData)
        XCTAssertEqual(packet, Packet(decryptedData))
        XCTAssertDecode(value, packet)
    }
    
    func testLoginFailure() throws {
        
        let encryptedData = Data([0xF7, 0x78, 0xFF, 0x78, 0x1E, 0x8F, 0xDA, 0x80, 0x10, 0x78, 0xAE, 0xFA])
        let packet: Packet<ServerOpcode> = [0x00, 0x00, 0x17, 0x00, 0x00, 0x00, 0x00, 0x00]
        let nonce: Nonce = 0x8C7E5B87
        
        let value = LoginResponse.failure(.licenseAgreement)
        XCTAssertEqual(packet.opcode, type(of: value).opcode)
        XCTAssertEncode(value, packet)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v83
        )
        
        XCTAssertEqual(encrypted.data, encryptedData)
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.parametersSize, 8)
    }

    func testSuccessLoginResponse() throws {
        
        let packet: Packet<ServerOpcode> = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x05, 0x00, 0x61, 0x64, 0x6D, 0x69, 0x6E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x02]
        
        let value = MapleStory83.LoginResponse.success(
            MapleStory83.LoginResponse.Success(
                account: 2,
                gender: .none,
                isAdmin: false,
                adminType: 0,
                countryCode: 0,
                username: "admin",
                isQuietBan: false,
                quietBanTimeStamp: 0,
                creationTimeStamp: 0,
                worldSelection: .skipPrompt,
                skipPin: true,
                picMode: .disabled
            )
        )
        
        XCTAssertEqual(packet.opcode, type(of: value).opcode)
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
    }
    
    func testSetGender() throws {
        
        let packet: Packet<ClientOpcode> = [0x08, 0x00, 0x01, 0x00]
        let value = SetGenderRequest(gender: .male)
        XCTAssertEqual(packet.opcode, type(of: value).opcode)
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
    }
    
    func testPong() throws {
        
        let encryptedData = Data([0x46, 0xD3])
        let packetData = Data([0x18, 0x00])
        let nonce: Nonce = 0x0A627F70
        
        let packet = try Packet<ClientOpcode>.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v83
        )
        
        let value = PongPacket()
        XCTAssertEqual(packet, Packet(packetData))
        XCTAssertEqual(packet.opcode, type(of: value).opcode)
        XCTAssertDecode(value, packet)
        XCTAssertEncode(value, packet)
    }
    
    func testServerListResponse() throws {
        
        let packet: Packet<ServerOpcode> = [0x0A, 0x00, 0x00, 0x06, 0x00, 0x53, 0x63, 0x61, 0x6E, 0x69, 0x61, 0x00, 0x07, 0x00, 0x53, 0x63, 0x61, 0x6E, 0x69, 0x61, 0x21, 0x64, 0x00, 0x64, 0x00, 0x00, 0x03, 0x08, 0x00, 0x53, 0x63, 0x61, 0x6E, 0x69, 0x61, 0x2D, 0x31, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x08, 0x00, 0x53, 0x63, 0x61, 0x6E, 0x69, 0x61, 0x2D, 0x32, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x08, 0x00, 0x53, 0x63, 0x61, 0x6E, 0x69, 0x61, 0x2D, 0x33, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x00, 0x00, 0x00]
        
        let value = ServerListResponse.world(
            0, MapleStory83.ServerListResponse.World(
                name: "Scania",
                flags: 0,
                eventMessage: "Scania!",
                rateModifier: 100,
                eventXP: 0,
                rateModifier2: 100,
                dropRate: 0,
                value0: 0,
                channels: [
                    MapleStory83.ServerListResponse.Channel(
                        name: "Scania-1",
                        load: 0,
                        value0: 1,
                        id: 0
                    ),
                    MapleStory83.ServerListResponse.Channel(
                        name: "Scania-2",
                        load: 0,
                        value0: 1,
                        id: 1
                    ),
                    MapleStory83.ServerListResponse.Channel(
                        name: "Scania-3",
                        load: 0,
                        value0: 1,
                        id: 2
                    )
                ],
                value1: 0x00
            )
        )
        
        XCTAssertDecode(value, packet)
        XCTAssertEncode(value, packet)
        
        XCTAssertDecode(ServerListResponse.end, [0x0A, 0x00, 0xFF])
        XCTAssertEncode(ServerListResponse.end, [0x0A, 0x00, 0xFF])
    }
    
    func testCharacterListResquest() {
        
        let packet: Packet<ClientOpcode> = [0x05, 0x00, 0x02, 0x00, 0x00, 0x0A, 0xD3, 0x37, 0x03]
                
        let value = CharacterListRequest(
            value0: 0x02,
            world: 0,
            channel: 0,
            value1: 0x0337D30A
        )
        
        XCTAssertDecode(value, packet)
        XCTAssertEncode(value, packet)
    }
    
    func testCharacterListResponse() {
        
        let packet: Packet<ServerOpcode> = [0x0B, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x43, 0x6F, 0x6C, 0x65, 0x6D, 0x61, 0x6E, 0x43, 0x44, 0x41, 0x00, 0x00, 0x00, 0x00, 0x03, 0x21, 0x4E, 0x00, 0x00, 0x47, 0x75, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x0C, 0x00, 0x05, 0x00, 0x04, 0x00, 0x04, 0x00, 0x32, 0x00, 0x32, 0x00, 0x05, 0x00, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x27, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x21, 0x4E, 0x00, 0x00, 0x01, 0x47, 0x75, 0x00, 0x00, 0x05, 0x82, 0xDE, 0x0F, 0x00, 0x06, 0xA2, 0x2C, 0x10, 0x00, 0x07, 0x85, 0x5B, 0x10, 0x00, 0x0B, 0x04, 0x05, 0x14, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x03, 0x00, 0x00, 0x00]
                
        let value = CharacterListResponse(
            characters: [
                MapleStory83.CharacterListResponse.Character(
                    stats: MapleStory83.CharacterListResponse.CharacterStats(
                        id: 1,
                        name: "ColemanCDA",
                        gender: .male,
                        skinColor: .pale,
                        face: 20001,
                        hair: 30023,
                        value0: 0,
                        value1: 0,
                        value2: 0,
                        level: 1,
                        job: .beginner,
                        str: 12,
                        dex: 5,
                        int: 4,
                        luk: 4,
                        hp: 50,
                        maxHp: 50,
                        mp: 5,
                        maxMp: 5,
                        ap: 0,
                        sp: 0,
                        exp: 0,
                        fame: 0,
                        isMarried: 0,
                        currentMap: .mushroomTown,
                        spawnPoint: 0, 
                        value3: 0
                    ),
                    appearance: MapleStory83.CharacterListResponse.CharacterAppeareance(
                        gender: .male,
                        skinColor: .pale,
                        face: 20001,
                        mega: true,
                        hair: 30023,
                        equipment: [5: 2195590912, 6: 2720796672, 7: 2237337600, 11: 67441664],
                        maskedEquipment: [:],
                        cashWeapon: 0,
                        value0: 0,
                        value1: 0
                    ), 
                    value0: 0x00,
                    rank: .enabled(
                        worldRank: 1,
                        rankMove: 0,
                        jobRank: 1,
                        jobRankMove: 0
                    )
                )
            ],
            picStatus: .disabled,
            maxCharacters: 3
        )
        
        XCTAssertDecode(value, packet)
        XCTAssertEncode(value, packet)
    }
    
    func testCreateCharacterRequest() throws {
        
        let packet: Packet<ClientOpcode> = [0x16, 0x00, 0x0C, 0x00, 0x63, 0x6F, 0x6C, 0x65, 0x6D, 0x61, 0x6E, 0x6E, 0x69, 0x67, 0x68, 0x74, 0x00, 0x00, 0x00, 0x00, 0x20, 0x4E, 0x00, 0x00, 0x44, 0x75, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x82, 0xDE, 0x0F, 0x00, 0xA2, 0x2C, 0x10, 0x00, 0x85, 0x5B, 0x10, 0x00, 0xF0, 0xDD, 0x13, 0x00, 0x00]
        
        let value = CreateCharacterRequest(
            name: "colemannight",
            job: .knights,
            face: 20000,
            hair: 30020,
            hairColor: 3,
            skinColor: 0,
            top: 1040002,
            bottom: 1060002,
            shoes: 1072005,
            weapon: 1302000,
            gender: .male
        )
        
        XCTAssertDecode(value, packet)
        XCTAssertEncode(value, packet)
    }
    
    func testCreateCharacterResponse() throws {
        
        let packet: Packet<ServerOpcode> = [0x0E, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x63, 0x6F, 0x6C, 0x65, 0x6D, 0x61, 0x6E, 0x6E, 0x69, 0x67, 0x68, 0x74, 0x00, 0x00, 0x00, 0x20, 0x4E, 0x00, 0x00, 0x47, 0x75, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0xE8, 0x03, 0x0C, 0x00, 0x05, 0x00, 0x04, 0x00, 0x04, 0x00, 0x32, 0x00, 0x32, 0x00, 0x05, 0x00, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xB0, 0x19, 0xC0, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x4E, 0x00, 0x00, 0x01, 0x47, 0x75, 0x00, 0x00, 0x05, 0x82, 0xDE, 0x0F, 0x00, 0x06, 0xA2, 0x2C, 0x10, 0x00, 0x07, 0x85, 0x5B, 0x10, 0x00, 0x0B, 0xF0, 0xDD, 0x13, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        
        let value = CreateCharacterResponse(
            error: false,
            character: MapleStory83.CharacterListResponse.Character(
                stats: MapleStory83.CharacterListResponse.CharacterStats(
                    id: 3,
                    name: "colemannight",
                    gender: .male,
                    skinColor: .normal,
                    face: 20000,
                    hair: 30023,
                    value0: 0,
                    value1: 0,
                    value2: 0,
                    level: 1,
                    job: .noblesse,
                    str: 12,
                    dex: 5,
                    int: 4,
                    luk: 4,
                    hp: 50,
                    maxHp: 50,
                    mp: 5,
                    maxMp: 5,
                    ap: 0,
                    sp: 0,
                    exp: 0,
                    fame: 0,
                    isMarried: 0,
                    currentMap: .startingMapNoblesse,
                    spawnPoint: 0,
                    value3: 0
                ),
                appearance: MapleStory83.CharacterListResponse.CharacterAppeareance(
                    gender: .male,
                    skinColor: .normal,
                    face: 20000,
                    mega: true,
                    hair: 30023,
                    equipment: [5: 2195590912, 6: 2720796672, 7: 2237337600, 11: 4041020160],
                    maskedEquipment: [:],
                    cashWeapon: 0,
                    value0: 0,
                    value1: 0
                ),
                value0: 0,
                rank: .enabled(
                    worldRank: 0,
                    rankMove: 0,
                    jobRank: 0,
                    jobRankMove: 0
                )
            )
        )
        
        XCTAssertDecode(value, packet)
        XCTAssertEncode(value, packet)
    }
    
    func testListAllCharactersResponse() {
        
        let packet: Packet<ServerOpcode> = [0x08, 0x00, 0x00, 0x00, 0x03, 0x01, 0x00, 0x00, 0x00, 0x43, 0x6F, 0x6C, 0x65, 0x6D, 0x61, 0x6E, 0x43, 0x44, 0x41, 0x00, 0x00, 0x00, 0x00, 0x03, 0x21, 0x4E, 0x00, 0x00, 0x47, 0x75, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x0C, 0x00, 0x05, 0x00, 0x04, 0x00, 0x04, 0x00, 0x32, 0x00, 0x32, 0x00, 0x05, 0x00, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x27, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x21, 0x4E, 0x00, 0x00, 0x01, 0x47, 0x75, 0x00, 0x00, 0x05, 0x82, 0xDE, 0x0F, 0x00, 0x06, 0xA2, 0x2C, 0x10, 0x00, 0x07, 0x85, 0x5B, 0x10, 0x00, 0x0B, 0x04, 0x05, 0x14, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x63, 0x6F, 0x6C, 0x65, 0x6D, 0x61, 0x6E, 0x32, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x4E, 0x00, 0x00, 0x44, 0x75, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x0C, 0x00, 0x05, 0x00, 0x04, 0x00, 0x04, 0x00, 0x32, 0x00, 0x32, 0x00, 0x05, 0x00, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x27, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x4E, 0x00, 0x00, 0x01, 0x44, 0x75, 0x00, 0x00, 0x05, 0x86, 0xDE, 0x0F, 0x00, 0x06, 0xA2, 0x2C, 0x10, 0x00, 0x07, 0x85, 0x5B, 0x10, 0x00, 0x0B, 0xF0, 0xDD, 0x13, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x63, 0x6F, 0x6C, 0x65, 0x6D, 0x61, 0x6E, 0x6E, 0x69, 0x67, 0x68, 0x74, 0x00, 0x00, 0x00, 0x20, 0x4E, 0x00, 0x00, 0x47, 0x75, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0xE8, 0x03, 0x0C, 0x00, 0x05, 0x00, 0x04, 0x00, 0x04, 0x00, 0x32, 0x00, 0x32, 0x00, 0x05, 0x00, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xB0, 0x19, 0xC0, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x4E, 0x00, 0x00, 0x01, 0x47, 0x75, 0x00, 0x00, 0x05, 0x82, 0xDE, 0x0F, 0x00, 0x06, 0xA2, 0x2C, 0x10, 0x00, 0x07, 0x85, 0x5B, 0x10, 0x00, 0x0B, 0xF0, 0xDD, 0x13, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02]
        
        let value = AllCharactersResponse.characters(
            world: 0,
            characters: [
                MapleStory83.AllCharactersResponse.Character(
                    stats: MapleStory83.AllCharactersResponse.CharacterStats(
                        id: 1,
                        name: "ColemanCDA",
                        gender: .male,
                        skinColor: .pale,
                        face: 20001,
                        hair: .rebel(.blonde),
                        value0: 0,
                        value1: 0,
                        value2: 0,
                        level: 1,
                        job: .beginner,
                        str: 12,
                        dex: 5,
                        int: 4,
                        luk: 4,
                        hp: 50,
                        maxHp: 50,
                        mp: 5,
                        maxMp: 5,
                        ap: 0,
                        sp: 0,
                        exp: 0,
                        fame: 0,
                        isMarried: 0,
                        currentMap: .mushroomTown,
                        spawnPoint: 0,
                        value3: 0
                    ),
                    appearance: MapleStory83.AllCharactersResponse.CharacterAppeareance(
                        gender: .male,
                        skinColor: .pale,
                        face: 20001,
                        mega: true,
                        hair: .rebel(.blonde),
                        equipment: [5: 2195590912, 6: 2720796672, 7: 2237337600, 11: 67441664],
                        maskedEquipment: [:],
                        cashWeapon: 0,
                        value0: 0,
                        value1: 0
                    ),
                    rank: .enabled(
                        worldRank: 1,
                        rankMove: 0,
                        jobRank: 1,
                        jobRankMove: 0
                    )
                ),
                MapleStory83.AllCharactersResponse.Character(
                    stats: MapleStory83.AllCharactersResponse.CharacterStats(
                        id: 2,
                        name: "coleman2",
                        gender: .male,
                        skinColor: .normal,
                        face: 20000,
                        hair: .rebel(.black),
                        value0: 0,
                        value1: 0,
                        value2: 0,
                        level: 1,
                        job: .beginner,
                        str: 12,
                        dex: 5,
                        int: 4,
                        luk: 4,
                        hp: 50,
                        maxHp: 50,
                        mp: 5,
                        maxMp: 5,
                        ap: 0,
                        sp: 0,
                        exp: 0,
                        fame: 0,
                        isMarried: 0,
                        currentMap: .mushroomTown,
                        spawnPoint: 0,
                        value3: 0
                    ),
                    appearance: MapleStory83.AllCharactersResponse.CharacterAppeareance(
                        gender: MapleStory.Gender.male,
                        skinColor: MapleStory.SkinColor.normal,
                        face: 20000,
                        mega: true,
                        hair: .rebel(.black),
                        equipment: [5: 2262699776, 6: 2720796672, 7: 2237337600, 11: 4041020160],
                        maskedEquipment: [:],
                        cashWeapon: 0,
                        value0: 0,
                        value1: 0)
                    ,
                    rank: .enabled(
                        worldRank: 1,
                        rankMove: 0,
                        jobRank: 1,
                        jobRankMove: 0
                    )
                ),
                MapleStory83.AllCharactersResponse.Character(
                    stats: MapleStory83.AllCharactersResponse.CharacterStats(
                        id: 3,
                        name: "colemannight",
                        gender: MapleStory.Gender.male,
                        skinColor: MapleStory.SkinColor.normal,
                        face: 20000,
                        hair: .rebel(.blonde),
                        value0: 0,
                        value1: 0,
                        value2: 0,
                        level: 1,
                        job: .noblesse,
                        str: 12,
                        dex: 5,
                        int: 4,
                        luk: 4,
                        hp: 50,
                        maxHp: 50,
                        mp: 5,
                        maxMp: 5,
                        ap: 0,
                        sp: 0,
                        exp: 0,
                        fame: 0,
                        isMarried: 0,
                        currentMap: .startingMapNoblesse,
                        spawnPoint: 0,
                        value3: 0
                    ),
                    appearance: MapleStory83.AllCharactersResponse.CharacterAppeareance(
                        gender: .male,
                        skinColor: .normal,
                        face: 20000,
                        mega: true,
                        hair: .rebel(.blonde),
                        equipment:  [5: 2195590912, 6: 2720796672, 7: 2237337600, 11: 4041020160],
                        maskedEquipment: [:],
                        cashWeapon: 0,
                        value0: 0,
                        value1: 0
                    ),
                    rank: .enabled(
                        worldRank: 1,
                        rankMove: 0,
                        jobRank: 1,
                        jobRankMove: 0
                    )
                )
            ],
            picMode: .disabled
        )
        
        XCTAssertDecode(value, packet)
        XCTAssertEncode(value, packet)
    }
}
