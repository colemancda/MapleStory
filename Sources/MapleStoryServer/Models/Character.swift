//
//  Character.swift
//  
//
//  Created by Alsey Coleman Miller on 1/2/23.
//

import Foundation
import MapleStory
import SwiftBSON

extension Character {
    
    struct BSON: Codable, Equatable, Hashable, Identifiable {
        
        static var collection: String { "characters" }
        
        let id: BSONObjectID
        
        let user: BSONObjectID
        
        let world: BSONObjectID
        
        let characterID: UInt32
        
        let name: CharacterName
        
        let created: Date
        
        var gender: Gender
        
        var skinColor: SkinColor
        
        var face: UInt32
        
        var hair: UInt32
        
        var hairColor: UInt32
        
        var level: UInt8
        
        var job: Job
        
        var str: UInt16
        
        var dex: UInt16
        
        var int: UInt16
        
        var luk: UInt16
        
        var hp: UInt16
        
        var maxHp: UInt16
        
        var mp: UInt16
        
        var maxMp: UInt16
        
        var ap: UInt16
        
        var sp: UInt16
        
        var exp: UInt32
        
        var fame: UInt16
        
        var isMarried: Bool
        
        var currentMap: UInt32
        
        var spawnPoint: UInt8
        
        var isMega: Bool
        
        var cashWeapon: UInt32
        
        var equipment: [UInt8: UInt32]
        
        var maskedEquipment: [UInt8: UInt32]
        
        var isRankEnabled: Bool
        
        var worldRank: UInt32
        
        var rankMove: UInt32
        
        var jobRank: UInt32
        
        var jobRankMove: UInt32
        
        init(
            id: BSONObjectID = BSONObjectID(),
            user: BSONObjectID,
            world: BSONObjectID,
            characterID: UInt32,
            name: CharacterName,
            created: Date = Date(),
            gender: Gender = .male,
            skinColor: SkinColor = .normal,
            face: UInt32 = 20000,
            hair: UInt32 = 30030,
            hairColor: UInt32 = 0,
            level: UInt8 = 1,
            job: Job = .beginner,
            str: UInt16 = 5,
            dex: UInt16 = 5,
            int: UInt16 = 5,
            luk: UInt16 = 5,
            hp: UInt16 = 50,
            maxHp: UInt16 = 50,
            mp: UInt16 = 5,
            maxMp: UInt16 = 5,
            ap: UInt16 = 0,
            sp: UInt16 = 0,
            exp: UInt32 = 0,
            fame: UInt16 = 0,
            isMarried: Bool = false,
            currentMap: UInt32 = 40000,
            spawnPoint: UInt8 = 2,
            isMega: Bool = false,
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
            self.user = user
            self.world = world
            self.characterID = characterID
            self.name = name
            self.created = created
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
    
    
}
