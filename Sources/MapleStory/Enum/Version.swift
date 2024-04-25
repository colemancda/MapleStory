//
//  Version.swift
//  
//
//  Created by Alsey Coleman Miller on 12/14/22.
//

/// MapleStory Version
public struct Version: RawRepresentable, Equatable, Hashable, Codable {
    
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

// MARK: - Version

public extension Version {
    
    /// MapleStory v28
    static var v28: Version { 28 }
    
    /// MapleStory v40
    static var v40: Version { 40 }
    
    /// MapleStory v55
    static var v55: Version { 55 }
    
    /// MapleStory v62
    static var v62: Version { 62 }
    
    /// MapleStory v83
    static var v83: Version { 83 }
}
