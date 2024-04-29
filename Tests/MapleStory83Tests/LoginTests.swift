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
}
