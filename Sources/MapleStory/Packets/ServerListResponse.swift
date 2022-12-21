//
//  ServerListResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 12/20/22.
//

import Foundation

/// Server List Response
///
/// A packet detailing a server and its channels.
public enum ServerListResponse: MapleStoryPacket, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x0A }
    
    case world(World)
    case end
}

extension ServerListResponse: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .world(let world):
            try world.encode(to: encoder)
        case .end:
            try EndList().encode(to: encoder)
        }
    }
}

// MARK: - Supporting Types

public extension ServerListResponse {
    
    struct World: Encodable, Equatable, Hashable, Identifiable {
        
        public let id: UInt8
        
        public var name: String
        
        public var flags: UInt8
        
        public var eventMessage: String
        
        public var rateModifier: UInt8
        
        public var eventXP: UInt8
        
        public var rateModifier2: UInt8
        
        public var dropRate: UInt8
        
        public var value0: UInt8
            
        public var channels: [Channel]
        
        public var value1: UInt16
    }
}

public extension ServerListResponse {
    
    /// Channel
    struct Channel: Encodable, Equatable, Hashable {
        
        public let name: String
        
        public let load: UInt32
        
        public let value0: UInt8
        
        public let id: UInt16
    }
}

internal extension ServerListResponse {
    
    struct EndList: Encodable, Equatable, Hashable {
        
        let id: UInt8
        
        public init() {
            self.id = 0xFF
        }
    }
}
