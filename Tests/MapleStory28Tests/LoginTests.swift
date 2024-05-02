//
//  LoginTests.swift
//  
//
//  Created by Alsey Coleman Miller on 5/1/24.
//

import Foundation
import XCTest
@testable import MapleStory
@testable import MapleStory28

final class LoginTests: XCTestCase {
    
    func testHello() throws {
        
        let packet: Packet = [0x0D, 0x00, 0x1C, 0x00, 0x00, 0x00, 0x90, 0xE0, 0xCE, 0x6E, 0x5C, 0x2C, 0x1D, 0x1F, 0x08]
        
        let value = HelloPacket(
            recieveNonce: 0x90E0CE6E,
            sendNonce: 0x5C2C1D1F,
            region: .global
        )
        
        XCTAssertEqual(value.version, .v28)
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
    }
    
    func testLoginRequest() throws {
        
        let packet: Packet = [
            0x01,
            0x0A, 0x00,
            0x63, 0x6F, 0x6C, 0x65, 0x6D, 0x61, 0x6E, 0x63, 0x64, 0x61,
            0x08, 0x00,
            0x70, 0x61, 0x73, 0x73, 0x77, 0x6F, 0x72, 0x64,
            0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x83, 0x6E, 0x5B, 0x02,
            0x00, 0x00, 0x00, 0x00,
            0x8F, 0xA7,
            0x00, 0x00, 0x00, 0x00,
            0x02, 0x00
        ]
        
        let value = LoginRequest(
            username: "colemancda",
            password: "password",
            value0: 0x00,
            value1: 0x00,
            hardwareID: 0x025B6E83,
            value2: 0x00,
            value3: 0xA78F,
            value4: 0x00,
            value5: 0x02
        )
        
        XCTAssertDecode(value, packet)
        XCTAssertEncode(value, packet)
        //XCTAssertEqual(packet.data.count, 43)
    }
    
    func testLoginFailure() throws {
        
        let packet: Packet = [1, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        
        let encryptedData = Data([77, 65, 82, 65, 118, 195, 228, 214, 201, 110, 170, 145, 151, 208, 130, 25, 199, 219, 141, 197, 211, 204, 12, 13, 38, 157, 30, 174, 217, 211, 173, 174, 247, 121, 120])
        
        let encryptedPacket = try packet.encrypt(
            key: nil,
            nonce: Nonce(rawValue: UInt32(bigEndian: UInt32(bytes: (86, 68, 174, 190)))),
            version: .v28
        )
        
        XCTAssertEqual(encryptedData, encryptedPacket.data)
        
        let value = LoginResponse.failure(.alreadyLoggedIn)
        
        XCTAssertDecode(value, packet)
        XCTAssertEncode(value, packet)
    }
}
