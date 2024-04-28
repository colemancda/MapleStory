//
//  ServerListResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 4/27/24.
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
        
        internal init(
            id: UInt8,
            name: String,
            flags: UInt8,
            eventMessage: String,
            rateModifier: UInt8,
            eventXP: UInt8,
            rateModifier2: UInt8,
            dropRate: UInt8,
            value0: UInt8,
            channels: [ServerListResponse.Channel],
            value1: UInt16
        ) {
            self.id = id
            self.name = name
            self.flags = flags
            self.eventMessage = eventMessage
            self.rateModifier = rateModifier
            self.eventXP = eventXP
            self.rateModifier2 = rateModifier2
            self.dropRate = dropRate
            self.value0 = value0
            self.channels = channels
            self.value1 = value1
        }
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

public extension ServerListResponse.World {
    
    init(
        world: MapleStory.World,
        channels: [Channel]
    ) {
        self.id = world.index
        self.name = world.name
        self.flags = world.flags
        self.eventMessage = world.eventMessage
        self.rateModifier = world.rateModifier
        self.eventXP = world.eventXP
        self.rateModifier2 = world.rateModifier
        self.dropRate = world.dropRate
        self.value0 = 0x00
        self.channels = channels.map { .init($0) }
        self.value1 = 0x00
    }
}

public extension ServerListResponse.Channel {
    
    init(_ channel: MapleStory.Channel) {
        self.init(
            name: channel.name,
            load: channel.load,
            value0: 0x01,
            id: numericCast(channel.index)
        )
    }
}
