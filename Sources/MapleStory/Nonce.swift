//
//  Nonce.swift
//  
//
//  Created by Alsey Coleman Miller on 12/14/22.
//

@_implementationOnly import CMapleStory

/// MapleStory Cryptographic Nonce
public struct Nonce: RawRepresentable, Equatable, Hashable, Codable {
    
    public var rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

public extension Nonce {
    
    /// Initialize `Nonce` with random value.
    init() {
        let randomValue = UInt32.random(in: .min ..< .max)
        self.init(rawValue: randomValue)
    }
    
    /// Shuffle IV
    mutating func shuffle() {
        var iv = self.rawValue.bigEndian
        withUnsafeMutableBytes(of: &iv) {
            $0.baseAddress!.withMemoryRebound(to: UInt8.self, capacity: 4) {
                maple_shuffle_iv($0)
            }
        }
        self.rawValue = UInt32(bigEndian: iv)
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Nonce: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt32) {
        self.init(rawValue: value)
    }
}

// MARK: - CustomStringConvertible

extension Nonce: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        "0x" + rawValue.toHexadecimal()
    }
    
    public var debugDescription: String {
        description
    }
}

// MARK: - MapleStoryCodable

extension Nonce: MapleStoryCodable {
    
    public init(from container: MapleStoryDecodingContainer) throws {
        self.rawValue = try container.decode(UInt32.self, isLittleEndian: false)
    }
    
    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(rawValue, isLittleEndian: false)
    }
}
