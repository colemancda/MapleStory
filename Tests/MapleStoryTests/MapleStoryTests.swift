//
//  MapleStoryTests.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/22.
//

import Foundation
import XCTest
@testable import MapleStory

final class MapleStoryTests: XCTestCase {
    
    func testHello() throws {
        
        let data = Data([0x0D, 0x00, 0x3E, 0x00, 0x00, 0x00, 0x46, 0x72, 0x7A, 0x18, 0x52, 0x30, 0x78, 0x14, 0x08])
        
        guard let packet = Packet(data: data) else {
            XCTFail()
            return
        }
        
        let value = HelloPacket(
            version: .v62,
            recieveNonce: 0x46727A18,
            sendNonce: 0x52307814,
            region: .global
        )
        
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
    }
    
    func testPing() throws {
        
        /*
         Ping packet
         short 17
         Packet to be sent:
         11 00
         MaplePacketEncoder will write encrypted 11 00
         MaplePacketEncoder header 48 7D 4A 7D
         MapleCustomEncryption.encryptData(): input 11 00
         MapleCustomEncryption.encryptData(): output 7C 89
         MaplePacketEncoder custom encrypted 7C 89
         MapleAESOFB.crypt() input: 7C 89
         MapleAESOFB.crypt() iv: 27 56 89 82
         MapleAESOFB.crypt() output: 01 5C
         MaplePacketEncoder AES encrypted 01 5C
         MaplePacketEncoder output 48 7D 4A 7D 01 5C
         */
        
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
        
        let value = ServerListResponse(
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
        )
        
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
        
        XCTAssertEqual(packet.opcode, ServerListResponse.opcode)
        
        let encrypted = try packet.encrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(encrypted.length, packet.data.count)
        XCTAssertEqual(encrypted.data, encryptedData)
    }
    
    func testPinRequest() throws {
        
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
}

// MARK: - Extensions

extension Data {
    
    init?(hexString: String) {
      let len = hexString.count / 2
      var data = Data(capacity: len)
      var i = hexString.startIndex
      for _ in 0..<len {
        let j = hexString.index(i, offsetBy: 2)
        let bytes = hexString[i..<j]
        if var num = UInt8(bytes, radix: 16) {
          data.append(&num, count: 1)
        } else {
          return nil
        }
        i = j
      }
      self = data
    }
}

func XCTAssertEncode<T>(
    _ value: T,
    _ packet: Packet,
    file: StaticString = #file,
    line: UInt = #line
) where T: Equatable, T: Encodable, T: MapleStoryPacket {
    
    var encoder = MapleStoryEncoder()
    encoder.log = { print("Encoder:", $0) }
    
    do {
        let encodedPacket = try encoder.encodePacket(value)
        XCTAssertFalse(encodedPacket.data.isEmpty, file: file, line: line)
        XCTAssertEqual(encodedPacket.data, packet.data, "\(encodedPacket.data.hexString) is not equal to \(packet.data.hexString)", file: file, line: line)
    } catch {
        XCTFail(error.localizedDescription, file: file, line: line)
        dump(error)
    }
}

func XCTAssertEncrypt<T>(
    _ value: T,
    _ packet: Packet,
    file: StaticString = #file,
    line: UInt = #line
) where T: Equatable, T: Encodable, T: MapleStoryPacket {
    
    var encoder = MapleStoryEncoder()
    encoder.log = { print("Encoder:", $0) }
    
    do {
        let encodedPacket = try encoder.encodePacket(value)
        XCTAssertFalse(encodedPacket.data.isEmpty, file: file, line: line)
        XCTAssertEqual(encodedPacket.data, packet.data, "\(encodedPacket.data.hexString) is not equal to \(packet.data.hexString)", file: file, line: line)
    } catch {
        XCTFail(error.localizedDescription, file: file, line: line)
        dump(error)
    }
}


func XCTAssertDecode<T>(
    _ value: T,
    _ packet: Packet,
    file: StaticString = #file,
    line: UInt = #line
) where T: MapleStoryPacket, T: Equatable, T: Decodable {
    
    var decoder = MapleStoryDecoder()
    decoder.log = { print("Decoder:", $0) }
    
    do {
        let decodedValue = try decoder.decodePacket(T.self, from: packet.data)
        XCTAssertEqual(decodedValue, value, file: file, line: line)
    } catch {
        XCTFail(error.localizedDescription, file: file, line: line)
        dump(error)
    }
}
