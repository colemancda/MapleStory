//
//  TemporaryBanDate.swift
//  
//
//  Created by Alsey Coleman Miller on 12/14/22.
//

import Foundation

/// Date type for temporary ban date.
public struct TemporaryBanDate: MapleStoryDate, Sendable {
    
    public var rawValue: Int64
    
    public init(rawValue: Int64) {
        self.rawValue = rawValue
    }
}

public extension TemporaryBanDate {
    
    var timeIntervalSince1970: Double {
        let offset: Int64 = 116444736000000000
        return Double(((rawValue * 10000) + offset) / 1000)
    }
    
    init(timeIntervalSince1970 timeInterval: Double) {
        fatalError()
    }
}
