//
//  LoginRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/27/24.
//

import Foundation

/// Login request
public struct LoginRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
        
    public static var opcode: ClientOpcode { .loginRequest }

    public var username: String
    
    public var password: String
    
    internal let value0: UInt16

    internal let value1: UInt32

    public var hardwareID: UInt32

    internal init(
        username: String,
        password: String,
        value0: UInt16,
        value1: UInt32,
        hardwareID: UInt32
    ) {
        self.username = username
        self.password = password
        self.value0 = value0
        self.value1 = value1
        self.hardwareID = hardwareID
    }

    public init(
        username: String,
        password: String,
        hardwareID: UInt32 = 0
    ) {
        self.init(
            username: username,
            password: password,
            value0: 0,
            value1: 0,
            hardwareID: hardwareID
        )
    }
}
