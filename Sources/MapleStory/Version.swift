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
    
    /// MapleStory v0.62
    static var v62: Version { 62 }
    
    /// MapleStory v0.83
    static var v83: Version { 83 }
}
