//
//  LoginTests.swift
//  
//
//  Created by Alsey Coleman Miller on 12/21/22.
//

import Foundation
import XCTest
@testable import MapleStory

final class LoginTests: XCTestCase {
    
    func testGuestLoginRequest() throws {
        
        /*
         MaplePacketDecoder encrypted packet C9 12 A9 11
         Recieve IV 46 72 7A E0
         MapleAESOFB.crypt() input: C9 12 A9 11
         MapleAESOFB.crypt() iv: 46 72 7A E0
         MapleAESOFB.crypt() output: 0A 3E DD 5C
         MaplePacketDecoder AES decrypted packet 0A 3E DD 5C
         MaplePacketDecoder custom decrypted packet 02 00 00 00
         Incoming packet 0x0002
         */
        
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
        
        /*
         MapleAESOFB:  Key: 13 00 00 00 08 00 00 00 06 00 00 00 B4 00 00 00 1B 00 00 00 0F 00 00 00 33 00 00 00 52 00 00 00 IV: 52 30 78 C8 Version: -63
         MapleAESOFB:  Key: 13 00 00 00 08 00 00 00 06 00 00 00 B4 00 00 00 1B 00 00 00 0F 00 00 00 33 00 00 00 52 00 00 00 IV: 46 72 7A B3 Version: 62
         MaplePacketDecoder encrypted packet 41 B4 8A 04 55 9A DE 80 D0 58 2C 44 64 27 A1 22 1A 84 14 0F E5 EE B7 EC 67 A4 68 60 15 8A 6F DF DA 52 FC 04 1F AF 25 7C 62 82 5C
         Recieve IV 46 72 7A B3
         MapleAESOFB.crypt() input: 41 B4 8A 04 55 9A DE 80 D0 58 2C 44 64 27 A1 22 1A 84 14 0F E5 EE B7 EC 67 A4 68 60 15 8A 6F DF DA 52 FC 04 1F AF 25 7C 62 82 5C
         MapleAESOFB.crypt() iv: 46 72 7A B3
         MapleAESOFB.crypt() output: 71 8A 05 E8 C2 46 CB 75 CA FF 4B 07 BA 9F 35 56 22 73 4A 19 FF CA 23 30 78 70 5A 09 56 C9 A3 C6 E8 4B 03 9B 8A 96 D9 B1 71 7E 0B
         MaplePacketDecoder AES decrypted packet 71 8A 05 E8 C2 46 CB 75 CA FF 4B 07 BA 9F 35 56 22 73 4A 19 FF CA 23 30 78 70 5A 09 56 C9 A3 C6 E8 4B 03 9B 8A 96 D9 B1 71 7E 0B
         MaplePacketDecoder custom decrypted packet 01 00 05 00 61 64 6D 69 6E 05 00 61 64 6D 69 6E 00 00 00 00 00 00 DB 97 C5 BE 00 00 00 00 85 C6 00 00 00 00 02 00 00 00 00 00 00
         Incoming packet 0x0001
         Login: admin admin
         */
        
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
            password: "admin"
        )
        
        XCTAssertEqual(packet.opcode, LoginRequest.opcode)
        XCTAssertEqual(packet.data, decryptedData)
        XCTAssertEqual(packet, Packet(decryptedData))
        XCTAssertDecode(value, packet)
    }
    
    func testSuccessLoginResponse() throws {
        
        /*
         getAuthSuccessRequestPin: admin
         MaplePacketEncoder will write encrypted 00 00 00 00 00 00 00 00 FF 6A 01 00 00 00 4E 05 00 61 64 6D 69 6E 03 00 00 00 00 00 00 00 00 00 00 DC 3D 0B 28 64 C5 01 08 00 00 00
         MaplePacketEncoder header B9 27 95 27
         MaplePacketEncoder custom encrypted 18 72 5E 8C 92 FE FA 38 29 45 4F C7 61 F8 8B 8A 1D 1E 17 A0 5D DC 02 F7 BD 54 91 B7 51 0A E7 EB D8 98 78 C8 FD DC 0F 9A 52 E4 D9 B1
         MapleAESOFB.crypt() input: 18 72 5E 8C 92 FE FA 38 29 45 4F C7 61 F8 8B 8A 1D 1E 17 A0 5D DC 02 F7 BD 54 91 B7 51 0A E7 EB D8 98 78 C8 FD DC 0F 9A 52 E4 D9 B1
         MapleAESOFB.crypt() iv: 52 30 78 D8
         MapleAESOFB.crypt() output: 4A BB C5 DD DC D4 08 BE 55 FD 75 F0 CC 74 50 95 E2 B2 9D CD 22 53 F6 5E F7 D6 44 E3 93 2F D3 A5 16 AD 6C FE 3F 55 C5 38 BD ED 46 50
         MaplePacketEncoder AES encrypted 4A BB C5 DD DC D4 08 BE 55 FD 75 F0 CC 74 50 95 E2 B2 9D CD 22 53 F6 5E F7 D6 44 E3 93 2F D3 A5 16 AD 6C FE 3F 55 C5 38 BD ED 46 50
         MaplePacketEncoder output B9 27 95 27 4A BB C5 DD DC D4 08 BE 55 FD 75 F0 CC 74 50 95 E2 B2 9D CD 22 53 F6 5E F7 D6 44 E3 93 2F D3 A5 16 AD 6C FE 3F 55 C5 38 BD ED 46 50
         */
        
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
        
        /*
         MaplePacketDecoder encrypted packet AE D7 B7 85 D7 56 9A BE 5E 1A
         Recieve IV 53 96 48 06
         MapleAESOFB.crypt() input: AE D7 B7 85 D7 56 9A BE 5E 1A
         MapleAESOFB.crypt() iv: 53 96 48 06
         MapleAESOFB.crypt() output: 58 77 FA 70 F0 48 84 1C AD C7
         MaplePacketDecoder AES decrypted packet 58 77 FA 70 F0 48 84 1C AD C7
         MaplePacketDecoder custom decrypted packet 09 00 01 01 FF 6A 01 00 00 00
         Incoming packet 0x0009
         AfterLoginHandler 1 1
         */
        
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
        
        /*
         pinOperation: 0
         MaplePacketEncoder will write encrypted 06 00 00
         MaplePacketEncoder header 30 16 33 16
         MaplePacketEncoder custom encrypted F1 81 4D
         MapleAESOFB.crypt() input: F1 81 4D
         MapleAESOFB.crypt() iv: 8A C3 F1 E9
         MapleAESOFB.crypt() output: F5 E4 8F
         MaplePacketEncoder AES encrypted F5 E4 8F
         MaplePacketEncoder output 30 16 33 16 F5 E4 8F
         */
        
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
        
        /*
         getServerList: 0 Name: " World 0" channelLoad: {2=0, 1=0}
         MaplePacketEncoder will write encrypted 0A 00 00 08 00 20 57 6F 72 6C 64 20 30 02 00 00 64 00 64 00 00 02 0A 00 20 57 6F 72 6C 64 20 30 2D 31 00 00 00 00 01 00 00 0A 00 20 57 6F 72 6C 64 20 30 2D 32 00 00 00 00 01 01 00 00 00
         MaplePacketEncoder header 17 CB 29 CB
         MaplePacketEncoder custom encrypted 49 63 F1 F9 2E D7 67 86 42 B8 96 0E 96 A7 91 DA C8 3B 9A F9 16 1A 0D F8 D4 86 2A 36 AC 01 DE 13 11 8D FB 81 BD 87 A2 88 31 EE 80 F3 47 63 32 18 36 C9 AC F4 45 E7 D5 AD 72 07 5C 13 A6 97
         MapleAESOFB.crypt() input: 49 63 F1 F9 2E D7 67 86 42 B8 96 0E 96 A7 91 DA C8 3B 9A F9 16 1A 0D F8 D4 86 2A 36 AC 01 DE 13 11 8D FB 81 BD 87 A2 88 31 EE 80 F3 47 63 32 18 36 C9 AC F4 45 E7 D5 AD 72 07 5C 13 A6 97
         MapleAESOFB.crypt() iv: 40 01 D6 34
         MapleAESOFB.crypt() output: 00 0D 49 3D 99 DC BF B3 FD 73 EE 54 E9 69 4D 9F 49 FA C9 DC 67 23 A4 8E E5 02 7F 5D 01 E3 5C B8 E9 C1 28 7B E1 36 B6 55 7A 15 BC 97 E4 A0 F1 35 09 5B AF 84 C7 8D 90 98 41 CF AC DF 76 07
         MaplePacketEncoder AES encrypted 00 0D 49 3D 99 DC BF B3 FD 73 EE 54 E9 69 4D 9F 49 FA C9 DC 67 23 A4 8E E5 02 7F 5D 01 E3 5C B8 E9 C1 28 7B E1 36 B6 55 7A 15 BC 97 E4 A0 F1 35 09 5B AF 84 C7 8D 90 98 41 CF AC DF 76 07
         MaplePacketEncoder output 17 CB 29 CB 00 0D 49 3D 99 DC BF B3 FD 73 EE 54 E9 69 4D 9F 49 FA C9 DC 67 23 A4 8E E5 02 7F 5D 01 E3 5C B8 E9 C1 28 7B E1 36 B6 55 7A 15 BC 97 E4 A0 F1 35 09 5B AF 84 C7 8D 90 98 41 CF AC DF 76 07
         */
        
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
        
        /*
         getEndOfServerList
         MaplePacketEncoder will write encrypted 0A 00 FF
         MaplePacketEncoder header CE 3C CD 3C
         MaplePacketEncoder custom encrypted C2 EA E2
         MapleAESOFB.crypt() input: C2 EA E2
         MapleAESOFB.crypt() iv: 9C 29 0F C3
         MapleAESOFB.crypt() output: 0D 00 6A
         MaplePacketEncoder AES encrypted 0D 00 6A
         MaplePacketEncoder output CE 3C CD 3C 0D 00 6A
         */
        
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
        
        /*
         MaplePacketEncoder will write encrypted 0B 00 00 01 01 00 00 00 41 64 6D 69 6E 00 00 00 00 00 00 00 00 00 00 20 4E 00 00 4E 75 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FE 00 02 FF 7F FF 7F FF 7F FF 7F 30 75 30 75 6A 67 30 75 00 00 00 00 00 00 00 00 19 34 00 00 00 00 80 7F 3D 36 01 00 00 00 00 00 00 20 4E 00 00 01 4E 75 00 00 05 82 DE 0F 00 06 A2 2C 10 00 09 D9 D0 10 00 01 75 4B 0F 00 07 81 5B 10 00 0B 27 9D 16 00 FF FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 01 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 06 00 00 00
         MaplePacketEncoder header 60 59 D1 59
         MaplePacketEncoder custom encrypted 82 1B 0B 3C 60 F0 FA 4F 8B 5E B6 A0 6D 71 03 E7 02 F1 0D 9E 52 C7 F1 20 22 63 9D FF 67 10 C0 F9 D2 AC C1 9D D7 72 07 96 D5 AB CA 91 36 9F C5 F0 6D DE EB DB 9F B7 0B 0D 4F 5B AA C0 5E 7E 46 AA 3A 8B 21 8D 5B E9 87 26 A3 28 B1 72 E4 1B D7 B5 B6 60 9E CB BD 9D B4 E7 2D 59 02 A7 8E 15 80 4A AF 18 65 D0 06 C4 92 40 06 5F 8E 85 5C E1 1E BB 9D B1 26 BD FA F4 1F 69 64 C6 63 5E 6F C6 B5 66 28 32 96 38 4B 3B E9 C5 5A 67 4A 51 82 59 7C 5C 68 96 2D 6A CE 69 18 0B 47 79 E7 D9 11 D3 65 83 56 AB 3B 40 F2 45 5F E6 71 A6 1F 1E 22 3A 39 69 23
         MapleAESOFB.crypt() input: 82 1B 0B 3C 60 F0 FA 4F 8B 5E B6 A0 6D 71 03 E7 02 F1 0D 9E 52 C7 F1 20 22 63 9D FF 67 10 C0 F9 D2 AC C1 9D D7 72 07 96 D5 AB CA 91 36 9F C5 F0 6D DE EB DB 9F B7 0B 0D 4F 5B AA C0 5E 7E 46 AA 3A 8B 21 8D 5B E9 87 26 A3 28 B1 72 E4 1B D7 B5 B6 60 9E CB BD 9D B4 E7 2D 59 02 A7 8E 15 80 4A AF 18 65 D0 06 C4 92 40 06 5F 8E 85 5C E1 1E BB 9D B1 26 BD FA F4 1F 69 64 C6 63 5E 6F C6 B5 66 28 32 96 38 4B 3B E9 C5 5A 67 4A 51 82 59 7C 5C 68 96 2D 6A CE 69 18 0B 47 79 E7 D9 11 D3 65 83 56 AB 3B 40 F2 45 5F E6 71 A6 1F 1E 22 3A 39 69 23
         MapleAESOFB.crypt() iv: 0C 5E A1 A6
         MapleAESOFB.crypt() output: 7A BC 1A 42 35 1E 17 21 F0 BC 27 85 75 39 8A 00 DF FA C7 78 98 EB A8 C4 E1 89 B4 3B 70 FD FC EC 82 B0 C4 06 6C 2D DF 8A 16 40 15 BE 76 D2 4B F8 41 B7 13 E9 E2 55 23 7B C2 7D 2A E5 DB FC 77 1F A0 0F B7 2C CE 3E 86 9B A4 4A CC 07 38 F3 41 F3 AD 35 F5 3C F3 65 36 91 11 59 DE CE C4 5E AD 5A 58 3A 9B A6 2A 06 2A F9 C8 70 25 A6 66 D4 58 89 4E E6 52 BE 72 40 CA C7 74 0D 80 36 5D 56 2E E6 86 C0 50 F1 9F 70 02 03 CF A5 C7 A3 E0 A6 2B 67 B5 AA 8A 4C 5F 00 AD B3 B3 23 5B DD 29 0B 09 CE 71 33 02 2D 19 5D A3 8F B3 65 67 B7 7E B6 F7 E9 BD
         MaplePacketEncoder AES encrypted 7A BC 1A 42 35 1E 17 21 F0 BC 27 85 75 39 8A 00 DF FA C7 78 98 EB A8 C4 E1 89 B4 3B 70 FD FC EC 82 B0 C4 06 6C 2D DF 8A 16 40 15 BE 76 D2 4B F8 41 B7 13 E9 E2 55 23 7B C2 7D 2A E5 DB FC 77 1F A0 0F B7 2C CE 3E 86 9B A4 4A CC 07 38 F3 41 F3 AD 35 F5 3C F3 65 36 91 11 59 DE CE C4 5E AD 5A 58 3A 9B A6 2A 06 2A F9 C8 70 25 A6 66 D4 58 89 4E E6 52 BE 72 40 CA C7 74 0D 80 36 5D 56 2E E6 86 C0 50 F1 9F 70 02 03 CF A5 C7 A3 E0 A6 2B 67 B5 AA 8A 4C 5F 00 AD B3 B3 23 5B DD 29 0B 09 CE 71 33 02 2D 19 5D A3 8F B3 65 67 B7 7E B6 F7 E9 BD
         MaplePacketEncoder output 60 59 D1 59 7A BC 1A 42 35 1E 17 21 F0 BC 27 85 75 39 8A 00 DF FA C7 78 98 EB A8 C4 E1 89 B4 3B 70 FD FC EC 82 B0 C4 06 6C 2D DF 8A 16 40 15 BE 76 D2 4B F8 41 B7 13 E9 E2 55 23 7B C2 7D 2A E5 DB FC 77 1F A0 0F B7 2C CE 3E 86 9B A4 4A CC 07 38 F3 41 F3 AD 35 F5 3C F3 65 36 91 11 59 DE CE C4 5E AD 5A 58 3A 9B A6 2A 06 2A F9 C8 70 25 A6 66 D4 58 89 4E E6 52 BE 72 40 CA C7 74 0D 80 36 5D 56 2E E6 86 C0 50 F1 9F 70 02 03 CF A5 C7 A3 E0 A6 2B 67 B5 AA 8A 4C 5F 00 AD B3 B3 23 5B DD 29 0B 09 CE 71 33 02 2D 19 5D A3 8F B3 65 67 B7 7E B6 F7 E9 BD
         */
        
        let packetData = Data([0x0B, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x41, 0x64, 0x6D, 0x69, 0x6E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x4E, 0x00, 0x00, 0x4E, 0x75, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFE, 0x00, 0x02, 0xFF, 0x7F, 0xFF, 0x7F, 0xFF, 0x7F, 0xFF, 0x7F, 0x30, 0x75, 0x30, 0x75, 0x6A, 0x67, 0x30, 0x75, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x19, 0x34, 0x00, 0x00, 0x00, 0x00, 0x80, 0x7F, 0x3D, 0x36, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x4E, 0x00, 0x00, 0x01, 0x4E, 0x75, 0x00, 0x00, 0x05, 0x82, 0xDE, 0x0F, 0x00, 0x06, 0xA2, 0x2C, 0x10, 0x00, 0x09, 0xD9, 0xD0, 0x10, 0x00, 0x01, 0x75, 0x4B, 0x0F, 0x00, 0x07, 0x81, 0x5B, 0x10, 0x00, 0x0B, 0x27, 0x9D, 0x16, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00])
        let encryptedData = Data([0x60, 0x59, 0xD1, 0x59, 0x7A, 0xBC, 0x1A, 0x42, 0x35, 0x1E, 0x17, 0x21, 0xF0, 0xBC, 0x27, 0x85, 0x75, 0x39, 0x8A, 0x00, 0xDF, 0xFA, 0xC7, 0x78, 0x98, 0xEB, 0xA8, 0xC4, 0xE1, 0x89, 0xB4, 0x3B, 0x70, 0xFD, 0xFC, 0xEC, 0x82, 0xB0, 0xC4, 0x06, 0x6C, 0x2D, 0xDF, 0x8A, 0x16, 0x40, 0x15, 0xBE, 0x76, 0xD2, 0x4B, 0xF8, 0x41, 0xB7, 0x13, 0xE9, 0xE2, 0x55, 0x23, 0x7B, 0xC2, 0x7D, 0x2A, 0xE5, 0xDB, 0xFC, 0x77, 0x1F, 0xA0, 0x0F, 0xB7, 0x2C, 0xCE, 0x3E, 0x86, 0x9B, 0xA4, 0x4A, 0xCC, 0x07, 0x38, 0xF3, 0x41, 0xF3, 0xAD, 0x35, 0xF5, 0x3C, 0xF3, 0x65, 0x36, 0x91, 0x11, 0x59, 0xDE, 0xCE, 0xC4, 0x5E, 0xAD, 0x5A, 0x58, 0x3A, 0x9B, 0xA6, 0x2A, 0x06, 0x2A, 0xF9, 0xC8, 0x70, 0x25, 0xA6, 0x66, 0xD4, 0x58, 0x89, 0x4E, 0xE6, 0x52, 0xBE, 0x72, 0x40, 0xCA, 0xC7, 0x74, 0x0D, 0x80, 0x36, 0x5D, 0x56, 0x2E, 0xE6, 0x86, 0xC0, 0x50, 0xF1, 0x9F, 0x70, 0x02, 0x03, 0xCF, 0xA5, 0xC7, 0xA3, 0xE0, 0xA6, 0x2B, 0x67, 0xB5, 0xAA, 0x8A, 0x4C, 0x5F, 0x00, 0xAD, 0xB3, 0xB3, 0x23, 0x5B, 0xDD, 0x29, 0x0B, 0x09, 0xCE, 0x71, 0x33, 0x02, 0x2D, 0x19, 0x5D, 0xA3, 0x8F, 0xB3, 0x65, 0x67, 0xB7, 0x7E, 0xB6, 0xF7, 0xE9, 0xBD])
        let nonce: Nonce = 0x0C5EA1A6
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = CharacterListResponse(
            value0: 0x00,
            characters: [
                MapleStory.CharacterListResponse.Character(
                    stats: MapleStory.CharacterListResponse.CharacterStats(
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
                    appearance: MapleStory.CharacterListResponse.CharacterAppeareance(
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
                    rank: MapleStory.CharacterListResponse.Rank(
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
        
        /*
         MaplePacketEncoder will write encrypted 08 00 00 00 01 01 00 00 00 41 64 6D 69 6E 00 00 00 00 00 00 00 00 00 00 20 4E 00 00 4E 75 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FE 00 02 FF 7F FF 7F FF 7F FF 7F 30 75 30 75 6A 67 30 75 00 00 00 00 00 00 00 00 19 34 00 00 00 00 80 7F 3D 36 01 00 00 00 00 00 00 20 4E 00 00 01 4E 75 00 00 05 82 DE 0F 00 06 A2 2C 10 00 09 D9 D0 10 00 01 75 4B 0F 00 07 81 5B 10 00 0B 27 9D 16 00 FF FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 01 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00
         MaplePacketEncoder header 2A 47 84 47
         MaplePacketEncoder custom encrypted C6 8F 2D 05 5A CD 87 2D 0E EC AC 67 84 EE 54 EC 74 A0 B2 AD 05 63 54 C0 A1 5F CD 6B F6 38 11 B4 EA 85 B0 9E A6 0E 6D 97 2A B9 F5 A6 FB F1 26 8D B1 B8 15 4C 63 38 7B 85 8F BD A1 04 64 5D F7 56 9D 1F A3 A4 B9 97 B1 15 F7 7A 2F 6D 10 07 5C C1 FB 5A 2F 89 07 C1 23 AE 12 72 18 98 F7 73 46 0F 79 B7 3B 61 A6 DC BF 8A 7D 81 74 E5 00 AA 66 18 F8 E0 E1 23 39 DD 9B 4A 04 33 1C 0C 18 C9 6D 89 99 CA 44 E8 56 40 2D 12 CE 35 F9 47 D0 F4 78 7B 89 8B 4F 10 97 83 2A 89 0B E7 6C CD 9F C9 BA B3 A9 ED 04 07 C8 6B 92 5B 75 75 4B 50 8B F4
         MapleAESOFB.crypt() input: C6 8F 2D 05 5A CD 87 2D 0E EC AC 67 84 EE 54 EC 74 A0 B2 AD 05 63 54 C0 A1 5F CD 6B F6 38 11 B4 EA 85 B0 9E A6 0E 6D 97 2A B9 F5 A6 FB F1 26 8D B1 B8 15 4C 63 38 7B 85 8F BD A1 04 64 5D F7 56 9D 1F A3 A4 B9 97 B1 15 F7 7A 2F 6D 10 07 5C C1 FB 5A 2F 89 07 C1 23 AE 12 72 18 98 F7 73 46 0F 79 B7 3B 61 A6 DC BF 8A 7D 81 74 E5 00 AA 66 18 F8 E0 E1 23 39 DD 9B 4A 04 33 1C 0C 18 C9 6D 89 99 CA 44 E8 56 40 2D 12 CE 35 F9 47 D0 F4 78 7B 89 8B 4F 10 97 83 2A 89 0B E7 6C CD 9F C9 BA B3 A9 ED 04 07 C8 6B 92 5B 75 75 4B 50 8B F4
         MapleAESOFB.crypt() iv: 79 B9 EB B8
         MapleAESOFB.crypt() output: C5 93 F9 DB 27 75 29 30 DB A1 78 6C 98 39 4B 93 C0 E9 28 60 CF 53 C2 99 5F 20 D9 11 85 4A D4 8B 81 A8 6E 67 B3 33 96 E0 5F 3F 9A 66 41 CB 86 4A 4B 33 F4 2E 2E E7 99 F2 A7 C9 31 E1 FB 45 86 34 2E 56 69 45 4E 31 4D 64 DA 00 4A 53 86 26 D9 31 50 AB 0F DA FA B9 5A 5F 35 AE 1A 04 42 65 93 24 00 D5 DF DF 22 43 8A 3A F8 69 7B E1 D9 69 2B 61 0A DE 34 66 01 82 86 0F EE 0A DC 1E 27 C0 23 E0 18 A4 5E 05 D9 CA 2F 8A 73 46 9A F7 53 A9 89 70 5A 02 5E 67 E7 E6 89 15 78 7A 5F 4F 31 05 36 82 18 E3 5C AE F7 7D 58 C5 91 23 43 DE 90 F7
         MaplePacketEncoder AES encrypted C5 93 F9 DB 27 75 29 30 DB A1 78 6C 98 39 4B 93 C0 E9 28 60 CF 53 C2 99 5F 20 D9 11 85 4A D4 8B 81 A8 6E 67 B3 33 96 E0 5F 3F 9A 66 41 CB 86 4A 4B 33 F4 2E 2E E7 99 F2 A7 C9 31 E1 FB 45 86 34 2E 56 69 45 4E 31 4D 64 DA 00 4A 53 86 26 D9 31 50 AB 0F DA FA B9 5A 5F 35 AE 1A 04 42 65 93 24 00 D5 DF DF 22 43 8A 3A F8 69 7B E1 D9 69 2B 61 0A DE 34 66 01 82 86 0F EE 0A DC 1E 27 C0 23 E0 18 A4 5E 05 D9 CA 2F 8A 73 46 9A F7 53 A9 89 70 5A 02 5E 67 E7 E6 89 15 78 7A 5F 4F 31 05 36 82 18 E3 5C AE F7 7D 58 C5 91 23 43 DE 90 F7
         MaplePacketEncoder output 2A 47 84 47 C5 93 F9 DB 27 75 29 30 DB A1 78 6C 98 39 4B 93 C0 E9 28 60 CF 53 C2 99 5F 20 D9 11 85 4A D4 8B 81 A8 6E 67 B3 33 96 E0 5F 3F 9A 66 41 CB 86 4A 4B 33 F4 2E 2E E7 99 F2 A7 C9 31 E1 FB 45 86 34 2E 56 69 45 4E 31 4D 64 DA 00 4A 53 86 26 D9 31 50 AB 0F DA FA B9 5A 5F 35 AE 1A 04 42 65 93 24 00 D5 DF DF 22 43 8A 3A F8 69 7B E1 D9 69 2B 61 0A DE 34 66 01 82 86 0F EE 0A DC 1E 27 C0 23 E0 18 A4 5E 05 D9 CA 2F 8A 73 46 9A F7 53 A9 89 70 5A 02 5E 67 E7 E6 89 15 78 7A 5F 4F 31 05 36 82 18 E3 5C AE F7 7D 58 C5 91 23 43 DE 90 F7
         */
        
        let packetData = Data([0x08, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x41, 0x64, 0x6D, 0x69, 0x6E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x4E, 0x00, 0x00, 0x4E, 0x75, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFE, 0x00, 0x02, 0xFF, 0x7F, 0xFF, 0x7F, 0xFF, 0x7F, 0xFF, 0x7F, 0x30, 0x75, 0x30, 0x75, 0x6A, 0x67, 0x30, 0x75, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x19, 0x34, 0x00, 0x00, 0x00, 0x00, 0x80, 0x7F, 0x3D, 0x36, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x4E, 0x00, 0x00, 0x01, 0x4E, 0x75, 0x00, 0x00, 0x05, 0x82, 0xDE, 0x0F, 0x00, 0x06, 0xA2, 0x2C, 0x10, 0x00, 0x09, 0xD9, 0xD0, 0x10, 0x00, 0x01, 0x75, 0x4B, 0x0F, 0x00, 0x07, 0x81, 0x5B, 0x10, 0x00, 0x0B, 0x27, 0x9D, 0x16, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        let encryptedData = Data([0x2A, 0x47, 0x84, 0x47, 0xC5, 0x93, 0xF9, 0xDB, 0x27, 0x75, 0x29, 0x30, 0xDB, 0xA1, 0x78, 0x6C, 0x98, 0x39, 0x4B, 0x93, 0xC0, 0xE9, 0x28, 0x60, 0xCF, 0x53, 0xC2, 0x99, 0x5F, 0x20, 0xD9, 0x11, 0x85, 0x4A, 0xD4, 0x8B, 0x81, 0xA8, 0x6E, 0x67, 0xB3, 0x33, 0x96, 0xE0, 0x5F, 0x3F, 0x9A, 0x66, 0x41, 0xCB, 0x86, 0x4A, 0x4B, 0x33, 0xF4, 0x2E, 0x2E, 0xE7, 0x99, 0xF2, 0xA7, 0xC9, 0x31, 0xE1, 0xFB, 0x45, 0x86, 0x34, 0x2E, 0x56, 0x69, 0x45, 0x4E, 0x31, 0x4D, 0x64, 0xDA, 0x00, 0x4A, 0x53, 0x86, 0x26, 0xD9, 0x31, 0x50, 0xAB, 0x0F, 0xDA, 0xFA, 0xB9, 0x5A, 0x5F, 0x35, 0xAE, 0x1A, 0x04, 0x42, 0x65, 0x93, 0x24, 0x00, 0xD5, 0xDF, 0xDF, 0x22, 0x43, 0x8A, 0x3A, 0xF8, 0x69, 0x7B, 0xE1, 0xD9, 0x69, 0x2B, 0x61, 0x0A, 0xDE, 0x34, 0x66, 0x01, 0x82, 0x86, 0x0F, 0xEE, 0x0A, 0xDC, 0x1E, 0x27, 0xC0, 0x23, 0xE0, 0x18, 0xA4, 0x5E, 0x05, 0xD9, 0xCA, 0x2F, 0x8A, 0x73, 0x46, 0x9A, 0xF7, 0x53, 0xA9, 0x89, 0x70, 0x5A, 0x02, 0x5E, 0x67, 0xE7, 0xE6, 0x89, 0x15, 0x78, 0x7A, 0x5F, 0x4F, 0x31, 0x05, 0x36, 0x82, 0x18, 0xE3, 0x5C, 0xAE, 0xF7, 0x7D, 0x58, 0xC5, 0x91, 0x23, 0x43, 0xDE, 0x90, 0xF7])
        let nonce: Nonce = 0x79B9EBB8
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = AllCharactersResponse.characters(world: 0, characters: [
            MapleStory.CharacterListResponse.Character(
                stats: MapleStory.CharacterListResponse.CharacterStats(
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
                appearance: MapleStory.CharacterListResponse.CharacterAppeareance(
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
                rank: MapleStory.CharacterListResponse.Rank(
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
        
        /*
         MaplePacketEncoder will write encrypted 08 00 01 01 00 00 00 03 00 00 00
         MaplePacketEncoder header 05 F2 0E F2
         MaplePacketEncoder custom encrypted 77 B6 48 07 99 7A 0E 5D 97 BE 32
         MapleAESOFB.crypt() input: 77 B6 48 07 99 7A 0E 5D 97 BE 32
         MapleAESOFB.crypt() iv: 97 86 C4 0D
         MapleAESOFB.crypt() output: E2 29 45 34 B6 76 C7 D2 18 E4 CF
         MaplePacketEncoder AES encrypted E2 29 45 34 B6 76 C7 D2 18 E4 CF
         MaplePacketEncoder output 05 F2 0E F2 E2 29 45 34 B6 76 C7 D2 18 E4 CF
         */
        
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
    
    func testSelectCharacterRequest() throws {
        
        /*
         MaplePacketDecoder encrypted packet E9 46 D1 A0 6F E7 E5 54 AF 6C 9C 45 55 8B DB 3F 7B CD 1D EB 4C B1 B4 82 19 E4 1A 36 8F 08 E6 24 9F CF 34 FC F6 1B B6 43 A8 0A 6F 27 4C 77 9E 5E 82 42 40 8F
         Recieve IV 2E B6 1F E4
         MapleAESOFB.crypt() input: E9 46 D1 A0 6F E7 E5 54 AF 6C 9C 45 55 8B DB 3F 7B CD 1D EB 4C B1 B4 82 19 E4 1A 36 8F 08 E6 24 9F CF 34 FC F6 1B B6 43 A8 0A 6F 27 4C 77 9E 5E 82 42 40 8F
         MapleAESOFB.crypt() iv: 2E B6 1F E4
         MapleAESOFB.crypt() output: D5 87 B7 70 51 55 3E 45 A8 D1 09 6C B9 82 AD E5 3E 61 A8 4A CE 77 50 A9 39 50 FD 36 BA 2C C9 68 D1 49 3A 99 21 EF 4E C5 26 79 14 03 04 7C 6C 42 E8 09 86 6C
         MaplePacketDecoder AES decrypted packet D5 87 B7 70 51 55 3E 45 A8 D1 09 6C B9 82 AD E5 3E 61 A8 4A CE 77 50 A9 39 50 FD 36 BA 2C C9 68 D1 49 3A 99 21 EF 4E C5 26 79 14 03 04 7C 6C 42 E8 09 86 6C
         MaplePacketDecoder custom decrypted packet 0E 00 01 00 00 00 00 00 00 00 11 00 30 30 2D 31 43 2D 34 32 2D 34 38 2D 30 37 2D 32 39 15 00 42 43 39 41 37 38 35 36 33 34 31 32 5F 44 42 39 37 43 35 42 45
         Incoming packet 0x000E
         */
        
        let packetData = Data([0x0E, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00, 0x30, 0x30, 0x2D, 0x31, 0x43, 0x2D, 0x34, 0x32, 0x2D, 0x34, 0x38, 0x2D, 0x30, 0x37, 0x2D, 0x32, 0x39, 0x15, 0x00, 0x42, 0x43, 0x39, 0x41, 0x37, 0x38, 0x35, 0x36, 0x33, 0x34, 0x31, 0x32, 0x5F, 0x44, 0x42, 0x39, 0x37, 0x43, 0x35, 0x42, 0x45])
        let encryptedData = Data([0xE9, 0x46, 0xD1, 0xA0, 0x6F, 0xE7, 0xE5, 0x54, 0xAF, 0x6C, 0x9C, 0x45, 0x55, 0x8B, 0xDB, 0x3F, 0x7B, 0xCD, 0x1D, 0xEB, 0x4C, 0xB1, 0xB4, 0x82, 0x19, 0xE4, 0x1A, 0x36, 0x8F, 0x08, 0xE6, 0x24, 0x9F, 0xCF, 0x34, 0xFC, 0xF6, 0x1B, 0xB6, 0x43, 0xA8, 0x0A, 0x6F, 0x27, 0x4C, 0x77, 0x9E, 0x5E, 0x82, 0x42, 0x40, 0x8F])
        let nonce: Nonce = 0x2EB61FE4
        
        let value = SelectCharacterRequest(
            client: 1,
            macAddresses: ""
        )
        
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
        
        XCTAssertDecode(value, packet)
        XCTAssertEqual(decrypted, packet)
        XCTAssertEqual(packet.opcode, type(of: value).opcode)
    }
    
    func testServerIPResponse() throws {
        
        /*
         getServerIP: /172.17.0.3 7575 1
         MaplePacketEncoder will write encrypted 0C 00 00 00 AC 11 00 03 97 1D 01 00 00 00 00 00 00 00 00
         MaplePacketEncoder header 40 87 53 87
         MaplePacketEncoder custom encrypted 2F BA FA D3 82 53 0C CB D0 B5 E8 B9 B7 E3 C5 6F 8D 7A BE
         MapleAESOFB.crypt() input: 2F BA FA D3 82 53 0C CB D0 B5 E8 B9 B7 E3 C5 6F 8D 7A BE
         MapleAESOFB.crypt() iv: 96 27 81 78
         MapleAESOFB.crypt() output: 51 66 E7 BF 46 CA EB B5 CA C2 D2 4D CD A0 25 60 B2 D9 3C
         MaplePacketEncoder AES encrypted 51 66 E7 BF 46 CA EB B5 CA C2 D2 4D CD A0 25 60 B2 D9 3C
         MaplePacketEncoder output 40 87 53 87 51 66 E7 BF 46 CA EB B5 CA C2 D2 4D CD A0 25 60 B2 D9 3C
         */
        
        let packetData = Data([0x0C, 0x00, 0x00, 0x00, 0xAC, 0x11, 0x00, 0x03, 0x97, 0x1D, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        let encryptedData = Data([0x40, 0x87, 0x53, 0x87, 0x51, 0x66, 0xE7, 0xBF, 0x46, 0xCA, 0xEB, 0xB5, 0xCA, 0xC2, 0xD2, 0x4D, 0xCD, 0xA0, 0x25, 0x60, 0xB2, 0xD9, 0x3C])
        let nonce: Nonce = 0x96278178
        
        let value = ServerIPResponse(
            value0: 0,
            address: MapleStoryAddress(rawValue: "172.17.0.3:7575")!,
            client: 1,
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
}
