//
//  Character.swift
//  
//
//  Created by Alsey Coleman Miller on 12/25/22.
//

import Foundation
import CoreModel

public struct Character: Codable, Equatable, Hashable, Identifiable {
    
    public let id: UInt32
    
    public let created: Date
    
    public var name: CharacterName
    
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
    
    public var equipment: [UInt8: UInt32]
    
    public var maskedEquipment: [UInt8: UInt32]
    
    public var isRankEnabled: Bool
    
    public var worldRank: UInt32
    
    public var rankMove: UInt32
    
    public var jobRank: UInt32
    
    public var jobRankMove: UInt32
    
    public init(
        id: UInt32,
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
        equipment: [UInt8 : UInt32] = [:],
        maskedEquipment: [UInt8 : UInt32] = [:],
        isRankEnabled: Bool = true,
        worldRank: UInt32 = 0,
        rankMove: UInt32 = 0,
        jobRank: UInt32 = 0,
        jobRankMove: UInt32 = 0
    ) {
        self.id = id
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
}
