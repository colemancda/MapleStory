//
//  CharacterListResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 12/21/22.
//

import Foundation

public struct CharacterListResponse: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x0B }
    
    internal let value0: UInt8 // 0x00
    
    public let characters: [Character]
    
    public let maxCharacters: UInt32
}

public extension CharacterListResponse {
    
    struct Character: Codable, Equatable, Hashable {
        
        public let stats: CharacterStats
        
        public let appearance: CharacterAppeareance
        
        public let rank: Rank
    }
}

public extension CharacterListResponse {
    
    struct CharacterStats: Codable, Equatable, Hashable {
        
        public let id: UInt32
        
        public let name: CharacterName
        
        public let gender: Gender
        
        public let skinColor: SkinColor
        
        public let face: UInt32
        
        public let hair: UInt32
        
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
        
        public let currentMap: UInt32
        
        public let spawnPoint: UInt8
        
        internal let value3: UInt32
    }
}

public extension CharacterListResponse {
    
    struct CharacterAppeareance: Codable, Equatable, Hashable {
        
        public let gender: Gender
        
        public let skinColor: SkinColor
        
        public let face: UInt32
        
        public let mega: Bool
        
        public let hair: UInt32
        
        public let equipment: Equipment
        
        public let maskedEquipment: Equipment
        
        public let cashWeapon: UInt32
        
        public let value0: UInt32
        
        public let value1: UInt64
    }
}

public extension CharacterListResponse {
    
    enum Rank: Equatable, Hashable {
        
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
    
    struct Equipment: Equatable, Hashable {
        
        struct Element: Equatable, Hashable {
            
            let key: UInt8
            
            let value: UInt32
        }
        
        var values: [Element]
        
        public init(_ values: [UInt8: UInt32] = [:]) {
            self.values = []
            self.values.reserveCapacity(values.count)
            for (key, value) in values.lazy.sorted(by: { $0.key < $1.key }) {
                self.values.append(Element(key: key, value: value))
            }
        }
    }
}

internal extension CharacterListResponse.Equipment {
    
    var dictionary: [UInt8: UInt32] {
        var values = [UInt8: UInt32]()
        values.reserveCapacity(self.values.count)
        for element in self.values {
            values[element.key] = element.value
        }
        return values
    }
}

extension CharacterListResponse.Equipment: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (UInt8, UInt32)...) {
        self.init()
        self.values.reserveCapacity(elements.count)
        elements.forEach {
            self.values.append(Element(key: $0.0, value: $0.1))
        }
    }
}

extension CharacterListResponse.Equipment: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        return "[" + values.reduce("", { $0 + ($0.isEmpty ? "" : ", ") + "\($1.key): 0x\($1.value.toHexadecimal())" }) + "]"
    }
    
    public var debugDescription: String {
        return description
    }
}

extension CharacterListResponse.Equipment: Codable {
    
    public init(from decoder: Decoder) throws {
        let values = try [UInt8: UInt32].init(from: decoder)
        self.init(values)
    }
    
    public func encode(to encoder: Encoder) throws {
        try dictionary.encode(to: encoder)
    }
}

extension CharacterListResponse.Equipment: MapleStoryCodable {
    
    public init(from container: MapleStoryDecodingContainer) throws {
        self.init()
        var key = try container.decode(UInt8.self)
        while key != 0xFF {
            // read value
            let value = try container.decode(UInt32.self, isLittleEndian: false)
            self.values.append(Element(key: key, value: value))
            // read next
            key = try container.decode(UInt8.self)
        }
    }
    
    public func encode(to container: MapleStoryEncodingContainer) throws {
        for element in self.values {
            try container.encode(element.key)
            try container.encode(element.value, isLittleEndian: false)
        }
        try container.encode(UInt8(0xFF))
    }
}
