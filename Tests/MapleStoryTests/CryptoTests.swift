//
//  CryptoTests.swift
//  
//
//  Created by Alsey Coleman Miller on 12/14/22.
//

import Foundation
import XCTest
@testable import MapleStory

final class CryptoTests: XCTestCase {
    
    func testMapleEncrypt() {
        
        let data: [(input: Data, output: Data)] = [
            (Data([0x11, 0x00]), Data([0x7C, 0x89])),
        ]
        
        for (input, output) in data {
            var encrypted = input
            Crypto.Maple.encrypt(&encrypted)
            XCTAssertEqual(encrypted, output, "\(encrypted.toHexadecimal()) should equal \(output.toHexadecimal())")
        }
    }
    
    func testMapleDecrypt() {
        
        let data: [(input: Data, output: Data)] = [
            (Data([0x0B, 0x34]), Data([0x18, 0x00])),
        ]
        
        for (input, output) in data {
            var decrypted = input
            Crypto.Maple.decrypt(&decrypted)
            XCTAssertEqual(decrypted, output, "\(decrypted.toHexadecimal()) should equal \(output.toHexadecimal())")
        }
    }
}
