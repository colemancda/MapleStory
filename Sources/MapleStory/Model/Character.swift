//
//  Character.swift
//  
//
//  Created by Alsey Coleman Miller on 12/25/22.
//

import Foundation
import CoreModel

/// MapleStory Character
public struct Character: Codable, Equatable, Hashable, Identifiable, Sendable {
    
    public typealias Index = UInt32
    
    public let id: UUID
    
    public let index: Index
    
    public let user: User.ID
    
    public let world: World.ID
    
    public let channel: Channel.ID?
        
    public var name: CharacterName
    
    public let created: Date
    
    public var gender: Gender
    
    public var skinColor: SkinColor
    
    public var face: UInt32
    
    public var hair: UInt32
    
    public var hairColor: UInt32
    
    public var level: UInt16
    
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
    
    public var currentMap: Map.ID
    
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
        world: User.ID,
        channel: Channel.ID? = nil,
        created: Date = Date(),
        name: CharacterName,
        gender: Gender = .male,
        skinColor: SkinColor = .pale,
        face: UInt32,
        hair: UInt32,
        hairColor: UInt32,
        level: UInt16 = 1,
        job: Job = .beginner,
        str: UInt16 = 4,
        dex: UInt16 = 4,
        int: UInt16 = 4,
        luk: UInt16 = 4,
        hp: UInt16 = 50,
        maxHp: UInt16 = 50,
        mp: UInt16 = 5,
        maxMp: UInt16 = 5,
        ap: UInt16 = 0,
        sp: UInt16 = 0,
        exp: Experience = 0,
        fame: UInt16 = 0,
        isMarried: Bool = false,
        currentMap: Map.ID = .mushroomTown, // Mushroom Town
        spawnPoint: UInt8 = 1,
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
        self.world = world
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
        case world
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
            .level: .int32,
            .job: .int32,
            .str: .int32,
            .dex: .int32,
            .int: .int32,
            .luk: .int32,
            .hp: .int32,
            .maxHp: .int32,
            .mp: .int32,
            .maxMp: .int32,
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
            .world: Relationship(
                id: .world,
                entity: Character.self,
                destination: World.self,
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

// MARK: - Supporting Types

public extension Character {
    
    struct CreationValues: Equatable, Hashable, Sendable {
        
        public let name: CharacterName
        
        public let face: UInt32
        
        public let hair: UInt32
        
        public let hairColor: UInt32
        
        public let skinColor: SkinColor
        
        public let top: UInt32
        
        public let bottom: UInt32
        
        public let shoes: UInt32
        
        public let weapon: UInt32
        
        public let gender: Gender
        
        public let str: UInt16
        
        public let dex: UInt16
        
        public let int: UInt16
        
        public let luk: UInt16
        
        public let job: Job
        
        public init(
            name: CharacterName,
            face: UInt32,
            hair: UInt32,
            hairColor: UInt32,
            skinColor: SkinColor = .pale,
            top: UInt32,
            bottom: UInt32,
            shoes: UInt32,
            weapon: UInt32,
            gender: Gender = .male,
            str: UInt16 = 4,
            dex: UInt16 = 4,
            int: UInt16 = 4,
            luk: UInt16 = 4,
            job: Job = .beginner
        ) {
            self.name = name
            self.face = face
            self.hair = hair
            self.hairColor = hairColor
            self.skinColor = skinColor
            self.top = top
            self.bottom = bottom
            self.shoes = shoes
            self.weapon = weapon
            self.gender = gender
            self.str = str
            self.dex = dex
            self.int = int
            self.luk = luk
            self.job = job
        }
    }
}

public extension Character {
    
    init(
        create value: CreationValues,
        index: Character.Index,
        user: User.ID,
        world: World.ID,
        id: UUID = UUID(),
        created: Date = Date()
    ) {
        let currentMap: Map.ID
        switch value.job {
        case .beginner:
            currentMap = .mushroomTown
        case .legend:
            currentMap = .aranTutorialStart
        case .noblesse:
            currentMap = .startingMapNoblesse
        default:
            currentMap = .mushroomTown
        }
        self.init(
            id: id,
            index: index,
            user: user,
            world: world,
            created: created,
            name: value.name,
            gender: value.gender,
            skinColor: value.skinColor,
            face: value.face,
            hair: value.hair,
            hairColor: value.hairColor,
            job: value.job,
            str: value.str,
            dex: value.dex,
            int: value.int,
            luk: value.luk,
            currentMap: currentMap,
            spawnPoint: 1
        )
    }
}
