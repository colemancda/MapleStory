//
//  AllCharactersResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory

public enum AllCharactersResponse: MapleStoryPacket, Equatable, Hashable, Sendable {
    
    public static var opcode: Opcode { .init(server: .viewAllCharacters) }
        
    /// Count of all characters in world
    case count(
        status: Status,
        worlds: UInt32,
        characters: UInt32
    )
    
    /// Characters per world
    case characters(
        world: MapleStory.World.Index,
        characters: [Character],
        picMode: PicCodeStatus
    )
}

public extension AllCharactersResponse {
    
    var status: UInt8 {
        switch self {
        case .count(let status, _, _):
            return status.rawValue
        case .characters:
            return 0x00
        }
    }
}

extension AllCharactersResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        
        case status
        case characters
        case worlds
        case world
        case picMode
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let statusRawValue = try container.decode(UInt8.self, forKey: .status)
        switch statusRawValue {
        case 0x00:
            let world = try container.decode(UInt8.self, forKey: .world)
            let characters = try container.decode([Character].self, forKey: .characters)
            let picMode = try container.decode(PicCodeStatus.self, forKey: .picMode)
            self = .characters(world: world, characters: characters, picMode: picMode)
        default:
            guard let status = Status(rawValue: statusRawValue) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid status \(statusRawValue)"))
            }
            let worlds = try container.decode(UInt32.self, forKey: .worlds)
            let characters = try container.decode(UInt32.self, forKey: .characters)
            self = .count(status: status, worlds: worlds, characters: characters)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(status, forKey: .status)
        switch self {
        case let .count(_, worlds, characters):
            try container.encode(worlds, forKey: .worlds)
            try container.encode(characters, forKey: .characters)
        case let .characters(world, characters, picMode):
            try container.encode(world, forKey: .world)
            try container.encode(characters, forKey: .characters)
            try container.encode(picMode, forKey: .picMode)
        }
    }
}

public extension AllCharactersResponse {
    
    struct CharacterCount: Equatable, Hashable, Codable, Sendable {
        
        let status: Status
        
        let worldCount: UInt32
        
        let characterCount: UInt32
    }
}

public extension AllCharactersResponse {
    
    enum Status: UInt8, Codable, CaseIterable, Sendable {
        
        case foundCharacters            = 1
        case alreadyConnectedToServer   = 2
        case unknownError               = 3
        case notFound                   = 5
    }
}


public extension AllCharactersResponse {
    
    struct Character: Codable, Equatable, Hashable, Sendable {
        
        public let stats: CharacterStats
        
        public let appearance: CharacterAppeareance
                
        public let rank: Rank
    }
}

public extension AllCharactersResponse {
    
    struct CharacterStats: Codable, Equatable, Hashable, Sendable {
        
        public let id: UInt32
        
        public let name: CharacterName
        
        public let gender: Gender
        
        public let skinColor: SkinColor
        
        public let face: UInt32
        
        public let hair: Hair
        
        public let value0: UInt64
        
        public let value1: UInt64
        
        public let value2: UInt64
        
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
        
        public let isMarried: UInt32
        
        public let currentMap: Map.ID
        
        public let spawnPoint: UInt8
        
        internal let value3: UInt32
    }
}

public extension AllCharactersResponse {
    
    struct CharacterAppeareance: Codable, Equatable, Hashable, Sendable {
        
        public let gender: Gender
        
        public let skinColor: SkinColor
        
        public let face: UInt32
        
        public let mega: Bool
        
        public let hair: Hair
        
        public let equipment: Equipment
        
        public let maskedEquipment: Equipment
        
        public let cashWeapon: UInt32
        
        public let value0: UInt32
        
        public let value1: UInt64
    }
}

public extension AllCharactersResponse {
    
    enum Rank: Equatable, Hashable, Sendable {
        
        case disabled
        case enabled(worldRank: UInt32, rankMove: UInt32, jobRank: UInt32, jobRankMove: UInt32)
        
        public init(worldRank: UInt32, rankMove: UInt32, jobRank: UInt32, jobRankMove: UInt32) {
            self = .enabled(worldRank: worldRank, rankMove: rankMove, jobRank: jobRank, jobRankMove: jobRankMove)
        }
    }
}

extension AllCharactersResponse.Rank: Codable {
    
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

public extension AllCharactersResponse {
    
    struct Equipment: Equatable, Hashable, Sendable {
        
        var value: MapleStory.Character.Equipment
        
        init(_ value: MapleStory.Character.Equipment = [:]) {
            self.value = value
        }
    }
}

internal extension AllCharactersResponse.Equipment {
    
    var dictionary: [UInt8: UInt32] {
        [UInt8: UInt32].init(value)
    }
}

extension AllCharactersResponse.Equipment: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (UInt8, UInt32)...) {
        self.init(.init(uniqueKeysWithValues: elements))
    }
}

extension AllCharactersResponse.Equipment: Codable {
    
    public init(from decoder: Decoder) throws {
        let value = try MapleStory.Character.Equipment.init(from: decoder)
        self.init(value)
    }
    
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

extension AllCharactersResponse.Equipment: MapleStoryCodable {
    
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

public extension AllCharactersResponse.Character {
    
    init(_ character: Character) {
        self.stats = .init(
            id: character.index,
            name: character.name,
            gender: character.gender,
            skinColor: character.skinColor,
            face: character.face,
            hair: character.hair,
            value0: 0,
            value1: 0,
            value2: 0,
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
            isMarried: character.isMarried ? 1 : 0,
            currentMap: character.currentMap,
            spawnPoint: character.spawnPoint,
            value3: 0
        )
        self.appearance = .init(
            gender: character.gender,
            skinColor: character.skinColor,
            face: character.face,
            mega: character.isMega,
            hair: character.hair,
            equipment: .init(character.equipment),
            maskedEquipment: .init(character.maskedEquipment),
            cashWeapon: character.cashWeapon,
            value0: 0,
            value1: 0
        )
        self.rank = character.isRankEnabled ? .enabled(
            worldRank: character.worldRank,
            rankMove: character.rankMove,
            jobRank: character.jobRank,
            jobRankMove: character.jobRankMove
        ) : .disabled
    }
}
