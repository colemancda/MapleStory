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
    
    func testNPCActionRequest() throws {
        
        /*
         MaplePacketDecoder encrypted packet D6 90 F0 82 73 B6 8C 57
         Recieve IV DF 53 AC 5C
         MapleAESOFB.crypt() input: D6 90 F0 82 73 B6 8C 57
         MapleAESOFB.crypt() iv: DF 53 AC 5C
         MapleAESOFB.crypt() output: FC 12 BF 5D C9 D6 0A 50
         MaplePacketDecoder AES decrypted packet FC 12 BF 5D C9 D6 0A 50
         MaplePacketDecoder custom decrypted packet A6 00 65 00 00 00 FF 00
         Incoming packet 0x00A6
         */
        
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
        
        /*
         MaplePacketEncoder will write encrypted C5 00 65 00 00 00 FF 00
         MaplePacketEncoder header D5 D2 DD D2
         MaplePacketEncoder custom encrypted A3 D6 B0 86 03 DC BF CD
         MapleAESOFB.crypt() input: A3 D6 B0 86 03 DC BF CD
         MapleAESOFB.crypt() iv: E7 F7 14 2D
         MapleAESOFB.crypt() output: DA 01 35 32 4E 5C 3D D7
         MaplePacketEncoder AES encrypted DA 01 35 32 4E 5C 3D D7
         MaplePacketEncoder output D5 D2 DD D2 DA 01 35 32 4E 5C 3D D7
         */
        
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
    
    func testRequest0x51() throws {
        
        /*
         MaplePacketDecoder encrypted packet CD 64 48 B0 98 20 37 CE 0D C0 73
         Recieve IV 2E 37 48 D7
         MapleAESOFB.crypt() input: CD 64 48 B0 98 20 37 CE 0D C0 73
         MapleAESOFB.crypt() iv: 2E 37 48 D7
         MapleAESOFB.crypt() output: 1C 86 1B 96 CA 3F 71 24 C9 09 67
         MaplePacketDecoder AES decrypted packet 1C 86 1B 96 CA 3F 71 24 C9 09 67
         MaplePacketDecoder custom decrypted packet 51 00 00 14 00 00 00 00 03 00 00
         Incoming packet 0x0051
         */
        
        let encryptedData = Data([0xCD, 0x64, 0x48, 0xB0, 0x98, 0x20, 0x37, 0xCE, 0x0D, 0xC0, 0x73])
        let packetData = Data([0x51, 0x00, 0x00, 0x14, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00])
        let nonce: Nonce = 0x2E3748D7
        
        let packet = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(packet.opcode, 0x0051)
        XCTAssertEqual(packet.data, packetData)
    }
}
