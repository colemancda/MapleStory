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
}
