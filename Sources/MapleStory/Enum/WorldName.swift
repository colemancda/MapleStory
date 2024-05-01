//
//  WorldName.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation

public extension World {
    
    enum Name: String, Codable, CaseIterable, Sendable {
        
        case scania     = "Scania"
        case bera       = "Bera"
        case broa       = "Broa"
        case windia     = "Windia"
        case khaini     = "Khaini"
        case bellocan   = "Bellocan"
        case mardia     = "Mardia"
        case kradia     = "Kradia"
        case yellonde   = "Yellonde"
        case demethos   = "Demethos"
        case galicia    = "Galicia"
        
        // Big-Bang
        case elnido     = "Elnido"
        case zenith     = "Zenith"
        
        // Post Big Bang
        case arcania    = "Arcania"
        case chaos      = "Chaos"
        case nova       = "Nova"
        case kastia     = "Kastia"
        case judis      = "Judis"
        case plana      = "Plana"
    }
}

public extension World.Name {
    
    init?(index: World.Index) {
        guard let value = Self.allCases.enumerated().first(where: { $0.offset == index })?.element else {
            return nil
        }
        self = value
    }
    
    var index: World.Index {
        World.Index(Self.allCases.firstIndex(of: self)!)
    }
    
    /// Version the world was introduced.
    var version: Version {
        switch self {
        case .scania:
            return 1
        case .bera:
            return 2
        case .broa:
            return 7
        case .windia:
            return .v14
        case .khaini:
            return 18
        case .bellocan:
            return .v28
        case .mardia:
            return 35
        case .kradia:
            return 44
        case .yellonde:
            return 59
        case .demethos:
            return .v62
        case .galicia:
            return .v80
        case .elnido:
            return .v93
        case .zenith:
            return .v93
        default:
            return 94 // Post-Big Bang
        }
    }
    
    func isCompatible(for version: MapleStory.Version) -> Bool {
        version >= self.version
    }
}
