//
//  PacketOpcode.swift
//  
//
//  Created by Alsey Coleman Miller on 12/4/22.
//

/// MapleStory Opcode
public struct Opcode: RawRepresentable, Equatable, Hashable, Codable {
    
    public let rawValue: UInt16
    
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Opcode: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt16) {
        self.init(rawValue: value)
    }
}

// MARK: - CustomStringConvertible

extension Opcode: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        "0x" + rawValue.toHexadecimal()
    }
    
    public var debugDescription: String {
        description
    }
}
