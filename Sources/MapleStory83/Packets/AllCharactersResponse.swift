//
//  AllCharactersResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public enum AllCharactersResponse: MapleStoryPacket, Equatable, Hashable {
    
    public static var opcode: Opcode { .init(server: .viewAllCharacters) }
    
    public typealias Character = CharacterListResponse.Character
    
    /// Count of all characters in world
    case count(characters: UInt32, value0: UInt32)
    
    /// Characters per world
    case characters(world: UInt8, characters: [Character])
}

public extension AllCharactersResponse {
    
    static func count(_ value: Int) -> AllCharactersResponse {
        let count = UInt32(value)
        let unk = count + (3 - count % 3)
        return .count(characters: count, value0: unk)
    }
}

extension AllCharactersResponse: Codable {
    
    enum PacketType: UInt8, Codable {
        
        case characters     = 0
        case count          = 1
    }
    
    enum CodingKeys: String, CodingKey {
        
        case packetType
        case characters
        case count
        case value0
        case world
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let packetType = try container.decode(PacketType.self, forKey: .packetType)
        switch packetType {
        case .count:
            let count = try container.decode(UInt32.self, forKey: .count)
            let value0 = try container.decode(UInt32.self, forKey: .value0)
            self = .count(characters: count, value0: value0)
        case .characters:
            let world = try container.decode(UInt8.self, forKey: .world)
            let characters = try container.decode([Character].self, forKey: .characters)
            self = .characters(world: world, characters: characters)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .count(characters: count, value0: value0):
            try container.encode(PacketType.count, forKey: .packetType)
            try container.encode(count, forKey: .count)
            try container.encode(value0, forKey: .value0)
        case let .characters(world: world, characters: characters):
            try container.encode(PacketType.characters, forKey: .packetType)
            try container.encode(world, forKey: .world)
            try container.encode(characters, forKey: .characters)
        }
    }
}
