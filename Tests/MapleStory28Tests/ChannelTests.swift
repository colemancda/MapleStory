//
//  ChannelTests.swift
//
//
//  Created by Alsey Coleman Miller on 5/3/24.
//

import Foundation
import XCTest
@testable import MapleStory
@testable import MapleStory28

final class ChannelTests: XCTestCase {
    
    func testPlayerLoginRequest() {
        
        let encryptedPacket: EncryptedPacket = [36, 105, 245, 183, 228, 8]
        let packet: Packet<ClientOpcode> = [0x0C, 0x01, 0x00, 0x00, 0x00, 0x00]
        let nonce = Nonce(rawValue: UInt32(bigEndian: UInt32(bytes: (35, 47, 85, 23))))
        
        let value = PlayerLoginRequest(character: 1)
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
    }
}
