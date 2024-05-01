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
    
    func testLoginRequest() throws {
        
        let packet: Packet = [
            0x01, 0x00,
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
    }
}
