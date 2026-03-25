//
//  BuddyListModifyRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Buddy list modification request packet.
public enum BuddyListModifyRequest: Equatable, Hashable, Sendable {
    
    /// Add buddy by name
    case add(name: String)
    
    /// Accept pending buddy request
    case accept(characterID: UInt32)
    
    /// Remove buddy
    case remove(characterID: UInt32)
}

// MARK: - MapleStoryPacket

extension BuddyListModifyRequest: MapleStoryPacket {
    
    public static var opcode: ClientOpcode { .buddylistModify }
}

// MARK: - Mode

internal extension BuddyListModifyRequest {
    
    enum Mode: UInt8, Codable {
        case add = 1
        case accept = 2
        case remove = 3
    }
    
    var mode: Mode {
        switch self {
        case .add:
            return .add
        case .accept:
            return .accept
        case .remove:
            return .remove
        }
    }
}

// MARK: - MapleStoryDecodable

extension BuddyListModifyRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        let mode = try container.decode(BuddyListModifyRequest.Mode.self)
        switch mode {
        case .add:
            let name = try container.decode(String.self)
            self = .add(name: name)
        case .accept:
            let characterID = try container.decode(UInt32.self)
            self = .accept(characterID: characterID)
        case .remove:
            let characterID = try container.decode(UInt32.self)
            self = .remove(characterID: characterID)
        }
    }
}
