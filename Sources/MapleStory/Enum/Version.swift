//
//  Version.swift
//  
//
//  Created by Alsey Coleman Miller on 12/14/22.
//

/// MapleStory Version
public struct Version: RawRepresentable, Equatable, Hashable, Codable, Sendable {
    
    public let rawValue: UInt16
    
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Version: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt16) {
        self.init(rawValue: value)
    }
}

// MARK: - CustomStringConvertible

extension Version: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        rawValue.description
    }
    
    public var debugDescription: String {
        description
    }
}

// MARK: - Comparable

extension Version: Comparable {
    
    public static func < (lhs: Version, rhs: Version) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    public static func > (lhs: Version, rhs: Version) -> Bool {
        lhs.rawValue > rhs.rawValue
    }
}

// MARK: - Version

public extension Version {
    
    /// MapleStory v28
    static var v28: Version { 28 } // Pianus boss added
    
    /// MapleStory v40
    static var v40: Version { 40 } // Leaf City added
    
    /// MapleStory v49
    static var v49: Version { 49 } // 4th Job advancement added
    
    /// MapleStory v55
    static var v55: Version { 55 } // Dragon Mount added
    
    /// MapleStory v62
    static var v62: Version { 62 } // Pirate Class added
    
    /// MapleStory v73
    static var v73: Version { 73 } // Cygnus Knights added
    
    /// MapleStory v80
    static var v80: Version { 80 } // Aran class added
    
    /// MapleStory v83
    static var v83: Version { 83 } // Neo City added
    
    /// MapleStory v93
    static var v93: Version { 93 } // Big Bang
}
