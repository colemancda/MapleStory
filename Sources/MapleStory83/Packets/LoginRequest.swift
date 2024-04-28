//
//  LoginRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/27/24.
//

import Foundation

/// Login request
public struct LoginRequest: MapleStoryPacket, Decodable, Equatable, Hashable {
    
    public static var clientOpcode: ClientOpcode { .loginPassword }
    
    public static var opcode: Opcode { 0x01 }
    
    public var username: String
    
    public var password: String
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}
