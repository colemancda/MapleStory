//
//  Date.swift
//  
//
//  Created by Alsey Coleman Miller on 12/14/22.
//

import Foundation

/// MapleStory Date
public protocol MapleStoryDate: RawRepresentable, Hashable, Codable, MapleStoryCodable where Self.RawValue: FixedWidthInteger, Self.RawValue: Codable {
    
    var timeIntervalSince1970: Int64 { get }
    
    init(timeIntervalSince1970: Int64)
    
    init(rawValue: RawValue)
}

// MARK: - MapleStoryCodable

extension MapleStoryDate where Self.RawValue == Int64 {
    
    public init(from container: MapleStoryDecodingContainer) throws {
        let rawValue = try container.decode(Int64.self)
        self.init(rawValue: rawValue)
    }
    
    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(rawValue)
    }
}

extension MapleStoryDate where Self.RawValue == Int32 {
    
    public init(from container: MapleStoryDecodingContainer) throws {
        let rawValue = try container.decode(Int32.self)
        self.init(rawValue: rawValue)
    }
    
    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(rawValue)
    }
}

// MARK: - CustomStringConvertible

extension MapleStoryDate where Self: CustomStringConvertible {
    
    public var description: String {
        Date(self).description
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension MapleStoryDate where Self: ExpressibleByIntegerLiteral {
    
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
        self.init(timeIntervalSince1970: Int64(date.timeIntervalSince1970))
    }
}

public extension Date {
    
    init<T: MapleStoryDate>(_ date: T) {
        self.init(timeIntervalSince1970: TimeInterval(date.timeIntervalSince1970))
    }
}
