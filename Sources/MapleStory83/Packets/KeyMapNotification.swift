//
//  KeyMapNotification.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public struct KeyMapNotification: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x107 }
    
    public var keyMap: [UInt8: KeyBinding]
}

extension KeyMapNotification: MapleStoryCodable {
    
    static var count: UInt8 { 90 }
    
    public init(from container: MapleStoryDecodingContainer) throws {
        let value0 = try container.decode(UInt8.self)
        guard value0 == 0 else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unexpected value"))
        }
        self.keyMap = [:]
        self.keyMap.reserveCapacity(Int(Self.count))
        for index in 0 ..< Self.count {
            let type = try container.decode(UInt8.self)
            let action = try container.decode(UInt32.self)
            if type != 0 || action != 0 {
                self.keyMap[index] = KeyBinding(type: type, action: action)
            }
        }
    }
    
    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(UInt8(0))
        for index in 0 ..< Self.count {
            let binding = self.keyMap[index]
            try container.encode(binding?.type ?? 0)
            try container.encode(binding?.action ?? 0)
        }
    }
}
