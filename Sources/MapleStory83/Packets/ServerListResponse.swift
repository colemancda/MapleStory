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
public enum ServerListResponse: MapleStoryPacket, Equatable, Hashable, Sendable {
    
    public static var opcode: Opcode { .init(server: .serverList) }
    
    case world(MapleStory.World.Index, World)
    case end
}

extension ServerListResponse: Identifiable {
    
    public var id: MapleStory.World.Index {
        switch self {
        case .world(let index, _):
            return index
        case .end:
            return 0xFF
        }
    }
}

extension ServerListResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case world
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UInt8.self, forKey: .id)
        if id == 0xFF {
            self = .end
        } else {
            let world = try container.decode(World.self, forKey: .world)
            self = .world(id, world)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        switch self {
        case let .world(_, world):
            try world.encode(to: encoder)
        case .end:
            break
        }
    }
}

// MARK: - Supporting Types

public extension ServerListResponse {
    
    struct World: Codable, Equatable, Hashable, Sendable {
                
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
    struct Channel: Codable, Equatable, Hashable, Identifiable, Sendable {
        
        public let name: String
        
        public let load: UInt32
        
        public let value0: UInt8
        
        public let id: UInt16
    }
}

public extension ServerListResponse {
    
    static func world(_ world: MapleStory.World, channels: [MapleStory.Channel]) -> ServerListResponse {
        .world(world.index, .init(world: world, channels: channels))
    }
}

public extension ServerListResponse.World {
        
    init(
        world: MapleStory.World,
        channels: [MapleStory.Channel]
    ) {
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
