//
//  Job.swift
//  
//
//  Created by Alsey Coleman Miller on 12/21/22.
//

/// MapleStory Character Job
public enum Job: UInt16, Codable, CaseIterable {
    
    case beginner           = 0
    
    case warrior            = 100
    case fighter            = 110
    case crusader           = 111
    case hero               = 112
    case page               = 120
    case whiteknight        = 121
    case paladin            = 122
    case spearman           = 130
    case dragonknight       = 131
    case darkknight         = 132
    
    case magician           = 200
    case fpWizard           = 210
    case fpMage             = 211
    case fpArchmage         = 212
    case ilWizard           = 220
    case ilMage             = 221
    case ilArchmage         = 222
    case cleric             = 230
    case priest             = 231
    case bishop             = 232
    
    case bowman             = 300
    case hunter             = 310
    case ranger             = 311
    case bowmaster          = 312
    case crossbowman        = 320
    case sniper             = 321
    case marksman           = 322
    
    case thief              = 400
    case assassin           = 410
    case hermit             = 411
    case nightlord          = 412
    case bandit             = 420
    case chiefbandit        = 421
    case shadower           = 422
    
    case pirate             = 500
    case brawler            = 510
    case marauder           = 511
    case buccaneer          = 512
    case gunslinger         = 520
    case outlaw             = 521
    case corsair            = 522
    
    case gm                 = 900
    case supergm            = 910
}

public enum Class: UInt8 {
    
    case beginner = 0
    
    case warrior = 1
    
    case magician = 2
    
    case bowman = 3
    
    case thief = 4
    
    case pirate = 5
    
    case gm = 9
}

public extension Job {
    
    var type: Class {
        return Class(rawValue: UInt8(self.rawValue / 100))!
    }
}
