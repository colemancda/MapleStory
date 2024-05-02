//
//  KoreanDate.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct KoreanDate: MapleStoryDate, Sendable {
    
    public var rawValue: Int64
    
    public init(rawValue: Int64) {
        self.rawValue = rawValue
    }
}

public extension KoreanDate {
    
    var timeIntervalSince1970: Double {
        fatalError()
    }
    
    init(timeIntervalSince1970 realTimestamp: Double) {
        let offset: Int64 = 116444592000000000
        let time = (realTimestamp / 1000 / 60)
        let koreanValue = (Int64(time * 600000000) + offset)
        self.init(rawValue: koreanValue)
    }
}

extension KoreanDate: CustomStringConvertible { }

extension KoreanDate: ExpressibleByIntegerLiteral { }

// MARK: - Constants

public extension KoreanDate {
    
    static var `default`: KoreanDate {
        150842304000000000
    }
    
    static var zero: KoreanDate {
        94354848000000000
    }
    
    static var permanent: KoreanDate {
        150841440000000000
    }
}
