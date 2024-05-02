//
//  BuddyListNotification.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public enum BuddyListNotification: MapleStoryPacket, Encodable, Equatable, Hashable, Sendable {
    
    public static var opcode: ServerOpcode { .buddylist }
    
    case update([Buddy])
}

extension BuddyListNotification: MapleStoryEncodable {
    
    public func encode(to container: MapleStoryEncodingContainer) throws {
        switch self {
        case let .update(list):
            try container.encode(UInt8(7))
            try container.encode(list, forKey: CodingKeys.update)
            for _ in 0 ..< list.count {
                try container.encode(UInt32(0))
            }
        }
    }
}

// MARK: - Supporting Types

public extension BuddyListNotification {
    
    struct Buddy: Codable, Equatable, Hashable, Identifiable, Sendable {
        
        public let id: UInt32
        
        public let name: CharacterName
        
        internal let value0: UInt8
        
        public let channel: Int32
    }
}
