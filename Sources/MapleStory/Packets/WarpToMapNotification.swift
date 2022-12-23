//
//  WarpToMapNotification.swift
//  
//
//  Created by Alsey Coleman Miller on 12/23/22.
//

import Foundation

public enum WarpToMapNotification: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x5C }
    
    case characterInfo(CharacterInfo)
}

public extension WarpToMapNotification {
    
    typealias CharacterStats = CharacterListResponse.CharacterStats
    
    struct CharacterInfo: Codable, Equatable, Hashable {
        
        public let channel: UInt32
        
        public let random: UInt32
        
        public let stats: CharacterStats
        
        public let buddyListSize: UInt8
        
        public let meso: UInt32
        
        public let equipSlots: UInt8 // 100
        
        public let useSlots: UInt8 // 100
        
        public let setupSlots: UInt8 // 100
        
        public let etcSlots: UInt8 // 100
        
        public let cashSlots: UInt8 // 100
        
        public let equipped: [Item]
        
        public let equip: [Item]
        
        public let use: [Item]
        
        public let setup: [Item]
        
        public let etc: [Item]
        
        public let cash: [Item]
        
        public let skills: [Skill]
        
        public let questInfo: QuestInfo
        
        public let rings: [Ring]
        
        public let date: Date
    }
    
    struct Item: Codable, Equatable, Hashable {
        
        
    }
    
    struct Skill: Codable, Equatable, Hashable, Identifiable {
        
        public let id: UInt32
        
        public let level: UInt32
        
        public let masterLevel: UInt32?
    }
    
    struct QuestInfo: Codable, Equatable, Hashable {
        
        
    }
    
    struct Ring: Codable, Equatable, Hashable {
        
    }
}

extension WarpToMapNotification: MapleStoryEncodable {
    
    public func encode(to container: MapleStoryEncodingContainer) throws {
        switch self {
        case let .characterInfo(characterInfo):
            try container.encode(characterInfo, forKey: CodingKeys.characterInfo)
        }
    }
}

extension WarpToMapNotification.CharacterInfo: MapleStoryEncodable {
    
    static var magic: Data { Data([0xff, 0xc9, 0x9a, 0x3b]) }
    
    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(channel, forKey: CodingKeys.channel)
        try container.encode(UInt8(1))
        try container.encode(UInt8(1))
        try container.encode(UInt16(0))
        try container.encode(random, forKey: CodingKeys.random)
        try container.encode(Data([0xF8, 0x17, 0xD7, 0x13, 0xCD, 0xC5, 0xAD, 0x78]))
        try container.encode(Int64(-1))
        try container.encode(stats, forKey: CodingKeys.stats)
        try container.encode(buddyListSize, forKey: CodingKeys.buddyListSize)
        try container.encode(meso, forKey: CodingKeys.meso)
        try container.encode(equipSlots, forKey: CodingKeys.equipSlots)
        try container.encode(useSlots, forKey: CodingKeys.useSlots)
        try container.encode(setupSlots, forKey: CodingKeys.setupSlots)
        try container.encode(etcSlots, forKey: CodingKeys.etcSlots)
        try container.encode(cashSlots, forKey: CodingKeys.cashSlots)
        try container.encodeArray(equipped, forKey: CodingKeys.equipped)
        try container.encode(UInt16(0))
        try container.encodeArray(equip, forKey: CodingKeys.equip)
        try container.encode(UInt8(0))
        try container.encodeArray(use, forKey: CodingKeys.use)
        try container.encode(UInt8(0))
        try container.encodeArray(setup, forKey: CodingKeys.setup)
        try container.encode(UInt8(0))
        try container.encodeArray(etc, forKey: CodingKeys.etc)
        try container.encode(UInt8(0))
        try container.encodeArray(cash, forKey: CodingKeys.cash)
        try container.encode(UInt8(0))
        try container.encode(UInt16(skills.count))
        try container.encodeArray(skills, forKey: CodingKeys.skills)
        try container.encode(UInt16(0))
        try container.encode(questInfo, forKey: CodingKeys.questInfo)
        try container.encodeArray(rings, forKey: CodingKeys.rings)
        for _ in 0 ..< 15 {
            try container.encode(Self.magic)
        }
        try container.encode(UInt32(0))
        try container.encode(date, forKey: CodingKeys.date)
    }
}
