//
//  XCTest.swift
//
//
//  Created by Alsey Coleman Miller on 5/1/24.
//

import Foundation
import XCTest
@testable import MapleStory

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
    _ packet: Packet<T.Opcode>,
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

func XCTAssertEncode<T>(
    _ value: T,
    _ data: Data,
    file: StaticString = #file,
    line: UInt = #line
) where T: Equatable, T: Encodable {
    
    var encoder = MapleStoryEncoder()
    encoder.log = { print("Encoder:", $0) }
    
    do {
        let encodedData = try encoder.encode(value)
        XCTAssertFalse(encodedData.isEmpty, file: file, line: line)
        XCTAssertEqual(encodedData, data, "\(encodedData.hexString) is not equal to \(data.hexString)", file: file, line: line)
    } catch {
        XCTFail(error.localizedDescription, file: file, line: line)
        dump(error)
    }
}

func XCTAssertEncrypt<T>(
    _ value: T,
    _ encrypted: EncryptedPacket,
    key: Key? = .default,
    nonce: Nonce,
    version: Version,
    file: StaticString = #file,
    line: UInt = #line
) where T: Equatable, T: Encodable, T: MapleStoryPacket {
    
    var encoder = MapleStoryEncoder()
    encoder.log = { print("Encoder:", $0) }
    
    do {
        let encodedPacket = try encoder.encodePacket(value)
        let encryptedPacket = try encodedPacket.encrypt(key: key, nonce: nonce, version: version)
        XCTAssertEqual(encryptedPacket.data, encrypted.data, "\(encryptedPacket.data.hexString) is not equal to \(encrypted.data.hexString)", file: file, line: line)
    } catch {
        XCTFail(error.localizedDescription, file: file, line: line)
        dump(error)
    }
}

func XCTAssertDecode<T>(
    _ value: T,
    _ packet: Packet<T.Opcode>,
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

func XCTAssertDecode<T>(
    _ value: T,
    _ data: Data,
    file: StaticString = #file,
    line: UInt = #line
) where T: Equatable, T: Decodable {
    
    var decoder = MapleStoryDecoder()
    decoder.log = { print("Decoder:", $0) }
    
    do {
        let decodedValue = try decoder.decode(T.self, from: data)
        XCTAssertEqual(decodedValue, value, file: file, line: line)
    } catch {
        XCTFail(error.localizedDescription, file: file, line: line)
        dump(error)
    }
}
