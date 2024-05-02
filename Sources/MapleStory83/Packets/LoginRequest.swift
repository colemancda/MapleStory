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
}
