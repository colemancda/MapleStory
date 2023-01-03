//
//  CreateCharacterRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct CreateCharacterRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x16 }
    
    public let name: String
    
    public let face: UInt32
    
    public let hair: UInt32
    
    public let hairColor: UInt32
    
    public let skinColor: UInt32
    
    public let top: UInt32
    
    public let bottom: UInt32
    
    public let shoes: UInt32
    
    public let weapon: UInt32
    
    public let gender: Gender
    
    public let str: UInt8
    
    public let dex: UInt8
    
    public let int: UInt8
    
    public let luk: UInt8
}

public extension Character {
    
    init?(id: Character.ID, request: CreateCharacterRequest) {
        guard let name = CharacterName(rawValue: request.name),
              request.skinColor <= UInt8.max,
              let skinColor = SkinColor(rawValue: UInt8(request.skinColor)) else {
            return nil
        }
        self.id = id
        self.name = name
        self.face = request.face
        self.hair = request.hair
        self.hairColor = request.hairColor
        self.skinColor = skinColor
        self.gender = request.gender
        self.str = numericCast(request.str)
        self.dex = numericCast(request.dex)
        self.int = numericCast(request.int)
        self.luk = numericCast(request.luk)
        //self.weapon = request.weapon
        //self.top = request.top
        //self.bottom = request.bottom
        //self.shoes = request.shoes
        self.cashWeapon = 0
        self.created = Date()
        self.level = 0
        self.job = .beginner
        self.hp = 50
        self.maxHp = 50
        self.mp = 5
        self.maxMp = 5
        self.ap = 0
        self.sp = 0
        self.exp = 0
        self.fame = 0
        self.cashWeapon = 0
        self.isMarried = false
        self.isMega = true
        self.currentMap = 40000
        self.spawnPoint = 2
        self.equipment = [:]
        self.maskedEquipment = [:]
        self.isRankEnabled = true
        self.worldRank = 0
        self.rankMove = 0
        self.jobRank = 0
        self.jobRankMove = 0
    }
}
