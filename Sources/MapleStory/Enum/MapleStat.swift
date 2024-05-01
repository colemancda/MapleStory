//
//  MapleStat.swift
//  
//
//  Created by Alsey Coleman Miller on 12/4/22.
//

/// The `MapleStat` enum represents various stats that a character in the game can have.
public struct MapleStat: OptionSet, Codable, Sendable {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

// MARK: - Extensions

public extension MapleStat {
    
    init?(byte5Encoding value: UInt32) {
        switch value {
        case 64:
            self = .str
        case 128:
            self = .dex
        case 256:
            self = .int
        case 512:
            self = .luk
        default:
            return nil
        }
    }
}

// MARK: - Constants

public extension MapleStat {
    
    static var skin: MapleStat {
        return MapleStat(rawValue: 0x1)
    }
    
    static var face: MapleStat {
        return MapleStat(rawValue: 0x2)
    }
    
    static var hair: MapleStat {
        return MapleStat(rawValue: 0x4)
    }
    
    static var level: MapleStat {
        return MapleStat(rawValue: 0x10)
    }
    
    static var job: MapleStat {
        return MapleStat(rawValue: 0x20)
    }
    
    static var str: MapleStat {
        return MapleStat(rawValue: 0x40)
    }
    
    static var dex: MapleStat {
        return MapleStat(rawValue: 0x80)
    }
    
    static var int: MapleStat {
        return MapleStat(rawValue: 0x100)
    }
    
    static var luk: MapleStat {
        return MapleStat(rawValue: 0x200)
    }
    
    static var hp: MapleStat {
        return MapleStat(rawValue: 0x400)
    }
    
    static var maxHP: MapleStat {
        return MapleStat(rawValue: 0x800)
    }
    
    static var mp: MapleStat {
        return MapleStat(rawValue: 0x1000)
    }
    
    static var maxMP: MapleStat {
        return MapleStat(rawValue: 0x2000)
    }
    
    static var availableAP: MapleStat {
        return MapleStat(rawValue: 0x4000)
    }
    
    static var availableSP: MapleStat {
        return MapleStat(rawValue: 0x8000)
    }
    
    static var exp: MapleStat {
        return MapleStat(rawValue: 0x10000)
    }
    
    static var fame: MapleStat {
        return MapleStat(rawValue: 0x20000)
    }
    
    static var meso: MapleStat {
        return MapleStat(rawValue: 0x40000)
    }
    
    static var pet: MapleStat {
        return MapleStat(rawValue: 0x180008)
    }
    
    static var gachaExp: MapleStat {
        return MapleStat(rawValue: 0x200000)
    }
}
