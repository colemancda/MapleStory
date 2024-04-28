//
//  LoginResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 4/27/24.
//

import Foundation

/// Login Response
public enum LoginResponse: MapleStoryPacket, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x00 }
    
    /// Successful authentication and PIN Request packet.
    case success(username: String)
}

// MARK: - Encodable

extension LoginResponse: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case username
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .success(username):
            try container.encode(username, forKey: CodingKeys.username)
        }
    }
}

// MARK: - MapleStoryEncodable

extension LoginResponse: MapleStoryEncodable {
    
    public func encode(to container: MapleStoryEncodingContainer) throws {
        switch self {
        case let .success(username):
            try container.encode(Data([0, 0, 0, 0, 0, 0, 0xFF, 0x6A, 1, 0, 0, 0, 0x4E]))
            try container.encode(username, forKey: CodingKeys.username)
            try container.encode(Data([3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xDC, 0x3D, 0x0B, 0x28, 0x64, 0xC5, 1, 8, 0, 0, 0]))
        }
    }
}
