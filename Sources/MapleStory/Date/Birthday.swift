//
//  Birthday.swift
//
//
//  Created by Alsey Coleman Miller on 5/3/24.
//

import Foundation

/// MapleStory Birthday
public struct Birthday: RawRepresentable, Equatable, Hashable, Codable, Sendable {
    
    public let rawValue: UInt32
    
    public init?(rawValue: UInt32) {
        guard let date = Self.date(from: rawValue) else {
            return nil
        }
        self.init(rawValue)
        assert(self.date == date)
    }
    
    private init(_ raw: UInt32) {
        self.rawValue = raw
    }
}

internal extension Birthday {
    
    init(date: Date) {
        let dateString = Self.formatter.string(from: date)
        guard let rawValue = UInt32(dateString) else {
            fatalError("Invalid string")
        }
        self.init(rawValue)
    }
    
    var date: Date {
        guard let date = Self.date(from: rawValue) else {
            fatalError()
        }
        return date
    }
}

internal extension Birthday {
    
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = .init(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static func date(from rawValue: UInt32) -> Date? {
        formatter.date(from: rawValue.description)
    }
}

// MARK: - MapleStoryDate

extension Birthday: MapleStoryDate {
    
    public var timeIntervalSince1970: Double {
        date.timeIntervalSince1970
    }
    
    public init(timeIntervalSince1970: Double) {
        self.init(date: Date(timeIntervalSince1970: timeIntervalSince1970))
    }
}

// MARK: - CustomStringConvertible

extension Birthday: CustomStringConvertible, CustomDebugStringConvertible { }

// MARK: - Constants

public extension Birthday {
    
    /// The date MapleGlobal released (May 11 2005)
    static var mapleStoryGlobal: Birthday {
        .init(20050511)
    }
}
