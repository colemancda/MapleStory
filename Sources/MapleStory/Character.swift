//
//  Character.swift
//  
//
//  Created by Alsey Coleman Miller on 12/25/22.
//

import Foundation

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
    
    public var exp: UInt32
    
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
}
