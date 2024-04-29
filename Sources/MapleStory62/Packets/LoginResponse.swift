//
//  LoginResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 12/14/22.
//

import Foundation

/// Login Response
public enum LoginResponse: MapleStoryPacket, Equatable, Hashable, Encodable {
    
    public static var opcode: Opcode { 0x00 }
    
    /// Successful authentication and PIN Request packet.
    case success(username: String)
    
    /// Failure
    case failure(reason: LoginError)
}

// MARK: - MapleStoryEncodable

extension LoginResponse: MapleStoryEncodable {
    
    enum MapleCodingKeys: String, CodingKey {
        case username
        case reason
    }
    
    public func encode(to container: MapleStoryEncodingContainer) throws {
        switch self {
        case let .success(username):
            try container.encode(Data([0, 0, 0, 0, 0, 0, 0xFF, 0x6A, 1, 0, 0, 0, 0x4E]))
            try container.encode(username, forKey: MapleCodingKeys.username)
            try container.encode(Data([3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xDC, 0x3D, 0x0B, 0x28, 0x64, 0xC5, 1, 8, 0, 0, 0]))
        case let .failure(reason):
            try container.encode(UInt32(reason.rawValue), forKey: MapleCodingKeys.reason)
            try container.encode(Data([0x00]))
        }
    }
}
