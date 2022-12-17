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
    }
    
    func testPing() {
        
        /*
         Ping packet
         short 17
         Packet to be sent:
         11 00
         
         MaplePacketEncoder will write encrypted 11 00
         MaplePacketEncoder header F8 11 FA 11
         MapleCustomEncryption.encryptData(): input 11 00
         MapleCustomEncryption.encryptData(): output 7C 89
         MaplePacketEncoder output F8 11 FA 11 EC E5
         */
    }
    
    func testLoginRequest() {
        
        
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
