//
//  LoginRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/14/22.
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
    
    internal let value2: UInt32
    
    internal let value3: UInt16
    
    internal let value4: UInt32
    
    internal let value5: UInt16
    
    internal let value6: UInt32
    
    internal let value7: UInt8
}
