//
//  LoginRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 5/1/24.
//

import Foundation
import MapleStory

/// Login request
public struct LoginRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: Opcode { .init(client: .loginRequest) }
    
    public var username: String
    
    public var password: String
    
    internal let value0: UInt16
    
    internal let value1: UInt32
    
    public var hardwareID: UInt32
    
    internal let value2: UInt32
    
    internal let value3: UInt16
    
    internal let value4: UInt32
    
    internal let value5: UInt16
}
