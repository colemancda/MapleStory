//
//  File.swift
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
        
        let data = Data([0x0E, 0x00, 0x53, 0x00, 0x01, 0x00, 0x31, 0x68, 0x91, 0x09, 0x81, 0x42, 0x0F, 0x90, 0x9B, 0x08])
        
        guard let packet = Packet(data: data) else {
            XCTFail()
            return
        }
        
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
        
        let packet = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v83
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
    
    func testLoginFailure() throws {
        
        let encryptedData = Data([0xF7, 0x78, 0xFF, 0x78, 0x1E, 0x8F, 0xDA, 0x80, 0x10, 0x78, 0xAE, 0xFA])
        
        let packetData = Data([0x00, 0x00, 0x17, 0x00, 0x00, 0x00, 0x00, 0x00])
        
        let nonce: Nonce = 0x8C7E5B87
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
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
        
        let packetData = Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x05, 0x00, 0x61, 0x64, 0x6D, 0x69, 0x6E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x02])
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
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
        
        let packetData = Data([0x08, 0x00, 0x01, 0x00])
        
        guard let packet = Packet(data: packetData) else {
            XCTFail()
            return
        }
        
        let value = SetGenderRequest(gender: .male)
        XCTAssertEqual(packet, Packet(packetData))
        XCTAssertEqual(packet.opcode, type(of: value).opcode)
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
    }
    
    func testPong() throws {
        
        let encryptedData = Data([0x46, 0xD3])
        
        let packetData = Data([0x18, 0x00])
        
        let nonce: Nonce = 0x0A627F70
        
        let packet = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v83
        )
        
        let value = PongPacket()
        XCTAssertEqual(packet, Packet(packetData))
        XCTAssertEqual(packet.opcode, type(of: value).opcode)
        XCTAssertDecode(value, packet)
    }
}
