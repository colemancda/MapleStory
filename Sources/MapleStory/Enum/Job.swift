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
    
    case mapleLeafBrigadier = 800
    
    case gm                 = 900
    case supergm            = 910
    
    case noblesse           = 1000
    
    case dawnWarrior1       = 1100
    case dawnWarrior2       = 1110
    case dawnWarrior3       = 1111
    case dawnWarrior4       = 1112
    
    case blazeWizard1       = 1200
    case blazeWizard2       = 1210
    case blazeWizard3       = 1211
    case blazeWizard4       = 1212
    
    case windArcher1        = 1300
    case windArcher2        = 1310
    case windArcher3        = 1311
    case windArcher4        = 1312
    
    case nightWalker1       = 1400
    case nightWalker2       = 1410
    case nightWalker3       = 1411
    case nightWalker4       = 1412
    
    case thunderBreaker1    = 1500
    case thunderBreaker2    = 1510
    case thunderBreaker3    = 1511
    case thunderBreaker4    = 1512
    
    case legend             = 2000
    case evan               = 2001
    
    case aran1              = 2100
    case aran2              = 2110
    case aran3              = 2111
    case aran4              = 2112
    
    case evan1              = 2200
    case evan2              = 2210
    case evan3              = 2211
    case evan4              = 2212
    case evan5              = 2213
    case evan6              = 2214
    case evan7              = 2215
    case evan8              = 2216
    case evan9              = 2217
    case evan10             = 2218
}

public extension Job {
    
    var type: Class {
        return Class(rawValue: UInt8(self.rawValue / 100))!
    }
}

// MARK: - Class

public enum Class: UInt8 {
    
    case beginner       = 0
    
    case warrior        = 1
    
    case magician       = 2
    
    case bowman         = 3
    
    case thief          = 4
    
    case pirate         = 5
    
    case mapleLeaf      = 8
    
    case gm             = 9
    
    case noblesse       = 10
    
    case dawnWarrior    = 11
    
    case blazeWizard    = 12
    
    case windArcher     = 13
    
    case nightWalker    = 14
    
    case thunderBreaker = 15
    
    case legend         = 20
    
    case aran           = 21
    
    case evan           = 22
}

public extension Class {
    
    init(byte5Encoding value: UInt32) {
        switch value {
        case 2:
            self = .warrior
        case 4:
            self = .magician
        case 8:
            self = .bowman
        case 16:
            self = .thief
        case 32:
            self = .pirate
        case 1024:
            self = .noblesse
        case 2048:
            self = .dawnWarrior
        case 4096:
            self = .blazeWizard
        case 8192:
            self = .windArcher
        case 16384:
            self = .nightWalker
        case 32768:
            self = .thunderBreaker
        default:
            self = .beginner
        }
    }
}

public extension Class {
    
    func isCompatible(for version: MapleStory.Version) -> Bool {
        switch self {
        case .beginner:
            return true
        case .warrior:
            return true
        case .magician:
            return true
        case .bowman:
            return true
        case .thief:
            return true
        case .pirate:
            return version >= .v62
        case .mapleLeaf:
            return true
        case .gm:
            return true
        case .noblesse:
            return version >= .v73
        case .dawnWarrior:
            return version >= .v73
        case .blazeWizard:
            return version >= .v73
        case .windArcher:
            return version >= .v73
        case .nightWalker:
            return version >= .v73
        case .thunderBreaker:
            return version >= .v73
        case .legend:
            return version >= .v80
        case .aran:
            return version >= .v80
        case .evan:
            return version >= .v83
        }
    }
}
