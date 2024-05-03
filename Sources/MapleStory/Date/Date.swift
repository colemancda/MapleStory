//
//  Date.swift
//  
//
//  Created by Alsey Coleman Miller on 12/14/22.
//

import Foundation

/// MapleStory Date
public protocol MapleStoryDate: RawRepresentable, Hashable, Codable where Self.RawValue: FixedWidthInteger, Self.RawValue: Codable {
    
    var timeIntervalSince1970: Double { get }
    
    init(timeIntervalSince1970: Double)
}

public protocol MapleStoryExpressibleByIntegerLiteralDate: MapleStoryDate, ExpressibleByIntegerLiteral {
    
    init(rawValue: RawValue)
}

// MARK: - CustomStringConvertible

extension MapleStoryDate where Self: CustomStringConvertible {
    
    public var description: String {
        Date(self).description
    }
    
    public func description(with locale: Locale?) -> String {
        Date(self).description(with: locale)
    }
}

// MARK: - CustomDebugStringConvertible

extension MapleStoryDate where Self: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        Date(self).debugDescription
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension MapleStoryExpressibleByIntegerLiteralDate {
    
    public init(integerLiteral value: RawValue) {
        self.init(rawValue: value)
    }
}

// MARK: - Date Conversion

public extension MapleStoryDate {
    
    init() {
        self.init(Date())
    }
    
    init(_ date: Date) {
        self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }
}

public extension Date {
    
    init<T: MapleStoryDate>(_ date: T) {
        self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }
}

// MARK: - Constants

public extension Date {
    
    /// The date MapleGlobal released (May 11 2005)
    static var mapleGlobalRelease: Date {
        Date(timeIntervalSince1970: 1_115_769_600.0) // 2005-05-11
    }
}
