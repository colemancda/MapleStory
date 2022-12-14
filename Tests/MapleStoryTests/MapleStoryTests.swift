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
    
    func testJob() {
        
        XCTAssertEqual(Job.beginner.type, .beginner)
        
        XCTAssertEqual(Job.warrior.type, .warrior)
        XCTAssertEqual(Job.fighter.type, .warrior)
        XCTAssertEqual(Job.crusader.type, .warrior)
        XCTAssertEqual(Job.darkknight.type, .warrior)
        
        XCTAssertEqual(Job.magician.type, .magician)
        XCTAssertEqual(Job.fpWizard.type, .magician)
        XCTAssertEqual(Job.fpMage.type, .magician)
        XCTAssertEqual(Job.priest.type, .magician)
        XCTAssertEqual(Job.bishop.type, .magician)
        
        XCTAssertEqual(Job.bowman.type, .bowman)
        XCTAssertEqual(Job.hunter.type, .bowman)
        XCTAssertEqual(Job.sniper.type, .bowman)
        XCTAssertEqual(Job.marksman.type, .bowman)
        
        XCTAssertEqual(Job.thief.type, .thief)
        XCTAssertEqual(Job.assassin.type, .thief)
        XCTAssertEqual(Job.bandit.type, .thief)
        XCTAssertEqual(Job.shadower.type, .thief)
        
        XCTAssertEqual(Job.pirate.type, .pirate)
        XCTAssertEqual(Job.brawler.type, .pirate)
        XCTAssertEqual(Job.buccaneer.type, .pirate)
        XCTAssertEqual(Job.gunslinger.type, .pirate)
        XCTAssertEqual(Job.outlaw.type, .pirate)
        XCTAssertEqual(Job.corsair.type, .pirate)
        
        XCTAssertEqual(Job.gm.type, .gm)
        XCTAssertEqual(Job.supergm.type, .gm)
    }
    
    func testWorldName() {
        
        func name(for id: World.ID) -> String {
            switch id {
            case 0:
                return "Scania"
            case 1:
                return "Bera"
            case 2:
                return "Broa"
            case 3:
                return "Windia"
            case 4:
                return "Khaini"
            case 5:
                return "Bellocan"
            case 6:
                return "Mardia"
            case 7:
                return "Kradia"
            case 8:
                return "Yellonde"
            case 9:
                return "Demethos"
            case 10:
                return "Elnido"
            case 11:
                return "Kastia"
            case 12:
                return "Judis"
            case 13:
                return "Arkenia"
            case 14:
                return "Plana"
            default:
                return "World \(id + 1)"
            }
        }
        
        XCTAssertEqual(World.Name.scania.rawValue, name(for: 0))
        XCTAssertEqual(World.Name.scania.id, 0)
        XCTAssertEqual(World.Name(id: 0), .scania)
        
        XCTAssertNil(World.Name(id: 15))
        XCTAssertEqual(World.name(for: 15), "World 16")
        XCTAssertEqual(World.name(for: 15), name(for: 15))
        
        for (index, value) in World.Name.allCases.enumerated() {
            let id = UInt8(index)
            XCTAssertEqual(value.id, id)
            XCTAssertEqual(World.Name(id: id), value)
            XCTAssertEqual(value.rawValue, name(for: id))
            XCTAssertEqual(World.Name(rawValue: name(for: id)), value)
        }
    }
    
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
        XCTAssertEqual(encrypted.data, encryptedData)
        
        let decrypted = try encrypted.decrypt(
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(decrypted, packet)
    }
    
    func testPong() throws {
        
        let encryptedData = Data([0x05, 0x28])
        let packetData = Data([0x18, 0x00])
        let nonce: Nonce = 0x56CFECDD
                
        let packet = try Packet.decrypt(
            encryptedData,
            key: .default,
            nonce: nonce,
            version: .v62
        )
        
        XCTAssertEqual(packet.data, packetData)
        
        let value = PongPacket()
        XCTAssertEncode(value, packet)
        XCTAssertDecode(value, packet)
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
