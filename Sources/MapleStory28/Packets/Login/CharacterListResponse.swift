//
//  CharacterListResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory

/// Character List Response
public struct CharacterListResponse: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ServerOpcode { .characterList }
    
    public let status: UInt8 // 0x00
    
    public let characters: [CharacterListResponse.Character]
    
    public init(
        characters: [Character]
    ) {
        self.status = 0x00
        self.characters = characters
    }
}

public extension CharacterListResponse {
    
    struct Character: Codable, Equatable, Hashable, Sendable, Identifiable {
        
        public let id: UInt32
        
        public let stats: CharacterStats
        
        public let appearance: CharacterAppeareance
        
        internal let value0: UInt32 // character selection
        
        public let rank: Rank
    }
}

public extension CharacterListResponse {
    
    struct CharacterStats: Codable, Equatable, Hashable, Sendable {
                
        public let name: CharacterName
        
        public let gender: Gender
        
        public let skinColor: SkinColor
        
        public let face: UInt32
        
        public let hair: Hair
        
        public let petCash: UInt64 // Pet cash ID
        
        public let level: UInt8
        
        public let job: Job
        
        public let str: UInt16
        
        public let dex: UInt16
        
        public let int: UInt16
        
        public let luk: UInt16
        
        public let hp: UInt16
        
        public let maxHp: UInt16
        
        public let mp: UInt16
        
        public let maxMp: UInt16
        
        public let ap: UInt16
        
        public let sp: UInt16
        
        public let exp: UInt32
        
        public let fame: UInt16
                
        public let currentMap: Map.ID
        
        public let spawnPoint: UInt8
    }
}

public extension CharacterListResponse {
    
    struct CharacterAppeareance: Codable, Equatable, Hashable, Sendable {
        
        public let gender: Gender
        
        public let skinColor: SkinColor
        
        public let face: UInt32
        
        public let mega: Bool
        
        public let hair: Hair
        
        public let equipment: Equipment
        
        public let maskedEquipment: Equipment
        
        public let cashWeapon: UInt32
    }
}

public extension CharacterListResponse {
    
    enum Rank: Equatable, Hashable, Sendable {
        
        case disabled
        case enabled(worldRank: UInt32, rankMove: UInt32, jobRank: UInt32, jobRankMove: UInt32)
        
        public init(worldRank: UInt32, rankMove: UInt32, jobRank: UInt32, jobRankMove: UInt32) {
            self = .enabled(worldRank: worldRank, rankMove: rankMove, jobRank: jobRank, jobRankMove: jobRankMove)
        }
    }
}

extension CharacterListResponse.Rank: Codable {
    
    enum CodingKeys: String, CodingKey {
        
        case isWorldRankEnabled
        case worldRank
        case rankMove
        case jobRank
        case jobRankMove
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let isWorldRankEnabled = try container.decode(Bool.self, forKey: .isWorldRankEnabled)
        if isWorldRankEnabled {
            let worldRank = try container.decode(UInt32.self, forKey: .worldRank)
            let rankMove = try container.decode(UInt32.self, forKey: .rankMove)
            let jobRank = try container.decode(UInt32.self, forKey: .jobRank)
            let jobRankMove = try container.decode(UInt32.self, forKey: .jobRankMove)
            self = .enabled(worldRank: worldRank, rankMove: rankMove, jobRank: jobRank, jobRankMove: jobRankMove)
        } else {
            self = .disabled
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .disabled:
            try container.encode(false, forKey: .isWorldRankEnabled)
        case .enabled(let worldRank, let rankMove, let jobRank, let jobRankMove):
            try container.encode(true, forKey: .isWorldRankEnabled)
            try container.encode(worldRank, forKey: .worldRank)
            try container.encode(rankMove, forKey: .rankMove)
            try container.encode(jobRank, forKey: .jobRank)
            try container.encode(jobRankMove, forKey: .jobRankMove)
        }
    }
}

public extension CharacterListResponse {
    
    struct Equipment: Equatable, Hashable, Sendable {
        
        var value: MapleStory.Character.Equipment
        
        init(_ value: MapleStory.Character.Equipment = [:]) {
            self.value = value
        }
    }
}

internal extension CharacterListResponse.Equipment {
    
    var dictionary: [UInt8: UInt32] {
        [UInt8: UInt32].init(value)
    }
}

extension CharacterListResponse.Equipment: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (UInt8, UInt32)...) {
        self.init(.init(uniqueKeysWithValues: elements))
    }
}

extension CharacterListResponse.Equipment: Codable {
    
    public init(from decoder: Decoder) throws {
        let value = try MapleStory.Character.Equipment.init(from: decoder)
        self.init(value)
    }
    
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

extension CharacterListResponse.Equipment: MapleStoryCodable {
    
    public init(from container: MapleStoryDecodingContainer) throws {
        self.init()
        var key = try container.decode(UInt8.self)
        while key != 0xFF {
            // read value
            let value = try container.decode(UInt32.self, isLittleEndian: false)
            self.value[key] = value
            // read next
            key = try container.decode(UInt8.self)
        }
    }
    
    public func encode(to container: MapleStoryEncodingContainer) throws {
        for element in self.value {
            try container.encode(element.key)
            try container.encode(element.value, isLittleEndian: false)
        }
        try container.encode(UInt8(0xFF))
    }
}

public extension CharacterListResponse.Character {
    
    init(_ character: Character) {
        self.id = character.index
        self.stats = .init(character)
        self.appearance = .init(
            gender: character.gender,
            skinColor: character.skinColor,
            face: character.face,
            mega: character.isMega,
            hair: character.hair,
            equipment: .init(character.equipment),
            maskedEquipment: .init(character.maskedEquipment),
            cashWeapon: character.cashWeapon
        )
        self.rank = character.isRankEnabled ? .enabled(
            worldRank: character.worldRank,
            rankMove: character.rankMove,
            jobRank: character.jobRank,
            jobRankMove: character.jobRankMove
        ) : .disabled
        self.value0 = 0x00
    }
}

public extension CharacterListResponse.CharacterStats {
    
    init(_ character: Character) {
        self.init(
            name: character.name,
            gender: character.gender,
            skinColor: character.skinColor,
            face: character.face,
            hair: character.hair,
            petCash: 0x00, // TODO: Pet Cash
            level: numericCast(character.level),
            job: character.job,
            str: character.str,
            dex: character.dex,
            int: character.int,
            luk: character.luk,
            hp: character.hp,
            maxHp: character.maxHp,
            mp: character.mp,
            maxMp: character.maxMp,
            ap: character.ap,
            sp: character.sp,
            exp: character.exp.rawValue,
            fame: character.fame,
            currentMap: character.currentMap,
            spawnPoint: character.spawnPoint
        )
    }
}
