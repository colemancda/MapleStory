//
//  AllCharactersResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 12/21/22.
//

import Foundation

public enum AllCharactersResponse: MapleStoryPacket, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x08 }
    
    public typealias Character = CharacterListResponse.Character
    
    /// Count of all characters in world
    case count(characters: UInt32, value0: UInt32)
    
    /// Characters per world
    case characters(world: UInt8, characters: [Character])
}

extension AllCharactersResponse: Encodable {
    
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
