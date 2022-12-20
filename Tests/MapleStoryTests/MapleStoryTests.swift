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
        XCTAssertEqual(encrypted.data, encryptedData, "\(encrypted.data.toHexadecimal()) is not equal to \(encryptedData.toHexadecimal())")
        
        let decrypted = try encrypted.decrypt(key: .default, nonce: nonce, version: .v62)
        XCTAssertEqual(decrypted, packet)
    }
    
    func testLoginRequest() throws {
        
        let decryptedData = Data([0x01, 0x00, 0x05, 0x00, 0x61, 0x64, 0x6D, 0x69, 0x6E, 0x05, 0x00, 0x61, 0x64, 0x6D, 0x69, 0x6E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xDB, 0x97, 0xC5, 0xBE, 0x00, 0x00, 0x00, 0x00, 0x85, 0xC6, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
                
        let value = LoginRequest(
            username: "admin",
            password: "admin"
        )
        
        let packet = Packet(decryptedData)
        XCTAssertEqual(packet.opcode, LoginRequest.opcode)
        XCTAssertEqual(packet.data, decryptedData)
        XCTAssertDecode(value, packet)
    }
    
    func testLoginResponse() {
        
        
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
