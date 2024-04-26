//
//  WorldName.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation

public extension World {
    
    enum Name: String, Codable, CaseIterable {
        
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
        case elnido     = "Elnido"
        case kastia     = "Kastia"
        case judis      = "Judis"
        case arkenia    = "Arkenia"
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
}
