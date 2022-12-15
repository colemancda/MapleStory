//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 12/14/22.
//

import Foundation

/// Date type for temporary ban date.
public struct TemporaryBanDate: MapleStoryDate {
    
    public var rawValue: Int64
    
    public init(rawValue: Int64) {
        self.rawValue = rawValue
    }
}

internal extension TemporaryBanDate {
    
    static var FT_UT_OFFSET: Int64 { 116444736000000000 }
}

public extension TemporaryBanDate {
    
    var timeIntervalSince1970: Int64 {
        ((rawValue * 10000) + Int64(Self.FT_UT_OFFSET)) / 1000
    }
    
    init(timeIntervalSince1970 timeInterval: Int64) {
        fatalError()
    }
}
