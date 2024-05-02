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
        
        let data = Data([0x0D, 0x00, 0x1C, 0x00, 0x00, 0x00, 0x90, 0xE0, 0xCE, 0x6E, 0x5C, 0x2C, 0x1D, 0x1F, 0x08])
        
        let value = HelloPacket(
            recieveNonce: 0x90E0CE6E,
            sendNonce: 0x5C2C1D1F,
            region: .global
        )
        
        XCTAssertEqual(value.version, .v28)
        XCTAssertEncode(value, data)
        XCTAssertDecode(value, data)
    }
    
    func testLoginRequest() throws {
        
        let packet: Packet<ClientOpcode> = [
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
        XCTAssertEqual(packet.data.count, 45)
    }
    
    func testLoginSuccess() throws {
        
        let packet: Packet<ServerOpcode> = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x0A, 0x00, 0x63, 0x6F, 0x6C, 0x65, 0x6D, 0x61, 0x6E, 0x63, 0x64, 0x61, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        
        let value = LoginResponse.success(
            MapleStory28.LoginResponse.Success(
                account: 1,
                gender: .male,
                isAdmin: false,
                username: "colemancda"
            )
        )
        
        XCTAssertDecode(value, packet)
        XCTAssertEncode(value, packet)
    }
    
    func testLoginFailure() throws {
        
        let packet: Packet<ServerOpcode> = [1, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        
        let value = LoginResponse.failure(.alreadyLoggedIn)
        
        XCTAssertDecode(value, packet)
        XCTAssertEncode(value, packet)
        
        let encryptedData = Data([77, 65, 82, 65, 118, 195, 228, 214, 201, 110, 170, 145, 151, 208, 130, 25, 199, 219, 141, 197, 211, 204, 12, 13, 38, 157, 30, 174, 217, 211, 173, 174, 247, 121, 120])
        
        let encryptedPacket = try packet.encrypt(
            key: nil,
            nonce: Nonce(rawValue: UInt32(bigEndian: UInt32(bytes: (86, 68, 174, 190)))),
            version: .v28
        )
        
        XCTAssertEqual(encryptedData, encryptedPacket.data)
    }
    
    func testAcceptLicense() {
        
        let packet: Packet<ClientOpcode> = [0x06, 0x01]
        let value = AcceptLicenseRequest()
        XCTAssertDecode(value, packet)
        XCTAssertEncode(value, packet)
    }
    
    func testCheckLogin() {
        
        let packet: Packet<ClientOpcode> = [0x08, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00]
        XCTAssertEqual(packet.opcode, .checkLogin)
        
        let value = PinOperationRequest(
            value0: 1,
            value1: 1,
            pinCode: nil
        )
        
        XCTAssertDecode(value, packet)
    }
    
    func testSetGender() {
        
        let packet: Packet<ClientOpcode> = [0x07, 0x01, 0x00]
        let value = SetGenderRequest(gender: .male)
        XCTAssertDecode(value, packet)
        XCTAssertEncode(value, packet)
    }
    
    func testWorldList() {
        
        let packet: Packet<ServerOpcode> = [0x09, 0x00, 0x06, 0x00, 0x53, 0x63, 0x61, 0x6E, 0x69, 0x61, 0x02, 0x00, 0x00, 0x00, 0x09, 0x12, 0x00, 0x53, 0x63, 0x61, 0x6E, 0x69, 0x61, 0x20, 0x2D, 0x20, 0x43, 0x68, 0x61, 0x6E, 0x6E, 0x65, 0x6C, 0x20, 0x31, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x12, 0x00, 0x53, 0x63, 0x61, 0x6E, 0x69, 0x61, 0x20, 0x2D, 0x20, 0x43, 0x68, 0x61, 0x6E, 0x6E, 0x65, 0x6C, 0x20, 0x32, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x12, 0x00, 0x53, 0x63, 0x61, 0x6E, 0x69, 0x61, 0x20, 0x2D, 0x20, 0x43, 0x68, 0x61, 0x6E, 0x6E, 0x65, 0x6C, 0x20, 0x33, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x12, 0x00, 0x53, 0x63, 0x61, 0x6E, 0x69, 0x61, 0x20, 0x2D, 0x20, 0x43, 0x68, 0x61, 0x6E, 0x6E, 0x65, 0x6C, 0x20, 0x34, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x12, 0x00, 0x53, 0x63, 0x61, 0x6E, 0x69, 0x61, 0x20, 0x2D, 0x20, 0x43, 0x68, 0x61, 0x6E, 0x6E, 0x65, 0x6C, 0x20, 0x35, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x12, 0x00, 0x53, 0x63, 0x61, 0x6E, 0x69, 0x61, 0x20, 0x2D, 0x20, 0x43, 0x68, 0x61, 0x6E, 0x6E, 0x65, 0x6C, 0x20, 0x36, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x12, 0x00, 0x53, 0x63, 0x61, 0x6E, 0x69, 0x61, 0x20, 0x2D, 0x20, 0x43, 0x68, 0x61, 0x6E, 0x6E, 0x65, 0x6C, 0x20, 0x37, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x12, 0x00, 0x53, 0x63, 0x61, 0x6E, 0x69, 0x61, 0x20, 0x2D, 0x20, 0x43, 0x68, 0x61, 0x6E, 0x6E, 0x65, 0x6C, 0x20, 0x38, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x12, 0x00, 0x53, 0x63, 0x61, 0x6E, 0x69, 0x61, 0x20, 0x2D, 0x20, 0x43, 0x68, 0x61, 0x6E, 0x6E, 0x65, 0x6C, 0x20, 0x39, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00]

        let value = ServerListResponse.world(0, MapleStory28.ServerListResponse.World(
            name: "Scania",
            flags: 2,
            eventMessage: "",
            eventXP: 0,
            channels: [
                MapleStory28.ServerListResponse.Channel(
                    name: "Scania - Channel 1",
                    load: 0,
                    world: 0,
                    id: 0
                ),
                MapleStory28.ServerListResponse.Channel(
                    name: "Scania - Channel 2",
                    load: 0,
                    world: 0,
                    id: 1
                ),
                MapleStory28.ServerListResponse.Channel(
                    name: "Scania - Channel 3",
                    load: 0,
                    world: 0,
                    id: 2
                ),
                MapleStory28.ServerListResponse.Channel(
                    name: "Scania - Channel 4",
                    load: 0,
                    world: 0,
                    id: 3
                ),
                MapleStory28.ServerListResponse.Channel(
                    name: "Scania - Channel 5",
                    load: 0,
                    world: 0,
                    id: 4
                ),
                MapleStory28.ServerListResponse.Channel(
                    name: "Scania - Channel 6",
                    load: 0,
                    world: 0,
                    id: 5),
                MapleStory28.ServerListResponse.Channel(
                    name: "Scania - Channel 7",
                    load: 0,
                    world: 0,
                    id: 6
                ),
                MapleStory28.ServerListResponse.Channel(
                    name: "Scania - Channel 8",
                    load: 0,
                    world: 0,
                    id: 7
                ),
                MapleStory28.ServerListResponse.Channel(
                    name: "Scania - Channel 9",
                    load: 0,
                    world: 0,
                    id: 8
                )
            ])
        )
        
        XCTAssertDecode(value, packet)
        XCTAssertEncode(value, packet)
    }
    
    func testEndWorldList() {
        
        let packet: Packet<ServerOpcode> = [0x09, 0xFF]
        let value = ServerListResponse.end
        XCTAssertDecode(value, packet)
        XCTAssertEncode(value, packet)
    }
}
