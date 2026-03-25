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
    
    // MARK: - Properties
    
    public let id: UUID
    
    public let index: Index
    
    public let user: User.ID
    
    public let world: World.ID
    
    public var session: Session.ID?
    
    public let name: CharacterName
    
    public let created: Date
    
    public let gender: Gender
    
    public var skinColor: SkinColor
    
    public var face: UInt32
    
    public var hair: Hair
        
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

    public var meso: UInt32

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
    
    /// Maximum number of buddies allowed in buddy list (default: 25)
    public var buddyCapacity: UInt8
    
    // MARK: - Initialization
    
    public init(
        id: UUID,
        index: Index,
        user: User.ID,
        world: World.ID,
        session: Session.ID? = nil,
        created: Date = Date(),
        name: CharacterName,
        gender: Gender = .male,
        skinColor: SkinColor = .normal,
        face: UInt32,
        hair: Hair = .buzz(.black),
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
        meso: UInt32 = 0,
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
        jobRankMove: UInt32 = 0,
        buddyCapacity: UInt8 = 25
    ) {
        self.id = id
        self.index = index
        self.user = user
        self.world = world
        self.session = session
        self.created = created
        self.name = name
        self.gender = gender
        self.skinColor = skinColor
        self.face = face
        self.hair = hair
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
        self.meso = meso
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
        self.buddyCapacity = buddyCapacity
    }
    
    // MARK: - Codable
    
    public enum CodingKeys: String, CodingKey, CaseIterable, Sendable {
        case id
        case index
        case user
        case world
        case session
        case created
        case name
        case gender
        case skinColor
        case face
        case hair
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
        case meso
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
        case skillMacros
        case buddyCapacity
        case buddies
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        index = try container.decode(Index.self, forKey: .index)
        user = try container.decode(User.ID.self, forKey: .user)
        world = try container.decode(World.ID.self, forKey: .world)
        session = try container.decodeIfPresent(Session.ID.self, forKey: .session)
        created = try container.decode(Date.self, forKey: .created)
        name = try container.decode(CharacterName.self, forKey: .name)
        gender = try container.decode(Gender.self, forKey: .gender)
        skinColor = try container.decode(SkinColor.self, forKey: .skinColor)
        face = try container.decode(UInt32.self, forKey: .face)
        hair = try container.decode(Hair.self, forKey: .hair)
        level = try container.decode(UInt16.self, forKey: .level)
        job = try container.decode(Job.self, forKey: .job)
        str = try container.decode(UInt16.self, forKey: .str)
        dex = try container.decode(UInt16.self, forKey: .dex)
        int = try container.decode(UInt16.self, forKey: .int)
        luk = try container.decode(UInt16.self, forKey: .luk)
        hp = try container.decode(UInt16.self, forKey: .hp)
        maxHp = try container.decode(UInt16.self, forKey: .maxHp)
        mp = try container.decode(UInt16.self, forKey: .mp)
        maxMp = try container.decode(UInt16.self, forKey: .maxMp)
        ap = try container.decode(UInt16.self, forKey: .ap)
        sp = try container.decode(UInt16.self, forKey: .sp)
        exp = try container.decode(Experience.self, forKey: .exp)
        fame = try container.decode(UInt16.self, forKey: .fame)
        meso = try container.decode(UInt32.self, forKey: .meso)
        isMarried = try container.decode(Bool.self, forKey: .isMarried)
        currentMap = try container.decode(Map.ID.self, forKey: .currentMap)
        spawnPoint = try container.decode(UInt8.self, forKey: .spawnPoint)
        isMega = try container.decode(Bool.self, forKey: .isMega)
        cashWeapon = try container.decode(UInt32.self, forKey: .cashWeapon)
        equipment = try container.decode(Character.Equipment.self, forKey: .equipment)
        maskedEquipment = try container.decode(Character.Equipment.self, forKey: .maskedEquipment)
        isRankEnabled = try container.decode(Bool.self, forKey: .isRankEnabled)
        worldRank = try container.decode(UInt32.self, forKey: .worldRank)
        rankMove = try container.decode(UInt32.self, forKey: .rankMove)
        jobRank = try container.decode(UInt32.self, forKey: .jobRank)
        jobRankMove = try container.decode(UInt32.self, forKey: .jobRankMove)
        buddyCapacity = try container.decodeIfPresent(UInt8.self, forKey: .buddyCapacity) ?? 25
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(index, forKey: .index)
        try container.encode(user, forKey: .user)
        try container.encode(world, forKey: .world)
        try container.encodeIfPresent(session, forKey: .session)
        try container.encode(created, forKey: .created)
        try container.encode(name, forKey: .name)
        try container.encode(gender, forKey: .gender)
        try container.encode(skinColor, forKey: .skinColor)
        try container.encode(face, forKey: .face)
        try container.encode(hair, forKey: .hair)
        try container.encode(level, forKey: .level)
        try container.encode(job, forKey: .job)
        try container.encode(str, forKey: .str)
        try container.encode(dex, forKey: .dex)
        try container.encode(int, forKey: .int)
        try container.encode(luk, forKey: .luk)
        try container.encode(hp, forKey: .hp)
        try container.encode(maxHp, forKey: .maxHp)
        try container.encode(mp, forKey: .mp)
        try container.encode(maxMp, forKey: .maxMp)
        try container.encode(ap, forKey: .ap)
        try container.encode(sp, forKey: .sp)
        try container.encode(exp, forKey: .exp)
        try container.encode(fame, forKey: .fame)
        try container.encode(meso, forKey: .meso)
        try container.encode(isMarried, forKey: .isMarried)
        try container.encode(currentMap, forKey: .currentMap)
        try container.encode(spawnPoint, forKey: .spawnPoint)
        try container.encode(isMega, forKey: .isMega)
        try container.encode(cashWeapon, forKey: .cashWeapon)
        try container.encode(equipment, forKey: .equipment)
        try container.encode(maskedEquipment, forKey: .maskedEquipment)
        try container.encode(isRankEnabled, forKey: .isRankEnabled)
        try container.encode(worldRank, forKey: .worldRank)
        try container.encode(rankMove, forKey: .rankMove)
        try container.encode(jobRank, forKey: .jobRank)
        try container.encode(jobRankMove, forKey: .jobRankMove)
        try container.encode(buddyCapacity, forKey: .buddyCapacity)
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
            .meso: .int64,
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
            .jobRankMove: .int64,
            .buddyCapacity: .int16
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
            .session: Relationship(
                id: .session,
                entity: Character.self,
                destination: Session.self,
                type: .toOne,
                inverseRelationship: .character
            ),
            .skillMacros: Relationship(
                id: .skillMacros,
                entity: Character.self,
                destination: SkillMacro.self,
                type: .toMany,
                inverseRelationship: .character
            )
        ]
    }
}

// MARK: - Supporting Types

public extension Character {
    
    struct CreationValues: Equatable, Hashable, Sendable {
        
        public let name: CharacterName
        
        public let face: UInt32
        
        public let hair: Hair
        
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
            hair: Hair,
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
            job: value.job,
            str: value.str,
            dex: value.dex,
            int: value.int,
            luk: value.luk,
            currentMap: currentMap,
            spawnPoint: 0
        )
    }
}
