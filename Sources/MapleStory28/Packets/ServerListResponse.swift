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
    
    public static var opcode: ServerOpcode { .loginWorldList }
    
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
        
        public var flags: UInt8 // Ribbon on world - 0 = normal, 1 = event, 2 = new, 3 = hot
        
        public var eventMessage: String
        
        public var eventXP: UInt8
        
        public var channels: [Channel]
        
        internal init(
            name: String,
            flags: UInt8 = 0,
            eventMessage: String,
            eventXP: UInt8,
            channels: [ServerListResponse.Channel]
        ) {
            self.name = name
            self.flags = flags
            self.eventMessage = eventMessage
            self.channels = channels
            self.eventXP = eventXP
        }
    }
}

public extension ServerListResponse {
    
    /// Channel
    struct Channel: Codable, Equatable, Hashable, Identifiable, Sendable {
        
        public let name: String
        
        public let load: UInt32 // 1200.0 * pop / maxPop
        
        public let world: UInt8
        
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
        self.flags = world.ribbon.rawValue
        self.eventMessage = world.eventMessage
        self.eventXP = world.eventXP
        self.channels = channels.map { .init($0, world: world.index) }
    }
}

public extension ServerListResponse.Channel {
    
    init(_ channel: MapleStory.Channel, world: World.Index) {
        self.init(
            name: channel.name,
            load: channel.load,
            world: world,
            id: numericCast(channel.index)
        )
    }
}
