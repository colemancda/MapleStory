//
//  Character.swift
//  
//
//  Created by Alsey Coleman Miller on 12/25/22.
//

import Foundation
import CoreModel

public struct Character: Codable, Equatable, Hashable, Identifiable, Sendable {
    
    public typealias Index = UInt32
    
    public let id: UUID
    
    public let index: Index
    
    public let user: User.ID
    
    public let channel: Channel.ID
        
    public var name: CharacterName
    
    public let created: Date
    
    public var gender: Gender
    
    public var skinColor: SkinColor
    
    public var face: UInt32
    
    public var hair: UInt32
    
    public var hairColor: UInt32
    
    public var level: UInt8
    
    public var job: Job
    
    public var str: UInt16
    
    public var dex: UInt16
    
    public var int: UInt16
    
    public var luk: UInt16
    
    public var hp: UInt16
    
    public var maxHp: UInt16
    
    public var mp: UInt16
    
    public var maxMp: UInt16
    
    public var ap: UInt16
    
    public var sp: UInt16
    
    public var exp: Experience
    
    public var fame: UInt16
    
    public var isMarried: Bool
    
    public var currentMap: UInt32
    
    public var spawnPoint: UInt8
    
    public var isMega: Bool
    
    public var cashWeapon: UInt32
    
    public var equipment: Character.Equipment
    
    public var maskedEquipment: Character.Equipment
    
    public var isRankEnabled: Bool
    
    public var worldRank: UInt32
    
    public var rankMove: UInt32
    
    public var jobRank: UInt32
    
    public var jobRankMove: UInt32
    
    public init(
        id: UUID,
        index: Index,
        user: User.ID,
        channel: Channel.ID,
        created: Date = Date(),
        name: CharacterName,
        gender: Gender = .male,
        skinColor: SkinColor = .pale,
        face: UInt32,
        hair: UInt32,
        hairColor: UInt32,
        level: UInt8 = 0,
        job: Job = .beginner,
        str: UInt16 = 1,
        dex: UInt16 = 1,
        int: UInt16 = 1,
        luk: UInt16 = 1,
        hp: UInt16 = 50,
        maxHp: UInt16 = 50,
        mp: UInt16 = 5,
        maxMp: UInt16 = 5,
        ap: UInt16 = 0,
        sp: UInt16 = 0,
        exp: Experience = 0,
        fame: UInt16 = 0,
        isMarried: Bool = false,
        currentMap: UInt32 = 40000,
        spawnPoint: UInt8 = 2,
        isMega: Bool = true,
        cashWeapon: UInt32 = 0,
        equipment: Character.Equipment = [:],
        maskedEquipment: Character.Equipment = [:],
        isRankEnabled: Bool = true,
        worldRank: UInt32 = 0,
        rankMove: UInt32 = 0,
        jobRank: UInt32 = 0,
        jobRankMove: UInt32 = 0
    ) {
        self.id = id
        self.index = index
        self.user = user
        self.channel = channel
        self.created = created
        self.name = name
        self.gender = gender
        self.skinColor = skinColor
        self.face = face
        self.hair = hair
        self.hairColor = hairColor
        self.level = level
        self.job = job
        self.str = str
        self.dex = dex
        self.int = int
        self.luk = luk
        self.hp = hp
        self.maxHp = maxHp
        self.mp = mp
        self.maxMp = maxMp
        self.ap = ap
        self.sp = sp
        self.exp = exp
        self.fame = fame
        self.isMarried = isMarried
        self.currentMap = currentMap
        self.spawnPoint = spawnPoint
        self.isMega = isMega
        self.cashWeapon = cashWeapon
        self.equipment = equipment
        self.maskedEquipment = maskedEquipment
        self.isRankEnabled = isRankEnabled
        self.worldRank = worldRank
        self.rankMove = rankMove
        self.jobRank = jobRank
        self.jobRankMove = jobRankMove
    }
    
    public enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case index
        case user
        case channel
        case created
        case name
        case gender
        case skinColor
        case face
        case hair
        case hairColor
        case level
        case job
        case str
        case dex
        case int
        case luk
        case hp
        case maxHp
        case mp
        case maxMp
        case ap
        case sp
        case exp
        case fame
        case isMarried
        case currentMap
        case spawnPoint
        case isMega
        case cashWeapon
        case equipment
        case maskedEquipment
        case isRankEnabled
        case worldRank
        case rankMove
        case jobRank
        case jobRankMove
    }
}

// MARK: - Entity

extension Character: Entity {
    
    public static var attributes: [CodingKeys: AttributeType] {
        [
            .index: .int64,
            .created: .date,
            .name: .string,
            .gender: .int16,
            .skinColor: .int16,
            .face: .int64,
            .hair: .int64,
            .hairColor: .int64,
            .level: .int16,
            .job: .int32,
            .str: .int32,
            .dex: .int32,
            .int: .int32,
            .luk: .int32,
            .hp: .int32,
            .maxHp: .int32,
            .mp: .int32,
            .maxMp: .int32,
            .hp: .int32,
            .ap: .int32,
            .sp: .int32,
            .exp: .int64,
            .fame: .int32,
            .isMarried: .bool,
            .currentMap: .int64,
            .spawnPoint: .int16,
            .isMega: .bool,
            .cashWeapon: .int64,
            .equipment: .string,
            .maskedEquipment: .string,
            .isRankEnabled: .bool,
            .worldRank: .int64,
            .rankMove: .int64,
            .jobRank: .int64,
            .jobRankMove: .int64
        ]
    }
    
    public static var relationships: [CodingKeys: Relationship] {
        [
            .user: Relationship(
                id: .user,
                entity: Character.self,
                destination: User.self,
                type: .toOne,
                inverseRelationship: .characters
            ),
            .channel: Relationship(
                id: .channel,
                entity: Character.self,
                destination: Channel.self,
                type: .toOne,
                inverseRelationship: .characters
            )
        ]
    }
}
